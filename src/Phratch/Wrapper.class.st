Class {
	#name : #Wrapper,
	#superclass : #Object,
	#instVars : [
		'data'
	],
	#category : #'Phratch-DefaultArguments'
}

{ #category : #'instance creation' }
Wrapper class >> with: anObject [

	^ self new 
		data: anObject; 
		yourself
]

{ #category : #accessing }
Wrapper >> data [
	
	^ data
]

{ #category : #accessing }
Wrapper >> data: anObject [
	
	data := anObject
]

{ #category : #accessing }
Wrapper >> selector [
	^ self subclassResponsibility 
]

{ #category : #accessing }
Wrapper >> size [

	^ self data size
]
