Extension { #name : #CustomBlockDefinition }

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> declarations [
	^declarations
]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> deduceType [
	"private - set my return type from the deprecated legacy attributes #isReporter and #isBoolean.
	use this when reading an old block from file"

	self isReporter ifFalse: [ ^ type := #none ].
	isBoolean ifTrue: [ ^ type := #boolean ].
	^ type := #any
]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> fieldsVersion [

	^ 4

]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		userSpec
		blockVars
		body
		isAtomic
		isBoolean
		answer
	) from: anObjStream.

	classVersion = 1 ifTrue: [
		^ self deduceType ].

	"fields added in version 2:"
	self initFieldsNamed: #(
		category
		type
		declarations
	) from: anObjStream.

	"fields added in version 3:"
	self initFieldsNamed: #(
			defaults
		) from: anObjStream.
		
	"fields added in version 4:"
	self initFieldsNamed: #(
			isGlobal
		) from: anObjStream.
]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> isBoolean [
	"deprecated, kept for legacy support (jens)"

	^isBoolean
]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> ownerOrYourselfThatIsA: aClassName [
	^nil
]
