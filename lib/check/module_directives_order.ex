defmodule CredoContrib.Check.ModuleDirectivesOrder do
  @moduledoc """
  Module directives and special attributes should follow a consistent order

  https://github.com/christopheradams/elixir_style_guide#module-attribute-ordering
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  @order [
           :moduledoc,
           :behaviour,
           :use,
           :import,
           :alias,
           :require,
           :defstruct,
           :type,
           :module_attribute,
           :callback,
           :macrocallback,
           :optional_callbacks
         ]
         |> Enum.with_index()
         |> Enum.into(%{})

  @attributes [
    :behaviour,
    :callback,
    :macrocallback,
    :module_attribute,
    :moduledoc,
    :optional_callbacks,
    :type
  ]

  @directives [
    :alias,
    :defstruct,
    :import,
    :require,
    :use
  ]

  @printable_attributes Enum.map(@attributes, &{&1, "@#{&1}"})
  @printable_directives Enum.map(@directives, &{&1, "#{&1}"})

  @printable_order (@printable_attributes ++ @printable_directives)
                   |> Enum.sort_by(fn {k, _} -> Map.fetch!(@order, k) end)
                   |> Enum.map(&elem(&1, 1))
                   |> Enum.join(", ")

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:defmodule, _, [_, [do: {:__block__, _, module_body}]]} = ast, acc, issue_meta) do
    case first_unordered_directive(module_body) do
      nil ->
        {ast, acc}

      {_, directive_meta} ->
        {ast, [issue_for(issue_meta, directive_meta[:line]) | acc]}
    end
  end

  defp traverse(ast, acc, _) do
    {ast, acc}
  end

  defp first_unordered_directive(module_body) do
    directives = Enum.reduce(module_body, [], &find_directives/2)

    sorted_directives =
      Enum.sort_by(directives, fn {name, _} -> Map.fetch!(@order, name) * -1 end)

    if directives == sorted_directives do
      nil
    else
      [{directive, _} | _] =
        [directives, sorted_directives]
        |> Enum.zip()
        |> Enum.reverse()
        |> Enum.drop_while(fn {a, b} -> a == b end)

      directive
    end
  end

  defp find_directives({:@, _, [{directive, meta, _}]}, directives)
       when directive in @attributes do
    [{directive, meta} | directives]
  end

  defp find_directives({directive, meta, _}, directives) when directive in @directives do
    [{directive, meta} | directives]
  end

  defp find_directives(_, directives) do
    directives
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message:
        "Module directives and special attributes must be in the following order: " <>
          @printable_order,
      line_no: line_no,
      trigger: nil
    )
  end
end
