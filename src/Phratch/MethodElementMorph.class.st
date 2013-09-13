Class {
	#name : #MethodElementMorph,
	#superclass : #BlockElementMorph,
	#instVars : [
		'header'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #converting }
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

{ #category : #menu }
MethodElementMorph >> contextMenu [
	| m |
	m := super contextMenu.
	self isRenameable
		ifTrue: [ 
			m addLine.
			m add: 'rename...' translated action: #editSelector ].
	^ m
]

{ #category : #'instance creation' }
MethodElementMorph >> editSelector [
	header editSelector
]

{ #category : #private }
MethodElementMorph >> fit [
	| bw bw2 cw handle x y editor |
	header ifNil: [ ^ self ].
	bw := self borderWidth.
	bw2 := bw * 2.
	cw := self labelFont widthOf: $ .
	handle := cw.
	header position: (self left + bw + handle) @ self top.
	palette position: (self left + handle) @ header bottom.
	y := palette height = 0
		ifTrue: [ header bottom + (bw * 3) ]
		ifFalse: [ palette bottom ].
	steps position: (self left + bw2 + handle) @ y.
	x := (steps right + bw2 max: palette right) max: header right.
	self width: x - self left.
	palette height = 0
		ifTrue: [ self height: steps height + header height + (bw * 6) ]
		ifFalse: [ self height: steps height + palette height + header height + bw2 ].
	self refreshVarColors.
	(owner respondsTo: #fit)
		ifTrue: [ ^ owner fit ].
	editor := self ownerThatIsA: ElementsMethodEditorMorph.
	editor ifNotNil: [ editor methodModified ]
]

{ #category : #private }
MethodElementMorph >> fitMethod [
	|editor|
	(self findA: StepHolderElementMorph) fitMethod.
	editor := (self ownerThatIsA: ElementsMethodEditorMorph).
	editor ifNotNil: [editor methodModified ]
]

{ #category : #initialize }
MethodElementMorph >> initialize [
	super initialize.
	color := Color paleTan.
	steps color: color slightlyDarker.
	header := MessageHeaderElementMorph new.
	self addMorph: header.
	self fit.
]

{ #category : #testing }
MethodElementMorph >> isRenameable [
	^true
]

{ #category : #accessing }
MethodElementMorph >> localVariableNames [
	^super variableNames
]

{ #category : #'*Phratch-Extensions' }
MethodElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(self ownerThatIsA: ElementsMethodEditorMorph) notNil
		ifTrue: [^nil].
	^super rootForGrabOf: aMorph
]

{ #category : #accessing }
MethodElementMorph >> selector [
	^header selector asSymbol
]

{ #category : #'instance creation' }
MethodElementMorph >> selector: aSymbol arguments: aCollection [
	header selector: aSymbol arguments: aCollection
]

{ #category : #private }
MethodElementMorph >> stackBottom [
	steps contents isNil
		ifTrue: [^self bottom ]
		ifFalse: [^steps contents stack last bottom ]
	
]

{ #category : #enumerating }
MethodElementMorph >> variableNames [
	^super variableNames, header variableNames
]
