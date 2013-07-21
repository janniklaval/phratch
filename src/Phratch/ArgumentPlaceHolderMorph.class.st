Class {
	#name : #ArgumentPlaceHolderMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'labelFragment',
		'isRaised'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph class >> dimensions [
	^ 16@10
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> acceptDroppingMorph: aBlockMorph event: evt [
	"This message is sent when a morph is dropped onto a morph that has agreed to accept the dropped morph by responding 'true' to the wantsDroppedMorph:Event: message. This default implementation just adds the given morph to the receiver."

	labelFragment
		label: aBlockMorph variable;
		isInput: true.
	aBlockMorph delete.
	self template updateSpecWithDnDSpec
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> appear [

	self
		isHidden: false;
		appearInactive
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> appearActiveFor: aMorph [
	self
		extent: aMorph extent + (4@4);
		borderWidth: 4;
		borderColor: Color white;
		color: Color white darker
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> appearInactive [
	self
		extent: self class dimensions;
		borderWidth: 0;
		color: Color transparent
	
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> drawEmbeddedOn: aCanvas [
	
	| form |
	form := (PhratchFrameMorph skinAt: #addItem) deepCopy.
	form replaceColor: (form colorAt: 5@5) with: (ScriptablePhratchMorph blockColorFor: 'variables') darker.
	form replaceColor: (form colorAt: form center) with: Color white.
	super drawOn: aCanvas.
	aCanvas translucentImage: (form withEmbeddedOutlineColor: owner color width: 1) 
			at: self position + (( self extent - form extent) // 2)

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> drawOn: aCanvas [
	
	isRaised
		ifTrue: [self drawRaisedOn: aCanvas]
		ifFalse: [self drawEmbeddedOn: aCanvas]
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> drawRaisedOn: aCanvas [
	
	| form |
	form := (PhratchFrameMorph skinAt: #addItem) deepCopy.
	form replaceColor: (form colorAt: 5@5) with: (ScriptablePhratchMorph blockColorFor: 'variables').
	form replaceColor: (form colorAt: form center) with: Color white.
	super drawOn: aCanvas.
	aCanvas translucentImage: (form withEmbeddedOutlineColor: owner color width: 1) 
			at: self position + (( self extent - form extent) // 2)

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> handlesMouseOver: evt [
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient. The default response is false; subclasses that implement mouse mouseEnterDragging messages should override this to return true."

	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	^ true

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> handlesMouseOverDragging: evt [
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient. The default response is false; subclasses that implement mouse mouseEnterDragging messages should override this to return true."

	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	^ true

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> initialize [
	super initialize.
	isRaised := false.
	labelFragment := BlockLabelFragment new.
	self
		useRoundedCorners;
		appearInactive;
		updateFragment

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> labelFragment [
	^labelFragment
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> labelFragment: aBlockLabelFragmen [
	labelFragment := aBlockLabelFragmen
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> mouseDown: evt [
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
	frag = #cancelled ifTrue: [
		labelFragment := old.
		^ self]. 
	owner updateSpecWithDnDSpec
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> mouseEnter: evt [

	owner isFrozen 
		ifTrue: [^ self].
	isRaised := true.
	self changed

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> mouseEnterDragging: evt [
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	| m |
	owner isFrozen 
		ifTrue: [^ self].
	evt hand hasSubmorphs ifFalse: [^self].
	m := evt hand submorphs first.
	(self wantsDroppedMorph: m event: evt)
		ifTrue: [
			self appearActiveFor: m ].

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> mouseLeave: evt [

	owner ifNil: [^ self].
	owner isFrozen 
		ifTrue: [^ self].
	isRaised := false.
	self changed

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> mouseLeaveDragging: evt [
	"Handle a mouseLeaveLaden event. The mouse just left my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	owner ifNil: [^ self].
	owner isFrozen 
		ifTrue: [^ self].
	self appearInactive
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> template [

	| template |
	template := self ownerOrYourselfThatIsA: CustomCommandBlockMorph.
	template ifNil: [
		template := self ownerOrYourselfThatIsA: CustomReporterBlockMorph].
	^ template 

]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> updateFragment [

	labelFragment
		isInput: true;
		label: ''
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> vanish [

	self
		isHidden: true;
		extent: 0@0
]

{ #category : #'as yet unclassified' }
ArgumentPlaceHolderMorph >> wantsDroppedMorph: aMorph event: evt [
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. The default implementation returns false.
NOTE: the event is assumed to be in global (world) coordinates."

	| template |
	template := self template.
	template ifNil: [^ false].

	^((aMorph isKindOf: VariableBlockMorph) and: [aMorph isSpecialForm]) and: [
		(template parameterNames includes: aMorph variable) not]
]
