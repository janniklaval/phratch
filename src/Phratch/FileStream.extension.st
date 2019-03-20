Extension { #name : #FileStream }

{ #category : #'*Phratch-Extensions' }
FileStream class >> readOnlyFileNamedOrNil: fileName [
	"Attempt to open the file with the given name read-only. If the file does not exist, return nil."

	^ self concreteStream new open: (self fullName: fileName) forWrite: false

]
