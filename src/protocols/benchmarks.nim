# ============================================================
# | Benchmark Helpers                                        |
# | -> Compare algorithm runtimes over repeated loops        |
# ============================================================

import std/strutils

import protocols/time/sleep

type
  BenchAlgo* = object
    name*: string
    run*: proc() {.closure.}

  BenchResult* = object
    name*: string
    loops*: int
    totalTicks*: int64
    avgTicks*: int64


proc compareAlgorithms*(algos: openArray[BenchAlgo], loops: int = 10000,
    warmup: int = 100): seq[BenchResult] =
  ## Compare algorithms by running each one `loops` times.
  ## Uses a small warmup to reduce first-run effects.
  var results: seq[BenchResult] = @[]
  if loops <= 0:
    return results
  for algo in algos:
    var w = 0
    while w < warmup:
      algo.run()
      inc w
    let total = takeTime:
      var i = 0
      while i < loops:
        algo.run()
        inc i
    results.add(BenchResult(
      name: algo.name,
      loops: loops,
      totalTicks: total,
      avgTicks: total div loops
    ))
  result = results


proc formatBenchResults*(results: openArray[BenchResult]): string =
  ## Format benchmark results for printing.
  var lines: seq[string] = @[]
  for r in results:
    lines.add(r.name & " total=" & $r.totalTicks & " avg=" & $r.avgTicks &
      " loops=" & $r.loops)
  result = lines.join("\n")
