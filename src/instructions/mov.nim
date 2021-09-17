import ../hardware
import ./instmacros

variationInsts movR32Imm32, 0xb0, 8:
  let reg = cpu.getU8(0) - 0xb8
  let val = cpu.getU32(1)

  case reg
  of 0:
    cpu.register.EAX = val
  of 1:
    cpu.register.ECX = val
  of 2:
    cpu.register.EDX = val
  of 3:
    cpu.register.EBX = val
  of 4:
    cpu.register.ESP = val
  of 5:
    cpu.register.EBP = val
  of 6:
    cpu.register.ESI = val
  of 7:
    cpu.register.EDI = val
  else: discard
  cpu.eip += 5

inst movRm32Imm32, 0xc7:
  cpu.eip += 1
  let rm = cpu.modRm()
  let val = cpu.getU32(0)
  cpu.eip += 4
  cpu.setRm32(rm, val)

inst movRm32R32, 0x89:
  cpu.eip += 1
  let rm = cpu.modRm()
  cpu.setRm32(rm, cpu.getRu32(rm))

inst movR32Rm32, 0x8b:
  cpu.eip += 1
  let rm = cpu.modRm()
  let rm32 = cpu.getRmu32(rm)
  cpu.setR32(rm, rm32)

variationInsts movR8Imm8, 0xb8, 8:
  cpu.setR8(cpu.getU8(0) - 0xB0, cpu.getU8(1))
  cpu.eip += 2

inst movR8Rm8, 0x8a:
  cpu.eip += 1
  let rm = cpu.modRm()
  let rm8 = cpu.getRm8(rm)
  cpu.setR8(rm, rm8)

inst movSr16Rm16, 0x8e:
  cpu.eip += 1
  let rm = cpu.modRm()
  cpu.setSr(rm.reg, cpu.getRm16(rm))

inst movRm16Sr16, 0x8c:
  cpu.eip += 1
  let rm = cpu.modRm()
  cpu.setRm16(rm, cpu.getSr(rm.reg))

proc movCr32Rm32*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  cpu.setCr(rm.reg, cpu.getRmu32(rm))

proc movRm32Cr32*(cpu: Cpu) =
  cpu.eip += 1
  let rm = cpu.modRm()
  cpu.setRm32(rm, cpu.getCr(rm.reg))

inst op0fh, 0x0f:
  cpu.eip += 1
  case cpu.getU8(0)
  of 0x22:
    cpu.movCr32Rm32()
  of 0x20:
    cpu.movRm32Cr32()
  else:
    raise newException(ValueError, "unknown operator")
