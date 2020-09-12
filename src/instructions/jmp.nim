import ../internalmacros
import ../hardware

proc jmps*(cpu: Cpu) =
  let to = cpu.get8(1)

  if to < 0:
    cpu.eip -= cast[uint32](-to) - 2
  else:
    cpu.eip += cast[uint32](to) + 2

proc jmpn*(cpu: Cpu) =
  let to = cpu.get32(1)

  if to < 0:
    cpu.eip -= cast[uint32](-to) - 5'u32
  else:
    cpu.eip += cast[uint32](to) + 5'u32

jumpIf jc:
  cpu.isCarry

jumpIfNot jnc:
  cpu.isCarry

jumpIfNot jnp:
  cpu.isParity

jumpIf jp:
  cpu.isParity

jumpIf js:
  cpu.isSign

jumpIfNot jns:
  cpu.isSign

jumpIf jz:
  cpu.isZero

jumpIfNot jnz:
  cpu.isZero

jumpIf jo:
  cpu.isOverflow

jumpIfNot jno:
  cpu.isOverflow

jumpIf jl:
  cpu.isOverflow xor cpu.isSign

jumpIf jle:
  cpu.isZero or (cpu.isOverflow xor cpu.isSign)

jumpIf jg:
  cpu.isZero and not (cpu.isOverflow xor cpu.isSign)

jumpIfNot jge:
  cpu.isOverflow xor cpu.isSign

jumpIfNot ja:
  cpu.isZero or cpu.isCarry

jumpIf jna:
  cpu.isZero or cpu.isCarry

jumpIf jcxz:
  cpu.register.ECX == 0
