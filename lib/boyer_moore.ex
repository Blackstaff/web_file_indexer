defmodule BoyerMoore do
  def search(text, pattern) do
    r_pattern = Enum.reverse(pattern)

    bad_character_table = make_bad_character_table(r_pattern)
    good_suffix_tables = make_good_suffix_tables(r_pattern)
    tables = Tuple.insert_at(good_suffix_tables, 0, bad_character_table)

    text_prefixes = text_to_prefixes(text)

    search(text_prefixes, r_pattern, Enum.count(pattern), tables, [])
  end

  defp search([], _, _, _, matches), do: Enum.reverse(matches)
  defp search(text_prefixes, pattern, pattern_length, tables, matches) do
    {bad_character_table, good_suffix_table, full_shift_table} = tables
    [{number, prefix} | tail] = text_prefixes

    matching_chars = llcp(pattern, prefix)
    shift = 1
    shifted_tail = Enum.drop(tail, shift - 1)
    updated_matches = if matching_chars == pattern_length do
      [number | matches]
    else
      matches
    end

    search(shifted_tail, pattern, pattern_length, tables, updated_matches)
  end

  defp calculate_shift(tables) do
  end

  def text_to_prefixes(text) do
    step = fn(char, {number, prefix}) -> {number + 1, [char | prefix]} end
    text_prefixes = List.foldl(text, [{0, []}], fn(char, acc) -> [step.(char, Kernel.hd(acc)) | acc] end)
    Enum.reverse(text_prefixes)
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
    for tail <- tails(pattern), do: llcp(pattern, tail)
  end

  #TODO Przerobić na rekurencję ogonową
  defp tails([]), do: []
  defp tails(tail), do: [tail | tails(Kernel.tl(tail))]

  defp llcp(list1, list2), do: llcp(list1, list2, 0)

  defp llcp([head | tail_x], [head | tail_y], matching_chars), do: llcp(tail_x, tail_y, matching_chars + 1)
  defp llcp(_,_, matching_chars), do: matching_chars
end
