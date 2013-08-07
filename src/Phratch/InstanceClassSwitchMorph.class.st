Class {
	#name : #InstanceClassSwitchMorph,
	#superclass : #Morph,
	#instVars : [
		'instance',
		'class',
		'choice',
		'frame'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #private }
InstanceClassSwitchMorph >> arrangePanes [

	| toggleWidth |
	toggleWidth := self width - 6 // 2.

	instance 
		width: toggleWidth;
		position: self topLeft + 2;
		fitMorphs.

	class 
		width: toggleWidth;
		position: instance right + 2 @ (instance top);
		fitMorphs.

	self height: class bottom + 2 - self top
]

{ #category : #initialization }
InstanceClassSwitchMorph >> buildPanes [

	instance := ElementsToggleButtonMorph new
				target: self;
				selector: #instance;
				label: 'instance';
				onColor: Color blue darker offColor: color;
		yourself.

	class := ElementsToggleButtonMorph new
				target: self;
				selector: #class;
				label: 'class';
				onColor: Color magenta twiceDarker offColor: color;
		yourself.

	self
		addMorph: instance;
		addMorph: class

]

{ #category : #accessing }
InstanceClassSwitchMorph >> choice [
	^choice
]

{ #category : #accessing }
InstanceClassSwitchMorph >> class [
	(choice = #class) ifTrue: [^self].
	choice := #class.
	frame ifNotNil: [
		frame switchToClassSide.
		self refresh ]
]

{ #category : #accessing }
InstanceClassSwitchMorph >> frame: aMorph [
	frame := aMorph
]

{ #category : #initialize }
InstanceClassSwitchMorph >> initialize [
	super initialize.
	choice := #instance.
	color := Color gray.
	self width: 180.
	self buildPanes.
	self arrangePanes.
	self refresh
]

{ #category : #accessing }
InstanceClassSwitchMorph >> instance [
	(choice = #instance) ifTrue: [^self].
	choice := #instance.
	frame ifNotNil: [
		frame switchToInstanceSide.
		self refresh ]
]

{ #category : #private }
InstanceClassSwitchMorph >> refresh [

	instance off.
	class off.

	(#instance = choice) ifTrue: [
		instance on ].
	(#class = choice) ifTrue: [
		class on ].


]
