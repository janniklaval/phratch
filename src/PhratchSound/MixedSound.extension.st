Extension { #name : #MixedSound }

{ #category : #'*PhratchSound' }
MixedSound >> setPan: leftRightPan volume: volume for: index [
	"Set the pan left-right pan and volume for the sound with the given index, where 0.0 is full left, 1.0 is full right, and 0.5 is centered. Volume ranges from 0 to 1.0."

	| pan vol |
	(index < 1 or: [index > leftVols size]) ifTrue: [^ self].
	pan := ((leftRightPan * ScaleFactor) asInteger max: 0) min: ScaleFactor.
	vol := ((volume * ScaleFactor) asInteger max: 0) min: ScaleFactor.
	leftVols at: index put: ((ScaleFactor - pan) * vol) // ScaleFactor.
	rightVols  at: index put: (pan * vol) // ScaleFactor.
]
