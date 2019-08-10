defmodule CredoContrib.Check.DocWhitespace do
  @moduledoc """
  `@moduledoc` and `@doc` strings should not have extra whitespace
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({key, meta, [string]} = ast, issues, issue_meta)
       when key in [:doc, :moduledoc] and is_binary(string) do
    trimmed = String.trim(string)

    if string == trimmed || (string == "#{trimmed}\n" && trimmed != "") do
      {ast, issues}
    else
      new_issue = issue_for(issue_meta, meta[:line], key)
      {ast, [new_issue | issues]}
    end
  end

  defp traverse(ast, issues, _) do
    {ast, issues}
  end

  defp issue_for(issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "Extra whitespace in documentation",
      line_no: line_no,
      trigger: trigger
    )
  end
end
