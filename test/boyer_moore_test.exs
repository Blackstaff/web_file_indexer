defmodule BoyerMooreTest do
  use ExUnit.Case, async: true

  test "Search for a pattern that exists in the text" do
    text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    pattern = 'sit'

    tables = BoyerMoore.preprocess(pattern)
    assert BoyerMoore.search(text, pattern, tables) == [19]
  end

  test "Search for a pattern that doesn't exist in the text" do
    text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    pattern = 'kot'

    tables = BoyerMoore.preprocess(pattern)
    assert BoyerMoore.search(text, pattern, tables) == []
  end

  test "Search for a pattern that has multiple occurences in the text" do
    text = 'Lorem ipsum dolor sit amet, consectetur sit adipiscing elit.'
    pattern = 'sit'

    tables = BoyerMoore.preprocess(pattern)
    assert BoyerMoore.search(text, pattern, tables) == [19, 41]
  end

  test "Use an empty pattern in search" do
    text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    pattern = ''

    tables = BoyerMoore.preprocess(pattern)
    assert_raise FunctionClauseError, fn -> BoyerMoore.search(text, pattern, tables) end
  end

  test "Use an empty text in search" do
    text = ''
    pattern = 'sit'

    tables = BoyerMoore.preprocess(pattern)
    assert BoyerMoore.search(text, pattern, tables) == []
  end
end
