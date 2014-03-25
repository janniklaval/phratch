Class {
	#name : #TypeInReporterSlotMorph,
	#superclass : #OSlotMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'argument slot behavior' }
TypeInReporterSlotMorph >> evaluate [

	"empty slot and implicit values need yet to be supported"

	| rcv answerBlock reportBlock |

	(submorphs first isExpressionArgMorph)
		ifFalse: [^ super evaluate].

	rcv := self receiver.
	rcv ifNil: [rcv := ScriptablePhratchMorph new].
	answerBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #procedure) 
							color: (ScriptablePhratchMorph blockColorFor: 'operators').
	answerBlock isAtomic: true.
	reportBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #doAnswer) 
							color: (ScriptablePhratchMorph blockColorFor: 'control').
	reportBlock argMorphs first defaultValue: submorphs first evaluate.
	answerBlock attachBlock: reportBlock.
	^ answerBlock

"

	answerBlock := ReporterBlockMorph new.
	answerBlock
		isSpecialForm: true;
		selector: #doAnswer;
		commandSpec: '$String$'.
	answerBlock argMorphs first defaultValue: submorphs first evaluate.
	^ answerBlock
"
]

{ #category : #initialization }
TypeInReporterSlotMorph >> initialize [
	super initialize.
	self selector: #typeInLambda.
	self commandSpec: '$String$'.
	removeElementMorph ifNotNil: [
		removeElementMorph delete]
]

{ #category : #'argument slot behavior' }
TypeInReporterSlotMorph >> isEmptySlot [

	(argMorphs first isExpressionArgMorph) ifTrue: [
		^ argMorphs first isEmptySlot].

	^ super isEmptySlot
]
