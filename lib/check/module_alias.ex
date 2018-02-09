defmodule CredoContrib.Check.ModuleAlias do
  @moduledoc """
  `alias __MODULE__` and `@foo __MODULE__` are not allowed

  https://github.com/christopheradams/elixir_style_guide#module-pseudo-variable
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:@, meta, [{name, _, [{:__MODULE__, _, nil}]}]} = ast, issues, issue_meta) do
    new_issue = issue_for(issue_meta, meta[:line], name)
    {ast, [new_issue | issues]}
  end

  defp traverse({:alias, meta, [{:__MODULE__, _, nil}]} = ast, issues, issue_meta) do
    new_issue = issue_for(issue_meta, meta[:line], :__MODULE__)
    {ast, [new_issue | issues]}
  end

  defp traverse(ast, issues, _) do
    {ast, issues}
  end

  defp issue_for(issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "Use `__MODULE__` directly or `alias __MODULE__, as: SomeName`",
      line_no: line_no,
      trigger: trigger
    )
  end
end
