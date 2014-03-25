Class {
	#name : #VariableFrame,
	#superclass : #Object,
	#instVars : [
		'vars'
	],
	#classVars : [
		'ScopeContrast'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #private }
VariableFrame class >> forNames: aCollection [
	^self new forNames: aCollection
]

{ #category : #'class initialization' }
VariableFrame class >> initialize [

	"VariableFrame initialize"

	super initialize.
	ScopeContrast := false.
]

{ #category : #private }
VariableFrame class >> maxNestingDepth [
	"kludge alert!"

	^ 100
]

{ #category : #'class initialization' }
VariableFrame class >> scopeContrast: bool [

	ScopeContrast := bool
]

{ #category : #variables }
VariableFrame class >> variableBlockColor [

	ScopeContrast
		ifTrue: [^ (Color brown darker mixed: 0.8 with: Color orange) lighter]
		ifFalse: [^ ScriptablePhratchMorph blockColorFor: 'variables']
	

]

{ #category : #adding }
VariableFrame >> add: varName [
	vars at: varName put: 0


]

{ #category : #variables }
VariableFrame >> changeVar: varName by: increment [
	"Change the value of the given variable of this object by the given amount."

	|  n |
	n := vars at: varName asString ifAbsent: [^ self].
	self setVar: varName to: n asNumberNoError + increment asNumberNoError.

]

{ #category : #private }
VariableFrame >> forNames: aCollectionOfStrings [
	aCollectionOfStrings do:[:eachVarName |
		vars at: eachVarName put: 0 ]
]

{ #category : #variables }
VariableFrame >> getVar: varName [
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	^ vars at: varName asString ifAbsent: [0]

]

{ #category : #variables }
VariableFrame >> getVar: varName block: aVariableBlockMorph [
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	^ vars at: varName asString ifAbsent: [0]

]

{ #category : #'initialize-release' }
VariableFrame >> initialize [
	super initialize.
	vars := Dictionary new.
]

{ #category : #private }
VariableFrame >> interpretStringAsNumberIfPossible: anObject [
	"If the argument is a string that can be interpreted as a number, such as '123', then return it's value as a number. Otherwise, return the original object."

	| s digits hasDigit |
	(anObject isString)
		ifFalse: [ ^ anObject ].
	anObject size = 0
		ifTrue: [ ^ anObject ].
	s := (anObject first isKindOf: Character)
		ifTrue: [ ReadStream on: anObject asByteArray ]
		ifFalse: [ ReadStream on: anObject ].	"see if the string can be parsed as a Phratch number:"
	digits := '0123456789' asByteArray.
	hasDigit := false.
	(s atEnd not and: [ s peek = $- asciiValue ])
		ifTrue: [ s next ].
	[ s atEnd not and: [ digits includes: s peek ] ]
		whileTrue: [ 
			hasDigit := true.
			s next ].
	(s atEnd not and: [ s peek = $. asciiValue ])
		ifTrue: [ s next ].
	[ s atEnd not and: [ digits includes: s peek ] ]
		whileTrue: [ 
			hasDigit := true.
			s next ].
	(s atEnd and: [ hasDigit ])
		ifTrue: [ ^ anObject asNumberNoError ]
		ifFalse: [ ^ anObject ]
]

{ #category : #testing }
VariableFrame >> isMaxNestedAt: int [
	"kludge-alert!"

	vars do: [:each |
		(each respondsTo: #isMaxNestedAt:)
			ifTrue: [ (each isMaxNestedAt: int + 1)
				ifTrue: [^ true]]].
	^ false
]

{ #category : #testing }
VariableFrame >> isReferencing: aVarFrame [

	| obj |
	
	vars keysDo: [:key |
		obj := vars at: key. 
		(obj isBlockMorph) ifTrue: [
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

{ #category : #testing }
VariableFrame >> references: obj [
	"kludge-alert: answer true if any part of me contains a reference to obj"

	vars do: [:each |
		each == obj ifTrue: [^ true].
		(each respondsTo: #references:)
			ifTrue: [ (each references: obj)
				ifTrue: [^ true]]].
	^ false
]

{ #category : #removing }
VariableFrame >> remove: varName [
	vars removeKey: varName
]

{ #category : #private }
VariableFrame >> renameVar: old to: new [

	| value |
	(vars includesKey: old)
		ifTrue: [ 
			value := vars at: old.
			self remove: old]
		ifFalse: [ value := 0 ].
	vars at: new put: value
]

{ #category : #accessing }
VariableFrame >> scope [

	^self varNamesMenu
]

{ #category : #variables }
VariableFrame >> setVar: varName to: newValue [
	"Set the value of the given variable of this object to the given value."

"	|  v |
	v := self interpretStringAsNumberIfPossible: newValue."

	vars at: varName put: newValue.

]

{ #category : #variables }
VariableFrame >> varNamesMenu [
	^vars keys asSortedCollection asArray
]

{ #category : #variables }
VariableFrame >> variableBlockColor [

	^ self class variableBlockColor
]

{ #category : #accessing }
VariableFrame >> vars [
	"private"
	^ vars
]
