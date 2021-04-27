defmodule Elastic.Role do
  @moduledoc """
  An API wrapper for dealing with ElasticSearch roles.

  In particular, this wrapper covers the following elements of the
  [ElasticSearch REST API](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html):

  * [Create or update roles API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-role.html)
  * [Get roles API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-role.html)
  * [Delete roles API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-role.html)
  """

  alias Elastic.HTTP
  alias Elastic.ResponseHandler
  alias Elastic.User.Name

  @base_url "/_security/role/"

  @spec upsert(
          name :: binary(),
          body :: map()
        ) :: ResponseHandler.result()
  def upsert(name, body) do
    HTTP.put(@base_url <> Name.url_encode(name),
      body: body
    )
  end

  @spec delete(name :: binary()) :: ResponseHandler.result()
  def delete(name) do
    HTTP.delete(@base_url <> Name.url_encode(name))
  end

  @spec get(name :: binary() | nil) :: ResponseHandler.result()
  def get(name \\ nil) do
    url =
      case name do
        nil -> ""
        _ -> Name.url_encode(name)
      end

    HTTP.get(@base_url <> url)
  end
end
