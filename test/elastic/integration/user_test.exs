defmodule Elastic.Integration.UserTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Elastic.User

  @valid_non_infix_chars [0x21..0x2B, 0x2D..0x7E]

  @doc """
  Generate a valid ElasticSearch username

  NB! Comma(,), although allowed when creating a user, leads to odd
  behaviour when dealing with such users. See also:
  * https://github.com/elastic/elasticsearch/issues/72286
  """
  def valid_username_gen do
    gen all(
          text <- string([0x20..0x2B, 0x2D..0x7E], min_length: 1, max_length: 341),
          prefix <- string(@valid_non_infix_chars, min_length: 1, max_length: 341),
          postfix <- string(@valid_non_infix_chars, min_length: 1, max_length: 341)
        ) do
      prefix <> text <> postfix
    end
  end

  @tag integration: true

  property "basic create/2 and delete/1" do
    check all(
            username <- valid_username_gen(),
            max_runs: 10
          ) do
      assert User.create(username, {:password, "password"}) == {:ok, 200, %{"created" => true}}
      assert User.delete(username) == {:ok, 200, %{"found" => true}}
    end
  end

  property "change_password/2 with given username" do
    check all(
            username <- valid_username_gen(),
            max_runs: 10
          ) do
      assert User.create(username, {:password, "password1"}) == {:ok, 200, %{"created" => true}}
      assert User.change_password("password2", username) == {:ok, 200, %{}}
      assert User.delete(username) == {:ok, 200, %{"found" => true}}
    end
  end

  test "get/1 can return kibana user" do
    {:ok, 200, user} = User.get("kibana")
    {:ok, kibana_user} = Map.fetch(user, "kibana")
    assert Map.fetch(kibana_user, "username") == {:ok, "kibana"}
  end

  property "get/1 yields recently created user" do
    check all(
            username <- valid_username_gen(),
            max_runs: 10
          ) do
      assert User.create(username, {:password, "password"}) == {:ok, 200, %{"created" => true}}
      {:ok, 200, user} = User.get(username)
      {:ok, kibana_user} = Map.fetch(user, username)
      assert Map.fetch(kibana_user, "username") == {:ok, username}
      assert User.delete(username) == {:ok, 200, %{"found" => true}}
    end
  end
end
