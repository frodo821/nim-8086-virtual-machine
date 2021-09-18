import ../hardware
import ./instmacros

inst jmps, 0xeb:
  let to = cpu.get8(1)

  if to < 0:
    cpu.eip -= cast[uint32](-to) - 2
  else:
    cpu.eip += cast[uint32](to) + 2

inst jmpn, 0xe9:
  let to = cpu.get32(1)

  if to < 0:
    cpu.eip -= cast[uint32](-to) - 5'u32
  else:
    cpu.eip += cast[uint32](to) + 5'u32

jumpIf jo, 0x70:
  cpu.isOverflow

jumpUnless jno, 0x71:
  cpu.isOverflow

jumpIf jc, 0x72:
  cpu.isCarry

jumpUnless jnc, 0x73:
  cpu.isCarry

jumpIf jz, 0x74:
  cpu.isZero

jumpUnless jnz, 0x75:
  cpu.isZero

jumpIf jna, 0x76:
  cpu.isZero or cpu.isCarry

jumpUnless ja, 0x77:
  cpu.isZero or cpu.isCarry

jumpIf js, 0x78:
  cpu.isSign

jumpUnless jns, 0x79:
  cpu.isSign

jumpIf jp, 0x7a:
  cpu.isParity

jumpUnless jnp, 0x7b:
  cpu.isParity

jumpIf jl, 0x7c:
  cpu.isOverflow xor cpu.isSign

jumpIf jnl, 0x7d:
  cpu.isOverflow and cpu.isSign

jumpIf jle, 0x7e:
  cpu.isZero or (cpu.isOverflow xor cpu.isSign)

jumpIf jg, 0x7f:
  cpu.isZero and not (cpu.isOverflow xor cpu.isSign)

jumpIf jcxz, 0xe3:
  cpu.register.ECX == 0
