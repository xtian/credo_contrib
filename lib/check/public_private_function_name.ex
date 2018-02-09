defmodule CredoContrib.Check.PublicPrivateFunctionName do
  @moduledoc """
  Public and private functions should not share a name

  https://github.com/christopheradams/elixir_style_guide#private-functions-with-same-name-as-public
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:defmodule, _, [_, [do: {:__block__, _, module_body}]]} = ast, acc, issue_meta) do
    definitions = Enum.reduce(module_body, %{public: %{}, private: %{}}, &find_definitions/2)

    acc =
      definitions.private
      |> Enum.filter(fn {name, _} -> definitions.public[name] end)
      |> Enum.reduce(acc, fn {name, meta}, acc ->
        [issue_for(issue_meta, meta[:line], name) | acc]
      end)

    {ast, acc}
  end

  defp traverse(ast, acc, _) do
    {ast, acc}
  end

  defp find_definitions({:def, meta, [{:when, _, [{name, _, _} | _]} | _]}, acc) do
    %{acc | public: Map.put(acc.public, name, meta)}
  end

  defp find_definitions({:def, meta, [{name, _, _} | _]}, acc) do
    %{acc | public: Map.put(acc.public, name, meta)}
  end

  defp find_definitions({:defp, meta, [{:when, _, [{name, _, _} | _]} | _]}, acc) do
    %{acc | private: Map.put(acc.private, name, meta)}
  end

  defp find_definitions({:defp, meta, [{name, _, _} | _]}, acc) do
    %{acc | private: Map.put(acc.private, name, meta)}
  end

  defp find_definitions(_, acc) do
    acc
  end

  defp issue_for(issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "Private functions should not share a name with public functions",
      line_no: line_no,
      trigger: trigger
    )
  end
end
