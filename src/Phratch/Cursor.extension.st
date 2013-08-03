Extension { #name : #Cursor }

{ #category : #'*Phratch-Extensions' }
Cursor class >> eyeDropper [
	"Cursor eyeDropper showWhile: [Sensor waitButton]"

	| cursor |
	cursor := CursorWithMask
		fromArray: #(14 31 31 255 126 184 280 552 1088 2176 4352 8704 17408 18432 45056 16384)
		offset: 0@(-14).
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(917504 2031616 2031616 16711680 8257536 16252928 33030144 65536000 130023424 260046848 520093696 1040187392 2080374784 2013265920 4026531840 3221225472)
		offset: 0@0).
	^ cursor
]

{ #category : #'*Phratch-Extensions' }
Cursor class >> fromArray: anArray offset: offsetPoint [
	"Answer a new 16x16 cursor offset by offsetPoint and and filled with bits from anArray.
	NOTE: This method takes an array of 16-bit values and left-shifts by 16-bits so they are left-justified in a 32-bit bitmap."

	^ super
		extent: 16@16
		fromArray: (anArray collect: [:bits | bits bitShift: 16])
		offset: offsetPoint

]

{ #category : #'*Phratch-Extensions' }
Cursor class >> handClosed [
	"Cursor handOpen showWhile: [Sensor waitButton].
	 Cursor handClosed showWhile: [Sensor waitNoButton]"

	| cursor |
	cursor := CursorWithMask
		fromArray: #(0 0 0 448 3704 4686 4105 14337 18434 16386 8194 8196 4100 2056 1032 1032)
		offset: -8@(-8).
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(0 0 0 29360128 267911168 536739840 536805376 1073676288 2147352576 2147352576 1073610752 1073479680 536608768 267911168 133693440 133693440)
		offset: 0@0).
	^ cursor
]

{ #category : #'*Phratch-Extensions' }
Cursor class >> handOpen [
	"Cursor handOpen showWhile: [Sensor waitButton]"

	| cursor |
	cursor := CursorWithMask
		fromArray: #(384 6768 9800 9802 4685 4681 26633 38913 34818 16386 8194 8196 4100 2056 1032 1032)
		offset: -8@(-8).
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(25165824 468713472 1073217536 1073348608 536805376 536805376 1878982656 4294901760 4294836224 2147352576 1073610752 1073479680 536608768 267911168 133693440 133693440)
		offset: 0@0).
	^ cursor

]

{ #category : #'*Phratch-Extensions' }
Cursor class >> paintBucket [
	"Cursor paintBucket showWhile: [Sensor waitButton]"

	| cursor |
	cursor := CursorWithMask
		fromArray: #(896 1088 1216 1376 1624 1102 2119 4259 8259 16391 16395 8211 4131 2115 1154 768)
		offset: -14@(-15).
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(58720256 130023424 130023424 132120576 133693440 134086656 268369920 536805376 1073676288 2147418112 2147155968 1072889856 534970368 264437760 125960192 50462720)
		offset: 0@0).
	^ cursor

]

{ #category : #'*Phratch-Extensions' }
Cursor class >> resizeCorner [

	^ Cursor 
		fromArray: #(
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r1111100000000000
			2r1111000000000000
			2r1110000000000000
			2r1101000000000000
			2r1000100000000000
			2r0000010001000000
			2r0000001011000000
			2r0000000111000000
			2r0000001111000000
			2r0000011111000000
			2r0000000000000000
			2r0000000000000000)
		offset: -5@(-5)
]

{ #category : #'*Phratch-Extensions' }
Cursor class >> resizeHorizontally [

	^ Cursor 
		fromArray: #(
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0001000000100000
			2r0011000000110000
			2r0111000000111000
			2r1111111111111100
			2r0111000000111000
			2r0011000000110000
			2r0001000000100000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000)
		offset: -5@(-5)

]
