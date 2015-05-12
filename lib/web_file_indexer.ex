defmodule WebFileIndexer do
end

defmodule WebFileIndexer.API do
  use Maru.Router

  get do
    %{hello: :world} |> json
  end
end
