defmodule Exmemtest do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmemtest.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Exmemtest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
