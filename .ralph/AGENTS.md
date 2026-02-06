# AGENTS.md

## How to build and run

```bash
dotnet restore && dotnet build
dotnet run --project src/HelloWorld
dotnet test
```

## Running tests by category

```bash
# Unit tests only (fast, isolated)
dotnet test --filter "Category=Unit"

# Integration tests only (components wired together)
dotnet test --filter "Category=Integration"

# E2E tests only (launch real executable, verify stdout)
dotnet test --filter "Category=E2E"

# All tests
dotnet test
```

## Test conventions

- Tag every test class or method with `[Trait("Category", "Unit")]`, `[Trait("Category", "Integration")]`, or `[Trait("Category", "E2E")]`.
- Unit tests: no I/O, no process spawning, test one class in isolation.
- Integration tests: may wire real services, DI container, verify component interaction.
- E2E tests: use `System.Diagnostics.Process` to launch the built executable, capture stdout, and assert output format matches the spec (e.g. `Hola (Spanish)`).
- Always document *why* a test exists in a `<summary>` or comment.

## Conventions

- .NET 10 (net10.0), C#, xUnit for tests
- Nullable reference types enabled
- Implicit usings enabled
- TreatWarningsAsErrors = true
- Idiomatic C#, no warnings
