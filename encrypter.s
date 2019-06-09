################################################################################
# Title:                                      Filename: encrypter.s
# Author: Simone Cappabianca                  Date: 25/02/2019
# Description: ...
# Input: ...
# Output: ...
# $s0: Full name of the key file
# $s1: Full name of the message file
# $s2: Length of key
# $s3: length of message
# $s4: Full name of the crypted file 
################################################################################

################################# Data segment #################################
.data

# Key
fullNameOfKey: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/chiave.txt"
bufferKeyData: .space 5

# Message
fullNameOfMsg: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/messaggio.txt"
bufferMsgData: .space 128

# Encrypt Message
fullNameOfEncrptMsg: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/messaggioCifrato.txt"
bufferEncrptData: .space 128

# Decrypt Message
fullNameOfDecrptMsg: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/messaggioDecifrato.txt"
bufferDecrptData: .space 128

# Messages
promptReadKey: .asciiz "1 - Read file chiave.txt\n"
promptReadMsg: .asciiz "\n2 - Read file messaggio.txt\n"
promptEncrptMsg: .asciiz "\n3 - Encrypt the original message\n"
promptWriteEncrptMsg: .asciiz "\n4 - Write the file mesasggioCifrato.txt\n"
promptDecrptMsg: .asciiz "\n5 - Decrypt the encrypted message\n"
promptWriteDecrptMsg: .asciiz "\n6 - Write the file messaggioDecifrato.txt\n"
msgErrKeyNotExist: .asciiz "File of key not exist!\n"
msgErrKeyIsEmpty: .asciiz "File of key is empty!\n"
msgErrMsgNotExist: .asciiz "File of message not exist!\n"
msgErrMsgIsEmpty: .asciiz "File of message is empty!\n"
msgEndProgram: .asciiz "\nEnd program\n"
lineFeed: .asciiz "\n"
promptAlgEncrptA: .asciiz "\nApplied the algorithm of encryption A\n"
promptAlgEncrptB: .asciiz "\nApplied the algorithm of encryption B\n"
promptAlgEncrptC: .asciiz "\nApplied the algorithm of encryption C\n"
promptAlgEncrptD: .asciiz "\nApplied the algorithm of encryption D\n"
promptAlgEncrptE: .asciiz "\nApplied the algorithm of encryption E\n"
promptAlgDecrptA: .asciiz "\nApplied the algorithm of decryption A\n"
promptAlgDecrptB: .asciiz "\nApplied the algorithm of decryption B\n"
promptAlgDecrptC: .asciiz "\nApplied the algorithm of decryption C\n"
promptAlgDecrptD: .asciiz "\nApplied the algorithm of decryption D\n"
promptAlgDecrptE: .asciiz "\nApplied the algorithm of decryption E\n"

.align 2
jumpEncrtpTable: .word  encrptA encrptB encrptC encrptD encrptE
jumpDecrptTable: .word  decrptA decrptB decrptC decrptD decrptE

################################# Code segment #################################
.text
.globl main

printStr:
  # Procedure to print a string
  # $a0: address of null-terminated string to print

  li $v0,4
  syscall
  jr $ra

printInt:
  # Procedure to print a integer
  # $a0: integer to print

  li $v0,1
  syscall
  jr $ra

printChr:
  # Procedure to print a char
  # $a0: character to print

  li $v0,11
  syscall
  jr $ra

readStr:
  # Procedure to read a string
  # $a0: address of input buffer
	# $a1: maximum number of characters to read

  li $v0,8
	syscall
  jr $ra

length:
  # procedure to calcolate length of string
  # $a0: ...

  move $t2,$a0
  li $t1,0
nextCh:
  lb $t0,($t2)
  beqz $t0,strEnd
  add $t1,$t1,1
  add $t2,$t2,1
  j nextCh

strEnd:
  move $v0,$t1
  jr $ra

removeLF:
  # Procedure to remove line feed char \n

  add $a0,$a0,79
rLFloop:
  lb $v0,($a0)
  bnez $v0,rLFdone
  sub $a0,$a0,1
  j rLFloop
rLFdone: sb $0,0($a0)
  jr $ra

openFileToRead:
  # Procedure to open file in read mode
  # $a0 = address of null-terminated string containing filename

  li $v0, 13 # system call for open file
  li $a1, 0 # flag for reading
  li $a2, 0 # mode is ignored
  syscall # open a file
  jr $ra

readFile:
  # Procedure to read a file
  # $a0: file descriptor
  # $a1: address of input buffer
  # $a2: maximum number of characters to read

  li $v0,14
  syscall
  jr $ra

openFileToWrite:
  # Procedure to open file in write mode
  # $a0: output file name

  li $v0, 13 # system call for open file
  li $a1, 1 # flag for writing
  li $a2, 0 # mode is ignored
  syscall # open a file
	jr $ra

writeFile:
  # Procedure to write a file
  # $a0: file descriptor
  # $a1: address of buffer from which to write
  # $s2: hardcoded buffer length

  li $v0, 15
  syscall
  jr $ra

closeFile:
  # Procedure to close file
  # $a0: file descriptor

  li $v0,16
  syscall
  jr $ra

module:
  # Procedure to calcolate a mod 256
  # $a0: number
  # $a1: module
  # $v0: result of number mod modulo

  div $a0,$a1
  mfhi $v0
  jr $ra

encryptA:
  # Procedure for algorithm A
  # $a0: original message

  move $t0,$a0
  move $t2,$a1
  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgEncrptA
  jal printStr
nextChrEncryptA:
  lb $t1,($t0)
  beqz $t1,endBufferEncryptA
  move $a0,$t1                # Start - char encoding
  addi $a0,4                  # .
  li $a1,256                  # .
  jal module                  # End - char endcoding
  sb $v0,0($t0)               # Store coded char
  move $a0,$v0
  jal printChr
  add $t0,$t0,1
  j nextChrEncryptA

endBufferEncryptA:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

decryptA:
  # Procedure for algorithm A

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgDecrptA
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

encryptB:
  # Procedure for algorithm B
  # $a0: original message

  move $t0,$a0
  move $t2,$a1
  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgEncrptB
  jal printStr
  move $t3,$zero
nextChrEncryptB:
  lb $t1,($t0)
  beqz $t1,endBufferEncryptB
  move $a0,$t3
  li $a1,2
  jal module
  bnez $v0,jumpEncodingB
  move $a0,$t1                # Start - char encoding
  addi $a0,4                  # .
  li $a1,256                  # .
  jal module                  # End - char encoding
  move $t1,$v0
jumpEncodingB:
  sb $t1,0($t0)               # Store coded char
  move $a0,$t1
  jal printChr
  add $t3,$t3,1
  add $t0,$t0,1
  j nextChrEncryptB

endBufferEncryptB:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

decryptB:
  # Procedure for algorithm B

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgDecrptB
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

encryptC:
  # Procedure for algorithm C
  # $a0: original message

  move $t0,$a0
  move $t2,$a1
  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgEncrptC
  jal printStr
  move $t3,$zero
nextChrEncryptC:
  lb $t1,($t0)
  beqz $t1,endBufferEncryptC
  move $a0,$t3
  li $a1,2
  jal module
  beqz $v0,jumpEncodingC
  move $a0,$t1                # Start - char encoding
  addi $a0,4                  # .
  li $a1,256                  # .
  jal module                  # End - char encoding
  move $t1,$v0
jumpEncodingC:
  sb $t1,0($t0)               # Store coded char
  move $a0,$t1
  jal printChr
  add $t3,$t3,1
  add $t0,$t0,1
  j nextChrEncryptC

endBufferEncryptC:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

decryptC:
  # Procedure for algorithm C

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgDecrptC
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

encryptD:
  # Procedure for algorithm D

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgEncrptD
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

decryptD:
  # Procedure for algorithm D

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgDecrptD
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

encryptE:
  # Procedure for algorithm E

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgEncrptE
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

decryptE:
  # Procedure for algorithm E

  addi $sp,$sp,-4
  sw $ra,0($sp)
  la $a0,promptAlgDecrptE
  jal printStr
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

encryptMsg:
  # Procedure to encrypth message
  # This procedure applies the right algorithm or the algorithms on the message
  # in base on the key of the encryption.

  # Prepare the jump table of algorithms
  la $t1,jumpEncrtpTable

  move $t3,$a0 # $t3 key
  move $t5,$a1 # $t5 length of key
  sub $t5,$t5,1
  addi $sp,$sp,-4
  sw $ra,0($sp)
nextEncrpt:
  lb $t4,($t3)
  beqz $t5,endEncrpt
  sub $t0,$t4,65
  mul $t0,$t0,4
  add $t0,$t0,$t1
  lw $t0,0($t0)
  jr $t0

encrptA:
  addi $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  addi $sp,$sp,-4
  sw $t3,0($sp)
  addi $sp,$sp,-4
  sw $t4,0($sp)
  addi $sp,$sp,-4
  sw $t5,0($sp)
  la $a0,bufferMsgData
  jal encryptA
  lw $t5,0($sp)
  addi $sp,$sp,4
  lw $t4,0($sp)
  addi $sp,$sp,4
  lw $t3,0($sp)
  addi $sp,$sp,4
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t0,0($sp)
  addi $sp,$sp,4
  j exitCaseEncrpt
encrptB:
  addi $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  addi $sp,$sp,-4
  sw $t3,0($sp)
  addi $sp,$sp,-4
  sw $t4,0($sp)
  addi $sp,$sp,-4
  sw $t5,0($sp)
  la $a0,bufferMsgData
  jal encryptB
  lw $t5,0($sp)
  addi $sp,$sp,4
  lw $t4,0($sp)
  addi $sp,$sp,4
  lw $t3,0($sp)
  addi $sp,$sp,4
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t0,0($sp)
  addi $sp,$sp,4
  j exitCaseEncrpt
encrptC:
  addi $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  addi $sp,$sp,-4
  sw $t3,0($sp)
  addi $sp,$sp,-4
  sw $t4,0($sp)
  addi $sp,$sp,-4
  sw $t5,0($sp)
  la $a0,bufferMsgData
  jal encryptC
  lw $t5,0($sp)
  addi $sp,$sp,4
  lw $t4,0($sp)
  addi $sp,$sp,4
  lw $t3,0($sp)
  addi $sp,$sp,4
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t0,0($sp)
  addi $sp,$sp,4
  j exitCaseEncrpt
encrptD:
  jal encryptD
  j exitCaseEncrpt
encrptE:
  jal encryptE
exitCaseEncrpt:
  sub $t5,$t5,1
  add $t3,$t3,1
  j nextEncrpt

endEncrpt:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

decryptMsg:
  # Procedure to decrypth the encrypted message
  # This procedure applies the right algorithm or the algorithms on the message
  # in base on the key of the encryption.

  # Prepare the jump table of algorithms
  la $t1,jumpDecrptTable

  move $t3,$a0 # $t3 key
  move $t5,$a1 # $t5 length of key
  sub $t5,$t5,2
  add $t3,$t3,$t5
  addi $sp,$sp,-4
  sw $ra,0($sp)
nextDecrpt:
  lb $t4,($t3)
  bltz $t5,endDecrpt
  sub $t0,$t4,65
  mul $t0,$t0,4
  add $t0,$t0,$t1
  lw $t0,0($t0)
  jr $t0
decrptA:
  jal decryptA
  j exitCaseDecrpt
decrptB:
  jal decryptB
  j exitCaseDecrpt
decrptC:
  jal decryptC
  j exitCaseDecrpt
decrptD:
  jal decryptD
  j exitCaseDecrpt
decrptE:
  jal decryptE
exitCaseDecrpt:
  sub $t5,$t5,1
  sub $t3,$t3,1
  j nextDecrpt

endDecrpt:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

printBuffer:
  # Procedure to print a buffer
  # $a0: address of input buffer
  # $a1: length of input buffer

  move $t3,$a0 # $t3 buffer
  move $t5,$a1 # $t5 length of buffer
  addi $sp,$sp,-4
  sw $ra,0($sp)
nextChr:
  lb $t4,($t3)
  beqz $t5,endBuffer
  move $a0,$t4
  jal printChr
  sub $t5,$t5,1
  add $t3,$t3,1
  j nextChr

endBuffer:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

##################################### MAIN #####################################
main:
################################################################################

  # Open file to read the key
  la $a0,promptReadKey
  jal printStr
  la $a0,fullNameOfKey
  jal openFileToRead

  # Check if file of key exist
  beq $v0,-1,keyNotExist

  # Read the key
  move $a0,$v0
  la $a1,bufferKeyData
  li $a2,5
  jal readFile
  move $s2,$v0

  # Check if file of key is empty
  beq $v0,$zero,keyIsEmpty

  # Open file to read message
  la $a0,promptReadMsg
  jal printStr
  la $a0,fullNameOfMsg
  jal openFileToRead

  # Check if file of message exist
  beq $v0,-1,msgNotExist

  # Read the message
  move $a0,$v0
  la $a1,bufferMsgData
  li $a2,128
  jal readFile
  move $s3,$v0

  # Check if file of key is empty
	beq $v0,$zero,msgIsEmpty

  # Encrypt message
  la $a0,promptEncrptMsg
  jal printStr
  la $a0,bufferKeyData
  move $a1,$s2
  jal encryptMsg

  # Open file to write the encrypth message
  la $a0,promptWriteEncrptMsg
  jal printStr
  la $a0,fullNameOfEncrptMsg
  jal openFileToWrite
  move $s4,$v0

  # Write the encrypted message
  move $a0,$s4
  la $a1,bufferMsgData
  li $a2,128
  jal writeFile

  # Close the encrypted message
  move $a0,$s4
  jal closeFile

  # Decrypt message
  la $a0,promptDecrptMsg
  jal printStr
  la $a0,bufferKeyData
  move $a1,$s2
  jal decryptMsg

  # Open file to write the decrypted message
  la $a0,promptWriteDecrptMsg
  jal printStr
  la $a0,fullNameOfDecrptMsg
  jal openFileToWrite
  move $s4,$v0

  # Write the decrypted message
  move $a0,$s4
  la $a1,bufferMsgData
  li $a2,128
  jal writeFile

  # Close the decrypted message
  move $a0,$s4
  jal closeFile

  j endProgram

keyNotExist:
  la $a0,msgErrKeyNotExist
  j printErrMsg

keyIsEmpty:
  la $a0,msgErrKeyIsEmpty
  j printErrMsg

msgNotExist:
  la $a0,msgErrMsgNotExist
  j printErrMsg

msgIsEmpty:
  la $a0,msgErrMsgIsEmpty
  j printErrMsg

printErrMsg:
  jal printStr

endProgram: # Exit to programm
  la $a0,msgEndProgram
  jal printStr
  li $v0,10
  syscall
