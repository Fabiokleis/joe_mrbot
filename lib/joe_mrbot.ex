defmodule JoeMrbot do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("[APP] application starting")
    Supervisor.start_link([JoeMrbot.Bot], strategy: :one_for_one)
  end
end
