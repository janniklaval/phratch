"
Frame to hold the readout of a WatcherMoroph.

"
Class {
	#name : #WatcherReadoutFrameMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'frameLayoutNeeded',
		'complexObject'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #encapsulatedScripts }
WatcherReadoutFrameMorph >> complexObject [
	^complexObject
]

{ #category : #encapsulatedScripts }
WatcherReadoutFrameMorph >> complexObject: anObject [
	| newListWatcher |

	complexObject := anObject.

	(anObject isKindOf: PhratchListMorph) ifTrue: [
		submorphs := submorphs copyWithout: anObject.
		anObject position: self position + 5.
		self addMorphBack: anObject.
		anObject fixLayout.
		anObject startStepping.
		^ self].

	(anObject isKindOf: BYOBList) ifTrue: [
		newListWatcher := BYOBListWatcherMorph new 
							listName: '' target: nil; 
							list: anObject; 
							updateCountMorph; 
							yourself.
		newListWatcher fixLayout.
		submorphs := submorphs reject: [:each |
			each isKindOf: newListWatcher class ].
		newListWatcher position: self position + 5.
		self addMorphBack: newListWatcher.
		newListWatcher fixLayout.
		newListWatcher startStepping]
]

{ #category : #drawing }
WatcherReadoutFrameMorph >> drawBorderOn: aCanvas [

	"border lines"
	aCanvas
		line: (self topLeft + (2@0)) to: (self topRight - (3@0)) color: borderColor;
		line: (self topLeft + (0@2)) to: (self bottomLeft - (0@3)) color: borderColor;
		line: (self bottomLeft + (2@(-1))) to: (self bottomRight - (3@1)) color: borderColor;
		line: (self bottomRight - (1@3)) to: (self topRight + ((-1)@2)) color: borderColor.

	"border corners"
	aCanvas
		line: (self topLeft + (1@1)) to: (self topLeft + (1@1)) color: borderColor;
		line: (self topRight - (2@(-1))) to: (self topRight - (2@(-1))) color: borderColor;
		line: (self bottomRight - (2@2)) to: (self bottomRight - (2@2)) color: borderColor;
		line: (self bottomLeft - ((-1)@2)) to: (self bottomLeft - ((-1)@2)) color: borderColor.

]

{ #category : #drawing }
WatcherReadoutFrameMorph >> drawOn: aCanvas [

	"fill inside"
	aCanvas
		fillRectangle: (Rectangle origin: (self topLeft + (2@1)) corner: (self bottomRight - (2@1))) color: color;
		fillRectangle: (Rectangle origin: (self topLeft + (1@2)) corner: (self bottomRight - (1@2))) color: color.

	"white border"
	self drawBorderOn: aCanvas.

	"inner shadows"
	aCanvas
		line: (self topLeft + (2@1)) to: (self topRight - (3@(-1))) color: (self color darker darker);
		line: (self topLeft + (1@2)) to: (self bottomLeft - (-1@3)) color: (self color darker darker);
		line: (self topLeft + (2@2)) to: (self topRight - (3@(-2))) color: (self color darker);
		line: (self topLeft + (2@2)) to: (self bottomLeft - (-2@2)) color: (self color darker);
		line: (self bottomLeft - (-2@2)) to: (self bottomRight - (3@2)) color: (self color darker);
		line: (self topRight - (2@(-2))) to: (self bottomRight - (2@3)) color: (self color darker).

	(complexObject isKindOf: Morph) ifTrue: [
		| form |
		(complexObject respondsTo: #displayForm)
			ifTrue: [form := complexObject displayForm]
			ifFalse: [ (complexObject respondsTo: #thumbnailImageForm)
				ifTrue: [form := complexObject thumbnailImageForm]
				ifFalse: [form := complexObject imageForm]].
		aCanvas paintImage: form at: self position + (5@5)]


]

{ #category : #'object i/o' }
WatcherReadoutFrameMorph >> fieldsVersion [

	^ 1

]

{ #category : #encapsulatedScripts }
WatcherReadoutFrameMorph >> fixLayout [

	| watcher readout isLarge s e readoutWidth yOffset w inset blist |

	((submorphs size = 1) and: [submorphs first isKindOf: PhratchStringMorph]) ifFalse: [^ self].

	watcher := self ownerOrYourselfThatIsA: WatcherMorph.
	readout := submorphs first.

	isLarge := watcher ifNil: [false] ifNotNil: [watcher isLarge].
	s := readout contents.
	isLarge
		ifTrue: [self width: 50]
		ifFalse: [self width: 40].

	(s isKindOf: Form) 
		ifTrue: [
			readout extent: s extent.

			self extent: readout extent +( 10@10).
			readout position: self position + (5@5).
			^self layoutChanged ]

		ifFalse: [
			blist := submorphs detect: [:sm | sm isKindOf: BYOBListWatcherMorph] ifNone: [nil].
			blist ifNotNil: [
				readout extent: blist extent.
				self extent: blist extent +( 10@10).
				readout position: self position + (5@5).
				^self layoutChanged ]].

	e := PhratchTranslator stringExtent: s font: readout font.
	readoutWidth := e x.
	(readoutWidth + 10) > self width ifTrue: [self width: readoutWidth + 12].
	self width > (readoutWidth + 50) ifTrue: [self width: readoutWidth + 50].

	readout contents: (UTF8 withAll: readout contents).
	"set height"
	isLarge
		ifTrue: [self height: (e y max: 23)]
		ifFalse: [self height: (e y max: 14)].

	yOffset := (self height // 2) - (PhratchTranslator centerOffsetForButtonWithFont: readout font) + 1.
	(((s indexOf: $.) = (s size - 2)) and: [((s indexOf: $.) = 0) not]) "one digit after the decimal point"
		ifTrue: [  "right-justify the string"
			w := (PhratchTranslator stringExtent: (s copyUpTo: $.) font: readout font) x.
			inset := (PhratchTranslator stringExtent: '.0' font: readout font) x.
			self isLarge ifTrue: [inset := inset + 1].
			readout position: self topRight - ((w + inset + 5) @ (-1 * yOffset))]
		ifFalse: [
			readout position: self position + (((self width - readoutWidth) // 2) @ yOffset)].
	(readout bottom > self bottom) ifTrue: [readout bottom: self bottom].
	(readout top < self top) ifTrue: [readout top: self top].

	isLarge ifFalse: [
		watcher  ifNotNil: [watcher layoutForViewer]].

	self layoutChanged.

]

{ #category : #initialization }
WatcherReadoutFrameMorph >> initialize [

	super initialize.
	borderColor := Color white.

]

{ #category : #accessing }
WatcherReadoutFrameMorph >> isLarge [
	"Support for reading old Watchers; do not remove!"

	^ submorphs size > 0 and: [self firstSubmorph font pointSize > 10]

]