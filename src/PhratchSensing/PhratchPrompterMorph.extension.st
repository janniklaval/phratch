Extension { #name : #PhratchPrompterMorph }

{ #category : #'*PhratchSensing' }
PhratchPrompterMorph >> grabKeyboardFocus [

	World activeHand newKeyboardFocus: typeinMorph.

]

{ #category : #'*PhratchSensing' }
PhratchPrompterMorph class >> lastAnswer: anAnswer [

	LastAnswer := anAnswer

]

{ #category : #'*PhratchSensing' }
PhratchPrompterMorph >> question: aString [
	(aString isMorph)
		ifTrue: [ 
			| frm |
			frm := (aString respondsTo: #displayForm)
				ifTrue: [ aString displayForm ]
				ifFalse: [ aString imageForm ].
			questionMorph := ImageMorph new form: frm ]
		ifFalse: [ 
			questionMorph := StringMorph new
				contents: aString asString;
				font: (PhratchFrameMorph getFont: #DialogBoxButton);
		yourself ].
	self addMorph: questionMorph.
	self height: questionMorph height + typeinMorph height + 16
]

{ #category : #'*PhratchSensing' }
PhratchPrompterMorph >> sprite: aSprite [

	sprite := aSprite.

]
