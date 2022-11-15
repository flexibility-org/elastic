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

  defp security_root, do: Elastic.base_url() <> "/_security/role/"

  @spec upsert(
          name :: binary(),
          body :: map()
        ) :: ResponseHandler.upsert_result()
  def upsert(name, body) do
    response =
      HTTP.put(security_root() <> Name.url_encode(name),
        body: body
      )

    case response do
      {:ok, 200, %{"role" => %{"created" => true}}} ->
        {:ok, :created}

      {:ok, 200, %{"role" => %{"created" => false}}} ->
        {:ok, :updated}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end

  @spec delete(name :: binary()) :: ResponseHandler.find_result()
  def delete(name) do
    HTTP.delete(security_root() <> Name.url_encode(name))
    |> ResponseHandler.process_find_response()
  end

  @spec get(name :: binary() | nil) :: {:ok, map()} | ResponseHandler.find_error()
  def get(name \\ nil) do
    url =
      case name do
        nil -> ""
        _ -> Name.url_encode(name)
      end

    response = HTTP.get(security_root() <> url)

    case response do
      {:ok, 200, roles} ->
        {:ok, roles}

      {:error, 404, %{}} ->
        {:error, :not_found}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end
end
