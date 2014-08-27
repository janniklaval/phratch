Class {
	#name : #CommandNoMouse,
	#superclass : #CommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'event handling' }
CommandNoMouse >> click: evt [
	"If a tool is selected, handle a click with that tool. Otherwise, toggle my process."

	^self 
]
