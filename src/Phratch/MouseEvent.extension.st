Extension { #name : #MouseEvent }

{ #category : #'*Phratch-Extensions' }
MouseEvent >> cursorPoint: aPoint [
	"Answer the location of the cursor's hotspot when this event occured."

	position := aPoint
]

{ #category : #'*Phratch-Extensions' }
MouseEvent >> rightButtonPressed [
	"Answer true if the right mouse button is pressed. On Mac's, this is sometimes reported as the blue button or control-red-button. On Windows, this this is mapped to the yellow button. Answer true for any of these cases."

	^ (buttons anyMask: 3) or:
	  [self redButtonPressed & self controlKeyPressed]

]
