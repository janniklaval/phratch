Extension { #name : #MovieMedia }

{ #category : #'*PhratchObjStream' }
MovieMedia >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
MovieMedia >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		fileName
		fade
		fadeColor
		zoom
		hPan
		vPan
		msecsPerFrame
		currentFrame
		moviePlaying
	) from: anObjStream.
	self openAfterLoad.

]

{ #category : #'*PhratchObjStream' }
MovieMedia >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		fileName
		fade
		fadeColor
		zoom
		hPan
		vPan
		msecsPerFrame
		currentFrame
		moviePlaying
	) on: anObjStream.

]
