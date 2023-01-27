defmodule Population do
  @type t :: %__MODULE__{
    members: Enum.t, # list of invidiuals
    target_size: integer # target population size cached, as actual may vary
  }
  defstruct members: [], target_size: 0

  def hello do
    :world
  end
end
