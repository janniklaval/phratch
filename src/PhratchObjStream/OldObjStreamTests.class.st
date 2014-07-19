"
Tests ObjStream separately from Phratch.
"
Class {
	#name : #OldObjStreamTests,
	#superclass : #TestCase,
	#category : #'PhratchObjStream-Tests'
}

{ #category : #tests }
OldObjStreamTests >> phratchObjectsFrom: aFileName [
	"Read a Phratch project from the file with the given name and answer the objects array."

	| f version objects |
	f := (FileStream readOnlyFileNamed: aFileName) binary.
	version := ObjStream phratchFileVersionFrom: (f next: 10) asString.
	version = 0 ifTrue: [
		f position: 0.
		objects := ObjStream new oldReadObjFrom: f].
	(version = 1) | (version = 2) ifTrue: [
		f skip: f uint32.  "skip header"
		objects := ObjStream new readObjsFrom: f].
	f close.
	^ objects

]
