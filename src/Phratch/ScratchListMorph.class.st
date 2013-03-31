"
A scrollable, ordered list of editable strings.

The following are top-level submorphs:
	titleMorph
	addItemMorph
	resizeMorph
	countMorph
	scrollPane

These morphs appear inside the scroll pane:
	emptyMorph -- added/removed to indicate when list is empty
	numberMorphs -- cell numbers (indices)
	cellMorphs -- list of cells

Each cell consists of a frame containing a line-wrapping string morph.


"
Class {
	#name : #ScratchListMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'titleMorph',
		'addItemMorph',
		'addSublistMorph',
		'countMorph',
		'resizeMorph',
		'scrollPane',
		'emptyMorph',
		'numberMorphs',
		'cellMorphs',
		'listName',
		'target',
		'resizeOffset',
		'focusIndex',
		'lastActivityIndex',
		'highlightActive',
		'lastActivityError',
		'listLayoutNeeded',
		'deleteMorph'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'instance creation' }
ScratchListMorph class >> deepCopyFrom: anArray [
	^self deepCopyFrom: anArray from: 1 to: anArray size


]

{ #category : #'instance creation' }
ScratchListMorph class >> deepCopyFrom: anArray from: start to: stop [

	| ans converter element |
	converter := ScriptableScratchMorph new.
	ans := self new.
	ans listName: '' target: nil.
	start to: stop do: [:i |
		element := converter asListElement: (anArray at: i).
		(element isKindOf: self)
			ifTrue: [element := self deepCopyFrom: (element asArray) from: 1 to: element lineCount].
		ans privateInsertLine: element at: (ans lineCount + 1)].
	ans updateCountMorph.
	ans updateContents.
	stop > 0 ifTrue: [
		ans noteChangeAtIndex: stop].
	^ ans
	

]

{ #category : #'instance creation' }
ScratchListMorph class >> on: anArray [
	^self on: anArray from: 1 to: anArray size


]

{ #category : #'instance creation' }
ScratchListMorph class >> on: anArray from: start to: stop [

	| ans converter |
	converter := ScriptableScratchMorph new.
	ans := self new.
	ans listName: '' target: nil.
	start to: stop do: [:i |
		ans privateInsertLine: (converter asListElement: (anArray at: i)) at: (ans lineCount + 1)].
	ans updateCountMorph.
	ans updateContents.
	stop > 0 ifTrue: [
		ans noteChangeAtIndex: stop].
	^ ans
	

]

{ #category : #'instance creation' }
ScratchListMorph class >> with: anObject [

	^ self new
		insertLine: (ScriptableScratchMorph new asListElement: anObject) at: 1
	

]

{ #category : #'byob lambdas' }
ScratchListMorph >> aboutToBeGrabbedBy: aHand [

	self listOwner
		ifNil: [^ self]
		ifNotNil: [^ nil]
]

{ #category : #'list ops' }
ScratchListMorph >> addLettersOf: anObject [

	anObject asString asUTF32 do: [:ch |
		cellMorphs addLast: (self createCell: (String with: ch) asUTF8)].

	self noteChangeAtIndex: cellMorphs size.

]

{ #category : #initialization }
ScratchListMorph >> addScrollPane [

	scrollPane := ScrollFrameMorph2 new
		vBarInset: 16;
		hBarInset: 18;
		color: Color transparent;
		growthFraction: 0.0;
		scrollbarStartInset: 2 endInset: -2;
		contents: (Morph new color: Color transparent).

	self addMorph: scrollPane.

]

{ #category : #initialization }
ScratchListMorph >> addTitleAndControls [

	titleMorph := ScratchStringMorph new contents: 'myList'; font: (ScratchFrameMorph getFont: #Label).
	deleteMorph := (ImageMorph new form: (ScratchFrameMorph skinAt: #deleteItem)).
	addItemMorph := (ImageMorph new form: (ScratchFrameMorph skinAt: #addItem)).
	addSublistMorph := (ImageMorph new form: self sublistIcon).
	resizeMorph := ScratchResizeMorph ofType: #corner.
	countMorph := ScratchStringMorph new
		contents: '0';
		font: (ScratchFrameMorph getFont: #XYReadout);
		color: (Color gray: 0.15).

	"emptyMorph is added to contents pane when list is empty"
	emptyMorph := ScratchStringMorph new
		contents: '(empty)' localized;
		font: (ScratchFrameMorph getFont: #CommentBlock).

	self addMorph: titleMorph.
	self addMorph: deleteMorph.
	self addMorph: addItemMorph.
	self addMorph: addSublistMorph.
	self addMorph: resizeMorph.
	self addMorph: countMorph.

]

{ #category : #'byob lambdas' }
ScratchListMorph >> asArray [

	| result |
	result := Array new: self lineCount.
	1 to: self lineCount do: [:i |
		result at: i put: (self lineAt: i)].
	^ result
]

{ #category : #'byob lambdas' }
ScratchListMorph >> asReferenceTuple [

	" answer an array describing the receiver in an abstract way
	format conventions:

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| stage rcvr ref |

	target isNil ifTrue: [
		stage := ScratchFrameMorph someInstance workPane.
		ref := stage referenceToList: self.
		ref ifNil: [^nil].
		^(Array with: #variableList), ref].

	stage := target ownerOrYourselfThatIsA: ScratchStageMorph.
	target == stage
		ifTrue: [rcvr := 'Stage']
		ifFalse: [rcvr := target objName].
	^ Array with: #namedList with: rcvr with: listName	

		
]

{ #category : #'list ops' }
ScratchListMorph >> clear [

	cellMorphs := cellMorphs species new: 1000.
	self updateContents.

]

{ #category : #'byob lambdas' }
ScratchListMorph >> complexContents: anArray [

	| obj |
	1 to: anArray size do: [:i |
		obj := anArray at: i.
		obj isNil ifFalse: [
			self setLineAt: i to: obj]].
	anArray isEmpty ifFalse: [ self noteChangeAtIndex: 1 ]
]

{ #category : #'list ops' }
ScratchListMorph >> concatenatedLines [

	| isSingleLetters s |
	isSingleLetters := true.
	cellMorphs do: [:m |
		isSingleLetters ifTrue: [
			m firstSubmorph contents asString asUTF32 size <= 1 ifFalse: [isSingleLetters := false]]].

	s := WriteStream on: (String new: 1000).
	isSingleLetters
		ifTrue: [
			cellMorphs do: [:m | s nextPutAll: m firstSubmorph contents asString]]
		ifFalse: [
			cellMorphs do: [:m | s nextPutAll: m firstSubmorph contents asString; space].
			s position > 0 ifTrue: [s skip: -1]].

	^ s contents

]

{ #category : #'list ops' }
ScratchListMorph >> contains: anObject [

	| s isComplex |
	isComplex := (anObject isKindOf: ScriptableScratchMorph) 
				| (anObject isKindOf: ScratchListMorph) 
				| (anObject isKindOf: CommandBlockMorph).

	isComplex ifTrue: [
		cellMorphs do: [:m |
			m complexObject = anObject ifTrue: [^ true]].
		^ false].

	s := anObject asString asUTF8.
	cellMorphs do: [:m |
		m complexObject = anObject ifTrue: [^ true ].
		s = m firstSubmorph contents ifTrue: [^ true]].

	^ false

]

{ #category : #'byob lambdas' }
ScratchListMorph >> containsRecursive: anObject [

	| s |
	s := anObject asString asUTF8.
	cellMorphs do: [:m |
		m complexObject notNil
			ifTrue: [
				m complexObject = anObject ifTrue: [^ true ].
				(m complexObject isKindOf: self class) ifTrue: [
					(m complexObject containsRecursive: anObject) ifTrue: [^true]]]
			ifFalse: [
				s = m firstSubmorph contents ifTrue: [^ true]]].

	^ false

]

{ #category : #'byob lambdas' }
ScratchListMorph >> convertBlockTuplesToStacksFor: aScriptableScratchMorph [

	"only for multi arg persistence"
	| obj block |

	cellMorphs do: [:m | obj := m complexObject.

		(obj isKindOf: Array) ifTrue: [

			#block = obj first ifTrue: [
				block := aScriptableScratchMorph stackFromTupleList: obj third receiver: aScriptableScratchMorph.
				m complexObject: block ]]].

	self updateContents
]

{ #category : #'byob lambdas' }
ScratchListMorph >> convertStacksToTuples [

	"format conventions:

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"


	| obj rcvr ref |

	cellMorphs do: [:m | obj := m complexObject.

		(obj isKindOf: BlockMorph) ifTrue: [
			(obj receiver isKindOf: ScriptableScratchMorph)
				ifTrue: [(obj receiver isKindOf: ScratchStageMorph)
					ifTrue: [rcvr := 'Stage']
					ifFalse: [rcvr := obj receiver objName]]
				ifFalse: [ rcvr := '' ].
			m complexObject: (Array with: #block with: rcvr with: obj tupleSequence) ].

		(obj isKindOf: self class) ifTrue: [ 
			ref := obj asReferenceTuple.
			ref isNil
				ifTrue: [ obj convertStacksToTuples]
				ifFalse: [ m complexObject: ref]].

		(obj isKindOf: ScriptableScratchMorph) ifTrue: [ 
			ref := obj asReferenceTuple.
			m complexObject: ref]].

]

{ #category : #'byob lambdas' }
ScratchListMorph >> convertTuplesToStacks [

	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj rcvr block stage |

	cellMorphs do: [:m | obj := m complexObject.

		(obj isKindOf: Array) ifTrue: [

			target isNil
				ifTrue: [ stage := ScratchFrameMorph someInstance workPane]
				ifFalse: [stage := target ownerOrYourselfThatIsA: ScratchStageMorph ].

			obj second = 'Stage'
				ifTrue: [rcvr := stage ]
				ifFalse: [rcvr := stage coerceSpriteArg: obj second ].

			#block = obj first ifTrue: [
				block := stage stackFromTupleList: obj third receiver: rcvr.
				m complexObject: block ].

			#namedList = obj first ifTrue: [
				m complexObject: (stage listNamed: obj third targetName: obj second)].

			#variableList = obj first ifTrue: [
				m complexObject: (stage listInVarNamed: obj third targetName: obj second)].

			#stage = obj first ifTrue: [
				m complexObject: stage].	

			#sprite = obj first ifTrue: [
				m complexObject: (stage coerceSpriteArg: obj second)]].

		(obj isKindOf: self class) ifTrue: [
			obj convertTuplesToStacks.
			m complexObject: obj]].

	self updateContents
]

{ #category : #'list ops' }
ScratchListMorph >> createCell: anObject [

	| readout cell font numberRight txt double |

	txt := anObject.
	(anObject isKindOf: String)
		ifFalse: [txt := anObject printString].

	font := ScratchFrameMorph getFont: #Watcher.
	readout := ListMultilineStringMorph new
		borderWidth: 0;
		color: Color transparent;
		textColor: Color white;
		growWithText: true;
		contents: txt font: font.
	readout height: ((ScratchTranslator stringExtent: 'A' font: font) y) + 6.
	ScratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].
	ScratchTranslator isRTL
		ifTrue: [readout width: self right - self left - self largestIndexWidth - 33]
		ifFalse: [readout width: self right - numberRight - 25].

	cell := WatcherReadoutFrameMorph new
		color: ScriptableScratchMorph listBlockColor;
		extent: readout extent + 3;
		addMorphBack: readout.

	(anObject isKindOf: String) ifFalse: [
		cell complexObject: anObject ].

	cell position: scrollPane contents bottomLeft.

	"avoid recursive lists"

	anObject = self ifFalse: [scrollPane contents addMorph: cell].

"
	double := scrollPane contents allMorphs detect: [:m | cell allMorphs includes: m] ifNone: [nil].
	double ifNil: [
		scrollPane contents addMorph: cell]
		ifNotNil: [].
"
	^ cell

]

{ #category : #'dropping/grabbing' }
ScratchListMorph >> delete [

	super delete.
	ScratchFrameMorph allInstancesDo: [:frame | frame deletingWatcher].

]

{ #category : #'list ops' }
ScratchListMorph >> deleteLineAt: aNumber [

	| index |

	index := aNumber asInteger.
	(index > 0 and: [index <= cellMorphs size]) ifFalse: [
		lastActivityError := true.
		^ self].

	index = numberMorphs size ifTrue: [
		numberMorphs last delete.
		numberMorphs := numberMorphs copyFrom: 1 to: numberMorphs size - 1].

	(cellMorphs removeAt: index) delete.
	self noteChangeAtIndex: index.
	owner ifNil: [self step].

]

{ #category : #'byob lambdas' }
ScratchListMorph >> equals: another [

	another class == self class ifFalse: [^ false].
	^ self asArray = another asArray
]

{ #category : #'import/export' }
ScratchListMorph >> exportList [

	| fName f |
	fName := titleMorph contents.
	fName size <= 1 ifTrue: [fName := 'newList'].
	fName := fName, '.txt'.

	fName := ScratchFileChooserDialog
		chooseNewFileDefault: fName
		title: 'File Name?'
		type: #list.
	fName = #cancelled ifTrue: [^ self].

	f := StandardFileStream newScratchFileNamed: fName.
	f ifNil: [^ self].
	cellMorphs do: [:m | f nextPutAll: m firstSubmorph contents; crlf].
	f close.

]

{ #category : #geometry }
ScratchListMorph >> extent: aPoint [

	super extent: (aPoint max: 95@115).
	self fixLayout.

]

{ #category : #'object i/o' }
ScratchListMorph >> fieldsVersion [

	^ 3

]

{ #category : #geometry }
ScratchListMorph >> fixLayout [

	titleMorph fitContents.
	(titleMorph width > (self width - 12)) ifTrue: [
		self width: titleMorph width + 12].

	titleMorph position: (self center x - (titleMorph width // 2)) @ (self top + 5).

	self listOwner 
		ifNil: [deleteMorph isHidden: true]
		ifNotNil: [
			deleteMorph position: (self right - deleteMorph width - 3) @ (self top + 3).
			deleteMorph isHidden: false; changed].

	countMorph fitContents.

	scrollPane
		position: (self left + 2) @ (titleMorph bottom + 3);
		extent: (self width - 4) @ (self bottom - titleMorph bottom - countMorph height - 12).

	addItemMorph position: (self left + 3) @ (self bottom - addItemMorph height - 3).
	addSublistMorph position: addItemMorph position + (addItemMorph width + 1 @ 0).

	resizeMorph position: (self bottomRight - resizeMorph extent).

	self updateCountMorph.
	countMorph bottom: self bottom - 3.

	self updateContents.

]

{ #category : #geometry }
ScratchListMorph >> fixLayoutForNewLanguage [
	"This method updates the height and word-wrapping of cells after a language or font change."

	| cellContents oldH |
	cellMorphs size = 0 ifTrue: [self fixLayout. ^ self showEmpty].
	cellContents := cellMorphs first firstSubmorph.
	oldH := cellContents height.
	(cellContents isKindOf: ScratchListMorph)
		ifFalse: [ cellContents font: cellContents font].
	cellContents height = oldH ifTrue: [self fixLayout. ^ self].  "no size change"

	scrollPane vScrollRelative: 0.
	cellMorphs do: [:c | c firstSubmorph font: c firstSubmorph font].
	self fixLayout.

]

{ #category : #accessing }
ScratchListMorph >> focusCell: cellMorph [

	focusIndex := cellMorphs indexOf: cellMorph ifAbsent: [1].
	World activeHand newKeyboardFocus: cellMorph firstSubmorph.

]

{ #category : #accessing }
ScratchListMorph >> focusIndex [

	^ focusIndex

]

{ #category : #accessing }
ScratchListMorph >> focusIndex: anInteger [

	| cell |
	focusIndex := anInteger.
	focusIndex > cellMorphs size ifTrue: [focusIndex := 1].
	focusIndex < 1 ifTrue: [focusIndex := cellMorphs size].

	cellMorphs size > 0 ifTrue: [
		cell := cellMorphs at: focusIndex.
		(cell complexObject isKindOf: Morph) ifFalse: [
			World activeHand newKeyboardFocus: cell firstSubmorph.
			scrollPane scrollSubmorphIntoView: cell]].

]

{ #category : #'byob lambdas' }
ScratchListMorph >> fullDrawOn: aCanvas [
	"private - ensure that I show the correct length"
	self updateCountMorph.
	super fullDrawOn: aCanvas
]

{ #category : #'event handling' }
ScratchListMorph >> handlesMouseDown: evt [

	^ self world notNil
]

{ #category : #'import/export' }
ScratchListMorph >> importList [

	| result |
	result := ScratchFileChooserDialog
		chooseExistingFileType: #list
		extensions: #(txt)
		title: 'Import List'.

	#cancelled = result ifTrue: [^ self].
	self importListFromFileNamed: result.

]

{ #category : #'import/export' }
ScratchListMorph >> importListFromFileNamed: aFilename [

	| f |
	f := FileStream readOnlyFileNamedOrNil: (( aFilename) fullName).
	f ifNil: [
		DialogBoxMorph inform: 'File not found' withDetails: aFilename.
		^ nil].

	"Assume the file was encoded as UTF8"
	[	self newContents:
			(f contentsOfEntireFile lines collect: [:s | String withAll: s]).
	] ifError: [Beeper beep].

]

{ #category : #private }
ScratchListMorph >> indexColor [

	^ Color gray: 0.32

]

{ #category : #'byob lambdas' }
ScratchListMorph >> indexOf: anObject [

	1 to: self lineCount do: [:i | 
		(self lineAt: i) = anObject ifTrue: [^ i]].
	^ -1
]

{ #category : #accessing }
ScratchListMorph >> indexOfCell: cellMorph [

	^ cellMorphs indexOf: cellMorph ifAbsent: [-1]

]

{ #category : #'object i/o' }
ScratchListMorph >> initFieldsFrom: anObjStream version: classVersion [
	"Note: To simplify my representation in the project file, my submorphs are removed before saving and restored when I am read in from an object file."

	| strings complex |
	super initFieldsFrom: anObjStream version: classVersion.

	listName := anObjStream nextField.
	strings := anObjStream nextField.
	classVersion > 1 ifTrue: [target := anObjStream nextField].
	classVersion > 2 ifTrue: [complex := anObjStream nextField].

	self removeAllMorphs.
	self addTitleAndControls; addScrollPane.
	titleMorph contents: listName.
	self newContents: strings.
	complex ifNotNil: [
		self complexContents: complex ].
	self fixLayout.
	self updateContents.

]

{ #category : #initialization }
ScratchListMorph >> initialize [

	super initialize.
	self
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderWidth: 2;
		borderColor: self normalBorderColor;
		useRoundedCorners.

	cellMorphs := OrderedCollection new: 1000.
	numberMorphs := #().
	listLayoutNeeded := true.
	focusIndex := 0.
	lastActivityError := false.
	highlightActive := false.

	self addTitleAndControls.
	self addScrollPane.

	self extent: 65@115.

]

{ #category : #'list ops' }
ScratchListMorph >> insertLine: aString at: aNumber [

	| index newCell |

"
	(aString isKindOf: self class) ifTrue: [
		(aString containsRecursive: self) ifTrue: [
			self error: 'attempting to create a recursive list']].
"

	index := aNumber asInteger.
	(index > 0 and: [index <= (cellMorphs size + 1)]) ifFalse: [
		lastActivityError := true.
		^ self].

	newCell := self createCell: aString.
	index = 1
		ifTrue: [cellMorphs addFirst: newCell]
		ifFalse: [
			index > cellMorphs size
				ifTrue: [cellMorphs addLast: newCell]
				ifFalse: [cellMorphs add: newCell afterIndex: index - 1]].

	self updateCountMorph.
	self noteChangeAtIndex: index.
	^ newCell

]

{ #category : #'byob lambdas' }
ScratchListMorph >> isMaxNestedAt: int [
	"kludge-alert!"

	int > VariableFrame maxNestingDepth
		ifTrue: [^ true].

	cellMorphs do: [:m |
		m complexObject ifNotNil: [
			(m complexObject respondsTo: #isMaxNestedAt:) ifTrue: [
				(m complexObject isMaxNestedAt: int + 1) 
					ifTrue:[^ true]]]].
	^ false

]

{ #category : #'dropping/grabbing' }
ScratchListMorph >> justDroppedInto: aMorph event: evt [

	(aMorph isKindOf: ScratchStageMorph) ifTrue: [
		super justDroppedInto: aMorph event: evt.
		self world ifNotNil: [self world startSteppingSubmorphsOf: self].
		^ self].

	"delete me if dropped anywhere but the stage"
	self position: (self formerPosition ifNil: [0@0]).
	^ self delete

]

{ #category : #private }
ScratchListMorph >> largestIndexWidth [
	"Estimate the width needed for the largest cell number."
	"Note: we estimate using the width of the the digit '0' times the number of digits needed."

	| digitWidth digitCount n |
	digitWidth := (ScratchFrameMorph getFont: #Label) widthOf: $0.
	n := cellMorphs size + 1 max: 100.
	digitCount := n log ceiling.
	^ digitCount * digitWidth


]

{ #category : #'list ops' }
ScratchListMorph >> lineAt: aNumber [

	| index cell |

	index := aNumber asInteger.
	(index > 0 and: [index <= cellMorphs size])
		ifTrue: [
			self isInWorld ifTrue: [
				self noteChangeForReadingAtIndex: index ].
			cell := (cellMorphs at: index).
			^cell complexObject ifNil: [
				cell firstSubmorph contents "asUTF8"]]
		ifFalse: [
			lastActivityError := true.
			^ ''].

]

{ #category : #'list ops' }
ScratchListMorph >> lineCount [

	^ cellMorphs size

]

{ #category : #accessing }
ScratchListMorph >> listContents [

	^ cellMorphs collect: [:m | m firstSubmorph contents].

]

{ #category : #accessing }
ScratchListMorph >> listName [

	^ listName

]

{ #category : #initialization }
ScratchListMorph >> listName: asString target: aScriptableSpriteMorph [

	listName := asString asUTF8.
	target := aScriptableSpriteMorph.
	self updateTitle.

]

{ #category : #'byob lambdas' }
ScratchListMorph >> listOwner [

	owner ifNil: [^ nil].
	^ owner ownerOrYourselfThatIsA: self class.

]

{ #category : #'event handling' }
ScratchListMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p listOwner newList |

	resizeOffset := nil.
	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		^ self delete].

	World activeHand showTemporaryCursor: nil.
	evt hand newKeyboardFocus: nil.
	p := evt cursorPoint.

	((addItemMorph bounds expandBy: 2) containsPoint: p) ifTrue: [
		^ self insertLine: '' at: (self lineCount + 1)].

	((addSublistMorph bounds expandBy: 2) containsPoint: p) ifTrue: [
		newList := ScratchListMorph new 
							listName: '' target: nil; 
							updateCountMorph; 
							startStepping;
							yourself.
		self insertLine: newList at: (self lineCount + 1).
		^ newList fixLayout].

	listOwner := self listOwner.
	(((deleteMorph bounds expandBy: 2) containsPoint: p) and: [listOwner notNil]) ifTrue: [
		^ listOwner deleteLineAt: (listOwner indexOf: self)].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			((resizeMorph bounds expandBy: 4) containsPoint: p)
				ifFalse: [evt hand grabMorph: self]
				ifTrue: [resizeOffset := self bottomRight - p]].

]

{ #category : #'event handling' }
ScratchListMorph >> mouseMove: evt [

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset].

]

{ #category : #private }
ScratchListMorph >> newContents: listOfStrings [
	"Set my contents to the given collection of strings."

	scrollPane contents
		removeAllMorphs;
		top: scrollPane top;
		extent: scrollPane extent.

	cellMorphs := cellMorphs species new: ((2 * listOfStrings size) max: 1000).
	numberMorphs := #().

	listOfStrings do: [:s | cellMorphs addLast: (self createCell: s)].
	self updateContents.

]

{ #category : #private }
ScratchListMorph >> normalBorderColor [

	^ Color r: (148/255) g: (145/255) b: (145/255)

]

{ #category : #private }
ScratchListMorph >> noteChangeAtIndex: index [

	lastActivityIndex := index.	

	cellMorphs size < 20
		ifTrue: [
			self updateContents.
			(index between: 1 and: numberMorphs size) ifTrue: [
				(numberMorphs at: index) color: (Color white).
				highlightActive := true].
			lastActivityIndex := nil]
		ifFalse: [
			listLayoutNeeded := true].

]

{ #category : #'-- all --' }
ScratchListMorph >> noteChangeForReadingAtIndex: index [

	lastActivityIndex := index.	

	cellMorphs size < 20
		ifTrue: [
			self updateContentsForReading.
			(index between: 1 and: numberMorphs size) ifTrue: [
				(numberMorphs at: index) color: (Color white).
				highlightActive := true].
			lastActivityIndex := nil]
		ifFalse: [
			listLayoutNeeded := true].

]

{ #category : #'byob lambdas' }
ScratchListMorph >> privateInsertLine: aString at: aNumber [

	| index newCell |
	index := aNumber asInteger.
	(index > 0 and: [index <= (cellMorphs size + 1)]) ifFalse: [
		lastActivityError := true.
		^ self].

	newCell := self createCell: aString.
	index = 1
		ifTrue: [cellMorphs addFirst: newCell]
		ifFalse: [
			index > cellMorphs size
				ifTrue: [cellMorphs addLast: newCell]
				ifFalse: [cellMorphs add: newCell afterIndex: index - 1]].
	^ newCell

]

{ #category : #'byob lambdas' }
ScratchListMorph >> references: anObject [

	cellMorphs do: [:m |
		m complexObject ifNotNil: [
			m complexObject == anObject ifTrue: [^ true ].
			(m complexObject respondsTo: #references:) ifTrue: [
				(m complexObject references: anObject) ifTrue: [^true]]]].
	^ false

]

{ #category : #'event handling' }
ScratchListMorph >> rightButtonMenu [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'export' action: #exportList.
	menu add: 'import' action: #importList.
	menu addLine.
	menu add: 'hide' action: #delete.

	menu localize.
	menu labels at: 2 put: 
		((menu labels at: 2) contents copyFrom: 1 to: (menu labels at: 2) contents size - 1), ScratchTranslator ellipsesSuffix.
	menu popUpInWorld.
]

{ #category : #private }
ScratchListMorph >> scrollActiveCellIntoView [

	| cell page newTop |
	lastActivityIndex := lastActivityIndex within: 1 and: cellMorphs size.
	cell := cellMorphs at: lastActivityIndex.
	page := scrollPane contents.
	(scrollPane bounds containsRect: cell bounds) ifFalse: [
		newTop := (scrollPane bounds center y) - (cell top - page top).
		newTop := newTop max: (scrollPane bottom - (cellMorphs last bottom - page top) - 3).
		newTop := newTop min: scrollPane top.
		page top: newTop].

]

{ #category : #'list ops' }
ScratchListMorph >> setLineAt: aNumber to: newContents [

	| index cell obj |

	(newContents isKindOf: self class) ifTrue: [
		(newContents containsRecursive: self) ifTrue: [
			self error: 'attempting to create a recursive list']].

	index := aNumber asInteger.
	(index > 0 and: [index <= cellMorphs size]) ifFalse: [
		lastActivityError := true.
		^ self].

	(newContents isKindOf: self class)
	| (newContents isKindOf: Morph)
	| (newContents isKindOf: Array)
	| (newContents isKindOf: Boolean)

		ifTrue: [obj := newContents]
		ifFalse: [ obj := newContents asString ].
	
	cell := cellMorphs at: index.

	(cell complexObject respondsTo: #delete)
		ifTrue: [cell complexObject delete].

	(obj isKindOf: String)
		ifTrue: [ 
			cell complexObject: nil.
			cell firstSubmorph contents: obj ]
		ifFalse: [
			cell firstSubmorph contents: ''.
			cell complexObject: obj ].

	cell changed.
	self noteChangeAtIndex: index


]

{ #category : #private }
ScratchListMorph >> showEmpty [
	"Show the empty label."

	| page |
	scrollPane hScrollRelative: 0; vScrollRelative: 0.
	page := scrollPane contents
		removeAllMorphs;
		extent: scrollPane extent.

	numberMorphs size > 0 ifTrue: [numberMorphs := #()].

	emptyMorph
		contents: '(empty)' localized;
		position: (page center - (emptyMorph extent // 2)).
	page addMorph: emptyMorph.

	scrollPane updateScrollbars.
	listLayoutNeeded := false.


]

{ #category : #stepping }
ScratchListMorph >> step [

	self updateTitle.
	self updateBorder.
	self updateCountMorph.
	self updateIndexHighlight.
	listLayoutNeeded ifTrue: [self updateContents].

]

{ #category : #stepping }
ScratchListMorph >> stepTime [

	^ 200

]

{ #category : #'object i/o' }
ScratchListMorph >> storeFieldsOn: anObjStream [
	"Note: To simplify my representation in the project file, my submorphs are removed before saving and restored when I am read in from an object file."

	| strings complex |

	"self purge.	"

	strings := cellMorphs asArray collect: [:m | m firstSubmorph contents asString].
	complex := cellMorphs asArray collect: [:m | m complexObject].

	self removeAllMorphs.
	numberMorphs := #().

	super storeFieldsOn: anObjStream.
	anObjStream putField: listName.
	anObjStream putField: strings.
	anObjStream putField: target.
	anObjStream putField: complex.

	self addTitleAndControls; addScrollPane.
	titleMorph contents: listName.
	self newContents: strings.
	self complexContents: complex.
	self fixLayout.


]

{ #category : #'byob lambdas' }
ScratchListMorph >> sublistIcon [

	| block slot form halfList big |
	block := ReporterBlockMorph new color: (ScriptableScratchMorph blockColorFor: 'list'); commandSpec: '%s'.
	slot := block argMorphs first.
	slot extent: 7 @ 4.
	form := slot imageForm.
	form replaceColor: (form colorAt: 2@2) withColor: (ScriptableScratchMorph blockColorFor: 'list').
	halfList := slot extent + 1.
	big := Form extent: halfList x @ (halfList y * 2) depth: 8.
	(WarpBlt toForm: big)
		sourceForm: form;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: form boundingBox corners toRect: form boundingBox.
	(WarpBlt toForm: big)
		sourceForm: form;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: form boundingBox corners toRect: (form boundingBox translateBy: 0@(halfList y)).
	^((big withOutlineColor: Color gray muchLighter width: 2) "withOutlineColor: Color darkGray width: 1").

]

{ #category : #accessing }
ScratchListMorph >> target [

	^ target

]

{ #category : #stepping }
ScratchListMorph >> updateBorder [

	lastActivityError
		ifTrue: [self borderColor: Color red]
		ifFalse: [self borderColor: self normalBorderColor].
	lastActivityError := false.

]

{ #category : #'list ops' }
ScratchListMorph >> updateContents [
	"Update and layout my contents."

	| page numberRight cellWidth inset x y listOwner |

	listOwner := self listOwner.
	listOwner ifNotNil: [
"		listOwner noteChangeAtIndex: (listOwner indexOf: self)]."
		listOwner updateContentsRecursive].

	cellMorphs size = 0 ifTrue: [^ self showEmpty].

	emptyMorph delete.

	page := scrollPane contents.
	page changed.

	ScratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	ScratchTranslator isRTL
		ifTrue: [cellWidth := self right - self left - self largestIndexWidth - 33]
		ifFalse: [cellWidth := self right - numberRight - 25].
	inset := 3.
	cellMorphs do: [:cell |

		(cell complexObject isKindOf: Morph)
			ifTrue: [ (cell complexObject respondsTo: #displayForm)
				ifTrue: [cell extent: cell complexObject displayForm extent +(10@10)]
				ifFalse: [(cell complexObject respondsTo: #thumbnailImageForm)
					ifTrue: [cell extent: cell complexObject thumbnailImageForm extent + (10@10)]
					ifFalse: [cell extent: cell complexObject fullBounds extent +(10@10)]]]
			ifFalse: [
				((cell width ~= cellWidth) or: [cell extent ~= (cell firstSubmorph extent + inset)]) ifTrue: [
				cell firstSubmorph width: cellWidth - inset.
				cell extent: cell firstSubmorph extent + inset]]].

	"position cells"
	ScratchTranslator isRTL
		ifTrue: [x := self left + 26]
		ifFalse: [x := numberRight + 4].
	y := page top + 3.
	cellMorphs do: [:cell |
		cell position: x@y.
		y := y + cell height - 1].

	self updateIndices: numberRight.

	page extent: (self width - (2 * borderWidth)) @ (y + 3).

	lastActivityIndex ifNotNil: [
 		(lastActivityIndex between: 1 and: cellMorphs size) ifTrue: [
			(numberMorphs at: lastActivityIndex) color: (Color white).
			highlightActive := true].
		self scrollActiveCellIntoView.
		lastActivityIndex := nil].
	scrollPane updateScrollbars.
	scrollPane updateScrollbars.

	listLayoutNeeded := false.

]

{ #category : #'list ops' }
ScratchListMorph >> updateContentsForReading [
	"Update and layout my contents."

	| page numberRight cellWidth inset x y listOwner |

	listOwner := self listOwner.
	listOwner ifNotNil: [
		listOwner noteChangeAtIndex: (listOwner indexOf: self)].
"		listOwner updateContentsRecursive]."

	cellMorphs size = 0 ifTrue: [^ self showEmpty].

	emptyMorph delete.

	page := scrollPane contents.
	page changed.

	ScratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	ScratchTranslator isRTL
		ifTrue: [cellWidth := self right - self left - self largestIndexWidth - 33]
		ifFalse: [cellWidth := self right - numberRight - 25].
	inset := 3.
	cellMorphs do: [:cell |

		(cell complexObject isKindOf: Morph)
			ifTrue: [ (cell complexObject respondsTo: #displayForm)
				ifTrue: [cell extent: cell complexObject displayForm extent +(10@10)]
				ifFalse: [cell extent: cell complexObject fullBounds extent +(10@10)]]
			ifFalse: [
				((cell width ~= cellWidth) or: [cell extent ~= (cell firstSubmorph extent + inset)]) ifTrue: [
				cell firstSubmorph width: cellWidth - inset.
				cell extent: cell firstSubmorph extent + inset]]].

	"position cells"
	ScratchTranslator isRTL
		ifTrue: [x := self left + 26]
		ifFalse: [x := numberRight + 4].
	y := page top + 3.
	cellMorphs do: [:cell |
		cell position: x@y.
		y := y + cell height - 1].

	self updateIndices: numberRight.

	page extent: (self width - (2 * borderWidth)) @ (y + 3).

	lastActivityIndex ifNotNil: [
 		(lastActivityIndex between: 1 and: cellMorphs size) ifTrue: [
			(numberMorphs at: lastActivityIndex) color: (Color white).
			highlightActive := true].
		self scrollActiveCellIntoView.
		lastActivityIndex := nil].
	scrollPane updateScrollbars.
	scrollPane updateScrollbars.

	listLayoutNeeded := false.

]

{ #category : #private }
ScratchListMorph >> updateContentsRecursive [
	"Update and layout my contents and those of my children."

	| page numberRight cellWidth inset x y |

	cellMorphs size = 0 ifTrue: [^ self showEmpty].
	emptyMorph delete.

	page := scrollPane contents.
	page changed.

	ScratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	ScratchTranslator isRTL
		ifTrue: [cellWidth := self right - self left - self largestIndexWidth - 33]
		ifFalse: [cellWidth := self right - numberRight - 25].
	inset := 3.
	cellMorphs do: [:cell |

		(cell complexObject isKindOf: Morph)
			ifTrue: [ 
				(cell complexObject respondsTo: #displayForm)
					ifTrue: [cell extent: cell complexObject displayForm extent +(10@10)]
					ifFalse: [cell extent: cell complexObject fullBounds extent +(10@10)].
				(cell complexObject isKindOf: self class)
					ifTrue: [cell complexObject updateContentsRecursive]]
			ifFalse: [
				((cell width ~= cellWidth) or: [cell extent ~= (cell firstSubmorph extent + inset)]) ifTrue: [
				cell firstSubmorph width: cellWidth - inset.
				cell extent: cell firstSubmorph extent + inset]]].

	"position cells"
	ScratchTranslator isRTL
		ifTrue: [x := self left + 26]
		ifFalse: [x := numberRight + 4].
	y := page top + 3.
	cellMorphs do: [:cell |
		cell position: x@y.
		y := y + cell height - 1].

	self updateIndices: numberRight.

	page extent: (self width - (2 * borderWidth)) @ (y + 3).

	lastActivityIndex ifNotNil: [
 		(lastActivityIndex between: 1 and: cellMorphs size) ifTrue: [
			(numberMorphs at: lastActivityIndex) color: (Color white).
			highlightActive := true].
		self scrollActiveCellIntoView.
		lastActivityIndex := nil].
	scrollPane updateScrollbars.
	scrollPane updateScrollbars.

	listLayoutNeeded := false.

]

{ #category : #stepping }
ScratchListMorph >> updateCountMorph [

	countMorph contents: 'length' localized, ScratchTranslator colonSuffix, ' ', self lineCount printString.
	countMorph left: ((self left + ((self width - countMorph width) // 2) + 3) max: (addSublistMorph right + 1))

]

{ #category : #stepping }
ScratchListMorph >> updateIndexHighlight [
	"Update the highlighted index."

	highlightActive ifTrue: [
		numberMorphs do: [:m | m color: self indexColor].
		highlightActive := false].

]

{ #category : #private }
ScratchListMorph >> updateIndices: rightX [

	| s newNumbers page num cell |
	numberMorphs size > cellMorphs size ifTrue: [
		cellMorphs size + 1 to: numberMorphs size do: [:i | (numberMorphs at: i) delete].
		numberMorphs := numberMorphs copyFrom: 1 to: cellMorphs size].

	newNumbers := #().
	numberMorphs size < cellMorphs size ifTrue: [
		page := scrollPane contents.
		s := ScratchStringMorph new
			color: self indexColor;
			font: (ScratchFrameMorph getFont: #Label).
		newNumbers := (numberMorphs size + 1 to: cellMorphs size)
			collect: [:i | s fullCopy contents: i printString].
		newNumbers do: [:m | page addMorph: m].
		numberMorphs := numberMorphs, newNumbers].

	1 to: cellMorphs size do: [:i |
		num := numberMorphs at: i.
		cell := cellMorphs at: i.
		num position: (rightX - num width) @ (cell top + ((cell height - num height) // 2))].


]

{ #category : #stepping }
ScratchListMorph >> updateTitle [
	"Update my title if I am owned by a sprite and the sprite name changes."

	| s |
	listName ifNil: [^ self].

	(target isKindOf: ScratchSpriteMorph)
		ifTrue: [s := target objName, ' ', listName]
		ifFalse: [s := listName].

	titleMorph contents = s ifFalse: [
		titleMorph contents: s.
		self fixLayout].

]
