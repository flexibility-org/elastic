use Mix.Config

config :elastic,
  index_prefix: "elastic",
  use_mix_env: true,
  basic_auth: {"elastic", "password"}

config :stream_data,
  initial_size: 1,
  max_runs: 100,
  max_run_time: :infinity,
  max_shrinking_steps: 100
