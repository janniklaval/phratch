Class {
	#name : #MethodElementMorph,
	#superclass : #BlockElementMorph,
	#instVars : [
		'header'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #'as yet unclassified' }
MethodElementMorph >> asCompiledMethodForClass: aClass [
	| mn1 cm st |
	st := self asSmalltalk.
	mn1 := Compiler new compile: st in: aClass notifying: nil ifFail: [self inform: 'compiling failed'].
	cm := mn1 generate: #(0 0 0 0).
	^cm 
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> asSmalltalk [
	| ws vn|
	ws := WriteStream on: String new.
	ws nextPutString: header asSmalltalk; cr; cr.
	(vn := self localVariableNames) isEmpty ifFalse: [
		ws nextPutString: '| '.
		vn do: [:n|
			ws nextPutString: n, ' ' ].
		ws
			nextPutString: '|';
			nextPut: Character cr].
	ws nextPutString: steps asSmalltalk.
	^ws contents
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> contextMenu [
	|m|
	m := super contextMenu.
	self isRenameable ifTrue: [
		m addLine.
		m add: 'rename...' action: #editSelector ].
	^m
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> editSelector [
	header editSelector
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> fit [
	| bw bw2 cw handle x y editor|

	header ifNil: [^self ].
	bw := self borderWidth.
	bw2 := bw * 2.
	cw := self labelFont widthOf: $ .
	handle := cw.

	header position: (self left + bw + handle) @ (self top).

	palette position: (self left + handle) @ (header bottom).
	(palette height = 0)
		ifTrue: [y := header bottom + (bw * 3)]
		ifFalse: [y := palette bottom].
	

	steps position: (self left + bw2 + handle) @ y.

	x := ((steps right + bw2) max: palette right) max: header right.

	self width: x - self left.
	(palette height = 0)
		ifTrue: [ self height: steps height + header height + (bw * 6) ]
		ifFalse: [self height: steps height + palette height + header height + (bw2) ].

	self refreshVarColors.

	(owner respondsTo: #fit)
		ifTrue: [^owner fit].

	editor := (self ownerThatIsA: ElementsMethodEditorMorph).
	editor ifNotNil: [editor methodModified ]
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> fitMethod [
	|editor|
	(self findA: StepHolderElementMorph) fitMethod.
	editor := (self ownerThatIsA: ElementsMethodEditorMorph).
	editor ifNotNil: [editor methodModified ]
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> initialize [
	super initialize.
	color := Color paleTan.
	steps color: color slightlyDarker.
	header := MessageHeaderElementMorph new.
	self addMorph: header.
	self fit.
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> isRenameable [
	^true
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> localVariableNames [
	^super variableNames
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(self ownerThatIsA: ElementsMethodEditorMorph) notNil
		ifTrue: [^nil].
	^super rootForGrabOf: aMorph
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> selector [
	^header selector asSymbol
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> selector: aSymbol arguments: aCollection [
	header selector: aSymbol arguments: aCollection
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> stackBottom [
	steps contents isNil
		ifTrue: [^self bottom ]
		ifFalse: [^steps contents stack last bottom ]
	
]

{ #category : #'as yet unclassified' }
MethodElementMorph >> variableNames [
	^super variableNames, header variableNames
]
