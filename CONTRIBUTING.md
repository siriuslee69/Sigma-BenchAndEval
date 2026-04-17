# Contributing to Sigma-BenchAndEval

## Purpose
This repo is the reusable statistical-evaluation library for binary-sequence analysis. Changes here should improve the correctness, clarity, or maintainability of the library itself, not add app-specific workflow code.

## What belongs here
- Pure in-memory implementations of the statistical tests.
- Shared math, bit, and result helpers used by those tests.
- Suite orchestration and benchmark-comparison helpers.
- Tests and documentation for the public library surface.

## What does not belong here
- Network, storage, UI, or long-running service logic.
- Repo-external orchestration for loading data or dispatching jobs.
- Workspace-wide convention changes that belong in `Proto-RepoTemplate`.

## Files To Read First
- `src/sigma_bench_and_eval.nim`
  - public export surface.
- `src/protocols/suite.nim`
  - main suite orchestrator.
- `src/protocols/types.nim`
  - shared result and parameter types.
- `src/protocols/benchmarks.nim`
  - benchmark helpers and formatting.
- `tests/test_smoke.nim`
  - baseline suite usage example.
- `tests/test_bench_compare.nim`
  - benchmark helper usage example.

## Functions To Understand Before Changing Behavior
- `bitsFromBytes`
  - shared conversion boundary used by the suite.
- `makeResult`
  - normalizes pass/fail behavior across tests.
- `nistSuiteFromBytes`
  - orchestrates ordering and aggregation of the full suite.
- Any individual test proc you are modifying
  - the repo expects each test to remain independently callable.
- `compareAlgorithms`
  - drives repeated benchmark loops and timing summaries.

## Change Checklist
- Keep module headers and top-level descriptions in place.
- Preserve the pure-library boundary unless there is an explicit repo-level reason to expand it.
- Reuse existing helpers before adding new duplicate math or bit logic.
- Update `README.md` if public behavior, module boundaries, or usage examples change.
- Update `iron/progress.md` after meaningful repo changes.
- Run `nimble test` after code changes.
- Run `nimble test_bench` if benchmark helpers or timing-related code changed.

## Review Checklist
- Does the change belong in this library instead of a consuming repo?
- Does it preserve or intentionally update the public API surface in `src/sigma_bench_and_eval.nim`?
- Are short-input and invalid-parameter cases still handled explicitly?
- If a statistical formula changed, is the reasoning documented well enough to review?
- Did the relevant tests run, and is new coverage needed?

## Commands
- `nimble test`
- `nimble test_bench`
- `nimble build`
- `nimble find`
