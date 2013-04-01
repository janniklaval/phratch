Class {
	#name : #PhratchStringMorph,
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
PhratchStringMorph class >> contents: aString [
	" 'StringMorph contents: str' is faster than 'StringMorph new contents: str' "
	^ self contents: aString font: nil
]

{ #category : #'instance creation' }
PhratchStringMorph class >> contents: aString font: aFont [
	^ self new contents: aString font: aFont
]

{ #category : #setting }
PhratchStringMorph class >> editableStringMorph [
	^ EditableStringMorph ifNil: [EditableStringMorph := false]
]

{ #category : #setting }
PhratchStringMorph class >> editableStringMorph: aBoolean [
	EditableStringMorph := aBoolean
]

{ #category : #editing }
PhratchStringMorph >> acceptContents [
	"The message is sent when the user hits enter or Cmd-S. Accept the current contents and end editing. This default implementation does nothing."

]

{ #category : #editing }
PhratchStringMorph >> acceptValue: aValue [
	| val |
	self contents: (val := aValue asString).
	^ val
]

{ #category : #menu }
PhratchStringMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change font' translated action: #changeFont.
	aCustomMenu add: 'change emphasis' translated action: #changeEmphasis.

]

{ #category : #'halos and balloon help' }
PhratchStringMorph >> addOptionalHandlesTo: aHalo box: box [
	self flag: #deferred.

	"Eventually...
	self addFontHandlesTo: aHalo box: box"
]

{ #category : #drawing }
PhratchStringMorph >> areasRemainingToFill: aRectangle [

	^ Array with: aRectangle
]

{ #category : #'halos and balloon help' }
PhratchStringMorph >> boundsForBalloon [
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
PhratchStringMorph >> cancelEdits [

	self doneWithEdits
]

{ #category : #menu }
PhratchStringMorph >> changeEmphasis [

	| reply |
	reply := UIManager default 
				chooseFrom: (self emphasisChoices collect: [:t | t translated]) 
				values: self emphasisChoices.
	reply ifNotNil:[
		self emphasis: (TextEmphasis perform: reply) emphasisCode.
	].

]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> closeEditor [
	"Be sure that any StringMorphEditors on me have been removed."

	self doneWithEdits.
	submorphs size = 0 ifTrue: [^ self].
	submorphs copy do: [:m |
		(m isKindOf: StringMorphEditor) ifTrue: [m delete]].
]

{ #category : #accessing }
PhratchStringMorph >> contents [

	^ contents
]

{ #category : #accessing }
PhratchStringMorph >> contents: newContents [ 
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
PhratchStringMorph >> contents: aString font: aFont [

	font := aFont.
	self contents: aString.
]

{ #category : #accessing }
PhratchStringMorph >> contentsClipped: aString [
	"Change my text, but do not change my size as a result"
	contents = aString ifTrue: [^ self].  "No substantive change"
	contents := aString.
	self changed
]

{ #category : #initialization }
PhratchStringMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #editing }
PhratchStringMorph >> doneWithEdits [

	hasFocus := false
]

{ #category : #drawing }
PhratchStringMorph >> drawOn: aCanvas [

	aCanvas drawString: contents in: bounds font: self fontToUse color: color.
]

{ #category : #font }
PhratchStringMorph >> emphasis: aNumber [
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
PhratchStringMorph >> emphasisChoices [
	"Returns the emphasis selectors that are sent to a TextEmphasis."
	
	^ #(normal bold italic narrow underlined struckOut)
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> fieldsVersion [

	^ 1

]

{ #category : #accessing }
PhratchStringMorph >> fitContents [

	| newBounds boundsChanged |
	newBounds := self measureContents.
	boundsChanged := bounds extent ~= newBounds.
	self extent: newBounds.		"default short-circuits if bounds not changed"
	boundsChanged ifFalse: [self changed]
]

{ #category : #accessing }
PhratchStringMorph >> font [
	"who came up with #fontToUse rather than font?!"
	^self fontToUse
]

{ #category : #printing }
PhratchStringMorph >> font: aFont [ 
	"Set the font my text will use. The emphasis remains unchanged."

	font := aFont.
	^ self font: font emphasis: emphasis
]

{ #category : #accessing }
PhratchStringMorph >> font: aFont emphasis: emphasisCode [
	font := aFont.
	emphasis := emphasisCode.
	self fitContents.
"
in inspector say,
	 self font: (TextStyle default fontAt: 2) emphasis: 1
"
]

{ #category : #accessing }
PhratchStringMorph >> fontName: fontName size: fontSize [

	^ self font: (StrikeFont familyName: fontName size: fontSize) 
			emphasis: 0
]

{ #category : #accessing }
PhratchStringMorph >> fontToUse [
	| fontToUse |
	fontToUse := font isNil ifTrue: [TextStyle defaultFont] ifFalse: [font].
	(emphasis isNil or: [emphasis = 0]) 
		ifTrue: [^fontToUse]
		ifFalse: [^fontToUse emphasized: emphasis]
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> forceUnicodeRendering [

	^forceUnicodeRendering ifNil: [forceUnicodeRendering := false].
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> forceUnicodeRendering: anObject [
	forceUnicodeRendering := anObject
]

{ #category : #'t-rotating' }
PhratchStringMorph >> forwardDirection [
	"Return the receiver's forward direction (in eToy terms)"
	^self valueOfProperty: #forwardDirection ifAbsent:[0.0]
]

{ #category : #'t-rotating' }
PhratchStringMorph >> forwardDirection: newDirection [
	"Set the receiver's forward direction (in eToy terms)"
	self setProperty: #forwardDirection toValue: newDirection.
]

{ #category : #layout }
PhratchStringMorph >> fullBounds [
	self contents ifNil: [ self contents: 'String Morph' ].
	^super fullBounds
]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> handlesMouseDown: evt [
	"If the shift key is pressed then yes.
	As normal if StringMorph class>> editableStringMorph  returns false."
	
	^ (self isEditable: evt)
		ifTrue: [true]
		ifFalse: [super handlesMouseDown: evt]
]

{ #category : #'event handling' }
PhratchStringMorph >> hasFocus [
	^ hasFocus
]

{ #category : #accessing }
PhratchStringMorph >> hasTranslucentColor [

	^true
]

{ #category : #'t-rotating' }
PhratchStringMorph >> heading [
	"Return the receiver's heading"
	^ self owner 
		ifNil: [self forwardDirection]
		ifNotNil: [self forwardDirection + self owner degreesOfFlex]
]

{ #category : #drawing }
PhratchStringMorph >> imageForm: depth forRectangle: rect [
	| canvas |
	canvas := Display defaultCanvasClass extent: rect extent depth: depth.
	canvas form fillColor: Color white. 
	canvas translateBy: rect topLeft negated
		during:[:tempCanvas| tempCanvas fullDrawMorph: self].
	^ canvas form offset: rect topLeft
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> initFieldsFrom: anObjStream version: classVersion [

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
PhratchStringMorph >> initWithContents: aString font: aFont emphasis: emphasisCode [ 
	super initialize.
	
	font := aFont.
	emphasis := emphasisCode.
	hasFocus := false.
	self contents: aString
]

{ #category : #initialization }
PhratchStringMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.

	font := nil.
	emphasis := 0.
	hasFocus := false
]

{ #category : #accessing }
PhratchStringMorph >> interimContents: aString [
	"The receiver is under edit and aString represents the string the user sees as she edits, which typically will not have been accepted and indeed may be abandoned"

	self contents: aString
]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> isEditable: evt [
	"If the shift key is pressed then yes.
	As normal if StringMorph class>> editableStringMorph  returns false."
	
	^(self class editableStringMorph and: [evt shiftPressed and: [self wantsKeyboardFocusOnShiftClick]])

]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> justificationOffsetFor: aString [

	rightJustify ifNil: [rightJustify := false].
	rightJustify ifFalse: [^ 0].

	^ (self width - (self stringWidth: self stringToDisplay)) max: 0
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> kern [
	^ kern
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> kern: anObject [
	kern := anObject
]

{ #category : #editing }
PhratchStringMorph >> launchMiniEditor: evt [

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
PhratchStringMorph >> leftMargin [
	"Answer the left edge of this StringMorph. For a left-justified string, this the left edge of its bounding box, but for a right-justified string it may be inset."

	^ self left + (self justificationOffsetFor: contents)

]

{ #category : #drawing }
PhratchStringMorph >> lookTranslucent [

	"keep the text the same color (black)"
]

{ #category : #editing }
PhratchStringMorph >> lostFocusWithoutAccepting [
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus -- typically by clicking on some editable text somewhere else -- without having accepted the current edits."

	self acceptContents
]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> measureContents [
	"Round up in case fractional."
	
	| f |
	f := self fontToUse.
	^(((f widthOfString: contents) max: self minimumWidth)  @ f height) ceiling
]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> minHeight [
	"Answer the minimum height of the receiver."
	
	^self fontToUse height max: super minHeight
]

{ #category : #accessing }
PhratchStringMorph >> minimumWidth [
	"Answer the minimum width that the receiver can have.  A nonzero value here keeps the receiver from degenerating into something that cannot ever be seen or touched again!  Obeyed by fitContents."

	^ 3
]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> mouseDown: evt [
	"If the shift key is pressed, make this string the keyboard input focus.
	Process as normal if StringMorph class>> editableStringMorph  returns false."

	(self isEditable: evt)
		ifTrue: [self launchMiniEditor: evt]
		ifFalse: [super mouseDown: evt].

]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> paneColor [
	"Answer the window's pane color or our owner's color otherwise."

	^self paneColorOrNil ifNil: [self owner ifNil: [Color transparent] ifNotNil: [self owner color]]
]

{ #category : #'t-rotating' }
PhratchStringMorph >> prepareForRotating [
	"If I require a flex shell to rotate,
	then wrap it in one and return it.
	Polygons, eg, may override to do nothing."

	^ self addFlexShell
]

{ #category : #printing }
PhratchStringMorph >> printOn: aStream [

	super printOn: aStream.
	aStream print: contents.

]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> rightJustify: aBoolean [

	rightJustify = aBoolean ifFalse: [self changed].
	rightJustify := aBoolean.

]

{ #category : #'t-rotating' }
PhratchStringMorph >> rotationDegrees [
	"Default implementation."

	^ 0.0

]

{ #category : #'t-rotating' }
PhratchStringMorph >> rotationDegrees: degrees [	
	"redefined in all morphs which are using myself"
]

{ #category : #'t-rotating' }
PhratchStringMorph >> setDirectionFrom: aPoint [
	| delta degrees |
	delta := (self transformFromWorld globalPointToLocal: aPoint) - self referencePosition.
	degrees := delta degrees + 90.0.
	self forwardDirection: (degrees \\ 360) rounded.

]

{ #category : #'Polymorph-Widgets' }
PhratchStringMorph >> setWidth: width [
	"Round up in case fractional."
	
	self extent: (width @ (font ifNil: [TextStyle defaultFont]) height) ceiling
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> storeFieldsOn: anObjStream [

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
PhratchStringMorph >> stringExtent: aString [
	"Answer the extent of the given string in my current font."

	| s usingOSFont scanner |
	s := aString.
	usingOSFont := font notNil and: [font isOSFont].
	s isUnicode | self forceUnicodeRendering | usingOSFont ifTrue: [
		PhratchTranslator canRenderUnicode
			ifTrue: [^ PhratchTranslator stringExtent: s asMacRoman    font: self font]
			ifFalse: [s := s asMacRoman]].

	scanner := MultiDisplayScanner quickPrintOn: Display box: Display boundingBox font: self font.
	kern ifNotNil: [scanner addKern: kern].
	^ scanner stringExtent: s
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> stringHeight: aString [
	"Answer the height of the given string in my current font."

	^ (self stringExtent: aString) y

]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> stringToDisplay [
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
PhratchStringMorph >> stringWidth: aString [
	"Answer the width of the given string in my current font."

	^ font widthOfString: aString
"
	^ (self stringExtent: aString) x"
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> stringWithEllipses: aString limitedToWidth: aNumber [
	"Answer the given string limited in width. If the string is too wide to fit, truncate it and append ellipses."

	| ellipses maxW s w |
	ellipses := PhratchTranslator ellipsesSuffix "asUTF32".
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
PhratchStringMorph >> userString [
	"Do I have a text string to be searched on?"

	^ contents
]

{ #category : #accessing }
PhratchStringMorph >> valueFromContents [
	"Return a new value from the current contents string."
	^ contents
]

{ #category : #editing }
PhratchStringMorph >> wantsKeyboardFocusOnShiftClick [
	^ owner topRendererOrSelf wantsKeyboardFocusFor: self

]

{ #category : #'event handling' }
PhratchStringMorph >> wouldAcceptKeyboardFocus [
	^ self isLocked not
]

{ #category : #'NScratch-Extensions' }
PhratchStringMorph >> xRangesFor: s [
	"Anwer an array of (leftX, rightX) pairs for the given string. For Unicode, there will be an entry in the resulting array for each UTF character in the input string, even when characters combine, so the x ranges for characters may overlap."
	"StringMorph new xRangesFor: 'Hello' asUTF8"

	s isUnicode | self forceUnicodeRendering ifTrue: [
		PhratchTranslator canRenderUnicode
			ifTrue: [^ PhratchTranslator xRangesFor: s asMacRoman  font: self font]
			ifFalse: [^ self font xRangesFor: s asMacRoman]].

	^ self font xRangesFor: s

]
