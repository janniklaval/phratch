Extension { #name : #StandardFileStream }

{ #category : #'*Phratch-Extensions' }
StandardFileStream class >> newPhratchFileNamed: fileName [
	"Create a new file with the given name, and answer a stream opened for writing on that file. If the file already exists, ask the user what to do."

	| dir localName choice newName fullName result ext |
	fullName := fileName isString ifTrue:[fileName] ifFalse:[fileName fullName].
	(self isAFileNamed: fullName) ifFalse: [
		result := self new open: fullName forWrite: true.
		result ifNil: [DialogBoxMorph inform: 'Could not write file' withDetails: 'Is the folder read-only?' localized].
		^ result].

	"file already exists:"
	
	dir :=  fileName parent.
	localName := fileName basename.
	choice := DialogBoxMorph
		askWithCancel: 'The file name already exists. Overwrite existing file?'.
	choice = #cancelled ifTrue: [^ nil].

	choice
		ifTrue: [
			(dir / localName) delete.
			result := self new open: fullName forWrite: true.
			result ifNil: [DialogBoxMorph inform: 'Could not write file' withDetails: 'Is the folder read-only?' localized].
			^ result]
		ifFalse: [
			newName := StringDialog askWithCancel: 'New file name?'.
			newName size = 0 ifTrue: [^ nil].
			fullName := (dir / newName) fullName.
			ext := (fileName) extension.
			(ext size > 0 and: [(newName endsWith: ext) not]) ifTrue: [
				fullName := fullName, '.', ext].

			^ self newPhratchFileNamed: fullName].
]
