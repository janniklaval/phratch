Extension { #name : #WatcherMorph }

{ #category : #'*PhratchObjStream' }
WatcherMorph >> fieldsVersion [

	^ 5

]

{ #category : #'*PhratchObjStream' }
WatcherMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		titleMorph
		readout
		readoutFrame
		phratchSlider
		watcher) from: anObjStream.
	watcher ifNotNil: [watcher useRoundedCorners].
	classVersion = 1 ifTrue: [^ self].
	
	"fields added in version 2"
	self initFieldsNamed: #(
		isSpriteSpecific
	) from: anObjStream.

	"fields added in version 4"
	classVersion < 4 ifTrue: [^ self].
	self initFieldsNamed: #(
		sliderMin
		sliderMax
	) from: anObjStream.

	"fields added in version 5"
	classVersion < 5 ifTrue: [^ self].
	self initFieldsNamed: #(
		isLarge
		isColor
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
WatcherMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		titleMorph
		readout
		readoutFrame
		phratchSlider
		watcher
		isSpriteSpecific
		sliderMin
		sliderMax
		isLarge
		isColor
	) on: anObjStream.
	      

]
