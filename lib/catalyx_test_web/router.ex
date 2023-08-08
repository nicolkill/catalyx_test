defmodule CatalyxTestWeb.Router do
  use CatalyxTestWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", CatalyxTestWeb do
    pipe_through :api

    post "/get_presigned_url", FileController, :get_presigned_url
  end
end
