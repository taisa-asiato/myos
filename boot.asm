;
; File Name: boot.asm
; Description:Bootloader

[BITS 16]

ORG	0x7C00
;
; BIOS Prameter Block
;
JMP	BOOT	;BS_JmpBoot

BS_JmpBoot	DB	0x90
BS_OEMName	DB	"MyOS    "
BPB_BytsPerSec	DW	0x0200	; BytesPerSector
BPB_SecPerClus	DB	0x01	; SectorPerCluster
BPB_RsvdSecCnt	DW	0x0001	; ReservedSectors
BPB_NumFATS	DB	0x02	; TotalFATS
BPB_RootEntCnt	DW	0x00ED	; MaxRootEntrys
BPB_TotSec16	DW	0x0B40	; TotalSectors
BPB_Media	DB	0xF0	; MediaDescriptor
BPB_FATSz16	DW	0x0009	; SectorsPerFats
BPB_SecPerTrk	DW	0x0012	; SectorsPerTrack
BPB_NumHeads	DW	0x0002	; NumHeads
BPB_HiddSec	DD	0x00000000	; HiddenSectors
BPB_ToSec23	DD	0x00000000	; TotalSectors

BPB_DrvNum	DB	0x00		; DriveNumber
BS_Reserved1	DB	0x00		; Reserved
BP_BootSig	DB	0x29		; BootSignature
BS_VolID	DD	0x20180310	; VolumeSerialNumber
BS_VolLab	DB	"MyOS       "	; VolumeLabel
BS_FilSysType	DB	"FAT12   "	; FileSystemType
ImageName 	DB	"Hello World", 0x00
FloppyRead	DB	"Read Sector From Floppy", 0x00
; ------------------------------------------------------------

;
; DisplayMessage
;
DisplayMessage:
	PUSH	AX
	PUSH	BX
StartDispMsg:
	LODSB
	OR	AL, AL
	JZ	.DONE
	MOV	AH, 0x0E
	MOV 	BH, 0x00
	MOV	BL, 0x07
	INT	0x10
	JMP	StartDispMsg
.DONE:
	POP	BX
	POP	AX
	RET

;
; For NewLine Function
;
NewLine:
	PUSH 	AX
	PUSH 	BX
	MOV	AH, 0x0E
	MOV	AL, 0x0a	; 改行文字
	MOV	BH, 0x00
	MOV	BL, 0x07
	INT	0x10
	POP	AX
	POP	BX
	RET

;
; Reset Floppy Drive
;
ResetFloppyDrive:
	MOV	AH, 0x00
	MOV	DL, 0x00
	INT 0x13
	JC	FAILURE
	HLT
FAILURE:
	HLT

;
; Read Floppy Drive
;
ReadSectors:
	MOV	AH, 0x02
	MOV	AL, 0x01
	MOV	CH, 0x01
	MOV	CL, 0x02
	MOV	DH, 0x00
	MOV	DL, 0x00
	MOV	BX, 0x1000
	MOV	ES, BX
	MOV	BX, 0x0000
	INT 0x13

;
; LBA2CHS
;
LBA2CHS:
	XOR	DX, DX			; Initailze DX
	DIV	WORD [BPB_SecPerTrk]	; calculate
	INC	DL
	MOV	BYTE [physicalSector], DL
	XOR	DX, DX
	DIV	WORD [BPB_NumHeads]
	MOV 	BYTE [physicalHead], DL
	MOV	BYTE [physicalTrack], AL

	MOV	SI, FloppyRead
	CALL	DisplayMessage

	RET

physicalSector	DB	0x00
physicalHead	DB	0x00
physicalTrack	DB	0x00

;
; BOOT
;
BOOT:
	CLI
	; Initialize Data Segment
	XOR	AX, AX
	MOV	DS, AX
	MOV	ES, AX
	MOV	FS, AX
	MOV	GS, AX

	XOR	BX, BX
	XOR	CX, CX
	XOR	DX, DX

	; Initialize Stack Segment and Stack Pointer
	MOV	SS, AX
	MOV	SP, 0xFFFC


	MOV	SI, ImageName
	CALL	DisplayMessage
	CALL 	NewLine

	CALL	LBA2CHS
	HLT

TIMES 510 - ( $ - $$ ) DB 0

DW	0xAA55
