defmodule CatalyxTestWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CatalyxTestWeb, :controller

  def call(conn, {field, {:error, :invalid_format}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: ["#{field} has invalid format"]})
  end

  def call(conn, {:error, %MapSchemaValidator.InvalidMapError{message: message}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: [message]})
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CatalyxTestWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: CatalyxTestWeb.ErrorHTML, json: CatalyxTestWeb.ErrorJSON)
    |> render(:"404")
  end
end
