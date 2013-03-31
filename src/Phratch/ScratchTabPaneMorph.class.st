Class {
	#name : #ScratchTabPaneMorph,
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
ScratchTabPaneMorph >> createTab: tabID withLabel: aString onForm: aForm1 offForm: aForm2 [

	| button |
	button := ResizableToggleButton2 new
		target: self;
		actionSelector: #currentTab:;
		toggleMode: false;
		toggleButtonMode: true;
		arguments: (Array with: tabID).

	button offForm: aForm2 onForm: aForm1.
	self tab: button label: aString.

	button position: (lastTabAdded ifNil: [-0@0] ifNotNil: [(lastTabAdded right - 16)@(self bottom - button height)]).

	lastTabAdded := button.
	self addMorph: button.

	(button height > self height) ifTrue: [
		self height: button height.
		"if we just changed the height, then we must make sure all the previous tabs are aligned to the bottom"
		self submorphs do: [:m |
			(m isKindOf: ResizableToggleButton2) ifTrue: [
				m height: self height; bottom: self bottom.
				m label top: m label top]]].

]

{ #category : #accessing }
ScratchTabPaneMorph >> currentTab [

	^ currentTab.
]

{ #category : #accessing }
ScratchTabPaneMorph >> currentTab: aString [

	currentTab := aString.
	self targetPane ifNil: [^ self].

	(targetPane target isKindOf: ScratchStageMorph)
		ifTrue: [self setLabelForTab: 'Costumes' to: 'Backgrounds' localized]
		ifFalse: [self setLabelForTab: 'Costumes' to: 'Costumes' localized].

	self lightUpCurrentTab.
	targetPane currentCategory: aString.

]

{ #category : #drawing }
ScratchTabPaneMorph >> drawSubmorphsOn: aCanvas [
	"Display submorphs back to front, draw a bar where appropriate in between tabs"

	| f barWidth myBox clipC |
	myBox := Rectangle origin: (self bounds origin) extent: (self bounds extent x - 20)@(self bounds extent y).
	clipC := aCanvas copyClipRect: myBox.

	barWidth := self width - 7.
	submorphs reverseDo:[:m | ((m isKindOf: ResizableToggleButton2) and: [m isOn])
		ifTrue: [f := Form extent: (barWidth @ barForm height) depth: 32.
				10 to: barWidth by: barForm width do: [:x | barForm displayOn: f at: x@0 rule: Form blend]].
		f ifNotNil: [clipC translucentImage: f at: ((self left - 13) @ (m bottom - 5))].
		clipC fullDrawMorph: m].

]

{ #category : #initialization }
ScratchTabPaneMorph >> initialize [

	| barFormSource |
	super initialize.
	self color: Color red.
	self extent: 100@1.
	
	barFormSource := ScratchFrameMorph skinAt: #dividedImageFrameBar.
	barForm := barFormSource copy: (((barFormSource width // 2) @ 0) extent: (1 @ barFormSource height))

]

{ #category : #private }
ScratchTabPaneMorph >> lightUpCurrentTab [

	(self submorphs) do: [:m |
		(m isKindOf: ResizableToggleButton2) ifTrue: [
			m arguments first = currentTab
				ifTrue: [m setLabelColor: (Color r:(33/255) g:(33/255) b:(31/255)); on; comeToFront]
				ifFalse: [m setLabelColor: (Color r:(88/255) g:(89/255) b:(93/255)); off]]].

]

{ #category : #private }
ScratchTabPaneMorph >> setLabelForTab: tabID to: aString [

	| theTab wInitial wDelta |
	self submorphs do: [:m |
		((m isKindOf: ResizableToggleButton2) and:
		 [m arguments first = tabID]) ifTrue: [
			theTab := m.
			wInitial := m width.
			self tab: m label: aString.
			wDelta := m width - wInitial]].

	theTab ifNotNil: [
		self submorphs do: [:m |
			((m isKindOf: ResizableToggleButton2) and: [m left > (theTab left)])
				ifTrue: [
					"scoot the others down if the tab's width changed"
					m position: (m position) + (wDelta@0)]]].

]

{ #category : #private }
ScratchTabPaneMorph >> tab: aResizableToggleButton2 label: aString [

	| label |
	aResizableToggleButton2
		label: aString font: (ScratchFrameMorph getFont: #Tab).

	ScratchTranslator renderWithSqueak ifFalse: [
		aResizableToggleButton2 forceUnicodeRendering: true].

	"account for the size of the tab skin."
	aResizableToggleButton2 extent: (aResizableToggleButton2 extent - (0@10)).

	(label := aResizableToggleButton2 findA: ScratchStringMorph) ifNotNil: [
		"slide label up a little"
		label top: label top].

]

{ #category : #accessing }
ScratchTabPaneMorph >> targetPane [

	^ targetPane.
]

{ #category : #accessing }
ScratchTabPaneMorph >> targetPane: aMorph [

	targetPane := aMorph.
]
