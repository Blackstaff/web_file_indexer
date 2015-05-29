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

  defmodule State do
    defstruct count: 0, files: []
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def init([]) do
    {:ok, %State{}}
  end

  def handle_call({:search, request}, _from, state) do
  end

  def handle_call({:get_files}, _from, state) do
    files = Enum.reverse(state.files)
    reply = for file <- files, do: %{id: file.id, filename: file.filename,
      folder: file.folder} #|> Enum.reverse
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

    new_state = %State{count: state.count + 1, files: [file | state.files]}
    {:noreply, new_state}
  end

  def handle_cast(request, state) do
    super(request, state)
  end
end
