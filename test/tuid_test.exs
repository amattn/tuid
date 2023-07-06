defmodule TuidTest do
  use ExUnit.Case
  doctest Tuid

  test "greets the world" do
    assert Tuid.hello() == :world
  end
end
