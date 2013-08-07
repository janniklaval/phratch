Class {
	#name : #PhratchTabPaneMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'targetPane',
		'currentTab',
		'lastTabAdded',
		'barForm'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #accessing }
PhratchTabPaneMorph >> createTab: tabID withLabel: aString onForm: aForm1 offForm: aForm2 [
	| button |
	button := ResizableToggleButton new
		target: self;
		actionSelector: #currentTab:;
		toggleMode: false;
		toggleButtonMode: true;
		arguments: (Array with: tabID).
	button offForm: aForm2 onForm: aForm1.
	self tab: button label: aString.
	button
		position: (lastTabAdded ifNil: [ -0 @ 0 ] ifNotNil: [ (lastTabAdded right - 16) @ (self bottom - button height) ]).
	lastTabAdded := button.
	self addMorph: button.
	button height > self height
		ifFalse: [ ^ self ].
	self height: button height.	"if we just changed the height, then we must make sure all the previous tabs are aligned to the bottom"
	self submorphs
		do: [ :m | 
			(m isKindOf: ResizableToggleButton)
				ifTrue: [ 
					m
						height: self height;
						bottom: self bottom.
					m label top: m label top ] ]
]

{ #category : #accessing }
PhratchTabPaneMorph >> currentTab [

	^ currentTab.
]

{ #category : #accessing }
PhratchTabPaneMorph >> currentTab: aString [

	currentTab := aString.
	self targetPane ifNil: [^ self].

	(targetPane target isKindOf: PhratchStageMorph)
		ifTrue: [self setLabelForTab: 'Costumes' to: 'Backgrounds' localized]
		ifFalse: [self setLabelForTab: 'Costumes' to: 'Costumes' localized].

	self lightUpCurrentTab.
	targetPane currentCategory: aString.

]

{ #category : #drawing }
PhratchTabPaneMorph >> drawSubmorphsOn: aCanvas [
	"Display submorphs back to front, draw a bar where appropriate in between tabs"

	| f barWidth myBox clipC |
	myBox := Rectangle origin: (self bounds origin) extent: (self bounds extent x - 20)@(self bounds extent y).
	clipC := aCanvas copyClipRect: myBox.

	barWidth := self width - 7.
	submorphs reverseDo:[:m | ((m isKindOf: ResizableToggleButton) and: [m isOn])
		ifTrue: [f := Form extent: (barWidth @ barForm height) depth: 32.
				10 to: barWidth by: barForm width do: [:x | barForm displayOn: f at: x@0 rule: Form blend]].
		f ifNotNil: [clipC translucentImage: f at: ((self left - 13) @ (m bottom - 5))].
		clipC fullDrawMorph: m].

]

{ #category : #initialization }
PhratchTabPaneMorph >> initialize [

	| barFormSource |
	super initialize.
	self color: Color red.
	self extent: 100@1.
	
	barFormSource := PhratchFrameMorph skinAt: #dividedImageFrameBar.
	barForm := barFormSource copy: (((barFormSource width // 2) @ 0) extent: (1 @ barFormSource height))

]

{ #category : #private }
PhratchTabPaneMorph >> lightUpCurrentTab [

	(self submorphs) do: [:m |
		(m isKindOf: ResizableToggleButton) ifTrue: [
			m arguments first = currentTab
				ifTrue: [m setLabelColor: (Color r:(33/255) g:(33/255) b:(31/255)); on; comeToFront]
				ifFalse: [m setLabelColor: (Color r:(88/255) g:(89/255) b:(93/255)); off]]].

]

{ #category : #private }
PhratchTabPaneMorph >> setLabelForTab: tabID to: aString [

	| theTab wInitial wDelta |
	self submorphs do: [:m |
		((m isKindOf: ResizableToggleButton) and:
		 [m arguments first = tabID]) ifTrue: [
			theTab := m.
			wInitial := m width.
			self tab: m label: aString.
			wDelta := m width - wInitial]].

	theTab ifNotNil: [
		self submorphs do: [:m |
			((m isKindOf: ResizableToggleButton) and: [m left > (theTab left)])
				ifTrue: [
					"scoot the others down if the tab's width changed"
					m position: (m position) + (wDelta@0)]]].

]

{ #category : #private }
PhratchTabPaneMorph >> tab: aResizableToggleButton2 label: aString [

	| label |
	aResizableToggleButton2
		label: aString font: (PhratchFrameMorph getFont: #Tab).

	PhratchTranslator renderWithSqueak ifFalse: [
		aResizableToggleButton2 forceUnicodeRendering: true].

	"account for the size of the tab skin."
	aResizableToggleButton2 extent: (aResizableToggleButton2 extent - (0@10)).

	(label := aResizableToggleButton2 findA: StringMorph) ifNotNil: [
		"slide label up a little"
		label top: label top].

]

{ #category : #accessing }
PhratchTabPaneMorph >> targetPane [

	^ targetPane.
]

{ #category : #accessing }
PhratchTabPaneMorph >> targetPane: aMorph [

	targetPane := aMorph.
]
