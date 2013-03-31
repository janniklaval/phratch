Class {
	#name : #ScratchStringMorph,
	#superclass : #Morph,
	#instVars : [
		'font',
		'emphasis',
		'contents',
		'hasFocus',
		'forceUnicodeRendering',
		'kern',
		'flags',
		'rightJustify'
	],
	#classVars : [
		'EditableStringMorph'
	],
	#category : #'Phratch-Compatibility'
}

{ #category : #'instance creation' }
ScratchStringMorph class >> contents: aString [
	" 'StringMorph contents: str' is faster than 'StringMorph new contents: str' "
	^ self contents: aString font: nil
]

{ #category : #'instance creation' }
ScratchStringMorph class >> contents: aString font: aFont [
	^ self new contents: aString font: aFont
]

{ #category : #setting }
ScratchStringMorph class >> editableStringMorph [
	^ EditableStringMorph ifNil: [EditableStringMorph := false]
]

{ #category : #setting }
ScratchStringMorph class >> editableStringMorph: aBoolean [
	EditableStringMorph := aBoolean
]

{ #category : #editing }
ScratchStringMorph >> acceptContents [
	"The message is sent when the user hits enter or Cmd-S. Accept the current contents and end editing. This default implementation does nothing."

]

{ #category : #editing }
ScratchStringMorph >> acceptValue: aValue [
	| val |
	self contents: (val := aValue asString).
	^ val
]

{ #category : #menu }
ScratchStringMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change font' translated action: #changeFont.
	aCustomMenu add: 'change emphasis' translated action: #changeEmphasis.

]

{ #category : #'halos and balloon help' }
ScratchStringMorph >> addOptionalHandlesTo: aHalo box: box [
	self flag: #deferred.

	"Eventually...
	self addFontHandlesTo: aHalo box: box"
]

{ #category : #drawing }
ScratchStringMorph >> areasRemainingToFill: aRectangle [

	^ Array with: aRectangle
]

{ #category : #'halos and balloon help' }
ScratchStringMorph >> boundsForBalloon [
	"Some morphs have bounds that are way too big.  This is a contorted way of making things work okay in PluggableListMorphs, whose list elements historically have huge widths"

	| ownerOwner |
	^ ((owner notNil and: [(ownerOwner := owner owner) notNil]) and:
			[ownerOwner isKindOf: PluggableListMorph])
		ifTrue:
			[self boundsInWorld intersect: ownerOwner boundsInWorld]
		ifFalse:
			[super boundsForBalloon]
]

{ #category : #editing }
ScratchStringMorph >> cancelEdits [

	self doneWithEdits
]

{ #category : #menu }
ScratchStringMorph >> changeEmphasis [

	| reply |
	reply := UIManager default 
				chooseFrom: (self emphasisChoices collect: [:t | t translated]) 
				values: self emphasisChoices.
	reply ifNotNil:[
		self emphasis: (TextEmphasis perform: reply) emphasisCode.
	].

]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> closeEditor [
	"Be sure that any StringMorphEditors on me have been removed."

	self doneWithEdits.
	submorphs size = 0 ifTrue: [^ self].
	submorphs copy do: [:m |
		(m isKindOf: StringMorphEditor) ifTrue: [m delete]].
]

{ #category : #accessing }
ScratchStringMorph >> contents [

	^ contents
]

{ #category : #accessing }
ScratchStringMorph >> contents: newContents [ 
	| scanner |
	contents := newContents isText
				ifTrue: [scanner := StringMorphAttributeScanner new initializeFromStringMorph: self.
					(newContents attributesAt: 1 forStyle: self font textStyle)
						do: [:attr | attr emphasizeScanner: scanner].
					emphasis := scanner emphasis.
					font := scanner font emphasis: emphasis.
					color := scanner textColor.
					newContents string]
				ifFalse: [contents = newContents
						ifTrue: [^ self].
					"no substantive change"
					newContents].
	self fitContents
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> contents: aString font: aFont [

	font := aFont.
	self contents: aString.
]

{ #category : #accessing }
ScratchStringMorph >> contentsClipped: aString [
	"Change my text, but do not change my size as a result"
	contents = aString ifTrue: [^ self].  "No substantive change"
	contents := aString.
	self changed
]

{ #category : #initialization }
ScratchStringMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #editing }
ScratchStringMorph >> doneWithEdits [

	hasFocus := false
]

{ #category : #drawing }
ScratchStringMorph >> drawOn: aCanvas [

	aCanvas drawString: contents in: bounds font: self fontToUse color: color.
]

{ #category : #font }
ScratchStringMorph >> emphasis: aNumber [
	"Set the receiver's emphasis as indicated. aNumber is a bitmask with the following format:

	bit	attribute
	1	bold
	2	italic
	4	underlined
	8	narrow
	16	struckOut"

	"examples: 0 -> plain.  
	1 -> bold.  2 -> italic.  3 -> bold italic.  4 -> underlined  
	5 -> bold underlined.  6 -> italic underlined.   7 -> bold italic underlined   
	etc..."

	emphasis := aNumber.
	^ self font: font emphasis: emphasis
]

{ #category : #menu }
ScratchStringMorph >> emphasisChoices [
	"Returns the emphasis selectors that are sent to a TextEmphasis."
	
	^ #(normal bold italic narrow underlined struckOut)
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> fieldsVersion [

	^ 1

]

{ #category : #accessing }
ScratchStringMorph >> fitContents [

	| newBounds boundsChanged |
	newBounds := self measureContents.
	boundsChanged := bounds extent ~= newBounds.
	self extent: newBounds.		"default short-circuits if bounds not changed"
	boundsChanged ifFalse: [self changed]
]

{ #category : #accessing }
ScratchStringMorph >> font [
	"who came up with #fontToUse rather than font?!"
	^self fontToUse
]

{ #category : #printing }
ScratchStringMorph >> font: aFont [ 
	"Set the font my text will use. The emphasis remains unchanged."

	font := aFont.
	^ self font: font emphasis: emphasis
]

{ #category : #accessing }
ScratchStringMorph >> font: aFont emphasis: emphasisCode [
	font := aFont.
	emphasis := emphasisCode.
	self fitContents.
"
in inspector say,
	 self font: (TextStyle default fontAt: 2) emphasis: 1
"
]

{ #category : #accessing }
ScratchStringMorph >> fontName: fontName size: fontSize [

	^ self font: (StrikeFont familyName: fontName size: fontSize) 
			emphasis: 0
]

{ #category : #accessing }
ScratchStringMorph >> fontToUse [
	| fontToUse |
	fontToUse := font isNil ifTrue: [TextStyle defaultFont] ifFalse: [font].
	(emphasis isNil or: [emphasis = 0]) 
		ifTrue: [^fontToUse]
		ifFalse: [^fontToUse emphasized: emphasis]
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> forceUnicodeRendering [

	^forceUnicodeRendering ifNil: [forceUnicodeRendering := false].
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> forceUnicodeRendering: anObject [
	forceUnicodeRendering := anObject
]

{ #category : #'t-rotating' }
ScratchStringMorph >> forwardDirection [
	"Return the receiver's forward direction (in eToy terms)"
	^self valueOfProperty: #forwardDirection ifAbsent:[0.0]
]

{ #category : #'t-rotating' }
ScratchStringMorph >> forwardDirection: newDirection [
	"Set the receiver's forward direction (in eToy terms)"
	self setProperty: #forwardDirection toValue: newDirection.
]

{ #category : #layout }
ScratchStringMorph >> fullBounds [
	self contents ifNil: [ self contents: 'String Morph' ].
	^super fullBounds
]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> handlesMouseDown: evt [
	"If the shift key is pressed then yes.
	As normal if StringMorph class>> editableStringMorph  returns false."
	
	^ (self isEditable: evt)
		ifTrue: [true]
		ifFalse: [super handlesMouseDown: evt]
]

{ #category : #'event handling' }
ScratchStringMorph >> hasFocus [
	^ hasFocus
]

{ #category : #accessing }
ScratchStringMorph >> hasTranslucentColor [

	^true
]

{ #category : #'t-rotating' }
ScratchStringMorph >> heading [
	"Return the receiver's heading"
	^ self owner 
		ifNil: [self forwardDirection]
		ifNotNil: [self forwardDirection + self owner degreesOfFlex]
]

{ #category : #drawing }
ScratchStringMorph >> imageForm: depth forRectangle: rect [
	| canvas |
	canvas := Display defaultCanvasClass extent: rect extent depth: depth.
	canvas form fillColor: Color white. 
	canvas translateBy: rect topLeft negated
		during:[:tempCanvas| tempCanvas fullDrawMorph: self].
	^ canvas form offset: rect topLeft
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> initFieldsFrom: anObjStream version: classVersion [

	| fontSpec |
	super initFieldsFrom: anObjStream version: classVersion.
	fontSpec := anObjStream nextField.
	fontSpec ifNotNil: [
		font := StrikeFont fontName: fontSpec first size: fontSpec second].

	self initFieldsNamed: #(
		emphasis
		contents
	) from: anObjStream.
]

{ #category : #initialization }
ScratchStringMorph >> initWithContents: aString font: aFont emphasis: emphasisCode [ 
	super initialize.
	
	font := aFont.
	emphasis := emphasisCode.
	hasFocus := false.
	self contents: aString
]

{ #category : #initialization }
ScratchStringMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.

	font := nil.
	emphasis := 0.
	hasFocus := false
]

{ #category : #accessing }
ScratchStringMorph >> interimContents: aString [
	"The receiver is under edit and aString represents the string the user sees as she edits, which typically will not have been accepted and indeed may be abandoned"

	self contents: aString
]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> isEditable: evt [
	"If the shift key is pressed then yes.
	As normal if StringMorph class>> editableStringMorph  returns false."
	
	^(self class editableStringMorph and: [evt shiftPressed and: [self wantsKeyboardFocusOnShiftClick]])

]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> justificationOffsetFor: aString [

	rightJustify ifNil: [rightJustify := false].
	rightJustify ifFalse: [^ 0].

	^ (self width - (self stringWidth: self stringToDisplay)) max: 0
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> kern [
	^ kern
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> kern: anObject [
	kern := anObject
]

{ #category : #editing }
ScratchStringMorph >> launchMiniEditor: evt [

	| textMorph |
	hasFocus := true.  "Really only means edit in progress for this morph"
	textMorph := StringMorphEditor new contentsAsIs: contents.
	textMorph beAllFont: self fontToUse.
	textMorph bounds: (self bounds expandBy: 0@2).
	self addMorphFront: textMorph.
	evt hand newKeyboardFocus: textMorph.
	textMorph editor selectFrom: 1 to: textMorph paragraph text string size
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> leftMargin [
	"Answer the left edge of this StringMorph. For a left-justified string, this the left edge of its bounding box, but for a right-justified string it may be inset."

	^ self left + (self justificationOffsetFor: contents)

]

{ #category : #drawing }
ScratchStringMorph >> lookTranslucent [

	"keep the text the same color (black)"
]

{ #category : #editing }
ScratchStringMorph >> lostFocusWithoutAccepting [
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus -- typically by clicking on some editable text somewhere else -- without having accepted the current edits."

	self acceptContents
]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> measureContents [
	"Round up in case fractional."
	
	| f |
	f := self fontToUse.
	^(((f widthOfString: contents) max: self minimumWidth)  @ f height) ceiling
]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> minHeight [
	"Answer the minimum height of the receiver."
	
	^self fontToUse height max: super minHeight
]

{ #category : #accessing }
ScratchStringMorph >> minimumWidth [
	"Answer the minimum width that the receiver can have.  A nonzero value here keeps the receiver from degenerating into something that cannot ever be seen or touched again!  Obeyed by fitContents."

	^ 3
]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> mouseDown: evt [
	"If the shift key is pressed, make this string the keyboard input focus.
	Process as normal if StringMorph class>> editableStringMorph  returns false."

	(self isEditable: evt)
		ifTrue: [self launchMiniEditor: evt]
		ifFalse: [super mouseDown: evt].

]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> paneColor [
	"Answer the window's pane color or our owner's color otherwise."

	^self paneColorOrNil ifNil: [self owner ifNil: [Color transparent] ifNotNil: [self owner color]]
]

{ #category : #'t-rotating' }
ScratchStringMorph >> prepareForRotating [
	"If I require a flex shell to rotate,
	then wrap it in one and return it.
	Polygons, eg, may override to do nothing."

	^ self addFlexShell
]

{ #category : #printing }
ScratchStringMorph >> printOn: aStream [

	super printOn: aStream.
	aStream print: contents.

]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> rightJustify: aBoolean [

	rightJustify = aBoolean ifFalse: [self changed].
	rightJustify := aBoolean.

]

{ #category : #'t-rotating' }
ScratchStringMorph >> rotationDegrees [
	"Default implementation."

	^ 0.0

]

{ #category : #'t-rotating' }
ScratchStringMorph >> rotationDegrees: degrees [	
	"redefined in all morphs which are using myself"
]

{ #category : #'t-rotating' }
ScratchStringMorph >> setDirectionFrom: aPoint [
	| delta degrees |
	delta := (self transformFromWorld globalPointToLocal: aPoint) - self referencePosition.
	degrees := delta degrees + 90.0.
	self forwardDirection: (degrees \\ 360) rounded.

]

{ #category : #'Polymorph-Widgets' }
ScratchStringMorph >> setWidth: width [
	"Round up in case fractional."
	
	self extent: (width @ (font ifNil: [TextStyle defaultFont]) height) ceiling
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> storeFieldsOn: anObjStream [

	self closeEditor.
	super storeFieldsOn: anObjStream.
	font
		ifNil: [anObjStream putField: nil]
		ifNotNil: [anObjStream putField: (Array with: font name with: font pointSize)].
	self storeFieldsNamed: #(
		emphasis
		contents
	) on: anObjStream.

]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> stringExtent: aString [
	"Answer the extent of the given string in my current font."

	| s usingOSFont scanner |
	s := aString.
	usingOSFont := font notNil and: [font isOSFont].
	s isUnicode | self forceUnicodeRendering | usingOSFont ifTrue: [
		ScratchTranslator canRenderUnicode
			ifTrue: [^ ScratchTranslator stringExtent: s asMacRoman    font: self font]
			ifFalse: [s := s asMacRoman]].

	scanner := MultiDisplayScanner quickPrintOn: Display box: Display boundingBox font: self font.
	kern ifNotNil: [scanner addKern: kern].
	^ scanner stringExtent: s
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> stringHeight: aString [
	"Answer the height of the given string in my current font."

	^ (self stringExtent: aString) y

]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> stringToDisplay [
	"Answer the string that is displayed. In password mode, this will be all asterisks."

	| n s |
	"passwordMode ifNil: [passwordMode := false].
	passwordMode ifTrue: [
		n := (contents isKindOf: UTF8) ifTrue: [contents asUTF32 size] ifFalse: [contents size].
		s := String new: n withAll: $*.
		contents isUnicode ifTrue: [s := s asUTF8].
		^ s]."

	^ contents
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> stringWidth: aString [
	"Answer the width of the given string in my current font."

	^ font widthOfString: aString
"
	^ (self stringExtent: aString) x"
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> stringWithEllipses: aString limitedToWidth: aNumber [
	"Answer the given string limited in width. If the string is too wide to fit, truncate it and append ellipses."

	| ellipses maxW s w |
	ellipses := ScratchTranslator ellipsesSuffix "asUTF32".
	maxW := (aNumber - (self stringWidth: ellipses)) max: 10.
	s := aString "asUTF32".
	(self stringWidth: s) < maxW ifTrue: [^ aString].

	1 to: s size do: [:i |
		w := self stringWidth: (s copyFrom: 1 to: i), ellipses.
		w > maxW ifTrue: [
			^ ((s copyFrom: 1 to: i - 1), ellipses) "asUTF8"]].

	^ aString

]

{ #category : #accessing }
ScratchStringMorph >> userString [
	"Do I have a text string to be searched on?"

	^ contents
]

{ #category : #accessing }
ScratchStringMorph >> valueFromContents [
	"Return a new value from the current contents string."
	^ contents
]

{ #category : #editing }
ScratchStringMorph >> wantsKeyboardFocusOnShiftClick [
	^ owner topRendererOrSelf wantsKeyboardFocusFor: self

]

{ #category : #'event handling' }
ScratchStringMorph >> wouldAcceptKeyboardFocus [
	^ self isLocked not
]

{ #category : #'NScratch-Extensions' }
ScratchStringMorph >> xRangesFor: s [
	"Anwer an array of (leftX, rightX) pairs for the given string. For Unicode, there will be an entry in the resulting array for each UTF character in the input string, even when characters combine, so the x ranges for characters may overlap."
	"StringMorph new xRangesFor: 'Hello' asUTF8"

	s isUnicode | self forceUnicodeRendering ifTrue: [
		ScratchTranslator canRenderUnicode
			ifTrue: [^ ScratchTranslator xRangesFor: s asMacRoman  font: self font]
			ifFalse: [^ self font xRangesFor: s asMacRoman]].

	^ self font xRangesFor: s

]
