"
Used to decode at UTF-8 string.

"
Class {
	#name : #UTF8Decoder,
	#superclass : #Object,
	#instVars : [
		'utf8',
		'byteIndex'
	],
	#category : #'Phratch-Translation'
}

{ #category : #accessing }
UTF8Decoder >> atEnd [

	^ byteIndex > utf8 size

]

{ #category : #accessing }
UTF8Decoder >> byteIndex [

	^ byteIndex

]

{ #category : #accessing }
UTF8Decoder >> byteIndex: anInteger [

	byteIndex := anInteger.

]

{ #category : #accessing }
UTF8Decoder >> next [
	"Answer the next Unicode character value. Decode multibyte characters and advance the byteIndex to the start of the next Unicode character. Answer nil if at end."

	| b out |
	"find start of next Unicode character in rare case of malformed UTF-8"
	[byteIndex <= utf8 size and:
	 [((utf8 byteAt: byteIndex) bitShift: -6) = 2r10]] whileTrue: [
		byteIndex := byteIndex + 1].

	byteIndex > utf8 size ifTrue: [^ nil].

	b := utf8 byteAt: byteIndex.
	b < 128 ifTrue: [
		 byteIndex := byteIndex + 1.
		^ b].

	b < 16rE0 ifTrue: [
		(byteIndex + 1) > utf8 size ifTrue: [^ nil].
		out := ((b bitAnd: 31) << 6) +
				((utf8 byteAt: byteIndex + 1) bitAnd: 63).
		byteIndex := byteIndex + 2.
		^ out].

	b < 16rF0 ifTrue: [
		(byteIndex + 2) > utf8 size ifTrue: [^ nil].
		out := ((b bitAnd: 15) << 12) +
				(((utf8 byteAt: byteIndex + 1) bitAnd: 63) << 6) +
				 ((utf8 byteAt: byteIndex + 2) bitAnd: 63).
		byteIndex := byteIndex + 3.
		^ out].

	(byteIndex + 3) > utf8 size ifTrue: [^ nil].
	out := ((b bitAnd: 7) << 18) +
			(((utf8 byteAt: byteIndex + 1) bitAnd: 63) << 12) +
			(((utf8 byteAt: byteIndex + 2) bitAnd: 63) << 6) +
			 ((utf8 byteAt: byteIndex + 3) bitAnd: 63).
	byteIndex := byteIndex + 4.
	^ out

]

{ #category : #accessing }
UTF8Decoder >> on: aUTF8String [

	utf8 := aUTF8String.
	byteIndex := 1.

]
