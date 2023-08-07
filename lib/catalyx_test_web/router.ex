defmodule CatalyxTestWeb.Router do
  use CatalyxTestWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CatalyxTestWeb do
    pipe_through :api
  end
end
