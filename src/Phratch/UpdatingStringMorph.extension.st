Extension { #name : #UpdatingStringMorph }

{ #category : #'*Phratch-Extensions' }
UpdatingStringMorph >> fieldsVersion [
	^ 1
]

{ #category : #'*Phratch-Extensions' }
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

{ #category : #'*Phratch' }
UpdatingStringMorph >> kern: ignored [
]

{ #category : #'*Phratch' }
UpdatingStringMorph >> parameter [

	^ self valueOfProperty: #scratchParameter
]

{ #category : #'*Phratch' }
UpdatingStringMorph >> parameter: anObject [

	self setProperty: #scratchParameter toValue: anObject
]

{ #category : #'*Phratch-Extensions' }
UpdatingStringMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		format
		target
		getSelector
		putSelector
		floatPrecision
		growable
		stepTime
	) on: anObjStream.
]
