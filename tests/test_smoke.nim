# ============================================================
# | NIST Eval Smoke Test                                    |
# | -> Ensures the suite runs and produces results          |
# ============================================================

import std/unittest

import sigma_bench_and_eval


suite "NIST Eval Smoke":
  test "suite runs on sample data":
    var
      bs: seq[uint8] = @[]
      i: int = 0
      p: NistParams
      rs: seq[NistResult] = @[]
    bs.setLen(2048)
    while i < bs.len:
      bs[i] = uint8(i mod 256)
      i = i + 1
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
    rs = nistSuiteFromBytes(bs, p)
    check rs.len > 0
