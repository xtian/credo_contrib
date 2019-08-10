defmodule CredoContrib.Check.EmptyDocStringTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.EmptyDocString

  test "does not report for expected code" do
    """
    @doc false
    def foo do
    end

    @doc "Some text"
    def bar do
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for @doc with empty string" do
    """
    @doc ""
    def foo do
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end
end
