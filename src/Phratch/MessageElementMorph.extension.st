Extension { #name : #MessageElementMorph }

{ #category : #'*Phratch-Extensions' }
MessageElementMorph >> fullCopy [
	|copy|
	copy := self class new selector: selector.
	(#ifTrue:ifFalse: = selector) 
		ifTrue: [copy yesNo ].
	(#_ = selector) 
		ifTrue: [copy assign ].
	copy position: self position.
	(copy argumentCount < self argumentCount)
		ifTrue: [copy beBinary].
	^copy
]

{ #category : #'*Phratch-Extensions' }
MessageElementMorph >> rootForGrabOf: aMorph [
	"Answer the root of the morph structure to be picked up when the given morph is grabbed."

	aMorph == self ifTrue: [^super rootForGrabOf: aMorph ].
	(aMorph isKindOf: self class) ifTrue: [^self].
	^super rootForGrabOf: aMorph

]
