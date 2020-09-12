import os, sequtils
import ./cpu

when isMainModule:
  let params = commandLineParams()
  if params.len < 1:
    echo "No bootloader specified."
    quit(-1)

  let file = open(params[0], fmRead)
  let src = file.readAll()
  file.close()

  var bytes: seq[uint8] = cast[string](src).toSeq().map(proc(it: char): uint8 = cast[uint8](it))

  var core = newCpu()
  core.run(0x7c00, bytes)
