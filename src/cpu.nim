import strutils
import ./bios
import ./hardware
import ./instructions

export hardware

proc newCpu*(bareMode: bool = false): Cpu =
  new result
  new result.register
  new result.sRegister
  new result.cRegister
  result.bareMode = bareMode

  loadAllInsts result

  result.initBios()

proc `$`(inst: Instruction): string =
  if inst.isNil:
    return "nil"
  return "inst"

proc dumpCpuStat*(cpu: Cpu) =
  var pr = "Registers:\n"
  pr &= "  EAX: " & $cpu.register.EAX & "\n"
  pr &= "  ECX: " & $cpu.register.ECX & "\n"
  pr &= "  EDX: " & $cpu.register.EDX & "\n"
  pr &= "  EBX: " & $cpu.register.EBX & "\n"
  pr &= "  ESP: " & $cpu.register.ESP & "\n"
  pr &= "  EBP: " & $cpu.register.EBP & "\n"
  pr &= "  ESI: " & $cpu.register.ESI & "\n"
  pr &= "  EDI: " & $cpu.register.EDI & "\n"
  pr &= "\nFlags:\n"
  pr &= "  Carry: " & $cpu.isCarry & "\n"
  pr &= "  Parity: " & $cpu.isParity & "\n"
  pr &= "  Adjust: " & $cpu.isAdjust & "\n"
  pr &= "  Zero: " & $cpu.isZero & "\n"
  pr &= "  Sign: " & $cpu.isSign & "\n"
  pr &= "  Trap: " & $cpu.isTrap & "\n"
  pr &= "  Interrupt: " & $cpu.isInterrupt & "\n"
  pr &= "  Direction: " & $cpu.isDirection & "\n"
  pr &= "  Overflow: " & $cpu.isOverflow & "\n"
  pr &= "\nInstruction Counter: " & $cpu.eip & "\n"
  pr &= "Instruction: " & cpu.memory[cpu.eip].toHex() & "\n"
  echo pr
  echo $cpu.insts

proc run*(cpu: Cpu, start: uint32, program: seq[uint8]) =
  cpu.dumpCpuStat()
  let ran = start..(start + cast[uint32](program.len) - 1)

  cpu.memory[ran] = program
  cpu.eip = start
  while cast[int](cpu.eip) < cpu.memory.len and cpu.eip != 0:
    let inst = cpu.memory[cpu.eip]
    cpu.insts[inst](cpu)
    #cpu.dumpCpuStat()
    #sleep(300)
