defmodule Elastic.User.NameTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Elastic.User.Name

  @valid_non_infix_chars [0x21..0x2B, 0x2D..0x7E]

  def valid_username_gen do
    gen all(
          text <- string([0x20..0x2B, 0x2D..0x7E], min_length: 1, max_length: 341),
          prefix <- string(@valid_non_infix_chars, min_length: 1, max_length: 341),
          postfix <- string(@valid_non_infix_chars, min_length: 1, max_length: 341)
        ) do
      prefix <> text <> postfix
    end
  end

  describe "is_valid_username?/1" do
    test "given empty string, returns false" do
      assert Name.is_valid?("") == false
    end

    test "given a comma, returns false" do
      assert Name.is_valid?(",") == false
    end

    property "given name starting with a comma, returns false" do
      check all(chars <- string(@valid_non_infix_chars, min_length: 1, max_length: 1023)) do
        assert Name.is_valid?("," <> chars) == false
      end
    end

    property "given name ending with a comma, returns false" do
      check all(chars <- string(@valid_non_infix_chars, min_length: 1, max_length: 1023)) do
        assert Name.is_valid?(chars <> ",") == false
      end
    end

    property "given a name containing some commas, returns false" do
      check all(
              length <- integer(1..200),
              n_commas <- integer(1..length),
              n_chars = length - n_commas,
              rest_chars <- string(@valid_non_infix_chars, length: n_chars),
              comma_indices <- list_of(integer(0..n_chars), length: n_commas)
            ) do
        name =
          comma_indices
          |> List.foldl(
            String.to_charlist(rest_chars),
            fn ndx, text -> List.insert_at(text, ndx, ~c",") end
          )
          |> List.to_string()

        assert Name.is_valid?(name) == false
      end
    end

    property "given a short, valid sequence, returns true" do
      check all(username <- string(@valid_non_infix_chars, min_length: 1, max_length: 3)) do
        assert Name.is_valid?(username) == true
      end
    end

    property "given a string with leading spaces, returns false" do
      check all(
              text <- string(@valid_non_infix_chars, min_length: 1, max_length: 1024),
              prefix <- string(0x20..0x20, min_length: 1, max_length: 20)
            ) do
        username = prefix <> text
        assert Name.is_valid?(username) == false
      end
    end

    property "given a string with trailing spaces, returns false" do
      check all(
              text <- string(@valid_non_infix_chars, min_length: 1, max_length: 1024),
              postfix <- string(0x20..0x20, min_length: 1, max_length: 20)
            ) do
        username = text <> postfix
        assert Name.is_valid?(username) == false
      end
    end

    property "given a string with leading and trailing spaces, returns false" do
      check all(
              text <- string(@valid_non_infix_chars, min_length: 1, max_length: 1024),
              prefix <- string(0x20..0x20, min_length: 1, max_length: 20),
              postfix <- string(0x20..0x20, min_length: 1, max_length: 20)
            ) do
        username = prefix <> text <> postfix
        assert Name.is_valid?(username) == false
      end
    end

    property "given a string with length > 1024 bytes, returns false" do
      check all(username <- string(@valid_non_infix_chars, min_length: 1025, max_length: 10_000)) do
        assert Name.is_valid?(username) == false
      end
    end

    property "given a valid name, returns true" do
      check all(username <- valid_username_gen()) do
        assert Name.is_valid?(username) == true
      end
    end
  end
end
