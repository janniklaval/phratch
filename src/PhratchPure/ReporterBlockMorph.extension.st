Extension { #name : #ReporterBlockMorph }

{ #category : #'*PhratchPure' }
ReporterBlockMorph >> stepTimeForPure [


	^self stepTimeForWatcher: PhratchSpritePureMorph stepTimeValue.
]
