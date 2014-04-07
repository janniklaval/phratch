Extension { #name : #BlockMorph }

{ #category : #'*PhratchObjStream' }
BlockMorph >> asBlockTuple [

	self subclassResponsibility 
]

{ #category : #'*PhratchObjStream' }
BlockMorph >> blockID [
	"answer a temporary (!) id for the receiver
	which can be used for tuple conversion of
	sticky comments"

	| sm |
	sm := self ownerOrYourselfThatIsAPhratchScriptsMorph.
	sm ifNil: [^ nil].
	^ (sm allMorphs select: [:m |
		m isKindOf: BlockMorph]) indexOf: self

]

{ #category : #'*PhratchObjStream' }
BlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
BlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isSpecialForm
		oldColor
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
BlockMorph >> showTuples [

	(StringHolder new contents: self tupleSequence printString)
		openLabel: 'Tuple'
]

{ #category : #'*PhratchObjStream' }
BlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isSpecialForm
		oldColor
	) on: anObjStream.

]

{ #category : #'*PhratchObjStream' }
BlockMorph >> tupleSequence [
	"Answer a sequence of tuples (Array) describing this stack of blocks."

	^ self blockSequence collect: [:b | b asBlockTuple]

]
