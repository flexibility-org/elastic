defmodule Elastic.Document do
  @moduledoc """
  An ElasticSearch document.
  """

  alias Elastic.HTTP
  alias Elastic.Index
  alias Elastic.ResponseHandler

  @type id :: binary() | integer() | atom()

  @spec index(
          index :: binary(),
          type :: binary(),
          id :: id() | nil,
          data :: term()
        ) :: ResponseHandler.result()
  def index(index, type, id, data) do
    document_path(index, type, id) |> HTTP.post(body: data)
  end

  @spec update(
          index :: binary(),
          type :: binary(),
          id :: id(),
          data :: term()
        ) :: ResponseHandler.result()
  def update(index, type, id, data) do
    data = %{doc: data}

    update_path(index, type, id)
    |> HTTP.post(body: data)
  end

  @spec get(
          index :: binary(),
          type :: binary(),
          id :: id()
        ) :: ResponseHandler.result()
  def get(index, type, id) do
    document_path(index, type, id) |> HTTP.get()
  end

  @spec delete(
          index :: binary(),
          type :: binary(),
          id :: id()
        ) :: ResponseHandler.result()
  def delete(index, type, id) do
    document_path(index, type, id) |> HTTP.delete()
  end

  @spec document_path(
          index :: binary(),
          type :: binary(),
          id :: id() | nil
        ) :: binary()
  defp document_path(index, type, id) do
    Elastic.base_url() <> "/#{index_name(index)}/#{type}/#{id}"
  end

  @spec update_path(
          index :: binary(),
          type :: binary(),
          id :: id()
        ) :: binary()
  def update_path(index, type, id) do
    document_path(index, type, id) <> "/_update"
  end

  @spec index_name(index :: binary()) :: binary()
  defp index_name(index) do
    Index.name(index)
  end
end
