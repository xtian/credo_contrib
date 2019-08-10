# CredoContrib [![Build Status][travis-badge]][travis] [![Hex][hex-badge]][hex]

CredoContrib is a set of additional checks for the [Credo static analysis tool][credo].
Many of the checks are implementations of rules from
[christopheradams/elixir_style_guide][styleguide]. Contributions welcome!

[credo]: https://github.com/rrrene/credo
[hex-badge]: https://img.shields.io/hexpm/v/credo_contrib.svg
[hex]: https://hex.pm/packages/credo_contrib
[styleguide]: https://github.com/christopheradams/elixir_style_guide
[travis-badge]: https://travis-ci.org/xtian/credo_contrib.svg?branch=master
[travis]: https://travis-ci.org/xtian/credo_contrib

## Installation

Add `credo_contrib` to the list of dependencies in your `mix.exs`:

```elixir
def deps do
  [
    {:credo_contrib, "~> 0.2.0"}
  ]
end
```

## Usage

Add `CredoContrib` as a plugin in your `.credo.exs` to enable all checks:

```
%{
  configs: [
    %{
      name: "default",
      plugins: [
        {CredoContrib, []}
      ]
    }
  ]
}
```

Or add the desired checks individually:

```elixir
%{
  configs: [
    %{
      name: "default",
      checks: [
        {CredoContrib.Check.FunctionBlockSyntax, allow_single_kw_defs: false},
        # …
      ]
    }
  ]
}
```

## Available Checks

#### `CredoContrib.Check.DocWhitespace`

Disallows extranneous whitespace in documentation strings:

```elixir
## GOOD

defmodule Foo do
  @moduledoc """
  This is a module
  """

  @doc """
  This is a function
  """
  def bar do
    :ok
  end
end

## BAD

defmodule Foo do
  @moduledoc """

  This is a module

  """

  @doc """

  This is a function

  """
  def bar do
    :ok
  end
end
```

---

#### `CredoContrib.Check.EmptyDocString`

Disallows `@doc` strings that do not contain any text.

```elixir
## GOOD

@doc """
This is a function
"""
def bar do
  :ok
end

## BAD

@doc """
"""
def bar do
  :ok
end
```

---

#### `CredoContrib.Check.EmptyTestBlock`

Disallows usage of [ExUnit.Case.test/3][test-3] with an empty body.

For unimplemented tests, use [ExUnit.Case.test/1][test-1] and set `ExUnit.start(except: [:not_implemented])`

```elixir
## GOOD

test "something not implemented"

test "something implemented" do
  assert 1 + 1 == 2
end

## BAD

test "something not implemented" do
end
```

[test-1]: https://hexdocs.pm/ex_unit/ExUnit.Case.html#test/1
[test-3]: https://hexdocs.pm/ex_unit/ExUnit.Case.html#test/3

---

#### `CredoContrib.Check.FunctionBlockSyntax`

Disallows mixing of `def …, do:` syntax with multiple `def … do … end`-style
definitions

https://github.com/christopheradams/elixir_style_guide#multiple-function-defs

#### Options

* `allow_single_kw_defs` (default: `true`): Set to `false` to only allow `def …, do:` syntax for
  functions with multiple heads

---

#### `CredoContrib.Check.FunctionNameUnderscorePrefix`

Disallows function names prefixed with a single underscore

https://github.com/christopheradams/elixir_style_guide#private-functions-with-same-name-as-public

---

#### `CredoContrib.Check.ModuleAlias`

Disallows `alias __MODULE__` and `@foo __MODULE__`

https://github.com/christopheradams/elixir_style_guide#module-pseudo-variable

---

#### `CredoContrib.Check.ModuleDirectivesOrder`

Enforces consistent ordering for module attributes and directives.

https://github.com/christopheradams/elixir_style_guide#module-attribute-ordering

---

#### `CredoContrib.Check.Unstable.ModuleFilePath`

Enforces a consistent naming scheme for modules based on their file path

```elixir
## GOOD

# lib/foo/bar.ex
defmodule SomeApp.Foo.Bar do
end

# lib/controllers/bar_controller.ex
defmodule SomeApp.BarController do
end

## BAD

# lib/foo/bar/bar.ex
defmodule SomeApp.Foo.Bar do
end

# lib/utils/foo.ex
defmodule SomeApp.Foo do
end
```

---

#### `CredoContrib.Check.PublicPrivateFunctionName`

Disallows public and private functions with the same name

https://github.com/christopheradams/elixir_style_guide#private-functions-with-same-name-as-public

---

#### `CredoContrib.Check.SingleFunctionPipe`

Disallows usage of the pipe operator with a single function call

https://github.com/christopheradams/elixir_style_guide#avoid-single-pipelines

#### Options

* `ignored_locals`: Keyword list of names and arities of local functions to ignore. E.g., `[expect: 3, stub: 3]`

## Development

### Setup

```
bin/setup
```

### Running the tests

```
bin/test
```

## License

[ISC](LICENSE.md)
