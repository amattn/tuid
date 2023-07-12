defmodule Base58Test do
  use ExUnit.Case, async: true

  alias TUID.Base58
  doctest TUID.Base58

  require Logger

  describe "Base58 encode/decode tests" do
    test "Base58 encode" do
      decimal = 296_404_044_986_473_453_140_047_160_099_378_263_721
      b58 = "UY58EHDR4PrnmUcbWvmqW8"

      assert Base58.encode(decimal) == b58

      hex = "defd57b3d3c24852ac3efd6dcfd376a9"
      assert Base58.encode_uuid(hex) == b58

      uuid = "defd57b3-d3c2-4852-ac3e-fd6dcfd376a9"
      assert Base58.encode_uuid(uuid) == b58

      zero_uuid = "00000000-0000-0000-0000-000000000000"
      empty_b58 = "111111111111111111111"
      assert Base58.encode_uuid(zero_uuid) == empty_b58
    end

    test "Base58 decode" do
      decimal = 296_404_044_986_473_453_140_047_160_099_378_263_721

      b58 = "UY58EHDR4PrnmUcbWvmqW8"
      assert Base58.decode(b58) == {:ok, decimal}

      b58 = "111111DR4PrnmUcbWvmqW8"
      hex = "0000000000000b57c16a58ce6e1c21e576a9"
      decimal = :binary.decode_unsigned(Base.decode16!(hex, case: :lower))

      assert Base58.decode(b58) == {:ok, decimal}
    end

    test "Base58 decode invalid chars" do
      assert {:error, _} = Base58.decode("\0")
      assert {:error, _} = Base58.decode("0")
      assert {:error, _} = Base58.decode("O")
      assert {:error, _} = Base58.decode("l")
      assert {:error, _} = Base58.decode("I")
      assert {:error, _} = Base58.decode("*")
      assert {:error, _} = Base58.decode("+")
      assert {:error, _} = Base58.decode("_")
      assert {:error, _} = Base58.decode(" ")

      assert {:error, _} = Base58.decode("abc01O2l3I4cba")
    end
  end
end
