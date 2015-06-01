defmodule WebFileIndexer.FileSearcherTest do
  use ExUnit.Case, async: true

  alias WebFileIndexer.FileSearcher
  alias WebFileIndexer.IndexedFile

  setup do
    {:ok, device} = File.open("test/web_file_indexer/tekst-krotki.txt", [:read, :utf8])
    text = IO.read(device, :all)
    file = %IndexedFile{data: text}
    {:ok, [file: file]}
  end

  test "Search for a pattern that exists in the text", context do
    file = context[:file]
    pattern = 'zwierz'

    expected = [%{line: 3, pos: 106}]
    [result | _] = FileSearcher.search([file], pattern)
    assert result.positions == expected
  end

  test "Search for a pattern that doesn't exist in the text", context do
    file = context[:file]
    pattern = 'coś'

    expected = []
    result = FileSearcher.search([file], pattern)
    assert result == expected
  end

  test "Search for a pattern that has multiple occurences in the text", context do
    file = context[:file]
    pattern = 'jesienny'

    expected = [%{line: 1, pos: 1}, %{line: 2, pos: 19}, %{line: 3, pos: 89},
      %{line: 4, pos: 205}]
    [result | _] = FileSearcher.search([file], pattern)
    assert result.positions == expected
  end

  test "Use an empty text in search" do
    file = %IndexedFile{}
    pattern = 'jesienny'

    expected = []
    result = FileSearcher.search([file], pattern)
    assert result == expected
  end

  test "Search through multiple files", context do
    file = context[:file]
    pattern = 'jesienny'

    expected = [%{line: 1, pos: 1}, %{line: 2, pos: 19}, %{line: 3, pos: 89},
      %{line: 4, pos: 205}]
    results = FileSearcher.search([file, file, file], pattern)
    for result <- results, do: assert result.positions == expected
  end
end
