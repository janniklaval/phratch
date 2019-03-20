Extension { #name : #LogicalFont }

{ #category : #'*Phratch-extension' }
LogicalFont >> xRangesFor: aString [
	"Anwer an array of (leftX, rightX) pairs for the given string."

	| result lastX w right |
	result := Array new: aString size.
	lastX := 0.
	1 to: aString size do: [:i |
		w := self widthOf: (aString at: i).
		right := lastX + w.
		result at: i put: (Array with: lastX with: right).
		lastX := right].

	^ result
]
