defmodule WebFileIndexer.FileSearcher do
  @moduledoc """
  """

  @vsn 0.2

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
    matches |> format_matches |> apply_offset(text_lines)
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

  defp apply_offset(matches, text_lines) do
    offset_table = make_offset_table(text_lines)
    for match <- matches, do: %{line: match.line,
      pos: match.pos + HashDict.get(offset_table, match.line)}
  end

  defp make_offset_table(text_lines) do
    offset_fun = fn(line, acc) ->
      {line_number, offset_table} = acc

      next_line_number = line_number + 1
      prev_offset = HashDict.get(offset_table, line_number, 0)
      offset = Enum.count(line) + prev_offset

      {next_line_number, HashDict.put(offset_table, next_line_number, offset)}
    end

    initial_acc = {1, HashDict.new |> HashDict.put(1, 0)}
    {_, offset_table} = List.foldl(text_lines, initial_acc, offset_fun)
    offset_table
  end

  defp concat([], acc), do: acc
  #defp concat(list, []), do: list
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
