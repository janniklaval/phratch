Class {
	#name : #FuelObjStream,
	#superclass : #Object,
	#instVars : [
		'objects'
	],
	#category : #'Phratch-Object IO'
}

{ #category : #testing }
FuelObjStream class >> phratchFileVersionFrom: aString [
	"Answer the Phratch file version number from the given string. If the string is of the form: 'ScratchVxx', were xx is a two-digit integer, answer the value of xx. Otherwise, answer 0."

	"changed for the BYOB-prototype -Jens"

	((aString beginsWith: 'BloxExpV') | (aString beginsWith: 'PhratchV')) 
		ifTrue: [ScriptablePhratchMorph decodeAsByob]
		ifFalse: [ScriptablePhratchMorph decodeAsScratch].

	((aString beginsWith: 'BloxExpV') 
		or: [(aString beginsWith: 'ScratchV') or: [aString beginsWith: 'PhratchV']]) ifFalse: [^ 0].
	^ (aString copyFrom: 9 to: aString size) asNumberNoError

]

{ #category : #'private-reading' }
FuelObjStream >> readFileHeader: aStream [
	"Read the file header on my stream."

	(((aStream next: 4) asString = 'ObjS') &
	 (aStream next = 1) &
	 ((aStream next: 4) asString = 'Stch') &
	 (aStream next = 1))
	 ifFalse: [
		self error: 'bad header'].

]

{ #category : #'entry points' }
FuelObjStream >> readObjFrom: aStream [
	"Read the root object from the given binary stream."

	^ self readObjFrom: aStream showProgress: false

]

{ #category : #'entry points' }
FuelObjStream >> readObjFrom: aStream showProgress: showProgress [
	"Read the root object from the given binary stream. If showProgress is true, display a progress bar."

	self readFileHeader: aStream.
	objects := showProgress
		ifTrue: [ (FLMaterializer newDefault materializeFrom: aStream) root	"showProgress;" ]
		ifFalse: [ (FLMaterializer newDefault materializeFrom: aStream) root ].
	^ objects
]

{ #category : #'entry points' }
FuelObjStream >> storeObj: anObject on: aStream [
	"Write the given object and all the objects that can be reached from it on the given binary stream. Do not display a progress bar."

	self storeObj: anObject on: aStream showProgress: false.

]

{ #category : #'entry points' }
FuelObjStream >> storeObj: anObject on: aStream showProgress: showProgress [
	"Write the given object and all the objects that can be reached from it on the given binary stream. If showProgress is true, display a progress bar."

	self writeFileHeaderOn: aStream.
	objects := showProgress
		ifTrue: [ 
			FLSerializer newDefault
				showProgress;
				serialize: anObject on: aStream ]
		ifFalse: [ FLSerializer newDefault serialize: anObject on: aStream ].
	^ objects
]

{ #category : #'private-writing' }
FuelObjStream >> writeFileHeaderOn: aStream [
	"Write the file header on my stream."

	aStream nextPutAll: 'ObjS' asByteArray.
	aStream nextPut: 1.
	aStream nextPutAll: 'Stch' asByteArray.
	aStream nextPut: 1.

]
