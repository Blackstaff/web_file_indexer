defmodule WebFileIndexer.BoyerMoore.Util do
  @moduledoc """
  Utility functions for Boyer-Moore algorithm.
  """

  @vsn 0.1

  @doc """
  Given a text returns a list containing all its prefixes.
  """

  @spec text_to_prefixes(char_list) :: [char_list]

  def text_to_prefixes(text) do
    step = fn(char, {number, prefix}) -> {number + 1, [char | prefix]} end
    text_prefixes = List.foldl(text, [{0, []}], fn(char, acc) -> [step.(char, Kernel.hd(acc)) | acc] end)
    Enum.reverse(text_prefixes)
  end

  @doc """
  """

  @spec

  #TODO optimize
  def prefix_function(pattern) do
    for tail <- tails(pattern), do: llcp(pattern, tail)
  end

  @doc """
  Given a list returns its list of tails.
  """

  @spec tails(list) :: list(list)

  #TODO Przerobić na rekurencję ogonową
  def tails([]), do: []
  def tails(tail), do: [tail | tails(Kernel.tl(tail))]

  @doc """
  Given two lists returns the length of their longest common prefix.
  """

  @spec llcp(list, list) :: integer

  def llcp(list1, list2), do: llcp(list1, list2, 0)

  defp llcp([head | tail_x], [head | tail_y], matching_chars), do: llcp(tail_x, tail_y, matching_chars + 1)
  defp llcp(_,_, matching_chars), do: matching_chars
end
