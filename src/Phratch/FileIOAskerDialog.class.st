Class {
	#name : #FileIOAskerDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'phratchFrame'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #status }
FileIOAskerDialog >> always [
	"Set the file I/O preference to 'always' and never prompt the user again."
	
	phratchFrame ifNotNil: [
		ScriptablePhratchMorph fileIOPreference: true].

	response := true.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #initialization }
FileIOAskerDialog >> initialize [
	| spacer |
	super initialize.
	spacer := Morph new
		extent: 10 @ 5;
		color: Color transparent;
		yourself.
	self
		withButtonsForYes: true
		no: true
		okay: false
		cancel: false.
	self title: 'Allow File I/O' localized.
	self
		message:
			'This Panther project is trying to use file I/O. While file I/O
can be a very useful feature, it also poses a potential risk
to your computer. Before allowing this project to use file
I/O, make sure that this project and its author can be
trusted before allowing it to write to local files, or better
yet, read through the code and determine if the file I/O is
harmful or useful.'.
	buttonRow addMorphBack: (self buttonLabel: 'Always' localized action: #always).
	buttonRow addMorphBack: spacer fullCopy.
	buttonRow addMorphBack: (self buttonLabel: 'Never' localized action: #never).
	buttonRow addMorphBack: spacer fullCopy.
	buttonRow submorphs
		do: [ :b | 
			(b isResizableToggleButton)
				ifTrue: [ tabFields add: b ] ]
]

{ #category : #status }
FileIOAskerDialog >> never [
	"Set the file I/O preference to 'never' and never prompt the user again."
	
	phratchFrame ifNotNil: [
		ScriptablePhratchMorph fileIOPreference: false].
	
	response := false.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"
]
