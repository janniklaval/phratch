Class {
	#name : #UnevaluatedBooleanArgMorph,
	#superclass : #BooleanArgMorph,
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
UnevaluatedBooleanArgMorph >> evaluate [

	"empty slot and implicit values need yet to be supported"

	| lambdafy |

	lambdafy := [:xpr |
		| rcv answerBlock reportBlock bool |
		rcv := owner receiver.
		rcv ifNil: [rcv := ScriptablePhratchMorph new].
		answerBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #procedure) 
									color: (ScriptablePhratchMorph blockColorFor: 'operators').
		answerBlock isAtomic: true.
		reportBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #doAnswer) 
									color: (ScriptablePhratchMorph blockColorFor: 'control').
		(xpr isKindOf: Boolean)
			ifTrue: [
				xpr
					ifTrue: [bool := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #getTrue) 
									color: (ScriptablePhratchMorph blockColorFor: 'operators').]
					ifFalse: [bool := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #getFalse) 
									color: (ScriptablePhratchMorph blockColorFor: 'operators').].
				reportBlock replaceArgMorph: reportBlock argMorphs first by: bool]
			ifFalse: [reportBlock argMorphs first defaultValue: xpr].
		answerBlock attachBlock: reportBlock.
		answerBlock ].

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [ (implicitValue isKindOf: LambdaBlockMorph)
			ifTrue: [ ^implicitValue]
			ifFalse: [ ^ lambdafy value: implicitValue ]].

	^ lambdafy value: false


]
