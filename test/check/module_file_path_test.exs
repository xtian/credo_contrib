defmodule CredoContrib.Check.ModuleFilePathTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.ModuleFilePath

  @valid_module_names %{
    "apps/some_child/lib/controllers/foo_bar_controller.ex" => "SomeChild.FooBarController",
    "apps/some_child/lib/controller/foo/bar_controller.ex" => "SomeChild.Foo.BarController",
    "apps/some_child/lib/foo_bar.ex" => "SomeChild.FooBar",
    "apps/some_child/test/controllers/foo_bar_controller_test.exs" =>
      "SomeChild.FooBarControllerTest",
    "apps/some_child/test/foo_bar_test.exs" => "SomeChild.FooBarTest",
    "apps/some_child/test/support/test_utils.ex" => "SomeChild.TestUtils",
    "lib/controllers/foo_bar_controller.ex" => "SomeLib.FooBarController",
    "lib/controllers/foo/bar_controller.ex" => "SomeLib.Foo.BarController",
    "lib/credo_contrib/foo/bar.ex" => "CredoContrib.Foo.Bar",
    "lib/foo/bar.ex" => "SomeLib.Foo.Bar",
    "test/controllers/foo_bar_controller_test.exs" => "SomeLib.FooBarControllerTest",
    "test/foo_bar_test.exs" => "SomeLib.FooBarTest",
    "test/support/test_utils.ex" => "SomeLib.TestUtils",
    "web/controllers/foo_bar_controller_test.exs" => "SomeLib.FooBarControllerTest"
  }

  @invalid_module_names %{
    "apps/some_child/lib/some_child/foo_bar.ex" => "SomeChild.FooBar",
    "apps/some_child/test/foo_bar_test.exs" => "SomeOtherChild.FooBarTest",
    "lib/foo/bar.ex" => "SomeLib.Foo.Baz",
    "test/foo_bar_test.exs" => "SomeLib.FooBazTest"
  }

  test "does not report issue for conventional module names" do
    for {path, valid_module_name} <- @valid_module_names do
      """
      defmodule #{valid_module_name} do
      end
      """
      |> to_source_file(path)
      |> refute_issues(@described_check)
    end
  end

  test "reports issue for unconventional module names" do
    for {path, invalid_module_name} <- @invalid_module_names do
      """
      defmodule #{invalid_module_name} do
      end
      """
      |> to_source_file(path)
      |> assert_issue(@described_check)
    end
  end
end
