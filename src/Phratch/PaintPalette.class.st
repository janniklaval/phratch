Class {
	#name : #PaintPalette,
	#superclass : #BorderedMorph,
	#instVars : [
		'canvasMorph',
		'brushSizeMorph',
		'brushSize',
		'eraserSize',
		'colorSwitcher',
		'fillStylePane',
		'optionsPane',
		'storedColor',
		'toolbarButtons',
		'mode',
		'storedMode',
		'shapeFilling',
		'fillStyle',
		'showRotationCenter',
		'brushSizeMenu',
		'textSizeMenu',
		'textSizeMorph',
		'textFontMenu'
	],
	#category : #'Phratch-Paint'
}

{ #category : #initialization }
PaintPalette >> addToolbarButtons [

	| b firstRow secondRow buttonSpecs bName bTip |
	toolbarButtons := AlignmentMorph newColumn
		inset: 0;
	 	wrapCentering: #topLeft;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap; 
		yourself.
	firstRow := AlignmentMorph newRow
		inset: 0;
		wrapCentering: #topLeft;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap; 
		yourself.
	secondRow := AlignmentMorph newRow
		inset: 0;
		wrapCentering: #topLeft;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap; 
		yourself.

	buttonSpecs := #(
		"name			tip"
		(paint			'Paintbrush')
		(erase			'Eraser')
		(fill				'Fill tool (fill areas with color or gradient)')
		(rect 			'Rectangle tool (draw outlined or filled rectangle or square)')
		(oval 			'Ellipse tool (draw outlined or filled ellipse or circle)')
	).

	buttonSpecs do: [:spec |
		bName := spec at: 1.
		bTip := spec at: 2.
		b := ToggleButton new
			onForm: (PhratchFrameMorph skinAt: (bName, 'ToolButtonPressed'))
			offForm: (PhratchFrameMorph skinAt: (bName, 'ToolButton'))
			overForm: (PhratchFrameMorph skinAt: (bName, 'ToolButtonOver'));
			target: self;
			isMomentary: false;
			toggleMode: false;
			actionSelector: #mode:;
			arguments: (Array with: bName);
			setProperty: #balloonText toValue: bTip localized;
			actWhen: #buttonDown; 
		yourself.
		firstRow addMorphBack: b].

	buttonSpecs := #(
		"name			tip"
		(line			'Line tool (draw lines)')
		(text			'Text tool (edit text layer)')
		(move			'Select tool (move, modify, or delete selection)')
		(stamp 			'Stamp tool (select area, then stamp copies of it)')
		(eyedropper 	'Eyedropper tool (select a color)')
	).

	buttonSpecs do: [:spec |
		bName := spec at: 1.
		bTip := spec at: 2.
		b := ToggleButton new
			onForm: (PhratchFrameMorph skinAt: (bName, 'ToolButtonPressed'))
			offForm: (PhratchFrameMorph skinAt: (bName, 'ToolButton'))
			overForm: (PhratchFrameMorph skinAt: (bName, 'ToolButtonOver'));
			target: self;
			isMomentary: false;
			toggleMode: false;
			actionSelector: #mode:;
			arguments: (Array with: bName);
			setProperty: #balloonText toValue: bTip localized;
			actWhen: #buttonDown; 
		yourself.
		secondRow addMorphBack: b.
		].

	toolbarButtons addMorphBack: firstRow.
	toolbarButtons addMorphBack: secondRow.
	self addMorph: toolbarButtons.

]

{ #category : #accessing }
PaintPalette >> brushSize [

	^ mode = #erase ifTrue: [eraserSize] ifFalse: [brushSize]

]

{ #category : #accessing }
PaintPalette >> brushSize: aNumber [
	"Set the brush size for painting and erasing."

	mode = #erase
		ifTrue: [eraserSize := aNumber]
		ifFalse: [brushSize := aNumber].

	brushSizeMenu ifNotNil: [brushSizeMenu delete].
	self updateOptionsPane.

]

{ #category : #'event handling' }
PaintPalette >> brushSizeMenu [
	| b icon row n2 colorToUse |
	brushSizeMenu
		ifNotNil: [ 
			brushSizeMenu isInWorld
				ifTrue: [ ^ self ] ].
	brushSizeMenu := AlignmentMorph newColumn
		color: Color transparent;
		inset: 0;
		borderWidth: 1;
		useRoundedCorners;
		borderColor: (Color r: 173 / 255 g: 174 / 255 b: 181 / 255); 
		yourself.
	row := AlignmentMorph newRow
		borderWidth: 0;
		inset: 0; 
		yourself.
	#(1 2 3 4 5 7 9 13 19 29 47 75)
		do: [ :n | 
			n2 := n asNumber.
			n2 <= 6
				ifTrue: [ n2 := n2 + 1 ].
			n2 == 29
				ifTrue: [ n2 := 23 ].
			n2 == 47
				ifTrue: [ n2 := 25 ].
			n2 == 75
				ifTrue: [ n2 := 27 ].
			colorToUse := self mode = #erase
				ifTrue: [ Color transparent ]
				ifFalse: [ self color1 ].
			icon := PaintCanvas brushCursorSize: n2 color: colorToUse scale: 1.
			b := IconicButton new
				color: (Color r: 211 / 255 g: 212 / 255 b: 220 / 255);
				borderColor: (Color r: 173 / 255 g: 174 / 255 b: 181 / 255);
				labelGraphic: icon;
				width: 30;
				height: 30;
				actionSelector: #brushSize:;
				target: self;
				arguments: (Array with: n); 
		yourself.
			self brushSize = n asNumber
				ifTrue: [ b color: Color white	"(Color r: (188/255) g: (193/255) b: (200/255))" ].
			row addMorphBack: b.
			row submorphs size == 4
				ifTrue: [ 
					brushSizeMenu addMorphBack: row.
					row := AlignmentMorph newRow
						borderWidth: 0;
						inset: 0; 
		yourself ] ].
	brushSizeMenu position: (optionsPane left + 55) @ (optionsPane bottom - 5).
	self owner addMorph: brushSizeMenu
]

{ #category : #accessing }
PaintPalette >> canvasMorph: anObject [
	"Set the PaintCanvas that I control."

	canvasMorph := anObject.

]

{ #category : #accessing }
PaintPalette >> color1 [

	^ colorSwitcher foreground

]

{ #category : #accessing }
PaintPalette >> color1: aColor [
	"Set the color for painting, ovals, and rectangles. This is also used as the first color when doing gradiant fills."

	| aColor2 |

	aColor2 := aColor.
	(mode == #text) 
		ifTrue: [(aColor == Color transparent) ifTrue: [aColor2 := Color white].
				canvasMorph textColor: aColor2. 
				canvasMorph changed]
		ifFalse: [self storedColor: aColor2].
	colorSwitcher foreground: aColor2.
	(mode == #fill) ifTrue: [self updateOptionsPane].

]

{ #category : #accessing }
PaintPalette >> color2 [

	^ colorSwitcher background

]

{ #category : #accessing }
PaintPalette >> color2: aColor [
	"Set the second color for gradiant fills."

	colorSwitcher background: aColor.
	(mode == #fill) ifTrue: [self updateOptionsPane].

]

{ #category : #initialization }
PaintPalette >> createColorSwitcher [

	colorSwitcher := PaintColorSwitcher new.
	colorSwitcher setProperty: #balloonText toValue: 'Switch colors' localized.
	self addMorph: colorSwitcher.

]

{ #category : #initialization }
PaintPalette >> createOptionsPane [

	optionsPane := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: #paintOptionsBackground).
	optionsPane extent: 232@44.
	self addMorphBack: optionsPane.

]

{ #category : #drawing }
PaintPalette >> drawOn: aCanvas [

"	color isTransparent ifTrue: [^ self]."
	aCanvas fillRectangle: self bounds color: color.
]

{ #category : #geometry }
PaintPalette >> extent: aPoint [

	super extent: aPoint.
	self fixLayout.

]

{ #category : #accessing }
PaintPalette >> fillStyle [

	^ fillStyle

]

{ #category : #accessing }
PaintPalette >> fillStyle: aSymbol [
	"Set the paint bucket fill style: color, erase, hGradient, vGradient, or rGradient."

	fillStyle := aSymbol.
	fillStylePane ifNil: [^ self].
	self updateOptionsPane.

]

{ #category : #geometry }
PaintPalette >> fixLayout [

	toolbarButtons position: self topLeft.
	optionsPane position: toolbarButtons left @ (toolbarButtons bottom - 2).
	colorSwitcher position: (self right - colorSwitcher width - 5)@(optionsPane bottom + 15).

]

{ #category : #'event handling' }
PaintPalette >> handlesMouseDown: evt [

	| p |
	p := evt cursorPoint.
	^ (brushSizeMorph containsPoint: p) |
		(textSizeMenu 
			ifNil: [false]
			ifNotNil: [(textSizeMenu containsPoint: p) | 
						(textFontMenu containsPoint: p)])

]

{ #category : #initialization }
PaintPalette >> initialize [

	super initialize.
	self borderWidth: 0.
	self color: Color transparent.
	self createOptionsPane.
	self createColorSwitcher.
	self addToolbarButtons.
	self brushSize: 3.
	eraserSize := 13.
	self extent: (toolbarButtons width)@(100 + toolbarButtons height).
	self shapeFilling: true.
	self paintBucketFillStyle: #color.
	showRotationCenter := false.
	self mode: #paint.
	self storedColor: colorSwitcher foreground.
	self updateOptionsPane.
	
	"strange hack: "
self openInWorld.
self extent: (toolbarButtons width)@(100 + toolbarButtons height).
self updateOptionsPane.
self delete.
]

{ #category : #accessing }
PaintPalette >> mode [

	^ mode

]

{ #category : #initialization }
PaintPalette >> mode: aSymbol [

	canvasMorph ifNotNil: [canvasMorph commitMove].
	self showRotationCenter ifTrue: [self showRotationCenter: false].
	mode := aSymbol.
	brushSizeMenu ifNotNil: [brushSizeMenu delete].
	canvasMorph ifNotNil: [
		mode = #text 
			ifTrue: [
				self color1: canvasMorph textColor.
				World activeHand newKeyboardFocus: canvasMorph]
			ifFalse: [
			self color1: self storedColor]].
	self updateOptionsPane.
	self updateToolbarButtons.

	self owner changed.

]

{ #category : #'event handling' }
PaintPalette >> mouseUp: evt [

	| p |
	p := evt cursorPoint.
	brushSizeMorph ifNotNil: [
		(brushSizeMorph isInWorld and: [brushSizeMorph containsPoint: p])
			ifTrue: [^ self brushSizeMenu]].
	textSizeMenu ifNotNil: [
		(textSizeMenu isInWorld and: [textSizeMenu containsPoint: p])
			ifTrue: [^ self textSizeMenu]].
	textFontMenu ifNotNil: [
		(textFontMenu isInWorld and: [textFontMenu containsPoint: p])
			ifTrue: [^ self textFontMenu]].

]

{ #category : #accessing }
PaintPalette >> paintBucketFillStyle [

	^ fillStyle

]

{ #category : #accessing }
PaintPalette >> paintBucketFillStyle: aSymbol [
	"Set the paint bucket fill style: color, erase, hGradient, vGradient, or rGradient."

	fillStyle := aSymbol.
	fillStylePane ifNil: [^ self].
	self updateOptionsPane.

]

{ #category : #accessing }
PaintPalette >> shapeFilling [

	^ shapeFilling

]

{ #category : #accessing }
PaintPalette >> shapeFilling: aBoolean [
	"Set the shape filling mode for ovals and rectangles."

	shapeFilling := aBoolean.
	optionsPane firstSubmorph submorphs do: [:m |
		(m isToggleButton) ifTrue: [
			m off.
			((m arguments at: 1) = aBoolean) ifTrue: [m on]]].

]

{ #category : #accessing }
PaintPalette >> showRotationCenter [

	^ showRotationCenter

]

{ #category : #accessing }
PaintPalette >> showRotationCenter: aBoolean [

	showRotationCenter = aBoolean ifTrue: [^ self].

	canvasMorph commitMove.  "commit the last move operation if necessary"

	showRotationCenter := aBoolean.
	showRotationCenter
		ifTrue: [
			storedMode := mode.
			mode := #setRotationCenter.
			owner ifNotNil: [owner setRotationCenterButton on]]
		ifFalse: [
			mode := storedMode.
			owner ifNotNil: [owner setRotationCenterButton off]].

	self updateToolbarButtons.
	canvasMorph ifNotNil: [canvasMorph changed].

]

{ #category : #accessing }
PaintPalette >> storedColor [

	^ storedColor
]

{ #category : #accessing }
PaintPalette >> storedColor: aColor [

	storedColor := aColor
]

{ #category : #'event handling' }
PaintPalette >> textFontMenu [

	| useOSFont fontList  menu lcName |

		useOSFont := false.
		fontList := StrikeFont fontNames reject: [:fn |
			lcName := fn asLowercase.
			(lcName includesSubstring: 'arial') |
			(lcName includesSubstring: 'helvetica') |
			(lcName includesSubstring: 'narrowspace') |
			(lcName includesSubstring: 'newyork')].

	menu := MenuMorph new defaultTarget: self.
	fontList do: [:n | 
		menu add: n
			target: self 
			selector: #updateFontMenu:withOsFont:
			argumentList: (Array with: n with: useOSFont).
	].
	menu popUpInWorld.

]

{ #category : #'event handling' }
PaintPalette >> textSizeMenu [
	| menu font sizeList |
	menu := MenuMorph new.
	font := canvasMorph canvasTextBox font.
	sizeList := font isOSFont
		ifTrue: [ #(8 9 10 12 14 18 24 36 48 60 72 96 120 144 216 288) ]
		ifFalse: [ StrikeFont sizesForFontName: font familyName ].
	sizeList size = 0
		ifTrue: [^PhratchError error: 'beep'. ].	"should not happen"
	sizeList
		do: [ :n | 
			menu
				add: n asString
				target: self
				selector: #updateSizeMenu:
				argument: n ].
	menu invokeModal
]

{ #category : #'event handling' }
PaintPalette >> toggleRotationPoint [

	self showRotationCenter: showRotationCenter not.

]

{ #category : #menus }
PaintPalette >> updateFontMenu: choice withOsFont: useOSFont [
	| fontSize font |
	fontSize := textSizeMorph contents asNumber.
	font := useOSFont
		ifTrue: [ StrikeFont osFontName: choice size: fontSize ]
		ifFalse: [ StrikeFont fontName: choice size: fontSize ].
	canvasMorph canvasTextBox font: font.
	self updateOptionsPane.
	canvasMorph changed
]

{ #category : #accessing }
PaintPalette >> updateOptionsPane [
	| options font s spacer form b formMorph colorToUse brushThumbnail n2 aColor2 fName textFontMorph brushIcon |
	optionsPane removeAllMorphs.
	options := AlignmentMorph newRow
		width: optionsPane width - 16;
		height: optionsPane height - 30; 
		color: Color transparent;
		hResizing: #shrinkWrap; 
		vResizing: #shrinkWrap;
		inset: 0; 
		yourself.
	(#(#paint #erase #line) includes: self mode)
		ifTrue: [ 
			brushSizeMorph := AlignmentMorph newRow
				cellPositioning: #leftCenter;
				centering: #center;
				color: Color transparent; 
		yourself.
			font := StrikeFont fontName: 'VerdanaBold' size: 11.
			s := StringMorph contents: 'Brush size: ' localized.
			self mode = #erase
				ifTrue: [ s contents: 'Eraser size' localized , ': ' ].
			s
				font: font;
				color: Color gray darker.
			brushSizeMorph addMorphBack: s.
			colorToUse := self mode = #erase
				ifTrue: [ Color transparent ]
				ifFalse: [ self color1 ].
			brushSizeMorph
				addMorphBack:
					(Morph new
						extent: 2 @ 5;
						color: Color transparent; 
		yourself).
			brushSizeMorph addMorphBack: (ImageMorph new form: (PhratchFrameMorph skinAt: #downArrow)).
			brushSizeMorph
				addMorphBack:
					(Morph new
						extent: 4 @ 5;
						color: Color transparent; 
		yourself).
			brushThumbnail := Morph new
				extent: 30 @ 30;
				color: Color transparent; 
		yourself.
			n2 := self brushSize.
			n2 <= 6
				ifTrue: [ n2 := n2 + 1 ].
			n2 == 29
				ifTrue: [ n2 := 23 ].
			n2 == 47
				ifTrue: [ n2 := 25 ].
			n2 == 75
				ifTrue: [ n2 := 27 ].
			brushIcon := ImageMorph new form: (PaintCanvas brushCursorSize: n2 color: colorToUse scale: 1).
			brushIcon position: 15 @ 15 - ((n2 // 2) @ (n2 // 2)).
			brushThumbnail addMorphBack: brushIcon.
			brushSizeMorph addMorphBack: brushThumbnail.
			options addMorphBack: brushSizeMorph ].
	(#(#oval #rect) includes: self mode)
		ifTrue: [ 
			b := ToggleButton
				onForm: (PhratchFrameMorph skinAt: #paintOptionsButtonPressed)
				offForm: (PhratchFrameMorph skinAt: #paintOptionsButton).
			b
				target: self;
				actionSelector: #shapeFilling:;
				arguments: (Array with: true);
				toggleMode: false.
			self shapeFilling
				ifTrue: [ b on ].
			self mode = #oval
				ifTrue: [ 
					form := Form extent: 16 @ 17 depth: 16.
					(FormCanvas on: form) fillOval: form boundingBox color: self color1 ]
				ifFalse: [ 
					form := Form extent: 16 @ 17 depth: 8.
					form fillColor: self color1 ].
			formMorph := ImageMorph new
				form: form;
				position: 7 @ 5; 
		yourself.
			b addMorph: formMorph.
			options addMorphBack: b.
			options
				addMorphBack:
					(Morph new
						extent: 5 @ 2;
						color: Color transparent; 
		yourself).
			b := ToggleButton
				onForm: (PhratchFrameMorph skinAt: #paintOptionsButtonPressed)
				offForm: (PhratchFrameMorph skinAt: #paintOptionsButton).
			b
				target: self;
				actionSelector: #shapeFilling:;
				arguments: (Array with: false);
				toggleMode: false.
			self shapeFilling
				ifFalse: [ b on ].
			self mode = #oval
				ifTrue: [ 
					form := Form extent: 16 @ 17 depth: 16.
					(FormCanvas on: form) frameOval: form boundingBox width: 2 color: self color1 ]
				ifFalse: [ 
					form := Form extent: 16 @ 17 depth: 8.
					form border: (0 @ 0 extent: 16 @ 17) width: 2 fillColor: self color1 ].
			formMorph := ImageMorph new
				form: form;
				position: 7 @ 5; 
		yourself.
			b addMorph: formMorph.
			options addMorphBack: b ].
	#fill = self mode
		ifTrue: [ 
			fillStylePane := AlignmentMorph newRow
				inset: 0;
				borderWidth: 0;
				color: Color transparent;
				vResizing: #shrinkWrap;
				hResizing: #shrinkWrap; 
		yourself.
			spacer := Morph new
				extent: 5 @ 5;
				color: Color transparent; 
		yourself.
			#(#color #hGradient #vGradient #rGradient)
				do: [ :style | 
					b := ToggleButton
						onForm: (PhratchFrameMorph skinAt: #paintOptionsButtonPressed)
						offForm: (PhratchFrameMorph skinAt: #paintOptionsButton).
					b
						target: self;
						actionSelector: #paintBucketFillStyle:;
						arguments: (Array with: style);
						toggleMode: false.
					form := Form extent: 16 @ 17 depth: 32.
					style == #color
						ifTrue: [ form fillColor: self color1 ].
					style == #hGradient
						ifTrue: [ form fillFromXColorBlock: [ :m | self color2 mixed: m with: self color1 ] ].
					style == #vGradient
						ifTrue: [ form fillFromYColorBlock: [ :m | self color2 mixed: m with: self color1 ] ].
					style == #rGradient
						ifTrue: [ form fillRadialFromXColorBlock: [ :m | self color2 mixed: m with: self color1 ] center: 8 @ 8 ].
					formMorph := ImageMorph new
						form: form;
						position: 7 @ 5; 
		yourself.
					formMorph lock.
					b addMorph: formMorph.
					b off.
					style == self paintBucketFillStyle
						ifTrue: [ b on ].
					fillStylePane addMorphBack: spacer fullCopy.
					fillStylePane addMorphBack: b.
					b position: b left @ b top + 2 ].
			fillStylePane addMorphBack: spacer fullCopy.
			options addMorphBack: fillStylePane ].
	#text = self mode
		ifTrue: [ 
			font := StrikeFont fontName: 'VerdanaBold' size: 11.
			fName := canvasMorph canvasTextBox font familyName.
			textFontMenu := ImageMorph new form: (PhratchFrameMorph skinAt: #textFontMenu).
			textFontMorph := StringMorph new font: font.
			textFontMorph contents: (textFontMorph stringWithEllipses: fName limitedToWidth: 109).
			textFontMenu addMorph: textFontMorph.
			textFontMorph position: 8 @ 3.
			textSizeMenu := ImageMorph new form: (PhratchFrameMorph skinAt: #textSizeMenu).
			textSizeMorph := StringMorph contents: canvasMorph canvasTextBox font pointSize asString font: font.
			textSizeMenu addMorph: textSizeMorph.
			textSizeMorph position: 9 @ 3.
			aColor2 := self color1.
			aColor2 == Color transparent
				ifTrue: [ aColor2 := Color white ].
			canvasMorph textColor: aColor2.
			canvasMorph changed.
			options
				addMorphBack: textFontMenu;
				addMorphBack:
						(Morph new
								width: 8;
								height: 5;
								color: Color transparent; 
		yourself);
				addMorphBack: textSizeMenu ].
	optionsPane addMorph: options.
	options
		position:
			(optionsPane left + (optionsPane width // 2) - (options width // 2))
				@ (optionsPane top + (optionsPane height // 2) - (options height // 2))
]

{ #category : #menus }
PaintPalette >> updateSizeMenu: aSize [
	| choice oldFont newFont font |
	font := canvasMorph canvasTextBox font.
	choice := aSize asNumber.
	choice ifNil: [ ^ self ].
	textSizeMorph contents: choice asString.
	oldFont := canvasMorph canvasTextBox font.
	newFont := oldFont isOSFont
		ifTrue: [ StrikeFont osFontName: font name size: choice ]
		ifFalse: [ StrikeFont fontName: font name size: choice ].
	canvasMorph canvasTextBox font: newFont.
	canvasMorph changed
]

{ #category : #'event handling' }
PaintPalette >> updateToolbarButtons [

	toolbarButtons ifNil: [^ self].
	toolbarButtons allMorphsDo: [:b |
		(b isToggleButton) ifTrue: [
			b arguments first = self mode ifTrue: [b on] ifFalse: [b off]]].

]
