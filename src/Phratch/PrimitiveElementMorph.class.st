Class {
	#name : #PrimitiveElementMorph,
	#superclass : #StepElementMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #adding }
PrimitiveElementMorph >> addExpression [
	expression := TextBoxElementMorph new label: 'primitive '.
	self addMorphFront: expression.
]

{ #category : #converting }
PrimitiveElementMorph >> asSmalltalk [
	^'<',expression contents, '>'

]

{ #category : #accessing }
PrimitiveElementMorph >> contents: aString [
	expression label: aString
]

{ #category : #initialize }
PrimitiveElementMorph >> initialize [
	super initialize.
	color := Color yellow darker
]

{ #category : #'dropping/grabbing' }
PrimitiveElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^next isNil & (aMorph isKindOf: StepElementMorph)
]
