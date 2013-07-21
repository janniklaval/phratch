Class {
	#name : #StepHolderElementMorph,
	#superclass : #ArgumentElementMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #'as yet unclassified' }
StepHolderElementMorph >> asSmalltalk [
	|stack ws|
	contents ifNil: [^''].
	stack := contents stack.
	ws := WriteStream on: String new.
	stack do: [:eachStep|
		ws nextPutString: eachStep asSmalltalk.
		(eachStep == stack last)
			ifFalse: [ws nextPut: $.;cr]].
	^ws contents
]

{ #category : #'as yet unclassified' }
StepHolderElementMorph >> drawOn: aCanvas [ 

	|r bw indent dent bw2 bw3 |

"	contents ifNotNil: [^aCanvas fillRectangle: self bounds color: owner color]."
	bw := self borderWidth.
	bw2 := bw * 2.
	bw3 := bw * 3.
	indent := bw * 5.
	dent := bw * 5.

	"border"
	"top"
	r := Rectangle origin: ((self left + bw) @ self top) corner: (self left + indent + bw) @ (self top + bw).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	r := Rectangle origin: ((self left + indent) @ (self top + bw)) corner: (self left + indent + bw) @ (self top + bw3).
	aCanvas fillRectangle: r color: self borderColorLight.

	r := Rectangle origin: ((self left + indent + bw) @ (self top + bw2)) corner: (self left + indent + dent + bw) @ (self top + bw3).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	r := Rectangle origin: ((self left + indent + dent) @ (self top)) corner: (self left + indent + dent + bw) @ (self top + bw2).
	aCanvas fillRectangle: r color: self borderColorDark.

	r := Rectangle origin: ((self left + indent + dent + bw) @ (self top)) corner: (self right) @ (self top + bw).
	aCanvas fillRectangle: r color: self borderColorVeryDark.


	"left"
	r := Rectangle origin: (self topLeft) corner: (self left + bw) @ (self bottom - bw3).
	aCanvas fillRectangle: r color: self borderColorDark.

	"right"
	r := Rectangle origin: ((self right - bw) @ (self top + bw)) corner: (self right @ (self bottom - bw2)).
	aCanvas fillRectangle: r color: self borderColorLight.

	"bottom"
	r := Rectangle origin: (self left @ (self bottom - bw3)) corner: (self right - bw) @ (self bottom - bw2).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

"	r := Rectangle origin: (self left @ (self bottom - bw3)) corner: (self left + indent) @ (self bottom - bw2).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	r := Rectangle origin: (self left + indent) @ (self bottom - bw3) corner: (self left + indent + bw) @ (self bottom - bw).
	aCanvas fillRectangle: r color: self borderColorDark.

	r := Rectangle origin: (self left + indent) @ (self bottom - bw) corner: (self left + indent + dent - bw) @ (self bottom).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	r := Rectangle origin: (self left + indent + dent - bw) @ (self bottom - bw2) corner: (self left + indent + dent) @ (self bottom).
	aCanvas fillRectangle: r color: self borderColorLight.

	r := Rectangle origin: (self left + indent + dent - bw) @ (self bottom - bw3) corner: (self right - bw) @ (self bottom - bw2).
	aCanvas fillRectangle: r color: self borderColorVeryLight.
"
	"body"
	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw3) corner: (self right - bw) @ (self bottom - bw3)) color: color.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw) corner: (self left + indent) @ (self top + bw3)) color: color.

	aCanvas fillRectangle: (Rectangle origin: (self left + indent + dent + bw) @ (self top + bw) corner: (self right - bw) @ (self top + bw3)) color: color.

"	aCanvas fillRectangle: (Rectangle origin: (self left + indent + bw) @ (self bottom - bw3) corner: (self left + indent + dent - bw) @ (self bottom - bw)) color: color."

]

{ #category : #'as yet unclassified' }
StepHolderElementMorph >> fit [
	| h |

	(owner isKindOf: MethodElementMorph) & (self ownerThatIsA: ElementsMethodEditorMorph) notNil
		ifTrue: [ ^self fitMethod ].

	contents isNil
		ifTrue: [
			h := MessageElementMorph labelFont height.
			self extent: (h * 1.8) @ (h * 1.2)]
		ifFalse: [
			(owner isKindOf: MethodElementMorph).
			self extent: contents stackExtent  + (self borderWidth * 2).
			contents position: bounds center - (contents stackExtent // 2) ].
	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #'as yet unclassified' }
StepHolderElementMorph >> fitMethod [
	| h |
	h := MessageElementMorph labelFont height.
	self extent: (h * 1.8) @ (h * 1.2).
	contents ifNotNil: [
		contents position: self position + self borderWidth].
	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #'as yet unclassified' }
StepHolderElementMorph >> mouseEnterDragging: evt [
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	| m |
	evt hand hasSubmorphs ifFalse: [^self].
	m := evt hand submorphs first.
	(self wantsDroppedMorph: m event: evt)
		ifTrue: [
			self extent: m stackExtent  + (self borderWidth * 2).
			self hilite .
			(owner respondsTo: #fit)
			ifTrue: [owner fit]]
]

{ #category : #'as yet unclassified' }
StepHolderElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^contents isNil & (aMorph isKindOf: StepElementMorph) & (self ownerThatIsA: ElementPaletteMorph) isNil


]
