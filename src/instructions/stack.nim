import ../hardware

proc pushR32*(cpu: Cpu) =
  let reg = cpu.getU8(0) - 0x50
  cpu.push32(cpu.getRu32(reg))
  cpu.eip += 1

proc popR32*(cpu: Cpu) =
  let reg = cpu.getU8(0) - 0x58
  cpu.setR32(reg, cpu.pop32())
  cpu.eip += 1

proc pushImm8*(cpu: Cpu) =
  cpu.push8(cpu.getU8(1))
  cpu.eip += 2

proc pushImm32*(cpu: Cpu) =
  cpu.push32(cpu.getU32(1))
  cpu.eip += 5
