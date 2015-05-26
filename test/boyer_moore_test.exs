defmodule BoyerMooreTest do
  use ExUnit.Case, async: true

  test "Search for a pattern that exists in the text" do
    text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    assert BoyerMoore.search(text, 'sit') == [21]
  end

  test "Search for a pattern that doesn't exist in the text" do
    text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    assert BoyerMoore.search(text, 'kot') == []
  end

  test "Search for a pattern that has multiple occurences in the text" do
    text = 'Lorem ipsum dolor sit amet, consectetur sit adipiscing elit.'
    assert BoyerMoore.search(text, 'sit') == [21, 43]
  end

  test "Use an empty pattern in search" do
    text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    assert_raise FunctionClauseError, fn -> BoyerMoore.search(text, '') end
  end

  test "Use an empty text in search" do
    text = ''
    assert BoyerMoore.search(text, 'sit') == []
  end
end
