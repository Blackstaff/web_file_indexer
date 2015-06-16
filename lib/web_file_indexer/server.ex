defmodule WebFileIndexer.IndexedFile do
  alias WebFileIndexer.IndexedFile

  defstruct id: 0, filename: "", folder: "", data: ""
  @type t :: %IndexedFile{id: integer, filename: String.t, folder: String.t, data: String.t}
end

defmodule WebFileIndexer.Server do
  @moduledoc """
  """

  @vsn 0.1

  use GenServer

  alias WebFileIndexer.IndexedFile
  alias WebFileIndexer.FileSearcher

  defmodule State do
    defstruct count: 0, files: [], words: HashDict.new, cache: HashDict.new
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def init([]) do
    {:ok, %State{}}
  end

  def handle_call({:search, request}, _from, state) do
    file_set = HashDict.get(state.words, request, [])
    cache = HashDict.get(state.cache, request, [])

    search(request, state, file_set, cache)
  end

  # Pattern doesn't exist in the files
  defp search(request, state, [], _cache), do: {:reply, [], state}

  # There is no cached result for the pattern
  defp search(request, state, file_set, []) do
    pattern = String.to_char_list(request)
    files = for file <- state.files, HashSet.member?(file_set, file.id), do: file
    reply = FileSearcher.search(state.files, pattern) |> Enum.reverse

    new_state = Map.put(state, :cache,
      HashDict.put(state.cache, request, {state.count, reply}))
    {:reply, reply, new_state}
  end

  # There is a cached result for the pattern (file count didn't change)
  defp search(request, %{count: count} = state, _file_set, {count, cache}) do
    {:reply, cache, state}
  end

  # There is a cached result for the pattern (file count has changed)
  defp search(request, state, file_set, {_count, cache}) do
    cashe_set = (for %{id: id} <- cache, do: id) |> Enum.into(HashSet.new)
    {_, reply, _} = search(request, state, HashSet.difference(file_set, cashe_set), [])

    combined_reply = reply ++ cache
    new_state = Map.put(state, :cache, HashDict.put(state.cache, request, {state.count, combined_reply}))

    {:reply, combined_reply, new_state}
  end


  def handle_call({:get_files}, _from, state) do
    files = Enum.reverse(state.files)
    reply = for file <- files, do: %{id: file.id, filename: file.filename,
      folder: file.folder}
    {:reply, reply, state}
  end

  def handle_call(request, from, state) do
    super(request, from, state)
  end

  def handle_cast({:push, request}, state) do
    file = %IndexedFile{id: state.count + 1,
      filename: request[:filename],
      folder: request[:folder],
      data: request[:data]}

    words_reduce = fn (elem, acc) ->
      acc |> HashDict.put(elem, HashSet.put(HashDict.get(acc, elem, HashSet.new), file.id))
    end
    words = file.data |> String.split(~r{[^A-Za-z0-9ĄąĆćĘęŁłŃńÓóŚśŹźŻż\-]})
            |> Enum.reduce(state.words, words_reduce)

    new_state = %State{count: state.count + 1, files: [file | state.files], words: words}
    {:noreply, new_state}
  end

  def handle_cast(request, state) do
    super(request, state)
  end
end
