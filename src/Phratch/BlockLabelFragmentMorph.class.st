Class {
	#name : #BlockLabelFragmentMorph,
	#superclass : #StringMorph,
	#instVars : [
		'labelFragment'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #widgets }
BlockLabelFragmentMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #widgets }
BlockLabelFragmentMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #'event handling' }
BlockLabelFragmentMorph >> handlesMouseOverDragging: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #initialization }
BlockLabelFragmentMorph >> initialize [
	super initialize.
	labelFragment := BlockLabelFragment new
]

{ #category : #accessing }
BlockLabelFragmentMorph >> labelFragment [
	^labelFragment
]

{ #category : #accessing }
BlockLabelFragmentMorph >> labelFragment: fragment [
	labelFragment := fragment
]

{ #category : #widgets }
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

{ #category : #'event handling' }
BlockLabelFragmentMorph >> mouseEnter: evt [

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self.

]

{ #category : #'event handling' }
BlockLabelFragmentMorph >> mouseEnterDragging: evt [

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self
]

{ #category : #'event handling' }
BlockLabelFragmentMorph >> mouseLeave: evt [

	owner isFrozen 
		ifTrue: [^ self].
	self color: Color white
]

{ #category : #'event handling' }
BlockLabelFragmentMorph >> mouseLeaveDragging: evt [

	(owner notNil and: [owner isFrozen])
		ifTrue: [^ self].
	self color: Color white
]

{ #category : #'byob lambdas' }
BlockLabelFragmentMorph >> updateFragment [

	labelFragment
		isInput: false;
		label: self contents
]
