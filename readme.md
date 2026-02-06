# Ralph Loop Sample with GitHub Copilot CLI

> Autonomous coding loop using the **Ralph Wiggum Method** with GitHub Copilot CLI

## What is Ralph Wiggum?

The **Ralph Wiggum Method** is an autonomous AI coding technique. In its purest form, it's a loop:

```bash
while :; do cat PROMPT.md | coding-agent ; done
```

Ralph reads a prompt, looks at the codebase, decides what's most important, implements it, and loops. Failures don't stop the loop — eventual consistency wins. You tune Ralph by adding "signs" (guardrails in the prompt) when he goes off track.

Learn more at [ghuntley.com/ralph](https://ghuntley.com/ralph/)

### Core Principles

- **One thing per loop** — Ralph picks the most important task each iteration
- **Specs, not stories** — specifications are the source of truth, Ralph decides priority
- **Eventual consistency** — failures are expected, the next loop picks up where it left off
- **Signs on the playground** — when Ralph does something bad, add a guardrail to the prompt
- **Minimize context window** — keep the prompt lean, let the agent discover the codebase

## What This Demo Does

Drives Copilot CLI to build a .NET 10 Hello World console app with multilingual greetings and unit tests — entirely from specs, no human intervention.

Uses `gpt-5-mini` by default (no premium requests needed).

## Quick Start

### Local mode (original behaviour)

```powershell
./ralph.ps1
```

Or with options:

```powershell
./ralph.ps1 -MaxIterations 20 -Model "gpt-5.1-codex-mini"
```

### Remote repository mode

Run Ralph against any remote Git repo that contains a `.ralph/` folder:

```powershell
# Clone, run the loop, then push results back
./ralph.ps1 -Repo "https://github.com/user/repo.git" -Branch main -Push

# Clone and run without pushing (inspect results locally)
./ralph.ps1 -Repo "git@github.com:user/repo.git"
```

By default clones are placed **one level above** the script root (e.g. if Ralph lives in `C:\Projects\RalphPilot`, clones land in `C:\Projects\ralph_<repo>_<timestamp>`). Override with `-CloneDir`:

```powershell
./ralph.ps1 -Repo "https://github.com/user/repo.git" -CloneDir "D:\ralph-clones" -Push
```

### Local directory mode

Point Ralph at an existing local checkout:

```powershell
./ralph.ps1 -WorkDir "C:\Projects\my-app"
```

### Initialise `.ralph/` in a target repo

Before running Ralph against a remote or local repo, scaffold the `.ralph/` folder:

```powershell
./ralph-init.ps1 -Path "C:\Projects\my-app"
```

This creates:

```
.ralph/
  prompt.md        # goal & signs (edit this)
  AGENTS.md        # build/run conventions (Ralph self-updates)
  fix_plan.md      # TODO list (Ralph maintains)
  specs/
    README.md      # put your specification files here
```

Then commit, push, and run `ralph.ps1 -Repo <url> -Push`.

## Repo Structure

```
ralph.ps1              # the loop (local, remote, or workdir mode)
ralph-init.ps1         # scaffold .ralph/ in any target repo
.ralph/                # instructions for Ralph
  prompt.md            # goal, workflow, and signs
  AGENTS.md            # build/run conventions (Ralph self-updates this)
  fix_plan.md          # TODO list (Ralph maintains this)
  specs/
    helloworld.md      # application specification (don't modify)
```

Every Ralph-powered repository uses the same `.ralph/` folder convention.
Use `ralph-init.ps1` to scaffold it in a new repo.

## How It Works

1. `ralph.ps1` resolves the target directory (clone from `-Repo`, use `-WorkDir`, or default to script root)
2. It looks for a `.ralph/` folder containing `prompt.md`
3. Each iteration, Ralph reads specs + fix_plan, picks the most important task, implements it
4. Ralph updates `fix_plan.md` with progress, updates `AGENTS.md` with build learnings
5. On success the loop auto-commits; on failure it continues — next loop fixes it
6. When using `-Repo -Push`, commits are pushed back to the remote after the loop

## Requirements

- PowerShell 5+ or PowerShell 7+
- .NET 10 SDK
- GitHub Copilot CLI (`copilot`) authenticated

## Credits

- Ralph Wiggum Method by [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Built by [Marcel Roozekrans](https://github.com/marcelroozekrans)
- Powered by GitHub Copilot CLI