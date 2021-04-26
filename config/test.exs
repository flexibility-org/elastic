use Mix.Config

config :elastic,
  index_prefix: "elastic",
  use_mix_env: true,
  basic_auth: {"elastic", "password"}
