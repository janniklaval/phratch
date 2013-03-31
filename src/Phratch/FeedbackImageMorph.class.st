"
I am an image that's invisible to mouse clicks.

"
Class {
	#name : #FeedbackImageMorph,
	#superclass : #ImageMorph,
	#category : #'Phratch-UI-Support'
}

{ #category : #'geometry-testing' }
FeedbackImageMorph >> containsPoint: aPoint [
	"I am not touchable--this allows mouse clicks to pass through me."

	^ false

]
