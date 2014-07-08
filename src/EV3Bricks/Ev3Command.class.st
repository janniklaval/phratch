Class {
	#name : #Ev3Command,
	#superclass : #Ev3BrickCommand,
	#category : #EV3Bricks
}

{ #category : #accessing }
Ev3Command class >> byteCodes [
	^ {#ProgramStop	-> 16r02.
		#ProgramStart -> 16r03.
		#InitBytes -> 16r2F.
		#Info -> 16r7C.
 		#String -> 16r7D.
 		#MemoryWrite -> 16r7E.
 		#MemoryRead -> 16r7F.
		#UIRead -> 16r81.
		#UIWrite -> 16r82.
		#UIButton -> 16r83.
		#UIDraw -> 16r84.
		#Sound -> 16r94.
		#SoundTest -> 095.
		#SoundReady -> 16r96.
		#InputSample -> 16r97.
		#InputDeviceList -> 16r98.
		#InputDevice -> 16r99.
		#InputRead -> 16r9a.
		#InputTest -> 16r9b.
		#InputReady -> 16r9c.
		#InputReadSI -> 16r9d.
		#InputReadExt -> 16r9e.
		#InputWrite -> 16r9f.
		#OutputGetType -> 16ra0.
		#OutputSetType -> 16ra1.         
 		#OutputReset -> 16ra2.           
 		#OutputStop -> 16rA3.
		#OutputPower -> 16rA4.
		#OutputSpeed -> 16rA5.
		#OutputStart-> 16rA6.
		#OutputPolarity -> 16rA7.
		#OutputRead -> 16rA8.
		#OutputTest -> 16rA9.
		#OutputReady -> 16rAA.
		#OutputPosition -> 16rAB.
		#OutputStepPower -> 16rAC.
		#OutputTimePower -> 16rAD.
		#OutputStepSpeed -> 16rAE.
		#OutputTimeSpeed -> 16rAF.
		#OutputStepSync -> 16rB0.
		#OutputTimeSync -> 16rB1.
		#OutputClrCount -> 16rB2.
		#OutputGetCount -> 16rB3.

		#File -> 16rC0.
 		#Array -> 16rc1.
 		#ArrayWrite -> 16rc2.
 		#ArrayRead -> 16rc3.
 		#ArrayAppend -> 16rc4.
 		#MemoryUsage -> 16rc5.
 		#FileName -> 16rc6.
		#MailboxOpen -> 16rD8.
		#MailboxWrite -> 16rD9.
		#MailboxRead -> 16rDA.
		#MailboxTest -> 16rDB.
		#MailboxReady -> 16rDC.
		#MailboxClose -> 16rDD.
		
		#Test -> 16rff.
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> constantParameterType [
	^ {#Value -> 16r00 . #Label -> 16r20  } asDictionary.
]

{ #category : #accessing }
Ev3Command class >> daisyChainLayer [
	^ {#EV3 -> 0.#First -> 1.	#Second -> 2.	#Third -> 3} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> fileSubCodes [ 

	^ {
		#OpenAppend -> 0.
		#OpenRead -> 1.
		#OpenWrite -> 2.
		#ReadValue -> 3.
		#WriteValue -> 4.
		#ReadText -> 5.
		#WriteText -> 6.
		#Close -> 7.
		#LoadImage -> 8.
		#GetHandle -> 9.
		#LoadPicture -> 10.
		#GetPool -> 11.
		#Unload -> 12.
		#GetFolders -> 13.
		#GetIcon -> 14.
		#GetSubfolderName -> 15.
		#WriteLog -> 16.
		#CLoseLog -> 17.
		#GetImage -> 18.
		#GetItem -> 19.
		#GetCacheFiles -> 20.
		#PutCacheFile -> 21.
		#GetCacheFile -> 22.
		#DelCacheFile -> 23.
		#DelSubfolder -> 24.
		#GetLogName -> 25.
		#GetCacheName -> 26.
		#OpenLog -> 27.
		#ReadBytes -> 28.
		#WriteBytes -> 29.
		#Remove -> 30.
		#Move -> 31
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> followType [
	^ {#OneByte -> 16r01 . #TwoBytes -> 16r02. #FourBytes -> 16r03. #TerminatedString -> 16r00. #TerminatedString2 -> 16r04} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> inputSubCodes [ 
	^ {
		#GetFormat -> 2.
 		#CalMinMax -> 3.
 		#CalDefault -> 4.
		#GetTypeMode -> 5.
		#GetSymbol -> 6.
		#CalMin -> 7.
		#CalMax -> 8.
		#Setup -> 9.
		#ClearAll -> 10.
		#GetRaw -> 11.
		#GetConnection -> 12.
		#StopAll -> 13.
		#GetName -> 21.
		#GetModeName -> 22.
		#SetRaw -> 23.
		#GetFigures -> 24.
		#GetChanges -> 25.
		#ClrChanges -> 26.
		#ReadyPCT -> 27.
		#ReadyRaw -> 28.
		#ReadySI -> 29.
		#GetMinMax -> 30.
		#GetBumps -> 31
 	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> memorySubCodes [ 
	^ {
		#Delete -> 0.
		#Create8 -> 1.
		#Create16 -> 2.
		#Create32 -> 3.
		#CreateTEF -> 4.
		#Resize -> 5.
		#Fill -> 6.
		#Copy -> 7.
		#Init8 -> 8 . 
		#Init16 -> 9.
		#Init32 -> 10.
		#InitF -> 11 . 
		#Size -> 12
	} asDictionary
]

{ #category : #'instance creation' }
Ev3Command class >> newGlobal: anIntGlobal local: anIntLocal sequence: anIntSeq reply: aBool [

	|newCmd firstByte secondByte |
	newCmd := self new.
	"newCmd systemCommand: (Ev3SystemCommand systemCommand at: #None).	"
	newCmd commandType: (Ev3BrickCommand commandType at: #DirectCommand).
	newCmd sequenceNumber: anIntSeq.
	newCmd appendInt16: anIntSeq.
	
	aBool ifTrue:[
		newCmd replyRequired: true.
		newCmd appendByte: newCmd commandType.
	] ifFalse:[
		newCmd replyRequired: false.
		newCmd appendByte: (newCmd commandType | 16r80).
	].
	firstByte := anIntGlobal & 16rFF.
	secondByte := (anIntLocal << 2) | (anIntGlobal >> 8).
	newCmd appendByte: firstByte.
	newCmd appendByte: secondByte.
	
	^newCmd
]

{ #category : #accessing }
Ev3Command class >> parameterFormat [
	^ { 	#Short -> 16r00. #Long -> 16r80 } asDictionary.
]

{ #category : #accessing }
Ev3Command class >> parameterType [
	^ { #Constant -> 16r00. #Variable -> 16r40  } asDictionary.
]

{ #category : #accessing }
Ev3Command class >> programSlots [ 
	^ {#Gui -> 0.#User -> 1.	#Cmd -> 2.	 #Term -> 3. #Debug -> 4.	#Current -> -1} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> shortSign [
	^ {#Positive -> 16r00 . #Negative -> 16r20} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> shortValueMax [
	^ 31
]

{ #category : #accessing }
Ev3Command class >> shortValueMin [
	^ -32.
]

{ #category : #accessing }
Ev3Command class >> soundSubCodes [

	^{#Break -> 0.
 		#Tone -> 1.
 		#Play -> 2.
 		#Repeat -> 3.
 		#Service -> 4 
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> uiButtonSubCodes [

	^{#Pressed -> 16r09
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> uiDrawSubCodes [

	^{#Update -> 16r00.
		#Clean -> 16r01.
		#Pixel -> 16r02.
		#Line -> 16r03.
		#Circle -> 16r04.
		#Text -> 16r05.
		#FillRect -> 16r09.
		#Rect -> 16r0a.
		#InverseRect -> 16r10.
		#SelectFont -> 16r11.
		#Topline -> 16r12.
		#FillWindow -> 16r13.
		#DotLine -> 16r15.
		#FillCircle -> 16r18.
		#BmpFile -> 16r1c
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> uiReadSubCodes [

	^{#GetFirmware -> 16r0a
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> uiWriteSubCodes [

	^{#Led -> 16r1b
	} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> variableScope [
	^ {#Local -> 16r00 . #Global -> 16r20} asDictionary.
]

{ #category : #accessing }
Ev3Command class >> variableType [

	^ {#Value -> 16r00. #Handle -> 16r10} asDictionary.
]

{ #category : #building }
Ev3Command >> addInt16Value: anInt [
	"value from -32767 to +32767"
	self appendUInt16: anInt constantParameterType: (Ev3Command constantParameterType at: #Value).
]

{ #category : #building }
Ev3Command >> addInt32Value: anInt [
	"value from -2147483647 to +2147483647"
	self appendUInt32: anInt constantParameterType: (Ev3Command constantParameterType at: #Value).
]

{ #category : #building }
Ev3Command >> addLongByteGlobalVariableAtAddress: anInt [
	
	
	data nextPutAll: (16re0 printStringBase: 16 nDigits: 2).
	self appendByte: anInt
]

{ #category : #building }
Ev3Command >> addLongByteLocalVariableAtAddress: anInt [
	
	
	data nextPutAll: (16rc0 printStringBase: 16 nDigits: 2).
	self appendByte: anInt
]

{ #category : #building }
Ev3Command >> addLongByteValue: anInt [
	"value from -127 to +127"
	self appendSByte: anInt parameterFormat: (Ev3Command parameterFormat at: #Long).
]

{ #category : #building }
Ev3Command >> addLongUInt16GlobalVariableAtAddress: anInt [
	
	
	data nextPutAll: (16re1 printStringBase: 16 nDigits: 2).
	self appendUInt16: anInt
]

{ #category : #building }
Ev3Command >> addLongUInt16LocalVariableAtAddress: anInt [
	
	
	data nextPutAll: (16rc1 printStringBase: 16 nDigits: 2).
	self appendUInt16: anInt
]

{ #category : #building }
Ev3Command >> addLongUInt32GlobalVariableAtAddress: anInt [
	
	
	data nextPutAll: (16re2 printStringBase: 16 nDigits: 2).
	self appendUInt32: anInt
]

{ #category : #building }
Ev3Command >> addLongUInt32LocalVariableAtAddress: anInt [
	
	
	data nextPutAll: (16rc2 printStringBase: 16 nDigits: 2).
	self appendUInt32: anInt
]

{ #category : #building }
Ev3Command >> addShortByteGlobalVariableAtAddress: anInt [
	"value from -127 to +127"
	self appendByte: anInt scope: (Ev3Command variableScope at: #Global).
]

{ #category : #building }
Ev3Command >> addShortByteLocalVariableAtAddress: anInt [
	"value from -127 to +127"
	self appendByte: anInt scope: (Ev3Command variableScope at: #Local).
]

{ #category : #building }
Ev3Command >> addShortValue: anInt [
	"value from -31 to +31"
	self appendSByte: anInt parameterFormat: (Ev3Command parameterFormat at: #Short).
]

{ #category : #internal }
Ev3Command >> appendByte: aByte scope: aVariableScope [

	|b|
	b  := ((Ev3Command parameterFormat at:#Short)| (Ev3Command parameterType at:#Variable) | aVariableScope | (aByte & 16r1f)).
	self appendByte: b.
]

{ #category : #internal }
Ev3Command >> appendConstant: aType follow: aFollowValue [
	
	|b|
	b := ((Ev3Command parameterFormat at: #Long) | (Ev3Command parameterType at: #Constant) | aType | aFollowValue).
	self appendByte: b.
]

{ #category : #internal }
Ev3Command >> appendSByte: aByte parameterFormat: format [
	| b value |
	value := aByte.
	format = (Ev3Command parameterFormat at: #Short)
		ifTrue: [ 
			b := 16r00.
			value < 0
				ifTrue: [ 
					value := value max: self class shortValueMin.
					b := format | (Ev3Command parameterType at: #Constant) | (value & 16r1f).
					b := (Ev3Command shortSign at: #Negative) | b ]
				ifFalse: [ 
					value := value min: self class shortValueMax.
					b := format | (Ev3Command parameterType at: #Constant) | (value & 16r1f).
					b := (Ev3Command shortSign at: #Positive) | b ].
			self appendByte: b ]
		ifFalse: [ 
			b := format | (Ev3Command parameterType at: #Constant) | (Ev3Command constantParameterType at: #Value)
				| (Ev3Command followType at: #OneByte).
			self appendByte: b.
			self appendByte: value ]
]

{ #category : #internal }
Ev3Command >> appendUInt16: anInt constantParameterType: aType [

	self appendConstant: aType follow: (Ev3Command followType at: #TwoBytes).
	self appendUInt16: anInt.
]

{ #category : #internal }
Ev3Command >> appendUInt32: anInt constantParameterType: aType [

	self appendConstant: aType follow: (Ev3Command followType at: #FourBytes).
	self appendUInt32: anInt.
]

{ #category : #building }
Ev3Command >> isDirectCommand [

	^ true
]

{ #category : #building }
Ev3Command >> isSystemCommand [

	^ false
]
