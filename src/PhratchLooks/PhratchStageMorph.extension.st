Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> addBackgroundTyped: aString [
	"Add a new background"
	<phratchItem: 'add $NewCostume$ to backgrounds' kind: #- category: 'looks' defaultValues: #() subCategory: #a2 special: #()>
	self addCostumeTyped: aString.
]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> changeHPanBy: amount [
	"Change my horizontal pan by the given amount."
	<phratchItem: 'change horizontal pan by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a4 special: #()>
	hPan := hPan + amount truncated.
	self changed.

]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> changeVPanBy: amount [
	"Change my vertical pan by the given amount."
	<phratchItem: 'change vertical pan by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a4 special: #()>
	vPan := vPan + amount truncated.
	self changed.

]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> deleteBackgroundAt: aNumber [
	"Remove the given background"
	<phratchItem: 'delete background $Number$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2 special: #()>
	self deleteCostumeAt: aNumber.
]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> nextBackground [
	"Show the next background in my backgrounds list."
	<phratchItem: 'next background' kind: #- category: 'looks' defaultValues: #() subCategory: #a1 special: #()>
	self nextCostume.

]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> replaceBackground: name with: sel [
	"Replace the given background"
	<phratchItem: 'replace background $Number$ with $NewCostume$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2 special: #()>
	self replaceCostume: name with: sel.
]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> setHPanTo: aNumber [
	"Set my horizontal pan to the given offset."
	<phratchItem: 'set horizontal pan to $Number$' kind: #- category: 'looks' defaultValues: #(0) subCategory: #a4 special: #()>
	hPan := aNumber truncated.
	self changed.


]

{ #category : #'*PhratchLooks' }
PhratchStageMorph >> setVPanTo: aNumber [
	"Set my vertical pan to the given offset."
	<phratchItem: 'set vertical pan to $Number$' kind: #- category: 'looks' defaultValues: #(0) subCategory: #a4 special: #()>
	vPan := aNumber truncated.
	self changed.


]
