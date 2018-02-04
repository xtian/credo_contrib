defmodule CredoContrib.Check.ModuleDirectivesOrderTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.ModuleDirectivesOrder

  test "does not report for expected code" do
    """
    defmodule SomeModule do
      @moduledoc "This is a module"
      @behaviour Foo
      use Bar
      import Baz
      alias Foo.Bar
      require Logger
      defstruct __MODULE__
      @type t :: %__MODULE__{}
      @module_attribute foo
      @callback bar :: t
      @macrocallback
      @optional_callbacks
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for out of order directives" do
    """
    defmodule SomeModule do
      use Bar
      @moduledoc "This is a module"
      @behaviour Foo
      import Baz
      alias Foo.Bar
      require Logger
      defstruct __MODULE__
      @callback bar :: t
      @type t :: %__MODULE__{}
      @module_attribute foo
      @macrocallback
      @optional_callbacks
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end
end
