Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchPen' }
PhratchStageMorph >> stampCostume: aSprite [
	"Stamp a copy of the given sprite on my pen trails form."

	self createOrResizeTrailsForm.
	aSprite filteredForm
		displayOn: penTrailsForm
		at: (aSprite position - self topLeft)
		rule: Form paint.

]
