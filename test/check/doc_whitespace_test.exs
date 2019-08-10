# credo:disable-for-this-file Credo.Check.Readability.TrailingWhiteSpace
# credo:disable-for-this-file Credo.Check.Readability.StringSigils
defmodule CredoContrib.Check.DocWhitespaceTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.DocWhitespace

  test "does not report for expected code" do
    """
    @moduledoc \"\"\"
    This is a module
    \"\"\"

    @doc \"\"\"
    This is a function
    \"\"\"
    def foo do
      :foo
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for moduledoc" do
    """
    @moduledoc \"\"\"

    This is a module

    \"\"\"
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "reports issue for doc" do
    """
    @doc \"\"\"

    This is a function

    \"\"\"
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "reports issue for docstrings with only whitespace" do
    """
    @moduledoc \"\"\"

    \"\"\"

    @doc \"\"\"

    \"\"\"
    """
    |> to_source_file()
    |> assert_issues(@described_check)
  end
end
