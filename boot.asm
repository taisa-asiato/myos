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
BPB_NUMHeads	DW	0x0002	; NumHeads
BPB_HiddSec	DD	0x00000000	; HiddenSectors
BPB_ToSec23	DD	0x00000000	; TotalSectors

BPB_DrvNum	DB	0x00		; DriveNumber
BS_Reserved1	DB	0x00		; Reserved
BP_BootSig	DB	0x29		; BootSignature
BS_VolID	DD	0x20180310	; VolumeSerialNumber
BS_VolLab	DB	"MyOS       "	; VolumeLabel
BS_FilSysType	DB	"FAT12   "	; FileSystemType

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

	HLT

TIMES 510 - ( $ - $$ ) DB 0

DW	0xAA55
