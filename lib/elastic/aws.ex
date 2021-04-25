defmodule Elastic.AWS do
  alias Elastic.HTTP

  @moduledoc false
  def enabled? do
    settings()[:enabled]
  end

  @spec authorization_headers(
          method :: HTTP.method(),
          url :: binary(),
          headers :: map(),
          body :: binary()
        ) :: any()
  def authorization_headers(method, url, headers, body) do
    AWSAuth.sign_authorization_header(
      settings().access_key_id,
      settings().secret_access_key,
      to_string(method),
      url,
      settings().region,
      "es",
      process_headers(method, headers),
      body
    )
  end

  # DELETE requests do not support headers
  @spec process_headers(HTTP.method(), map()) :: %{required(String.t()) => String.t()}
  defp process_headers(:delete, _), do: %{}

  defp process_headers(_method, headers) do
    for {k, v} <- headers,
        into: %{},
        do: {to_string(k), to_string(v)}
  end

  @spec settings() :: term()
  defp settings do
    Application.get_env(:elastic, :aws)
  end
end
