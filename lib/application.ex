defmodule Pokelixir.Application do
  use Application

  @impl true
  def start(_start_type, _start_args) do
    children = [
      {Finch, name: MyFinch}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Pokelixir.Supervisor)
  end
end
