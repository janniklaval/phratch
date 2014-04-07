Extension { #name : #ChoiceArgMorph }

{ #category : #'*PhratchObjStream' }
ChoiceArgMorph >> fieldsVersion [

	^ 2

]

{ #category : #'*PhratchObjStream' }
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

{ #category : #'*PhratchObjStream' }
ChoiceArgMorph >> privateSetChoice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| frame palette block doLocalization label |
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	((#soundNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, '...')]) ifTrue: [
		frame ifNotNil: [^ frame newSound]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, '...')]) ifTrue: [
		frame ifNotNil: [^ frame workPane newScene]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('re-record' localized, '...')]) ifTrue: [
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

	(block := self ownerOrYourselfThatIsAHatBlockMorph) ifNotNil: [
		block fixBlockLayout].

	(owner isKindOf: SetterBlockMorph) ifTrue: [ owner determineIfSpecialForm ].

"
	options = #('with inputs' 'with input list') ifTrue: [
		(owner respondsTo: #adjustInputParadigm:) ifTrue: [
			owner adjustInputParadigm: choice ]].
"
	(palette := self ownerOrYourselfThatIsAPhratchBlockPaletteMorph) ifNil: [^ self].
	(block := self ownerOrYourselfThatIsABlockMorph) ifNil: [^ self].

	block isReporter ifTrue: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #'*PhratchObjStream' }
ChoiceArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		options
		choice
		getOptionsSelector
	) on: anObjStream.

]
