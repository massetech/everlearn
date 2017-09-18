# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :everlearn,
  ecto_repos: [Everlearn.Repo]

# Configures the endpoint
config :everlearn, EverlearnWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sCep7QV5nIeOzSF9pxQuEnFzAr8e6xuZMP93brerI2N+axwv1zW2w6sBnhbeKRwo",
  render_errors: [view: EverlearnWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Everlearn.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
