# AGENTS.md: RalphPilot

RalphPilot is a small PowerShell sample of the Ralph Wiggum loop: `ralph.ps1` calls an agent CLI
(GitHub Copilot CLI by default, or `claude` with `-CLI claude`) over and over with `.ralph/prompt.md`
until `-MaxIterations` is reached. `ralph-init.ps1` copies the `.ralph/` folder into another repo. There
is no build output, no package and no .NET code in this repo: the HelloWorld app in the specs is what
the loop builds in a target repo.

## Layout

- `ralph.ps1` and `ralph-init.ps1` are the whole product. Everything else is documentation or template.
- `.ralph/` is the template that `ralph-init.ps1` copies verbatim into a target repo, and that
  `ralph.ps1` reads when it runs in this repo (self mode, the default without `-Repo` or `-WorkDir`).
- `.ralph/AGENTS.md` is part of the product, not instructions about these scripts: the build and
  test conventions of the sample HelloWorld app (.NET 10, xUnit, `src/HelloWorld`,
  `tests/HelloWorld.Tests`). Do not merge it with this file.
- During a self-mode loop run, `.ralph/prompt.md` drives the run: the loop's agent follows it and
  `.ralph/AGENTS.md`, and updates `.ralph/fix_plan.md` as the prompt says.
- Outside a loop run, when you work on the scripts, change the files under `.ralph/` only as a
  deliberate change to the shipped template, because `ralph-init.ps1` copies them into every new
  target repo.
- The `.ralph/specs/` files are the spec the loop builds from; the prompt tells the loop never to
  change them.

## Build and test

There is no build and there are no tests, and no CI workflow exists. The only check that applies is a
syntax parse of both scripts, run without executing them:

```powershell
foreach ($f in 'ralph.ps1','ralph-init.ps1') {
  $e = $null
  [System.Management.Automation.Language.Parser]::ParseFile("$PWD/$f", [ref]$null, [ref]$e) | Out-Null
  "$f errors: $($e.Count)"
}
```

Both scripts parse with 0 errors on PowerShell 7.6. The readme says PowerShell 5 or 7 is required;
only 7 has been checked.

To try `ralph-init.ps1` safely, point it at an empty temporary directory:
`pwsh -NoProfile -File ./ralph-init.ps1 -Path "$(mktemp -d)"`. It copies `.ralph/` and prints the
next steps.

## Conventions and gotchas

- Never run `ralph.ps1` to test a change. It starts an autonomous agent with permission checks off
  (`copilot --yolo --no-ask-user`, or `claude --dangerously-skip-permissions`) and, per
  `.ralph/prompt.md`, that agent runs `git add -A`, `git commit` and `git push` in the target
  directory. Without `-Repo` or `-WorkDir` the target is this repo.
- The loop itself does not commit. Only the agent does, following `.ralph/prompt.md`. `-Push` pushes
  once after the last iteration and only in `-Repo` mode.
- `ralph-init.ps1` copies the whole `.ralph/` folder, so any file added there ships to every new
  target repo. It skips silently (exit 0) when the target already has `.ralph/`.
- `ralph.ps1` stops after scaffolding (exit 0) when the target has no `.ralph/` folder. That is by
  design: the user must edit the template before the loop runs.
- A change to the CLI options, defaults or modes of `ralph.ps1` needs the same change in the usage
  comments at the top of the script and in `readme.md`.

## Exceptions to the org rules

This repo is an exception to the org rules below; what holds instead is stated per rule.

- Releases: the org rule says release-please reads Conventional Commits on the default branch. This
  repo has no release-please and no `release-please-config.json`, and nothing is released or
  versioned. Conventional Commit subjects are still expected for history, but they open no release PR,
  so there is nothing to check after a merge.
- CI: the org rule says .NET repos call the shared `ci-baseline` workflows. This repo has no
  `.github/workflows/` and is not a .NET repo, so there is no required check. Verify a change with the
  syntax parse above.
- Coverage: the 80% line-coverage floor and the Codecov gate do not apply. The repo has no tests and no
  coverage upload, and there is no issue to raise a floor, because there is no floor to lower.

The branch and PR rule and the commit body rule hold unchanged.

<!-- org-core:start sha256=08a88996bc9165f888fc0260607cfd0670cae128c323e16707c6b452ee66222d (generated from docker-nuc scripts/agents-md/org-core-personal.md; do not edit here) -->
## Org rules

These rules hold in every public MarcelRoozekrans repo.

### Commits and releases

- Conventional Commits. release-please reads them on the default branch, and the changelog sections
  in `release-please-config.json` decide which types count. The standard: `feat`, `fix`, `perf`,
  `deps` and `revert` open or update the release PR; `docs`, `test`, `refactor`, `build`, `ci`,
  `chore` and `style` do not, unless the commit is breaking or has a `Release-As:` footer. The
  release happens when that PR merges. A breaking change needs `!` or a `BREAKING CHANGE:` footer.
- A commit body never contains nested parentheses. release-please cannot parse them and silently
  drops the whole commit from the changelog, while the workflow still reports success.
- After merging a commit that should release, check that it appears in the release-please PR.

### Branches and pull requests

- Every change goes through a branch and a pull request. Never push to the default branch directly.
- A PR body says what the diff does, and nothing the diff does not do.
- Fix review findings in the PR under review, including small ones. File an issue only for a finding
  that belongs to other code, needs a design decision, is its own piece of work, or waits on
  something external.

### CI

- The .NET repos call the shared workflows of `MarcelRoozekrans/ci-baseline`, pinned to `@v1`, never
  `@main`.
- Its coverage gate fails the build when line coverage drops below the floor of 80%, and Codecov
  fails a PR that lowers project coverage by more than 1 percentage point. New code comes with
  tests.
- A repo with a lower floor documents the reason and links the issue that raises it.
<!-- org-core:end -->
