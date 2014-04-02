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

	"changed for the prototype -Jens"

	(aString beginsWith: 'BloxExpV') 
		ifTrue: [ScriptablePhratchMorph decodeAsByob]
		ifFalse: [ScriptablePhratchMorph decodeAsScratch].
		
	(aString beginsWith: 'PhratchV') 
		ifTrue: [ScriptablePhratchMorph decodeAsPhratch].

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
	objects := "showProgress
		ifTrue: [ (FLMaterializer newDefault materializeFrom: aStream) root	 showProgress; ]
		ifFalse: [ "(FLMaterializer newDefault materializeFrom: aStream) root "]".
	^ objects
]

{ #category : #'entry points' }
FuelObjStream >> readSpriteFrom: aStream showProgress: showProgress [
	"Read the root object from the given binary stream. If showProgress is true, display a progress bar."

	| objCount tenPercent stream |
	objects := OrderedCollection new.
	"stream := FLMaterializer newDefault materializeFrom: aStream."
	stream := aStream.
	self readFileHeader: aStream.
	objCount := stream uint32.
	showProgress
		ifTrue: [
			tenPercent := objCount // 10.
			('Reading...' localized, '...')
				displayProgressAt: Display center - (32@5)  "Sensor cursorPoint"
				from: 0 to: objCount + tenPercent
				during: [:progressBar |
					1 to: objCount do: [:i |
						objects addLast: self readObjectRecord.
						progressBar value: i].
					objects do: [:rec | self fixReferencesForObjectRecord: rec].
					progressBar value: objCount + (tenPercent // 2).
					objects do: [:rec | self initializeUserDefinedFields: rec].
					progressBar value: objCount + tenPercent.
					(Delay forMilliseconds: 200) wait]]
		ifFalse: [
			objCount timesRepeat: [objects addLast: self readObjectRecord].
			objects do: [:rec | self fixReferencesForObjectRecord: rec].
			objects do: [:rec | self initializeUserDefinedFields: rec]].

	^ objects first first
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
