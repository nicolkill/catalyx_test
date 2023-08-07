defmodule CatalyxTest.Repo do
  use Ecto.Repo,
    otp_app: :catalyx_test,
    adapter: Ecto.Adapters.Postgres
end
