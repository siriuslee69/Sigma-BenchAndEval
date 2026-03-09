import std/[os, strutils]

version       = "0.1.0"
author        = "siriuslee69"
description   = "NIST-style statistical test suite for binary sequences."
license       = "Unlicense"
srcDir        = "src"
requires "nim >= 1.6.0"

task test, "Run smoke tests":
  exec "nim c --path:src --path:submodules/fylgia/src -r tests/test_smoke.nim"

task build, "Build smoke test in release mode":
  exec "nim c --path:src --path:submodules/fylgia/src -d:release tests/test_smoke.nim"

task test_bench, "Run benchmark compare test":
  exec "nim c --path:src --path:submodules/fylgia/src -d:release -r tests/test_bench_compare.nim"

task autopush, "Add, commit, and push with message from iron/progress.md":
  let path = "iron/progress.md"
  var msg = ""
  if fileExists(path):
    let content = readFile(path)
    for line in content.splitLines:
      if line.startsWith("Commit Message:"):
        msg = line["Commit Message:".len .. ^1].strip()
        break
  if msg.len == 0:
    msg = "No specific commit message given."
  exec "git add -A ."
  exec "git commit -m \" " & msg & "\""
  exec "git push"

task find, "Use local clones for submodules in parent folder":
  let modulesPath = ".gitmodules"
  if not fileExists(modulesPath):
    echo "No .gitmodules found."
  else:
    let root = parentDir(getCurrentDir())
    var current = ""
    for line in readFile(modulesPath).splitLines:
      let s = line.strip()
      if s.startsWith("[submodule"):
        let start = s.find('"')
        let stop = s.rfind('"')
        if start >= 0 and stop > start:
          current = s[start + 1 .. stop - 1]
      elif current.len > 0 and s.startsWith("path"):
        let parts = s.split("=", maxsplit = 1)
        if parts.len == 2:
          let subPath = parts[1].strip()
          let tail = splitPath(subPath).tail
          let localDir = joinPath(root, tail)
          if dirExists(localDir):
            let localUrl = localDir.replace('\\', '/')
            exec "git config -f .gitmodules submodule." & current & ".url " & localUrl
            exec "git config submodule." & current & ".url " & localUrl
    exec "git submodule sync --recursive"
