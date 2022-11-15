defmodule Elastic.HTTPTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  describe "Set middlewares from config" do
    setup do
      Logger.configure(level: :debug)
      Application.delete_env(:elastic, :middlewares)

      :ok
    end

    test "with logger" do
      Application.put_env(
        :elastic,
        :middlewares,
        [{Tesla.Middleware.Logger, debug: true, log_level: :debug}]
      )

      log =
        capture_log(fn ->
          Elastic.HTTP.get(Elastic.base_url() <> "/answer/_search")
        end)

      assert log =~ "[debug] GET http://localhost:9200/answer/_search"
      assert log =~ "authorization: Basic"
    end
  end
end
