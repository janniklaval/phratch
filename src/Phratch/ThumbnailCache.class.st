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

	ThumbnailFileName := 'phratchthumbs.db'.

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
	extensions := #(#gif #jpeg #jpg #bmp #png #sprite) asSet.
	imageFiles := directory fileNames select: [ :fn | extensions includes: (directory / fn) extension asSymbol ].
	^ imageFiles reject: [ :fn | dict includesKey: fn ]
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
	hats := #(EventHatMorph StartEventHatMorph KeyEventHatMorph MouseClickEventHatMorph).
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
	"f depth < 16 ifTrue: [f := f asFormOfDepth: 16]."
	scale := (80.0 / f width) min: (60.0 / f height).
	f := f magnifyBy: scale.
	^ f

]

{ #category : #other }
ThumbnailCache >> updateThumbnails [
	"Update my dictionary by creating thumbnails for all the image files in my directory. If updates were needed, try to save save the thumbnails cache."

	| didRemove fList n thumb buf fSize |
	
	didRemove := self removeObsoleteEntries.
	fList := self filesToUpdate.
	fList size > 0
		ifTrue: [ 
			n := 0.
			'Updating thumbnails' localized , PhratchTranslator ellipsesSuffix
				displayProgressAt: Display center
				from: 0
				to: fList size
				during: [ :bar | 
					fList
						do: [ :fn | 
							bar value: n.
							thumb := nil.
							[
							buf := (FileStream readOnlyFileNamed: (directory / fn) fullName) binary contentsOfEntireFile.
							self flag: 'cannot load sprite for now'.
							thumb := (fn asLowercase endsWith: '.sprite') | (fn asLowercase endsWith: '.ysp')
								"ifTrue: [ self thumbnailFromSpriteData: buf ]"
								ifFalse: [ self thumbnailFromImageData: buf ] ] ifError: [ PhratchError error ].
							fSize := fileSizes at: fn ifAbsent: [ 0 ].
							thumb ifNotNil: [ dict at: fn put: (Array with: fSize with: thumb) ].
							n := n + 1 ] ] ].
]
