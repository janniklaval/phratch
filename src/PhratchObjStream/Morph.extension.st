Extension { #name : #Morph }

{ #category : #'*PhratchObjStream' }
Morph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
Morph >> initFieldsFrom: anObjStream version: classVersion [
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		bounds
		owner
		submorphs
		color
		flags
	) from: anObjStream.
	
	anObjStream nextField  "placeholder for properties".
	
	fullBounds := nil.

]

{ #category : #'*PhratchObjStream' }
Morph >> initObsoleteFieldNamed: varName from: anObjStream [

	| flags |

	 varName = 'flags' 
		ifFalse: [^ super initObsoleteFieldNamed: varName from: anObjStream].
		
	flags := anObjStream nextField.
	self isHidden: (flags bitAnd: 1) ~= 0.
	self sticky: (flags bitAnd: 2) ~= 0.
	self lock: (flags bitAnd: 4) ~= 0.
	self isPartsDonor: (flags bitAnd: 8) ~= 0.
]

{ #category : #'*PhratchObjStream' }
Morph >> isPartsDonor: aBoolean [

	^false
]

{ #category : #'*PhratchObjStream' }
Morph >> ownerOrYourselfThatIsA: aClass [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current meth |
	current := self.
	meth := ('is', aClass asString) asSymbol.
	[ current isNil ]
		whileFalse: [ 
			([current perform: meth] on: Error do: [Transcript show: 'Error in ownerOrYourselfThatIsA: ' .Transcript show: aClass asString. Transcript cr .(current isKindOf: aClass)])
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]
