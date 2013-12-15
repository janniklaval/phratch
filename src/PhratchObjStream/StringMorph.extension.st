Extension { #name : #StringMorph }

{ #category : #'*PhratchObjStream' }
StringMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
StringMorph >> initFieldsFrom: anObjStream version: classVersion [
	| fontSpec |
	super initFieldsFrom: anObjStream version: classVersion.
	fontSpec := anObjStream nextField.
	fontSpec ifNotNil: [ font := StrikeFont fontName: fontSpec first size: fontSpec second ].
	self initFieldsNamed: #(#emphasis #contents) from: anObjStream
]

{ #category : #'*PhratchObjStream' }
StringMorph >> storeFieldsOn: anObjStream [

	self closeEditor.
	super storeFieldsOn: anObjStream.
	font
		ifNil: [anObjStream putField: nil]
		ifNotNil: [anObjStream putField: (Array with: font name with: font pointSize)].
	self storeFieldsNamed: #(
		emphasis
		contents
	) on: anObjStream.

]
