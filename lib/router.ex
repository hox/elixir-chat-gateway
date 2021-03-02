defmodule Sockethost.Router do
  use Plug.Router
  require EEx

  plug Plug.Static,
    at: "/",
    from: :sockethost
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  plug :dispatch


  get "/" do
    send_resp(conn, 200, "200")
  end

  match _ do
    send_resp(conn, 404, "404")
  end
end
