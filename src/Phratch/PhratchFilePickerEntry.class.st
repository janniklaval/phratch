"
Displays one line representing a file or folder within a ScratchFilePicker.

"
Class {
	#name : #PhratchFilePickerEntry,
	#superclass : #BorderedMorph,
	#instVars : [
		'nameMorph',
		'highlit',
		'directory',
		'entryName',
		'entryIsDirectory'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #accessing }
PhratchFilePickerEntry >> entryIsDirectory [

	^ entryIsDirectory

]

{ #category : #accessing }
PhratchFilePickerEntry >> entryName [

	^ entryName

]

{ #category : #accessing }
PhratchFilePickerEntry >> highlight: aBoolean [
	"Show or hide my highlight."

	aBoolean ifFalse: [
		highlit := false.
		self color: owner color.
		nameMorph font: (ScratchFrameMorph getFont: #FilePickerEntry); color: Color black.
		borderWidth := 0.
		^ self].

	highlit := true.

	"self color: owner color darker darker darker.
	borderWidth := 2.
	borderColor := (Color r: (96/255) g: (136/255) b: (182/255))."

	self color: (Color r: (96/255) g: (136/255) b: (182/255)).

	nameMorph font: (ScratchFrameMorph getFont: #FilePickerEntryHighlighted); color: Color white.

]

{ #category : #accessing }
PhratchFilePickerEntry >> isHighlit [
	"Answer true if I am highlit."

	highlit
		ifNil: [^ false]
		ifNotNil: [^ highlit]

]

{ #category : #initialization }
PhratchFilePickerEntry >> name: aString dir: owningDirectory isDirectory: dirFlag [

	| icon m n |
	directory := owningDirectory.
	entryName := aString.
	entryIsDirectory := dirFlag.

	entryIsDirectory
		ifTrue: [icon := ScratchFrameMorph skinAt: #folderIcon]
		ifFalse: [icon := ScratchFrameMorph skinAt: #fileIcon].

	n := dirFlag ifTrue: [entryName] ifFalse: [(FileSystem workingDirectory / entryName) basename].
	nameMorph := StringMorph contents: (String  withAll: n) font: (ScratchFrameMorph getFont: #FilePickerEntry).
	self addMorph: (nameMorph position: self position + (28@3)).

	m := ImageMorph new form: icon.
	self addMorph: (m position: self position + (6@((nameMorph height - 6) // 2))).

	highlit := false.
	self extent: 200@(nameMorph height + 6).

]

{ #category : #accessing }
PhratchFilePickerEntry >> thumbnailReady [
	"I don't have a thumbnail."

	^ false

]
