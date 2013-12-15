Extension { #name : #HatBlockMorph }

{ #category : #'*PhratchObjStream' }
HatBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
HatBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		scriptNameMorph
		indicatorMorph
		scriptOwner
		isClickable
	) from: anObjStream.

	"remove the indicator morph when reading in an older project"
	indicatorMorph ifNotNil: [
		submorphs := submorphs copyWithout: indicatorMorph.
		indicatorMorph := nil].

]

{ #category : #'*PhratchObjStream' }
HatBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		scriptNameMorph
		indicatorMorph
		scriptOwner
		parameters
		isClickable
	) on: anObjStream.

]
