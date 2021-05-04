defmodule Elastic.Kibana.Role do
  @moduledoc """
  An API wrapper for dealing with Kibana roles.

  In particular, this wrapper covers the following elements of the
  [Kibana REST
  API](https://www.elastic.co/guide/en/kibana/master/api.html):

  * [Create or update role
    API](https://www.elastic.co/guide/en/kibana/master/role-management-api-put.html)
  * [Delete role
    API](https://www.elastic.co/guide/en/kibana/master/role-management-api-delete.html)
  """
  alias Elastic.HTTP
  alias Elastic.ResponseHandler
  alias Elastic.User.Name

  @base_url Elastic.base_kibana_url() <> "/api/security/role/"

  @spec upsert(
          name :: binary(),
          kibana_privileges :: list(any())
        ) :: ResponseHandler.result()
  def upsert(name, kibana_privileges) do
    HTTP.put(@base_url <> Name.url_encode(name),
      body: %{kibana: kibana_privileges}
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
        nil -> String.slice(@base_url, 0..-2)
        _ -> @base_url <> Name.url_encode(name)
      end

    HTTP.get(url)
  end
end
