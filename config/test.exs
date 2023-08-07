import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :catalyx_test, CatalyxTest.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "catalyx_test_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :catalyx_test, CatalyxTestWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "i42Dmc/F3wYA58r6xHJC5BUP9JLzTtiIz7I/nz3B6UX8qlDOS6pCtv6Y7KTDJbR0",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
