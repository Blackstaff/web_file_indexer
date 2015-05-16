defmodule BoyerMoore do
  def search(text, pattern) do
    r_pattern = Enum.reverse(pattern)
    bad_character_table = make_bad_character_table(r_pattern)
    good_suffix_tables = make_good_suffix_tables(r_pattern)
  end

  #TODO implement
  defp make_bad_character_table(pattern) do
    HashDict.new
  end

  def make_good_suffix_tables(pattern) do
    prefixes = Enum.reverse(prefix_function(pattern))
    pattern_length = Enum.count(pattern)
    {make_good_suffix_table(prefixes, pattern_length, 1, HashDict.new),
      make_full_shift_table(prefixes, 0, pattern_length, 0, HashDict.new)}
  end

  defp make_good_suffix_table(_, pattern_length, pattern_length, table), do: table
  defp make_good_suffix_table([head | tail], pattern_length, count, table) do
    position = pattern_length - head
    updated_table = cond do
      position != pattern_length -> HashDict.put(table, position + 1, count)
      true -> table
    end
    make_good_suffix_table(tail, pattern_length, count + 1, updated_table)
  end

  defp make_full_shift_table(_, _, pattern_length, pattern_length, table), do: table
  defp make_full_shift_table([head | tail], longest_suffix, pattern_length, count, table) do
    new_longest_suffix = cond do
      head == count + 1 -> max(head, longest_suffix)
      true -> longest_suffix
    end
    updated_table = HashDict.put(table, pattern_length - count, new_longest_suffix)
    make_full_shift_table(tail, new_longest_suffix, pattern_length, count + 1, updated_table)
  end

  #TODO optimize
  def prefix_function(pattern) do
    for tail <- tails(pattern), do: llcp(pattern, tail, 0)
  end

  defp prefix_function(pattern, count, prefix_table) do
    tails = List.foldl(pattern, [], fn(value, acc) -> [h|_] = acc [[value | h] | acc] end)
    for tail <- tails(pattern), do: llcp(pattern, tail)
  end

  #TODO Przerobić na rekurencję ogonową
  defp tails([]), do: []
  defp tails(tail), do: [tail | tails(Kernel.tl(tail))]

  defp llcp([head | tail_x], [head | tail_y], matching_chars), do: llcp(tail_x, tail_y, matching_chars + 1)
  defp llcp(_,_, matching_chars), do: matching_chars
end
