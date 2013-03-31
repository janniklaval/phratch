"
VariableDeclarationBlockMorph new commandSpec: 'local variables'; color: ScratchFrameMorph palettePaneColor; openInWorld

"
Class {
	#name : #VariableDeclarationBlockMorph,
	#superclass : #MultiArgCommandBlockMorph,
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> addItem [
	| varBlock pos vname names |
	names := #(a b c d e f g h i j k l m n o p q r s t u v w x y z foo bar baz).
	super addItem.
	pos := argMorphs size.
	pos > names size
		ifTrue: [vname := ('z', (pos - names size + 1) printString) asUTF8]
		ifFalse: [vname := (names at: pos) asString asUTF8].
	varBlock := VariableBlockMorph new.
	varBlock 
		isSpecialForm: true;
		selector: #getVar:;
"		color: (ScriptableScratchMorph blockColorFor: 'variables');"
		commandSpec: vname.
	self replaceArgMorph: (self argumentAt: pos) by: varBlock.
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> args [
	^argMorphs
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> defaultArgs: anArray [
 	"override my superclass, do nothing"
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> deleteVariableTemplate: aVarBlockMorph [

	aVarBlockMorph delete.
	argMorphs remove: aVarBlockMorph.
	self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3)
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> isPartsBin [
	^true
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> mouseDownPriority [

	^ 0
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> removeItem [
	argMorphs size > self minArgs ifTrue: [
		self removeLastArg.
		self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3) ]
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> removeLastArg [

	| idx |
	idx := argMorphs size.
	(argMorphs at: idx) delete.
	argMorphs at: idx put: nil.

]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> renameParm: old to: new [

	(self variables includes: new) ifTrue: [
		DialogBoxMorph warn: 'This variable name already exists'.
		^false ].
	^true
]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> rootForGrabOf: aMorph [

	| root |
	root := aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [
			self isPartsBin ifTrue: [
				root = self nextBlock
					ifTrue: [^root]
					ifFalse: [^ root fullCopy]].
			self dragNDropEnabled ifTrue: [^ root]].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #'as yet unclassified' }
VariableDeclarationBlockMorph >> variables [
	^argMorphs collect: [:a |
		a variable ]
]
