"
I am a block for setting a variable.

"
Class {
	#name : #SetterBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'variable'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #byob }
SetterBlockMorph >> contrastColor [
	| newColor |
	newColor := isSpecialForm
		ifTrue: [ VariableFrame variableBlockColor ]
		ifFalse: [ ScriptablePhratchMorph blockColorFor: 'variables' ].
	color = newColor
		ifFalse: [ self color: newColor ].
	super contrastColor
]

{ #category : #byob }
SetterBlockMorph >> determineIfSpecialForm [

	"also rebind my receiver to the sprite or stage that has my variable
	if it's not a temporay one"

	isSpecialForm := (self scriptVars includes: self variable).
	isSpecialForm ifFalse: [
		receiver := self phratchObject ]. 

	isSpecialForm
		ifTrue: [self color: VariableFrame variableBlockColor]
		ifFalse: [self color: (ScriptablePhratchMorph blockColorFor: 'variables')].


]

{ #category : #accessing }
SetterBlockMorph >> expressionArg [

	submorphs do: [:m |
		(m isExpressionArgMorph) ifTrue: [^ m]].

	^ nil
]

{ #category : #accessing }
SetterBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	#setVar:to: = selector
		ifTrue: [^ 'variableSet']
		ifFalse: [^ 'variableChangeBy']

]

{ #category : #initialization }
SetterBlockMorph >> initChangerForVar: varName [

	| var |
	var := varName.
	"(var isArray) ifTrue: [
		var := receiver blockFromTuple: var receiver: receiver]."

	self commandSpec: (PhratchTranslator translationFor: 'change $Variable$ by $String$').
	argPermutation := CommandBlockMorph argPermutationForSpec: 'set $Variable$ to $String$' withTranslation: commandSpec.
	self selector: #changeVar:by:.
	self variable: var.

]

{ #category : #initialization }
SetterBlockMorph >> initSetterForVar: varName [

	| var |
	var := varName.
	"(var isArray) ifTrue: [
		var := receiver blockFromTuple: var receiver: receiver]."
	
	self commandSpec: (PhratchTranslator translationFor: 'set $Variable$ to $String$').
	argPermutation := CommandBlockMorph argPermutationForSpec: 'set $Variable$ to $String$' withTranslation: commandSpec.
	self selector: #setVar:to:.
	self variable: var.

]

{ #category : #initialization }
SetterBlockMorph >> initialize [

	super initialize.
	isSpecialForm := false.
	isTimed := false.

]

{ #category : #accessing }
SetterBlockMorph >> isSetterBlockMorph [

	^ true
]

{ #category : #accessing }
SetterBlockMorph >> receiver: anObject [
	"Set my receiver object and, if possible, my block color."

	receiver := anObject.
	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].

]

{ #category : #byob }
SetterBlockMorph >> replaceArgMorph: oldMorph by: newMorph [
	"Replace oldMorph with newMorph in my argMorphs and submorphs lists. This is done when dropping a reporter block onto one of my arguments."


	super replaceArgMorph: oldMorph by: newMorph.
	oldMorph = argMorphs first ifTrue: [
		self determineIfSpecialForm]
]

{ #category : #accessing }
SetterBlockMorph >> variable [

	submorphs do: [:m |
		(m isChoiceArgMorph) ifTrue: [^ m choice]].
	^ ''


]

{ #category : #accessing }
SetterBlockMorph >> variable: aVar [

	(aVar isCommandBlockMorph) ifTrue: [
		^ self replaceArgMorph: self argMorphs first by: aVar].
	submorphs do: [:m |
		(m isChoiceArgMorph) ifTrue: [^ m choice: aVar]].


]
