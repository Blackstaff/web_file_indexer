defmodule WebFileIndexer.BoyerMoore do
  @moduledoc """
  Module that implements the Boyer-Moore string search algorithm.

  The search/0 function can be used to parallelize the search
    and should be spawned as a new process.

  The search/2 function can be used in sequencial program.
  """

  @vsn 0.5

  import WebFileIndexer.BoyerMoore.Util

  @doc """
  Searches for pattern matches in the text.
  """

  def search(text, pattern, tables) do
    pattern_length = Enum.count(pattern)
    text_prefixes = Enum.drop(text_to_prefixes(text), pattern_length)
    matches = search(pattern_length, text_prefixes, Enum.reverse(pattern),
      pattern_length, tables, [])
    #for match <- matches, do: match - (pattern_length - 1)
  end

  @spec search(integer, [char_list], char_list, integer, list, [integer]) :: [integer]

  defp search(_, [], _, _, _, matches), do: Enum.reverse(matches)
  defp search(galil, text_prefixes, pattern, pattern_length, tables, matches) do
    [{number, prefix} | tail] = text_prefixes

    length = llcp(pattern, Enum.take(prefix, galil))
    matching_chars = if length == galil do
      pattern_length
    else
      length
    end
    shift = calculate_shift(tables, {matching_chars, pattern_length}, pattern)
    shifted_tail = Enum.drop(tail, shift - 1)
    updated_matches = if matching_chars == pattern_length do
      [number - (pattern_length - 1) | matches]
    else
      matches
    end

    new_galil = if (pattern_length - shift) <= matching_chars do
      shift
    else
      pattern_length
    end

    search(new_galil, shifted_tail, pattern, pattern_length, tables, updated_matches)
  end

  @doc """
  Preprocesses the pattern and returns a tuple containing the tables used
  to calculate shift in Boyer-Moore algorithm.
  """

  @spec preprocess(char_list) :: {HashDict.t, HashDict.t, HashDict.t}

  def preprocess(pattern) do
    r_pattern = Enum.reverse(pattern)

    bad_character_table = make_bad_character_table(r_pattern)
    good_suffix_tables = make_good_suffix_tables(r_pattern)
    tables = Tuple.insert_at(good_suffix_tables, 0, bad_character_table)
  end

  @spec calculate_shift({any, HashDict.t, HashDict.t}, {integer, integer}, list) :: integer

  defp calculate_shift(tables, pattern_data, pattern) do
    {bad_character, good_suffix, full_shift} = tables
    max(bad_character_shift(bad_character, pattern_data, pattern),
      good_suffix_shift(good_suffix, full_shift, pattern_data))
  end

  @spec

  defp bad_character_shift(table, {matching_chars, _}, pattern) do
    r_pattern = Enum.reverse(pattern)
    char = Enum.at(r_pattern, matching_chars + 1)
    HashDict.get(table, char, 1)
  end

  @spec good_suffix_shift(HashDict.t, HashDict.t, {integer, integer}) :: integer

  defp good_suffix_shift(good_suffix, full_shift, pattern_data) do
    {matching_chars, pattern_length} = pattern_data
    cond do
      matching_chars + 1 == pattern_length -> 1
      HashDict.get(good_suffix, matching_chars + 1, 0) == 0 -> pattern_length - HashDict.get(full_shift, matching_chars + 1, 0)
      true -> pattern_length - (HashDict.get(good_suffix, matching_chars + 1) - 1)
    end
  end

  @spec

  defp make_bad_character_table(pattern) do
    pattern_length = Enum.count(pattern)
    default_table = (for char <- [1..255], do: {char, pattern_length})
      |> Enum.into(HashDict.new)
    set_shifts(pattern, pattern_length, 1, default_table)
  end

  defp set_shifts([], _, _, dict), do: dict
  defp set_shifts([h|t], pattern_length, position, dict) do
    set_shifts(t, pattern_length, position + 1,
      HashDict.put(dict, h, pattern_length - position))
  end

  @spec make_good_suffix_tables(char_list) :: {HashDict.t, HashDict.t}

  defp make_good_suffix_tables(pattern) do
    prefixes = Enum.reverse(prefix_function(pattern))
    pattern_length = Enum.count(pattern)
    {make_good_suffix_table(prefixes, pattern_length, 1, HashDict.new),
      make_full_shift_table(prefixes, 0, pattern_length, 0, HashDict.new)}
  end

  @spec

  defp make_good_suffix_table(_, pattern_length, pattern_length, table), do: table
  defp make_good_suffix_table([head | tail], pattern_length, count, table) do
    position = pattern_length - head
    updated_table = cond do
      position != pattern_length -> HashDict.put(table, position + 1, count)
      true -> table
    end
    make_good_suffix_table(tail, pattern_length, count + 1, updated_table)
  end

  @spec

  defp make_full_shift_table(_, _, pattern_length, pattern_length, table), do: table
  defp make_full_shift_table([head | tail], longest_suffix, pattern_length, count, table) do
    new_longest_suffix = cond do
      head == count + 1 -> max(head, longest_suffix)
      true -> longest_suffix
    end
    updated_table = HashDict.put(table, pattern_length - count, new_longest_suffix)
    make_full_shift_table(tail, new_longest_suffix, pattern_length, count + 1, updated_table)
  end
end
