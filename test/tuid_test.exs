defmodule TuidTest do
  use ExUnit.Case

  alias Uniq.UUID

  defmodule TestSchema do
    use Ecto.Schema

    @primary_key {:id, TUID.ParameterizedType, prefix: "test", autogenerate: true}
    @foreign_key_type TUID.ParameterizedType

    schema "test" do
      belongs_to(:test, TestSchema)
    end
  end

  @params TUID.ParameterizedType.init(
            schema: TestSchema,
            field: :id,
            primary_key: true,
            autogenerate: true,
            prefix: "test"
          )
  @belongs_to_params TUID.ParameterizedType.init(
                       schema: TestSchema,
                       field: :test,
                       foreign_key: :test_id
                     )
  @loader nil
  @dumper nil

  @test_prefixed_uuid "test_RrfF33bpyVHPZqvvBLo2Ac"
  @test_uuid UUID.to_string("c94a570c-5126-4391-a176-54750d54b2b1", :raw)
  @test_prefixed_uuid_with_leading_zero "test_1RYjzh3Emc87ejqSXyFcE"
  @test_uuid_with_leading_zero UUID.to_string("000f20b6-c23e-4b90-8e86-6a3a87c89733", :raw)
  @test_prefixed_uuid_null "test_111111111111111111111"
  @test_uuid_null UUID.to_string("00000000-0000-0000-0000-000000000000", :raw)
  @test_prefixed_uuid_invalid_characters "test_" <> String.duplicate(".", 32)
  @test_uuid_invalid_characters String.duplicate(".", 22)
  @test_prefixed_uuid_invalid_format "test_" <> String.duplicate("x", 31)
  @test_uuid_invalid_format String.duplicate("x", 21)

  test "cast/2" do
    assert TUID.ParameterizedType.cast(@test_prefixed_uuid, @params) == {:ok, @test_prefixed_uuid}

    assert TUID.ParameterizedType.cast(@test_prefixed_uuid_with_leading_zero, @params) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert TUID.ParameterizedType.cast(@test_prefixed_uuid_null, @params) ==
             {:ok, @test_prefixed_uuid_null}

    assert TUID.ParameterizedType.cast(nil, @params) == {:ok, nil}
    assert TUID.ParameterizedType.cast("otherprefix" <> @test_prefixed_uuid, @params) == :error
    assert TUID.ParameterizedType.cast(@test_prefixed_uuid_invalid_characters, @params) == :error
    assert TUID.ParameterizedType.cast(@test_prefixed_uuid_invalid_format, @params) == :error

    assert TUID.ParameterizedType.cast(@test_prefixed_uuid, @belongs_to_params) ==
             {:ok, @test_prefixed_uuid}
  end

  test "load/3" do
    assert TUID.ParameterizedType.load(@test_uuid, @loader, @params) == {:ok, @test_prefixed_uuid}

    assert TUID.ParameterizedType.load(@test_uuid_with_leading_zero, @loader, @params) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert TUID.ParameterizedType.load(@test_uuid_null, @loader, @params) ==
             {:ok, @test_prefixed_uuid_null}

    assert TUID.ParameterizedType.load(@test_uuid_invalid_characters, @loader, @params) == :error
    assert TUID.ParameterizedType.load(@test_uuid_invalid_format, @loader, @params) == :error
    assert TUID.ParameterizedType.load(@test_prefixed_uuid, @loader, @params) == :error
    assert TUID.ParameterizedType.load(nil, @loader, @params) == {:ok, nil}

    assert TUID.ParameterizedType.load(@test_uuid, @loader, @belongs_to_params) ==
             {:ok, @test_prefixed_uuid}
  end

  test "dump/3" do
    assert TUID.ParameterizedType.dump(@test_prefixed_uuid, @dumper, @params) == {:ok, @test_uuid}

    assert TUID.ParameterizedType.dump(@test_prefixed_uuid_with_leading_zero, @dumper, @params) ==
             {:ok, @test_uuid_with_leading_zero}

    assert TUID.ParameterizedType.dump(@test_prefixed_uuid_null, @dumper, @params) ==
             {:ok, @test_uuid_null}

    assert TUID.ParameterizedType.dump(@test_uuid, @dumper, @params) == :error
    assert TUID.ParameterizedType.dump(nil, @dumper, @params) == {:ok, nil}

    assert TUID.ParameterizedType.dump(@test_prefixed_uuid, @dumper, @belongs_to_params) ==
             {:ok, @test_uuid}
  end

  test "autogenerate/1" do
    assert prefixed_uuid = TUID.ParameterizedType.autogenerate(@params)
    assert {:ok, uuid} = TUID.ParameterizedType.dump(prefixed_uuid, nil, @params)
    assert {:ok, %UUID{format: :raw, version: 7}} = UUID.parse(uuid)
  end
end
