defmodule CredoContrib.Check.ModuleAliasTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.ModuleAlias

  test "does not report for expected code" do
    """
    alias __MODULE__, as: SomeName
    alias SomeName
    @foo SomeName
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for alias" do
    """
    alias __MODULE__
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "reports issue for module attribute" do
    """
    @foo __MODULE__
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end
end
