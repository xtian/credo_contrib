defmodule CredoContrib.TestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import CredoContrib.CheckUtils
    end
  end
end
