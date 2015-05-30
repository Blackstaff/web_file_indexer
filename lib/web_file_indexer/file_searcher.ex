defmodule WebFileIndexer.FileSearcher do
  @moduledoc """
  """

  @vsn 0.1

  alias WebFileIndexer.BoyerMoore

  def search(files, pattern) do
    tables = BoyerMoore.preprocess(pattern)
    search_fun = fn(file) ->
      positions = search_file(file.data, pattern, tables)
      %{id: file.id, filename: file.filename, folder: file.folder,
        positions: positions}
    end
    result = pmap(files, search_fun)
    for elem <- result, Enum.count(elem.positions) > 0, do: elem
  end

  defp search_file(data, pattern, tables) do
    text_lines = data |> String.split("\n") |> Enum.map(&(String.to_char_list(&1)))
    search_fun = fn(text_line) ->
      BoyerMoore.search(text_line, pattern, tables) end
    matches = pmap(text_lines, search_fun)
    format_matches(matches)
  end

  defp format_matches(matches) do
    fold_fun = fn(elem, accumulator) -> {current_line, positions} = accumulator
      new_line = current_line + 1
      new_elem = for match <- elem, do: %{line: new_line, pos: match}
      {new_line, concat(new_elem, positions)}
    end
    {_, positions} = List.foldl(matches, {0, []}, fold_fun)
    Enum.reverse(positions)
  end

  defp concat([], acc), do: acc
  defp concat(list, []), do: list
  defp concat(list, acc) do
    [head | tail] = list
    concat(tail, [head | acc])
  end

  def pmap(collection, fun) do
    me = self
    collection
    |> Enum.map(fn (elem) ->
      spawn_link fn -> (send me, {self, fun.(elem)}) end
      end)
    |> Enum.map(fn (pid) ->
      receive do {^pid, result} -> result end
      end)
  end
end
