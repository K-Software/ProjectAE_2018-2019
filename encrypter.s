################################################################################
# Title:                                      Filename: encrypter.s            #
# Author: Simone Cappabianca                  Date: 25/02/2019                 #
# Description: ...                                                             #
# Input: ...                                                                   #
# Output: ...                                                                  #
# $s2: Length of the encrypt key                                               #
# $s3: Length of messages(original message, encrypted message,                 #
#      decrypted message)                                                      #
################################################################################

################################################################################
################################# DATA SEGMENT #################################
################################################################################
.data

# Key
fullNameOfKey: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/chiave.txt"
bufferKeyData: .space 5

# Message
fullNameOfMsg: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/messaggio.txt"
bufferMsgData: .space 513

# Encrypt Message
fullNameOfEncrptMsg: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/messaggioCifrato.txt"
bufferEncrptData: .space 513
bufferEncrptDataTmp: .space 513

# Decrypt Message
fullNameOfDecrptMsg: .asciiz "Users/simonecappabianca/Documents/University/ProjectAE_2018-2019/samples/messaggioDecifrato.txt"
bufferDecrptData: .space 513
bufferDecrptDataTmp: .space 513

positionCounter: .byte 0

# Messages
promptReadKey: .asciiz "1 - Read file chiave.txt\n"
promptReadMsg: .asciiz "\n2 - Read file messaggio.txt\n"
promptLengthMsg: .asciiz "\n2.1 - Length of messsage: "
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
positionSeparetor: .asciiz "-"
charSeparetor: .asciiz " "

.align 2
jumpEncrtpTable: .word  encrptA encrptB encrptC encrptD encrptE
jumpDecrptTable: .word  decrptA decrptB decrptC decrptD decrptE

################################################################################
################################# Code segment #################################
################################################################################
.text
.globl main
.align 2
########################################
#               printStr               #
########################################
printStr:
  # Procedure to print a string
  # $a0: address of null-terminated string to print

  li $v0,4
  syscall
  jr $ra

########################################
#              printInt                #
########################################
printInt:
  # Procedure to print a integer
  # $a0: integer to print

  li $v0,1
  syscall
  jr $ra

########################################
#              printChr                #
########################################
printChr:
  # Procedure to print a char
  # $a0: character to print

  li $v0,11
  syscall
  jr $ra

########################################
#              printBuffer             #
########################################
printBuffer:
  # Procedure to print a buffer
  # $a0: address of input buffer

  move $t0,$a0                          # $t3 buffer
  addi $sp,$sp,-4
  sw $ra,0($sp)
nextChr:
  lb $t1,($t0)
  beqz $t1,endBuffer
  addi $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  move $a0,$t1
  jal printChr
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t0,0($sp)
  addi $sp,$sp,4
  add $t0,$t0,1
  j nextChr

endBuffer:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               readStr                #
########################################
readStr:
  # Procedure to read a string
  # $a0: address of input buffer
	# $a1: maximum number of characters to read

  li $v0,8
	syscall
  jr $ra

########################################
#                length                #
########################################
length:
  # Procedure to calcolate length of string
  # $a0: string
  # $v0: length of string

  move $t2,$a0
  move $t1,$zero
nextCh:
  lb $t0,($t2)
  beqz $t0,strEnd
  add $t1,$t1,1
  add $t2,$t2,1
  j nextCh

strEnd:
  add $t1,$t1,-1
  move $v0,$t1
  jr $ra

########################################
#           openFileToRead             #
########################################
openFileToRead:
  # Procedure to open file in read mode
  # $a0 = address of null-terminated string containing filename

  li $v0,13                             # system call for open file
  li $a1,0                              # flag for reading
  li $a2,0                              # mode is ignored
  syscall                               # open a file
  jr $ra

########################################
#              readFile                #
########################################
readFile:
  # Procedure to read a file
  # $a0: file descriptor
  # $a1: address of input buffer
  # $a2: maximum number of characters to read

  li $v0,14                             # system call for read file
  syscall
  jr $ra

########################################
#           openFileToWrite            #
########################################
openFileToWrite:
  # Procedure to open file in write mode
  # $a0: output file name

  li $v0, 13                            # system call for open file
  li $a1, 1                             # flag for writing
  li $a2, 0                             # mode is ignored
  syscall                               # open a file
	jr $ra

########################################
#              writeFile               #
########################################
writeFile:
  # Procedure to write a file
  # $a0: file descriptor
  # $a1: address of buffer from which to write
  # $s2: hardcoded buffer length

  li $v0, 15                            # system call for write file
  syscall
  jr $ra

########################################
#              closeFile               #
########################################
closeFile:
  # Procedure to close file
  # $a0: file descriptor

  li $v0,16                             # system call for close file
  syscall
  jr $ra

########################################
#                sbrk                  #
########################################
sbrk:
  # Procedure to allocate heap memory
  # $a0: number of bytes to allocate
  # $v0: address of allocated memory

  li $v0,9
  syscall
  jr $ra

########################################
#                module                #
########################################
module:
  # Procedure to calcolate a mod 256
  # $a0: number
  # $a1: module
  # $v0: result of number mod modulo

  div $a0,$a1
  mfhi $v0
  jr $ra

########################################
#               encryptA               #
########################################
encryptA:
  # Procedure for algorithm A
  # $a0: original message
  # $v0: length of the encrypted message

  move $t0,$a0                          # $t0: Message
  move $v0,$zero
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgEncrptA
  jal printStr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
nextChrEncryptA:
  lb $t1,($t0)
  beqz $t1,endBufferEncryptA
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1                          # Start - char encoding
  addi $a0,4                            # .
  li $a1,256                            # .
  jal module                            # End - char endcoding
  move $t2,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  sb $t2,0($t0)                         # Store coded char
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $v0,($sp)
  move $a0,$t2
  jal printChr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $t0,$t0,1
  addi $v0,1
  j nextChrEncryptA

endBufferEncryptA:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               decryptA               #
########################################
decryptA:
  # Procedure for decryption algorithm A
  # $a0: coded message
  # $v0: length of the decrypted message

  move $t0,$a0                          # $t0: Message
  move $v0,$zero
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgDecrptA
  jal printStr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
nextChrDecryptA:
  lb $t1,($t0)
  beqz $t1,endBufferDecryptA
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1                          # Start - char decoding
  addi $a0,-4                           # .
  li $a1,256                            # .
  jal module                            # End - char decoding
  sb $v0,0($t0)                         # Store decoded char
  move $a0,$v0
  jal printChr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $t0,$t0,1
  addi $v0,1
  j nextChrDecryptA

endBufferDecryptA:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               encryptB               #
########################################
encryptB:
  # Procedure for algorithm B
  # $a0: original message
  # $v0: length of the encrypted message

  move $t0,$a0                          # $t0: Message
  move $v0,$zero
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgEncrptB
  jal printStr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  move $t2,$zero
nextChrEncryptB:
  lb $t1,($t0)
  beqz $t1,endBufferEncryptB
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t2
  li $a1,2
  jal module
  move $t3,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  bnez $t3,jumpEncodingB
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1                          # Start - char encoding
  addi $a0,4                            # .
  li $a1,256                            # .
  jal module                            # End - char encoding
  move $t1,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
jumpEncodingB:
  sb $t1,0($t0)                         # Store coded char
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1
  jal printChr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $t2,$t2,1
  add $t0,$t0,1
  add $v0,$v0,1
  j nextChrEncryptB

endBufferEncryptB:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               decryptB               #
########################################
decryptB:
  # Procedure for decryption algorithm B
  # $a0: coded message
  # $v0: length of the decrypted message

  move $t0,$a0                           # $t0: Message
  move $v0,$zero
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgDecrptB
  jal printStr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  move $t2,$zero
nextChrDecryptB:
  lb $t1,($t0)
  beqz $t1,endBufferDecryptB
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t2
  li $a1,2
  jal module
  move $t3,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  bnez $t3,jumpDecodingB
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1                           # Start - char decoding
  addi $a0,-4                            # .
  li $a1,256                             # .
  jal module                             # End - char decoding
  move $t1,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
jumpDecodingB:
  sb $t1,0($t0)                          # Store decoded char
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1
  jal printChr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $t2,$t2,1
  add $t0,$t0,1
  add $v0,$v0,1
  j nextChrDecryptB

endBufferDecryptB:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               encryptC               #
########################################
encryptC:
  # Procedure for algorithm C
  # $a0: original message
  # $v0: length of the encrypted message

  move $t0,$a0                          # $t0: Message
  move $v0,$zero
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgEncrptC
  jal printStr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  move $t2,$zero
nextChrEncryptC:
  lb $t1,($t0)
  beqz $t1,endBufferEncryptC
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t2
  li $a1,2
  jal module
  move $t3,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  beqz $t3,jumpEncodingC
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1                          # Start - char encoding
  addi $a0,4                            # .
  li $a1,256                            # .
  jal module                            # End - char encoding
  move $t1,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
jumpEncodingC:
  sb $t1,0($t0)                         # Store coded char
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1
  jal printChr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $t2,$t2,1
  add $t0,$t0,1
  add $v0,$v0,1
  j nextChrEncryptC

endBufferEncryptC:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               decryptC               #
########################################
decryptC:
  # Procedure for decryption algorithm B
  # $a0: coded message
  # $v0: length of the decrypted message

  move $t0,$a0                          # $t0: Message
  move $v0,$zero
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgDecrptC
  jal printStr
  move $t2,$zero
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  move $t2,$zero
nextChrDecryptC:
  lb $t1,($t0)
  beqz $t1,endBufferDecryptC
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t2
  li $a1,2
  jal module
  move $t3,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  beqz $t3,jumpDecodingC
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1                          # Start - char decoding
  addi $a0,-4                           # .
  li $a1,256                            # .
  jal module                            # End - char decoding
  move $t1,$v0
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
jumpDecodingC:
  sb $t1,0($t0)                         # Store coded char
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t1
  jal printChr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $t2,$t2,1
  add $t0,$t0,1
  add $v0,$v0,1
  j nextChrDecryptC

endBufferDecryptC:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               encryptD               #
########################################
encryptD:
  # Procedure for algorithm D
  # $a0: original message
  # $v0: length of the encrypted message

  move $t0,$a0                          # $t0: Message
  move $t1,$a0                          # $t1: Message
  move $t5,$a0                          # $t5: Message
  addi $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t5,0($sp)
  la $a0,promptAlgEncrptD
  jal printStr
  lw $t5,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t5,0($sp)
  move $a0,$t0
  jal length
  move $t2,$v0                          # $t2: Length of message
  lw $t5,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  move $a1,$zero
  addi $a2,$t2,-1
  add $t1,$t1,$a2
nextChrEncryptD:
  lb $t3,($t0)
  lb $t4,($t1)
  sub $a3,$t1,$t0
  blez $a3,endBufferEncryptD
  sb $t4,($t0)                          # Store char in new position
  sb $t3,($t1)                          # Store char in new position
  add $t0,$t0,1
  sub $t1,$t1,1
  j nextChrEncryptD

endBufferEncryptD:
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t1,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $t5,0($sp)
  move $a0,$t5
  jal printBuffer
  lw $t5,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t1,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  lw $ra,0($sp)
  add $t2,$t2,1
  move $v0,$t2
  addi $sp,$sp,4
  jr $ra

########################################
#               decryptD               #
########################################
decryptD:
  # Procedure for decryption algorithm D
  # $a0: coded message
  # $v0: lenght of the decrypted message

  addi $sp,$sp,-4
  sw $ra,0($sp)
  jal encryptD
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               encryptE               #
########################################
encryptE:
  # Procedure for algorithm E
  # $a0: original message
  # $v0: length of the encrypted message

  # Make a copy of original message
  move $t0,$a0                          # $t0: Original message
  la $t1,bufferEncrptDataTmp            # $t1: Temporaty copy
loopCopyEncryptE:
  lb $t2,($t0)
  lb $t3,($t1)
  beqz $t2,endCopyEncryptE
  sb $t2,($t1)
  add $t0,$t0,1
  add $t1,$t1,1
  j loopCopyEncryptE
endCopyEncryptE:

  move $t0,$a0                          # $t0: Original message
  move $t3,$a0                          # $t3: Original message
  add $sp,$sp,-4
  sw $ra,0($sp)
  add $sp,$sp,-4
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t3,0($sp)
  la $a0,promptAlgEncrptE               # Print pront message
  jal printStr
  lw $t3,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  move $t8,$zero                        # $t8: Head
  move $t9,$zero                        # $t9: Tail

# Create a list with all the characters present in the message
nextChrEncryptE:
  lb $t2,($t0)
  beqz $t2,endBufferEncryptE
  bne $t8,$zero, linkLast
  addi $sp,$sp,-4                       # Start - Added first char
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $t3,0($sp)
  add $sp,$sp,-4
  sw $t8,0($sp)
  add $sp,$sp,-4
  sw $t9,0($sp)
  li $a0,5
  jal sbrk
  lw $t9,0($sp)
  add $sp,$sp,4
  lw $t8,0($sp)
  add $sp,$sp,4
  lw $t3,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  sb $t2,4($v0)
  sw $zero,0($v0)
  move $t8,$v0
  move $t9,$v0
  j endOfLoop                           # End - Added first char
linkLast:
  move $t7,$t8                          # $t7 = head of list
loopSearchChar:
  beq $t7,$zero,addNewElement
  lb $a2,4($t7)
  beq $a2,$t2,endOfLoop
  lw $t7,0($t7)
  j loopSearchChar

addNewElement:
  add $sp,$sp,-4                       # Start - Added new char
  sw $t0,0($sp)
  add $sp,$sp,-4
  sw $t2,0($sp)
  add $sp,$sp,-4
  sw $t3,0($sp)
  add $sp,$sp,-4
  sw $t8,0($sp)
  add $sp,$sp,-4
  sw $t9,0($sp)
  li $a0,5
  jal sbrk
  lw $t9,0($sp)
  add $sp,$sp,4
  lw $t8,0($sp)
  add $sp,$sp,4
  lw $t3,0($sp)
  add $sp,$sp,4
  lw $t2,0($sp)
  add $sp,$sp,4
  lw $t0,0($sp)
  add $sp,$sp,4
  sw $v0,0($t9)
  sb $t2,4($v0)
  sw $zero,0($v0)
  move $t9,$v0                          # End - Added new char

endOfLoop:
  add $t0,$t0,1
  j nextChrEncryptE

endBufferEncryptE:
  move $t7,$t8                          # $t7 = head of list
  move $v0,$zero
loopPrint:
  beq $t7,$zero,endPrint
  lb $a0,4($t7)                         # Store a char
  sb $a0,0($t3)
  add $t3,$t3,1
  addi $v0,$v0,1                        # Increase the length of the message
  add $sp,$sp,-4
  sw $t3,0($sp)
  add $sp,$sp,-4
  sw $t7,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  lb $a0,4($t7)
  jal printChr                          # Print a char
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t7,0($sp)
  add $sp,$sp,4
  lw $t3,0($sp)
  add $sp,$sp,4
  # Store char
  la $t1,bufferEncrptDataTmp
  lb $a0,positionCounter                # Position counter
  lb $a1,4($t7)                         # Char
loopSearchPosition:
  lb $t2,0($t1)
  beqz $t2,endLooopSearchPosition
  bne $t2,$a1,noPrintPosition
  lb $t4,positionSeparetor              # Store positionSeparetor
  sb $t4,0($t3)
  addi $t3,$t3,1
  addi $v0,$v0,1                        # Increase the length of the message
  move $t4,$a0
  addi $t5,$zero,100
  div $t4,$t5
  mflo $t4
  beqz $t4, tens
  add $t4,$t4,48
  sb $t4,0($t3)                         # Store position hundreds
  add $t3,$t3,1
  addi $v0,$v0,1                        # Increase the length of the message
tens:
  mfhi $t4
  add $t5,$zero,10
  div $t4,$t5
  mflo $t4
  beqz $t4, units
  addi $t4,$t4,48
  sb $t4,0($t3)                         # Store position tens
  addi $t3,$t3,1
  addi $v0,$v0,1                        # Increase the length of the message
units:
  mfhi $t4
  addi $t4,$t4,48
  sb $t4,0($t3)                         # Store position units
  addi $t3,$t3,1
  addi $v0,$v0,1                        # Increase the length of the message
  # TODO: Store positione and increase the length
  addi $sp,$sp,-4
  sw $t7,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  addi $sp,$sp,-4
  sw $a0,0($sp)
  addi $sp,$sp,-4
  sw $a1,0($sp)
  addi $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,positionSeparetor              # Print positionSeparator
  jal printStr
  lw $v0,0($sp)
  addi $sp,$sp,4
  lw $a1,0($sp)
  addi $sp,$sp,4
  lw $a0,0($sp)
  addi $sp,$sp,4
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t7,0($sp)
  addi $sp,$sp,4
  addi $sp,$sp,-4
  sw $t7,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  addi $sp,$sp,-4
  sw $a0,0($sp)
  addi $sp,$sp,-4
  sw $a1,0($sp)
  addi $sp,$sp,-4
  sw $v0,0($sp)
  jal printInt                          # Print position
  lw $v0,0($sp)
  addi $sp,$sp,4
  lw $a1,0($sp)
  addi $sp,$sp,4
  lw $a0,0($sp)
  addi $sp,$sp,4
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t7,0($sp)
  addi $sp,$sp,4
noPrintPosition:
  add $t1,$t1,1
  add $a0,$a0,1
  j loopSearchPosition
endLooopSearchPosition:
  lw $t7,0($t7)
  lb $a0,charSeparetor                  # Store char separator
  sb $a0,0($t3)
  add $t3,$t3,1
  addi $v0,$v0,1                        # Increase the length of the message
  add $sp,$sp,-4
  sw $t7,0($sp)
  add $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,charSeparetor                  # Print char sperator
  jal printStr
  lw $v0,0($sp)
  add $sp,$sp,4
  lw $t7,0($sp)
  add $sp,$sp,4
  j loopPrint
endPrint:

  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#               decryptE               #
########################################
decryptE:
  # Procedure for algorithm E
  # $a0: coded message
  # $v0: lenght of the decrypted message

  move $t0,$a0                          # Message
  la $t1,bufferDecrptDataTmp            # Temp buffer
loopCopyDecryptE:                       # Copy the encrypt message in the
  lb $t2,0($t0)                         # temp buffer and clear the original
  beqz $t2,endCopyDecryptE
  sb $t2,0($t1)
  sb $zero,0($t0)
  add $t0,$t0,1
  add $t1,$t1,1
  j loopCopyDecryptE
endCopyDecryptE:
  move $t0,$a0                          # Message
  la $t1,bufferDecrptDataTmp
  move $v0,$zero
  addi $sp,$sp,-4
  sw $ra,0($sp)
  addi $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $t1,0($sp)
  addi $sp,$sp,-4
  sw $v0,0($sp)
  la $a0,promptAlgDecrptE
  jal printStr
  lw $v0,0($sp)
  addi $sp,$sp,4
  lw $t1,0($sp)
  addi $sp,$sp,4
  lw $t0,0($sp)
  addi $sp,$sp,4
nextChrDecryptE:
  lb $t2,0($t1)                         # Char
  beqz $t2,cleanTmpBuffer
  addi $t1,$t1,2
nextPosition:
  lb $t3,0($t1)                         # Position (first digit)
  addi $t3,$t3,-48
nextDigitOfPosition:
  addi $t1,$t1,1
  lb $t4,0($t1)                         # Take the next char
  addi $t4,$t4,-48
  bgez $t4,updatedPosition              # If is a number add digit to position
  add $t0,$t0,$t3                       # In $t3 there is a position of char
  sb $t2,0($t0)                         # Store char
  sub $t0,$t0,$t3
  addi $v0,$v0,1                        # Increase the length of the message
  addi $t1,$t1,1
  addi $t4,$t4,3
  beqz $t4,nextPosition
  j nextChrDecryptE
updatedPosition:
  mul $t3,$t3,10
  add $t3,$t3,$t4
  j nextDigitOfPosition

cleanTmpBuffer:                         # Clear the temp buffer
  la $t1,bufferDecrptDataTmp
loopCleanTmp:
  lb $t2,0($t1)
  beqz $t2,endBufferDecryptE
  sb $zero,0($t1)
  add $t1,$t1,1
  j loopCleanTmp

endBufferDecryptE:
  addi $sp,$sp,-4
  sw $t0,0($sp)
  addi $sp,$sp,-4
  sw $v0,0($sp)
  move $a0,$t0
  jal printBuffer
  lw $v0,0($sp)
  addi $sp,$sp,4
  lw $t0,($sp)
  addi $sp,$sp,4
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#              encryptMsg              #
########################################
encryptMsg:
  # Procedure to encrypth message
  # This procedure applies the right algorithm or the algorithms on the message
  # in base on the key of the encryption.
  # $a0: encrypth key
  # $a1: length of Key
  # $v0: length of the encrypted message

  # Prepare the jump table of algorithms
  la $t1,jumpEncrtpTable

  move $t3,$a0                  # $t3 key
  move $t5,$a1                  # $t5 length of key
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
  jal encryptD
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
encrptE:
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
  jal encryptE
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
exitCaseEncrpt:
  sub $t5,$t5,1
  add $t3,$t3,1
  j nextEncrpt

endEncrpt:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

########################################
#              decryptMsg              #
########################################
decryptMsg:
  # Procedure to decrypth the encrypted message
  # This procedure applies the right algorithm or the algorithms on the message
  # in base on the key of the encryption.
  # $a0: Encrypth key
  # $a1: length of Key

  # Prepare the jump table of algorithms
  la $t1,jumpDecrptTable

  move $t3,$a0 #                $t3 key
  move $t5,$a1 #                $t5 length of key
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
  la $a0,bufferEncrptData
  jal decryptA
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
  j exitCaseDecrpt
decrptB:
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
  la $a0,bufferEncrptData
  jal decryptB
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
  j exitCaseDecrpt
decrptC:
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
  la $a0,bufferEncrptData
  jal decryptC
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
  j exitCaseDecrpt
decrptD:
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
  la $a0,bufferEncrptData
  jal decryptD
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
  j exitCaseDecrpt
decrptE:
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
  la $a0,bufferEncrptData
  jal decryptE
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
exitCaseDecrpt:
  sub $t5,$t5,1
  sub $t3,$t3,1
  j nextDecrpt

endDecrpt:
  lw $ra,0($sp)
  addi $sp,$sp,4
  jr $ra

##################################### MAIN #####################################
main:
################################################################################

  addi $sp,$sp,-4
  sw $s0,0($sp)
  addi $sp,$sp,-4
  sw $s1,0($sp)
  addi $sp,$sp,-4
  sw $s2,0($sp)
  addi $sp,$sp,-4
  sw $s3,0($sp)
  addi $sp,$sp,-4
  sw $s4,0($sp)
  addi $sp,$sp,-4
  sw $s5,0($sp)
  addi $sp,$sp,-4
  sw $s6,0($sp)
  addi $sp,$sp,-4
  sw $s7,0($sp)

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
  beq $s2,$zero,keyIsEmpty

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
  beq $s3,$zero,msgIsEmpty

  # Diplay the length of message
  la $a0,promptLengthMsg
  jal printStr
  move $a0,$s3
  jal printInt
  la $a0,lineFeed
  jal printStr

  ##############################################################################
  #                              Encrypt message                               #
  ##############################################################################
  la $a0,promptEncrptMsg
  jal printStr
  la $a0,bufferKeyData
  move $a1,$s2
  jal encryptMsg
  move $s3,$v0

  # Open file to write the encrypth message
  la $a0,promptWriteEncrptMsg
  jal printStr
  la $a0,fullNameOfEncrptMsg
  jal openFileToWrite
  move $s4,$v0

  # Write the encrypted message
  move $a0,$s4
  la $a1,bufferMsgData
  move $a2,$s3
  jal writeFile

  # Close the encrypted message
  move $a0,$s4
  jal closeFile

  ##############################################################################
  #                            Decrypt message                                 #
  ##############################################################################
  # Open file to read coded message
  la $a0,fullNameOfEncrptMsg
  jal openFileToRead

  # Read the encrypth message
  move $a0,$v0
  la $a1,bufferEncrptData
  move $a2,$s3
  jal readFile
  move $s3,$v0

  la $a0,promptDecrptMsg
  jal printStr
  la $a0,bufferKeyData
  move $a1,$s2
  jal decryptMsg
  move $s3,$v0

  # Open file to write the decrypted message
  la $a0,promptWriteDecrptMsg
  jal printStr
  la $a0,fullNameOfDecrptMsg
  jal openFileToWrite
  move $s4,$v0

  # Write the decrypted message
  move $a0,$s4
  la $a1,bufferEncrptData
  move $a2,$s3
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
  lw $s7,0($sp)
  addi $sp,$sp,4
  lw $s6,0($sp)
  addi $sp,$sp,4
  lw $s5,0($sp)
  addi $sp,$sp,4
  lw $s4,0($sp)
  addi $sp,$sp,4
  lw $s3,0($sp)
  addi $sp,$sp,4
  lw $s2,0($sp)
  addi $sp,$sp,4
  lw $s1,0($sp)
  addi $sp,$sp,4
  lw $s0,0($sp)
  addi $sp,$sp,4
  la $a0,msgEndProgram
  jal printStr
  li $v0,10
  syscall
