import ../bios
import ../hardware
import ./jmp
import ./instmacros

let interruptionTable = initInterruption()

inst callRelative32, 0xe8:
  cpu.push32(cpu.eip + 5)
  cpu.jmpn()

inst retn, 0xc3:
  cpu.eip = cpu.pop32()

inst leave, 0xc9:
  cpu.register.ESP = cpu.register.EBP
  cpu.register.EBP = cpu.pop32()
  cpu.eip += 1

inst inAlDx, 0xec:
  cpu.register.setAL(cpu.readIo8(cpu.register.getDX))
  cpu.eip += 1

inst outDxAl, 0xee:
  cpu.writeIo8(cpu.register.getDX, cpu.register.getAL)
  cpu.eip += 1

inst nop, 0x90:
  cpu.eip += 1

inst hlt, 0xf4:
  cpu.halted = true
  cpu.eip += 1

inst interrupt, 0xcd:
  let intr = cpu.getU8(1)
  if not cpu.bareMode:
    let interruption = interruptionTable[intr]
    if interruption.isNil:
      echo "unknown or unimplemented interruption: " & $intr
    else:
      interruption(cpu)
    cpu.eip += 2
    return

  let offset = intr*4
  let table = [
    cast[uint32](cpu.getM8(offset)), cast[uint32](cpu.getM8(offset + 1)),
    cast[uint32](cpu.getM8(offset + 2)), cast[uint32](cpu.getM8(offset + 3))
  ]
  let address = (table[2] shl 12) + (table[3] shl 4) + (table[0] shl 8) + (table[1])
  cpu.push32(cpu.eip + 2)
  cpu.eip = address

inst lock, 0xf0:
  # シングルプロセッサなのでlockプレフィクスはNOPとして動作する。
  cpu.eip += 1

inst lahf, 0x9f:
  cpu.register.setAH(cast[uint8](cpu.eflags and 0x0f))
  cpu.eip += 1

inst sahf, 0x9e:
  let ah = cpu.register.getAH
  cpu.eflags = (cpu.eflags and 0xffffff00'u32) or ah
  cpu.eip += 1

inst clc, 0xf8:
  cpu.setCarry(false)
  cpu.eip += 1

inst stc, 0xf9:
  cpu.setCarry(true)
  cpu.eip += 1

inst cli, 0xfa:
  cpu.setInterrupt(false)
  cpu.eip += 1

inst sti, 0xfb:
  cpu.setInterrupt(true)
  cpu.eip += 1

inst cld, 0xfc:
  cpu.setDirection(false)
  cpu.eip += 1

inst std, 0xfd:
  cpu.setDirection(true)
  cpu.eip += 1

prefixInst 0x0f
