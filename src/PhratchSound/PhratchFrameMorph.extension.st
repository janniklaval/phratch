Extension { #name : #PhratchFrameMorph }

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> closeMediaEditorsAndDialogs [
	"Close any open paint or sound editors, asking the user first to avoid losing edits. Answer true if all are closed."

	| mList mHasCancel |
	mList := PaintFrame allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close paint editor?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete].
		paintingInProgress := false].

	mList := PhratchSoundRecorderDialogMorph allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close sound recorder?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]].

	mList := DialogBoxMorph allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
		mList do: [:m |
			mHasCancel := false.
			m buttons do: [:b |
				b action = #cancelled ifTrue: [mHasCancel := true]].
			mHasCancel
				ifTrue: [m cancelled; delete]
				ifFalse: [m no; delete]]].

	DialogBoxMorph subclassesDo: [:c |
		mList := c allInstances select: [:m | m isInWorld].
		mList size > 0 ifTrue: [
			(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
			mList do: [:m |
				mHasCancel := false.
				m buttons do: [:b |
					b action = #cancelled ifTrue: [mHasCancel := true]].
				mHasCancel
					ifTrue: [m cancelled; delete]
					ifFalse: [m no; delete]]]].

	"subclass of a subclass of DialogBoxMorph"
	mList := NewVariableDialog allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]].

	^ true

]

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
PhratchFrameMorph >> newSound [
	"Open the dialog to record a new sound."

	scriptsPane tabPane currentTab: 'Sounds'.
	viewerPane target recordSound.
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
