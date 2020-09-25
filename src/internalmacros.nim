import macros, strutils

macro jumpIf*(name: untyped, cond: untyped): untyped =
  let ident = newIdentNode("cpu")
  result = quote do:
    proc `name`*(`ident`: Cpu) {.inject.} =
      if (`cond`):
        cpu.jmps()
      else:
        cpu.eip += 2

macro jumpIfNot*(name: untyped, cond: untyped): untyped =
  let ident = newIdentNode("cpu")
  result = quote do:
    proc `name`*(`ident`: Cpu) {.inject.} =
      if not (`cond`):
        cpu.jmps()
      else:
        cpu.eip += 2

macro registerOp16*(name: untyped): untyped =
  let getter = newIdentNode("get" & repr(name))
  let setter = newIdentNode("set" & repr(name))
  let regName = newIdentNode("E" & repr(name))

  result = quote do:
    template `getter`*(reg: Registers): uint16 = cast[array[2, uint16]](reg.`regName`)[0]

    template `setter`*(reg: Registers, val: uint16) =
      var arr = cast[array[2, uint16]](reg.`regName`)
      reg.`regName` = val + arr[1] shl 16

macro registerOp8*(name: untyped): untyped =
  let getterLow = newIdentNode("get" & repr(name) & "L")
  let setterLow = newIdentNode("set" & repr(name) & "L")
  let getterHigh = newIdentNode("get" & repr(name) & "H")
  let setterHigh = newIdentNode("set" & repr(name) & "H")
  let regName = newIdentNode("E" & repr(name) & "X")

  result = quote do:
    template `getterLow`*(reg: Registers): uint8 = cast[array[4, uint8]](reg.`regName`)[0]

    template `setterLow`*(reg: Registers, val: uint8) =
      var arr = cast[array[4, uint8]](reg.`regName`)
      arr[0] = val
      var regv = 0'u32
      for idx in 0'u32..3:
        regv = regv or (cast[uint32](arr[idx]) shl (8 * idx))
      reg.`regName` = regv

    template `getterHigh`*(reg: Registers): uint8 = cast[array[4, uint8]](reg.`regName`)[1]

    template `setterHigh`*(reg: Registers, val: uint8) =
      var arr = cast[array[4, uint8]](reg.`regName`)
      arr[1] = val
      var regv = 0'u32
      for idx in 0'u32..3:
        regv = regv or (cast[uint32](arr[idx]) shl (8 * idx))
      reg.`regName` = regv

macro flag*(name: untyped, flag: uint32): untyped =
  let setter = newIdentNode("set" & repr(name).capitalizeAscii())
  let getter = newIdentNode("is" & repr(name).capitalizeAscii())
  result = quote do:
    proc `setter`*(cpu: Cpu, `name`: bool) =
      if `name`:
        cpu.eflags = cpu.eflags or `flag`
      else:
        cpu.eflags = cpu.eflags and (not `flag`)

    proc `getter`*(cpu: Cpu): bool {.inline.} = (cpu.eflags and `flag`) != 0

var insts {.compileTime.}: seq[NimNode] = newSeq[NimNode]()

macro inst*(name: untyped, opcode: uint8, body: untyped): untyped =
  let cpu = newIdentNode("cpu")

  insts.add(
    quote do:
      `cpu`.insts[`opcode`] = `name`
  )

  result = quote do:
    proc `name`*(`cpu`: Cpu) =
      `body`

macro loadAllInsts*(ident: untyped): untyped =
  let cpu = newIdentNode("cpu")
  let instsStmt = newStmtList(insts)

  result = quote do:
    let `cpu` {.used.} = `ident`
    `instsStmt`
