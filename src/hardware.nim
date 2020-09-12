import ./internalmacros

const max8 {.used.} = 255'u8
const max16 {.used.} = 65535'u16
const max32 {.used.} = 4294967295'u32

type
  Instruction* = proc(cpu: Cpu)

  Cpu* = ref object
    insts*: array[256, Instruction]
    register*: Registers
    sRegister*: SegmentRegisters
    cRegister*: ControlRegisters
    memory*: array[1073741824, uint8]
    eflags*: uint32
    eip*: uint32
    bareMode*: bool

  Registers* = ref object
    EAX*, ECX*, EDX*, EBX*, ESP*, EBP*, ESI*, EDI*: uint32

  SegmentRegisters* = ref object
    CS*, DS*, SS* ,ES*, FS*, GS*: uint16

  ControlRegisters* = ref object
    CR0*, CR2*, CR3*, CR4: uint32

  ModRm* = ref object
    `mod`*: uint8
    opcode*: uint8
    reg*: uint8
    rm*: uint8
    sib*: int8
    disp8*: int8
    disp32*: int32

  CpuFlagsInternalType* = distinct int8

registerOp16(AX)
registerOp16(CX)
registerOp16(DX)
registerOp16(BX)
registerOp16(SP)
registerOp16(BP)
registerOp16(SI)
registerOp16(DI)
registerOp8(A)
registerOp8(C)
registerOp8(D)
registerOp8(B)

const CpuFlags* = CpuFlagsInternalType(0)

proc CarryFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32
proc ParityFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 2
proc AdjustFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 4
proc ZeroFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 6
proc SignFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 7
proc TrapFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 8
proc InterruptFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 9
proc DirectionFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 10
proc OverflowFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 11
proc IOPL*(flags: CpuFlagsInternalType): uint32 {.inline.} = (1'u32 shl 12) or (1'u32 shl 13)
proc NestTaskFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 14
proc ResumeFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 16
proc VirtualMode*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 17
proc AlignmentCheck*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 18
proc VirtualInterruptFlag*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 19
proc VirtualInterruptPending*(flags: CpuFlagsInternalType): uint32 {.inline.} = 1'u32 shl 20

flag carry:
  CpuFlags.CarryFlag

flag parity:
  CpuFlags.ParityFlag

flag adjust:
  CpuFlags.AdjustFlag

flag zero:
  CpuFlags.ZeroFlag

flag sign:
  CpuFlags.SignFlag

flag trap:
  CpuFlags.TrapFlag

flag interrupt:
  CpuFlags.InterruptFlag

flag direction:
  CpuFlags.DirectionFlag

flag overflow:
  CpuFlags.OverflowFlag

proc getU8*(cpu: Cpu, offset: uint32): uint8 = cpu.memory[cpu.eip + offset]
proc get8*(cpu: Cpu, offset: uint32): int8 = cast[int8](cpu.memory[cpu.eip + offset])
proc getU32*(cpu: Cpu, offset: uint32): uint32 =
  let start = cpu.eip + offset
  result = 0
  for idx in 0'u32..3:
    result = result or (cast[uint32](cpu.memory[start + idx]) shl (8 * idx))

proc get32*(cpu: Cpu, offset: uint32): int32 =
  let start = cpu.eip + offset
  result = 0
  for idx in 0'u32..3:
    result = result or (cast[int32](cpu.memory[start + idx]) shl (8 * idx))

proc getRu32*(cpu: Cpu, index: uint8): uint32 =
  result = case index
    of 0: cpu.register.EAX
    of 1: cpu.register.ECX
    of 2: cpu.register.EDX
    of 3: cpu.register.EBX
    of 4: cpu.register.ESP
    of 5: cpu.register.EBP
    of 6: cpu.register.ESI
    of 7: cpu.register.EDI
    else:
      raise newException(ValueError, "unknown register id")

proc getSr*(cpu: Cpu, index: uint8): uint16 =
  result = case index
    of 0: cpu.sRegister.ES
    of 1: cpu.sRegister.CS
    of 2: cpu.sRegister.SS
    of 3: cpu.sRegister.DS
    of 4: cpu.sRegister.FS
    of 5: cpu.sRegister.GS
    else:
      raise newException(ValueError, "unknown register id")

proc setSr*(cpu: Cpu, index: uint8, val: uint16) =
  case index
    of 0: cpu.sRegister.ES = val
    of 1: cpu.sRegister.CS = val
    of 2: cpu.sRegister.SS = val
    of 3: cpu.sRegister.DS = val
    of 4: cpu.sRegister.FS = val
    of 5: cpu.sRegister.GS = val
    else:
      raise newException(ValueError, "unknown register id")

proc getCr*(cpu: Cpu, index: uint8): uint32 =
  result = case index
    of 0: cpu.cRegister.CR0
    # of 1: cpu.cRegister.CR1 unused
    of 2: cpu.cRegister.CR2
    of 3: cpu.cRegister.CR3
    of 4: cpu.cRegister.CR4
    else:
      raise newException(ValueError, "unknown register id")

proc setCr*(cpu: Cpu, index: uint8, val: uint32) =
  case index
    of 0: cpu.cRegister.CR0 = val
    # of 1: cpu.cRegister.CR1 unused
    of 2: cpu.cRegister.CR2 = val
    of 3: cpu.cRegister.CR3 = val
    of 4: cpu.cRegister.CR4 = val
    else:
      raise newException(ValueError, "unknown register id")

proc getR32*(cpu: Cpu, index: uint8): int32 {.inline.} =
  cast[int32](cpu.getRu32(index))

proc setR32*(cpu: Cpu, index: uint8, val: uint32) =
  case index
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
    else:
      raise newException(ValueError, "unknown register id")

proc getR16*(cpu: Cpu, index: uint8): uint16 =
  result = case index
    of 0: cpu.register.getAX
    of 1: cpu.register.getCX
    of 2: cpu.register.getDX
    of 3: cpu.register.getBX
    of 4: cpu.register.getSP
    of 5: cpu.register.getBP
    of 6: cpu.register.getSI
    of 7: cpu.register.getDI
    else:
      raise newException(ValueError, "unknown register id")

proc setR16*(cpu: Cpu, index: uint8, val: uint16) =
  case index
    of 0: cpu.register.setAX(val)
    of 1: cpu.register.setCX(val)
    of 2: cpu.register.setDX(val)
    of 3: cpu.register.setBX(val)
    of 4: cpu.register.setSP(val)
    of 5: cpu.register.setBP(val)
    of 6: cpu.register.setSI(val)
    of 7: cpu.register.setDI(val)
    else:
      raise newException(ValueError, "unknown register id")

proc getR8*(cpu: Cpu, index: uint8): uint8 =
  result = case index
    of 0: cpu.register.getAL
    of 1: cpu.register.getCL
    of 2: cpu.register.getDL
    of 3: cpu.register.getBL
    of 4: cpu.register.getAH
    of 5: cpu.register.getCH
    of 6: cpu.register.getDH
    of 7: cpu.register.getBH
    else:
      raise newException(ValueError, "unknown register id")

proc setR8*(cpu: Cpu, index: uint8, val: uint8) =
  case index
    of 0: cpu.register.setAL(val)
    of 1: cpu.register.setCL(val)
    of 2: cpu.register.setDL(val)
    of 3: cpu.register.setBL(val)
    of 4: cpu.register.setAH(val)
    of 5: cpu.register.setCH(val)
    of 6: cpu.register.setDH(val)
    of 7: cpu.register.setBH(val)
    else:
      raise newException(ValueError, "unknown register id")

proc modRm*(cpu: Cpu): ModRm =
  new result
  let code = cpu.getU8(0)
  result.mod = (code and 0xc0'u8) shr 6
  result.reg = (code and 0x38'u8) shr 3
  result.opcode = result.reg
  result.rm = code and 0x07'u8

  cpu.eip += 1

  if (result.mod != 3 and result.rm == 4):
    result.sib = cpu.get8(0)
    cpu.eip += 1
  if (result.mod == 0 and result.rm == 5) or result.mod == 2:
    result.disp32 = cpu.get32(0)
    result.disp8 = cast[int8](result.disp32 and 0xff)
    cpu.eip += 4
  elif result.mod == 1:
    result.disp8 = cpu.get8(0)
    result.disp32 = result.disp8
    cpu.eip += 1

proc memoryAddress*(cpu: Cpu, rm: ModRm): uint32 =
  if rm.rm == 4:
    raise newException(ValueError, "unknown ModR/M flag byte")
  case rm.mod
  of 0:
    if rm.rm == 5:
      return cast[uint32](rm.disp32)
    else:
      return cpu.getRu32(rm.rm)
  of 1:
    return cast[uint32](cpu.getR32(rm.rm) + rm.disp8)
  of 2:
    return cast[uint32](cpu.getR32(rm.rm) + rm.disp32)
  else:
    raise newException(ValueError, "unknown ModR/M flag byte")

proc setM8*(cpu: Cpu, address: uint32, val: uint8) =
  cpu.memory[address] = val

proc setM16*(cpu: Cpu, address: uint32, val: uint16) =
  let split = cast[array[2, uint8]](val)
  cpu.setM8(address, split[0])
  cpu.setM8(address + 1, split[1])

proc setM32*(cpu: Cpu, address: uint32, val: uint32) =
  let split = cast[array[4, uint8]](val)
  for index in 0'u32..3'u32:
    cpu.setM8(address+index, split[index])

proc getMu8*(cpu: Cpu, address: uint32): uint8 =
  cpu.memory[address]

proc getMu16*(cpu: Cpu, address: uint32): uint16 =
  cast[uint16](cpu.memory[address]) or (cast[uint16](cpu.memory[address + 1]) shl 8)

proc getMu32*(cpu: Cpu, address: uint32): uint32 =
  result = 0
  for idx in 0'u32..3:
    result = result or (cast[uint32](cpu.memory[address + idx]) shl (8 * idx))

proc getM8*(cpu: Cpu, address: uint32): int8 =
  cast[int8](cpu.memory[address])

proc getM16*(cpu: Cpu, address: uint32): int16 =
  cast[int16](cpu.memory[address]) or (cast[int16](cpu.memory[address + 1]) shl 8)

proc getM32*(cpu: Cpu, address: uint32): int32 =
  result = 0
  for idx in 0'u32..3:
    result = result or (cast[int32](cpu.memory[address + idx]) shl (8 * idx))

proc getRu32*(cpu: Cpu, rm: ModRm): uint32 =
  cpu.getRu32(rm.reg)

proc getR32*(cpu: Cpu, rm: ModRm): int32 =
  cpu.getR32(rm.reg)

proc getRm32*(cpu: Cpu, rm: ModRm): int32 =
  if rm.mod == 3:
    return cpu.getR32(rm.rm)
  return cpu.getM32(cpu.memoryAddress(rm))

proc getRmu32*(cpu: Cpu, rm: ModRm): uint32 =
  if rm.mod == 3:
    return cpu.getRu32(rm.rm)
  return cpu.getMu32(cpu.memoryAddress(rm))

proc setRm32*(cpu: Cpu, rm: ModRm, val: uint32) =
  if rm.mod == 3:
    cpu.setR32(rm.rm, val)
  else:
    let address = cpu.memoryAddress(rm)
    cpu.setM32(address, val)

proc setR32*(cpu: Cpu, rm: ModRm, val: uint32) =
  cpu.setR32(rm.reg, val)

proc setR8*(cpu: Cpu, rm: ModRm, val: uint8) =
  cpu.setR8(rm.reg, val)

proc getRm16*(cpu: Cpu, rm: ModRm): uint16 =
  if rm.mod == 3:
    return cpu.getR16(rm.rm)
  return cpu.getMu16(cpu.memoryAddress(rm))

proc setRm16*(cpu: Cpu, rm: ModRm, val: uint16) =
  if rm.mod == 3:
    cpu.setR16(rm.rm, val)
  else:
    let address = cpu.memoryAddress(rm)
    cpu.setM16(address, val)

proc getRm8*(cpu: Cpu, rm: ModRm): uint8 =
  if rm.mod == 3:
    return cpu.getR8(rm.rm)
  return cpu.getMu8(cpu.memoryAddress(rm))

proc setRm8*(cpu: Cpu, rm: ModRm, val: uint8) =
  if rm.mod == 3:
    cpu.setR8(rm.rm, val)
  else:
    cpu.setM8(cpu.memoryAddress(rm), val)

proc updateFlagsAfterAdd*(cpu: Cpu, op1, op2: uint8, res: uint8) =
  let sign1 = op1 shr 7
  let sign2 = op2 shr 7
  let signR = res shr 7
  cpu.setCarry(op1 > max8 - op2)
  cpu.setZero(res == 0)
  cpu.setSign(signR == 1)
  cpu.setParity((res and 1) == 0)
  cpu.setOverflow(sign1 != sign2 and sign1 != signR)

proc updateFlagsAfterAdd*(cpu: Cpu, op1, op2: uint32, res: uint32) =
  let sign1 = op1 shr 31
  let sign2 = op2 shr 31
  let signR = res shr 31
  cpu.setCarry(op1 > max32 - op2)
  cpu.setZero(res == 0)
  cpu.setSign(signR == 1)
  cpu.setParity((res and 1) == 0)
  cpu.setOverflow(sign1 != sign2 and sign1 != signR)

proc updateFlagsAfterSubtract*(cpu: Cpu, op1, op2: uint32, res: uint32) =
  let sign1 = op1 shr 31
  let sign2 = op2 shr 31
  let signR = res shr 31
  cpu.setCarry(op1 < op2)
  cpu.setZero(res == 0)
  cpu.setSign(signR == 1)
  cpu.setParity((res and 1) == 0)
  cpu.setOverflow(sign1 != sign2 and sign1 != signR)

proc push32*(cpu: Cpu, val: uint32) =
  let esp = cpu.register.ESP - 4
  cpu.register.ESP = esp
  cpu.setM32(esp, val)

proc pop32*(cpu: Cpu): uint32 =
  let esp = cpu.register.ESP
  result = cpu.getMu32(esp)
  cpu.register.ESP = esp + 4

proc readIo8*(cpu: Cpu, port: uint16): uint8 =
  if port == 0x03f8:
    return cast[uint8](stdin.readChar())
  return 0

proc writeIo8*(cpu: Cpu, port: uint16, val: uint8) =
  if port == 0x03f8:
    stdout.write(cast[char](val))
    stdout.flushFile()
