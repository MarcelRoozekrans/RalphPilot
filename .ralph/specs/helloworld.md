# HelloWorld Specification

## Overview

A .NET 10 console application that prints exactly one random greeting in a different language each run.

## Technical Requirements

- Target framework: net10.0
- Language: C#
- Nullable reference types: enabled
- Implicit usings: enabled
- TreatWarningsAsErrors: true
- Solution format: .slnx at repository root

## Project Layout

- `src/HelloWorld/` — console application
- `tests/HelloWorld.Tests/` — xUnit test project

## Greeting Behaviour

- Maintain a fixed in-code list of (Language, Greeting) pairs.
- On each run, randomly select one pair and print it.
- Output format: `<Greeting> (<Language>)` — e.g. `Hola (Spanish)`

## Testing

All tests use xUnit. Every test must be tagged with a `[Trait("Category", "...")]`.

### Unit Tests (`Category=Unit`)

- Test `GreetingProvider` (or similar) in isolation.
- Validate that `GetGreeting()` always returns one of the predefined (Language, Greeting) pairs.
- Validate the full list of greetings is non-empty.
- Validate greeting format: neither Language nor Greeting is null or whitespace.
- No I/O, no process spawning, no console dependency.

### Integration Tests (`Category=Integration`)

- Wire up the real dependency graph (DI container or manual composition).
- Call the composed service and verify it returns a valid greeting tuple.
- Verify the output formatter produces the correct string format: `<Greeting> (<Language>)`.
- May test multiple components together but still runs in-process.

### E2E Tests (`Category=E2E`)

- Launch the compiled `HelloWorld` executable as a real OS process using `System.Diagnostics.Process`.
- Capture stdout.
- Verify exactly one line of output matching the regex `^.+ \(.+\)$` (e.g. `Hola (Spanish)`).
- Verify the output is one of the predefined greetings.
- Run the process multiple times to confirm randomness (not always the same greeting).
