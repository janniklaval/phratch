Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> addGenericListBlocksTo: page y: startY [
	"Add the generic list blocks to the given page starting at the given y offset."

	| addButton deleteButton x y hasLists stage |
	addButton := PhratchFrameMorph
		buttonLabel: 'Make a list' localized
		selector: #addList.
	(self isPhratchStageMorph) ifTrue: [addButton actionSelector: #addGlobalList].

	deleteButton := PhratchFrameMorph
		buttonLabel: 'Delete a list' localized
		selector: #deleteList.

	x := 13.
	y := startY + 10.
	page addMorph: (addButton target: self; position: x@y;
		yourself).
	y := addButton bottom + 3.

	hasLists := self listVarNames size > 0.
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNotNil: [
		stage listVarNames size > 0 ifTrue: [hasLists := true]].
	hasLists ifTrue: [

		page addMorph: (deleteButton target: self; position: x@y;
		yourself).
		y := deleteButton bottom + 10.

		y := (self addListReportersTo: page x: x y: y) + 10 ].


	(self blocksFor: 'list') do: [:blockOrSym |
		({#- . #~ . #=} includes: blockOrSym)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5].  "insert a half space"
				(blockOrSym = #=) ifTrue: [
					y := y + 7.
					page addMorph: ((ImageMorph new form: (PhratchFrameMorph skinAt: #connector)) position: x@y).
					y := y + 20]]  "insert a line"
			ifFalse: [
				y := self createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: ScriptablePhratchMorph listBlockColor]].
	^y

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> addGlobalList [

	| sFrame listName |
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ PhratchError error: 'beep'.].

	listName := StringDialog ask: 'List name?'.
	listName size = 0 ifTrue: [^ self].
	sFrame workPane createListNamed: listName.
	sFrame viewerPane categoryChanged: 'list'.

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> addList [

	| sFrame result listName |
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ PhratchError error: 'beep'.].

	result := NewVariableDialog ask: 'List name?'.
	result = #cancelled ifTrue: [^ self].
	listName := result first.
	result second
		ifTrue: [self createListNamed: listName]
		ifFalse: [sFrame workPane createListNamed: listName].
	sFrame viewerPane categoryChanged: 'list'.

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> addListReportersTo: page x: x y: startY [
	"Add the list block reporters to the given page starting at the given y offset. Answer the new y."

	| y stage b watcherButton yOffset line line2 |
	y := startY.
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	(stage notNil and: [stage ~= self]) ifTrue: [
		stage listVarNames do: [:listVarName |
			b := ListContentsBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: stage blockReceiver;
				commandSpec: listVarName;
				selector: #listNamed:;
		yourself.
			watcherButton := self createToggleButtonFor: b.
			yOffset := (b fullBounds height - watcherButton height) // 2.
			page addMorph: (watcherButton position: x @ (y + yOffset)).
			page addMorph: (b position: (x + watcherButton width + 4)@y).
			y := y + b height + 3].
		(self listVarNames size > 0) ifTrue: [
			line := Morph new.
			line
				extent: 90@1;
				color: Color gray darker darker;
				position: x@(y+2).
			line2 := Morph new.
			line2
				extent: 90@1;
				color: Color gray lighter;
				position: x@(y+3).
			page
				addMorph: line;
				addMorph: line2.
			y := y + 9]].

	self listVarNames do: [:listVarName |
		b := ListContentsBlockMorph new
			color: ScriptablePhratchMorph listBlockColor;
			receiver: self blockReceiver;
			commandSpec: listVarName;
			selector: #listNamed:;
		yourself.
		watcherButton := self createToggleButtonFor: b.
		yOffset := (b fullBounds height - watcherButton height) // 2.
		page addMorph: (watcherButton position: x @ (y + yOffset)).
		page addMorph: (b position: (x + watcherButton width + 4)@y).
		y := y + b height + 3].

	^ y

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> append: anObject toList: listName [
	"Add a new value to the selected list."
	<phratchItem: 'add $String$ to $List$' kind: #- category: 'list' defaultValues: #('thing') subCategory: #a4 special: #()>
	| list |
	list := (listName isPhratchListMorph)
		ifTrue: [ listName ]
		ifFalse: [ self listNamed: listName ifNone: [ ^ 0 ] ].
	list insertLine: (self asListElement: anObject) at: list lineCount + 1
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> contentsOfList: listName [
	"Give the contents of the given list"
	<phratchItem: '$List$' kind: #ReporterBlockMorph category: 'list' defaultValues: #('a list') subCategory: #a1 special: #()>
	| list |
	list := self listNamed: listName ifNone: [^ ''].
	^ list concatenatedLines

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> copyOfList: aList [
	"Return a copy of the given list"
	<phratchItem: 'copy of $SAList$' kind: #ReporterBlockMorph category: 'list' defaultValues: #() subCategory: #a7 special: #()>
	aList ifNil: [^ PhratchListMorph on: #()].
	^ PhratchListMorph on: aList asArray

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> createListNamed: listName [

	| list stage n |
	(self variableNameInUse: listName) ifTrue: [
		PhratchError error: 'beep'.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	lists at: listName put: (list := PhratchListMorph new listName: listName target: self).
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNotNil: [
		n := (stage submorphs select: [:m | m isPhratchListMorph]) size.
		stage addMorph: (list position: stage topRight - ((list width + 10)@0) + (0@(10+(20*n)))).
		list startStepping].

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> defaultListName [

	| stage |
	lists size > 0 ifTrue: [^ lists keys asArray sort first].

	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNotNil: [
		stage lists size > 0 ifTrue: [^ stage lists keys asArray sort first]].

	^ ''

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> deleteLine: lineNum ofList: listName [
	"Remove the given entry of the given list"
	<phratchItem: 'delete $ListDelete$ of $List$' kind: #- category: 'list' defaultValues: #(1) subCategory: #a4 special: #()>
	| list |
	list := self listNamed: listName ifNone: [^ self].
	lineNum = 'all' ifTrue: [list clear. ^ self].
	list deleteLineAt: (self lineNum: lineNum forList: list)

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> deleteList [
	"Ask the user which list variable to delete, then remove it."

	| sFrame stage menu |
	sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage listVarNames isEmpty) & (self listVarNames isEmpty)
		ifTrue: [^ self inform: 'No lists.' localized].

	menu := MenuMorph new defaultTarget: self.
	stage listVarNames do: [:v | menu add: v target: stage selector: #deleteList: argument: v].
	self = stage ifFalse: [
		stage listVarNames isEmpty ifFalse: [menu addLine].
		self listVarNames do: [:v | menu add: v target: self selector: #deleteList: argument: v]].
	menu invokeModal.

	sFrame viewerPane categoryChanged: 'list'.

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> deleteList: listName [
	"Delete the list variable with the given name. Do nothing if the variable doesn't exist."
	<phratchItem: 'delete list $String$' kind: #- category: 'list' defaultValues: #('a list') subCategory: #a2 special: #()>
	| stage sFrame |
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ PhratchError error: 'beep'.].
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	lists removeKey: listName asString ifAbsent: [].
	(self prototype notNil and: [self prototype lists includesKey: listName]) ifFalse: [ 
	stage submorphs do: [:m |
		((m isPhratchListMorph) and: 
		[(m listName = listName) and: 
		[m target = self]])
			ifTrue: [m delete]]].
	sFrame viewerPane categoryChanged: 'list'.

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> getLine: lineNum ofList: listName [
	"Return the value of given item number in the given list"
	<phratchItem: 'item $ListIndex$ of $List$' kind: #ReporterBlockMorph category: 'list' defaultValues: #(1) subCategory: #a5 special: #()>
	| list |
	list := (listName isPhratchListMorph)
		ifTrue: [ listName ]
		ifFalse: [ self listNamed: listName ifNone: [ ^ '' ] ].
	^ list lineAt: (self lineNum: lineNum forList: list)
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> hideList: aList [
	"Hide the watcher(s) for the given list. If the receiver is a sprite and both it and and the stage have the given list, hide both. Do nothing if the list does not exist or is already hidden."
	<phratchItem: 'hide list $List$' kind: #- category: 'list' defaultValues: #() subCategory: #a3 special: #()>
	self showOrHideList: aList show: false
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> indexOf: t1 List: t2 [ 
	"Return the index of the given value in the given list"
	<phratchItem: 'first index of $String$ in $List$' kind: #ReporterBlockMorph category: 'list' defaultValues: #('' 'list') subCategory: #a5 special: #()>  
  | t3 |
    t3 := 1.
    (self lineCountOfList: t2)
        timesRepeat: 
            [(self getLine: t3 ofList: t2)
                = t1 ifTrue: [^ t3].
            t3 := t3 + 1].
    ^ 0
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> insert: anObject at: lineNum ofList: listName [
	"Insert a value at the given index of the given list"
	<phratchItem: 'insert $String$ at $ListIndex$ of $List$' kind: #- category: 'list' defaultValues: #('thing' 1) subCategory: #a4 special: #()>
	| list i |
	list := self listNamed: listName ifNone: [^ self].
	i := self lineNum: lineNum forList: list.
	#last = lineNum ifTrue: [i := list lineCount + 1].
	list insertLine: (self asListElement: anObject) at: i.


]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> lineCountOfList: listName [
	"Give the number of items in the given list"
	<phratchItem: 'length of $List$' kind: #ReporterBlockMorph category: 'list' defaultValues: #() subCategory: #a5 special: #()>
	| list |
	list := self listNamed: listName ifNone: [^ 0].
	^ list lineCount

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> lineNum: lineNum forList: list [

	| s |
	lineNum isNumber ifTrue: [^ lineNum asInteger].

	s := lineNum.
	(s isString) ifTrue: [
		#first = s ifTrue: [^ 1].
		#last = s ifTrue: [^ list lineCount].
		#any = s ifTrue: [
			list lineCount = 0 ifTrue: [^ 1].
			^ (1 to: list lineCount) atRandom].
		^ s asNumberNoError].
	^ 0

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> list: listName contains: anObject [
	"Verify if the list contains the given object."
	<phratchItem: '$List$ contains $String$' kind: #BooleanBlockMorph category: 'list' defaultValues: #('list' 'thing') subCategory: #a5 special: #()>
	| list |
	list := self listNamed: listName ifNone: [^ false].
	^ list includes: anObject

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> listIndexMenu [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	#('1' last any) do: [:s | menu add: s value: s].
	menu localize invokeModal.
	^ menu

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> newList: aPhratchListMorph [
	"Return a list of the given arguments. This list is not stored in the environment"
	<phratchItem: 'list $MAAny$' kind: #ReporterBlockMorph category: 'list' defaultValues: #() subCategory: #a1 special: #()>
	^aPhratchListMorph
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> numberSort: t1 [ 
	"Sort the given list numerically"
	<phratchItem: 'sort items of $List$ by numerical value' kind: #- category: 'list' defaultValues: #('list') subCategory: #a6 special: #()>
    | t2 t3 t4 t5 t6 |
    t2 := #() asOrderedCollection.
    t3 := #() asOrderedCollection.
    t4 := #() asOrderedCollection.
    t6 := #() asOrderedCollection.
    t5 := 1.
    (self lineCountOfList: t1)
        timesRepeat: 
            [t2 add: (self getLine: t5 ofList: t1).
            t5 := t5 + 1].
    t2 do: 
        [:t7 | 
        t3 add: t7 asNumberNoError.
        t7 asNumberNoError = 0 ifTrue: [t4 add: t7]].
    t3 := t3 asArray sort.
    t3 := t3 asOrderedCollection.
    t5 := 1.
    t3 do: 
        [:t8 | 
        t8 = 0 ifFalse: [t6 add: t8].
        t8 = 0
            ifTrue: 
                [t6 add: (t4 at: t5).
                t5 := t5 + 1]].
    self deleteLine: 'all' ofList: t1.
    t6 do: [:t9 | self append: t9 toList: t1]
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> quietCreateListNamed: listName [
	"Create the given list silently"
	<phratchItem: 'make list $String$' kind: #- category: 'list' defaultValues: #('a list') subCategory: #a2 special: #()>
	| list stage n |
	(self variableNameInUse: listName) ifTrue: [^ self].

	lists at: listName put: (list := PhratchListMorph new listName: listName target: self).
	(stage := self ownerThatIsAPhratchStageMorph) ifNotNil: [
		n := (stage submorphs select: [:m | m isPhratchListMorph]) size.
		stage addMorph: (list position: stage topRight - ((list width + 10)@0) + (0@(10+(20*n)))).
		list startStepping].
	self showOrHideList: listName show: false.
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> setLine: lineNum ofList: listName to: anObject [
	"Replace the given item of the list by the given value"
	<phratchItem: 'replace item $ListIndex$ of $List$ with $String$' kind: #- category: 'list' defaultValues: #(1 'list' 'thing') subCategory: #a4 special: #()>
	| list |
	list := self listNamed: listName ifNone: [^ ''].
	^ list setLineAt: (self lineNum: lineNum forList: list) to: (self asListElement: anObject)

]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> showList: aList [
	"Show the watcher(s) for the given list. If the receiver is a sprite and both it and and the stage have the given list, show both. Do nothing if the list does not exist or is already showing."
	<phratchItem: 'show list $List$' kind: #- category: 'list' defaultValues: #() subCategory: #a3 special: #()>
	self showOrHideList: aList show: true
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> showOrHideList: aList show: aBoolean [
	"Show or hide the given list"
 
	| list stage sFrame |
	(stage := self ownerThatIsAPhratchStageMorph).
	(self listVarNames includes: aList)
		ifFalse: [stage
			ifNotNil: [(stage listVarNames includes: aList)
				ifTrue: [list := stage lists at: aList]
				ifFalse: [^ self]]
			ifNil: [^ self]]
		ifTrue: [list := lists at: aList].
	aBoolean
		ifTrue: [stage addMorph: list]
		ifFalse: [list delete].
	(sFrame := self ownerThatIsAPhratchFrameMorph) ifNil: [^ self].
	sFrame viewerPane categoryChanged: 'variables'
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> stringSort: t1 [
	"Sort the list using the character order"
	<phratchItem: 'sort items of $List$ by string value' kind: #- category: 'list' defaultValues: #('list') subCategory: #a6 special: #()> 
    | t2 t3 |
    (self lineCountOfList: t1)
        = 0 ifTrue: [^ self].
    (self lineCountOfList: t1)
        = 1 ifTrue: [^ self].
    t2 := #() asOrderedCollection.
    t3 := 1.
    (self lineCountOfList: t1)
        timesRepeat: 
            [t2 add: (self getLine: t3 ofList: t1).
            t3 := t3 + 1].
    t2 := t2 asArray sort.
    self deleteLine: 'all' ofList: t1.
    t2 do: [:t4 | self append: t4 toList: t1]
]

{ #category : #'*PhratchList' }
ScriptablePhratchMorph >> times: t1 List: t2 [ 
	"Return the number times that the given value appears in the given list"
<phratchItem: 'times $String$ appears in $List$' kind: #ReporterBlockMorph category: 'list' defaultValues: #('' 'list') subCategory: #a5 special: #()>
    | t3 t4 |
    t3 := 1.
    t4 := 0.
    (self lineCountOfList: t2)
        timesRepeat: 
            [(self getLine: t3 ofList: t2)
                = t1 ifTrue: [t4 := t4 + 1].
            t3 := t3 + 1].
    ^ t4
]
