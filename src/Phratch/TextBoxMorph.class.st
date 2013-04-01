"
This was going to be used to represent lists, but we went in a different direction.

"
Class {
	#name : #TextBoxMorph,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'contentsMorph',
		'resizeMode'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #operations }
TextBoxMorph >> addLine: anObject [

	| s |
	s := (anObject isKindOf: String) ifTrue: [anObject] ifFalse: [anObject printString].
	contentsMorph moveCursorContentsEnd.
	s size = 0 ifTrue: [s := String cr].
	contentsMorph lines last isEmpty ifFalse: [s := String cr, s].
	contentsMorph insertString: s.

]

{ #category : #operations }
TextBoxMorph >> addWord: anObject [

	| s |
	s := (anObject isKindOf: String) ifTrue: [anObject] ifFalse: [anObject printString].
	contentsMorph moveCursorContentsEnd.
	contentsMorph lines last isEmpty ifFalse: [s := ' ', s].
	contentsMorph insertString: s.

]

{ #category : #operations }
TextBoxMorph >> clear [

	contentsMorph contents: ''.

]

{ #category : #operations }
TextBoxMorph >> contents [

	^ contentsMorph contents

]

{ #category : #'event handling' }
TextBoxMorph >> extent: aPoint [

	super extent: aPoint.
	contentsMorph ifNotNil: [self fixLayout].

]

{ #category : #'event handling' }
TextBoxMorph >> fixLayout [

	contentsMorph position: self position + (10@10).
	contentsMorph extent: self extent - (20@20).
]

{ #category : #'event handling' }
TextBoxMorph >> handlesMouseDown: evt [

	^ ((self bounds insetBy: 17) containsPoint: evt cursorPoint) not
]

{ #category : #initialization }
TextBoxMorph >> initialize [

	super initialize.
	self initFromForm: (PhratchFrameMorph skinAt: #btn).
	contentsMorph := ScrollingStringMorph new
		contents: '';
		borderColor: (Color gray: 0.6);
		borderWidth: 1.

	self addMorph: contentsMorph.
	self extent: 140@210.
	self fixLayout.

]

{ #category : #operations }
TextBoxMorph >> insertLine: aString at: lineIndex [

	| lines n newContents |
	lines := contentsMorph contents lines asOrderedCollection.
	n := lineIndex truncated.
	n > lines size ifTrue: [n := lines size].
	n < 1 ifTrue: [n := 1].
	lines insert: aString before: n.

	newContents := WriteStream on: (String new: 1000).
	lines do: [:s | newContents nextPutAll: s; cr].
	contentsMorph contents: newContents contents.

]

{ #category : #operations }
TextBoxMorph >> isNumber: aString [

	| n |
	aString size = 0 ifTrue: [^ false].
	('-.0123456789' includes: aString first) ifFalse: [^ false].
	n := [aString asNumber] ifError: [nil].
	n ifNil: [^ false].
	^ n printString = aString

]

{ #category : #operations }
TextBoxMorph >> line: lineIndex [

	| lines n |
	lines := contentsMorph contents lines asOrderedCollection.
	lines size = 0 ifTrue: [^ ''].
	n := lineIndex truncated.
	(n < 1) | (n > lines size) ifTrue: [^ ''].

	^ lines at: n


]

{ #category : #operations }
TextBoxMorph >> lineCount [

	^ contentsMorph contents lines size

]

{ #category : #'event handling' }
TextBoxMorph >> mouseDown: evt [

	| edgeW bottomW |
	resizeMode := nil.

	evt cursorPoint y < (self top + 50) ifTrue: [
		evt hand grabMorph: self.
		^ self].

	edgeW := 30.
	bottomW := 30.
	((evt cursorPoint x - self left) < edgeW) ifTrue: [
		(self bottom - evt cursorPoint y) < bottomW
			ifTrue: [resizeMode := #bottomLeft]
			ifFalse: [resizeMode := #left].
		^ self].

	((self right - evt cursorPoint x) < edgeW) ifTrue: [
		(self bottom - evt cursorPoint y) < bottomW
			ifTrue: [resizeMode := #bottomRight]
			ifFalse: [resizeMode := #right].
		^ self].

	(self bottom - evt cursorPoint y) < edgeW ifTrue: [resizeMode := #bottom].

]

{ #category : #'event handling' }
TextBoxMorph >> mouseMove: evt [

	| x y |
	resizeMode ifNil: [^ self].

	x := evt cursorPoint x.
	y := evt cursorPoint y.
	#left = resizeMode ifTrue: [
		^ self bounds: (x@self top corner: self bottomRight)].
	#right = resizeMode ifTrue: [
		^ self bounds: (self topLeft corner: x@self bottom)].
	#bottom = resizeMode ifTrue: [
		^ self bounds: (self topLeft corner: self right@y)].
	#bottomLeft = resizeMode ifTrue: [
		^ self bounds: (x@self top corner: self right@y)].
	#bottomRight = resizeMode ifTrue: [
		^ self bounds: (self topLeft corner: evt cursorPoint)].

]

{ #category : #operations }
TextBoxMorph >> removeLine: lineIndex [

	| lines n result newContents |
	lines := contentsMorph contents lines asOrderedCollection.
	n := lineIndex truncated.
	((n < 1) or: [n > lines size]) ifTrue: [^ ''].
	result := lines at: n.
	lines removeIndex: n.

	newContents := WriteStream on: (String new: 1000).
	lines do: [:s | newContents nextPutAll: s; cr].
	contentsMorph contents: newContents contents.

	^ result


]

{ #category : #operations }
TextBoxMorph >> reverse [

	| out allLines |
	allLines := contentsMorph contents lines.
	out := WriteStream on: (String new: 1000).
	allLines reverseDo: [:s | out nextPutAll: s; cr].

	contentsMorph contents: out contents.


]

{ #category : #operations }
TextBoxMorph >> sort [

	| allLines numbers strings words sorted |
	allLines := contentsMorph contents lines.
	numbers := OrderedCollection new: allLines size.
	strings := OrderedCollection new: allLines size.
	allLines do: [:s |
		words := s findTokens: ' 	'.
		words size > 0
			ifTrue: [
				(self isNumber: words first)
					ifTrue: [numbers add: (Array with: words first with: s)]
					ifFalse: [strings add: (Array with: words first with: s)]]
			ifFalse: [
				strings add: (Array with: '' with: s)]].

	strings := strings asArray sort: [:e1 :e2 | e1 first caseInsensitiveLessOrEqual: e2 first].
	numbers := numbers asArray sort: [:e1 :e2 | e1 first asNumber < e2 first asNumber].

	sorted := WriteStream on: (String new: 1000).
	numbers do: [:e | sorted nextPutAll: e second; cr].
	strings do: [:e | sorted nextPutAll: e second; cr].

	contentsMorph contents: sorted contents.


]

{ #category : #operations }
TextBoxMorph >> word: wordIndex of: aString [

	| words n |
	words := aString findTokens: ' 	'.
	words size = 0 ifTrue: [^ ''].
	n := wordIndex truncated.
	(n < 1) | (n > words size) ifTrue: [^ ''].
	^ words at: n


]

{ #category : #operations }
TextBoxMorph >> wordCount: aString [

	^ (aString findTokens: ' 	') size

]
