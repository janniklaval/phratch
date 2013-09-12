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
Query class >> findHandlerFor: aSelector with: blockSpec on: anObject [
	| class |
	
	class := self allSubclasses detect: [ :e | e handlesQuery: aSelector ] ifNone: [ self ].
	^ class with: blockSpec on: anObject
]

{ #category : #protocol }
Query class >> from: blockSpec on: anObject [
	
	| selector |
	selector := (blockSpec at: 3) asSymbol.
	
	^ self findHandlerFor: selector with: blockSpec on: anObject
]

{ #category : #'instance creation' }
Query class >> with: blockSpec on: anObject [

	^ self new
		blockSpec: blockSpec;
		model: anObject;
		yourself 
]

{ #category : #accessing }
Query >> blockSpec [
	
	^ blockSpec
]

{ #category : #accessing }
Query >> blockSpec: anObject [
	
	blockSpec := anObject
]

{ #category : #protocol }
Query >> defaultArguments [

	^  blockSpec copyFrom: 4 to: blockSpec size.
]

{ #category : #accessing }
Query >> model [
	
	^ model
]

{ #category : #accessing }
Query >> model: anObject [
	
	model := anObject
]
