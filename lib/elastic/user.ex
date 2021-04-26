defmodule Elastic.User do
  alias Elastic.HTTP
  alias Elastic.ResponseHandler

  @base_url "/_security/user/"

  @doc """
    URL-encode username for use with the Elastic Users API.

    In this API, the username is supplied as part of a URL path, and
    yet, Elastic allows for all sorts of printable ASCII characters in
    usernames, including ?, /, &, =, and so on.

    This percent-encodes everything but the unreserved URL character
    set, as defined by [RFC 3986, section
    2.3](https://tools.ietf.org/html/rfc3986#section-2.3). In particular,
    everything, but the following character is percent-encoded:

    * Alphanumeric ASCII characters: `A-Z`, `a-z`, and `0-9`.
    * `~`, `_`, `-`, `.`
  """
  @spec url_encode_username(username :: binary()) :: binary()
  defp url_encode_username(username) do
    URI.encode(username, &URI.char_unreserved?/1)
  end

  @spec create(
          username :: binary(),
          password :: binary()
        ) :: ResponseHandler.result()
  def create(username, password) do
    HTTP.put(@base_url <> url_encode_username(username),
      body: %{
        password: password,
        roles: []
      }
    )
  end

  @spec delete(username :: binary()) :: ResponseHandler.result()
  def delete(username) do
    HTTP.delete(@base_url <> url_encode_username(username))
  end

  def is_valid_username?(username) do
    len = String.length(username)

    len > 0 && len <= 1024 &&
      Regex.run(~r{^[!-~][ -~]+[!-~]$}, username) != nil
  end
end
