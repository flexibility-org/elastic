defmodule Elastic.Query do
  @moduledoc false

  defstruct index: nil, body: %{}

  @spec build(index :: binary(), body :: term()) :: %Elastic.Query{}
  def build(index, body) do
    %Elastic.Query{index: index, body: body}
  end
end
