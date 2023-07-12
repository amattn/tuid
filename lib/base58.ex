defmodule TUID.Base58 do
  @moduledoc """
  `Base58` provides heper functions to encode and decode base58 encoded strings

  https://en.wikipedia.org/wiki/Binary-to-text_encoding#Base58


  credit to blog post:
  https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto

  """

  @b58_char_list ~c"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

  for {digit, idx} <- Enum.with_index(@b58_char_list) do
    def encode(unquote(idx)), do: unquote(<<digit>>)
  end

  def encode(number) do
    encode(div(number, unquote(length(@b58_char_list)))) <>
      encode(rem(number, unquote(length(@b58_char_list))))
  end

  def decode(string) do
    string
    |> String.split("", trim: true)
    |> Enum.reverse()
    |> Enum.reduce_while({:ok, {0, 0}}, fn char, {:ok, {acc, step}} ->
      case decode_base58_char(char) do
        {:ok, number} ->
          {:cont,
           {:ok, {acc + number * Integer.pow(unquote(length(@b58_char_list)), step), step + 1}}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, {number, _step}} -> {:ok, number}
      {:error, error} -> {:error, error}
    end
  end

  for {digit, idx} <- Enum.with_index(@b58_char_list) do
    defp decode_base58_char(unquote(<<digit>>)), do: {:ok, unquote(idx)}
  end

  defp decode_base58_char(char), do: {:error, "got invalid base58 character; #{inspect(char)}"}

  @base58_uuid_length 21
  @uuid_length 32

  def encode_uuid(uuid) do
    uuid
    |> String.replace("-", "")
    |> String.to_integer(16)
    |> encode()
    |> String.pad_leading(@base58_uuid_length, "1")
  end

  def decode_uuid(string) do
    with {:ok, number} <- decode(string) do
      number_to_uuid(number)
    end
  end

  defp number_to_uuid(number) do
    number
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(@uuid_length, "0")
    |> case do
      <<g1::binary-size(8), g2::binary-size(4), g3::binary-size(4), g4::binary-size(4),
        g5::binary-size(12)>> ->
        {:ok, "#{g1}-#{g2}-#{g3}-#{g4}-#{g5}"}

      other ->
        {:error, "got invalid base58 uuid; #{inspect(other)}"}
    end
  end
end
