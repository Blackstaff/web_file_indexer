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

  def handle_call(request, _from, state) do
  end

  def handle_cast(request, state) do
    file = %IndexedFile{id: state.count + 1,
      filename: request[:filename],
      folder: request[:folder],
      data: request[:data]}

    new_state = %State{count: state.count + 1, files: [file | state.files]}
    {:noreply, new_state}
  end
end
