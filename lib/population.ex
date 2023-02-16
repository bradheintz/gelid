defmodule Population do
  @type t :: %__MODULE__{
    members: Enum.t, # list of invidiuals
    target_size: integer, # target population size cached, as actual may vary
    experiment: Experiment,
    domain: any()
  }
  defstruct members: [], target_size: 0, experiment: nil, domain: nil

  def hello do
    :world
  end
end
