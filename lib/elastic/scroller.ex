defmodule Elastic.Scroller do
  alias Elastic.Index
  alias Elastic.Scroll

  use GenServer

  @moduledoc ~S"""
  Provides an API for working with [Elastic Search's Scroll API](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-scroll.html)

  ## Example

  ```elixir
  {:ok, pid} = Elastic.Scroller.start_link(%{index: "answer"})
  # get the first "page" of results
  Elastic.Scroller.results(pid)
  # Request the second page
  Elastic.Scroller.next_page(pid)
  # get the second "page" of results
  Elastic.Scroller.results(pid)
  ```

  Then you can choose to kill the search context yourself... keeping in mind
  of course that Elastic Search will do this automatically after the
  keepalive (default of 1 minute) expires for the scroll.

  ```elixir
  Elastic.Scroller.clear(pid)
  ```
  """

  @doc ~S"""
  Starts an Elastic.Scroller server.

  For usage information refer to the documentation at the top of this module.
  """

  @spec start_link(%{
          required(:index) => String.t(),
          optional(:body) => map(),
          optional(:size) => pos_integer(),
          optional(:keepalive) => String.t()
        }) :: {:ok, pid()}
  def start_link(opts = %{index: index}) do
    opts =
      opts
      |> Map.put_new(:body, %{})
      |> Map.put_new(:size, 100)
      |> Map.put_new(:keepalive, "1m")
      |> Map.put(:index, index)

    GenServer.start_link(__MODULE__, opts)
  end

  @spec init(%{
          required(:index) => String.t(),
          required(:body) => map(),
          required(:size) => pos_integer(),
          required(:keepalive) => String.t()
        }) :: {:ok, pid()} | {:stop, String.t()}
  def init(state = %{index: index, body: body, size: size, keepalive: keepalive}) do
    scroll =
      Scroll.start(%{
        index: index,
        body: body,
        size: size,
        keepalive: keepalive
      })

    case scroll do
      {:ok, 200, %{"_scroll_id" => id, "hits" => %{"hits" => hits}}} ->
        {:ok, Map.merge(state, %{scroll_id: id, hits: hits})}

      {:error, _status, error} ->
        {:stop, inspect(error)}
    end
  end

  @doc ~S"""
  Returns the results of the current scroll location.

  ```elixir
  Elastic.Scroller.results(pid)
  ```
  """
  @spec results(pid()) :: [map()]
  def results(pid) do
    GenServer.call(pid, :results)
  end

  @doc ~S"""
  Fetches the next page of results and returns a scroll ID.

  To retrieve the results that come from this request, make a call to `Elastic.Scroller.results/1`.

  ```elixir
  Elastic.Scroller.next_page(pid)
  ```
  """

  @spec next_page(pid()) ::
          {:ok, String.t()}
          | {:error, :search_context_not_found, map()}
          | {:error, String.t()}
  def next_page(pid) do
    GenServer.call(pid, :next_page, Application.get_env(:elastic, :timeout, 30_000))
  end

  @doc false
  @spec scroll_id(pid :: pid()) :: term()
  def scroll_id(pid) do
    GenServer.call(pid, :scroll_id)
  end

  @doc false
  @spec index(pid :: pid()) :: term()
  def index(pid) do
    GenServer.call(pid, :index)
  end

  @doc false
  @spec body(pid :: pid()) :: term()
  def body(pid) do
    GenServer.call(pid, :body)
  end

  @doc false
  @spec keepalive(pid :: pid()) :: term()
  def keepalive(pid) do
    GenServer.call(pid, :keepalive)
  end

  @doc false
  @spec size(pid :: pid()) :: term()
  def size(pid) do
    GenServer.call(pid, :size)
  end

  @doc false
  @spec clear(pid :: pid()) :: term()
  def clear(pid) do
    GenServer.call(pid, :clear)
  end

  @type request ::
          :body
          | :clear
          | :index
          | :keepalive
          | :next_page
          | :results
          | :scroll_id
          | :size

  @type state ::
          %{
            optional(:index) => binary(),
            optional(:body) => any(),
            optional(:keepalive) => boolean(),
            optional(:scroll_id) => binary()
          }

  @spec handle_call(request :: request(), GenServer.from(), state :: state()) ::
          {:reply, reply, new_state}
          | {:reply, reply, new_state, timeout() | :hibernate | {:continue, term()}}
          | {:noreply, new_state}
          | {:noreply, new_state, timeout() | :hibernate | {:continue, term()}}
          | {:stop, reason, reply, new_state}
          | {:stop, reason, new_state}
        when reply: term(), new_state: state(), reason: term()
  def handle_call(:results, _from, state = %{hits: hits}) do
    {:reply, hits, state}
  end

  def handle_call(
        :next_page,
        _from,
        state = %{index: index, body: body, keepalive: keepalive, scroll_id: scroll_id}
      ) do
    scroll = %{
      index: index,
      body: body,
      scroll_id: scroll_id,
      keepalive: keepalive
    }

    case scroll |> Scroll.next() do
      {:ok, 200, %{"_scroll_id" => id, "hits" => %{"hits" => hits}}} ->
        state = state |> Map.merge(%{scroll_id: id, hits: hits})
        {:reply, {:ok, id}, state}

      {:error, 404, error} ->
        {:reply, {:error, :search_context_not_found, error}, state}

      {:error, _, error} ->
        {:reply, {:error, inspect(error)}, state}
    end
  end

  def handle_call(:scroll_id, _from, state = %{scroll_id: scroll_id}) do
    {:reply, scroll_id, state}
  end

  def handle_call(:size, _from, state = %{size: size}) do
    {:reply, size, state}
  end

  def handle_call(:index, _from, state = %{index: index}) do
    {:reply, Index.name(index), state}
  end

  def handle_call(:body, _from, state = %{body: body}) do
    {:reply, body, state}
  end

  def handle_call(:keepalive, _from, state = %{keepalive: keepalive}) do
    {:reply, keepalive, state}
  end

  def handle_call(:clear, _from, state = %{scroll_id: scroll_id}) do
    response = Scroll.clear([scroll_id])
    {:reply, response, state}
  end
end
