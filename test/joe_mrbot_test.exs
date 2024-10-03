defmodule JoeMrbotTest do
  use ExUnit.Case
  doctest JoeMrbot

  test "greets the world" do
    assert JoeMrbot.hello() == :world
  end
end
