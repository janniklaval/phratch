Class {
	#name : #BlockType,
	#superclass : #PhratchBlockMorphBuilder,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
BlockType class >> initBlock: aBlock on: aScriptablePhratchMorph withSpec: spec color: blockColor [

	|blockLabelSpec argPermutation selector defaultArgs rcvr|
	blockLabelSpec := PhratchTranslator translationFor: (spec at: 1).
	argPermutation := CommandBlockMorph argPermutationForSpec: (spec at: 1) withTranslation: blockLabelSpec.
	selector := (spec at: 3) asSymbol.
	defaultArgs := aScriptablePhratchMorph defaultArgsFor: spec.
	
	rcvr := (ScriptablePhratchMorph isSpriteSpecificTarget: aScriptablePhratchMorph selector: selector)
		ifTrue: [ aScriptablePhratchMorph ]
		ifFalse: [ aScriptablePhratchMorph ownerOrYourselfThatIsA: PhratchStageMorph ].
		
	^ aBlock
		argPermutation: argPermutation;
		color: blockColor;
		selector: selector;
		commandSpec: blockLabelSpec;
		defaultArgs: defaultArgs;
		receiver: rcvr;
		yourself
]

{ #category : #'as yet unclassified' }
BlockType >> initialize [ 

	^super initialize
]
