"
I am a Scratch image media object. I hold a still image that can be used as the costume for a Scratch object.

Instance variables:
	form			my form
	rotationCenter	my rotation center
	textBox			optional text layer
	jpegBytes		optional JPEG data for this image if it was compressed
	compositeForm	form that combines my base form with my text layer; same as form if no text

When there is no text layer and the image contains no transparent pixels, it can be compressed using JPEG. In that case, jpegBytes contains the compressed image and form is just a cache of decompressed image. If the image is not edited, the original jpegBytes are retained and saved with the project to avoid losing quality through repeated compress/decompress cycles.

When there is a text layer, compositeForm caches the base form with the text painted on top of it. This composite image is saved with the project to allow the Java player to use it. (Since the Java player does not have the same set of fonts as Scratch, it is not possible for it to recreate the compositeForm.)

"
Class {
	#name : #ImageMedia,
	#superclass : #PhratchMedia,
	#instVars : [
		'form',
		'rotationCenter',
		'textBox',
		'jpegBytes',
		'compositeForm',
		'savedForm'
	],
	#classVars : [
		'JPEGPlaceholderForm'
	],
	#category : #'Phratch-Objects'
}

{ #category : #accessing }
ImageMedia >> compositeForm [
	"Answer my composite form, which is my form with the text painted on top of it."

	compositeForm ifNotNil: [^ compositeForm].
	self hasTextLayer ifFalse: [^ compositeForm := form].

	compositeForm := Form extent: form extent depth: 32.
	form displayOn: compositeForm.
	textBox
		suppressAntiAliasing: true;
		drawTextOn: ((FormCanvas on: compositeForm) copyOffset: textBox topLeft).

	^ compositeForm

]

{ #category : #copying }
ImageMedia >> copy [
	"Return a copy of me with a copy of my textbox."

	^ self shallowCopy textBox: textBox copy

]

{ #category : #other }
ImageMedia >> exportFilename: fileName for: stageOrSprite [
	"Export my image to a file with the given name. Save sprite costumes as GIF's, dropping color resolution if necessary."

	| myForm f fName |
	myForm := self compositeForm.

	"save as GIF if image has under 256 colors"
	((myForm depth <= 8) or: [myForm couldBeColorReduced]) ifTrue: [
		f := myForm colorReduced8Bit.
		(fileName asLowercase endsWith: '.gif')
			ifTrue: [fName := fileName]
			ifFalse: [fName := fileName, '.gif'].
		GIFReadWriter putForm: f onFileNamed: fName.
		^ self].

	"otherwise, save as BMP to retain color resolution"
	(fileName asLowercase endsWith: '.bmp')
		ifTrue: [fName := fileName]
		ifFalse: [fName := fileName, '.bmp'].

	(stageOrSprite isKindOf: PhratchSpriteMorph)
		ifTrue: [
			f := Form extent: myForm extent depth: 32.
			f fillColor: Color white.  "BMP cannot handle transparency; use white as BG color"
			myForm displayOn: f at: form offset negated rule: Form paint]
		ifFalse: [
			f := myForm asFormOfDepth: 32].

	f writeBMPFileNamed: fileName.

]

{ #category : #'object i/o' }
ImageMedia >> fieldsVersion [

	^ 4

]

{ #category : #accessing }
ImageMedia >> form [

	^ form

]

{ #category : #accessing }
ImageMedia >> form: aForm [

	form := aForm.
	form couldBeColorReduced
		ifTrue: [form := form colorReduced].  "reduce color depth to save space"

	rotationCenter := form extent // 2.
	jpegBytes := compositeForm := nil.

]

{ #category : #accessing }
ImageMedia >> hasTextLayer [
	"Return true if I have a text layer."

	^ textBox notNil and: [textBox contents size > 0]

]

{ #category : #accessing }
ImageMedia >> infoString [
	"Answer a string for this media, typically something about its size."

	^ form width printString, 'x', form height printString

]

{ #category : #'object i/o' }
ImageMedia >> initFieldsFrom: anObjStream version: classVersion [

	| f |
	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		form
		rotationCenter 
	) from: anObjStream.

	(form isKindOf: ColorForm) ifTrue: [  "convert ColorForm to 32-bit color"
		f := Form extent: form extent depth: 32.
		form displayOn: f.
		form := f].

	compositeForm := jpegBytes := nil.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		textBox
	) from: anObjStream.

	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		jpegBytes
	) from: anObjStream.
	jpegBytes ifNotNil: [form := FastJPEG uncompress: jpegBytes].

	classVersion = 3 ifTrue: [^ self].

	"fields added in version 4"
	self initFieldsNamed: #(
		compositeForm
	) from: anObjStream.

]

{ #category : #initialization }
ImageMedia >> initialize [

	super initialize.
	mediaName := 'costume' localized, '1'.
	form := (Form extent: 8@8 depth: 4) fillWhite.
	rotationCenter := form extent // 2.	"relative to the top-left corner of the Form"
	textBox := nil.
	jpegBytes := nil.
	compositeForm := nil.

]

{ #category : #accessing }
ImageMedia >> isImage [
	"Answer true if I am an image media object."

	^ true

]

{ #category : #accessing }
ImageMedia >> jpegBytes [

	^ jpegBytes

]

{ #category : #other }
ImageMedia >> jpegCompressIfPossibleQuality: quality [
	"Attempt to compress my form using JPEG at the given quality level. If successful, save the compressed JPEG data in my jpegBytes instance variable. If JPEG compression does not yield a sufficient savings, then set jpegBytes to nil. If jpegBytes is non-nil when I am saved, then my form will not be saved and the form will be reconstructed from the JPEG data when this media is read back in. Answer true if JPEG compression was done."

	| oldSz tally |
	jpegBytes ifNotNil: [^ false].

	form unhibernate.
	(form isKindOf: ColorForm)
		ifTrue: [
			(form colorsUsed includes: Color transparent) ifTrue: [^ false]]
		ifFalse: [
			form depth > 1 ifTrue: [
				tally := form tallyPixelValues.
				(tally at: 1) > 0 ifTrue: [^ false]]].  "contains transparent pixels"

	"no transparency; attempt jpeg compression"
	form hibernate.
	oldSz := form bits size.
	jpegBytes := FastJPEG compress: form quality: quality.
	jpegBytes size <= (oldSz // 3)
		ifFalse: [jpegBytes := nil].  "not enough savings; don't use JPEG"

	^ jpegBytes notNil

]

{ #category : #other }
ImageMedia >> jpegCompressIfPossibleQuality: quality saveOriginal: saveFlag [
	"Attempt to compress my form using JPEG at the given quality level. if saveFlag is true and I was not previously compressed, save my original (pre-compression) image so that compression can be undone later (e.g. after uploading the project)."

	| wasCompressed |
	saveFlag & quality notNil
		ifTrue: [savedForm := form]
		ifFalse: [savedForm := nil].

	wasCompressed := self jpegCompressIfPossibleQuality: quality.

	wasCompressed & saveFlag not ifTrue: [
		"show the result of doing the compression"
		form := FastJPEG uncompress: jpegBytes.
		compositeForm := nil].

	^ wasCompressed

]

{ #category : #accessing }
ImageMedia >> mediaSizeInKilobytes [
	"Returns the storage size of this media in kilobytes, rounded to the nearest kilobyte."

	| bytes |
	bytes := 0.
	jpegBytes
		ifNil: [form hibernate. bytes := form bits size]
		ifNotNil: [bytes := jpegBytes size].
	self hasTextLayer ifTrue: [
		self compositeForm hibernate.
		bytes := bytes + compositeForm bits size].

	bytes < 1024 ifTrue: [
		 ^ (bytes / 1024) roundTo: 0.01].

	^ (bytes + 512) // 1024

]

{ #category : #accessing }
ImageMedia >> mediaType [
	"Answer a string describing this type of media."

	^ 'image'

]

{ #category : #other }
ImageMedia >> revertToUncompressed [
	"Revert to my original, uncompressed Form after compression with the 'saveOriginal' flag."

	savedForm ifNotNil: [
		form := savedForm.
		compositeForm := nil.
		jpegBytes := nil.
		savedForm := nil].

]

{ #category : #accessing }
ImageMedia >> rotationCenter [

	^ rotationCenter

]

{ #category : #accessing }
ImageMedia >> rotationCenter: aPoint [

	rotationCenter := aPoint.

]

{ #category : #accessing }
ImageMedia >> savedForm [

	^ savedForm

]

{ #category : #other }
ImageMedia >> shareFormWith: anImageMedia [
	"Share the same form object with the given image media object."

	form := anImageMedia form.
	jpegBytes := anImageMedia jpegBytes.
	savedForm := anImageMedia savedForm.

]

{ #category : #'object i/o' }
ImageMedia >> storeFieldsOn: anObjStream [

	| oldForm f |
	super storeFieldsOn: anObjStream.

	oldForm := form.

	compositeForm := nil.
	self hasTextLayer ifTrue: [
		compositeForm := self compositeForm hibernateForScratch.
		compositeForm couldBeColorReduced ifTrue: [
			f := compositeForm colorReduced hibernateForScratch.
			(f bits size < compositeForm bits size) ifTrue: [compositeForm := f]]].

	jpegBytes
		ifNil: [form := form hibernateForScratch]
		ifNotNil: [form := JPEGPlaceholderForm].

	self storeFieldsNamed: #(
		form
		rotationCenter
		textBox
		jpegBytes
		compositeForm
	) on: anObjStream.

	form := oldForm.
	compositeForm := nil.

]

{ #category : #accessing }
ImageMedia >> textBox [

	^ textBox

]

{ #category : #accessing }
ImageMedia >> textBox: aMultilineStringMorphOrNil [

	textBox := aMultilineStringMorphOrNil.

]

{ #category : #accessing }
ImageMedia >> thumbnailFormExtent: extent [
	"Answer a Form of the given extent containing a thumbnail of me."

	| f compositeF scale shrunk |
	f := (ColorForm extent: extent depth: 16) fillColor: Color transparent.
	form ifNotNil: [
		compositeF := self compositeForm.
		scale := (f width / compositeF width) min: (f height / compositeF height).
		scale < 1
			ifTrue: [
				shrunk := (compositeF asFormOfDepth: 16)
					magnify: compositeF boundingBox
					by: scale
					smoothing: 2]
			ifFalse: [
				shrunk := compositeF].

		shrunk displayOn: f at: (f extent - shrunk extent) // 2 rule: Form paint].
	^ f

]
