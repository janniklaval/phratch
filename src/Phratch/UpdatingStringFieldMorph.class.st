"
A subclass of UpdatingStringFieldMorph that updates when stepped.

"
Class {
	#name : #UpdatingStringFieldMorph,
	#superclass : #StringFieldMorph,
	#instVars : [
		'target',
		'getSelector',
		'putSelector'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #private }
UpdatingStringFieldMorph >> acceptEdits [
	"Tell the client to accept edits."

	(target notNil & putSelector notNil) ifFalse: [^ self].
	[target perform: putSelector with: self contents] ifError: [].


]

{ #category : #accessing }
UpdatingStringFieldMorph >> getSelector: aSelector [

	getSelector := aSelector  .

]

{ #category : #initialization }
UpdatingStringFieldMorph >> initialize [

	super initialize.
	stringMorph color: Color white.
	self useTypeinFrame.
	self font: (StrikeFont familyName: 'Verdana' size: 12).

]

{ #category : #private }
UpdatingStringFieldMorph >> isEditable [
	"Answer true if I am editable."

	^ putSelector notNil

]

{ #category : #accessing }
UpdatingStringFieldMorph >> putSelector: aSelector [

	putSelector := aSelector  .

]

{ #category : #stepping }
UpdatingStringFieldMorph >> step [

	| s |
	super step.
	isKeyboardFocus ifTrue: [^ self]. "do not update if user is editing"
	(target notNil & getSelector notNil) ifFalse: [^ self].

	s := target perform: getSelector.
	s asUTF8   = self contents ifFalse: [self contents: s  ].


]

{ #category : #accessing }
UpdatingStringFieldMorph >> target [

	^ target

]

{ #category : #accessing }
UpdatingStringFieldMorph >> target: aPhratchObjectOrMediaObjectOrNil [

	target := aPhratchObjectOrMediaObjectOrNil.
	self step.

]
