import macros

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

macro instReg*(name: untyped, base: uint8, count: uint8, body: untyped): untyped =
  let cpu = newIdentNode("cpu")

  for opcode in base.intVal..(base.intVal + count.intVal - 1):
    insts.add(
      quote do:
        `cpu`.insts[`opcode`] = `name`
    )

  result = quote do:
    proc `name`*(`cpu`: Cpu) =
      `body`

macro jumpIf*(name: untyped, opcode: uint8, cond: untyped): untyped =
  result = quote do:
    inst `name`, `opcode`:
      if (`cond`):
        cpu.jmps()
      else:
        cpu.eip += 2

macro jumpIfNot*(name: untyped, opcode: uint8, cond: untyped): untyped =
  result = quote do:
    inst `name`, `opcode`:
      if not (`cond`):
        cpu.jmps()
      else:
        cpu.eip += 2

macro loadAllInsts*(ident: untyped): untyped =
  let cpu = newIdentNode("cpu")
  let instsStmt = newStmtList(insts)

  result = quote do:
    let `cpu` {.used.} = `ident`
    `instsStmt`
