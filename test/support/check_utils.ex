defmodule CredoContrib.CheckUtils do
  @moduledoc """
  Test utils cribbed from the main credo repo:

  https://git.io/vNxf5
  """

  alias Credo.Execution.Issues
  alias Credo.SourceFile
  alias ExUnit.Assertions

  def assert_issues(source_file, callback) when is_function(callback) do
    assert_issues(source_file, nil, [], callback)
  end

  def assert_issues(source_file, check, callback) when is_function(callback) do
    assert_issues(source_file, check, [], callback)
  end

  def assert_issues(source_file, check \\ nil, params \\ [], callback \\ nil) do
    issues = issues_for(source_file, check, create_config(), params)

    Assertions.assert(Enum.count(issues) > 0, "There should be multiple issues, got none.")

    Assertions.assert(
      Enum.count(issues) > 1,
      "There should be more than one issue, got: #{to_inspected(issues)}"
    )

    if callback, do: callback.(issues)

    issues
  end

  def refute_issues(source_file, check \\ nil, params \\ []) do
    issues = issues_for(source_file, check, create_config(), params)

    Assertions.assert(
      [] == issues,
      "There should be no issues, got #{Enum.count(issues)}: #{to_inspected(issues)}"
    )

    issues
  end

  def to_source_file(source) do
    to_source_file(source, generate_file_name())
  end

  def to_source_file(source, filename) do
    case Credo.SourceFile.parse(source, filename) do
      %{valid?: true} = source_file ->
        source_file

      _ ->
        raise "Source could not be parsed!"
    end
  end

  def to_source_files(list) do
    Enum.map(list, &to_source_file/1)
  end

  defp create_config do
    %Credo.Execution{}
    |> Credo.Execution.SourceFiles.start_server()
    |> Credo.Execution.Issues.start_server()
  end

  defp generate_file_name do
    "test-untitled.#{System.unique_integer([:positive])}.ex"
  end

  defp get_issues_from_source_file(source_file, exec) do
    Issues.get(exec, source_file)
  end

  defp issues_for(source_files, nil, exec, _) when is_list(source_files) do
    Enum.flat_map(source_files, &(&1 |> get_issues_from_source_file(exec)))
  end

  defp issues_for(source_files, check, _exec, params) when is_list(source_files) do
    exec = create_config()

    if check.run_on_all? do
      :ok = check.run(source_files, exec, params)

      source_files
      |> Enum.flat_map(&(&1 |> get_issues_from_source_file(exec)))
    else
      source_files
      |> check.run(params)
      |> Enum.flat_map(&(&1 |> get_issues_from_source_file(exec)))
    end
  end

  defp issues_for(%SourceFile{} = source_file, nil, exec, _) do
    source_file |> get_issues_from_source_file(exec)
  end

  defp issues_for(%SourceFile{} = source_file, check, _exec, params) do
    _issues = check.run(source_file, params)
  end

  defp to_inspected(value) do
    value
    |> Inspect.Algebra.to_doc(%Inspect.Opts{})
    |> Inspect.Algebra.format(50)
    |> Enum.join("")
  end
end
