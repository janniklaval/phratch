Class {
	#name : #BYOBListWatcherMorph,
	#superclass : #ScratchListMorph,
	#instVars : [
		'list',
		'lastUpdated',
		'isUpdating'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'instance creation' }
BYOBListWatcherMorph class >> on: aBYOBList [

	^ self new list: aBYOBList
]

{ #category : #comparing }
BYOBListWatcherMorph >> = another [

	^ self == another
]

{ #category : #private }
BYOBListWatcherMorph >> createCell: anObject [

	| readout cell font numberRight txt|

	txt := anObject.
	(anObject isKindOf: String)
		ifFalse: [txt := anObject printString].

	font := ScratchFrameMorph getFont: #Watcher.
	readout := ListMultilineStringMorph new
		borderWidth: 0;
		color: Color transparent;
		textColor: Color white;
		growWithText: true;
		contents: txt font: font.
	readout height: ((ScratchTranslator stringExtent: 'A' font: font) y) + 6.
	ScratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].
	ScratchTranslator isRTL
		ifTrue: [readout width: self right - self left - self largestIndexWidth - 33]
		ifFalse: [readout width: self right - numberRight - 25].

	cell := WatcherReadoutFrameMorph new
		color: ScriptableScratchMorph listBlockColor;
		extent: readout extent + 3;
		addMorphBack: readout.

	(anObject isKindOf: String) ifFalse: [
		cell complexObject: anObject ].

	cell position: scrollPane contents bottomLeft.

	"avoid recursive lists"
	scrollPane contents allMorphs detect: [:m | cell allMorphs includes: m] ifNone: [
		scrollPane contents addMorph: cell].

	^ cell

]

{ #category : #'user interaction' }
BYOBListWatcherMorph >> deleteLineAt: aNumber [

	super deleteLineAt: aNumber	.
	list deleteLineAt: aNumber.
	lastUpdated := list lastChanged
]

{ #category : #'user interaction' }
BYOBListWatcherMorph >> focusCell: cellMorph [

	super focusCell: cellMorph.
	lastUpdated := list lastChanged.

]

{ #category : #'user interaction' }
BYOBListWatcherMorph >> focusIndex: anInteger [

	super focusIndex: anInteger.
	lastUpdated := list lastChanged.
	lastActivityIndex := anInteger

]

{ #category : #initialization }
BYOBListWatcherMorph >> initialize [
	super initialize.
	list := BYOBList new.
	lastUpdated := list lastChanged.
	isUpdating := false
]

{ #category : #'user interaction' }
BYOBListWatcherMorph >> insertLine: aString at: aNumber [

	| newCell |
	newCell := super insertLine: aString at: aNumber.
	list insertLine: aString at: aNumber.
	lastUpdated := list lastChanged.
	^ newCell

]

{ #category : #'dropping/grabbing' }
BYOBListWatcherMorph >> justDroppedInto: aMorph event: evt [

	(aMorph isKindOf: ScratchStageMorph) ifTrue: [
		super justDroppedInto: aMorph event: evt.
		self world ifNotNil: [self world startSteppingSubmorphsOf: self].
		^ self].

	"delete me if dropped anywhere but the stage"

"
	self position:  evt hand formerPosition.
	^ self delete

"
]

{ #category : #accessing }
BYOBListWatcherMorph >> list [
	^ list
]

{ #category : #accessing }
BYOBListWatcherMorph >> list: aBYOBList [

	list := aBYOBList.
	self update

]

{ #category : #'event handling' }
BYOBListWatcherMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p listOwner |

	resizeOffset := nil.
	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		^ self delete].

	World activeHand showTemporaryCursor: nil.
	evt hand newKeyboardFocus: nil.
	p := evt cursorPoint.

	((addItemMorph bounds expandBy: 2) containsPoint: p) ifTrue: [
		^ self insertLine: '' at: (self lineCount + 1)].

	((addSublistMorph bounds expandBy: 2) containsPoint: p) ifTrue: [
		^ list insertLine: BYOBList new at: (self lineCount + 1)].

	listOwner := self listOwner.
	(((deleteMorph bounds expandBy: 2) containsPoint: p) and: [listOwner notNil]) ifTrue: [
		^ listOwner list deleteLineAt: (listOwner indexOf: self list)].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			((resizeMorph bounds expandBy: 4) containsPoint: p)
				ifFalse: [evt hand grabMorph: self]
				ifTrue: [resizeOffset := self bottomRight - p]].

]

{ #category : #private }
BYOBListWatcherMorph >> noteChangeAtIndex: index [

	self updateContents


]

{ #category : #private }
BYOBListWatcherMorph >> privateInsertLine: anObject at: aNumber [

	| index newCell |

"
	(anObject isKindOf: list class) ifTrue: [
		(anObject containsRecursive: list) ifTrue: [
			self error: 'attempting to create a recursive list']].
"

	index := aNumber asInteger.
	(index > 0 and: [index <= (cellMorphs size + 1)]) ifFalse: [
		lastActivityError := true.
		^ self].

	newCell := self createCell: anObject.
	index = 1
		ifTrue: [cellMorphs addFirst: newCell]
		ifFalse: [
			index > cellMorphs size
				ifTrue: [cellMorphs addLast: newCell]
				ifFalse: [cellMorphs add: newCell afterIndex: index - 1]].

	self updateCountMorph.

	self updateContents.

"	self noteChangeAtIndex: index."
	^ newCell

]

{ #category : #updating }
BYOBListWatcherMorph >> scrollActiveCellIntoView [

	"override my superclass behavior - do nothing"
]

{ #category : #'user interaction' }
BYOBListWatcherMorph >> setLineAt: aNumber to: newContents [

	super setLineAt: aNumber to: newContents.
	list setLineAt: aNumber to: newContents.
	lastUpdated := list lastChanged


]

{ #category : #stepping }
BYOBListWatcherMorph >> step [

	lastUpdated = list lastChanged
		ifTrue: [^ self].

	self update.
	super step
]

{ #category : #updating }
BYOBListWatcherMorph >> update [

	isUpdating ifTrue: [^ self].
	isUpdating := true.
	self clear.
	1 to: list size do: [:i |
		self privateInsertLine: (list at: i) at: i].
	self layoutChanged.
	lastUpdated := list lastChanged.
	isUpdating := false.
		
]

{ #category : #updating }
BYOBListWatcherMorph >> updateList [
	list contents: self asArray asOrderedCollection.
	lastUpdated := list lastChanged
]
