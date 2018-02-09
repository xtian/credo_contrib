defmodule CredoContrib.Check.FunctionBlockSyntaxTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.FunctionBlockSyntax

  test "does not report for expected code" do
    """
    def foo(1), do: :foo
    def foo(2), do: :bar

    def bar(1), do: :foo
    def bar(2), do: :bar
    def bar(3) do
      :baz
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "does not reports issue for single `do:` definition by default" do
    """
    def foo, do: :foo

    defp foo, do: :bar
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for mixed `do:` and `do … end` definitions" do
    """
    def foo(1) do
      :foo
    end

    def foo(2), do: :bar

    def foo(3) do
      :baz
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "reports issue for single `do:` definition" do
    """
    def foo(_, _), do: :foo

    defp foo, do: :bar
    """
    |> to_source_file()
    |> assert_issues(@described_check, allow_single_kw_defs: false)
  end
end
