"
I represent an image file, which I can display as thumbnail.

Details: The image file is read and the thumbnail computed by a background process. A step method in the UI process polls to find out when the thumbnail is ready for display, then installs it. This avoids potential race conditions with the UI thread's damage reporting and redisplay mechanism.

"
Class {
	#name : #ScratchFilePickerImageEntry,
	#superclass : #ScratchFilePickerEntry,
	#instVars : [
		'thumbnailMorph',
		'thumbnailForm',
		'thumbnailReady'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #accessing }
ScratchFilePickerImageEntry >> clearThumbnailReady [
	"Clear my thumbnailReady flag and report a change. Because it contains a 'self changed', this method should be called from the main UI thread, not from the background process to avoid potential race conditions."

	thumbnailMorph top: self bottom - thumbnailForm height - 23.
	thumbnailMorph left: self left + ((self width - thumbnailForm width) // 2).
	thumbnailMorph form: thumbnailForm.

	thumbnailReady := false.
	self changed.

]

{ #category : #accessing }
ScratchFilePickerImageEntry >> computeThumbnail [
	"Compute my thumbnail, but don't do a 'self changed' because I may be run from a background thread."

	| fName fContents f scale |
	entryIsDirectory ifTrue: [^ self].
	thumbnailForm ifNotNil: [^ self].
self haltOnce.
	[	fName := (directory / entryName) fullName.
		fContents := (FileStream readOnlyFileNamed: fName) binary contentsOfEntireFile.
		f := ColorForm fromBinaryStream: (ReadStream on: fContents)
	] ifError: [^ self].

	f depth < 16 ifTrue: [f := f asFormOfDepth: 16].
	scale := (80.0 / f width) min: (60.0 / f height).
	thumbnailForm := f magnifyBy: scale.

	thumbnailReady := true.
]

{ #category : #accessing }
ScratchFilePickerImageEntry >> highlight: aBoolean [
	"Show or hide my highlight."

	aBoolean ifFalse: [
		self color: owner color.
		nameMorph font: (ScratchFrameMorph getFont: #FilePickerEntry); color: Color black.
		highlit := false.
		borderWidth := 0.
		nameMorph left: self left + ((self width - nameMorph width) // 2).
		^ self].

	"self color: owner color darker darker darker.
	borderWidth := 2.
	borderColor := (Color r: (96/255) g: (136/255) b: (182/255))."

	self color: (Color r: (96/255) g: (136/255) b: (182/255)).

	nameMorph font: (ScratchFrameMorph getFont: #FilePickerEntryHighlighted); color: Color white.
	nameMorph left: self left + ((self width - nameMorph width) // 2).

	highlit := true.

]

{ #category : #initialization }
ScratchFilePickerImageEntry >> name: aString dir: owningDirectory isDirectory: dirFlag [

	| n truncated w eWidth |
	self color: Color transparent.
	self extent: 125@110.

	directory := owningDirectory.
	entryName := aString.
	entryIsDirectory := dirFlag.
	thumbnailReady := false.

	thumbnailMorph := ImageMorph new.
	entryIsDirectory
		ifTrue: [thumbnailMorph form: (ScratchFrameMorph skinAt: #bigFolderIcon)]
		ifFalse: [thumbnailMorph form: ((Form extent: 4@4 depth: 8) fillColor: Color transparent)].

	thumbnailMorph top: self bottom - thumbnailMorph height - 23.
	thumbnailMorph left: self left + ((self width - thumbnailMorph width) // 2).

	n := dirFlag ifTrue: [entryName] ifFalse: [(owningDirectory / entryName) basename].
	nameMorph := StringMorph contents: (String  withAll: n) font: (ScratchFrameMorph getFont: #FilePickerEntry).

	"trim file name to fit button, if necessary"
	truncated := false.
	eWidth := (ScratchTranslator stringExtent: '...' font: (ScratchFrameMorph getFont: #FilePickerEntryHighlighted)) x.
	w := 100 - eWidth.
	[((ScratchTranslator stringExtent: n font: nameMorph font) x) > w] whileTrue: [
		truncated := true.
		n := n copyFrom: 1 to: n size - 1].
	truncated ifTrue: [n := n, '...'].
	nameMorph contents: (String  withAll: n).
	nameMorph bottom: self bottom - 2.
	self isHighlit
		ifTrue: [nameMorph left: self left + ((self width - nameMorph width - eWidth) // 2)]
		ifFalse: [nameMorph left: self left + ((self width - nameMorph width) // 2)].

	self addMorph: nameMorph.
	self addMorph: thumbnailMorph.

]

{ #category : #accessing }
ScratchFilePickerImageEntry >> thumbnailForm: aForm [
	"Set my thumbnail form."

	thumbnailForm := aForm.
	thumbnailMorph top: self bottom - thumbnailForm height - 23.
	thumbnailMorph left: self left + ((self width - thumbnailForm width) // 2).
	thumbnailMorph colorform: thumbnailForm.


]

{ #category : #accessing }
ScratchFilePickerImageEntry >> thumbnailReady [
	"Answer true if my thumbnail has been computed but I have not yet done a change update."

	^ thumbnailReady

]
