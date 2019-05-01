  # Programm: encrypter.s
  # Author: Simone Cappabianca
  # Date: 01/05/2019
  #
  # $s0: Full name of the key file
  # $s1: Full name of the message file

.data

promptKey: .asciiz "Enter full file name of key: "
bufferKeyName: .space 300
bufferKeyData: .space 5
msgErrKeyNotExist: .asciiz "File of key not exist!\n"
msgErrKeyIsEmpty: .asciiz "File of Key is empty!\n"
promptMsg: .asciiz "Enter full file name of message: "
bufferMsgName: .space 80
bufferMsgData: .space 256
msgErrMsgNotExist: .asciiz "File of message not exist!\n"
msgErrMsgIsEmpty: .asciiz "File of message is empty!\n"
msgEndProgram: .asciiz "End program"
lineFeed: .asciiz "\n"

.text
.globl main

printStr: # procedure to print a string

  li $v0,4
  syscall
  jr $ra

printInt: # procedure to print a integer

  li $v0,1
  syscall
  jr $ra

readStr:  # procedure to read a string

  li $v0,8
	syscall
  jr $ra

length:   # procedure to calcolate length of string

  move $t2,$a0
  li $t1,0
nextCh:
  lb $t0,($t2)
	beqz $t0,strEnd
	add $t1,$t1,1
	add $t2,$t2,1
	j nextCh

strEnd:
  move $v0,$t1    # scrivo il risultato
  jr $ra

removeLF:  # procedure to remove line feed char \n

	add $a0,$a0,79
rLFloop:
	lb $v0,0($a0)
	bnez $v0,rLFdone
	sub $a0,$a0,1
	j rLFloop
rLFdone: sb $0,0($a0)
  jr $ra


openFileToRead: # procedure to open filein read mode

	li   $v0, 13 # system call for open file
	li   $a1, 0 # flag for reading
	li   $a2, 0 # mode is ignored
	syscall # open a file
  jr $ra

readFile: # procedure read a file

	li $v0,14
	syscall
  jr $ra

main:

  # prompt for get file name of key
  la $a0, promptKey
  jal printStr
	la $a0,bufferKeyName
  li $a1,300
  jal readStr
  la $a0,bufferKeyName
  jal removeLF
  la $s0,bufferKeyName

  # Open file to read the key
	move $a0,$s0
	jal openFileToRead

	# Check if file of key exist
	beq $v0,-1,keyNotExist

	# Read the key
	move $a0,$v0
	la $a1,bufferKeyData
	li $a2,5
	jal readFile

  # Check if file of key is empty
  beq $v0,$zero,keyIsEmpty

  # prompt for get file name of message
  la $a0,promptMsg
  jal printStr
  la $a0,bufferMsgName
  li $a1,80
  jal readStr
  la $a0,bufferMsgName
  jal removeLF
  la $s1,bufferMsgName

  # Open file to read message
  move $a0,$s1
  jal openFileToRead

  # Check if file of message exist
  beq $v0,-1,	msgNotExist

  # Read the message
  move $a0,$v0
  la $a1,bufferMsgData
  li $a2,256
  jal readFile

  # Check if file of key is empty
	beq $v0,$zero,msgIsEmpty

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
