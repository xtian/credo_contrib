defmodule CredoContrib.Check.PipelineLineBreaksTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.PipelineLineBreaks

  test "does not report for expected code" do
    """
    1 |> foo() |> Foo.bar()

    1
    |> foo()
    |> Foo.bar()

    a =
      1
      |> foo()
      |> Foo.bar
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for mixed line-break style" do
    """
    1 |> foo()
    |> Foo.bar()

    a =
      1 |> foo()
      |> Foo.bar
    """
    |> to_source_file()
    |> assert_issues(@described_check)
  end
end
