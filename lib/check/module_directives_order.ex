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
    with {:ok, ast} <- Credo.Code.ast(source_file),
         {:ok, module_body} <- module_body(ast) do
      issue_meta = IssueMeta.for(source_file, params)

      directives =
        module_body
        |> Enum.reduce([], &find_directives/2)
        |> Enum.reverse()

      sorted_directives =
        Enum.sort_by(directives, fn {name, _} ->
          Map.fetch!(@order, name)
        end)

      if directives == sorted_directives do
        []
      else
        [{{_, first_failing_meta}, _} | _] =
          [directives, sorted_directives]
          |> Enum.zip()
          |> Enum.drop_while(fn {a, b} -> a == b end)

        [issue_for(issue_meta, first_failing_meta[:line])]
      end
    else
      _ -> []
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

  def module_body({:defmodule, _, [_, [do: {:__block__, _, body}]]}) do
    {:ok, body}
  end

  def module_body(_) do
    {:error, :no_module}
  end
end
