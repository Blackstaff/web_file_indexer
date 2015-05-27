defmodule FileSearcher do
  def search_file(data, pattern, tables) do
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
