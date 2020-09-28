import ../internalmacros
import ../hardware

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

jumpInst jo, 0x70:
  cpu.isOverflow

jumpNotInst jno, 0x71:
  cpu.isOverflow

jumpInst jc, 0x72:
  cpu.isCarry

jumpNotInst jnc, 0x73:
  cpu.isCarry

jumpInst jz, 0x74:
  cpu.isZero

jumpNotInst jnz, 0x75:
  cpu.isZero

jumpInst jna, 0x76:
  cpu.isZero or cpu.isCarry

jumpNotInst ja, 0x77:
  cpu.isZero or cpu.isCarry

jumpInst js, 0x78:
  cpu.isSign

jumpNotInst jns, 0x79:
  cpu.isSign

jumpInst jp, 0x7a:
  cpu.isParity

jumpNotInst jnp, 0x7b:
  cpu.isParity

jumpInst jl, 0x7c:
  cpu.isOverflow xor cpu.isSign

jumpInst jnl, 0x7d:
  cpu.isOverflow and cpu.isSign

jumpInst jle, 0x7e:
  cpu.isZero or (cpu.isOverflow xor cpu.isSign)

jumpInst jg, 0x7f:
  cpu.isZero and not (cpu.isOverflow xor cpu.isSign)

jumpInst jcxz, 0xe3:
  cpu.register.ECX == 0
