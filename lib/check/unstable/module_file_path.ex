defmodule CredoContrib.Check.Unstable.ModuleFilePath do
  @moduledoc """
  A module's name should match its file path
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, base_priority: :high, category: :readability

  def run(%SourceFile{filename: filename} = source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    with {:ok, meta, actual_name} <- source_file |> Credo.Code.ast() |> module_name(filename),
         false <- filename |> possible_names() |> Enum.any?(&name_matches?(actual_name, &1)) do
      [issue_for(issue_meta, meta[:line])]
    else
      _ -> []
    end
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message: "Module name does not match file path",
      line_no: line_no,
      trigger: :defmodule
    )
  end

  defp module_name({:ok, {:defmodule, meta, [{:__aliases__, _, name_parts} | _]}}, filename) do
    if String.ends_with?(filename, "mix.exs") do
      {:error, :mixfile}
    else
      name = name_parts |> Enum.map(&Atom.to_string/1) |> Enum.join(".")
      {:ok, meta, name}
    end
  end

  defp module_name(_, _) do
    {:error, :no_module}
  end

  defp name_matches?(actual, possible) do
    actual == possible || String.ends_with?(actual, ".#{possible}")
  end

  defp possible_names(filename) do
    parts =
      filename
      |> Path.rootname()
      |> String.trim_leading("apps/")
      |> String.replace(~r"lib/|test/support/|test/|web/", "")
      |> String.split("/")
      |> Enum.map(&Macro.camelize/1)

    standard_name =
      with false <- String.ends_with?(filename, "_test.exs"),
           [a, a] <- parts do
        a
      else
        _ -> Enum.join(parts, ".")
      end

    with [module, parent | rest] <- Enum.reverse(parts),
         true <- matches_plural_parent?(module, parent, filename) do
      plural_directory_name = [module | rest] |> Enum.reverse() |> Enum.join(".")

      [standard_name, plural_directory_name]
    else
      _ -> [standard_name]
    end
  end

  defp matches_plural_parent?(module, parent, filename) do
    parent_type = String.trim_trailing(parent, "s")

    if String.ends_with?(filename, "_test.exs") do
      String.ends_with?(module, parent_type <> "Test")
    else
      String.ends_with?(module, parent_type)
    end
  end
end
