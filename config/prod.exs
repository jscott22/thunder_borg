use Mix.Config

import Supervisor.Spec, warn: false

config :thunder_borg,
  i2c: ElixirALE.I2C