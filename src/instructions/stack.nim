import ../hardware
import ./instmacros

instReg pushR32, 0x50, 8:
  let reg = cpu.getU8(0) - 0x50
  cpu.push32(cpu.getRu32(reg))
  cpu.eip += 1

instReg popR32, 0x58, 8:
  let reg = cpu.getU8(0) - 0x58
  cpu.setR32(reg, cpu.pop32())
  cpu.eip += 1

inst pushImm8, 0x6a:
  cpu.push8(cpu.getU8(1))
  cpu.eip += 2

inst pushImm32, 0x68:
  cpu.push32(cpu.getU32(1))
  cpu.eip += 5
