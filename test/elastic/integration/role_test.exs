defmodule Elastic.Integration.RoleTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Elastic.IntegrationTestCase

  alias Elastic.Role

  @valid_non_infix_chars [0x21..0x2B, 0x2D..0x7E]

  @doc """
  Generate a valid ElasticSearch username

  NB! Comma(,), although allowed when creating a user, leads to odd
  behaviour when dealing with such users. See also:
  * https://github.com/elastic/elasticsearch/issues/72286
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
      assert Role.upsert(name, %{indices: []}) == {:ok, :created}
      assert Role.delete(name) == :ok
    end
  end

  property "second delete/1 fails" do
    check all(
            name <- valid_name_gen(),
            max_runs: 10
          ) do
      assert Role.upsert(name, %{indices: []}) == {:ok, :created}
      assert Role.delete(name) == :ok
      assert Role.delete(name) == {:error, :not_found}
    end
  end

  property "second upsert/2 updates" do
    check all(
            name <- valid_name_gen(),
            max_runs: 10
          ) do
      assert Role.upsert(name, %{indices: []}) == {:ok, :created}
      assert Role.upsert(name, %{indices: []}) == {:ok, :updated}
    end
  end
end
