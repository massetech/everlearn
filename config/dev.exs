use Mix.Config

config :everlearn, EverlearnWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

config :everlearn, Everlearn.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "everlearn_dev",
  hostname: "localhost",
  pool_size: 10
  # postgresql://postgres:postgres@localhost:5432/everlearn_dev

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :everlearn, Everlearn.Auth.Guardian,
  secret_key: System.get_env("GUARDIAN_SECRET")

config :cors_plug,
  origin: ["http://localhost:4000"],
  max_age: 86400,
  methods: ["GET", "POST"]

# Watch static and templates for browser reloading.
config :everlearn, EverlearnWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/everlearn_web/views/.*(ex)$},
      ~r{lib/everlearn_web/templates/.*(eex)$},
      ~r{web/templates/.*(eex|haml|drab)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
