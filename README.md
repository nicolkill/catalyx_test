## CatalyxTest



To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## How to push file

First call to the endpoint `POST "/api/v1/get_presigned_url"` and get the presigned url

This new url must be called using PUT using the entire file as body

#### Examples

```elixir
url = "https://localstack:4566"
%{status_code: code} = HTTPoison.put!(url, {:file, "/example/path"})
```
