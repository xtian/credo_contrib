defmodule CredoContrib.Check.FunctionNameUnderscorePrefix do
  @moduledoc """
  Function names should not be prefixed with underscores. Consider using do_<name> instead.
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({def_call, meta, [{name, _, _} | _]} = ast, issues, issue_meta)
       when def_call in [:def, :defp] do
    name = Atom.to_string(name)

    if String.starts_with?(name, "_") do
      if String.starts_with?(name, "__") and String.ends_with?(name, "__") do
        {ast, issues}
      else
        {ast, [issue_for(issue_meta, meta[:line], def_call) | issues]}
      end
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _) do
    {ast, issues}
  end

  defp issue_for(issue_meta, line_no, def_call) do
    format_issue(
      issue_meta,
      message:
        "Function names should not be prefixed with underscores. Consider using do_<name> instead.",
      line_no: line_no,
      trigger: def_call
    )
  end
end
