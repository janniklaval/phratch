Class {
	#name : #ThumbnailCache,
	#superclass : #Object,
	#instVars : [
		'directory',
		'fileSizes',
		'dict'
	],
	#classVars : [
		'ThumbnailFileName'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'class initialization' }
ThumbnailCache class >> initialize [
	"self initialize"

	ThumbnailFileName := 'scratchthumbs.db'.

]

{ #category : #initialization }
ThumbnailCache >> directory: aFileDirectory [

	directory := aFileDirectory.
	dict := Dictionary new.

	fileSizes := Dictionary new.
	directory entries do: [:entry |
		entry isDirectory ifFalse: [
			fileSizes at: entry name put: entry size]].

]

{ #category : #other }
ThumbnailCache >> filesToUpdate [
	"Answer a list of image files that need to have their thumbnails updated."

	| extensions imageFiles |
	extensions := #(gif jpeg jpg bmp png sprite) asSet.
	imageFiles := directory fileNames select: [:fn |
		extensions includes: (directory / fn) extension asSymbol].

	^ imageFiles select: [:fn | (dict includesKey: fn) not].

]

{ #category : #other }
ThumbnailCache >> readThumbnailFile [
	"Attempt to read the thumbnail file in my directory and store the result in dict. If the file doesn't exist or can't be read, make dict be an empty dictionary."

	| fName f buf |
	dict := Dictionary new.
	fName := (directory / ThumbnailFileName) fullName.
	[	(FileStream isAFileNamed: fName) ifTrue: [
			f := (FileStream readOnlyFileNamed: fName) binary.
			buf := f contentsOfEntireFile.
			dict := ObjStream new readObjFrom: (ReadStream on: buf)].
	] ifError: [].

]

{ #category : #other }
ThumbnailCache >> removeObsoleteEntries [
	"Remove obsolete entries from the dictionary. A thumbnail cache entry is obsolete if (a) the file is no longer found in the directory or (b) the size of the file does not match the files size in the cache entry. Return true if any entries were removed."
	"Note: Originally we used file modification times to detect when a cache entry became obsolete (e.g. because a file was edited). However, these timestamps could change with transitions to/from daylight savings time and when moving laptops between timezones. We now use the file size which is very likely to change when a graphics file is edited. Although there is a small change that an invalid cache entry will not be detected, in that case the obsolete chache entry will probably be very similar in appearance to the edited image. In the worst case, one can manually delete the thumbnails cache file to force the cache to be regenerated."

	| didRemove fSize |
	didRemove := false.
	dict keys do: [:fn |
		fSize := fileSizes at: fn ifAbsent: [0].
		((dict at: fn) value at: 1) ~= fSize ifTrue: [
			didRemove := true.
			dict removeKey: fn]].
	^ didRemove

]

{ #category : #other }
ThumbnailCache >> scriptCountFor: aSprite [
	"Answer the number of scripts in the given sprite. The scripts are in tuple form. A script must start with a hat block."

	| hats count stack |
	hats := #(EventHatMorph KeyEventHatMorph MouseClickEventHatMorph WhenHatBlockMorph).
	count := 0.
	aSprite blocksBin do: [:pair |
		stack := pair at: 2.
		((stack size > 0) and: [stack first size > 0]) ifTrue: [
			(hats includes: stack first first) ifTrue: [count := count + 1]]].
	^ count


]

{ #category : #other }
ThumbnailCache >> thumbnailFor: fileName [

	^ (dict at: fileName ifAbsent: [^ nil]) at: 2

]

{ #category : #other }
ThumbnailCache >> thumbnailFromImageData: aByteArray [
	"Answer a thumbnail for the image stored in the given ByteArray (the contents of a binary file)."

	| f scale |
	f := Form fromBinaryStream: (ReadStream on: aByteArray).
	f depth < 16 ifTrue: [f := f asFormOfDepth: 16].
	scale := (80.0 / f width) min: (60.0 / f height).
	f := f magnifyBy: scale.
	^ f

]

{ #category : #other }
ThumbnailCache >> thumbnailFromSpriteData: aByteArray [
	"Answer a thumbnail for the sprite stored in the given ByteArray (the contents of a binary file)."

	| s version proj sprite scriptCount f scale thumbF spriteBlock p label labelForm |
	s := ReadStream on: aByteArray.

	version := ObjStream scratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptableScratchMorph decodeAsByob.	"make sure we initialize every field - this breaks compatibility with Scratch-sprites. -Jens". 

		s position: 0.
		proj := ObjStream new readObjFrom: s showProgress: false].
	(version = 1) | (version = 2) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := ObjStream new readObjFrom: s showProgress: false].

	proj class = ScratchStageMorph ifFalse: [^ nil].
	sprite := proj submorphs detect: [:m | m isKindOf: ScriptableScratchMorph] ifNone: [^ nil].
	f := sprite costumeForm asFormOfDepth: 16.
	scale := (56.0 / f width) min: (42.0 / f height).
	f := f magnifyBy: scale.
	thumbF := Form extent: 80@60 depth: 16.
	f displayOn: thumbF at: ((thumbF width - f width) // 2) @ 0 rule: Form paint.
	spriteBlock := ScratchFrameMorph skinAt: #spriteBlock.
	p := ((thumbF width - spriteBlock width) // 2) @ (thumbF height - spriteBlock height).
	spriteBlock displayOn: thumbF at: p rule: Form paint.

	scriptCount := self scriptCountFor: sprite.
	label := 'Scripts' localized, ScratchTranslator colonSuffix, ' ', scriptCount printString.
	scriptCount = 0 ifTrue: [label := 'no scripts' localized].
	scriptCount = 1 ifTrue: [label := '1 script' localized].
	labelForm := (StringMorph contents: label font: (StrikeFont fontName: 'Verdana' size: 10)) imageForm.
	labelForm displayOn: thumbF at: p + (((spriteBlock width - labelForm width // 2) + 1)@ 5) rule: Form paint.

	^ thumbF

]

{ #category : #other }
ThumbnailCache >> updateThumbnails [
	"Update my dictionary by creating thumbnails for all the image files in my directory. If updates were needed, try to save save the thumbnails cache."

	| didRemove fList n thumb buf fSize |
	didRemove := self removeObsoleteEntries.
	fList := self filesToUpdate.

	fList size > 0 ifTrue: [
		n := 0.
		('Updating thumbnails' localized, ScratchTranslator ellipsesSuffix)
			displayProgressAt: Display center
			from: 0 to: fList size
			during: [:bar |
				fList do: [:fn |
					bar value: n.
					thumb := nil.
					[
						buf := (FileStream readOnlyFileNamed: (directory / fn) fullName) binary contentsOfEntireFile.
						((fn asLowercase endsWith: '.sprite') | (fn asLowercase endsWith: '.ysp'))
							ifTrue: [thumb := self thumbnailFromSpriteData: buf]
							ifFalse: [thumb := self thumbnailFromImageData: buf].
					] ifError: [].
					fSize := fileSizes at: fn ifAbsent: [0].
					thumb ifNotNil: [dict at: fn put: (Array with: fSize with: thumb colorReduced)].
					n := n + 1]]].

	(didRemove | (fList size > 0) | (dict size = 0)) ifTrue: [self writeThumbnailFile].

]

{ #category : #other }
ThumbnailCache >> writeThumbnailFile [
	"Write dict to the thumbnail file in my directory. Do nothing if the file cannot be written."

	| f |
	dict size = 0 ifTrue: [  "if no thumbnails and no thumbnails file to delete, do nothing"
		(FileStream isAFileNamed: (directory / ThumbnailFileName) fullName)
			ifFalse: [^ self]].

	[	directory delete: ThumbnailFileName.  "delete may fail if directory is read-only or is an alias"
		((dict size > 0) or: [directory exists: ThumbnailFileName]) ifTrue: [
			f := (FileStream fileNamed: (directory / ThumbnailFileName) fullName) binary.
			ObjStream new storeObj: dict on: f.
			f close].
	] ifError: [].

]
