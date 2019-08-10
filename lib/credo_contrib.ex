defmodule CredoContrib do
  @moduledoc false

  alias Credo.Plugin

  @config_file :code.priv_dir(:credo_contrib)
               |> Path.join(".credo.exs")
               |> File.read!()

  def init(exec) do
    Plugin.register_default_config(exec, @config_file)
  end
end
