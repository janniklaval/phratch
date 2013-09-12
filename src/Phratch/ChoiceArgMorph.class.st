"
I am used to represent an ArgMorph that allows the user to choose from a popup menu of choices. For example, I might allow selection of a sensor port from the list ('a', 'b', 'c', 'd').

In an earlier version of Scratch, I was used to represent boolean values. That usage has been replaced with BooleanArgMorph.

"
Class {
	#name : #ChoiceArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'menuIconMorph',
		'options',
		'choice',
		'getOptionsSelector'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #other }
ChoiceArgMorph >> acceptsDroppedReporters [
	"Accept reporter blocks in list blocks"

	^(owner respondsTo: #selector) and: [ 
		 #(listNamed: 
		append:toList: 
		deleteLine:ofList: 
		insert:at:ofList: 
		setLine:ofList:to: 
		getLine:ofList: 
		lineCountOfList: 
		list:contains:
		contentsOfList:
		getAttribute:of:
		attribute:of:
		get:
		set:to:
		setVar:to:
	) includes: owner selector]
]

{ #category : #byob }
ChoiceArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type."

	^ aBlockMorph isReporter and:[ aBlockMorph isBooleanReporter not]
]

{ #category : #accessing }
ChoiceArgMorph >> choice [

	^ choice

]

{ #category : #accessing }
ChoiceArgMorph >> choice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| frame palette block doLocalization label |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	((#soundNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame newSound]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane newScene]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('re-record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane rerecordScene]].

	choice := label := aSymbol.
	label := label asString.
	doLocalization := (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not. 
	doLocalization
		ifTrue:[labelMorph contents: label localized]
		ifFalse:[labelMorph contents: label].
	options = {'with inputs' localized. 'with input list' localized} ifTrue: [
		labelMorph contents: label localized].
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: (labelMorph extent + (16@2) + borderWidth).

	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(owner isKindOf: BlockMorph) ifTrue: [
		((owner respondsTo: #addLabel) and: [owner isCustomBlock not])
			ifTrue: [owner addLabel]
			ifFalse: [owner fixBlockLayout]].

	(owner isKindOf: SetterBlockMorph) ifTrue: [ owner determineIfSpecialForm ].

	options = {'with inputs' localized. 'with input list' localized} ifTrue: [
		(owner respondsTo: #adjustInputParadigm:) ifTrue: [
			owner adjustInputParadigm: choice localized]]. 

	(palette := self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) ifNil: [^ self].
	(block := self ownerOrYourselfThatIsA: BlockMorph) ifNil: [^ self].

	block isReporter ifTrue: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #accessing }
ChoiceArgMorph >> defaultValue: aString [
	"Set my default value."

	self choice: aString.

]

{ #category : #other }
ChoiceArgMorph >> evaluate [
	"Answer my value."

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [^implicitValue].
	^ choice

]

{ #category : #'object i/o' }
ChoiceArgMorph >> fieldsVersion [

	^ 2

]

{ #category : #other }
ChoiceArgMorph >> fixArgLayout [
	"Set my color to my owner's color."

	self color: (owner color mixed: 0.75 with: (Color gray: 0.45)).

]

{ #category : #accessing }
ChoiceArgMorph >> getOptionsSelector [

	^ getOptionsSelector

]

{ #category : #accessing }
ChoiceArgMorph >> getOptionsSelector: aSymbolOrString [
	"Set a selector that is used to get a set of options from my command block's receiver. This is used when the options can change over time, such as selecting from a list of available sounds or costumes in the objects media library."

	getOptionsSelector := aSymbolOrString asSymbol.

]

{ #category : #'event handling' }
ChoiceArgMorph >> handlesMouseDown: evt [

	^ evt hand toolType isNil and:
		[(self topRight - (14@0) corner: self bottomRight) containsPoint: evt cursorPoint]

]

{ #category : #'object i/o' }
ChoiceArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		options
		choice
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		getOptionsSelector
	) from: anObjStream.

]

{ #category : #initialization }
ChoiceArgMorph >> initialize [

	super initialize.
	self borderInset.
	self borderWidth: 1.
	self color: Color brown.
	labelMorph := StringMorph new
		font: (PhratchFrameMorph getFont: #Arg);
		forceUnicodeRendering: true;
		color: Color white;
		yourself.
	self addMorph: labelMorph.
	menuIconMorph := ImageMorph new form: DropDownMenuForm.
	self addMorphFront: menuIconMorph.
	options := #(a b c d).
	self choice: #a.

]

{ #category : #byob }
ChoiceArgMorph >> isEmptySlot [
	^choice size = 0
]

{ #category : #'event handling' }
ChoiceArgMorph >> mouseDown: evt [

	self presentMenu.

]

{ #category : #accessing }
ChoiceArgMorph >> options [
	"Answer my set of options. If getOptionsSelector is not nil and I'm in a CommandBlock with a non-nil receiver, fetch my set of options by sending getOptionsSelector to that receiver."

	#varNamesMenu = getOptionsSelector
		ifTrue: [^owner varNamesMenu].

	(getOptionsSelector notNil and:
	 [(owner respondsTo: #receiver) and:
	 [owner receiver notNil]]) ifTrue: [
		^ owner receiver perform: getOptionsSelector].

	^ options

]

{ #category : #accessing }
ChoiceArgMorph >> options: stringList [

	options := stringList asArray.
	(options includes: choice) ifFalse: [self choice: options first].

]

{ #category : #accessing }
ChoiceArgMorph >> presentMenu [
	"Pop up a menu of choices."

	| optionList doLocalization menu option |
	optionList := self options.
	optionList size = 0 ifTrue: [^ self].
	doLocalization := (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
	doLocalization ifFalse: [
		doLocalization := (optionList = {'with inputs' localized. 'with input list' localized})].
	menu := MenuMorph new defaultTarget: self.
	optionList do: [:sym |
		'-' = sym
			ifTrue: [menu addLine]
			ifFalse: [
				option := sym localized.

				((#(hookupSensorNames hookupBooleanSensorNames) includes: getOptionsSelector) and:
				 [(#(connected resistance) includes: sym)])
					ifTrue: [#(A B C D) do: [:c |
						self owner isBooleanReporter
							ifFalse: [
								menu
								 	add: (option, '-', c)
									target: self 
									selector: #choice:
									argument: (sym, '-', c)]
							ifTrue: [
								menu
								 	add: (c, ' ', option)
									target: self 
									selector: #choice:
									argument: (c, ' ' ,sym)]]]
					ifFalse: [
						menu
							add: (option)
							target: self 
							selector: #choice:
							argument: (sym)]]].


	menu invokeModal

]

{ #category : #other }
ChoiceArgMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	aStream
		nextPutAll: '"';
		nextPutAll: self labelMorph contents;
		nextPutAll: '"'
]

{ #category : #accessing }
ChoiceArgMorph >> privateSetChoice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| frame palette block doLocalization label |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	((#soundNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame newSound]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane newScene]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('re-record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane rerecordScene]].

	choice := label := aSymbol.
	label := label asString.
	doLocalization := (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
	doLocalization
		ifTrue:[labelMorph contents: label localized]
		ifFalse:[labelMorph contents: label].
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: (labelMorph extent + (16@2) + borderWidth).

	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(block := self ownerOrYourselfThatIsA: HatBlockMorph) ifNotNil: [
		block fixBlockLayout].

	(owner isKindOf: SetterBlockMorph) ifTrue: [ owner determineIfSpecialForm ].

"
	options = #('with inputs' 'with input list') ifTrue: [
		(owner respondsTo: #adjustInputParadigm:) ifTrue: [
			owner adjustInputParadigm: choice ]].
"
	(palette := self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) ifNil: [^ self].
	(block := self ownerOrYourselfThatIsA: BlockMorph) ifNil: [^ self].

	block isReporter ifTrue: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #'object i/o' }
ChoiceArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		options
		choice
		getOptionsSelector
	) on: anObjStream.

]
