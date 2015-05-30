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

  alias WebFileIndexer.Server

  namespace :search do
    route_param :word do
      get do
        GenServer.call(Server, {:search, params[:word]}) |> json
      end
    end
  end

  resource :push do
    desc "Upload file"
    params do
      requires :filename, type: String
      requires :folder, type: String
      requires :data, type: String
    end
    post do
      GenServer.cast(Server, {:push, params})
      %{response: :ok} |> json
    end
  end

  resource :files do
    desc "Get file list"
    get do
      GenServer.call(Server, {:get_files}) |> json
    end
  end
end
