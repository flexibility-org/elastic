defmodule Elastic.Integration.UserTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Elastic.User

  @valid_non_infix_chars 0x21..0x7E

  def valid_username_gen do
    gen all(
          text <- string(0x20..0x7E, min_length: 1, max_length: 341),
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
      assert User.create(username, "password") == {:ok, 200, %{"created" => true}}
      assert User.delete(username) == {:ok, 200, %{"found" => true}}
    end
  end

  property "change_password/2 with given username" do
    check all(
            username <- valid_username_gen(),
            max_runs: 10
          ) do
      assert User.create(username, "password1") == {:ok, 200, %{"created" => true}}
      assert User.change_password("password2", username) == {:ok, 200, %{}}
      assert User.delete(username) == {:ok, 200, %{"found" => true}}
    end
  end
end
