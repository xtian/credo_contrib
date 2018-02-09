defmodule CredoContrib.Check.FunctionBlockSyntax do
  @moduledoc """
  `def …, do:` syntax should not be mixed with multiple `def … do … end`-style definitions.

  https://github.com/christopheradams/elixir_style_guide#multiple-function-defs
  """

  @explanation [
    check: @moduledoc,
    params: [
      allow_single_kw_defs:
        "Set to `false` to only allow `def …, do:` syntax for functions with multiple heads"
    ]
  ]

  @default_params [allow_single_kw_defs: true]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    allow_single_kw_defs? = Params.get(params, :allow_single_kw_defs, @default_params)

    source_file
    |> Credo.Code.to_tokens()
    |> collect_definitions(%{})
    |> Enum.reduce([], fn
      {{_, name}, %{long: long, short: _, line_no: line_no}}, issues when long > 1 ->
        new_issue = issue_for(:mixed_defs, issue_meta, line_no, name)

        [new_issue | issues]

      {_, %{long: _}}, issues ->
        issues

      {{_, name}, %{short: 1, line_no: line_no}}, issues ->
        if allow_single_kw_defs? do
          issues
        else
          new_issue = issue_for(:single_kw_def, issue_meta, line_no, name)

          [new_issue | issues]
        end

      _, issues ->
        issues
    end)
  end

  defp collect_definitions([], acc) do
    acc
  end

  defp collect_definitions(
         [
           {:identifier, _, def_call},
           {name_identifier, {line_no, _, _}, name}
           | rest
         ],
         acc
       )
       when def_call in [:def, :defp] and name_identifier in [:identifier, :paren_identifier] do
    [block_start | rest] =
      Enum.drop_while(rest, fn
        {:do, _} -> false
        {:kw_identifier, _, :do} -> false
        _ -> true
      end)

    acc =
      case block_start do
        {:do, _} -> count_definition(acc, {def_call, name}, line_no, :long)
        {:kw_identifier, _, :do} -> count_definition(acc, {def_call, name}, line_no, :short)
      end

    collect_definitions(rest, acc)
  end

  defp collect_definitions([_ | rest], acc) do
    collect_definitions(rest, acc)
  end

  defp count_definition(acc, name, line_no, type) do
    case Map.fetch(acc, name) do
      :error ->
        Map.put(acc, name, %{type => 1, line_no: line_no})

      {:ok, %{^type => count} = map} ->
        Map.put(acc, name, %{map | type => count + 1})

      {:ok, map} ->
        Map.put(acc, name, Map.put(map, type, 1))
    end
  end

  defp issue_for(:mixed_defs, issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message:
        "`def …, do:` syntax should not be mixed with multiple `def … do … end`-style definitions",
      line_no: line_no,
      trigger: trigger
    )
  end

  defp issue_for(:single_kw_def, issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "`def …, do:` syntax should only be used for functions with multiple heads",
      line_no: line_no,
      trigger: trigger
    )
  end
end
