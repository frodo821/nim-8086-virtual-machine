import macros, tables, strutils

var insts {.compileTime.}: seq[NimNode] = newSeq[NimNode]()
var prefixes {.compileTime.}: Table[uint8, seq[NimNode]] = initTable[uint8, seq[NimNode]]()

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

macro jumpUnless*(name: untyped, opcode: uint8, cond: untyped): untyped =
  result = quote do:
    inst `name`, `opcode`:
      if not (`cond`):
        cpu.jmps()
      else:
        cpu.eip += 2

macro instWithPrefix*(name: untyped, prefix: uint8, opcode: uint8, body: untyped): untyped =
  let pf = cast[uint8](prefix.intVal)

  if pf notin prefixes:
    prefixes[pf] = @[]

  let cpu = newIdentNode("cpu")

  let caseof = quote do:
      case 0:
      of `opcode`:
        `body`

  prefixes[pf].add(caseof[1])

  result = quote do:
    proc `name`*(`cpu`: Cpu) =
      `body`

macro prefixInst*(opcode: uint8): untyped =
  let code: uint8 = cast[uint8](opcode.intVal)

  if code notin prefixes:
    return newEmptyNode()

  let insts = newNimNode(nnkCaseStmt)
  insts.add(nnkCall.newTree(nnkDotExpr.newTree(newIdentNode("cpu"), newIdentNode("getU8")), newLit(0)))
  insts.add(prefixes[code])
  
  insts.add(
    nnkElse.newTree(
      nnkStmtList.newTree(
        nnkRaiseStmt.newTree(
          nnkCall.newTree(
            newIdentNode("newException"),
            newIdentNode("ValueError"),
            newLit("unknown operator")
          )
        )
      )
    )
  )

  let sym = newIdentNode("i"&opcode.intVal.toHex&"H")

  result = quote do:
    inst `sym`, `opcode`:
      cpu.eip += 1
      `insts`

macro loadAllInsts*(ident: untyped): untyped =
  let cpu = newIdentNode("cpu")
  let instsStmt = newStmtList(insts)

  result = quote do:
    let `cpu` {.used.} = `ident`
    `instsStmt`
