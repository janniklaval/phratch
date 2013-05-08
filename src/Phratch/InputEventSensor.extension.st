Extension { #name : #InputEventSensor }

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> clearKeystate [
	"Clear the keystate array. Do nothing if we're not using OS event handling."
"
	keystate ifNotNil: [keystate _ Array new: 256 withAll: false].
"
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
	"Is this key being pressed? If an event is found it is removed from the queue."
	| event |
	event := eventQueue nextOrNilSuchThat: [  :evt |
		(self isKbdEvent: evt) and: [ evt sixth = asciiValue ]
	].
	^ event notNil

]

{ #category : #'*Phratch-Extensions' }
InputEventSensor >> lastMousePosition [

	^ mousePosition

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
