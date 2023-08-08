# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :catalyx_test,
  ecto_repos: [CatalyxTest.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :catalyx_test, CatalyxTestWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: CatalyxTestWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CatalyxTest.PubSub,
  live_view: [signing_salt: "5Nkoiz9E"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

aws_host = System.get_env("AWS_HOST")
aws_region = System.get_env("AWS_REGION")
aws_port = System.get_env("AWS_PORT")

config :ex_aws, :s3,
       scheme: "http://",
       region: aws_region,
       host: aws_host,
       port: aws_port,
       bucket: System.get_env("AWS_S3_BUCKET")

config :ex_aws, :sqs,
       scheme: "http://",
       region: aws_region,
       host: aws_host,
       port: aws_port,
       base_queue_url: "http://#{aws_host}:#{aws_port}/000000000000/",
       new_files_queue: System.get_env("AWS_SQS_NEW_FILES_QUEUE"),
       general_events_queue: System.get_env("AWS_SQS_GENERAL_EVENTS_QUEUE")

config :catalyx_test, :broadway,
       producer_module: {BroadwaySQS.Producer, config: [region: aws_region]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
