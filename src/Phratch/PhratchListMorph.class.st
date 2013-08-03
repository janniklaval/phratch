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
	#name : #PhratchListMorph,
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
		'deleteMorph',
		'list',
		'lastUpdated',
		'isUpdating'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'instance creation' }
PhratchListMorph class >> deepCopyFrom: anArray [
	^self deepCopyFrom: anArray from: 1 to: anArray size


]

{ #category : #'instance creation' }
PhratchListMorph class >> deepCopyFrom: anArray from: start to: stop [

	| ans converter element |
	converter := ScriptablePhratchMorph new.
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
PhratchListMorph class >> on: aBYOBList [

	^ self new list: aBYOBList
]

{ #category : #'instance creation' }
PhratchListMorph class >> on: anArray from: start to: stop [

	| ans converter |
	converter := ScriptablePhratchMorph new.
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
PhratchListMorph class >> with: anObject [

	^ self new
		insertLine: (ScriptablePhratchMorph new asListElement: anObject) at: 1
	

]

{ #category : #'as yet unclassified' }
PhratchListMorph >> = another [

	^ self == another
]

{ #category : #'byob lambdas' }
PhratchListMorph >> aboutToBeGrabbedBy: aHand [

	self listOwner
		ifNil: [^ self]
		ifNotNil: [^ nil]
]

{ #category : #'list ops' }
PhratchListMorph >> addLettersOf: anObject [

	anObject asString do: [:ch |
		cellMorphs addLast: (self createCell: (String with: ch))].

	self noteChangeAtIndex: cellMorphs size.

]

{ #category : #initialization }
PhratchListMorph >> addScrollPane [

	scrollPane := ScrollFrameMorph new
		vBarInset: 16;
		hBarInset: 18;
		color: Color transparent;
		growthFraction: 0.0;
		scrollbarStartInset: 2 endInset: -2;
		contents: (Morph new color: Color transparent).

	self addMorph: scrollPane.

]

{ #category : #initialization }
PhratchListMorph >> addTitleAndControls [

	titleMorph := StringMorph new contents: 'myList'; font: (PhratchFrameMorph getFont: #Label).
	deleteMorph := (ImageMorph new form: (PhratchFrameMorph skinAt: #deleteItem)).
	addItemMorph := (ImageMorph new form: (PhratchFrameMorph skinAt: #addItem)).
	addSublistMorph := (ImageMorph new form: self sublistIcon).
	resizeMorph := PhratchResizeMorph ofType: #corner.
	countMorph := StringMorph new
		contents: '0';
		font: (PhratchFrameMorph getFont: #XYReadout);
		color: (Color gray: 0.15).

	"emptyMorph is added to contents pane when list is empty"
	emptyMorph := StringMorph new
		contents: '(empty)' localized;
		font: (PhratchFrameMorph getFont: #CommentBlock).

	self addMorph: titleMorph.
	self addMorph: deleteMorph.
	self addMorph: addItemMorph.
	self addMorph: addSublistMorph.
	self addMorph: resizeMorph.
	self addMorph: countMorph.

]

{ #category : #'byob lambdas' }
PhratchListMorph >> asArray [

	| result |
	result := Array new: self lineCount.
	1 to: self lineCount do: [:i |
		result at: i put: (self lineAt: i)].
	^ result
]

{ #category : #'byob lambdas' }
PhratchListMorph >> asReferenceTuple [

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
		stage := PhratchFrameMorph someInstance workPane.
		ref := stage referenceToList: self.
		ref ifNil: [^nil].
		^(Array with: #variableList), ref].

	stage := target ownerOrYourselfThatIsA: PhratchStageMorph.
	target == stage
		ifTrue: [rcvr := 'Stage']
		ifFalse: [rcvr := target objName].
	^ Array with: #namedList with: rcvr with: listName	

		
]

{ #category : #'list ops' }
PhratchListMorph >> clear [

	cellMorphs := cellMorphs species new: 1000.
	self updateContents.

]

{ #category : #'byob lambdas' }
PhratchListMorph >> complexContents: anArray [

	| obj |
	1 to: anArray size do: [:i |
		obj := anArray at: i.
		obj isNil ifFalse: [
			self setLineAt: i to: obj]].
	anArray isEmpty ifFalse: [ self noteChangeAtIndex: 1 ]
]

{ #category : #'list ops' }
PhratchListMorph >> concatenatedLines [

	| isSingleLetters s |
	isSingleLetters := true.
	cellMorphs do: [:m |
		isSingleLetters ifTrue: [
			m firstSubmorph contents asString size <= 1 ifFalse: [isSingleLetters := false]]].

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
PhratchListMorph >> contains: anObject [

	| s isComplex |
	isComplex := (anObject isKindOf: ScriptablePhratchMorph) 
				| (anObject isKindOf: PhratchListMorph) 
				| (anObject isKindOf: CommandBlockMorph).

	isComplex ifTrue: [
		cellMorphs do: [:m |
			m complexObject = anObject ifTrue: [^ true]].
		^ false].

	s := anObject asString.
	cellMorphs do: [:m |
		m complexObject = anObject ifTrue: [^ true ].
		s = m firstSubmorph contents ifTrue: [^ true]].

	^ false

]

{ #category : #'byob lambdas' }
PhratchListMorph >> containsRecursive: anObject [

	| s |
	s := anObject asString.
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
PhratchListMorph >> convertBlockTuplesToStacksFor: aScriptablePhratchMorph [

	"only for multi arg persistence"
	| obj block |

	cellMorphs do: [:m | obj := m complexObject.

		(obj isKindOf: Array) ifTrue: [

			#block = obj first ifTrue: [
				block := aScriptablePhratchMorph stackFromTupleList: obj third receiver: aScriptablePhratchMorph.
				m complexObject: block ]]].

	self updateContents
]

{ #category : #'byob lambdas' }
PhratchListMorph >> convertStacksToTuples [

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
			(obj receiver isKindOf: ScriptablePhratchMorph)
				ifTrue: [(obj receiver isKindOf: PhratchStageMorph)
					ifTrue: [rcvr := 'Stage']
					ifFalse: [rcvr := obj receiver objName]]
				ifFalse: [ rcvr := '' ].
			m complexObject: (Array with: #block with: rcvr with: obj tupleSequence) ].

		(obj isKindOf: self class) ifTrue: [ 
			ref := obj asReferenceTuple.
			ref isNil
				ifTrue: [ obj convertStacksToTuples]
				ifFalse: [ m complexObject: ref]].

		(obj isKindOf: ScriptablePhratchMorph) ifTrue: [ 
			ref := obj asReferenceTuple.
			m complexObject: ref]].

]

{ #category : #'byob lambdas' }
PhratchListMorph >> convertTuplesToStacks [

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
				ifTrue: [ stage := PhratchFrameMorph someInstance workPane]
				ifFalse: [stage := target ownerOrYourselfThatIsA: PhratchStageMorph ].

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
PhratchListMorph >> createCell: anObject [

	| readout cell font numberRight txt |

	txt := anObject.
	(anObject isKindOf: String)
		ifFalse: [txt := anObject printString].

	font := PhratchFrameMorph getFont: #Watcher.
	readout := ListMultilineStringMorph new
		borderWidth: 0;
		color: Color transparent;
		textColor: Color white;
		growWithText: true;
		contents: txt font: font.
	readout height: ((PhratchTranslator stringExtent: 'A' font: font) y) + 6.
	PhratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].
	PhratchTranslator isRTL
		ifTrue: [readout width: self right - self left - self largestIndexWidth - 33]
		ifFalse: [readout width: self right - numberRight - 25].

	cell := WatcherReadoutFrameMorph new
		color: ScriptablePhratchMorph listBlockColor;
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
PhratchListMorph >> delete [

	super delete.
	PhratchFrameMorph allInstancesDo: [:frame | frame deletingWatcher].

]

{ #category : #'list ops' }
PhratchListMorph >> deleteLineAt: aNumber [

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

	list deleteLineAt: aNumber.
	lastUpdated := list lastChanged
]

{ #category : #'byob lambdas' }
PhratchListMorph >> equals: another [

	another class == self class ifFalse: [^ false].
	^ self asArray = another asArray
]

{ #category : #'import/export' }
PhratchListMorph >> exportList [

	| fName f |
	fName := titleMorph contents.
	fName size <= 1 ifTrue: [fName := 'newList'].
	fName := fName, '.txt'.

	fName := PhratchFileChooserDialog
		chooseNewFileDefault: fName
		title: 'File Name?'
		type: #list.
	fName = #cancelled ifTrue: [^ self].

	f := StandardFileStream newPhratchFileNamed: fName.
	f ifNil: [^ self].
	cellMorphs do: [:m | f nextPutAll: m firstSubmorph contents; crlf].
	f close.

]

{ #category : #geometry }
PhratchListMorph >> extent: aPoint [

	super extent: (aPoint max: 95@115).
	self fixLayout.

]

{ #category : #'object i/o' }
PhratchListMorph >> fieldsVersion [

	^ 3

]

{ #category : #geometry }
PhratchListMorph >> fixLayout [

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
PhratchListMorph >> fixLayoutForNewLanguage [
	"This method updates the height and word-wrapping of cells after a language or font change."

	| cellContents oldH |
	cellMorphs size = 0 ifTrue: [self fixLayout. ^ self showEmpty].
	cellContents := cellMorphs first firstSubmorph.
	oldH := cellContents height.
	(cellContents isKindOf: PhratchListMorph)
		ifFalse: [ cellContents font: cellContents font].
	cellContents height = oldH ifTrue: [self fixLayout. ^ self].  "no size change"

	scrollPane vScrollRelative: 0.
	cellMorphs do: [:c | c firstSubmorph font: c firstSubmorph font].
	self fixLayout.

]

{ #category : #accessing }
PhratchListMorph >> focusCell: cellMorph [

	focusIndex := cellMorphs indexOf: cellMorph ifAbsent: [1].
	World activeHand newKeyboardFocus: cellMorph firstSubmorph.
	lastUpdated := list lastChanged.
]

{ #category : #accessing }
PhratchListMorph >> focusIndex [

	^ focusIndex

]

{ #category : #accessing }
PhratchListMorph >> focusIndex: anInteger [

	| cell |
	focusIndex := anInteger.
	focusIndex > cellMorphs size ifTrue: [focusIndex := 1].
	focusIndex < 1 ifTrue: [focusIndex := cellMorphs size].

	cellMorphs size > 0 ifTrue: [
		cell := cellMorphs at: focusIndex.
		(cell complexObject isKindOf: Morph) ifFalse: [
			World activeHand newKeyboardFocus: cell firstSubmorph.
			scrollPane scrollSubmorphIntoView: cell]].
	lastUpdated := list lastChanged.
	lastActivityIndex := anInteger
]

{ #category : #'byob lambdas' }
PhratchListMorph >> fullDrawOn: aCanvas [
	"private - ensure that I show the correct length"
	self updateCountMorph.
	super fullDrawOn: aCanvas
]

{ #category : #'event handling' }
PhratchListMorph >> handlesMouseDown: evt [

	^ self world notNil
]

{ #category : #'import/export' }
PhratchListMorph >> importList [

	| result |
	result := PhratchFileChooserDialog
		chooseExistingFileType: #list
		extensions: #(txt)
		title: 'Import List'.

	#cancelled = result ifTrue: [^ self].
	self importListFromFileNamed: result.

]

{ #category : #'import/export' }
PhratchListMorph >> importListFromFileNamed: aFilename [

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
PhratchListMorph >> indexColor [

	^ Color gray: 0.32

]

{ #category : #'byob lambdas' }
PhratchListMorph >> indexOf: anObject [

	1 to: self lineCount do: [:i | 
		(self lineAt: i) = anObject ifTrue: [^ i]].
	^ -1
]

{ #category : #accessing }
PhratchListMorph >> indexOfCell: cellMorph [

	^ cellMorphs indexOf: cellMorph ifAbsent: [-1]

]

{ #category : #'object i/o' }
PhratchListMorph >> initFieldsFrom: anObjStream version: classVersion [
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
PhratchListMorph >> initialize [

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
	list := BYOBList new.
	lastUpdated := list lastChanged.
	isUpdating := false
]

{ #category : #'list ops' }
PhratchListMorph >> insertLine: aString at: aNumber [

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
	list insertLine: aString at: aNumber.
	lastUpdated := list lastChanged.
	^ newCell

]

{ #category : #'byob lambdas' }
PhratchListMorph >> isMaxNestedAt: int [
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
PhratchListMorph >> justDroppedInto: aMorph event: evt [

	(aMorph isKindOf: PhratchStageMorph) ifTrue: [
		super justDroppedInto: aMorph event: evt.
		self world ifNotNil: [self world startSteppingSubmorphsOf: self].
		^ self].

	"delete me if dropped anywhere but the stage"
	self position: (self formerPosition ifNil: [0@0]).
	^ self delete

]

{ #category : #private }
PhratchListMorph >> largestIndexWidth [
	"Estimate the width needed for the largest cell number."
	"Note: we estimate using the width of the the digit '0' times the number of digits needed."

	| digitWidth digitCount n |
	digitWidth := (PhratchFrameMorph getFont: #Label) widthOf: $0.
	n := cellMorphs size + 1 max: 100.
	digitCount := n log ceiling.
	^ digitCount * digitWidth


]

{ #category : #'list ops' }
PhratchListMorph >> lineAt: aNumber [

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
PhratchListMorph >> lineCount [

	^ cellMorphs size

]

{ #category : #'dropping/grabbing' }
PhratchListMorph >> list [
	^ list
]

{ #category : #'dropping/grabbing' }
PhratchListMorph >> list: aBYOBList [

	list := aBYOBList.
	self update

]

{ #category : #accessing }
PhratchListMorph >> listContents [

	^ cellMorphs collect: [:m | m firstSubmorph contents].

]

{ #category : #accessing }
PhratchListMorph >> listName [

	^ listName

]

{ #category : #initialization }
PhratchListMorph >> listName: asString target: aScriptableSpriteMorph [

	listName := asString.
	target := aScriptableSpriteMorph.
	self updateTitle.

]

{ #category : #'byob lambdas' }
PhratchListMorph >> listOwner [

	owner ifNil: [^ nil].
	^ owner ownerOrYourselfThatIsA: self class.

]

{ #category : #'event handling' }
PhratchListMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p listOwner |

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
		^ list insertLine: BYOBList new at: (self lineCount + 1)].

	listOwner := self listOwner.
	(((deleteMorph bounds expandBy: 2) containsPoint: p) and: [listOwner notNil]) ifTrue: [
		^ listOwner deleteLineAt: (listOwner indexOf: self list)].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			((resizeMorph bounds expandBy: 4) containsPoint: p)
				ifFalse: [evt hand grabMorph: self]
				ifTrue: [resizeOffset := self bottomRight - p]].

]

{ #category : #'event handling' }
PhratchListMorph >> mouseMove: evt [

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset].

]

{ #category : #private }
PhratchListMorph >> newContents: listOfStrings [
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
PhratchListMorph >> normalBorderColor [

	^ Color r: (148/255) g: (145/255) b: (145/255)

]

{ #category : #private }
PhratchListMorph >> noteChangeAtIndex: index [

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
PhratchListMorph >> noteChangeForReadingAtIndex: index [

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
PhratchListMorph >> privateInsertLine: aString at: aNumber [

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
			
	self updateCountMorph.

	self updateContents.
	^ newCell

]

{ #category : #'byob lambdas' }
PhratchListMorph >> references: anObject [

	cellMorphs do: [:m |
		m complexObject ifNotNil: [
			m complexObject == anObject ifTrue: [^ true ].
			(m complexObject respondsTo: #references:) ifTrue: [
				(m complexObject references: anObject) ifTrue: [^true]]]].
	^ false

]

{ #category : #'event handling' }
PhratchListMorph >> rightButtonMenu [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'export' action: #exportList.
	menu add: 'import' action: #importList.
	menu addLine.
	menu add: 'hide' action: #delete.

	menu localize.
	menu labels at: 2 put: 
		((menu labels at: 2) contents copyFrom: 1 to: (menu labels at: 2) contents size - 1), PhratchTranslator ellipsesSuffix.
	menu invokeModal.
]

{ #category : #private }
PhratchListMorph >> scrollActiveCellIntoView [

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
PhratchListMorph >> setLineAt: aNumber to: newContents [

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
	self noteChangeAtIndex: index.
	list setLineAt: aNumber to: newContents.
	lastUpdated := list lastChanged


]

{ #category : #private }
PhratchListMorph >> showEmpty [
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
PhratchListMorph >> step [
	lastUpdated = list lastChanged
		ifTrue: [^ self].
	self update.
	self updateTitle.
	self updateBorder.
	self updateCountMorph.
	self updateIndexHighlight.
	listLayoutNeeded ifTrue: [self updateContents].

]

{ #category : #stepping }
PhratchListMorph >> stepTime [

	^ 200

]

{ #category : #'object i/o' }
PhratchListMorph >> storeFieldsOn: anObjStream [
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
PhratchListMorph >> sublistIcon [

	| block slot form halfList big |
	block := ReporterBlockMorph new color: (ScriptablePhratchMorph blockColorFor: 'list'); commandSpec: '$String$'.
	slot := block argMorphs first.
	slot extent: 7 @ 4.
	form := slot imageForm.
	form replaceColor: (form colorAt: 2@2) withColor: (ScriptablePhratchMorph blockColorFor: 'list').
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
PhratchListMorph >> target [

	^ target

]

{ #category : #'list ops' }
PhratchListMorph >> update [

	isUpdating ifTrue: [^ self].
	isUpdating := true.
	self clear.
	1 to: list size do: [:i |
		self privateInsertLine: (list at: i) at: i].
	self layoutChanged.
	lastUpdated := list lastChanged.
	isUpdating := false.
		
]

{ #category : #stepping }
PhratchListMorph >> updateBorder [

	lastActivityError
		ifTrue: [self borderColor: Color red]
		ifFalse: [self borderColor: self normalBorderColor].
	lastActivityError := false.

]

{ #category : #'list ops' }
PhratchListMorph >> updateContents [
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

	PhratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	PhratchTranslator isRTL
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
	PhratchTranslator isRTL
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
PhratchListMorph >> updateContentsForReading [
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

	PhratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	PhratchTranslator isRTL
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
	PhratchTranslator isRTL
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
PhratchListMorph >> updateContentsRecursive [
	"Update and layout my contents and those of my children."

	| page numberRight cellWidth inset x y |

	cellMorphs size = 0 ifTrue: [^ self showEmpty].
	emptyMorph delete.

	page := scrollPane contents.
	page changed.

	PhratchTranslator isRTL
		ifTrue: [numberRight := self right - 5]
		ifFalse: [numberRight := self left + self largestIndexWidth + 6].

	"word-wrap cell contents and fix cell extents, if needed"
	PhratchTranslator isRTL
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
	PhratchTranslator isRTL
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
PhratchListMorph >> updateCountMorph [

	countMorph contents: 'length' localized, PhratchTranslator colonSuffix, ' ', self lineCount printString.
	countMorph left: ((self left + ((self width - countMorph width) // 2) + 3) max: (addSublistMorph right + 1))

]

{ #category : #stepping }
PhratchListMorph >> updateIndexHighlight [
	"Update the highlighted index."

	highlightActive ifTrue: [
		numberMorphs do: [:m | m color: self indexColor].
		highlightActive := false].

]

{ #category : #private }
PhratchListMorph >> updateIndices: rightX [

	| s newNumbers page num cell |
	numberMorphs size > cellMorphs size ifTrue: [
		cellMorphs size + 1 to: numberMorphs size do: [:i | (numberMorphs at: i) delete].
		numberMorphs := numberMorphs copyFrom: 1 to: cellMorphs size].

	newNumbers := #().
	numberMorphs size < cellMorphs size ifTrue: [
		page := scrollPane contents.
		s := StringMorph new
			color: self indexColor;
			font: (PhratchFrameMorph getFont: #Label).
		newNumbers := (numberMorphs size + 1 to: cellMorphs size)
			collect: [:i | s fullCopy contents: i printString].
		newNumbers do: [:m | page addMorph: m].
		numberMorphs := numberMorphs, newNumbers].

	1 to: cellMorphs size do: [:i |
		num := numberMorphs at: i.
		cell := cellMorphs at: i.
		num position: (rightX - num width) @ (cell top + ((cell height - num height) // 2))].


]

{ #category : #'list ops' }
PhratchListMorph >> updateList [
	list contents: self asArray asOrderedCollection.
	lastUpdated := list lastChanged
]

{ #category : #stepping }
PhratchListMorph >> updateTitle [
	"Update my title if I am owned by a sprite and the sprite name changes."

	| s |
	listName ifNil: [^ self].

	(target isKindOf: PhratchSpriteMorph)
		ifTrue: [s := target objName, ' ', listName]
		ifFalse: [s := listName].

	titleMorph contents = s ifFalse: [
		titleMorph contents: s.
		self fixLayout].

]
