Extension { #name : #InputEventSensor }

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> clearKeystate [
	"Clear the keystate array. "
	keyPressed := nil

]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> keyPressed: asciiValue [
	"Is this key being pressed down?
	We assume that something else is processing events and therefore keyPressed it set."
	^keyPressed = asciiValue

]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> lastMousePosition [

	^ mousePosition

]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> processEvent: evt [
	"Process a single event. This method is run at high priority.
	
	The event record is:
	<type><timestamp><character code><updown><modifier keys>...
	where updown is:
	  0 - keystroke
	  1 - key down
	  2 - key up
	
	NOTE: You must ensure that there is an instance variable keyPressed."

	| type updown |
	type := evt at: 1.	"Treat menu events first"
	type = EventTypeMenu
		ifTrue: [ 
			self processMenuEvent: evt.
			^ nil ].	"Tackle mouse events first"
	type = EventTypeMouse
		ifTrue: [ 
			"Transmogrify the button state according to the platform's button map definition"
			evt at: 5 put: (ButtonDecodeTable at: (evt at: 5) + 1).	"Map the mouse buttons depending on modifiers"
			evt at: 5 put: (self mapButtons: (evt at: 5) modifiers: (evt at: 6)).	"Update state for polling calls"
			mousePosition := (evt at: 3) @ (evt at: 4).
			modifiers := evt at: 6.
			mouseButtons := evt at: 5.
			^ evt ].	"Finally keyboard"
	type = EventTypeKeyboard
		ifTrue: [ 
			"Update state for polling calls"
			modifiers := evt at: 5.
			updown := evt at: 4.
			keyPressed := updown = 2
				ifTrue: [ nil ]
				ifFalse: [ evt at: 3 ].
			^ evt ].	"Handle all events other than Keyborad or Mouse."
	^ evt
]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> rightButtonPressed [

^ self blueButtonPressed 
]
