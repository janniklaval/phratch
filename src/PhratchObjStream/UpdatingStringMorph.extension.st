Extension { #name : #UpdatingStringMorph }

{ #category : #'*PhratchObjStream' }
UpdatingStringMorph >> fieldsVersion [
	^ 1
]

{ #category : #'*PhratchObjStream' }
UpdatingStringMorph >> initFieldsFrom: anObjStream version: classVersion [
	super initFieldsFrom: anObjStream version: classVersion.
	self
		initFieldsNamed: #(
			#format
			#target
			#getSelector
			#putSelector
			#floatPrecision
			#growable
			#stepTime)
		from: anObjStream
]
