defmodule CredoContrib.Check.PipelineLineBreaks do
  @moduledoc """
  Each step of a pipeline should either be on the same line
  or on its own line
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:|>, _, [{:|>, _, _}, _] = args} = ast, acc, _) do
    {ast, acc}
  end

  defp traverse(ast, acc, _) do
    {ast, acc}
  end

  defp issue_for(issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "",
      line_no: line_no,
      trigger: trigger
    )
  end
end
