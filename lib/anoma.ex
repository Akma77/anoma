defmodule Anoma do
  use Application

  @moduledoc """
  Documentation for `Anoma`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Anoma.hello()
      :world

  """
  def hello do
    :world
  end

  def start(_type, _args) do
    arguments = Burrito.Util.Args.get_arguments()

    # This will invoke start_logic if we want that application
    Anoma.Cli.start_application(arguments)
  end

  def start_logic() do
    storage = %Anoma.Storage{
      qualified: Anoma.Qualified,
      order: Anoma.Order,
      rm_commitments: Anoma.RMCommitments
    }

    name = :anoma
    snapshot_path = [:my_special_nock_snaphsot | 0]

    node_settings = [
      name: name,
      snapshot_path: snapshot_path,
      storage: storage,
      block_storage: :anoma_block
    ]

    children = [
      if Application.get_env(name, :env) == :prod do
        {Anoma.Node,
         [
           new_storage: true,
           name: name,
           settings:
             [{:ping_time, 10000} | node_settings] |> Anoma.Node.start_min()
         ]}
      else
        {Anoma.Node,
         [
           new_storage: true,
           name: name,
           settings:
             [{:ping_time, :no_timer} | node_settings]
             |> Anoma.Node.start_min()
         ]}
      end
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Anoma)
  end
end
