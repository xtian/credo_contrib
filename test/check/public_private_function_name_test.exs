defmodule CredoContrib.Check.PublicPrivateFunctionNameTest do
  use CredoContrib.TestCase, async: true

  @described_check CredoContrib.Check.PublicPrivateFunctionName

  test "does not report for expected code" do
    """
    defmodule Foo do
      def foo do
        :foo
      end

      def bar do
        :bar
      end
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  test "reports issue for private function with same name as private function" do
    """
    defmodule Foo do
      def foo(1) do
        foo()
      end

      defp foo do
        :foo
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "handles nested modules" do
    """
    defmodule Foo do
      defmodule ChildModule do
        def foo do
          :foo
        end
      end

      defp foo do
        ChildModule.foo
      end
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end
end
