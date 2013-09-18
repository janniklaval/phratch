Class {
	#name : #MessageHeaderElementMorph,
	#superclass : #PaletteElementMorph,
	#instVars : [
		'selector',
		'labels',
		'arguments'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #converting }
MessageHeaderElementMorph >> asSmalltalk [
	| kw ws |
	kw := selector keywords.
	ws := WriteStream on: String new.
	1 to: kw size do: [:i|
		ws nextPutAll: (kw at: i).
		(variables size < i) ifFalse: [
			ws nextPutAll: ' ', (variables at: i) asSmalltalk, ' ' ]].
	^ws contents
]

{ #category : #'instance creation' }
MessageHeaderElementMorph >> beBinary [
	self selector: selector arguments: #(arg)
]

{ #category : #menu }
MessageHeaderElementMorph >> contextMenu [
	| m |
	m := MenuMorph new.
	m add: 'rename...' translated action: #editSelector.
	arguments isEmpty
		ifTrue: [ m add: 'add argument' translated action: #beBinary ].
	^ m
]

{ #category : #'instance creation' }
MessageHeaderElementMorph >> editSelector [
	|ans parms tokens|

	parms := OrderedCollection new.
	ans := UIManager default request: 'selector:' initialAnswer: selector.
	ans isEmpty ifTrue: [^self].
	ans := (SyntaxElementMorph selectorFrom: ans) asString.
	(ans includes: ($:)) ifFalse: [
		^self selector: ans arguments: #() ].

	tokens := ans findTokens: ':'.
	1 to: tokens size do: [:i |
		parms add: 'arg', i printString ].

	self selector: ans arguments: parms.
]

{ #category : #private }
MessageHeaderElementMorph >> fit [
	| cw bw bw2 x arg lb maxHeight |

	labels ifNil: [^self].
	cw := (self labelFont widthOf: $ ) // 2.
	bw := self borderWidth.
	bw2 := bw * 2.

	x := self left + bw.
	maxHeight := self labelFont height.

	1 to: labels size do: [:i |
		lb := labels at: i.
		lb position: x @ self center y.
		x := lb right + cw.
		(variables size >= i)
			ifTrue: [
				arg := variables at: i.
				maxHeight := maxHeight max: arg height.
				arg position: x @ self center y.
				x := arg right + cw]].

	self extent: (x - self position x - cw - bw2) @ maxHeight + (bw2 * 2).
	variables do: [:each|
		each position: (each position x @ (bounds center y - (each height // 2))) ].
	labels do: [:each|
		each position: (each position x @ (bounds center y - (each height // 2))) ].

	(owner respondsTo: #fit)
		ifTrue: [^owner fit]
]

{ #category : #initialize }
MessageHeaderElementMorph >> initialize [
	super initialize.
	labels := OrderedCollection new.
	variables := OrderedCollection new.
	self fit
]

{ #category : #private }
MessageHeaderElementMorph >> labelColor [
	^Color black
]

{ #category : #private }
MessageHeaderElementMorph >> labelFont [
	^StrikeFont fontName: 'VerdanaBold' size: 10
]

{ #category : #accessing }
MessageHeaderElementMorph >> selector [
	^selector
]

{ #category : #'instance creation' }
MessageHeaderElementMorph >> selector: aString arguments: anArray [

	"for decompilation purposes only. Caution: this method assumes that the number of arguments matches the
	number of parameters required by the selector."
	| tokens lb arg |

	selector := aString.

	label ifNotNil: [label delete. label := nil].
	labels do: [:each| each delete ].
	labels := OrderedCollection new.
	arguments := anArray.
	variables do: [:each| each delete ].
	variables := OrderedCollection new.

	tokens := selector findTokens: ':'.
	1 to: tokens size do: [:i |
		lb := ((StringMorph 
				contents: (self wordsFrom: (tokens at: i)) 
				font: self labelFont) 
				color: self labelColor).
		labels add: lb.
		self addMorph: lb.
		(anArray size < i) ifFalse: [
			arg := ObjectElementMorph new label: (anArray at: i) asString.
			arg color: owner color twiceDarker.
			variables add: arg.
			self addMorph: arg]].

	self fit

]
