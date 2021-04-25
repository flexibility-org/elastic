defmodule Elastic.User do
  def is_valid_username?(username) do
    len = String.length(username)
    len > 0 && len <= 1024 &&
      Regex.run(~r{^[!-~][ -~]+[!-~]$}, username) != nil
  end
end
