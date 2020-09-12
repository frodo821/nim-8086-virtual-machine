import ../hardware

proc addRm32R32*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  let r32 = cpu.getRu32(rm)
  let rm32 = cpu.getRmu32(rm)
  cpu.setRm32(rm, r32 + rm32)

proc subRm32Imm8(cpu: Cpu, rm: ModRm) =
  let rm32 = cpu.getRmu32(rm)
  let imm8 = cpu.getU8(0)
  let res = rm32 - imm8
  cpu.eip += 1
  cpu.setRm32(rm, res)
  cpu.updateFlagsAfterSubtract(rm32, imm8, res)

proc addRm32Imm8*(cpu: Cpu, rm: ModRm) =
  let rm32 = cpu.getRm32(rm)
  let imm8 = cpu.get8(0)
  cpu.eip += 1
  cpu.setRm32(rm, cast[uint32](rm32 + imm8))

proc cmpRm32Imm8*(cpu: Cpu, rm: ModRm) =
  let rm32 = cpu.getRm32(rm)
  let imm8 = cpu.get8(0)
  cpu.eip += 1
  cpu.updateFlagsAfterSubtract(cast[uint32](rm32), cast[uint32](imm8), cast[uint32](rm32 - imm8))

proc op83h*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  case rm.opcode
  of 0:
    cpu.addRm32Imm8(rm)
  of 5:
    cpu.subRm32Imm8(rm)
  of 7:
    cpu.cmpRm32Imm8(rm)
  else:
    raise newException(ValueError, "unknown operator")

proc incRm32*(cpu: Cpu, rm: ModRm) =
  cpu.setRm32(rm, cpu.getRmu32(rm) + 1)

proc incR32*(cpu: Cpu) =
  let reg = cpu.getU8(0) - 0x40
  cpu.setR32(reg, cpu.getRu32(reg) + 1)
  cpu.eip += 1

proc opFFh*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()

  if rm.opcode == 0:
    cpu.incRm32(rm)
  else:
    raise newException(ValueError, "unknown operator")

proc cmpR32Rm32*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  let r32 = cpu.getRu32(rm)
  let rm32 = cpu.getRmu32(rm)
  cpu.updateFlagsAfterSubtract(r32, rm32, r32 - rm32)

proc cmpAlImm8*(cpu: Cpu) =
  let val = cpu.getU8(1)
  let al = cpu.register.getAL
  cpu.updateFlagsAfterSubtract(al, val, al - val)
  cpu.eip += 2
