use Mix.Config

config :exmemtest, Exmemtest.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "exmemtest_web",
  password: "",
  database: "exmemtest_dev"
