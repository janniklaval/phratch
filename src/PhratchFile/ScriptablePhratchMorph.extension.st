Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> askForFileIO [
	"Ask the user to either allow or deny file I/O, or return the preference from the sFrame if it exists."
	
	| sFrame dialog |
	(sFrame := self ownerThatIsAPhratchFrameMorph) ifNil: [
		sFrame := (self ownerThatIsAOffscreenWorldMorph) frame].
	ScriptablePhratchMorph fileIOPreference ifNotNil: [^ ScriptablePhratchMorph fileIOPreference].
	dialog := FileIOAskerDialog new forPhratchFrame: sFrame.
	^ dialog getUserResponse.
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> clearFile: aFileNameString [
	"Clear the given file."
	<phratchItem: 'clear file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a special: #()>
	| f |
	(self askForFileIO = true) ifFalse: [^ self].
	aFileNameString asFileReference delete.
	f := FileStream newFileNamed: aFileNameString.
	f close
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> createFile: aFileNameString [
	"Create the given file name."
	<phratchItem: 'create file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a special: #()>
	(self askForFileIO = true) ifFalse: [^ self].
	aFileNameString asFileReference ensureDelete.
	(FileStream newFileNamed: aFileNameString) 
		nextPutAll: '';
		close.
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> deleteFile: aFileNameString [
	"Delete the given file."
	<phratchItem: 'delete file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a special: #()>
	(self askForFileIO = true) ifFalse: [^ self].
	aFileNameString asFileReference delete.
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> numFileLines: aFileNameString [
	"Answer the number of lines in the given file."
	<phratchItem: 'number of lines of file $String$' kind: #ReporterBlockMorph category: 'files' defaultValues: #() subCategory: #a special: #()>
	| f data |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ ''].
	f := (FileStream readOnlyFileNamed: aFileNameString) binary.
	f ifNil: [^ ''].
	data := f contentsOfEntireFile asString.
	f close.
	"Replace newlines:
	data replaceAll: $
 with: $ ."
	^ data lines size.
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> numUrlFileLines: aURLString [
	"Answer the number of lines in the given URL file."
	<phratchItem: 'number of lines of file at URL $String$' kind: #ReporterBlockMorph category: 'files' defaultValues: #('http://') subCategory: #a special: #()>
	^ (ZnClient new get: aURLString) contents lines size.
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> readFile: aFileNameString [
	"Answer the contents of the given file."
	<phratchItem: 'contents of file $String$' kind: #ReporterBlockMorph category: 'files' defaultValues: #() subCategory: #a special: #()>
	| f data |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ ''].
	f := (FileStream readOnlyFileNamed: aFileNameString) binary.
	f ifNil: [^ ''].
	data := f contentsOfEntireFile asString.
	f close.
	^ data
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> readFromUrl: aURLString [
	"Answer the contents of the given URL."
	<phratchItem: 'contents of file at URL $String$' kind: #ReporterBlockMorph category: 'files' defaultValues: #('http://') subCategory: #a special: #()>
	^ (ZnClient new get: aURLString) contents.
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> readLine: t1 FromUrl: t2 [ 
	"Answer the contents of the given line of the given URL."
	<phratchItem: 'line $Number$ of file at URL $String$' kind: #ReporterBlockMorph category: 'files' defaultValues: #(1 'http://') subCategory: #a special: #()>
	^ (ZnClient new get: t2) contents lines at: t1 ifAbsent: [''].
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> readLine: lineNum ofFile: aFileNameString [
	"Answer the contents of the given line of the given file."
	<phratchItem: 'line $Number$ of file $String$' kind: #ReporterBlockMorph category: 'files' defaultValues: #() subCategory: #a special: #()>
	| f data |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ ''].
	f := (FileStream readOnlyFileNamed: aFileNameString) binary.
	f ifNil: [^ ''].
	data := f contentsOfEntireFile asString.
	f close.
	^ data lines at: lineNum ifAbsent: [''].
]

{ #category : #'*PhratchFile' }
ScriptablePhratchMorph >> writeText: aString toFile: aFileNameString [
	"Write the given text in the given file."
	<phratchItem: 'write $String$ to file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a special: #()>
	| f |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ self].
	f := (FileStream fileNamed: aFileNameString) binary.
	f ifNil: [^ self].
	f setToEnd.
	f nextPutAll: aString.
	f close
]
