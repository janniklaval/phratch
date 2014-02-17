Extension { #name : #Object }

{ #category : #'*PhratchObjStream' }
Object >> initFieldsNamed: varList from: anObjStream [
	"Initialize my instance variables in the given list from the given object stream."

	| allVars |
	allVars := self class allInstVarNames.
	varList do: [:varName |
		(allVars includes: varName) 
			ifFalse: [self initObsoleteFieldNamed: varName from: anObjStream]
			ifTrue: [self instVarAt: (allVars indexOf: varName) put: anObjStream nextField]].

]

{ #category : #'*PhratchObjStream' }
Object >> initObsoleteFieldNamed: varName from: anObjStream [

	"|value |"
	"value := "anObjStream nextField.
	"self setProperty: varName toValue: value."
	 Transcript show: self; show: ' >> '; show: varName; cr.

]

{ #category : #'*PhratchObjStream' }
Object >> storeFieldsNamed: varList on: anObjStream [
	"Store the instance variables in the given list on the given object stream."

	| allVars |
	allVars := self class allInstVarNames.
	varList do: [:varName |
		
		(allVars includes: varName) ifFalse: [anObjStream putField: nil]
			ifTrue: [
		
		anObjStream putField: (self instVarAt: (allVars indexOf: varName))]].

]
