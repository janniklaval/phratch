"
I am used as the title for a named event hat. I have a popup list of events that includes a way to type in a new event name.

Unlike other kind of ArgMorph, I can't be replaced with a reporter.


"
Class {
	#name : #EventTitleMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'menuIconMorph'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #queries }
EventTitleMorph >> acceptsDroppedReporters [
	"Accept reporter blocks in broadcast blocks but not in 'when I receive' hat block."

	^ owner isKindOf: CommandBlockMorph

]

{ #category : #queries }
EventTitleMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type."

	aBlockMorph isReporter ifFalse: [^ false].
	(aBlockMorph isKindOf: ColorBlockMorph) ifTrue: [^ false].
	^ aBlockMorph isBooleanReporter not

]

{ #category : #accessing }
EventTitleMorph >> defaultValue: aString [

	self eventName: aString.

]

{ #category : #accessing }
EventTitleMorph >> evaluate [

	^ self eventName

]

{ #category : #accessing }
EventTitleMorph >> eventName [

	^ labelMorph contents

]

{ #category : #accessing }
EventTitleMorph >> eventName: aString [

	| |
	labelMorph contents: aString asString.
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: (labelMorph extent + (16@2) + borderWidth).
	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(owner isKindOf: BlockMorph) ifTrue: [
		(owner respondsTo: #addLabel)
			ifTrue: [owner addLabel]
			ifFalse: [owner fixBlockLayout]]
]

{ #category : #accessing }
EventTitleMorph >> fixArgLayout [
	"Set my color to my owner's color."

	self color: (owner color mixed: 0.75 with: (Color gray: 0.4)).

]

{ #category : #'event handling' }
EventTitleMorph >> handlesMouseDown: evt [

	^ evt hand toolType isNil and:
		[(self topRight - (14@0) corner: self bottomRight) containsPoint: evt cursorPoint]

]

{ #category : #initialization }
EventTitleMorph >> initialize [

	super initialize.
	self borderInset.
	self borderWidth: 1.
	self color: Color brown.

	menuIconMorph := ImageMorph new form: DropDownMenuForm.
	self addMorphFront: menuIconMorph.

	labelMorph := StringMorph new
		font: (PhratchFrameMorph getFont: #Arg);
		forceUnicodeRendering: true;
		color: Color white;
		yourself.
	self addMorph: labelMorph.
	self eventName: ''.

]

{ #category : #'event handling' }
EventTitleMorph >> mouseDown: evt [

	self presentMenu.

]

{ #category : #'event handling' }
EventTitleMorph >> newEvent [
	| s |
	s := StringDialog ask: 'Message name:'.
	s size = 0
		ifTrue: [ ^ self ].
	self eventName: s
]

{ #category : #'event handling' }
EventTitleMorph >> presentMenu [
	"Pop up a menu of choices."

	| eventNames sFrame menu be |
	eventNames := #().

	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sFrame ifNil: [
		be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
		be ifNotNil: [sFrame := be phratchFrame]].

	sFrame ifNotNil: [eventNames := sFrame workPane allEventNames].

	menu := MenuMorph new defaultTarget: self.
	eventNames do: [ :n | menu add: n
		target: self 
		selector: #eventName:
		argument: n asString ].
	menu addLine.
	menu
		add: 'new' localized , PhratchTranslator ellipsesSuffix
		target: self
		selector: #newEvent.

	menu invokeModal
]

{ #category : #accessing }
EventTitleMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	aStream nextPut: $".
	aStream nextPutAll: self labelMorph contents.
	aStream nextPut: $".

]
