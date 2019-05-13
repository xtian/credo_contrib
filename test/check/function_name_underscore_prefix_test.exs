defmodule CredoContrib.Check.FunctionNameUnderscorePrefixTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.FunctionNameUnderscorePrefix

  test "does not report for expected code" do
    """
    def foo_bar do
      :foo_bar
    end

    defp foo do
      :foo
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issues for public functions" do
    """
    def _foo_bar do
      :foo_bar
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "reports issues for private functions" do
    """
    defp _foo do
      :foo
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end
end
