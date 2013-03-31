Extension { #name : #FileStream }

{ #category : #'*Phratch-Extensions' }
FileStream class >> droppedFiles [
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
FileStream class >> readOnlyFileNamedOrNil: fileName [
	"Attempt to open the file with the given name read-only. If the file does not exist, return nil."

	^ self concreteStream new open: (self fullName: fileName) forWrite: false

]
