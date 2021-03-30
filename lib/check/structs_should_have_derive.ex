defmodule CredoContrib.Check.StructsShouldHaveDerive do
  @moduledoc """
  Structs should also have '@derive Jason.Encoder' statement to be safe in case it needs to be serialized
  """
  alias Credo.IssueMeta

  @explanation [
    check: @derive
  ]

  use Credo.Check, base_priority: :high, category: :consistency

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    acc = %{issues: [], struct_found: false, derive_found: false, struct_line: 0}

    case Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta), acc) do
      %{struct_found: true, struct_line: struct_line, derive_found: false, issues: issues} ->
        [issue_for(issue_meta, struct_line) | issues]

      %{issues: issues} ->
        issues
    end
  end

  defp traverse({:defstruct, [line: line, column: _], _} = ast, acc, _) do
    {ast, %{acc | struct_found: true, struct_line: line}}
  end

  defp traverse({:derive, _, _} = ast, acc, _) do
    {ast, %{acc | derive_found: true}}
  end

  defp traverse(ast, acc, _) do
    {ast, acc}
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message:
        "Structs should also have `@derive Jason.Encoder` for being safe in case it nees to be serialized.",
      line_no: line_no,
      trigger: :defstruct
    )
  end
end
