%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["config/", "lib/", "src/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      strict: true,
      color: true,
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Readability.MaxLineLength, max_length: 100}
      ]
    }
  ]
}
