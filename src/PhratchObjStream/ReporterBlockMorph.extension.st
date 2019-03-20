Extension { #name : #ReporterBlockMorph }

{ #category : #'*PhratchObjStream' }
ReporterBlockMorph >> fieldsVersion [

	^ 2

]

{ #category : #'*PhratchObjStream' }
ReporterBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		isBoolean
	) from: anObjStream.


]
