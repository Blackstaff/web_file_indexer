defmodule BoyerMoore do
  def search do
    receive do
      {from, tables, text, pattern, line_number} ->
        pattern_length = Enum.count(pattern)
        text_prefixes = Enum.drop(text_to_prefixes(text), pattern_length)
        matches = search(text_prefixes, Enum.reverse(pattern), pattern_length, tables, [])
        positions = format_response(matches, line_number)
        send(from, positions)
    end
  end

  defp format_response(matches, line_number) do
    for match <- matches, do: %{line: line_number, pos: match}
  end

  def search(text, pattern) do
    r_pattern = Enum.reverse(pattern)

    bad_character_table = make_bad_character_table(r_pattern)
    good_suffix_tables = make_good_suffix_tables(r_pattern)
    tables = Tuple.insert_at(good_suffix_tables, 0, bad_character_table)

    pattern_length = Enum.count(pattern)
    text_prefixes = Enum.drop(text_to_prefixes(text), pattern_length)

    search(text_prefixes, r_pattern, pattern_length, tables, [])
  end

  #TODO Add Galil's rule
  defp search([], _, _, _, matches), do: Enum.reverse(matches)
  defp search(text_prefixes, pattern, pattern_length, tables, matches) do
    [{number, prefix} | tail] = text_prefixes

    matching_chars = llcp(pattern, prefix)
    shift = calculate_shift(tables, {matching_chars, pattern_length})
    shifted_tail = Enum.drop(tail, shift - 1)
    updated_matches = if matching_chars == pattern_length do
      [number | matches]
    else
      matches
    end

    search(shifted_tail, pattern, pattern_length, tables, updated_matches)
  end


  def text_to_prefixes(text) do
    step = fn(char, {number, prefix}) -> {number + 1, [char | prefix]} end
    text_prefixes = List.foldl(text, [{0, []}], fn(char, acc) -> [step.(char, Kernel.hd(acc)) | acc] end)
    Enum.reverse(text_prefixes)
  end

  def preprocess(pattern) do
    r_pattern = Enum.reverse(pattern)

    bad_character_table = make_bad_character_table(r_pattern)
    good_suffix_tables = make_good_suffix_tables(r_pattern)
    tables = Tuple.insert_at(good_suffix_tables, 0, bad_character_table)
  end

  defp calculate_shift(tables, pattern_data) do
    {bad_character, good_suffix, full_shift} = tables
    max(bad_character_shift(bad_character, pattern_data),
      good_suffix_shift(good_suffix, full_shift, pattern_data))
  end

  defp bad_character_shift(table, matching_chars) do
    1
  end

  defp good_suffix_shift(good_suffix, full_shift, pattern_data) do
    {matching_chars, pattern_length} = pattern_data
    #TODO split into 3 functions
    cond do
      matching_chars + 1 == pattern_length -> 1
      HashDict.get(good_suffix, matching_chars + 1, 0) == 0 -> pattern_length - HashDict.get(full_shift, matching_chars + 1, 0)
      true -> pattern_length - (HashDict.get(good_suffix, matching_chars + 1) - 1)
    end
  end

  #TODO implement
  defp make_bad_character_table(pattern) do
    HashDict.new
  end

  defp make_good_suffix_tables(pattern) do
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
