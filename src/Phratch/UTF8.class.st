"
I represent a Unicode string encoded as a sequence of 8-bit bytes using UTF-8 encoding.

"
Class {
	#name : #UTF8,
	#superclass : #String,
	#type : #bytes,
	#category : #'Phratch-Translation'
}

{ #category : #utilities }
UTF8 class >> byteOrderMark [
	"Return the UTF8 byte order mark. This is a non-printing 3-byte Unicode character sometimes used to indicate that a string is encoded as UTF8."

	^ UTF8 withAll: #(239 187 191) asByteArray asString

]

{ #category : #utilities }
UTF8 class >> encode: n on: aStream [
	"Append the UTF-8 encoding of the given integer onto the given stream."

	n < 0 ifTrue: [^ self error: 'UTF-8 cannot represent: ', n printString, ' (negative)'].
	n < 128 ifTrue: [aStream nextPut: n. ^ self].
	n < 2048 ifTrue: [
		aStream nextPut: (2r11000000 bitOr: (n bitShift: -6)).
		aStream nextPut: (2r10000000 bitOr: (n bitAnd: 2r111111)).
		^ self].
	n < 65536 ifTrue: [
		aStream nextPut: (2r11100000 bitOr: (n bitShift: -12)).
		aStream nextPut: (2r10000000 bitOr: ((n bitShift: -6) bitAnd: 2r111111)).
		aStream nextPut: (2r10000000 bitOr: (n bitAnd: 2r111111)).
		^ self].
	n < 16r110000 ifTrue: [
		aStream nextPut: (2r11110000 bitOr: (n bitShift: -18)).
		aStream nextPut: (2r10000000 bitOr: ((n bitShift: -12) bitAnd: 2r111111)).
		aStream nextPut: (2r10000000 bitOr: ((n bitShift: -6) bitAnd: 2r111111)).
		aStream nextPut: (2r10000000 bitOr: (n bitAnd: 2r111111)).
		^ self].

	self error: 'UTF-8 cannot represent: ', n printString, ' (out of range)'

]

{ #category : #utilities }
UTF8 class >> from: aCollection [
	"Answer a new UTF-8 string resulting from encoding the given sequence of positive integers (e.g. a UTF32 object or an Array of Unicode codepoints)."
	"self from: #(1 2 3 1000)"

	| out |
	out := WriteStream on: (ByteArray new: (4 * aCollection size)).
	aCollection do: [:n | self encode: n on: out].
	^ UTF8 withAll: out contents

]

{ #category : #utilities }
UTF8 class >> fromMacRoman: aString [
	"Convert the given MacRoman-encoded String into UTF-8."
	"(UTF8 fromMacRoman: (0 to: 255) asByteArray asString) asUTF32"

	| macRomanToUnicode out n |
	macRomanToUnicode := #(196 197 199 201 209 214 220 225 224 226 228 227 229 231 233 232 234 235 237 236 238 239 241 243 242 244 246 245 250 249 251 252 8224 176 162 163 167 8226 182 223 174 169 8482 180 168 8800 198 216 8734 177 8804 8805 165 181 8706 8721 8719 960 8747 170 186 937 230 248 191 161 172 8730 402 8776 8710 171 187 8230 160 192 195 213 338 339 8211 8212 8220 8221 8216 8217 247 9674 255 376 8260 8364 8249 8250 64257 64258 8225 183 8218 8222 8240 194 202 193 203 200 205 206 207 204 211 212 63743 210 218 219 217 305 710 732 175 728 729 730 184 733 731 711).

	aString isUnicode ifTrue: [^ aString asUTF8].

	out := WriteStream on: (ByteArray new: (4 * aString size)).
	aString do: [:ch |
		n := ch asciiValue.
		n > 127 ifTrue: [n := macRomanToUnicode at: (n - 127)].
		self encode: n on: out].
	^ UTF8 withAll: out contents

]

{ #category : #'hacking (spfa)' }
UTF8 class >> withAll: aCharacter [

	^ String withAll: aCharacter
]

{ #category : #comparing }
UTF8 >> = aStringOrUTF8 [ 
	"Answer whether the receiver has the exact same contents as the argument."

	(aStringOrUTF8 isKindOf: String) ifFalse: [^ false].

	^ (self compare: self with: aStringOrUTF8 collated: AsciiOrder) = 2
]

{ #category : #converting }
UTF8 >> asByteArray [
	"Convert to a ByteArray."

	^ (ByteArray new: self size) replaceFrom: 1 to: self size with: self

]

{ #category : #converting }
UTF8 >> asMacRoman [
	"Answer the receiver as a String encoded as well as possible in the MacRoman character set. This transformation loses information if the string contains characters outside of the MacRoman character set."

	^ self asUTF32 asMacRoman

]

{ #category : #converting }
UTF8 >> asUTF32 [
	"Answer this Unicode string encoded as UTF-32."

	| s out n |
	s := UTF8Decoder new on: self.
	out := WriteStream on: (UTF32 new: self size).
 	[(n := s next) notNil] whileTrue: [out nextPut: n].
	^ out contents

]

{ #category : #converting }
UTF8 >> asUTF8 [

	^ self

]

{ #category : #accessing }
UTF8 >> atAllPut: value [
	"Fill the receiver with the given value."

	<primitive: 145>
	super atAllPut: value.

]

{ #category : #accessing }
UTF8 >> byteAt: index [

	<primitive: 60>
	^ self at: index

]

{ #category : #accessing }
UTF8 >> byteAt: index put: value [

	<primitive: 61>
	^ self at: index put: value

]

{ #category : #accessing }
UTF8 >> isMacRoman [
	"Answer true if I contain only characters from Squeak's Mac Roman character set."

	| decoder uChar |
	decoder := UTF8Decoder new on: self.
 	[(uChar := decoder next) notNil] whileTrue: [
		(UTF32 macRomanFor: uChar) = 127 ifTrue: [^ false]].
	^ true

]

{ #category : #accessing }
UTF8 >> isUnicode [
	"Answer true if I represent a Unicode string."

	^ true

]

{ #category : #printing }
UTF8 >> printOn: aStream [

	aStream nextPutAll: 'UTF8['.
	self isMacRoman
		ifTrue: [aStream nextPut:$'; nextPutAll: self asMacRoman; nextPut: $']
		ifFalse: [aStream nextPutAll: self size printString].
	aStream nextPutAll: ']'.


]

{ #category : #private }
UTF8 >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart.

]

{ #category : #private }
UTF8 >> species [

	^ UTF8

]
