defmodule Elastic.ResponseHandler do
  @moduledoc false
  alias Jason.DecodeError

  def process({:ok, %{body: body, status: status_code}}) when status_code in 400..599 do
    case decode_body(body) do
      {:ok, decoded_body} ->
        {:error, status_code, decoded_body}

      {:error, error} ->
        json_error(error)
    end
  end

  def process({:ok, %{body: body, status: status_code}}) do
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

  defp json_error(error) do
    {:error, 0,
     %{
       "error" =>
         "Could not decode response into JSON, error: #{inspect(DecodeError.message(error))}"
     }}
  end

  defp decode_body(""), do: {:ok, ""}

  defp decode_body(body) do
    with {:ok, decoded_body} <- Jason.decode(body), do: {:ok, decoded_body}
  end
end
