"
Tests ObjStream separately from Phratch.
"
Class {
	#name : #ObjStreamTests,
	#superclass : #TestCase,
	#category : #'PhratchObjStream-Tests'
}

{ #category : #tests }
ObjStreamTests >> equalityTest: inObj [
	"For testing. Serialize and deserialize the given object and compare the result for equality with the original object."

	| outObj |
	outObj := self serializeAndDeserialize: inObj.
	self assert: (outObj class == inObj class).
	self assert: (outObj = inObj)
]

{ #category : #tests }
ObjStreamTests >> formEqualityTest: inForm [
	"For testing. Serialize and deserialize the given form and compare the result for equality with the original."

	| outForm |
	outForm := self serializeAndDeserialize: inForm.
	self assert: (outForm class == inForm class).
	self assert: (((outForm extent = inForm extent) &
	 (outForm depth = inForm depth) &
	 (outForm bits = inForm bits) &
	 (outForm offset = inForm offset))).
	(inForm isKindOf: ColorForm) ifTrue: [
		self assert: (inForm colors = outForm colors)
	].

]

{ #category : #tests }
ObjStreamTests >> phratchObjectsFrom: aFileName [
	"Read a Phratch project from the file with the given name and answer the objects array."

	| f version objects |
	f := (FileStream readOnlyFileNamed: aFileName) binary.
	version := ObjStream phratchFileVersionFrom: (f next: 10) asString.
	version = 0 ifTrue: [
		f position: 0.
		objects := ObjStream new readObjFrom: f].
	(version = 1) | (version = 2) ifTrue: [
		f skip: f uint32.  "skip header"
		objects := ObjStream new readObjsFrom: f].
	f close.
	^ objects

]

{ #category : #tests }
ObjStreamTests >> serializeAndDeserialize: anObject [
	"For testing. Serialize and de-serialize the given object and answer the result."

	| stream |
	stream := WriteStream on: ByteArray new.
	ObjStream new storeObj: anObject on: stream showProgress: false.
	^ ObjStream new readObjFrom: (ReadStream on: stream contents)

]

{ #category : #tests }
ObjStreamTests >> testFixedFormatClass [
	"Test conversions for fixed-format objects."

	| shared |
	self equalityTest: #().
	self equalityTest: #(1 2 3).
	self equalityTest: (Array with: nil with: true with: false).
	self equalityTest: #(123 -123 123456 -123456 123456789000 -123456789000 3.14159).
	self equalityTest: 'hello'.
	self equalityTest: 'hello' asSymbol.
	self equalityTest: #(1 2 3) asByteArray.
	self equalityTest: (String withAll: 'hello').

	self equalityTest: (SoundBuffer fromArray: #(1 2 3 4)).
	self equalityTest: (Bitmap withAll: #(0 1 2 2147483647 2147483648 4294967295)).

	self equalityTest: #(1 2 3) asOrderedCollection.
	self equalityTest: #(1 2 3) asSet.
	self equalityTest: (IdentitySet new addAll: #(1 2 3); yourself).
	self equalityTest: (Dictionary new at: 1 put: 'a'; at: 'b' put: 2; yourself).
	self equalityTest: (IdentityDictionary new at: 1 put: 1; at: 2 put: 2; yourself).

	self equalityTest: (Color gray: 0.3).
	self equalityTest: (Color red alpha: 0.5).
	self equalityTest: 2 @ 3.14159.
	self equalityTest: (0@0 extent: 2.5@2.5).
	self formEqualityTest: (Form fromDisplay: (0@0 extent: 10@10)).
	self formEqualityTest: ((Form fromDisplay: (0@0 extent: 10@10)) colorReduced).

	shared := 1.
	self equalityTest: (Point x: shared y: shared).
	self equalityTest: ((Point x: shared y: shared) corner: (Point x: shared y: shared)).
	self equalityTest: (OrderedCollection with: shared with: shared).
	self equalityTest: (Array with: shared with: (Set new add: shared; yourself)).
	self equalityTest: (Dictionary new at: shared put: shared; at: 'b' put: shared; yourself).
	self equalityTest: (IdentityDictionary new at: shared put: shared; at: 2 put: shared; yourself).

	self inform: 'Fixed-format tests passed.'.

]

{ #category : #tests }
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

{ #category : #tests }
ObjStreamTests >> testUserClass [
	"Test conversions for fixed-format objects."
	"self initialize; userClassTests"

	| userClassList suspectClasses |
	userClassList := (ObjStream userClasses collect: [:rec | Smalltalk at: rec second ifAbsent:[]]) reject:[:e | e = nil].
	userClassList := userClassList reject: [:cl | (cl inheritsFrom: BlockMorph) | (cl inheritsFrom: ArgMorph)].
	userClassList do: [:cl | 
		self assert: (cl = (self serializeAndDeserialize: cl new) class)].

	suspectClasses := userClassList select: [:cl |
		(cl includesSelector: #fieldsVersion) not and: [cl instVarNames size > 0]].
	self assert: suspectClasses size = 0.
]

{ #category : #tests }
ObjStreamTests >> writeTestFile [
	"self writeTestFile"

	| all objects s |
	all := OrderedCollection new.
	all add: true.
	all add: false.
	all add: 12345.
	all add: 123.
	all add: 123456789123456789.
	all add: -123456789123456789.
	all add: 123.546.
	all add: 'This is a string.'.
	all add: #thisIsASymbol.
	all add: #(100 101 102 253 254 255) asByteArray.
	all add: ScriptablePhratchMorph popSound samples.
	all add: (ImageMorph defaultForm asFormOfDepth: 32) bits.
	all add: (Array with: 1 with: 2 with: 3).
	all add: (Array with: 1 with: 2 with: 3) asOrderedCollection.
	all add: (Array with: 1 with: 2 with: 3) asSet.
	all add: (IdentitySet withAll: (Array with: 1 with: 2 with: 3)).
	all add: (Dictionary new at: 'John' put: 'Maloney'; at: 'Lise' put: 'Kreps'; yourself).
	all add: (IdentityDictionary new at: #John put: 'Maloney'; at: #Lise put: 'Kreps'; yourself).
	all add: (Color gray: 0.5).
	all add: (Color red alpha: 0.5).
	all add: 1@2.0.
	all add: (9.5@20 extent: 30@40).
	all add: (ImageMorph defaultForm asFormOfDepth: 32).
	all add: ImageMorph defaultForm.

	objects := (Array with: nil), all asArray.
	s := (FileStream newFileNamed: 'test.obj') binary.
	ObjStream new storeObj: objects on: s.
	s close.

]