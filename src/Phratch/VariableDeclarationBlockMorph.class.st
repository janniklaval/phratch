"
VariableDeclarationBlockMorph new commandSpec: 'local variables'; color: ScratchFrameMorph palettePaneColor; openInWorld

"
Class {
	#name : #VariableDeclarationBlockMorph,
	#superclass : #MultiArgCommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #adding }
VariableDeclarationBlockMorph >> addItem [
	| varBlock pos vname names |
	names := #(#a #b #c #d #e #f #g #h #i #j #k #l #m #n #o #p #q #r #s #t #u #v #w #x #y #z #foo #bar #baz).
	super addItem.
	pos := argMorphs size.
	vname := pos > names size
		ifTrue: [ 'z' , (pos - names size + 1) printString ]
		ifFalse: [ (names at: pos) asString ].
	varBlock := VariableBlockMorph new.
	varBlock
		isSpecialForm: true;
		selector: #getVar:;
		commandSpec: vname.
	self replaceArgMorph: (self argumentAt: pos) by: varBlock
]

{ #category : #accessing }
VariableDeclarationBlockMorph >> args [
	^argMorphs
]

{ #category : #accessing }
VariableDeclarationBlockMorph >> defaultArgs: anArray [
 	"override my superclass, do nothing"
]

{ #category : #deleting }
VariableDeclarationBlockMorph >> deleteVariableTemplate: aVarBlockMorph [

	aVarBlockMorph delete.
	argMorphs remove: aVarBlockMorph.
	self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3)
]

{ #category : #'parts bin' }
VariableDeclarationBlockMorph >> isPartsBin [
	^true
]

{ #category : #deleting }
VariableDeclarationBlockMorph >> removeItem [
	argMorphs size > self minArgs
		ifFalse: [ ^ self ].
	self removeLastArg.
	self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3)
]

{ #category : #deleting }
VariableDeclarationBlockMorph >> removeLastArg [

	| idx |
	idx := argMorphs size.
	(argMorphs at: idx) delete.
	argMorphs at: idx put: nil.

]

{ #category : #'events-processing' }
VariableDeclarationBlockMorph >> renameParm: old to: new [

	(self variables includes: new) ifTrue: [
		DialogBoxMorph warn: 'This variable name already exists'.
		^false ].
	^true
]

{ #category : #'dropping/grabbing' }
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

{ #category : #accessing }
VariableDeclarationBlockMorph >> variables [
	^argMorphs collect: [:a |
		a variable ]
]
