import ../hardware
import ./instmacros
template carry8(cpu: Cpu): uint8 = (if cpu.isCarry: 1 else: 0)
# template carry16(cpu: Cpu): uint16 = (if cpu.isCarry: 1 else: 0)
template carry32(cpu: Cpu): uint32 = (if cpu.isCarry: 1 else: 0)

inst addRm8R8, 0x00:
  cpu.eip += 1
  let rm = cpu.modRm()
  let r8 = cpu.getR8(rm.reg)
  let rm8 = cpu.getRm8(rm)
  let res = r8 + rm8
  cpu.setRm8(rm, res)
  cpu.updateFlagsAfterAdd(r8, rm8, res)

inst addRm32R32, 0x01:
  cpu.eip += 1
  let rm = cpu.modRm()
  let r32 = cpu.getRu32(rm)
  let rm32 = cpu.getRmu32(rm)
  let res = r32 + rm32
  cpu.setRm32(rm, res)
  cpu.updateFlagsAfterAdd(r32, rm32, res)

inst addR32Rm32, 0x03:
  cpu.eip += 1
  let rm = cpu.modRm()
  let r32 = cpu.getRu32(rm)
  let rm32 = cpu.getRmu32(rm)
  let res = r32 + rm32
  cpu.setR32(rm.reg, res)
  cpu.updateFlagsAfterAdd(r32, rm32, res)

inst addR8Rm8, 0x02:
  cpu.eip += 1
  let rm = cpu.modRm()
  let r8 = cpu.getR8(rm.reg)
  let rm8 = cpu.getRm8(rm)
  let res = r8 + rm8
  cpu.setR8(rm.reg, res)
  cpu.updateFlagsAfterAdd(r8, rm8, res)

inst addAlImm8, 0x04:
  let imm8 = cpu.getU8(1)
  let r8 = cpu.register.getAL
  let res = r8 + imm8
  cpu.register.setAL(res)
  cpu.updateFlagsAfterAdd(r8, imm8, res)
  cpu.eip += 2

inst addEaxImm32, 0x05:
  let imm32 = cpu.getU32(1)
  let eax = cpu.register.EAX
  let res = imm32 + eax
  cpu.register.EAX = res
  cpu.updateFlagsAfterAdd(eax, imm32, res)
  cpu.eip += 2

proc adcRm8R8*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  let r8 = cpu.getR8(rm.reg) + cpu.carry8
  let rm8 = cpu.getRm8(rm)
  let res = r8 + rm8
  cpu.setRm8(rm, res)
  cpu.updateFlagsAfterAdd(r8, rm8, res)

proc adcRm32R32*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  let r32 = cpu.getRu32(rm) + cpu.carry32
  let rm32 = cpu.getRmu32(rm)
  let res = r32 + rm32
  cpu.setRm32(rm, res)
  cpu.updateFlagsAfterAdd(r32, rm32, res)

proc adcR32Rm32*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  let r32 = cpu.getRu32(rm) + cpu.carry32
  let rm32 = cpu.getRmu32(rm)
  let res = r32 + rm32
  cpu.setR32(rm.reg, res)
  cpu.updateFlagsAfterAdd(r32, rm32, res)

proc adcR8Rm8*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  let r8 = cpu.getR8(rm.reg) + cpu.carry8
  let rm8 = cpu.getRm8(rm)
  let res = r8 + rm8
  cpu.setR8(rm.reg, res)
  cpu.updateFlagsAfterAdd(r8, rm8, res)

proc adcAlImm8*(cpu: Cpu) =
  let imm8 = cpu.getU8(1) + cpu.carry8
  let al = cpu.register.getAL
  let res = al + imm8
  cpu.register.setAL(res)
  cpu.updateFlagsAfterAdd(al, imm8, res)
  cpu.eip += 2

proc adcEaxImm32*(cpu: Cpu) =
  let imm32 = cpu.getU32(1) + cpu.carry32
  let eax = cpu.register.EAX
  let res = imm32 + eax
  cpu.register.EAX = res
  cpu.updateFlagsAfterAdd(eax, imm32, res)
  cpu.eip += 2

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
