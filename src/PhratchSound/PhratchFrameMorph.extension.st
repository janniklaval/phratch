Extension { #name : #PhratchFrameMorph }

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> compressSounds [
	<phratchMenu: 'Compress Sounds' category: 'edit' position: 3 sub:2 shift: false>
	| menu bitsPerSample count |
	menu := MenuMorph new
		title: 'Sound quality:' translated;
		defaultTarget: self;
		yourself.	"menu add: 'High (biggest)'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 5 with: false).
	menu add: 'Normal'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 4 with: false).
	menu add: 'Low'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 3 with: false).
	menu add: 'Lowest (smallest)'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 2 with: false).
	menu addLine.
	menu add: 'cancel' action: nil.
	count := menu localize; invokeModal."
	menu := MenuMorphNG new
		title: 'Sound quality:' translated;
		defaultTarget: self;
		yourself.
	menu add: 'High (biggest)' value: 5.
	menu add: 'Normal' value: 4.
	menu add: 'Low' value: 3.
	menu add: 'Lowest (smallest)' value: 2.
	menu addLine.
	menu add: 'cancel' value: nil.
	menu localize.
	(bitsPerSample := menu
		invokeModal;
		selectedValue;
		yourself) ifNil: [ ^ self ].
	count := self canonicalizeSoundsBits: bitsPerSample saveOriginal: false.
	scriptsPane categoryChanged: 'Sounds'.
	DialogBoxMorph inform: 'Sounds compressed' withDetails: count printString
]

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> updateMediaCategoryFor: anObject [
	"Update the media viewer for the given object's media category. Do nothing if the media category of the given object is not being viewed."

	scriptsPane target = anObject ifTrue: [
		scriptsPane categoryChanged: 'Sounds'.
		scriptsPane categoryChanged: 'Costumes'].
	viewerPane target = anObject ifTrue: [
		viewerPane categoryChanged: 'Sound'].

]
