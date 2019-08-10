defmodule CredoContrib.Check.EmptyDocString do
  @moduledoc """
  `@doc` strings should contain some explanatory text.

  Use `@doc false` if a macro or function will not be documented.
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:doc, meta, [""]} = ast, issues, issue_meta) do
    {ast, [issue_for(issue_meta, meta[:line]) | issues]}
  end

  defp traverse(ast, issues, _) do
    {ast, issues}
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message: "Use `@doc false` if a macro or function will not be documented.",
      line_no: line_no,
      trigger: :doc
    )
  end
end
