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
  result.insts[0x10] = adcRm8R8
  result.insts[0x11] = adcRm32R32
  result.insts[0x12] = adcR8Rm8
  result.insts[0x13] = adcR32Rm32
  result.insts[0x14] = adcAlImm8
  result.insts[0x15] = adcEaxImm32
  result.insts[0x0f] = op0fh
  result.insts[0x3b] = cmpR32Rm32
  result.insts[0x3c] = cmpAlImm8
  for idx in 0..8:
    result.insts[0x40 + idx] = incR32
  for idx in 0..8:
    result.insts[0x50 + idx] = pushR32
  for idx in 0..8:
    result.insts[0x58 + idx] = popR32
  result.insts[0x83] = op83h
  result.insts[0x89] = movRm32R32
  result.insts[0x8a] = movR8Rm8
  result.insts[0x8b] = movR32Rm32
  result.insts[0x8c] = movRm16Sr16
  result.insts[0x8e] = movSr16Rm16
  result.insts[0x90] = nop
  result.insts[0x9e] = sahf
  result.insts[0x9f] = lahf
  for idx in 0..8:
      result.insts[0xb0 + idx] = movR8Imm8
  for idx in 0..8:
      result.insts[0xb8 + idx] = movR32Imm32
  result.insts[0xc3] = retn
  result.insts[0xc7] = movRm32Imm32
  result.insts[0xc9] = leave
  result.insts[0xcd] = interrupt
  result.insts[0xe8] = callRelative32
  result.insts[0xec] = inAlDx
  result.insts[0xee] = outDxAl
  result.insts[0xf4] = hlt
  result.insts[0xf0] = lock
  result.insts[0xf8] = clc
  result.insts[0xf9] = stc
  result.insts[0xfa] = cli
  result.insts[0xfb] = sti
  result.insts[0xfc] = cld
  result.insts[0xfd] = std
  result.insts[0xff] = opFFh

  result.initBios()

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

proc run*(cpu: Cpu, start: uint32, program: seq[uint8]) =
  let ran = start..(start + cast[uint32](program.len) - 1)

  cpu.memory[ran] = program
  cpu.eip = start
  while cast[int](cpu.eip) < cpu.memory.len and cpu.eip != 0:
    let inst = cpu.memory[cpu.eip]
    cpu.insts[inst](cpu)
    #cpu.dumpCpuStat()
    #sleep(300)
