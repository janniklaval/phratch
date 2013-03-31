"
I define the behavior common to all Scratch media objects. There are subclasses of me for still images, movies, and sounds.

All media objects have an editable name.

"
Class {
	#name : #PhratchMedia,
	#superclass : #Object,
	#instVars : [
		'mediaName'
	],
	#category : #'Phratch-Objects'
}

{ #category : #accessing }
PhratchMedia >> infoString [
	"Answer a string for this media, typically something about its size."

	self subclassResponsibility

]

{ #category : #'object i/o' }
PhratchMedia >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		mediaName
	) from: anObjStream.

]

{ #category : #initialization }
PhratchMedia >> initialize [

	super initialize.
	mediaName := 'untitled'.

]

{ #category : #accessing }
PhratchMedia >> isImage [
	"Answer true if I am an image media object."

	^ false

]

{ #category : #accessing }
PhratchMedia >> isMovie [
	"Answer true if I am a movie media object."

	^ false

]

{ #category : #accessing }
PhratchMedia >> isSound [
	"Answer true if I am a sound media object."

	^ false

]

{ #category : #accessing }
PhratchMedia >> mediaName [

	^ mediaName

]

{ #category : #accessing }
PhratchMedia >> mediaName: aString [

	mediaName := aString.

]

{ #category : #accessing }
PhratchMedia >> mediaSizeInKilobytes [
	"Returns the storage size of this media in kilobytes, rounded to the nearest kilobyte."

	^ 0

]

{ #category : #playing }
PhratchMedia >> mediaStep [
	"Do one animation or movie step and answer true if my appearance has changed. This default implementation does nothing."

	^ false

]

{ #category : #accessing }
PhratchMedia >> mediaType [
	"Answer a string describing this type of media."

	^ 'generic'

]

{ #category : #printing }
PhratchMedia >> printOn: aStream [

	aStream nextPutAll: mediaName, ' [', self mediaType, ']'.

]

{ #category : #playing }
PhratchMedia >> resumePlaying [
	"This method is called when switching costumes to resume playing a costume that was playing when it was switched out. This default implementaton does nothing."
]

{ #category : #accessing }
PhratchMedia >> revertToUncompressed [
	"Revert to my uncompressed version after temporary compression (e.g. when uploading a project). This default implementation does nothing."
]

{ #category : #playing }
PhratchMedia >> startPlaying [
	"Start playing if I am a movie or animation."

]

{ #category : #playing }
PhratchMedia >> stopPlaying [
	"Stop playing if I am a movie or animation."

]

{ #category : #'object i/o' }
PhratchMedia >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		mediaName
	) on: anObjStream.

]

{ #category : #playing }
PhratchMedia >> suspendPlaying [
	"This method is called when switching costumes to suspect a playing costume. This default implementaton does nothing."
]

{ #category : #accessing }
PhratchMedia >> thumbnailFormExtent: extent [
	"Answer a Form of the given extent containing a thumbnail of me. This default implementation answers a blank thumbnail."

	^ (ColorForm extent: extent depth: 2) fillWhite

]
