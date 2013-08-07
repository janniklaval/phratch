Class {
	#name : #StringElementMorph,
	#superclass : #StringMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #editing }
StringElementMorph >> launchMiniEditor: evt [

	| textMorph |

	hasFocus := true.  "Really only means edit in progress for this morph"
	textMorph := StringMorphEditor new contentsAsIs: contents.
	textMorph color: self color.
	textMorph beAllFont: self font.
	textMorph bounds: (self bounds expandBy: 0@2).
	self addMorphFront: textMorph.
	evt hand newMouseFocus: textMorph.
	evt hand newKeyboardFocus: textMorph.
	textMorph editor selectFrom: 1 to: textMorph paragraph text string size.
	textMorph mouseDown: evt.

]
