"
Tests ObjStream separately from Phratch.
"
Class {
	#name : #ObjStreamTests,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #'as yet unclassified' }
ObjStreamTests >> testStoreDictionary [
	"Failing test for storing and reading dictionaries."
	
	| stream objstreamer d d2 |
	stream := FileStream fileNamed: '_test.out'.
	stream binary.
	objstreamer := ObjStream new.
	d := Dictionary new.
	d at: 'score' put: 10.
	objstreamer storeObj: d on: stream.
	stream close.
	
	"Now try and read back the object"
	stream := FileStream readOnlyFileNamed: '_test.out'.
	stream binary.
	objstreamer := ObjStream new.
	d2 := objstreamer readObjFrom: stream.
	stream close.
	
	self assert: (d = d2).
]
