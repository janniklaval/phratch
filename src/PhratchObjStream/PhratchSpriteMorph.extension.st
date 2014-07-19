Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchObjStream' }
PhratchSpriteMorph >> asReferenceTuple [

	" answer an array describing the receiver in an abstract way
	format conventions:"

	^ Array 
		with: #sprite
		with: self objName

]

{ #category : #'*PhratchObjStream' }
PhratchSpriteMorph >> fieldsVersion [

	^ 5

]

{ #category : #'*PhratchObjStream' }
PhratchSpriteMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.

(customBlocks isKindOf: Boolean) ifTrue: [ self error: 'attempting to initialize a wrong class version']. 

	self initFieldsNamed: #(
		visibility
		scalePoint
		rotationDegrees
		rotationStyle
	) from: anObjStream.

	scalePoint ifNil: [scalePoint := 1.0@1.0].
	offsetWhenRotated := 0@0.
	draggable := false.  "default for old sprites"
	self layoutChanged.

	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		volume
		tempoBPM
		draggable
	) from: anObjStream.
	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		sceneStates
		lists
	) from: anObjStream.
	lists ifNil: [lists := Dictionary new].  "work around"
	classVersion = 3 ifTrue: [^ self].

	"fields added in version 4"
	self initFieldsNamed: #(
		virtualScale
		ownerSprite
		subsprites
		rotateWithOwner
		refPos
	) from: anObjStream.

	classVersion = 4 ifTrue: [^ self].
	"fields added in version 5"
	self initFieldsNamed: #(
		prototype
		deletedAttributes
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
PhratchSpriteMorph >> refPos [
	^refPos
]

{ #category : #'*PhratchObjStream' }
PhratchSpriteMorph >> refPos: aPos [
	refPos := aPos
]
