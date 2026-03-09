# ============================================================
# | Benchmark Compare Test                                  |
# | -> Compares algorithm runtimes over many loops          |
# ============================================================

import std/unittest

import sigma_bench_and_eval

suite "Benchmark compare":
  test "compare algorithms over several thousand loops":
    var data: seq[uint8] = @[]
    data.setLen(4096)
    for i in 0 ..< data.len:
      data[i] = uint8(i and 0xff)

    let bits = bitsFromBytes(data)
    let algos = [
      BenchAlgo(name: "monobit", run: proc() = discard monobitTest(bits)),
      BenchAlgo(name: "runs", run: proc() = discard runsTest(bits))
    ]

    const loops = 3000
    let results = compareAlgorithms(algos, loops = loops, warmup = 100)
    check results.len == algos.len
    for r in results:
      check r.loops == loops
      check r.totalTicks > 0
      check r.avgTicks >= 0
    echo formatBenchResults(results)
