import ../bios
import ../hardware
import ./jmp

let interruptionTable = initInterruption()

proc callRelative32*(cpu: Cpu) =
  cpu.push32(cpu.eip + 5)
  cpu.jmpn()

proc retn*(cpu: Cpu) =
  cpu.eip = cpu.pop32()

proc leave*(cpu: Cpu) =
  cpu.register.ESP = cpu.register.EBP
  cpu.register.EBP = cpu.pop32()
  cpu.eip += 1

proc inAlDx*(cpu: Cpu) =
  cpu.register.setAL(cpu.readIo8(cpu.register.getDX))
  cpu.eip += 1

proc outDxAl*(cpu: Cpu) =
  cpu.writeIo8(cpu.register.getDX, cpu.register.getAL)
  cpu.eip += 1

proc nop*(cpu: Cpu) =
  cpu.eip += 1

proc hlt*(cpu: Cpu) =
  cpu.eip += 1

proc interrupt*(cpu: Cpu) =
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

proc lock*(cpu: Cpu) =
  # シングルプロセッサなのでlockプレフィクスはNOPとして動作する。
  cpu.eip += 1

proc lahf*(cpu: Cpu) =
  cpu.register.setAH(cast[uint8](cpu.eflags and 0x0f))
  cpu.eip += 1

proc sahf*(cpu: Cpu) =
  let ah = cpu.register.getAH
  cpu.eflags = (cpu.eflags and 0xffffff00'u32) or ah
  cpu.eip += 1

proc clc*(cpu: Cpu) =
  cpu.setCarry(false)
  cpu.eip += 1

proc stc*(cpu: Cpu) =
  cpu.setCarry(true)
  cpu.eip += 1

proc cli*(cpu: Cpu) =
  cpu.setInterrupt(false)
  cpu.eip += 1

proc sti*(cpu: Cpu) =
  cpu.setInterrupt(true)
  cpu.eip += 1

proc cld*(cpu: Cpu) =
  cpu.setDirection(false)
  cpu.eip += 1

proc std*(cpu: Cpu) =
  cpu.setDirection(true)
  cpu.eip += 1