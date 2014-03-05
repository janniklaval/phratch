"
I am the abstract class used to retrieve the concrete handler for the specification provided.

I am the root of a command pattern. See my subclasses for concrete implementation.

My entry point is on class side, #from:on:

It gives the default arguments of a block. By default, the default arguments is the 5th element of a block spec. But for some block, it is different.
"
Class {
	#name : #PhratchCommandHandler,
	#superclass : #Object,
	#instVars : [
		'blockSpec',
		'model'
	],
	#category : #'Phratch-DefaultArguments'
}

{ #category : #private }
PhratchCommandHandler class >> findHandlerFor: aSelector with: wrapper on: anObject [
	| class |
	
	class := self allSubclasses detect: [ :e | e handlesQuery: aSelector ] ifNone: [ self ].
	^ class with: wrapper on: anObject
]

{ #category : #protocol }
PhratchCommandHandler class >> from: wrapper on: anObject [
	
	| selector |
	selector := wrapper selector.
	
	^ self findHandlerFor: selector with: wrapper on: anObject
]

{ #category : #'instance creation' }
PhratchCommandHandler class >> with: blockSpec on: anObject [

	^ self new
		blockSpec: blockSpec;
		model: anObject;
		yourself 
]

{ #category : #accessing }
PhratchCommandHandler >> blockSpec: anObject [
	
	blockSpec := anObject
]

{ #category : #protocol }
PhratchCommandHandler >> defaultArguments [

	^ blockSpec copyFrom: 5 to: blockSpec size.
]

{ #category : #accessing }
PhratchCommandHandler >> model [
	
	^ model
]

{ #category : #accessing }
PhratchCommandHandler >> model: anObject [
	
	model := anObject
]

{ #category : #protocol }
PhratchCommandHandler >> stopTalkThinkAsk [

	^ self
]
