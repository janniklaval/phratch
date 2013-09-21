Extension { #name : #Object }

{ #category : #'*Phratch-Extensions' }
Object >> asArgString [
	^ self asString
]

{ #category : #'*Phratch-Extensions' }
Object >> asNumberNoError [
	"This message is intended to be sent to strings, booleans, and numbers. This method is a backstop in case some other type of object receives this message."

	^ 0

]

{ #category : #'*Phratch-Extensions' }
Object >> inform: informationString withDetails: detailsString [
	"Put up a DialogBox to give the user an informational message and wait until they click the 'ok' button before proceeding."

	DialogBoxMorph inform: informationString withDetails: detailsString.
]

{ #category : #'*Phratch-Extensions' }
Object >> initFieldsNamed: varList from: anObjStream [
	"Initialize my instance variables in the given list from the given object stream."

	| allVars |
	allVars := self class allInstVarNames.
	varList do: [:varName |
		(allVars includes: varName) 
			ifFalse: [self initObsoleteFieldNamed: varName from: anObjStream]
			ifTrue: [self instVarAt: (allVars indexOf: varName) put: anObjStream nextField]].

]

{ #category : #'*Phratch' }
Object >> initObsoleteFieldNamed: varName from: anObjStream [

	"|value |"
	"value := "anObjStream nextField.
	"self setProperty: varName toValue: value."
	 Transcript show: self; show: ' >> '; show: varName; cr.

]

{ #category : #'*Phratch-Extensions' }
Object >> storeFieldsNamed: varList on: anObjStream [
	"Store the instance variables in the given list on the given object stream."

	| allVars |
	allVars := self class allInstVarNames.
	varList do: [:varName |
		
		(allVars includes: varName) ifFalse: [anObjStream putField: nil]
			ifTrue: [
		
		anObjStream putField: (self instVarAt: (allVars indexOf: varName))]].

]
