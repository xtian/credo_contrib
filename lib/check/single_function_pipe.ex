defmodule CredoContrib.Check.SingleFunctionPipe do
  @moduledoc """
  Avoid using the pipe operator just once.

  https://github.com/christopheradams/elixir_style_guide#avoid-single-pipelines
  """

  @explanation [
    check: @moduledoc
  ]

  @default_params [ignored_locals: []]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    ignored_locals = Params.get(params, :ignored_locals, @default_params)
    acc = %{issues: [], seen: [], ignored_locals: ignored_locals}

    %{issues: issues} = Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta), acc)

    issues
  end

  defp traverse({:|>, _, [{:|>, _, _}, _] = args} = ast, acc, _) do
    {ast, %{acc | seen: mark_seen(args, acc.seen)}}
  end

  defp traverse({:|>, meta, [_, {fn_name, _, fn_args}]} = ast, acc, issue_meta) do
    cond do
      meta in acc.seen ->
        {ast, acc}

      {fn_name, length(fn_args || []) + 1} in acc.ignored_locals ->
        {ast, acc}

      true ->
        {ast, %{acc | issues: [issue_for(issue_meta, meta[:line]) | acc.issues]}}
    end
  end

  defp traverse(ast, acc, _) do
    {ast, acc}
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message: "Use normal function call syntax instead of a single pipe operator",
      line_no: line_no,
      trigger: :|>
    )
  end

  defp mark_seen([{:|>, meta, args}, _], seen) do
    mark_seen(args, [meta | seen])
  end

  defp mark_seen(_, seen) do
    seen
  end
end
