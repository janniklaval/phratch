Class {
	#name : #CSlotMorph,
	#superclass : #CommandScriptBlockMorph,
	#instVars : [
		'implicitValue'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #other }
CSlotMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ aBlockMorph isReporter and: [  
		(aBlockMorph isVariableBlockMorph) or: [
			#(autoLambda
			loopLambda
			getLine:ofList:
			getVar:
			procedure
			procedureWithArgs
			doReport
			doCallBlockWithArgs
			doCallBlockWithArgList
			doCustomBlock
			getAttribute:of:
			attribute:of:
		) includes: aBlockMorph selector]]
]

{ #category : #private }
CSlotMorph >> blockAttachPoints: aSet [
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| result |

	result := #().

	nestedBlock
		ifNil: [ result := result copyWith: ((self topLeft + (1@(self topBarHeight + 3))) -> self)]
		ifNotNil: [nestedBlock blockAttachPoints: aSet].

	aSet addAll: result.


]

{ #category : #drawing }
CSlotMorph >> blockWidth [
	| maxWidth |
	maxWidth := 0.
	self firstBlockList do: [:b |
		maxWidth := maxWidth max: b blockWidth ].
	^ 10 "2" + maxWidth
]

{ #category : #drawing }
CSlotMorph >> computeHighlightColors [

	| h s v |
	owner ifNotNil: [
		color = owner color ifFalse: [
			self color: owner color]].
	h := color hue.
	s := color saturation.
	v := color brightness.
	highlightColor1 := Color h: h s: (s - 0.13) v: (v + 0.1).
	shadowColor := color mixed: 0.55 with: Color black.

]

{ #category : #'argument slot behavior' }
CSlotMorph >> defaultValue: default [
	"do nothing"
]

{ #category : #drawing }
CSlotMorph >> drawBottomBarOn: aCanvas [ 

	| left barTop barBottom |

	barBottom := self bottom.

	barTop := barBottom - 3.
	left := self left.

	aCanvas fillRectangle: (left@(barTop - 2) extent: 1@1) color: color.
	aCanvas fillRectangle: (left@(barTop - 1) extent: 2@1) color: color.
	aCanvas fillRectangle: (left@barTop extent: 3@1) color: color.

	aCanvas
		fillRectangle: ((left + 3)@barTop corner: (self right - 1)@(barTop + 1))
		color: highlightColor1.

	aCanvas
		fillRectangle: (self left@(barTop + 1) corner: (self right - 1)@barBottom)
		color: color.

]

{ #category : #drawing }
CSlotMorph >> drawOn: aCanvas [ 

	| c |
	topBarBottom := self top.
	blockBottom := self bottom.
	self computeHighlightColors.
	c := FormCanvas extent: self extent depth: 32.
	c := c copyOffset: self topLeft negated.

	c
		fillRectangle: self bounds
		color: Color lightGray "(color mixed: 0.6 with: Color darkGray)".

	self drawTopBarOn: c.
	self drawVerticalBarOn: c.
	self drawBottomBarOn: c.

	self nestedBlock ifNotNil: [ c paintImage: (nestedBlock imageForm withOutlineColor: Color gray width: 4) 
					at: self position + (1@3) ].

	self drawFinalOn: aCanvas fromCanvas: c.

	self drawInlinePaletteOn: aCanvas.


]

{ #category : #drawing }
CSlotMorph >> drawTopBarOn: aCanvas [ 

	| left right y gapStart gapEnd |

	left := 0.
	right := self width - 1.
	y := topBarBottom - self top.

" ---- original: ---------
	gapStart := left + PuzzleInset + 1.
	gapEnd := gapStart + PuzzleWidth.
"
	gapStart := left + PuzzleInset + 9.
	gapEnd := gapStart + PuzzleWidth - 8.

	nestedBlock ifNil: [
		gapStart := left + PuzzleInset - 4.
		gapEnd := gapStart + PuzzleWidth - 5 ].


	self drawHLineFrom: left to: right y: y color: color on: aCanvas.
	self drawHLineFrom: left to: right y: y + 1 color: color on: aCanvas.

	self drawHLineFrom: left to: (left + 2) y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: left to: (left + 1) y: y + 3 color: color on: aCanvas.
	self drawPoint: (left + 1)@(y + 3) color: shadowColor on: aCanvas.

	self drawHLineFrom: gapStart to: gapEnd y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: color on: aCanvas.

	self drawHLineFrom: (left + 2) to: gapStart y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 1 y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 6 color: shadowColor on: aCanvas.

	self drawPoint: gapStart@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: gapStart@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapStart + 1)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (gapEnd - 1)@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 1)@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 2)@(y + 5) color: shadowColor on: aCanvas.



]

{ #category : #drawing }
CSlotMorph >> drawVerticalBarOn: aCanvas [ 

	| left barRight |
	left := self left.
	barRight := left.

	aCanvas
		fillRectangle: (barRight@(topBarBottom + 4) corner: (barRight + 1)@blockBottom)
		color: shadowColor.

	aCanvas
		fillRectangle: ((self bounds topRight + (-1@0)) corner: (self bounds corner ))
		color: color.

	aCanvas
		fillRectangle: ((self bounds topRight + (-1@2)) corner: (self bounds corner - (0@3)))
		color: color.

]

{ #category : #'argument slot behavior' }
CSlotMorph >> evaluate [

	implicitValue notNil
		ifTrue: [^implicitValue].
	^super evaluate
]

{ #category : #'argument slot behavior' }
CSlotMorph >> evaluateWithArgs: rawArgs [

	implicitValue notNil
		ifTrue: [^implicitValue].
	^super evaluateWithArgs: rawArgs
]

{ #category : #'argument slot behavior' }
CSlotMorph >> fixArgLayout [
	"Fix my layout. This default implementation does nothing."
]

{ #category : #drawing }
CSlotMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| newW newH |
	blockLayoutNeeded ifFalse: [^ self].
	owner ifNotNil: [
		color = owner color ifFalse: [
			self color: owner color]].

	"fix nestedBlock and nextBlock in case they've been removed from me"
	(nestedBlock notNil and: [nestedBlock owner ~~ self]) ifTrue: [nestedBlock := nil].

	newW := 28 max: self blockWidth.

	newH := self topBarHeight + 12 "+ self bracketThickness!".

	nestedBlock
		ifNotNil: [
			stretchHeight := 0.
			nestedBlock fixBlockLayout.
			newH := "newH +" nestedBlock fullBounds height + 10.
			nestedBlock position: self position + (5 "1"@(self topBarHeight + 4)).
			nestedBlock blockSequence last isStopOrForever ifTrue: [newH := newH + 4]].
	self extent: newW@newH


]

{ #category : #'event handling' }
CSlotMorph >> handlesMouseDown: evt [

	^false
]

{ #category : #'argument slot behavior' }
CSlotMorph >> implicitValue: anObject [
	implicitValue := anObject
]

{ #category : #initialization }
CSlotMorph >> initialize [
	super initialize.
	isSpecialForm := true.
	selector := #autoLambda
]

{ #category : #'argument slot behavior' }
CSlotMorph >> isArgMorph [

	^true
]

{ #category : #'argument slot behavior' }
CSlotMorph >> isCSlotMorph [

	^ true
]

{ #category : #'argument slot behavior' }
CSlotMorph >> isEmptySlot [
	^ nestedBlock isNil
]

{ #category : #'argument slot behavior' }
CSlotMorph >> isKindOf: aClass [
	
	^ (aClass = ArgMorph ) or:[ super isKindOf: aClass]

]

{ #category : #'argument slot behavior' }
CSlotMorph >> isLambdaForm [
	^ false
]

{ #category : #other }
CSlotMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	| v |
	v := self evaluate.
	(v isString)
		ifTrue: [ 
			aStream
				nextPutAll: '"';
				nextPutAll: v;
				nextPutAll: '"' ]
		ifFalse: [ aStream nextPutAll: v asString ]
]

{ #category : #drawing }
CSlotMorph >> topBarHeight [
	"Answer the height of the top bar."

	| nonBlockSubmorphs |
	nonBlockSubmorphs := self submorphs select: [:m |
		(m isBlockMorph) not or: [argMorphs includes: m]].
	^ nonBlockSubmorphs inject: 3 into: [:h :m | h max: (m height + 3)].


]

{ #category : #private }
CSlotMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	implicitValue := deepCopier references at: implicitValue ifAbsent: [implicitValue]

]
