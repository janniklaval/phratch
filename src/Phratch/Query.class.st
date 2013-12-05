"
I am the abstract class used to retrieve the concrete handler for the specification provided.

I am the root of a command pattern. See my subclasses for concrete implementation.

My entry point is on class side, #from:on:
"
Class {
	#name : #Query,
	#superclass : #Object,
	#instVars : [
		'blockSpec',
		'model'
	],
	#category : #'Phratch-DefaultArguments'
}

{ #category : #private }
Query class >> findHandlerFor: aSelector with: wrapper on: anObject [
	| class |
	
	class := self allSubclasses detect: [ :e | e handlesQuery: aSelector ] ifNone: [ self ].
	^ class with: wrapper on: anObject
]

{ #category : #protocol }
Query class >> from: wrapper on: anObject [
	
	| selector |
	selector := wrapper selector.
	
	^ self findHandlerFor: selector with: wrapper on: anObject
]

{ #category : #'instance creation' }
Query class >> with: blockSpec on: anObject [

	^ self new
		blockSpec: blockSpec;
		model: anObject;
		yourself 
]

{ #category : #accessing }
Query >> blockSpec: anObject [
	
	blockSpec := anObject
]

{ #category : #protocol }
Query >> defaultArguments [

	^ blockSpec copyFrom: 5 to: blockSpec size.
]

{ #category : #accessing }
Query >> model [
	
	^ model
]

{ #category : #accessing }
Query >> model: anObject [
	
	model := anObject
]

{ #category : #protocol }
Query >> stopTalkThinkAsk [

	^ self
]
