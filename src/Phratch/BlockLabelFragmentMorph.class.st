Class {
	#name : #BlockLabelFragmentMorph,
	#superclass : #ScratchStringMorph,
	#instVars : [
		'labelFragment'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> handlesMouseOverDragging: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> initialize [
	super initialize.
	labelFragment := BlockLabelFragment new
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> labelFragment [
	^labelFragment
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> labelFragment: fragment [
	labelFragment := fragment
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> mouseDown: evt [
	"Handle a mouse down event"

	| old frag |
	owner isFrozen 
		ifTrue: [^ self]
		ifFalse: [owner isFrozen: true].

	old := labelFragment deepCopy.
	frag := BlockLabelFragmentDialog on: labelFragment category: owner category.

	owner
		isFrozen: false;
		hideArgumentPlaceHolders.
	self color: Color white.

	frag = #cancelled ifTrue: [
		labelFragment := old.
		^ self].
	owner updateSpecWithDnDSpec
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> mouseEnter: evt [

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self.

]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> mouseEnterDragging: evt [

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> mouseLeave: evt [

	owner isFrozen 
		ifTrue: [^ self].
	self color: Color white
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> mouseLeaveDragging: evt [

	(owner notNil and: [owner isFrozen])
		ifTrue: [^ self].
	self color: Color white
]

{ #category : #'as yet unclassified' }
BlockLabelFragmentMorph >> updateFragment [

	labelFragment
		isInput: false;
		label: self contents
]
