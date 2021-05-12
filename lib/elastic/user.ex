defmodule Elastic.User do
  @moduledoc """
  An API wrapper for dealing with ElasticSearch users.

  In particular, this wrapper covers the following elements of the
  [ElasticSearch REST API](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html):

  * [Create or update users API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-user.html)
  * [Get users API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-user.html)
  * [Change passwords API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-change-password.html)
  * [Delete users API](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-user.html)
  """

  alias Elastic.HTTP
  alias Elastic.ResponseHandler
  alias Elastic.User.Name

  @base_url Elastic.base_url() <> "/_security/user/"

  @spec upsert(
          username :: binary(),
          password :: {:password, binary()} | {:password_hash, binary()},
          body :: %{roles: list(binary())}
        ) :: ResponseHandler.upsert_result()
  def upsert(username, password, body \\ %{roles: []}) do
    response =
      HTTP.put(@base_url <> Name.url_encode(username),
        body: Enum.into([password], body)
      )

    case response do
      {:ok, 200, %{"created" => true}} ->
        {:ok, :created}

      {:ok, 200, %{"created" => false}} ->
        {:ok, :updated}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end

  @doc """
  Change the password of the given user.

  If no user is given (`nil`), changes the password of the current
  user.
  """
  @spec change_password(
          new_password :: binary(),
          username :: binary() | nil
        ) :: ResponseHandler.find_result()
  def change_password(new_password, username \\ nil) do
    url =
      case username do
        nil -> "/_password"
        _ -> Name.url_encode(username) <> "/_password"
      end

    response = HTTP.post(@base_url <> url, body: %{password: new_password})

    case response do
      {:ok, 200, %{}} ->
        :ok

      {:error, 400,
       %{
         "error" => %{
           "reason" => "Validation Failed: 1: user must exist in order to change password;"
         }
       }} ->
        {:error, :not_found}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end

  @spec delete(username :: binary()) :: ResponseHandler.find_result()
  def delete(username) do
    HTTP.delete(@base_url <> Name.url_encode(username))
    |> ResponseHandler.process_find_response()
  end

  @spec get(username :: binary() | nil) :: {:ok, map()} | ResponseHandler.find_error()
  def get(username \\ nil) do
    url =
      case username do
        nil -> ""
        _ -> Name.url_encode(username)
      end

    response = HTTP.get(@base_url <> url)

    case response do
      {:ok, 200, users} ->
        {:ok, users}

      {:error, 404, %{}} ->
        {:error, :not_found}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end
end
