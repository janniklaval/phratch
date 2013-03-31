Class {
	#name : #UnevaluatedExpressionArgMorph,
	#superclass : #ExpressionArgMorph,
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
UnevaluatedExpressionArgMorph >> evaluate [

	"empty slot and implicit values need yet to be supported"

	| lambdafy |

	lambdafy := [:xpr |
		| rcv answerBlock reportBlock bool |
		rcv := owner receiver.
		rcv ifNil: [rcv := ScriptableScratchMorph new].
		answerBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #procedure) 
									color: (ScriptableScratchMorph blockColorFor: 'operators').
		answerBlock isAtomic: true.
		reportBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #doAnswer) 
									color: (ScriptableScratchMorph blockColorFor: 'control').
		(xpr isKindOf: Boolean)
			ifTrue: [
				xpr
					ifTrue: [bool := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #getTrue) 
									color: (ScriptableScratchMorph blockColorFor: 'operators').]
					ifFalse: [bool := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #getFalse) 
									color: (ScriptableScratchMorph blockColorFor: 'operators').].
				reportBlock replaceArgMorph: reportBlock argMorphs first by: bool]
			ifFalse: [reportBlock argMorphs first defaultValue: xpr].
		answerBlock attachBlock: reportBlock.
		answerBlock ].

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [ (implicitValue isKindOf: LambdaBlockMorph)
			ifTrue: [ ^implicitValue]
			ifFalse: [ ^ lambdafy value: implicitValue ]].

	^ lambdafy value: labelMorph savedContents


]

{ #category : #'as yet unclassified' }
UnevaluatedExpressionArgMorph >> initialize [

	super initialize.
	isNumber := false.

]
