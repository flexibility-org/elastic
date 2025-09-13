import Config

import_config "#{Mix.env()}.exs"

config :tesla, adapter: Tesla.Adapter.Mint
config :tesla, disable_deprecated_builder_warning: true
