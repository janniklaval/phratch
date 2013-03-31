Class {
	#name : #ListMultilineStringMorph,
	#superclass : #MultilineStringMorph,
	#instVars : [
		'deleteMorph'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #byob }
ListMultilineStringMorph >> drawTextOn: aCanvas [

	|rf|
	rf := self ownerOrYourselfThatIsA: WatcherReadoutFrameMorph.
	rf ifNotNil: [((rf complexObject isKindOf: Morph) or: [rf complexObject isKindOf: BYOBList])
		ifTrue: [^ self ]].

	super drawTextOn: aCanvas
]

{ #category : #geometry }
ListMultilineStringMorph >> extent: aPoint [

	super extent: aPoint.
	self fixLayout.

]

{ #category : #private }
ListMultilineStringMorph >> fixLayout [

	| readout |
	readout := self ownerOrYourselfThatIsA: WatcherReadoutFrameMorph.
	readout ifNotNil: [
		(readout complexObject isKindOf: BYOBList) ifTrue: [^self].
		(readout complexObject isKindOf: ScratchListMorph) ifTrue: [^self].
		(readout complexObject isKindOf: ScriptableScratchMorph) ifTrue: [^self].
		deleteMorph position: (readout bottomRight) - (deleteMorph extent) - (3@5)]
]

{ #category : #'event handling' }
ListMultilineStringMorph >> handlesKeyboard: evt [
^true  
]

{ #category : #'event handling' }
ListMultilineStringMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
ListMultilineStringMorph >> initialize [

	super initialize.
	deleteMorph := (ImageMorph new form: (ScratchFrameMorph skinAt: #deleteItem)).
   
]

{ #category : #byob }
ListMultilineStringMorph >> isList [

	|rf|
	rf := self ownerOrYourselfThatIsA: WatcherReadoutFrameMorph.
	rf ifNotNil: [^ ((rf complexObject isKindOf: ScratchListMorph) or: [
		rf complexObject isKindOf: BYOBList])].
	^ false

]

{ #category : #'event handling' }
ListMultilineStringMorph >> keyStroke: evt [

	| ch ownerList newCell oldH |
	ch := evt keyValue.
	ownerList := self ownerOrYourselfThatIsA: ScratchListMorph.

	"insert list item with cr"
	(ch = 3) & (evt buttons = 0) ifTrue: [ch := 13].	"map enter key to cr"
	(ch = 13) ifTrue: [
		ownerList ifNotNil:[
			newCell := ownerList insertLine: '' at: ownerList focusIndex + 1. 
			ownerList focusCell: newCell].
		^ self].

	"skip to previous list item with tab or down arrow"
	(ch = 30) ifTrue: [
		ownerList ifNotNil:[
			ownerList focusIndex: ownerList focusIndex - 1].
		^ self].

	"skip to next list item with tab or down arrow"
	(ch = 9) | (ch = 31) ifTrue: [
		ownerList ifNotNil:[
			ownerList focusIndex: ownerList focusIndex + 1].
		^ self].

	oldH := self height.
	super keyStroke: evt.
	(ownerList notNil and: [self height ~= oldH]) ifTrue: [
		ownerList extent: ownerList extent].  "force re-layout"
	self fixLayout.

]

{ #category : #'event handling' }
ListMultilineStringMorph >> keyboardFocusChange: aBoolean [

	super keyboardFocusChange: aBoolean.
	hasFocus
		ifTrue: [
			self textColor: (Color gray: 0.15).
			self owner color: (ScriptableScratchMorph listBlockColor mixed: 0.4 with: Color white).
			self addMorphBack: deleteMorph.
			self fixLayout]
		ifFalse: [
			self textColor: Color white.
			self owner color: ScriptableScratchMorph listBlockColor.
			deleteMorph delete].

]

{ #category : #byob }
ListMultilineStringMorph >> list [

	|rf|
	rf := self ownerOrYourselfThatIsA: WatcherReadoutFrameMorph.
	rf ifNotNil: [((rf complexObject isKindOf: ScratchListMorph) or: [
		rf complexObject isKindOf: BYOBList])
			ifTrue: [ (rf complexObject isKindOf: BYOBList)
				ifTrue: [^ rf submorphs detect: [:sm | sm isKindOf: BYOBListWatcherMorph] ifNone: [nil]]
				ifFalse: [^ rf complexObject]]].
	^ nil

]

{ #category : #'event handling' }
ListMultilineStringMorph >> mouseDown: evt [

	| list p ownerList i |

	self isInWorld ifFalse: [^ self].  "not editable in presentation mode"
	self isList ifTrue: [^ self list mouseDown: evt].
	super mouseDown: evt.
	p := evt cursorPoint.

	(list := self ownerOrYourselfThatIsA: ScratchListMorph)
		ifNotNil: [list focusCell: owner].

	ownerList := self ownerThatIsA: ScratchListMorph.
	((deleteMorph bounds expandBy: 4) containsPoint: p) ifTrue: [
		(ownerList notNil) ifTrue: [
			i := ownerList indexOfCell: self owner. 
			ownerList deleteLineAt: i.
			(ownerList listContents size > (i - 1))
				ifTrue: [ownerList focusIndex: i]
				ifFalse: [ownerList focusIndex: i - 1]]].

]
