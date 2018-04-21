# defmodule Everlearn.Plug.DisplayFlashes do
#   import Plug.Conn
#   import Phoenix.Controller
#
#   def init(opts), do: opts
#   def call(conn, _opts) do
#     flash_messages = conn
#       |> get_flash() # %{"info" => "Welcome Back!"}
#       |> Enum.map(fn({k, v}) -> build_flash_html(k, v) end)
#       |> Enum.join("\n")
#     conn
#       |> assign(:flash_messages, flash_messages)
#   end
#
#
#
# end
