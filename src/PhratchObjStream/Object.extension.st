Extension { #name : #Object }

{ #category : #'*PhratchObjStream' }
Object >> initObsoleteFieldNamed: varName from: anObjStream [

	"|value |"
	"value := "anObjStream nextField.
	"self setProperty: varName toValue: value."
	 Transcript show: self; show: ' >> '; show: varName; cr.

]
