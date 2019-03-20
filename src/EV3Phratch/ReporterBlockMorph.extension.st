Extension { #name : #ReporterBlockMorph }

{ #category : #'*EV3Phratch' }
ReporterBlockMorph >> stepTimeForEv3 [


	^self stepTimeForWatcher: PhratchSpriteEv3Morph stepTimeValue.
]
