"
Reporter for the contents of a list.

"
Class {
	#name : #ListContentsBlockMorph,
	#superclass : #ReporterBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #all }
ListContentsBlockMorph >> addLabel [
	"Add a label for my command and arguments. 
	This is the method that really creates the whole block."
	"Details: This overrides the superclass method to allow 
	using percent character in variable/list names"

	commandSpec ifNil: [^ self].
	self removeAllMorphs.
	self addMorphBack: (self labelMorphFor: commandSpec).

]

{ #category : #all }
ListContentsBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	^ (Array new: 4)
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: #listNamed:;
		at: 4 put: commandSpec;
		yourself


]

{ #category : #all }
ListContentsBlockMorph >> evaluateWithArgs: ignored [

	^ receiver listNamed: commandSpec

]

{ #category : #all }
ListContentsBlockMorph >> selectorAndArg [

	^ Array with: selector with: commandSpec

]

{ #category : #all }
ListContentsBlockMorph >> toggleWatcher [
	"Toggle between hiding and showing a list watcher for this block."

	| frame listMorph stage palette |
"	listMorph := receiver lists at: commandSpec ifAbsent: [^ self]."
	
	listMorph := receiver listNamed: commandSpec ifNone: [^ self].
	listMorph value owner
		ifNil: [
			(stage := receiver ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self].
			stage addMorph: listMorph.
			(stage bounds containsPoint: listMorph topLeft) ifFalse: [
				listMorph position: stage topLeft + 10].
			listMorph
				fixLayoutForNewLanguage;
				startStepping]
		ifNotNil: [
			listMorph delete].

	(frame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].				
	palette := self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].

]
