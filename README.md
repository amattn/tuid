# TUID
## Tagged Unique IDs


Developer Friendly:

- K-sortable
- Collision-free, coordination-free, dependency-free
- Just strings on the outside
- Tagged with underscore prefix to help with validation and act as a psuedo-type
- UUIDv7 encodes creation date

User Friendly:

- Base58 encoded
    - Shorten string representation in URLs and other places
    - Prevent confusing letters like lowercase L or Oh/zero
- Tagged with underscore prefix to reduce confusion
- Copy/paste friendly, double-click selectable


## Installation

This package can be installed by adding `tuid` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tuid, "~> 0.1.0"}
  ]
end
```

Add the following code to a single schema module to use TUID columns like so:

```elixir

  @primary_key {:id, TUID, prefix: unquote(prefix), autogenerate: true}
  @foreign_key_type TUID
  schema "books" do
    field :title, :string
    field :author, :string
  end
```

Migrations should look like the following:

```elixir

  create table(:books, primary_key: false) do
    add :id, :uuid, primary_key: true
    add :title, :string
    add :author, :string
  end
```

You may also create `MyApp.Schema` module and use that in place of `Ecto.Schema` in your schema modules.
Typically, the `MyApp.Schema` is saved to `lib/my_app/schema.ex`

```elixir
defmodule MyApp.Schema do
  @moduledoc """
  This module defines the default schema settings for schema modules
  in MyApp.

  Primary and foreign keys use TUIDs.

  ## Usage

      defmodule MyApp.Accounts.Account do
        use MyApp.Schema, prefix: "acct"

        # ...
      end
  """

  defmacro __using__(opts \\ []) do
    prefix = Keyword.fetch!(opts, :prefix)

    quote do
      use Ecto.Schema

      @primary_key {:id, TUID.ParameterizedType, prefix: unquote(prefix), autogenerate: true}
      @foreign_key_type TUID.ParameterizedType

      @type t :: %__MODULE__{}
    end
  end
end
```

Schema modules then should look like:

```elixir

defmodule MyApp.Library.Book do
  use MyApp.Schema, prefix: "book"

  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :author, :string
  end

  ...
     
end
```

## Credit and inspiration

This project is based on the code and blog post from Dan Shultzer's base 62 implementation. 

https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto


## Other projects of similar nature


- ksuid
    - https://github.com/segmentio/ksuid
- TypeID
    - https://github.com/jetpack-io/typeid