Extension { #name : #ArgMorph }

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ false

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> defaultValue [

	| def pos pname val |
	(owner respondsTo: #definition)
		ifFalse: [^ nil].
	def := owner definition.
	pos := (owner submorphs select: [:sm | sm isKindOf: ArgMorph]) indexOf: self.
	pname := def parameterNames at: pos.
	val := def defaultOf: pname.
	val = '' ifTrue: [^ nil].
	^ val
]

{ #category : #'*Phratch-BYOB-see-ddddd lambdas' }
ArgMorph class >> dropDownMenuForm [
	^DropDownMenuForm
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> implicitValue [
	^ implicitValue
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> implicitValue: anObject [
	implicitValue := anObject
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> isEmptySlot [
	^true
]
