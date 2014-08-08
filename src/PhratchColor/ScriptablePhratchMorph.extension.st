Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> addColor [

	| sFrame result colorName colorOwner |
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ PhratchError error: 'beep'.].

	result := NewVariableDialog ask: 'Color name?'.
	result = #cancelled ifTrue: [^ self].
	colorName := result first.
	colorOwner := result second ifTrue: [self] ifFalse: [sFrame workPane].
	(colorOwner variableNameInUse: colorName) ifTrue: [
		PhratchError error: 'beep'.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	colorOwner addColor: colorName.
	sFrame viewerPane categoryChanged: 'colors'.
	
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> addColor: colorName [
	"Add a new random color with the given name to this object."
	<phratchItem: 'make color $String$' kind: #- category: 'colors' defaultValues: #('a color') subCategory: #a3 special: #()>
	| sFrame stage isGlobal |
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ PhratchError error: 'beep'.].
	isGlobal := false.
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph)
		ifNotNil: [isGlobal := stage colorNames includes: colorName asString].
	((colors includesKey: colorName asString) or: [isGlobal]) ifFalse: [
		colors at: colorName asString put: (Color black)].
	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> addGlobalColor [
	"Ask the user for a color variable name, then add a background (global) variable of that name."

	| sFrame cName |
	(sFrame := self ownerThatIsAPhratchFrameMorph) ifNil: [^ PhratchError error: 'beep'.].

	cName := StringDialog ask: 'Variable name?'.
	cName size = 0 ifTrue: [^ self].
	cName := cName.
	(sFrame workPane colorNames includes: cName) ifTrue: [
		PhratchError error: 'beep'.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	sFrame workPane addColor: cName.
	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorAsString: aColor [
	"Give the RGB string representation of the given color"
	<phratchItem: '$Color$ as string' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a7 special: #()>
	^ aColor asHTMLColor
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorAtX: x y: y [
	"select the color of the given pixel"
	<phratchItem: 'color of pixel x: $Number$ y: $Number$' kind: #ColorBlockMorph category: 'colors' defaultValues: #(0 0) subCategory:
		#a3 special: #()>
	| frame w newX newY p |
	frame := self ownerThatIsAPhratchFrameMorph.
	frame
		ifNil: [ 
			(w := self ownerThatIsAOffscreenWorldMorph) ifNil: [ ^ self ].
			frame := w frame ].
	newX := x.
	newX isNaN
		ifTrue: [ newX := 0 ].
	newX := newX min: 240.
	newX := newX max: -240.
	newY := y.
	newY isNaN
		ifTrue: [ newY := 0 ].
	newY := newY max: -180.
	newY := newY min: 180.
	DoubleSize
		ifTrue: [ 
			newX := newX * 2.
			newY := newY * 2 ].
	p := newX @ newY negated.
	^ Display colorAt: PhratchOrigin + p
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorB: aColor [
	"Give the value of the blue in the RGB representation of the color"
	<phratchItem: '$Color$ blue' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a4 special: #()>
	^ aColor blue.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorG: aColor [
	"Give the value of the green in the RGB representation of the color"
	<phratchItem: '$Color$ green' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a4 special: #()>
	^ aColor green.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorH: aColor [
	"Give the value of the hue of the given color"
	<phratchItem: '$Color$ hue' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a5 special: #()>
	^ aColor hue.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorH: h s: s v: v [
	"Answer the given HSB color."
	<phratchItem: 'color h: $Number$ s: $Number$ b: $Number$' kind: #ColorBlockMorph category: 'colors' defaultValues: #(0 0 0) subCategory: #a5 special: #()>
	^ (Color h: h s: s v: v).
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorNames [

	^ colors keys asArray sort.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorR: aColor [
	"Give the value of the red in the RGB representation of the color"
	<phratchItem: '$Color$ red' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a4 special: #()>
	^ aColor red.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorR: r g: g b: b [
	"Answer the given RGB color."

	<phratchItem: 'color r: $Number$ g: $Number$ b: $Number$' kind: #ColorBlockMorph category: 'colors' defaultValues: #(0 0 0) subCategory: #a4 special: #()>
	^ (Color r: r g: g b: b).
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorS: aColor [
	"Give the value of the saturation of the given color"
	<phratchItem: '$Color$ saturation' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a5 special: #()>
	^ aColor saturation.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorV: aColor [
	"Give the value of the brightness of the given color"
	<phratchItem: '$Color$ brightness' kind: #ReporterWatcherBlockMorph category: 'colors' defaultValues: #() subCategory: #a5 special: #()>
	^ aColor brightness.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> colorsMenu [
	"Ask the user which user variable to show, then show it."

	| sFrame stage menu  |
	sFrame := self ownerThatIsAPhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.

	menu := MenuMorph new.
	stage colorNames do: [:v | menu add: v value: v].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value: v]].
	menu invokeModal.
	^ menu
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> deleteColor [
	"Ask the user which user variable to delete, then remove it."

	| sFrame stage menu choice |
	sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage colorNames isEmpty) & (self colorNames isEmpty)
		ifTrue: [^ self inform: 'No colors.' localized].

	menu := MenuMorph new.
	stage colorNames do: [:v | menu add: v value: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value: (Array with: v with: #local)]].
	choice := menu invokeModal; selectedValue.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage deleteColor: choice first]
		ifFalse: [self deleteColor: choice first].

	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> deleteColor: colorName [
	"Delete the variable with the given name. Do nothing if the variable doesn't exist."

	| frame |
	colors removeKey: colorName asString ifAbsent: [^ self].
	(frame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [frame := (self ownerOrYourselfThatIsAOffscreenWorldMorph) frame].
	frame deleteWatchersForVar: colorName ofSprite: self.
	frame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> deleteColorFull: colorName [
	"Delete the color variable with the given name. Do nothing if the variable doesn't exist."
	<phratchItem: 'delete color $String$' kind: #- category: 'colors' defaultValues: #('a color') subCategory: #a3 special: #()>
	| frame stage |
	(colors includesKey: colorName) ifTrue: [self deleteColor: colorName].
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	(stage notNil and: [stage colorNames includes: colorName]) ifTrue: [stage deleteColor: colorName].
	(frame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ self].
	frame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> getColor: colorName [

	^ colors at: colorName ifAbsent: [(Color black)]
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> getNamedColor: aColorName [
	"Return the color with the given name"
	<phratchItem: 'color named $NamedColors$' kind: #ColorBlockMorph category: 'colors' defaultValues: #() subCategory: #a7 special: #()>
	^ Color fromString: aColorName.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> hideColor [
	"Ask the user which user variable to hide, then hide it."

	| sFrame stage menu choice |
	sFrame := self ownerThatIsAPhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage colorNames isEmpty) & (self colorNames isEmpty)
		ifTrue: [^ self inform: 'No colors.' localized].

	menu := MenuMorph new.
	stage colorNames do: [:v | menu add: v value: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value:  (Array with: v with: #local)]].
	choice := menu invokeModal; selectedValue.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage hideColor: choice first]
		ifFalse: [self hideColor: choice first].

	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> hideColor: varName [
	"Hide the watcher(s) for the given color. If the receiver is a sprite and both it and and the stage have the given color, hide both. Do nothing if the color does not exist or is already hidden."
	<phratchItem: 'hide color $ColorVar$' kind: #- category: 'colors' defaultValues: #('') subCategory: #a2 special: #()>
	| stage |
	self showOrHideColor: varName show: false.

	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideColor: varName show: false].
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> mixColor: color1 ratioA: a toB: b with: color2 [
	"Mix the two colors with the given ratios"
	<phratchItem: 'mix $Color$ $Number$ : $Number$ with $Color$' kind: #ColorBlockMorph category: 'colors' defaultValues: #() subCategory: #a6 special: #()>
	^ color1 mixed: (a / (a + b)) with: color2.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> mixColor: color1 with: color2 [
	"Mix the two colors"
	<phratchItem: 'mix $Color$ with $Color$' kind: #ColorBlockMorph category: 'colors' defaultValues: #() subCategory: #a6 special: #()>
	^ color1 mixed: 0.5 with: color2.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> namedColors [

	^ self colorNames.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> reportColor: colorName [
	"Answer the value of the given color variable of this object or its parent."
	<phratchItem: '$ColorVar$' kind: #ColorBlockMorph category: 'colors' defaultValues: #('') subCategory: #a1 special: #()>
	| stage |
	(self colorNames includes: colorName)
		ifTrue: [^ self getColor: colorName].
	(stage := self ownerThatIsAPhratchStageMorph)
		ifNotNil: [^ stage getColor: colorName]
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> setColor: colorName to: newValue [
	"Set the given color attribute to the given value"
	<phratchItem: 'set $ColorVar$ to $Color$' kind: #- category: 'colors' defaultValues: #('') subCategory: #a1 special: #()>
	| cName stage |
	cName := colorName asString. "convert Symbol to String if needed"
	(colors includesKey: cName) ifFalse: [
		stage := self ownerThatIsAPhratchStageMorph.
		(stage notNil and: [stage ~= self]) ifTrue: [
			stage setColor: cName to: newValue].
		^ self].

	colors at: cName put: newValue.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> showColor [
	"Ask the user which user variable to show, then show it."

	| sFrame stage menu choice |
	sFrame := self ownerThatIsAPhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage colorNames isEmpty) & (self colorNames isEmpty)
		ifTrue: [^ self inform: 'No colors.' localized].

	menu := MenuMorph new.
	stage colorNames do: [:v | menu add: v value: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value: (Array with: v with: #local)]].
	choice := menu invokeModal; selectedValue.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage showColor: choice first]
		ifFalse: [self showColor: choice first].

	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> showColor: varName [
	"Show the watcher for the given color. If the receiver is a sprite and both it and and the stage have the given color, hide both. Do nothing if the color does not exist or is already hidden."
	<phratchItem: 'show color $ColorVar$' kind: #- category: 'colors' defaultValues: #('') subCategory: #a2 special: #()>
	| stage |
	self showOrHideColor: varName show: true.

	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideColor: varName show: true].
]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> showOrHideColor: varName show: showFlag [
	"Show the watcher for the given variable. Do nothing if the variable does not exist or is already showing."

	| frame w b palette |
	(self colorNames includes: varName) ifFalse: [^ self].
	frame := self ownerThatIsAPhratchFrameMorph.
	frame ifNil: [
		(w := self ownerThatIsAOffscreenWorldMorph) ifNil: [^ self].
		frame := w frame].

	b := (self blockFromSpec: #('$ColorVar$' ColorBlockMorph reportColor: '')  color: (PhratchCategory blockColorFor: 'colors')) defaultArgs: {varName}.
	w := frame watcherForBlock: b.
	showFlag
		ifTrue: [w ifNil: [frame showWatcher: b createWatcher]]
		ifFalse: [w ifNotNil: [w delete]].

	palette := frame viewerPane pageViewer contents.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #'*PhratchColor' }
ScriptablePhratchMorph >> stringAsColor: aString [
	"Convert the given string into a color"
	<phratchItem: '$String$ as color' kind: #ColorBlockMorph category: 'colors' defaultValues: #('#FFFFFF') subCategory: #a7 special: #()>
	^ Color fromString: (aString asString).
]
