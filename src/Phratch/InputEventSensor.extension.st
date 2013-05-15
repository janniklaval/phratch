Extension { #name : #InputEventSensor }

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> clearKeystate [
	"Clear the keystate array. "
	keyPressed := nil

]

{ #category : #'*Phratch' }
InputEventSensor >> droppedFiles [
	"Poll for a dropped file event. If there is such an event, answer an array containing the drop point followed by one or more FileStream's for the dropped files. Otherwise, answer the empty array."
	"Note: File dropping does not work on versions of the Squeak VM before the DropPlugin and event primitive. This method can still be called, but it will always answer an empty array."

	| p result i f |
	"check for a file drop event?"
	p := Sensor fileDropPoint.
	p ifNil: [^ #()].  "no file drop event"

	"get streams on all dropped files"
	result := OrderedCollection with: p.
	i := 1.
	[(f := StandardFileStream new requestDropStream: i) notNil] whileTrue: [
		result addLast: f.
		i := i + 1].

	^ result asArray

]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> fileDropPoint [
	"Answer the point a which a file (or files) were dropped or nil if no file has been dropped. Requires Squeak VM version 3.1 or later."

	| evtBuf |
"	events ifNotNil: [ 
		[true] whileTrue: [
			evtBuf := self nextEventRecordOfType: 3.
			evtBuf ifNil: [^ nil].
			(evtBuf at: 3) = 4 ifTrue: [ 
				^ (evtBuf at: 4) @ (evtBuf at: 5)]]]."

	"not using OS events for mouse/keyboard input"
	evtBuf := Array new: 8.
	[true] whileTrue: [
		evtBuf at: 1 put: 0.
		InputEventFetcher default primGetNextEvent: evtBuf.
		evtBuf first = 0 ifTrue: [^ nil].
		(evtBuf first = 3 and: [(evtBuf at: 3) = 4]) ifTrue: [
			^ (evtBuf at: 4) @ (evtBuf at: 5)]].

]

{ #category : #'*Phratch' }
InputEventSensor >> keyPressed: asciiValue [
	"Is this key being pressed down?
	We assume that something else is processing events and therefore keyPressed it set."
	^keyPressed = asciiValue

]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> lastMousePosition [

	^ mousePosition

]

{ #category : #'*Phratch' }
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
		
	type := evt at: 1.

	"Treat menu events first"
	type = EventTypeMenu
		ifTrue: [
			self processMenuEvent: evt.
			^nil].

	"Tackle mouse events first"
	type = EventTypeMouse
		ifTrue: [
			"Transmogrify the button state according to the platform's button map definition"
			evt at: 5 put: (ButtonDecodeTable at: (evt at: 5) + 1).
			"Map the mouse buttons depending on modifiers"
			evt at: 5 put: (self mapButtons: (evt at: 5) modifiers: (evt at: 6)).

			"Update state for polling calls"
			mousePosition := (evt at: 3) @ (evt at: 4).
			modifiers := evt at: 6.
			mouseButtons := evt at: 5.

			^evt].
	
	
	"Finally keyboard"
	type = EventTypeKeyboard
		ifTrue: [
			"Update state for polling calls"
			modifiers := evt at: 5.
			updown := evt at: 4.
			(updown = 2) ifTrue: [ 
				keyPressed := nil
			] ifFalse: [  
				keyPressed := evt at: 3 ].
			^evt].
				
	"Handle all events other than Keyborad or Mouse."
	^evt.
	
]

{ #category : #'*Phratch' }
InputEventSensor >> processOSMenuEvents [
]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> rightButtonPressed [

^ self blueButtonPressed 
]

{ #category : #'*Phratch' }
InputEventSensor >> useOSEvents: bool [
]
