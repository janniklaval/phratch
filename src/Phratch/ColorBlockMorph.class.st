Class {
	#name : #ColorBlockMorph,
	#superclass : #ReporterBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
ColorBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block := self new.
	^block
]

{ #category : #other }
ColorBlockMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^aBlockMorph isReporter and:[ aBlockMorph isKindOf: ColorBlockMorph]
]

{ #category : #watcher }
ColorBlockMorph >> createWatcher [
	"Return a new watcher for me."

	| newWatcher |
	newWatcher := WatcherMorph new isColor: true; buildReadout; setCategoryColor: self color;
		yourself.
	self argumentCount = 1
		ifTrue: [newWatcher target: receiver selector: selector parameter: self args first]
		ifFalse: [newWatcher target: receiver selector: selector parameter: nil].

	^ newWatcher
]

{ #category : #drawing }
ColorBlockMorph >> drawOn: aCanvas [ 

	| right topY bottomY xInset c |
	self computeHighlightColors.

"	BlockMorph graphicsQuality = #fast ifTrue: [
		aCanvas fillRectangle: (self position corner: (self position + self extent - (1@1))) color: highlightColor1.
		aCanvas fillRectangle: (self position + (1@1) corner: (self position + self extent - (1@1))) color: shadowColor.
		aCanvas fillRectangle: (self position + (1@1) corner: (self position + self extent - (2@2))) color: color.
		^ self]."

	right := self width.
	topY := bottomY := self height // 2.
	self height even ifTrue: [topY := bottomY - 1].
	xInset := 0.
	[topY >= 0] whileTrue: [
		topY = 0 ifTrue: [c := (highlightColor1 mixed: ((self height // 2) - topY / (self height) + 0.5) with: highlightColor1 dansDarker)].
		topY = 1 ifTrue: [c := (highlightColor2 mixed: ((self height // 2) - topY / (self height) + 0.5) with: highlightColor2 dansDarker)].
		topY > 1 ifTrue: [c := color lighter mixed: ((self height // 2) - topY / (self height) + 0.5) with: color dansDarker].
		self drawHLineFrom: 0 to: right y: topY color: c on: aCanvas.
		(topY > 1)" & (xInset > 0)" ifTrue: [
			self drawPoint: 0@topY color: (highlightColor1 mixed: ((self height // 2) - topY / (self height) + 0.5) with: highlightColor1 dansDarker) on: aCanvas.
			self drawPoint: 1@topY color: (highlightColor2 mixed: ((self height // 2) - topY / (self height) + 0.5) with: highlightColor2 dansDarker) on: aCanvas.
			self drawPoint: (right - 1)@topY color: (shadowColor mixed: ((self height // 2) - topY / (self height) + 0.5) with: shadowColor dansDarker) on: aCanvas].

		c := bottomY = (self height - 1) ifTrue: [(shadowColor mixed: (topY / (self height // 2) - 0.5) with: shadowColor dansDarker)] ifFalse: [color lighter mixed: (topY / (self height // 2) - 0.5) with: color dansDarker].
		self drawHLineFrom: 0 to: right y: bottomY color: c on: aCanvas.
		"xInset > 0 ifTrue: ["
			self drawPoint: 0@bottomY color: (highlightColor1 mixed: (topY / (self height // 2) - 0.5) with: highlightColor1 dansDarker) on: aCanvas.
			self drawPoint: 1@bottomY color: (highlightColor2 mixed: (topY / (self height // 2) - 0.5) with: highlightColor2 dansDarker) on: aCanvas.
			self drawPoint: (right - 1)@bottomY color: (shadowColor mixed: (topY / (self height // 2) - 0.5) with: shadowColor dansDarker) on: aCanvas"]".

		xInset := xInset + 1.	
		bottomY := bottomY + 1.
		topY := topY - 1].
		
]

{ #category : #other }
ColorBlockMorph >> showValue [

	| gotError msg tooltip w worldBounds |
	gotError := false.
	msg := ''.
	[self evaluate asString] ifError: [
		gotError := true.
		msg := 'Error!'. PhratchError error].

	msg := msg localized.
	tooltip := (PhratchReporterToolTipMorph string: msg for: self)
		left: self right;
		bottom: self top;
		yourself.
	PhratchTranslator isRTL ifTrue: [tooltip right: self left].
	gotError
		ifTrue: [tooltip messageColor: Color red darker]
		ifFalse: [tooltip addMorphFront: (BorderedMorph new color: self evaluate; position: (tooltip position + (6@2)); extent: 12@12; borderWidth: 1;
		yourself); extent: (24@17)].
	w := self world.
	w addMorphFront: tooltip.
	((worldBounds := w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].

	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping.
]
