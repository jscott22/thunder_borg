defmodule ThunderBorgTest do
  use ExUnit.Case
  doctest ThunderBorg

  test "greets the world" do
    assert ThunderBorg.hello() == :world
  end
end
