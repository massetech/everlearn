# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :everlearn,
  ecto_repos: [Everlearn.Repo]

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine,
  drab: Drab.Live.Engine

config :rummage_ecto, Rummage.Ecto,
  default_repo: Everlearn.Repo,
  default_per_page: 500

config :everlearn, EverlearnWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: EverlearnWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Everlearn.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "profile email https://www.googleapis.com/auth/plus.login"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :everlearn, Everlearn.Auth.Guardian,
  issuer: "Everlearn.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  # serializer: Everlearn.GuardianSerializer,
  secret_key: System.get_env("GUARDIAN_SECRET")

# config :cors_plug,
#   origin: ["http://localhost:4000"],
#   max_age: 86400,
#   methods: ["GET", "POST"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
