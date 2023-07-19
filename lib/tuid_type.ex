defmodule TUID.ParameterizedType do
  @moduledoc """
  Documentation for `TUID.ParameterizedType`.

  ParameterizedType implemention for use with Ecto to use TUIDs (tagged, unique ids) as Ecto Types.

  """

  use Ecto.ParameterizedType

  alias TUID.Base58

  require Logger

  @doc """
  Callback to convert the options specified in the field macro into parameters
  to be used in other callbacks.

  This function is called at compile time, and should raise if invalid values are
  specified. It is idiomatic that the parameters returned from this are a map.
  `field` and `schema` will be injected into the options automatically.

  For example, this schema specification

      schema "my_table" do
        field :my_field, MyParameterizedType, opt1: :foo, opt2: nil
      end

  will result in the call:

      MyParameterizedType.init([schema: "my_table", field: :my_field, opt1: :foo, opt2: nil])

  """
  @impl true
  def init(opts) do
    schema = Keyword.fetch!(opts, :schema)
    field = Keyword.fetch!(opts, :field)
    uniq = Uniq.UUID.init(schema: schema, field: field, version: 7, default: :raw, dump: :raw)

    case opts[:primary_key] do
      true ->
        prefix = Keyword.get(opts, :prefix) || raise "`:prefix` option is required"

        %{
          primary_key: true,
          schema: schema,
          prefix: prefix,
          uniq: uniq
        }

      _any ->
        %{
          schema: schema,
          field: field,
          uniq: uniq
        }
    end
  end

  @impl true
  def type(_params), do: :uuid

  @doc """
  Casts the given input to the ParameterizedType with the given parameters.

  Specifically, convert and validate a TUID, such as `user_C19xa4ANGXSz72USEyc2m` to a binary UUID for storage into the DB.

  On successful validation, returns `{:ok, input}`.

  Otherwise returns `:error` or `{:error, err_msg}`

  For more information on casting, see `c:Ecto.Type.cast/1`.
  """

  @impl true
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, params) do
    with {:ok, prefix, _uuid} <- tuid_to_uuid(data, params),
         {prefix, prefix} <- {prefix, prefix(params)} do
      {:ok, data}
    else
      {:error, err_msg} -> {:error, "invalid tuid or tag: #{err_msg}"}
      _ -> {:error, "invalid tuid or tag: #{data}"}
    end
  end

  defp tuid_to_uuid(tuid, _params) when is_binary(tuid) do
    with [prefix, b58_str] <- String.split(tuid, "_"),
         {:ok, uuid} <- Base58.decode_uuid(b58_str) do
      {:ok, prefix, uuid}
    else
      _ -> {:error, "failed to parse tuid: #{tuid}"}
    end
  end

  defp tuid_to_uuid(tuid, _params) do
    {:error, "unknown tuid or unexpected tuid type: #{tuid}"}
  end

  defp prefix(%{primary_key: true, prefix: prefix}), do: prefix

  # If we deal with a belongs_to assocation we need to fetch the prefix from
  # the associations schema module
  defp prefix(%{schema: schema, field: field}) do
    %{related: schema, related_key: field} = schema.__schema__(:association, field)
    {:parameterized, __MODULE__, %{prefix: prefix}} = schema.__schema__(:type, field)

    prefix
  end

  @doc """
  This is a fallback method to cast when we don't know the prefix type.
  """
  def cast(nil), do: {:ok, nil}

  def cast(data) do
    with {:ok, _prefix, _uuid} <- tuid_to_uuid(data, nil) do
      {:ok, data}
    else
      {:error, err_msg} -> {:error, "invalid tuid or tag: #{err_msg}"}
      _ -> {:error, "invalid tuid or tag: #{data}"}
    end
  end

  @doc """
  Loads the given term into a ParameterizedType.

  It receives a `loader` function in case the parameterized
  type is also a composite type. In order to load the inner
  type, the `loader` must be called with the inner type and
  the inner value as argument.

  For more information on loading, see `c:Ecto.Type.load/1`.
  Note that this callback *will* be called when loading a `nil`
  value, unlike `c:Ecto.Type.load/1`.
  """
  @impl true
  def load(data, loader, params) do
    case Uniq.UUID.load(data, loader, params.uniq) do
      {:ok, nil} -> {:ok, nil}
      {:ok, uuid} -> {:ok, uuid_to_slug(uuid, params)}
      :error -> {:error, "load error: #{data}"}
    end
  end

  defp uuid_to_slug(uuid, params) do
    "#{prefix(params)}_#{Base58.encode_uuid(uuid)}"
  end

  @doc """
  Dumps the given term into an Ecto native type.

  It receives a `dumper` function in case the parameterized
  type is also a composite type. In order to dump the inner
  type, the `dumper` must be called with the inner type and
  the inner value as argument.

  For more information on dumping, see `c:Ecto.Type.dump/1`.
  Note that this callback *will* be called when dumping a `nil`
  value, unlike `c:Ecto.Type.dump/1`.
  """
  @impl true
  def dump(nil, _, _), do: {:ok, nil}

  def dump(slug, dumper, params) do
    case tuid_to_uuid(slug, params) do
      {:ok, _prefix, uuid} -> Uniq.UUID.dump(uuid, dumper, params.uniq)
      {:error, err_msg} -> {:error, "dump error: #{err_msg}"}
      :error -> :error
    end
  end

  @doc """
  Generates a loaded version of the data.

  This callback is invoked when a parameterized type is given
  to `field` with the `:autogenerate` flag.
  """
  @impl true
  def autogenerate(params) do
    uuid_to_slug(Uniq.UUID.autogenerate(params.uniq), params)
  end

  @doc """
  Dictates how the type should be treated inside embeds.

  For more information on embedding, see `c:Ecto.Type.embed_as/1`
  """
  @impl true
  def embed_as(format, params), do: Uniq.UUID.embed_as(format, params.uniq)

  @doc """
  Returns the underlying schema type for the ParameterizedType.

  For more information on schema types, see `c:Ecto.Type.type/0`
  """
  @impl true
  def equal?(a, b, params), do: Uniq.UUID.equal?(a, b, params.uniq)

  def equal?(a, b) do
    Uniq.UUID.equal?(a, b, nil)
  end
end
