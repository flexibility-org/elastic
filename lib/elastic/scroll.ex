defmodule Elastic.Scroll do
  @moduledoc ~S"""
    Provides Elixir functions for ElasticSearch's scroll endpoint](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-scroll.html#search-request-scroll).

    You should probably be using `Elastic.Scroller` instead.
  """

  alias Elastic.HTTP
  alias Elastic.Index
  alias Elastic.ResponseHandler

  @scroll_endpoint Elastic.base_url() <> "/_search/scroll"

  @doc ~S"""
    Starts a new scroll using [ElasticSearch's scroll endpoint](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-scroll.html#search-request-scroll).

    ```elixir
    Elastic.Scroll.start(%{
      index: "answer",
      body: %{} # a query can go here
      size: 100,
      keepalive: "1m"
    })
    ```
  """
  @spec start(%{
          required(:index) => String.t(),
          required(:body) => map(),
          required(:size) => pos_integer(),
          required(:keepalive) => String.t()
        }) :: ResponseHandler.result()
  def start(%{index: index, body: body, size: size, keepalive: keepalive}) do
    body = body |> Map.merge(%{size: size})
    url = Elastic.base_url() <> "/#{Index.name(index)}/_search?scroll=#{keepalive}"
    HTTP.get(url, body: body)
  end

  @doc ~S"""
    Fetches the next batch of results from a specified scroll.

    ```elixir
    Elastic.Scroll.next(%{
      scroll_id: "<a base64 scroll ID goes here>"
      keepalive: "1m"
    })
    ```
  """
  @spec next(%{
          optional(:body) => any(),
          optional(:index) => any(),
          required(:scroll_id) => any(),
          required(:keepalive) => any()
        }) :: ResponseHandler.result()
  def next(%{scroll_id: scroll_id, keepalive: keepalive}) do
    HTTP.get(@scroll_endpoint, body: %{scroll_id: scroll_id, scroll: keepalive})
  end

  @doc ~S"""
    Clears the specified scroll by calling [this endpoint](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-scroll.html#_clear_scroll_api)

    ```elixir
      Elastic.Scroll.clear("<Base64 Scroll ID goes here>")
    ```

    Can also be used to clear multiple scrolls at the same time:

    ```elixir
      Elastic.Scroll.clear([
        "<Base64 Scroll ID goes here>",
        "<Base64 Scroll ID goes here>"
      ])
    ```
  """
  @spec clear(String.t() | [String.t(), ...]) :: ResponseHandler.result()
  def clear(scroll_id) do
    HTTP.delete(@scroll_endpoint, body: %{scroll_id: scroll_id})
  end
end
