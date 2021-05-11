defmodule Elastic.Integration.Kibana.RoleTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Elastic.IntegrationTestCase

  alias Elastic.Kibana.Role

  @valid_non_infix_chars [0x21..0x2B, 0x2D..0x7E]

  @doc """
  Generate a valid Kibana role name

  NB! Comma(,), although allowed when creating a role, leads to odd
  behaviour when dealing with such roles.
  """
  def valid_name_gen do
    gen all(
          text <- string([0x20..0x2B, 0x2D..0x7E], min_length: 1, max_length: 341),
          prefix <- string(@valid_non_infix_chars, min_length: 1, max_length: 341),
          postfix <- string(@valid_non_infix_chars, min_length: 1, max_length: 341)
        ) do
      prefix <> text <> postfix
    end
  end

  @tag integration: true

  property "basic upsert/2 and delete/1" do
    check all(
            name <- valid_name_gen(),
            max_runs: 10
          ) do
      assert Role.upsert(name) == {:ok, 204, ""}
      assert Role.delete(name) == {:ok, 204, ""}
    end
  end
end
