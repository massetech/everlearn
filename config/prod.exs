use Mix.Config

# config :everlearn,
#   secret_key_base: "${SECRET_KEY_BASE}",
#   client_id: "${GOOGLE_CLIENT_ID}",
#   client_secret: "${GOOGLE_CLIENT_SECRET}",
#   secret_key: "${GUARDIAN_SECRET}",
#   host: "${MY_HOSTNAME}",
#   port: "${PORT}"

config :everlearn, EverlearnWeb.Endpoint,
  load_from_system_env: true,
  server: true, # Without this line, your app will not start the web server!
  secret_key_base: "$SECRET_KEY_BASE",
  url: [host: "$MY_HOSTNAME",
        port: "$PORT"],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :everlearn, Everlearn.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "$DATABASE_URL",
  database: "",
  ssl: true,
  pool_size: 1 # Free tier db only allows 1 connection

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "$GOOGLE_CLIENT_ID",
  client_secret: "$GOOGLE_CLIENT_SECRET"

config :everlearn, Everlearn.Auth.Guardian,
  secret_key: "$GUARDIAN_SECRET"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :everlearn, EverlearnWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :everlearn, EverlearnWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :everlearn, EverlearnWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
# import_config "secrets/config.prod.exs"
