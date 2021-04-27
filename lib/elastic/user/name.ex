defmodule Elastic.User.Name do
  @moduledoc """
  For working with ElasticSearch-compatible usernames.
  """

  @doc """
  The ElasticSearch Users API, asks for usernames to be supplied as
  part of a URL path. At the same time, ElasticSearch allows for all
  sorts of printable ASCII characters in usernames (e.g., `?`, `/`, `&`,
  `=`).

  When you pass a username to this module, the username is
  percent-encoded before being used with the API.
  In particular, this library percent-encodes everything but the
  unreserved URL character set, as defined by [RFC 3986, section
  2.3](https://tools.ietf.org/html/rfc3986#section-2.3).

  In general however, you hopefully won't have to think about these
  internals.
  """
  @spec url_encode(username :: binary()) :: binary()
  def url_encode(username) do
    URI.encode(username, &URI.char_unreserved?/1)
  end

  @doc """
    A [valid ElasticSearch
    username](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-user.html#security-api-put-user-path-params)
    is between 1 and 1024 characters, each being a printable ASCII
    character, with no leading og trailing spaces.
  """
  @spec is_valid?(username :: binary()) :: boolean()
  def is_valid?(username) do
    len = String.length(username)

    len > 0 && len <= 1024 &&
      Regex.run(~r{^[!-~]([ -~]*[!-~])?$}, username) != nil
  end
end
