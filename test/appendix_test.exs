defmodule AppendixTest do
  use ExUnit.Case
  doctest Appendix

  test "greets the world" do
    assert Appendix.hello() == :world
  end
end
