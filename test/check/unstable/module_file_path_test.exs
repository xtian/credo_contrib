defmodule CredoContrib.Check.Unstable.ModuleFilePathTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.Unstable.ModuleFilePath

  test "does not report for conventional module name" do
    """
    defmodule SomeLib.Foo.Bar do
    end
    """
    |> to_source_file("lib/foo/bar.ex")
    |> refute_issues(@described_check)
  end

  test "does not report for module name using plural convention" do
    """
    defmodule SomeLib.FooBarController do
    end
    """
    |> to_source_file("lib/controllers/foo_bar_controller.ex")
    |> refute_issues(@described_check)
  end

  test "does not report for conventional module name in umbrella" do
    """
    defmodule SomeChild.FooBar do
    end
    """
    |> to_source_file("apps/some_child/lib/foo_bar.ex")
    |> refute_issues(@described_check)
  end

  test "does not report for top-level module as lib directory" do
    """
    defmodule CredoContrib.Foo.Bar do
    end
    """
    |> to_source_file("lib/credo_contrib/foo/bar.ex")
    |> refute_issues(@described_check)
  end

  test "does not report for module name using plural convention in umbrella" do
    """
    defmodule SomeChild.FooBarController do
    end
    """
    |> to_source_file("apps/some_child/lib/controllers/foo_bar_controller.ex")
    |> refute_issues(@described_check)
  end

  test "does not report issue for conventional test support module name" do
    """
    defmodule SomeLib.TestUtils do
    end
    """
    |> to_source_file("test/support/test_utils.ex")
    |> refute_issues(@described_check)
  end

  test "does not report issue for conventional test support module name in umbrella" do
    """
    defmodule SomeChild.TestUtils do
    end
    """
    |> to_source_file("apps/some_child/test/support/test_utils.ex")
    |> refute_issues(@described_check)
  end

  test "does not report issue for conventional test module name" do
    """
    defmodule SomeLib.FooBarTest do
    end
    """
    |> to_source_file("test/foo_bar_test.exs")
    |> refute_issues(@described_check)
  end

  test "does not report for web module name using plural convention" do
    """
    defmodule SomeLib.FooBarControllerTest do
    end
    """
    |> to_source_file("web/controllers/foo_bar_controller_test.exs")
    |> refute_issues(@described_check)
  end

  test "does not report for test module name using plural convention" do
    """
    defmodule SomeLib.FooBarControllerTest do
    end
    """
    |> to_source_file("test/controllers/foo_bar_controller_test.exs")
    |> refute_issues(@described_check)
  end

  test "does not report issue for conventional test module name in umbrella" do
    """
    defmodule SomeChild.FooBarTest do
    end
    """
    |> to_source_file("apps/some_child/test/foo_bar_test.exs")
    |> refute_issues(@described_check)
  end

  test "does not report for test module name using plural convention in umbrella" do
    """
    defmodule SomeChild.FooBarControllerTest do
    end
    """
    |> to_source_file("apps/some_child/test/controllers/foo_bar_controller_test.exs")
    |> refute_issues(@described_check)
  end

  test "reports issue for unconventional module name" do
    """
    defmodule SomeLib.Foo.Baz do
    end
    """
    |> to_source_file("lib/foo/bar.ex")
    |> assert_issue(@described_check)
  end

  test "reports issue for conventional module name in umbrella" do
    """
    defmodule SomeChild.FooBar do
    end
    """
    |> to_source_file("apps/some_child/lib/some_child/foo_bar.ex")
    |> assert_issue(@described_check)
  end

  test "reports issue for unconventional test module name" do
    """
    defmodule SomeLib.FooBazTest do
    end
    """
    |> to_source_file("test/foo_bar_test.exs")
    |> assert_issue(@described_check)
  end

  test "reports issue for unconventional test module name in umbrella" do
    """
    defmodule SomeOtherChild.FooBarTest do
    end
    """
    |> to_source_file("apps/some_child/test/foo_bar_test.exs")
    |> assert_issue(@described_check)
  end
end
