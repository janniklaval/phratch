Extension { #name : #CommandBlockMorph }

{ #category : #'*Phratch-DefaultArguments' }
CommandBlockMorph >> asArgumentWrapper [

	^ ExpressionWrapper with: self
]

{ #category : #'*Phratch-objects' }
CommandBlockMorph >> changeLabel [
	| tokens args nextArgIndex m next slot |
	commandSpec ifNil: [ ^ self ].	"we make sure not to remove the next block."
	next := self nextBlock.
	"self isCBlockMorph ifTrue:[next := super nextBlock.]."
	
	self removeAllMorphsIn: (self submorphs reject: [ :t | t = next or:[t isBlockMorph]]).
	tokens := CommandBlockMorph parseCommandSpec: commandSpec.
	args := tokens select: [ :s | CommandBlockMorph isArgSpec: s ].	"remove any excess arg morphs from the list."
	[ argMorphs size > args size ]
		whileTrue: [ 
			m := argMorphs last.
			argMorphs remove: m.	"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
			(m isBlockMorph)
				ifTrue: [ m openInWorld ] ].	"create new arg morphs."
	[ argMorphs size < args size ] whileTrue: [ argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1)) ].
	nextArgIndex := 1.
	tokens
		do: [ :s | 
			(CommandBlockMorph isArgSpec: s)
				ifTrue: [ 
					"check if the arg type has changed (jens)"
					m := argMorphs at: nextArgIndex.
					(m isArgMorph)
						ifTrue: [ 
							slot := self uncoloredArgMorphFor: s.
							m class = slot class
								ifFalse: [ 
									m := slot.
									argMorphs at: nextArgIndex put: m ] ].
					nextArgIndex := nextArgIndex + 1 ]
				ifFalse: [ m := self labelMorphFor: s ].
			self addMorphBack: m ].
	self isReporter
		ifFalse: [ ^ self ].
	m := submorphs last.
	(m isChoiceArgMorph) | (m isSpriteArgMorph)
		ifTrue: [ 
			"add spacer"
			self
				addMorphBack:
					(Morph new
						color: Color transparent;
						extent: 2 @ 5;
						yourself) ]
]

{ #category : #'*Phratch-objects' }
CommandBlockMorph >> changeLanguageString [

	self hasSubmorphs ifTrue:[self submorphsDo: [:sm | sm changeLanguageString]].
	self translateCommandSpec: (PhratchTranslator translationFor: (PhratchTranslator englishTranslationFor: self commandSpec))
]

{ #category : #'*Phratch-objects' }
CommandBlockMorph >> translateCommandSpec: aString [

	commandSpec := aString.
	numberArgFlags := nil.
	self changeLabel.
	self addCommandIcons.
]
