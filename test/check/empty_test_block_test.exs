defmodule CredoContrib.EmptyTestBlockTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.EmptyTestBlock

  test "does not report for expected code" do
    """
    test "not implemented"

    test "implemented" do
      assert true
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue test with empty body" do
    """
    test "empty body" do
    end

    test "empty body with comments" do
      # …
    end
    """
    |> to_source_file()
    |> assert_issues(@described_check)
  end
end
