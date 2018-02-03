defmodule CredoContrib.Check.SingleFunctionPipeTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.SingleFunctionPipe

  test "does not report for expected code" do
    """
    @value_a some_function(:foo)
    @value_b Module.some_function(:bar)

    def foo do
      some_function(:foo)
      Module.some_function(:bar)
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for single pipe in module attribute" do
    """
    @value_a :foo |> some_function()
    @value_b :bar |> Module.some_function
    """
    |> to_source_file()
    |> assert_issues(@described_check)
  end

  test "reports issue for single pipe in function body" do
    """
    def foo do
      :foo |> some_function
      :bar |> Module.some_function()
    end
    """
    |> to_source_file()
    |> assert_issues(@described_check)
  end
end
