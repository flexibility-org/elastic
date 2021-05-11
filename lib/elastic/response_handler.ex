defmodule Elastic.ResponseHandler do
  @moduledoc """
    Handles all responses from the ElasticSearch API.
  """

  alias Jason.DecodeError
  alias Tesla.Env

  @type status :: Env.status()
  @type error :: {:error, status(), %{required(String.t()) => any()}}
  @type tuple_error :: {status(), %{required(String.t()) => any()}}
  @type result :: {:ok, status(), any()} | error()

  @spec process(Env.result()) :: result()
  def process({:ok, %Env{body: body, status: status_code}}) when status_code in 400..599 do
    case decode_body(body) do
      {:ok, decoded_body} ->
        {:error, status_code, decoded_body}

      {:error, error} ->
        json_error(error)
    end
  end

  def process({:ok, %Env{body: body, status: status_code}}) do
    case decode_body(body) do
      {:ok, decoded_body} ->
        {:ok, status_code, decoded_body}

      {:error, error} ->
        json_error(error)
    end
  end

  def process({:error, :econnrefused}) do
    {:error, 0,
     %{"error" => "Could not connect to Elasticsearch: connection refused (econnrefused)"}}
  end

  def process({:error, :nxdomain}) do
    {:error, 0,
     %{"error" => "Could not connect to Elasticsearch: could not resolve address (nxdomain)"}}
  end

  def process({:error, :connection_closed}) do
    {:error, 0,
     %{"error" => "Could not connect to Elasticsearch: connection closed (connection_closed)"}}
  end

  def process({:error, :req_timedout}) do
    {:error, 0,
     %{"error" => "Could not connect to Elasticsearch: request timed out (req_timedout)"}}
  end

  def process({:error, reason}) do
    {:error, 0,
     %{
       "error" =>
         "Could not connect to Elasticsearch: " <>
           Kernel.inspect(reason)
     }}
  end

  @type unknown_response_value :: {:unknown_response, tuple_error()}
  @type find_error :: {:error, :not_found | unknown_response_value()}
  @type find_result :: :ok | find_error()

  @spec process_find_response(result()) :: find_result()
  def process_find_response(response) do
    case response do
      {:ok, 200, %{"found" => true}} ->
        :ok

      {:error, 404, %{"found" => false}} ->
        {:error, :not_found}

      {_, status_code, data} ->
        {:error, {:unknown_response, {status_code, data}}}
    end
  end

  @type upsert_error :: {:error, unknown_response_value()}
  @type upsert_result :: {:ok, :created | :updated} | upsert_error()

  @spec json_error(DecodeError.t()) :: error()
  defp json_error(error) do
    {:error, 0,
     %{
       "error" =>
         "Could not decode response into JSON, error: #{inspect(DecodeError.message(error))}"
     }}
  end

  @spec decode_body(binary()) :: {:ok, any()} | {:error, DecodeError.t()}
  defp decode_body(""), do: {:ok, ""}

  defp decode_body(body) do
    Jason.decode(body)
  end
end
