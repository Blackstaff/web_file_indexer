defmodule WebFileIndexer do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(WebFileIndexer.Server, [])]

    opts = [strategy: :one_for_one, name: WebFileIndexer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule WebFileIndexer.API do
  use Maru.Router

  get do
    %{hello: :world} |> json
  end
end
