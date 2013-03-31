Class {
	#name : #PhratchFullScreenMorph,
	#superclass : #ScratchFrameMorph,
	#category : #'Phratch-UI-Panes'
}

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph class >> deploy [
	Error signal:'Proceed Might Damage Your Image!!!...'.
	self takeOverScreen: false.
	self new startup openAndBecomeBackground
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph class >> open [
      Error signal: 'Proceed Might Damage Your Image..!!!'.
      PolymorphSystemSettings  showDesktopLogo: false.
	self takeOverScreen: false.
	self new startup openAndBecomeBackground
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> aboutToBeGrabbedBy: aHand [
	^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> attachMorph: m [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> buildMetaMenu: evt [
	^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> cursorPoint [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> drag: event [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> firstClickEvent [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> grabMorph: aMorph [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> grabMorph: aMorph from: formerOwner [ 
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> handleEvent: evt from: aHand [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> invokeMetaMenu: evt [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> isHandMorph [
^false
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> openAndBecomeBackground [
	self openInWorld.
	self world backgroundMorph: self
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> waitForClicksOrDrag: aMorph event: evt [
^nil
]

{ #category : #'as yet unclassified' }
PhratchFullScreenMorph >> waitForClicksOrDrag: aMorph event: evt selectors: clickAndDragSelectors threshold: threshold [
^nil
]
