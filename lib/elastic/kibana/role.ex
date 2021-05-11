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
        ) :: :ok | ResponseHandler.unknown_response_value()
  def upsert(name, kibana_privileges \\ []) do
    response =
      HTTP.put(@base_url <> Name.url_encode(name),
        body: %{kibana: kibana_privileges},
        middlewares: [HTTP.kibana_middleware()]
      )

    case response do
      {:ok, 204, ""} ->
        :ok

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end

  @spec delete(name :: binary()) :: ResponseHandler.find_result()
  def delete(name) do
    response =
      HTTP.delete(@base_url <> Name.url_encode(name),
        middlewares: [HTTP.kibana_middleware()]
      )

    case response do
      {:ok, 204, ""} ->
        :ok

      {:error, 404, %{"error" => "Not Found"}} ->
        {:error, :not_found}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end

  @spec get(name :: binary() | nil) :: {:ok, map()} | ResponseHandler.find_error()
  def get(name \\ nil) do
    url =
      case name do
        nil -> String.slice(@base_url, 0..-2)
        _ -> @base_url <> Name.url_encode(name)
      end

    response = HTTP.get(url)

    case response do
      {:ok, 200, role} ->
        {:ok, role}

      {:ok, 404, %{"error" => "Not Found"}} ->
        {:error, :not_found}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end
end
