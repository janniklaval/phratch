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
Morph >> storeFieldsOn: anObjStream [
	| flags |
	self storeFieldsNamed: #(#bounds #owner #submorphs #color) on: anObjStream.
	flags := 0.
	{(self isHidden).
	(self isSticky).
	(self isLocked)	". self isPartsDonor"}
		doWithIndex: [ :bool :i | 
			| maskInteger |
			maskInteger := 2 raisedTo: i - 1.
			flags := bool
				ifTrue: [ flags bitOr: maskInteger ]
				ifFalse: [ flags bitAnd: maskInteger bitInvert ] ].
	anObjStream putField: flags.
	anObjStream putField: nil	"placeholder for properties"
]
