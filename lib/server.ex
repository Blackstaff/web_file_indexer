defmodule IndexedFile do
  defstruct id: 0, filename: "", folder: "", data: ""
  @type t :: %IndexedFile{id: integer, filename: String.t, folder: String.t, data: String.t}
end

defmodule WebFileIndexer.Server do
  use GenServer

  defmodule State do
    defstruct files: []
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def init([]) do
    {:ok, %State{}}
  end

  def handle_call(request, _from, state) do

  end

  def handle_cast(_msg, state) do

  end
end
