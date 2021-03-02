defmodule Sockethost do
  use Application

  def start(_type, _args) do
    Sockethost.Cache.start_link()
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Sockethost.Router,
        options: [
          dispatch: dispatch(),
          port: 8080
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Sockethost
      )
    ]

    opts = [strategy: :one_for_one, name: Sockethost.Application]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", Sockethost.SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {Sockethost.Router, []}}
       ]}
    ]
  end
end
