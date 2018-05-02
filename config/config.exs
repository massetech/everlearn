use Mix.Config

config :everlearn,
  ecto_repos: [Everlearn.Repo],
  api_url: System.get_env("API_URL")

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine,
  drab: Drab.Live.Engine

config :rummage_ecto, Rummage.Ecto,
  default_repo: Everlearn.Repo,
  default_per_page: 5000

config :everlearn, EverlearnWeb.Endpoint,
  render_errors: [view: EverlearnWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Everlearn.PubSub, adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "profile email https://www.googleapis.com/auth/plus.login"]}
  ]

config :everlearn, Everlearn.Auth.Guardian,
  issuer: "Everlearn.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
