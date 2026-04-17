# Sigma-BenchAndEval

NIST-style statistical test suite for binary sequences in Nim.

## Purpose
- Own the in-memory statistical evaluation logic for binary sequences.
- Expose both individual test procs and a suite-level orchestrator for callers that want the full pass.
- Provide lightweight benchmark comparison helpers for local algorithm checks.

## What This Repo Does Not Own
- Random-data generation, file loading, protocol parsing, or persistence.
- Any service loops, background workers, network surfaces, or UI code.
- Application-specific benchmark harnesses that belong in consuming repos.

## Repo Layout
- `src/sigma_bench_and_eval.nim`
  - public re-export surface for the library.
- `src/protocols/types.nim`
  - shared parameter and result types.
- `src/protocols/suite.nim`
  - main suite orchestrator.
- `src/protocols/*.nim`
  - individual statistical tests and shared math/bit helpers.
- `tests/`
  - smoke and benchmark-comparison coverage.
- `iron/`
  - local repo coordination notes and copied workspace conventions.

## Main State Types
- `NistParams`
  - bundle of tunable parameters for the suite runner.
- `NistResult`
  - normalized result object for each test.
- `BenchAlgo`
  - named callback for benchmark comparisons.
- `BenchResult`
  - timing summary for one benchmarked algorithm.

## Important Orchestrators
- `nistSuiteFromBytes`
  - converts bytes to bits and runs the full suite in a fixed order.
- `compareAlgorithms`
  - performs warmup plus repeated timing loops for supplied callbacks.
- `formatBenchResults`
  - turns benchmark output into a readable summary string.

## Normal Flow
1. A caller prepares a byte buffer and a `NistParams` value.
2. `nistSuiteFromBytes` expands that byte buffer into a bit stream with `bitsFromBytes`.
3. The suite runs the individual tests in sequence and appends each `NistResult`.
4. The caller interprets pass/fail status or formats the results for a higher-level tool.

This repo has no resident scheduler loop. All loops are local computation loops inside the test implementations and benchmark helpers.

## Usage
```nim
import sigma_bench_and_eval

var
  data: seq[uint8] = newSeq[uint8](2048)
  p: NistParams

p.blockSize = 128
p.patternSize = 4
p.longRunBlock = 8
p.alpha = defaultAlpha
p.rankRows = 32
p.rankCols = 32
p.spectralMaxBits = 1 shl 12
p.templateSize = 9
p.templateBlockSize = 1032
p.templateCount = 8
p.overlapTemplateSize = 9
p.overlapTemplateBlock = 1032
p.linearComplexityBlock = 500
p.universalBlockSize = 7
p.universalInitBlocks = 0

let results = nistSuiteFromBytes(data, p)
```

For benchmark helpers:

```nim
import sigma_bench_and_eval

let bits = bitsFromBytes(@[0'u8, 255'u8, 170'u8, 85'u8])
let algos = [
  BenchAlgo(name: "monobit", run: proc() = discard monobitTest(bits)),
  BenchAlgo(name: "runs", run: proc() = discard runsTest(bits))
]

echo formatBenchResults(compareAlgorithms(algos, loops = 1000, warmup = 50))
```

## Development
- `nimble test`
  - run smoke coverage for the public suite API.
- `nimble test_bench`
  - run the benchmark comparison test.
- `nimble build`
  - compile the smoke test in release mode.
- `nimble find`
  - point submodule URLs at local sibling clones when available.

## License
Released under [The Unlicense](LICENSE.txt).

## Development Conventions (Short)
- Keep modules pure and in-memory unless there is a strong repo-level reason to add an external boundary.
- Preserve the current split between shared helpers, individual tests, and suite orchestration.
- Keep proc bodies flat where possible and move repeated logic into shared helpers instead of duplicating it.
- Update `iron/progress.md` and this README when public behavior or repo boundaries change.
- Follow the full workspace rules in `iron/conventions.md`.

## Issue Playbook
- Several tests require enough input bits or specific block sizes; invalid or too-short inputs can legitimately return zero-style results instead of useful statistical output.
- The benchmark helpers depend on the checked-out `submodules/fylgia` path being present; initialize the submodule before running benchmark-related tasks.
- Benchmark timings are machine-dependent. Treat them as relative comparisons inside one environment, not portable absolute numbers.
