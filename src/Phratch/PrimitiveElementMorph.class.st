Class {
	#name : #PrimitiveElementMorph,
	#superclass : #StepElementMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #'as yet unclassified' }
PrimitiveElementMorph >> addExpression [
	expression := TextBoxElementMorph new label: 'primitive '.
	self addMorphFront: expression.
]

{ #category : #'as yet unclassified' }
PrimitiveElementMorph >> asSmalltalk [
	^'<',expression contents, '>'

]

{ #category : #'as yet unclassified' }
PrimitiveElementMorph >> contents: aString [
	expression label: aString
]

{ #category : #'as yet unclassified' }
PrimitiveElementMorph >> initialize [
	super initialize.
	color := Color yellow darker
]

{ #category : #'as yet unclassified' }
PrimitiveElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^next isNil & (aMorph isKindOf: StepElementMorph)
]
