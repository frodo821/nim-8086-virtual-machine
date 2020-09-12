import ./hardware

proc initBios*(cpu: Cpu) =
  cpu.register.ESP = 0x7c04

proc int10h(cpu: Cpu) =
  case cpu.register.getAH
  of 0x00:
    discard
  of 0x01:
    discard
  of 0x02:
    discard
  of 0x0c:
    discard
  of 0x0e:
    stdout.write(cast[char](cpu.register.getAL))
  of 0x13:
    discard
  else:
    discard

proc initInterruption*(): array[0..255, Instruction] =
  result[0x10] = int10h
