defmodule Elastic.Query do
  @moduledoc false

  defstruct index: nil, body: %{}

  @type t :: %__MODULE__{}

  @spec build(index :: binary(), body :: term()) :: __MODULE__.t()
  def build(index, body) do
    %Elastic.Query{index: index, body: body}
  end
end
