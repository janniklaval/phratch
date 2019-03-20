Extension { #name : #ImageMedia }

{ #category : #'*PhratchObjStream' }
ImageMedia >> fieldsVersion [

	^ 4

]

{ #category : #'*PhratchObjStream' }
ImageMedia >> initFieldsFrom: anObjStream version: classVersion [

	| f |
	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		form
		rotationCenter 
	) from: anObjStream.

	(form isKindOf: ColorForm) ifTrue: [  "convert ColorForm to 32-bit color"
		f := Form extent: form extent depth: 32.
		form displayOn: f.
		form := f].

	compositeForm := jpegBytes := nil.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		textBox
	) from: anObjStream.

	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		jpegBytes
	) from: anObjStream.
	jpegBytes ifNotNil: [form := JPEGReadWriter new on: jpegBytes].

	classVersion = 3 ifTrue: [^ self].

	"fields added in version 4"
	self initFieldsNamed: #(
		compositeForm
	) from: anObjStream.

]
