Class {
	#name : #TypeInReporterSlotMorph,
	#superclass : #OSlotMorph,
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
TypeInReporterSlotMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg |
	
	blockTuple := Array new: 4.
	blockTuple
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: selector.

	arg := self nestedBlock.
	(arg isKindOf: ReporterBlockMorph)
		ifTrue: [blockTuple at: 4 put: (Array with: argMorphs first asBlockTuple)]
		ifFalse: [blockTuple at: 4 put: arg evaluate]. 
	^ blockTuple
]

{ #category : #'as yet unclassified' }
TypeInReporterSlotMorph >> evaluate [

	"empty slot and implicit values need yet to be supported"

	| rcv answerBlock reportBlock |

	(submorphs first isKindOf: ExpressionArgMorph)
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
		commandSpec: '%s'.
	answerBlock argMorphs first defaultValue: submorphs first evaluate.
	^ answerBlock
"
]

{ #category : #'as yet unclassified' }
TypeInReporterSlotMorph >> initialize [
	super initialize.
	self selector: #typeInLambda.
	self commandSpec: '%s'.
	removeElementMorph ifNotNil: [
		removeElementMorph delete]
]

{ #category : #'as yet unclassified' }
TypeInReporterSlotMorph >> isEmptySlot [

	(argMorphs first isKindOf: ExpressionArgMorph) ifTrue: [
		^ argMorphs first isEmptySlot].

	^ super isEmptySlot
]
