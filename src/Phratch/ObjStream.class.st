"
I can serialize a collection of inter-connected objects onto a binary stream or reconstruct the original object network from its serialized form. This allows object structures to be saved in files, transmitted over a network, etc.

I support user class evolution via class version numbers, making it possible to detect and, if so desired, convert old object formats.

The format consists of a table of serialized objects. The first object in this table is the ""root"" object that was serialized; the rest of the objects in the table are objects reachable from this root object. Inter-object references are stored as indices into this table. These indices are mapped to actual object references when the structure is deserialized.

Object storage formats fall into one of these categories:
  a. immediate values: the constants nil, true, false, integers, and floats
  b. fixed-format objects whose serialization is handled by this class
  c. objects that handle their own serialization and whose formats may change over time

Objects in the first category are encoded in-line; they do not appear in the object table and thus cannot be shared. Integers that small enough to be represented in 16 bits have their own format. Objects in the second catetory are assumed to have stable storage formats, so they do not have a class version number. In the unlikely event that the storage format of any of these classes changes, the file format version must be incremented.

Objects in the last category support user-defined serialization. They are expected to implement the three instance methods storeFieldsOnXX:, initializeFromFieldsXX:, and objStreamVersion, where XX is the class version number. In general, any change to the serialization format of an object requires adding new versions of the methods storeFieldsOnXX: and initializeFromFieldsXX:, then incrementing the version number returned by objStreamVersion.

The class of every object in this category must appear in the class ID table. To ensure that old object files can be read, once an object has been assigned an ID that ID can't be changed and even if the class is deleted, it's ID must not used for another class.

Maximums:
  Object types (i.e., classes): 255
  User-defined class fields: 255
  Number of objects: 2^24 - 1
  Indexable object size: 2^32 - 1

"
Class {
	#name : #ObjStream,
	#superclass : #Object,
	#instVars : [
		'objects',
		'objectIndex',
		'stream',
		'firstPass',
		'fields',
		'fieldIndex',
		'toDo'
	],
	#classVars : [
		'FirstPointerClassID',
		'FloatClassID',
		'IDToClassEntry',
		'NameToClassEntry',
		'ObjectReferenceID'
	],
	#category : #'Phratch-Object IO'
}

{ #category : #testing }
ObjStream class >> equalityTest: inObj [
	"For testing. Serialize and deserialize the given object and compare the result for equality with the original object."

	| outObj |
	outObj := self serializeAndDeserialize: inObj.
	outObj class == inObj class ifFalse: [self error: 'output class is not equal to input class'].
	outObj = inObj ifFalse: [self error: 'output is not equal to input'].

]

{ #category : #testing }
ObjStream class >> fixedFormatClassTests [
	"Test conversions for fixed-format objects."
	"self initialize; fixedFormatClassTests"

	| shared |
	self equalityTest: #().
	self equalityTest: #(1 2 3).
	self equalityTest: (Array with: nil with: true with: false).
	self equalityTest: #(123 -123 123456 -123456 123456789000 -123456789000 3.14159).
	self equalityTest: 'hello'.
	self equalityTest: 'hello' asSymbol.
	self equalityTest: #(1 2 3) asByteArray.
	self equalityTest: (UTF8 withAll: 'hello').

	self equalityTest: (SoundBuffer fromArray: #(1 2 3 4)).
	self equalityTest: (Bitmap withAll: #(0 1 2 2147483647 2147483648 4294967295)).

	self equalityTest: #(1 2 3) asOrderedCollection.
	self equalityTest: #(1 2 3) asSet.
	self equalityTest: (IdentitySet new addAll: #(1 2 3); yourself).
	self equalityTest: (Dictionary new at: 1 put: 'a'; at: 'b' put: 2; yourself).
	self equalityTest: (IdentityDictionary new at: 1 put: 'a'; at: 'b' put: 2; yourself).

	self equalityTest: (Color gray: 0.3).
	self equalityTest: (Color red alpha: 0.5).
	self equalityTest: 2 @ 3.14159.
	self equalityTest: (0@0 extent: 2.5).
	self formEqualityTest: (Form fromDisplay: (0@0 extent: 10)).
	self formEqualityTest: ((Form fromDisplay: (0@0 extent: 10)) colorReduced).

	shared := #Shared.
	self equalityTest: (Point x: shared y: shared).
	self equalityTest: ((Point x: shared y: shared) corner: (Point x: shared y: shared)).
	self equalityTest: (OrderedCollection with: shared with: shared).
	self equalityTest: (Array with: shared with: (Set new add: shared; yourself)).
	self equalityTest: (Dictionary new at: shared put: shared; at: 'b' put: shared; yourself).
	self equalityTest: (IdentityDictionary new at: shared put: shared; at: 'b' put: shared; yourself).

	self inform: 'Fixed-format tests passed.'.

]

{ #category : #'class initialization' }
ObjStream class >> fixedFormatClasses [
	"Answer an array of records for fixed-format classes."

	^ #(
		"id	class					read selector		write selector"
		(1	UndefinedObject			getConst:id:			putConst:id:)
		(2	True					getConst:id:			putConst:id:)
		(3	False					getConst:id:			putConst:id:)
		(4	SmallInteger			getSmallInt:id:		putSmallInt:id:)
		(5	SmallInteger16			getSmallInt:id:		putSmallInt:id:)  "optimization for ints that fit into 16 bits"
		(6	LargePositiveInteger		getBigInt:id:			putBigInt:id:)
		(7	LargeNegativeInteger	getBigInt:id:			putBigInt:id:)
		(8	Float					getFloat:id:			putFloat:id:)
		(9	String					getBytes:id:			putBytes:id:)
		(10	Symbol					getBytes:id:			putBytes:id:)
		(11	ByteArray				getBytes:id:			putBytes:id:)
		(12	SoundBuffer			getSoundBuf:id:		putSoundBuf:id:)
		(13	Bitmap					getBitmap:id:		putBitmap:id:)
		(14	UTF8					getBytes:id:			putBytes:id:)
											
		(15	ByteString					getBytes:id:			putBytes:id:)			
		(16	ByteSymbol				getBytes:id:			putBytes:id:)			
																																			
	"12-19 reserved for additional non-pointer objects"
		(20	Array					getArray:id:			putArray:id:)
		(21	OrderedCollection		getCollection:id:		putCollection:id:)
		(22	Set						getCollection:id:		putCollection:id:)
		(23	IdentitySet				getCollection:id:		putCollection:id:)
		(24	Dictionary				getDict:id:			putDict:id:)
		(25	IdentityDictionary		getDict:id:			putDict:id:)
		(26	ColorArray				getArray:id:			putArray:id:)
	"27-29 reserved for additional collections"
		(30	Color					getColor:id:			putColor:id:)
		(31	TranslucentColor		getColor:id:			putColor:id:)
		(32	Point					getPoint:id:			putPoint:id:)
		(33	Rectangle				getRect:id:			putRect:id:)
		(34	Form					getForm:id:			putForm:id:)
		(35	ColorForm				getForm:id:			putForm:id:)
	"99 reserved for object references"
	"100-255 reserved for user-defined classes"
	)

]

{ #category : #testing }
ObjStream class >> formEqualityTest: inForm [
	"For testing. Serialize and deserialize the given form and compare the result for equality with the original."

	| outForm |
	outForm := self serializeAndDeserialize: inForm.
	outForm class == inForm class ifFalse: [self error: 'output class is not equal to input class'].
	((outForm extent = inForm extent) &
	 (outForm depth = inForm depth) &
	 (outForm bits = inForm bits) &
	 (outForm offset = inForm offset))
		 ifFalse: [self error: 'output Form is not equal to input Form'].
	(inForm isKindOf: ColorForm) ifTrue: [
		inForm colors = outForm colors
			ifFalse: [self error: 'output colors are not equal to input colors']].

]

{ #category : #'class initialization' }
ObjStream class >> initialize [
	"self initialize"

	ObjectReferenceID := 99.
	IDToClassEntry := Dictionary new.
	NameToClassEntry := Dictionary new.

	self fixedFormatClasses do: [:entry |
		(IDToClassEntry includesKey: entry first) ifTrue: [self error: 'duplicate fixed class ID'].
		IDToClassEntry at: entry first put: entry.
		NameToClassEntry at: entry second put: entry].

	self userClasses do: [:pair | | entry |
		entry := pair, #(unused putUserObj:id:).
		(IDToClassEntry includesKey: entry first) ifTrue: [self error: 'duplicate user class ID'].
		IDToClassEntry at: entry first put: entry.
		NameToClassEntry at: entry second put: entry].

	FloatClassID := (NameToClassEntry at: #Float) first.
	FirstPointerClassID := (NameToClassEntry at: #Array) first.

]

{ #category : #testing }
ObjStream class >> phratchFileVersionFrom: aString [
	"Answer the Phratch file version number from the given string. If the string is of the form: 'ScratchVxx', were xx is a two-digit integer, answer the value of xx. Otherwise, answer 0."

	"changed for the BYOB-prototype -Jens"

	(aString beginsWith: 'BloxExpV') 
		ifTrue: [ScriptablePhratchMorph decodeAsByob]
		ifFalse: [ScriptablePhratchMorph decodeAsScratch].

	((aString beginsWith: 'BloxExpV') 
		or: [aString beginsWith: 'ScratchV']) ifFalse: [^ 0].
	^ (aString copyFrom: 9 to: aString size) asNumberNoError

]

{ #category : #testing }
ObjStream class >> phratchObjectsFrom: aFileName [
	"Read a Phratch project from the file with the given name and answer the objects array."

	| f version objects |
	f := (FileStream readOnlyFileNamed: aFileName) binary.
	version := self phratchFileVersionFrom: (f next: 10) asString.
	version = 0 ifTrue: [
		f position: 0.
		objects := ObjStream new readObjFrom: f].
	(version = 1) | (version = 2) ifTrue: [
		f skip: f uint32.  "skip header"
		objects := ObjStream new readObjsFrom: f].
	f close.
	^ objects

]

{ #category : #testing }
ObjStream class >> serializeAndDeserialize: anObject [
	"For testing. Serialize and de-serialize the given object and answer the result."

	| stream |
	stream := WriteStream on: ByteArray new.
	ObjStream new storeObj: anObject on: stream showProgress: false.
	^ ObjStream new readObjFrom: (ReadStream on: stream contents)

]

{ #category : #testing }
ObjStream class >> tallyPhratchObjectsFrom: aDirectory [
	"Tally the object class ID's for all Phratch projects in the given directory into the given array."
	"self tallyPhratchObjectsFrom: FileDirectory default"

	| classIDCounts objTable id result count cName |
	classIDCounts := Array new: 256 withAll: 0.
	aDirectory fileNames do: [:fn |
		((fn endsWith: '.sb') | (fn endsWith: '.ypr')) ifTrue: [
			objTable := self phratchObjectsFrom: (aDirectory fullNameFor: fn).
			objTable do: [:entry |
				id := entry at: 2.
				classIDCounts at: id put: (classIDCounts at: id) + 1]]].

	result := WriteStream on: String new.
	1 to: classIDCounts size do: [:i |
		count := classIDCounts at: i.
		count > 0 ifTrue: [
			cName := (IDToClassEntry at: i) at: 2.
			result nextPutAll: cName, '	', count printString; cr]].
	^ result contents

]

{ #category : #testing }
ObjStream class >> tallyPhratchObjectsFromFile: aFileName [
	"Read the Phratch project from the file with the given name and tally it's object class IDs."

	| classIDCounts objTable id result count cName |
	classIDCounts := Array new: 256 withAll: 0.
	objTable := self phratchObjectsFrom: aFileName.
	objTable do: [:entry |
		id := entry at: 2.
		classIDCounts at: id put: (classIDCounts at: id) + 1].

	result := WriteStream on: String new.
	1 to: classIDCounts size do: [:i |
		count := classIDCounts at: i.
		count > 0 ifTrue: [
			cName := (IDToClassEntry at: i) at: 2.
			result nextPutAll: cName, '	', count printString; cr]].
	^ result contents


]

{ #category : #testing }
ObjStream class >> userClassTests [
	"Test conversions for fixed-format objects."
	"self initialize; userClassTests"

	| userClassList suspectClasses |
	userClassList := self userClasses collect: [:rec | Smalltalk at: rec second].
	userClassList := userClassList reject: [:cl | (cl inheritsFrom: BlockMorph) | (cl inheritsFrom: ArgMorph)].
	userClassList do: [:cl | self serializeAndDeserialize: cl new].

	suspectClasses := userClassList select: [:cl |
		(cl includesSelector: #fieldsVersion) not and: [cl instVarNames size > 0]].
	suspectClasses size > 0 ifTrue: [^ self error: 'not all classes implement #fieldsVersion'].

	self inform: 'User class tests passed.'.


]

{ #category : #'class initialization' }
ObjStream class >> userClasses [
	"Answer an array of (<class id>, <class name>) records for all version numbered user classes."
	"The following finds obsolete user classes:"
	"self initialize. self userClasses reject: [:rec | Smalltalk includesKey: rec second]"

	^ #(
		"id		class"
		(100		Morph)
		(101		BorderedMorph)
		(102		RectangleMorph)
		(103		EllipseMorph)
		(104		AlignmentMorph)
		(105		#StringMorph)
		(106		#UpdatingStringMorph)
		(107		SimpleSliderMorph)
		(108		SimpleButtonMorph)
		(109		SampledSound)
		(110		ImageMorph)
		(111		SketchMorph)

		"(120	SpriteMorph)"
		"(121		SoundMorph)"
		"(122	ImageBoxMorph)"
		(123		SensorBoardMorph)
		(124		#PhratchSpriteMorph)
		(125		#PhratchStageMorph)

		(140		ChoiceArgMorph)
		(141		ColorArgMorph)
		(142		ExpressionArgMorph)
		"(143	ParameterReferenceMorph)"
		"(144	PositionArgMorph)"
		(145		SpriteArgMorph)
		"(146	VariableArgMorph)"
		(147		BlockMorph)
		(148		CommandBlockMorph)
		(149		CBlockMorph)
		"(150	MethodCallBlockMorph)"
		(151		HatBlockMorph)
		"(152	PhratchButtonMorph)"
		(153		#PhratchScriptsMorph)
		(154		#PhratchSliderMorph)
		(155		WatcherMorph)
		"(156	ParameterMorph)"
		(157		SetterBlockMorph)
		(158		EventHatMorph)
		"(159	EventArgMorph)"
		(160		VariableBlockMorph)
		"(161		IACTHatBlock)"
		(162		ImageMedia)
		(163		MovieMedia)
		(164		SoundMedia)
		(165		KeyEventHatMorph)
		(166		BooleanArgMorph)
		(167		EventTitleMorph)
		(168		MouseClickEventHatMorph)
		(169		ExpressionArgMorphWithMenu)
		(170		ReporterBlockMorph)
		(171		MultilineStringMorph)
		(172		ToggleButton)
		(173		WatcherReadoutFrameMorph)
		(174		WatcherSliderMorph)
		(175		#PhratchListMorph)
		(176		ScrollingStringMorph)

		(180		ScrollFrameMorph2)
		(181		ListMultilineStringMorph)
		(182		#PhratchScrollBar)

		(200		CustomCommandBlockMorph)
		(201		CustomBlockDefinition)
		(202		CommandScriptBlockMorph)
		(203		ReporterScriptBlockMorph)
		"(204		ListMakerBlockMorph)"
		(205		VariableFrame)
		(206		CustomReporterBlockMorph)

		(207		CReporterSlotMorph)

		(300		StringFieldMorph)
		(301		MultiArgReporterBlockMorph)

	)


]

{ #category : #testing }
ObjStream class >> writeTestFile [
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
	self new storeObj: objects on: s.
	s close.

]

{ #category : #'private-writing' }
ObjStream >> classEntryFor: anObject [
	"Answer the entry containing the class id and read/write selectors for the given object's class. Raise an error if the class is not registered."

	^ NameToClassEntry at: anObject class name
		ifAbsent: [self error: 'Unknown class ',  anObject class name]

]

{ #category : #'private-reading' }
ObjStream >> classForID: classID [
	"Answer the class for the given class ID."

	^ Smalltalk at: (IDToClassEntry at: classID) second

]

{ #category : #'private-reading' }
ObjStream >> fixReferencesForObjectRecord: objectRecord [
	"After reading all the objects in the objects table, this method is called on each object record to replace all its object references with pointers to the actual object in the object table. The fields for user-defined objects are still held in an array in the object table record. Fixed-format objects are processed by calling their read selector a second time and, since firstPass is now false, this read method fixes any object references."

	| obj classEntry classID readSelector |
	obj := objectRecord first.
	classEntry := self classEntryFor: obj.
	classID := classEntry first.

	classID >= FirstPointerClassID ifTrue: [
		classID > ObjectReferenceID
			ifTrue: [  "user defined class"
				self fixRefsInArray: (objectRecord at: 4)]
			ifFalse: [  "fixed format class"
				readSelector := classEntry at: 3.
				self perform: readSelector with: obj with: classID]].

]

{ #category : #'private-reading' }
ObjStream >> fixRefsInArray: anArray [
	"Replace any ObjRefRecord objects in the given array with references to the actual objects."

	| el |
	1 to: anArray size do: [:i |
		el := anArray at: i.
		el class = ObjRefRecord ifTrue: [
			el objectID > objects size
				ifTrue: [anArray at: i put: #badObjRef]
				ifFalse: [anArray at: i put: (objects at: el objectID) first]]].

]

{ #category : #'fixed format-reading' }
ObjStream >> getArray: anObject id: classID [

	| sz result |
	firstPass ifTrue: [
		sz := stream uint32.
		result := Array new: sz.
		1 to: sz do: [:i | result at: i put: self readField].
		^ result].

	"fix references"
	self fixRefsInArray: anObject.

]

{ #category : #'fixed format-reading' }
ObjStream >> getBigInt: anObject id: classID [

	| digitCount result |
	digitCount := stream uint16.
	result := (self classForID: classID) new: digitCount.
	1 to: digitCount do: [:i | result digitAt: i put: stream next].
	^ result

]

{ #category : #'fixed format-reading' }
ObjStream >> getBitmap: anObject id: classID [

	| count result |
	count := stream uint32.
	result := Bitmap new: count.
	1 to: count do: [:i | result at: i put: stream uint32].
	^ result

]

{ #category : #'fixed format-reading' }
ObjStream >> getBytes: anObject id: classID [

	| byteCount result |
	byteCount := stream uint32.
	result := stream next: byteCount.
	classID = 9 ifTrue: [^ result asString].
	classID = 15 ifTrue: [^ result asString].
	classID = 10 ifTrue: [^ result asString asSymbol].
	classID = 16 ifTrue: [^ result asString asSymbol].
	classID = 14 ifTrue: [^ UTF8 withAll: result].
	^ result

]

{ #category : #'fixed format-reading' }
ObjStream >> getCollection: anObject id: classID [

	| sz result newContents |
	firstPass ifTrue: [
		sz := stream uint32.
		result := (self classForID: classID) new: sz.
		sz timesRepeat: [result add: self readField].
		^ result].

	"fix references"
	newContents := anObject asArray.
	self fixRefsInArray: newContents.
	anObject removeAllSansError: anObject copy; addAll: newContents.

]

{ #category : #'fixed format-reading' }
ObjStream >> getColor: anObject id: classID [

	| rgb |
	firstPass ifFalse: [^ anObject].
	rgb := stream uint32.
	(self classForID: classID) = TranslucentColor
		ifTrue: [^ TranslucentColor basicNew setRgb: rgb alpha: stream next]
		ifFalse: [^ Color basicNew setRgb: rgb].

]

{ #category : #'fixed format-reading' }
ObjStream >> getConst: anObject id: classID [

	classID = 1 ifTrue: [^ nil].
	classID = 2 ifTrue: [^ true].
	classID = 3 ifTrue: [^ false].

]

{ #category : #'fixed format-reading' }
ObjStream >> getDict: anObject id: classID [

	| sz result key value newContents |
	firstPass ifTrue: [
		sz := stream uint32.
		result := (self classForID: classID) new: sz.
		sz timesRepeat: [
			key := self readField.
			value := self readField.
			result at: key put: value].
		^ result].

	"fix references"
	newContents := OrderedCollection new: anObject size.
	anObject copy associationsDo: [:assoc |
		newContents add: ((self targetObjectFor: assoc key) -> (self targetObjectFor: assoc value)).
		anObject removeKey: assoc key].
	anObject size = 0 ifFalse: [self error: 'should be empty!'].
	anObject addAll: newContents.

]

{ #category : #'fixed format-reading' }
ObjStream >> getFloat: anObject id: classID [

	| result |
	result := Float new: 2.
	result basicAt: 1 put: stream uint32.
	result basicAt: 2 put: stream uint32.
	^ result

]

{ #category : #'fixed format-reading' }
ObjStream >> getForm: anObject id: classID [

	| w h d offset bits result |
	firstPass ifTrue: [
		w := self readField.
		h := self readField.
		d := self readField.
		offset := self readField.
		bits := self readField.
		result := (self classForID: classID) basicNew
			setExtent: w@h depth: d bits: bits;
			offset: offset.
		(result class = ColorForm) ifTrue: [result privateColors: self readField].
		^ result].

	"fix references"
	anObject bits: (self targetObjectFor: anObject bits).
	anObject offset: (self targetObjectFor: anObject privateOffset).
	(anObject class = ColorForm) ifTrue: [anObject privateColors: (self targetObjectFor: anObject privateColors)].


]

{ #category : #'fixed format-reading' }
ObjStream >> getPoint: anObject id: classID [

	| x y |
	firstPass ifTrue: [
		x := self readField.
		y := self readField.
		^ Point x: x y: y].

	"fix references"
	anObject
		setX: (self targetObjectFor: anObject x)
		setY: (self targetObjectFor: anObject y).

]

{ #category : #'fixed format-reading' }
ObjStream >> getRect: anObject id: classID [

	| x1 y1 x2 y2 |
	firstPass ifTrue: [
		x1 := self readField.
		y1 := self readField.
		x2 := self readField.
		y2 := self readField.
		^ (Point x: x1 y: y1) corner: (Point x: x2 y: y2)].

	"fix references"
	anObject origin
		setX: (self targetObjectFor: anObject origin x)
		setY: (self targetObjectFor: anObject origin y).
	anObject corner
		setX: (self targetObjectFor: anObject corner x)
		setY: (self targetObjectFor: anObject corner y).

]

{ #category : #'fixed format-reading' }
ObjStream >> getSmallInt: anObject id: classID [

	classID = 4 ifTrue: [^ stream int32].
	classID = 5 ifTrue: [^ stream int16].

]

{ #category : #'fixed format-reading' }
ObjStream >> getSoundBuf: anObject id: classID [

	| sampleCount result |
	sampleCount := stream uint32.
	result := SoundBuffer newMonoSampleCount: sampleCount.
	(stream isKindOf: FileStream)
		ifTrue: [
			stream next: (sampleCount // 2) into: result startingAt: 1.  "size is in 32-bit words"
			Smalltalk isBigEndian ifFalse: [result reverseEndiannessStereo: false]]
		ifFalse: [
			1 to: sampleCount do: [:i | result at: i put: stream int16]].

	^ result

]

{ #category : #'private-reading' }
ObjStream >> initializeUserDefinedFields: objectRecord [
	"If the given object record designates a user-defined object, ask that object to initialiize itself from its fields list. Otherwise, do nothing."

	| obj classID classVersion |
	obj := objectRecord at: 1.
	classID := objectRecord at: 2.
	classID > ObjectReferenceID ifTrue: [  "user defined class"
		classVersion := objectRecord at: 3.
		fields := objectRecord at: 4.
		fieldIndex := 0.
		obj initFieldsFrom: self version: classVersion].

]

{ #category : #'entry points' }
ObjStream >> nextField [
	"Answer the next field and advance to the next field. This method should only be called from initFieldsFrom:version: during deserialization."
	"Note: If class versions are managed correctly, it should not be necessary to check that fieldIndex is in bounds. However, sometimes during development, we store a project that has objects with an extra field that is later removed. The check on fields size allows us to fail more gracefully in such cases."

	fieldIndex := fieldIndex + 1.
	fieldIndex > fields size ifTrue: [^ nil]. "fail gracefully"
	^ fields at: fieldIndex

]

{ #category : #'entry points' }
ObjStream >> objects [

	^ objects

]

{ #category : #'fixed format-writing' }
ObjStream >> putArray: anObject id: classID [

	self putCollection: anObject id: classID.

]

{ #category : #'fixed format-writing' }
ObjStream >> putBigInt: anObject id: classID [

	firstPass ifTrue: [^ self].
	stream nextPut: classID.
	stream uint16: anObject digitLength.
	1 to: anObject digitLength do: [:i | stream nextPut: (anObject digitAt: i)].

]

{ #category : #'fixed format-writing' }
ObjStream >> putBitmap: anObject id: classID [

	firstPass ifTrue: [^ self].
	stream nextPut: classID.
	stream uint32: anObject size.
	anObject do: [:el | stream uint32: el].

]

{ #category : #'fixed format-writing' }
ObjStream >> putBytes: anObject id: classID [

	firstPass ifTrue: [^ self].
	stream nextPut: classID.
	stream uint32: anObject size.
	stream nextPutAll: anObject asByteArray.

]

{ #category : #'fixed format-writing' }
ObjStream >> putCollection: anObject id: classID [

	firstPass ifFalse: [
		stream nextPut: classID.
		stream uint32: anObject size].
	anObject do: [:el | self putField: el].

]

{ #category : #'fixed format-writing' }
ObjStream >> putColor: anObject id: classID [

	| a |
	firstPass ifTrue: [^ self].
	stream nextPut: classID.
	stream uint32: anObject privateRGB.
	anObject class = TranslucentColor ifTrue: [
		a := (anObject privateAlpha asInteger min: 255) max: 0.
		stream nextPut: a].

]

{ #category : #'fixed format-writing' }
ObjStream >> putConst: anObject id: classID [

	firstPass ifTrue: [^ self].
	stream nextPut: classID.

]

{ #category : #'fixed format-writing' }
ObjStream >> putDict: anObject id: classID [

	firstPass ifFalse: [
		stream nextPut: classID.
		stream uint32: anObject size].
	anObject associationsDo: [:assoc |
		self putField: assoc key.
		self putField: assoc value].

]

{ #category : #'entry points' }
ObjStream >> putField: anObject [
	"Put the given object. If the given object is nil, true, false, an integer, or a float, it is stored directly. Otherwise, it is stored as an object reference and the object will be stored exactly once no matter how many other objects refer to it."

	| entry classID putSelector |
	entry := self classEntryFor: anObject.
	classID := entry at: 1.
	putSelector := entry at: 4.

 	firstPass ifTrue: [fields addLast: anObject].
	fieldIndex := fieldIndex + 1.

	classID <= FloatClassID ifTrue: [  "store the value directly inline"
		firstPass ifFalse: [self perform: putSelector with: anObject with: classID].
		^ self].
	
	firstPass
		ifTrue: [self recordObject: anObject id: classID]
		ifFalse: [self writeObjRef: (fields at: fieldIndex)].

]

{ #category : #'fixed format-writing' }
ObjStream >> putFloat: anObject id: classID [

	firstPass ifTrue: [^ self].
	stream nextPut: classID.
	stream uint32: (anObject basicAt: 1).
	stream uint32: (anObject basicAt: 2).

]

{ #category : #'fixed format-writing' }
ObjStream >> putForm: anObject id: classID [

	firstPass ifFalse: [stream nextPut: classID].
	anObject hibernateForPhratch.
	self putField: anObject width.
	self putField: anObject height.
	self putField: anObject depth.
	self putField: anObject privateOffset.
	self putField: anObject bits.
	(anObject class = ColorForm) ifTrue: [self putField: anObject colors].

]

{ #category : #'fixed format-writing' }
ObjStream >> putPoint: anObject id: classID [

	firstPass ifFalse: [
		stream nextPut: classID].
	self putField: anObject x.
	self putField: anObject y.

]

{ #category : #'fixed format-writing' }
ObjStream >> putRect: anObject id: classID [

	firstPass ifFalse: [
		stream nextPut: classID].
	self putField: anObject left.
	self putField: anObject top.
	self putField: anObject right.
	self putField: anObject bottom.

]

{ #category : #'fixed format-writing' }
ObjStream >> putSmallInt: anObject id: classID [

	firstPass ifTrue: [^ self].
	((-32768 <= anObject) and: [anObject <= 32767])
		ifTrue: [  "optimization for integers that fit into 16 bits"
			stream nextPut: classID + 1.
			stream int16: anObject]
		ifFalse: [
			stream nextPut: classID.
			stream int32: anObject].

]

{ #category : #'fixed format-writing' }
ObjStream >> putSoundBuf: anObject id: classID [

	firstPass ifTrue: [^ self].
	stream nextPut: classID.
	stream uint32: anObject size.
	anObject storeBigEndianOn: stream stereo: false.


]

{ #category : #'private-writing' }
ObjStream >> putUserObj: anObject id: ignored [
	"Ask the given user-defined object to write it's fields."

	anObject storeFieldsOn: self.

]

{ #category : #'private-reading' }
ObjStream >> readField [
	"Read a single object field. The result may be an object or an object reference."

	| classID readSelector |
	classID := stream next.
	classID = ObjectReferenceID ifTrue: [
		^ ObjRefRecord new objectID: stream uint24].

	readSelector := (IDToClassEntry at: classID) at: 3.
	^ self perform: readSelector with: nil with: classID

]

{ #category : #'private-reading' }
ObjStream >> readFileHeader [
	"Read the file header on my stream."

	(((stream next: 4) asString = 'ObjS') &
	 (stream next = 1) &
	 ((stream next: 4) asString = 'Stch') &
	 (stream next = 1)) ifFalse: [
		self error: 'bad header'].

]

{ #category : #'entry points' }
ObjStream >> readObjFrom: aStream [
	"Read the root object from the given binary stream."

	^ self readObjFrom: aStream showProgress: false

]

{ #category : #'entry points' }
ObjStream >> readObjFrom: aStream showProgress: showProgress [
	"Read the root object from the given binary stream. If showProgress is true, display a progress bar."

	| objCount tenPercent |
	objects := OrderedCollection new.
	stream := aStream.
	self readFileHeader.

	firstPass := true.
	objCount := stream uint32.
	showProgress
		ifTrue: [
			tenPercent := objCount // 10.
			('Reading...' localized, PhratchTranslator ellipsesSuffix)
				displayProgressAt: Display center - (32@5)  "Sensor cursorPoint"
				from: 0 to: objCount + tenPercent
				during: [:progressBar |
					1 to: objCount do: [:i |
						objects addLast: self readObjectRecord.
						progressBar value: i].

					firstPass := false.
					objects do: [:rec | self fixReferencesForObjectRecord: rec].
					progressBar value: objCount + (tenPercent // 2).
					objects do: [:rec | self initializeUserDefinedFields: rec].

					progressBar value: objCount + tenPercent.
					(Delay forMilliseconds: 200) wait]]
		ifFalse: [
			objCount timesRepeat: [objects addLast: self readObjectRecord].
			firstPass := false.
			objects do: [:rec | self fixReferencesForObjectRecord: rec].
			objects do: [:rec | self initializeUserDefinedFields: rec]].

	^ objects first first

]

{ #category : #'private-reading' }
ObjStream >> readObjectRecord [
	"Read the next object record. Answer an array of the form (<obj> <class ID> [<version> <fieldsArray>]). The version and fields array are supplied only for user-defined objects."

	| classID obj classVersion fieldCount fieldList readSelector |
	classID := stream next.
	classID > ObjectReferenceID
		ifTrue: [  "user defined object"
			obj := (self classForID: classID) new.
			classVersion := stream next.
			fieldCount := stream next.
			fieldList := (1 to: fieldCount) collect: [:i | self readField].
			^ Array with: obj with: classID with: classVersion with: fieldList]
		ifFalse: [  "fixed format object"
			readSelector := (IDToClassEntry at: classID) at: 3.
			obj := self perform: readSelector with: nil with: classID.
			^ Array with: obj with: classID].

]

{ #category : #'entry points' }
ObjStream >> readObjsFrom: aStream [
	"For testing. Answer the entire objects table from the given stream."

	| objCount |
	objects := OrderedCollection new.
	stream := aStream.
	self readFileHeader.

	firstPass := true.
	objCount := stream uint32.
	objCount timesRepeat: [objects addLast: self readObjectRecord].
	firstPass := false.
	objects do: [:rec | self fixReferencesForObjectRecord: rec].
	objects do: [:rec | self initializeUserDefinedFields: rec].

	^ objects


]

{ #category : #'private-writing' }
ObjStream >> recordFieldsOf: anObject [
	"Record the fields of the given object."
	"Details: Sometimes a user-defined class creates an object dynamically in a call to putField:. To preserve object identity between passes one and two, the objects passed to all calls to putField: are recorded during the first pass (i.e., by this method) and those exact same objects are used in the second pass."

	| entry classID putSelector |
	entry := self classEntryFor: anObject.
	classID := entry at: 1.
	putSelector := entry at: 4.

	fields := OrderedCollection new.
	fieldIndex := 0.
	self perform: putSelector with: anObject with: classID.
	(objects at: anObject) at: 4 put: fields asArray.

]

{ #category : #'private-writing' }
ObjStream >> recordObject: anObject id: classID [
	"Assign an ID for the given object, add it to the list of objects to be stored in the object table, and add it to the toDo list. Do nothing if this object has already been recorded."

	(objects includesKey: anObject) ifTrue: [^ self].
	objects at: anObject put: (Array with: objectIndex with: anObject with: classID with: nil).
	toDo addLast: anObject.
	objectIndex := objectIndex + 1.

]

{ #category : #'entry points' }
ObjStream >> storeObj: anObject on: aStream [
	"Write the given object and all the objects that can be reached from it on the given binary stream. Do not display a progress bar."

	self storeObj: anObject on: aStream showProgress: false.

]

{ #category : #'entry points' }
ObjStream >> storeObj: anObject on: aStream showProgress: showProgress [
	"Write the given object and all the objects that can be reached from it on the given binary stream. If showProgress is true, display a progress bar."

	| sortedObjEntries i obj |
	objects := IdentityDictionary new.
	objectIndex := 1.

	"collect objects"
	stream := nil.
	firstPass := true.
	toDo := OrderedCollection new.
	self recordObject: anObject id: (self classEntryFor: anObject) first.
	[toDo size > 0] whileTrue: [self recordFieldsOf: toDo removeFirst].

	"write object table"
	stream := aStream.
	firstPass := false.
	sortedObjEntries := objects asArray sort: [:e1 :e2 | e1 first < e2 first].
	self writeFileHeader.
	stream uint32: sortedObjEntries size.
	showProgress
		ifTrue: [
			i := 0.  "object counter for progress bar"
			'Saving...'
				displayProgressAt: Sensor cursorPoint
				from: 0 to: sortedObjEntries size
				during:  [:progressBar |
					sortedObjEntries do: [:objEntry |
						progressBar value: (i := i + 1).
						obj := objEntry at: 2.
						self writeObject: obj objEntry: objEntry]]]
		ifFalse: [
			sortedObjEntries do: [:objEntry |
				obj := objEntry at: 2.
				self writeObject: obj objEntry: objEntry]].

]

{ #category : #'private-reading' }
ObjStream >> targetObjectFor: anObject [
	"If the argument is an ObjRefRecord, answer the object that it refers to. Otherwise, just answer the argument."

	anObject class = ObjRefRecord
		ifTrue: [^ (objects at: anObject objectID) first]
		ifFalse: [^ anObject].

]

{ #category : #'private-writing' }
ObjStream >> writeFileHeader [
	"Write the file header on my stream."

	stream nextPutAll: 'ObjS' asByteArray.
	stream nextPut: 1.
	stream nextPutAll: 'Stch' asByteArray.
	stream nextPut: 1.

]

{ #category : #'private-writing' }
ObjStream >> writeObjRef: anObject [
	"Write a reference to the given object to my output stream. The object must have an entry in the object dictionary."

	| objEntry objIndex |
	objEntry := objects at: anObject ifAbsent: [self error: 'object not in dictionary'].  "should never happen"
	objIndex := objEntry at: 1.
	stream nextPut: ObjectReferenceID.
	stream uint24: objIndex.

]

{ #category : #'private-writing' }
ObjStream >> writeObject: anObject objEntry: objEntry [
	"Write the object described by the given entry."

	| entry classID putSelector |
	entry := self classEntryFor: anObject.
	classID := entry at: 1.
	putSelector := entry at: 4.

	fields := objEntry at: 4.
	fieldIndex := 0.

	putSelector = #putUserObj:id: ifTrue: [
		stream nextPut: classID.
		stream nextPut: anObject fieldsVersion.
		stream nextPut: fields size].

	self perform: putSelector with: anObject with: classID.

]
