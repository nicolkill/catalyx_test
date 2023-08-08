defmodule CatalyxTestWeb.FileJSON do

  def render("upload_url.json", %{url: url}) do
    %{
      url: url
    }
  end
end