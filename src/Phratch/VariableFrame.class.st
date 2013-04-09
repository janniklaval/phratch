Class {
	#name : #VariableFrame,
	#superclass : #Object,
	#instVars : [
		'vars'
	],
	#classVars : [
		'ScopeContrast'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
VariableFrame class >> forNames: aCollection [
	^self new forNames: aCollection
]

{ #category : #'as yet unclassified' }
VariableFrame class >> initialize [

	"VariableFrame initialize"

	super initialize.
	ScopeContrast := false.
]

{ #category : #'as yet unclassified' }
VariableFrame class >> maxNestingDepth [
	"kludge alert!"

	^ 100
]

{ #category : #'as yet unclassified' }
VariableFrame class >> scopeContrast [

	^ ScopeContrast
]

{ #category : #'as yet unclassified' }
VariableFrame class >> scopeContrast: bool [

	ScopeContrast := bool
]

{ #category : #'as yet unclassified' }
VariableFrame class >> variableBlockColor [

	ScopeContrast
		ifTrue: [^ (Color brown darker mixed: 0.8 with: Color orange) lighter]
		ifFalse: [^ ScriptablePhratchMorph blockColorFor: 'variables']
	

]

{ #category : #'as yet unclassified' }
VariableFrame >> add: varName [
	vars at: varName put: 0


]

{ #category : #'as yet unclassified' }
VariableFrame >> changeVar: varName by: increment [
	"Change the value of the given variable of this object by the given amount."

	|  n |
	n := vars at: varName asString ifAbsent: [^ self].
	self setVar: varName to: n asNumberNoError + increment asNumberNoError.

]

{ #category : #'as yet unclassified' }
VariableFrame >> convertStacksToTuples [

	| obj isCyclic |
	vars keysDo: [:key |
		obj := vars at: key. 
		(obj isKindOf: ScriptablePhratchMorph)
			ifTrue: [ vars at: key put: obj asReferenceTuple ]
			ifFalse: [
			(obj respondsTo: #convertStacksToTuples) ifTrue: [		"this must be a list or another variable"
				obj convertStacksToTuples ].
			(obj respondsTo: #asBlockTuple) ifTrue: [ 				"this must be a block"

				isCyclic := obj allMorphs anySatisfy: [ :m |
					(m isKindOf: SetterBlockMorph) | (m isKindOf: VariableBlockMorph) and: [
						m receiver == self or: [(m receiver isKindOf: self class) and: [m receiver isReferencing: self]] ]].
				isCyclic
					ifTrue: [ obj receiver: nil]
					ifFalse: [ vars at: key put: obj asBlockTuple ]]]]


]

{ #category : #'as yet unclassified' }
VariableFrame >> convertTuplesToStacks [

	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj stage rcvr block |

	stage := PhratchFrameMorph someInstance workPane.

	vars keysDo: [:key |
		obj := vars at: key.

		(obj isKindOf: Array) ifTrue: [

			obj second = 'Stage'
				ifTrue: [rcvr := stage ]
				ifFalse: [rcvr := stage coerceSpriteArg: obj second ].

			#block = obj first ifTrue: [
				block := stage stackFromTupleList: obj third receiver: rcvr.
				vars at: key put: block ].

			#namedList = obj first ifTrue: [
				vars at: key put: (stage listNamed: obj third targetName: obj second)].

			#variableList = obj first ifTrue: [
				vars at: key put: (stage listInVarNamed: obj third targetName: obj second)].

			#stage = obj first ifTrue: [
				vars at: key put: stage].	

			#sprite = obj first ifTrue: [
				vars at: key put: (stage coerceSpriteArg: obj second)]].

		(obj isKindOf: PhratchListMorph) ifTrue: [
			obj convertTuplesToStacks ]]
]

{ #category : #'as yet unclassified' }
VariableFrame >> fieldsVersion [

	^ 1

]

{ #category : #'as yet unclassified' }
VariableFrame >> forNames: aCollectionOfStrings [
	aCollectionOfStrings do:[:eachVarName |
		vars at: eachVarName put: 0 ]
]

{ #category : #'as yet unclassified' }
VariableFrame >> getVar: varName [
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	^ vars at: varName asString ifAbsent: [0]

]

{ #category : #'as yet unclassified' }
VariableFrame >> getVar: varName block: aVariableBlockMorph [
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	^ vars at: varName asString ifAbsent: [0]

]

{ #category : #'as yet unclassified' }
VariableFrame >> initFieldsFrom: anObjStream version: classVersion [
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		vars
	) from: anObjStream.

]

{ #category : #'as yet unclassified' }
VariableFrame >> initialize [
	super initialize.
	vars := Dictionary new.
]

{ #category : #'as yet unclassified' }
VariableFrame >> interpretStringAsNumberIfPossible: anObject [
	"If the argument is a string that can be interpreted as a number, such as '123', then return it's value as a number. Otherwise, return the original object."

	| s digits hasDigit |
	(anObject isKindOf: String) ifFalse: [^ anObject].
	anObject size = 0 ifTrue: [^ anObject].

	(anObject first isKindOf: Character)
		ifTrue: [s := ReadStream on: anObject asByteArray]
		ifFalse: [s := ReadStream on: anObject].

	"see if the string can be parsed as a Phratch number:"
	digits := '0123456789' asByteArray.
	hasDigit := false.
	(s atEnd not and: [s peek = $- asciiValue]) ifTrue: [s next].
	[s atEnd not and: [digits includes: s peek]] whileTrue: [hasDigit := true. s next].
	(s atEnd not and: [s peek = $. asciiValue]) ifTrue: [s next].
	[s atEnd not and: [digits includes: s peek]] whileTrue: [hasDigit := true. s next].

	(s atEnd and: [hasDigit])
		ifTrue: [^ anObject asNumberNoError]
		ifFalse: [^ anObject].


]

{ #category : #'as yet unclassified' }
VariableFrame >> isMaxNestedAt: int [
	"kludge-alert!"

	vars do: [:each |
		(each respondsTo: #isMaxNestedAt:)
			ifTrue: [ (each isMaxNestedAt: int + 1)
				ifTrue: [^ true]]].
	^ false
]

{ #category : #'as yet unclassified' }
VariableFrame >> isReferencing: aVarFrame [

	| obj |
	
	vars keysDo: [:key |
		obj := vars at: key. 
		(obj isKindOf: BlockMorph) ifTrue: [
			(obj allMorphs anySatisfy: [ :m |
				(m isKindOf: SetterBlockMorph) | (m isKindOf: VariableBlockMorph) and: [
					m receiver == aVarFrame or: [
						(m receiver isKindOf: self class) and: [
							m receiver isReferencing: aVarFrame]]]])
				ifTrue: [^ true]].
		(obj isKindOf: PhratchListMorph) ifTrue: [
			(obj asArray anySatisfy: [ :item |
				(item isKindOf: SetterBlockMorph) | (item isKindOf: VariableBlockMorph) and: [
					item receiver == aVarFrame or: [
						(item receiver isKindOf: self class) and: [
							item receiver isReferencing: aVarFrame]]]])]].
	^ false


]

{ #category : #'as yet unclassified' }
VariableFrame >> references: obj [
	"kludge-alert: answer true if any part of me contains a reference to obj"

	vars do: [:each |
		each == obj ifTrue: [^ true].
		(each respondsTo: #references:)
			ifTrue: [ (each references: obj)
				ifTrue: [^ true]]].
	^ false
]

{ #category : #'as yet unclassified' }
VariableFrame >> remove: varName [
	vars removeKey: varName
]

{ #category : #'as yet unclassified' }
VariableFrame >> renameVar: old to: new [

	| value |
	(vars includesKey: old)
		ifTrue: [ 
			value := vars at: old.
			self remove: old]
		ifFalse: [ value := 0 ].
	vars at: new put: value
]

{ #category : #'as yet unclassified' }
VariableFrame >> scope [

	^self varNamesMenu
]

{ #category : #'as yet unclassified' }
VariableFrame >> setVar: varName to: newValue [
	"Set the value of the given variable of this object to the given value."

"	|  v |
	v := self interpretStringAsNumberIfPossible: newValue."

	vars at: varName put: newValue.

]

{ #category : #'as yet unclassified' }
VariableFrame >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		vars
	) on: anObjStream.


]

{ #category : #'as yet unclassified' }
VariableFrame >> varNamesMenu [
	^vars keys asSortedCollection asArray
]

{ #category : #'as yet unclassified' }
VariableFrame >> variableBlockColor [

	^ self class variableBlockColor
]

{ #category : #'as yet unclassified' }
VariableFrame >> vars [
	"private"
	^ vars
]