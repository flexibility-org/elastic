defmodule Elastic.User do
  @moduledoc """
  An API wrapper for dealing with ElasticSearch users.

  In particular, this wrapper covers the following elements of the
  [ElasticSearch REST API](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html):

  * [Create or update users API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-user.html)
  * [Delete users API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-user.html)
  """

  alias Elastic.HTTP
  alias Elastic.ResponseHandler
  alias Elastic.User.Name

  @base_url "/_security/user/"

  @spec create(
          username :: binary(),
          password :: binary()
        ) :: ResponseHandler.result()
  def create(username, password) do
    HTTP.put(@base_url <> Name.url_encode(username),
      body: %{
        password: password,
        roles: []
      }
    )
  end

  @spec change_password(
          new_password :: binary(),
          username :: binary() | nil
        ) :: ResponseHandler.result()
  def change_password(new_password, username \\ nil) do
    url =
      case username do
        nil -> "/_password"
        _ -> Name.url_encode(username) <> "/_password"
      end

    HTTP.post(@base_url <> url, body: %{password: new_password})
  end

  @spec delete(username :: binary()) :: ResponseHandler.result()
  def delete(username) do
    HTTP.delete(@base_url <> Name.url_encode(username))
  end
end
