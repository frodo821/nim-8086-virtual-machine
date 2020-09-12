BITS 32
  ORG 0x7c00

start:
  MOV ESI,msg_Hello
  CALL prints
  JMP exit

prints:
  MOV AL,[ESI]
  ADD ESI,1
  CMP AL,0
  JE .exit
  MOV AH,0x0e
  MOV EBX,10
  INT 0x10
  JMP prints
.exit:
  ret

exit:
  HLT
  JMP exit

msg_Hello db "Hello, World!", 0x0d, 0x0a, 0x00
