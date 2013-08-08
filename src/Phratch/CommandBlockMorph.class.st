"
I represent a command or reporter. I have a label and may also have one or more arguments. The label text, number of arguments, and ordering of arguments and keywords are defined by my commandSpec string. This string consists of a sequence of keywords interspersed with argument specifications that indicate where the arguments appear. Here are some possible argument specifications:

	%b	- boolean
	%c	- color
	%C	- color (chosen with eyedropper, not palette)
	%m	- morph reference
	%n	- number
	%s	- string

Examples:

	%b and %b
	%m's color %C sees %C
	repeat %n times

"
Class {
	#name : #CommandBlockMorph,
	#superclass : #BlockMorph,
	#instVars : [
		'commandSpec',
		'argPermutation',
		'argMorphs',
		'titleMorph',
		'receiver',
		'selector',
		'isTimed',
		'numberArgFlags',
		'key',
		'stopFrame'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
CommandBlockMorph class >> argPermutationForSpec: spec withTranslation: translatedSpec [
	"CommandBlockMorph argPermutationForSpec: '$Attributes$ of $Sprite$ of $Sprite$ of $SAList$' withTranslation: '$Attributes$ de $Sprite$ de $Sprite$ de $SAList$'"
	"CommandBlockMorph argPermutationForSpec: '$Attributes$ of $Sprite$ of $Sprite$ of $SAList$' withTranslation: '$SAList$ de $Sprite$2 de $Sprite$1 de $Attributes$'"

	| parsedSpec parsedTranslatedSpec parsedSpecArgs parsedTranslatedSpecArgs permutation a copiesSize n originalPermutation |

	parsedSpec := CommandBlockMorph parseCommandSpec: spec.
	parsedSpecArgs := parsedSpec select: [ :s | CommandBlockMorph isArgSpec: s ].
	parsedTranslatedSpec := CommandBlockMorph parseCommandSpec: translatedSpec.
	parsedTranslatedSpecArgs := parsedTranslatedSpec select: [ :s | CommandBlockMorph isArgSpec: s ].

	permutation := #().
	1 to: parsedSpecArgs size do: [ :i | permutation := permutation copyWith: i ].
	originalPermutation := permutation.	"no change"
	parsedSpecArgs = parsedTranslatedSpecArgs
		ifTrue: [ ^ originalPermutation ].	"otherwise, calculate permutation"
	1 to: parsedSpecArgs size do: [ :i | 
		a := parsedSpecArgs at: i.
		copiesSize := (parsedSpecArgs select: [ :s | s = a ]) size.
		copiesSize = 1
			ifTrue: [ 
				permutation
					at: i
					put:
						(parsedTranslatedSpecArgs
							indexOf: a
							ifAbsent: [ 
								Transcript
									show: 'Permutation failed: ';
									show: spec.
								^ originalPermutation ]) ]
			ifFalse: [ 
				"count copies until now"
				n := ((parsedSpecArgs copyFrom: 1 to: i) select: [ :s | s = a ]) size.
				permutation
					at: i
					put:
						(parsedTranslatedSpecArgs
							indexOf: a , n asString
							ifAbsent: [ 
								Transcript
									show: 'Permutation failed: ';
									show: spec.
								^ originalPermutation ]) ] ].
	^ permutation

]

{ #category : #utilities }
CommandBlockMorph class >> isArgSpec: aString [
	"Answer true if the given string is an argument specification."
	^ ((aString size > 1) and: [aString first = $$ and:[aString last = $$]])

]

{ #category : #utilities }
CommandBlockMorph class >> parseCommandSpec: aCommandSpec [
	"Answer an array of token strings containing my keywords and argument specs."
	"CommandBlockMorph parseCommandSpec: '$blah$ to $blah$'"

	| result len i j spec k |
	result := OrderedCollection new.
	spec := aCommandSpec.
	len := aCommandSpec size.

	i := 1.
	[(i < len) and: [(spec at: i) isSeparator]] whileTrue: [i := i + 1].
	[i <= len] whileTrue: [
		j := spec indexOf: $$ startingAt: i.
		j > 0
			ifTrue: [
				j > i ifTrue: [result addLast: (spec copyFrom: i to: j - 1)].
				j < len
					ifTrue: [k := j + 1.
						((spec at: k) isLetter | (spec at: k) isDigit)
							ifTrue: [[(k+1 <= len) and: [(spec at: k+1) ~= $$]] whileTrue:[
								k := k + 1].
								(k >= len)
									ifTrue: [result addLast: (spec copyFrom: j to: len).
										i := len + 1]
									ifFalse: [result addLast: (spec copyFrom: j to: k+1).
										i := k+2]]
							ifFalse: [result addLast: '$'.
										i := j + 1]]
					ifFalse: [result addLast: '$'.
						i := j + 2]]
			ifFalse: [
				result addLast: (spec copyFrom: i to: len).
				i := len + 1]].

	result := result select: [:s | s ~= ' '].
	^ result asArray collect: [:s | s trimBoth].
]

{ #category : #byob }
CommandBlockMorph >> addArg: argMorph [
	"private - only for graphical representation in BYOB"

		argMorphs add: argMorph.
		self addMorphBack: argMorph.
		self layoutChanged
]

{ #category : #private }
CommandBlockMorph >> addCommandIcons [
	"Add additional icons to certain blocks. Do nothing if this isn't one of those blocks."

	| f m |
	#turnLeft: = selector
		ifTrue: [ 
			f := PhratchFrameMorph skinAt: #turnCCW ifAbsent: [ ^ self ].
			m := self firstSubmorph delete.
			self addMorphFront: (ImageMorph new form: f).
			self addMorphFront: m ].
	#turnRight: = selector
		ifTrue: [ 
			f := PhratchFrameMorph skinAt: #turnCW ifAbsent: [ ^ self ].
			m := self firstSubmorph delete.
			self addMorphFront: (ImageMorph new form: f).
			self addMorphFront: m ].
	#stopAll = selector
		ifFalse: [ ^ self ].
	f := PhratchFrameMorph skinAt: #stopButton ifAbsent: [ ^ self ].
	self addMorphBack: (ImageMorph new form: f)
]

{ #category : #private }
CommandBlockMorph >> addLabel [
	"Add a label for my command and arguments. This is the method that really creates the whole block."

	"Details: We remove all the pieces of this block, and then reassemble them, being careful not to destroy any argument morphs that we might still want to use. This is helpful if someone adds/removes parameters from a hat block."

	"attempt to embed ReporterScripts more gracefully. Has some issues, 
		commented out for now, (jens)"

	"self adjustReporterLayoutForLambda."

	| tokens args nextArgIndex m next slot |
	commandSpec ifNil: [ ^ self ].	"we make sure not to remove the next block."
	next := self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [ :t | t = next ]).
	tokens := CommandBlockMorph parseCommandSpec: commandSpec.
	args := tokens select: [ :s | CommandBlockMorph isArgSpec: s ].	"remove any excess arg morphs from the list."
	[ argMorphs size > args size ]
		whileTrue: [ 
			m := argMorphs last.
			argMorphs remove: m.	"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
			(m isKindOf: BlockMorph)
				ifTrue: [ m openInWorld ] ].	"create new arg morphs."
	[ argMorphs size < args size ] whileTrue: [ argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1)) ].
	nextArgIndex := 1.
	tokens
		do: [ :s | 
			(CommandBlockMorph isArgSpec: s)
				ifTrue: [ 
					"check if the arg type has changed (jens)"
					m := argMorphs at: nextArgIndex.
					(m isKindOf: ArgMorph)
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
	(m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)
		ifTrue: [ 
			"add spacer"
			self
				addMorphBack:
					(Morph new
						color: Color transparent;
						extent: 2 @ 5;
						yourself) ]
]

{ #category : #private }
CommandBlockMorph >> argMorphFor: specString [
	"Answer an argument morph for the given argument specification string. Set it's color appropriately."

	| m |
	m := self uncoloredArgMorphFor: specString.
	(m isKindOf: ColorArgMorph)
		ifTrue: [m color: Color random].
	^ m

]

{ #category : #private }
CommandBlockMorph >> argMorphToReplace: aMorph [
	"Answer a new argument morph to be used to replace the given morph. Answer nil if the given morph is not one of my argMorphs."

	| i argSpecs spec argM defaults v |
	i := argMorphs indexOf: aMorph ifAbsent: [^ nil].
	argSpecs := (CommandBlockMorph parseCommandSpec: commandSpec) select: [:s | CommandBlockMorph isArgSpec: s].
	i > argSpecs size ifTrue: [^ nil].
	argM := self argMorphFor: (argSpecs at: i).

	(#setVar:to: = selector and: [(argSpecs at: i) = '$Number$']) ifTrue: [
		^ argM stringExpression: '0'].
	spec := ScriptablePhratchMorph blockSpecDict at: selector ifAbsent: [^ argM].

	defaults := receiver defaultArgsFor: spec.
	i <= defaults size ifTrue: [
		v := defaults at: (argPermutation indexOf: i).
		(v isKindOf: String)
			ifTrue: [
				(argM isKindOf: ExpressionArgMorph)
					ifTrue: [argM defaultValueFromSpec: v localized]
					ifFalse: [argM defaultValue: v localized]]
			ifFalse: [argM defaultValue: v]].

	^ argM

]

{ #category : #accessing }
CommandBlockMorph >> argMorphs [

	^ argMorphs

]

{ #category : #accessing }
CommandBlockMorph >> argPermutation: aSet [

	argPermutation := aSet

]

{ #category : #accessing }
CommandBlockMorph >> args [
	"Answer my arguments evaluated and permuted into the order expected by the underlying Squeak method."

	^ self organizeArgs: (argMorphs collect: [:m | m evaluate]) asArray

]

{ #category : #evaluation }
CommandBlockMorph >> argumentAt: index [
	"Returns the argument morph at the given index."

	argPermutation ifNil: [^argMorphs at: index].	"BYOB custom blocks don't need argPermutations"
	^ argMorphs at: (argPermutation at: index).

]

{ #category : #evaluation }
CommandBlockMorph >> argumentCount [
	"Returns the number of arguments to this command block."

	^ argMorphs size

]

{ #category : #'stack/tuple conversion' }
CommandBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple argList arg val eval |
	blockTuple := Array new: argMorphs size + 3.
	blockTuple
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: selector.
	argList := argMorphs.
	argList := self organizeArgs: argList.
	((#(#+ #- #/ #* #=) includes: selector) and: [ PhratchTranslator isRTLMath ])
		ifTrue: [ argList := argList reversed ].	"RTLMath operators are RTL"
	1 to: argList size do: [ :i | 
		arg := argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [ 
				(arg isKindOf: MultiArgMorph)
					ifTrue: [ blockTuple at: i + 3 put: arg listValue convertStacksToTuples ]
					ifFalse: [ 
						((arg isKindOf: CSlotMorph) or: [ arg isKindOf: OSlotMorph ])
							ifTrue: [ blockTuple at: i + 3 put: arg asBlockTuple ]
							ifFalse: [ 
								(arg isKindOf: ExpressionArgMorph)
									ifTrue: [ 
										val := arg getExpression.
										eval := arg isNumberExpression
											ifTrue: [ 
												val = ' '
													ifTrue: [ val ]
													ifFalse: [ 
														(arg evaluate isKindOf: Symbol)
															ifTrue: [ arg evaluate ]
															ifFalse: [ val asNumberNoError ]	" special case for special values in list blocks (first, last, any)" ] ]
											ifFalse: [ arg evaluate ] ]
									ifFalse: [ 
										eval := (arg isKindOf: SpriteArgMorph)
											ifTrue: [ arg getChoice ]
											ifFalse: [ arg evaluate ] ].
								blockTuple at: i + 3 put: eval ] ]	"a list" ]
			ifFalse: [ blockTuple at: i + 3 put: arg asBlockTuple ] ].
	^ blockTuple
]

{ #category : #byob }
CommandBlockMorph >> asLambda [

	| lambda |
	lambda := CommandScriptBlockMorph new
		receiver: ScriptablePhratchMorph new;
		isSpecialForm: false;
		minArgs: 1;
		commandSpec: '.';
		selector: #procedure;
		yourself.
	lambda attachBlock: self.
	^ lambda evaluate
]

{ #category : #byob }
CommandBlockMorph >> blockWidth [
	^self width
]

{ #category : #private }
CommandBlockMorph >> canBecomeWatcher [
	"I determine which blocks can become watchers."

	| i |
	(#(	contentsOfList: 
		lambda: 
		doReport 
		listNamed: 
		newList:
		getTrue 
		getFalse 
		function 
		functionWithArgs
		copyOfList:
		doPauseThreadReporter
		asciiLetter:
		asciiCodeOf:
		getObject:
		getSpawnOf:
		spawn
		get:
	) includes: selector) ifTrue: [^false].

	i := selector asString findAnySubStr: #('mouse' 'key' 'touching' 'distance' 'File' 'Url') startingAt: 1.
	^ (self isReporter) &
	   (self argumentCount <= 1) &
	   ((#(not atRandom abs rounded lineCountOfList: stringLength: keyPressed: numericConstant: true false returnW: objName stringToBoolean: reportVar: contentsOfList: reportColor:) includes: selector) not) &
	   (i > selector asString size)

]

{ #category : #evaluation }
CommandBlockMorph >> coerceArgs: argList [
	"Answer an arguments array in which all arguments that should be numbers have been coerced to numbers if necessary."

	| args specialCommands ignoreCases numFlags |
	args := argList asArray.
	specialCommands := #(
		"append:toList: deleteLine:ofList: getLine:ofList: insert:at:ofList: list:contains: setLine:ofList:to:"
		lookLike: showBackground:
		playSound: doPlaySoundAndWait
		"setVar:to:").

	ignoreCases := Dictionary new.
	ignoreCases
		at: #deleteLine:ofList: put: 1;
		at: #getLine:ofList: put: 1;
		at: #insert:at:ofList: put: 2;
		at: #setLine:ofList:to: put: 1.

	(specialCommands includes: selector) ifFalse: [
		"ensure args are numbers where numbers are expected"
		numFlags := self numberArgFlags.

		(ignoreCases keys includes: selector) ifTrue: [
			numFlags at: (ignoreCases at: selector) put: false ].

		1 to: args size do: [:i |
			(numFlags at: i) ifTrue: [args at: i put: (args at: i) asNumberNoError]]].

	^ args

]

{ #category : #accessing }
CommandBlockMorph >> color: aColor [

	super color: aColor.
	self layoutChanged.

]

{ #category : #accessing }
CommandBlockMorph >> commandSpec [

	^ commandSpec

]

{ #category : #accessing }
CommandBlockMorph >> commandSpec: aString [
	"Set my command spec string. See my class comment."
	"CommandBlockMorph new commandSpec: 'forward $Number$'"

	commandSpec := aString.
	numberArgFlags := nil.
	self addLabel.
	self addCommandIcons.

]

{ #category : #private }
CommandBlockMorph >> deepCopy [

	^ self veryDeepCopy
]

{ #category : #accessing }
CommandBlockMorph >> defaultArgs: defaultValues [
	"Set the default values of my arguments from the given list."

	| argM defaultValue |
	1 to: (defaultValues size min: argMorphs size) do: [:i |
		argM := argMorphs at: (argPermutation at: i).
		defaultValue := defaultValues at: i.
		(argM  isKindOf: ExpressionArgMorph)
			ifTrue: [argM defaultValueFromSpec: defaultValue]
			ifFalse: [argM defaultValue: defaultValue]].


]

{ #category : #byob }
CommandBlockMorph >> drawBodyOn: aCanvas [ 

	| leftEdge middle rightEdge l m r cArgs relevant |

	leftEdge := Array with: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 7)).
	middle := Array with: (self left@(self top + 5) corner: (self right - 1)@(self bottom - 7)).
	rightEdge := Array with: ((self right - 1)@(self top + 3) corner: self right@(self bottom - 7)).

	cArgs := self nonControlFlowSubmorphs select: [:s | 
		(s isKindOf: CArgSlotMorph) 
		or: [(s isKindOf: CReporterSlotMorph)
		or: [(s isKindOf: MultiArgMorph) 
			and: [#(loop reporterSlot) includes: s type]]]].

	cArgs do: [:c |
		relevant := c bounds.
		(c isKindOf: MultiArgMorph) ifTrue: [
			relevant := c transparentRect].

		l := OrderedCollection new.
		leftEdge do: [:rect |
			l addAll: (rect areasOutside: relevant)].
		leftEdge := l.

		m := OrderedCollection new.
		middle do: [:rect |
			m addAll: (rect areasOutside: relevant)].
		middle := m.
	
		r := OrderedCollection new.
		rightEdge do: [:rect |
			r addAll: (rect areasOutside: relevant)].
		rightEdge := r].


	leftEdge do: [:rect |
		aCanvas
			fillRectangle: rect
			color: highlightColor2].

	middle do: [:rect |
		aCanvas
			fillRectangle: rect
			color: color].

	rightEdge do: [:rect |
		aCanvas
			fillRectangle: rect
			color: shadowColor]

]

{ #category : #byob }
CommandBlockMorph >> drawInlinePaletteOn: aCanvas [

	| templates |
	templates := submorphs select: [:m |
		(m isKindOf: ReporterBlockMorph)
		and: [m isBlockTemplate ]].


	templates do: [:t |
		aCanvas paintImage: ((t imageForm withOutlineColor: color width: 1) withRaisedOutlineColor: color width: 1) 
					at: t position - 2].

"
	argMorphs do: [:m |
		(#booleanslot = (self typeOfArg: m)
		and: [m isKindOf: ReporterBlockMorph]) ifTrue: [
			aCanvas paintImage: (m imageForm outlineHalfEmbeddedAdjustedColor: color) 
					at: m position - 1]]

"

]

{ #category : #elements }
CommandBlockMorph >> editElements [
	| cls sel |
	sel := selector.
	cls := receiver class classThatUnderstands: sel.

	cls ifNil: [cls := PhratchProcess].
	(cls canUnderstand: sel)
		ifFalse: [isSpecialForm ifTrue: [
			(#(getBlockVar: getVar:) includes: sel) ifTrue: [sel := #getVar].
			(#(setBlockVar:to: setVar:to:) includes: sel) ifTrue: [sel := #setVar].
			(#(changeBlockVar:by: changeVar:by:) includes: sel) ifTrue: [sel := #changeVar]]].
	
	[(cls methodNamed: sel) browse ] on: Error do: [cls browse].
]

{ #category : #evaluation }
CommandBlockMorph >> evaluate [
	^ self evaluateWithArgs: self args

]

{ #category : #evaluation }
CommandBlockMorph >> evaluateInfixWithArgs: rawArgs [
	"Evalue an infix operator with the given arguments list. Special case for comparison operatores when both operands are strings. Reverse order of comparison operands in RTL languages."

	"Note: The strings 'true' and 'false' in either English or the current language are equal to the boolean value that they name."

	| args result arg1 arg2 |
	args := rawArgs.
	#= = selector
		ifTrue: [ 
			"special case: check for equality between a boolean and the special strings 'true' or 'false'"
			((args first isKindOf: String) and: [ args second isKindOf: Boolean ])
				ifTrue: [ 
					args first = 'true'
						ifTrue: [ ^ args second = true ].
					args first = 'false'
						ifTrue: [ ^ args second = false ].
					args first = (PhratchTranslator translationFor: 'true')
						ifTrue: [ ^ args second = true ].
					args first = (PhratchTranslator translationFor: 'false')
						ifTrue: [ ^ args second = false ] ].
			((args first isKindOf: Boolean) and: [ args second isKindOf: String ])
				ifTrue: [ 
					args second = 'true'
						ifTrue: [ ^ args first = true ].
					args second = 'false'
						ifTrue: [ ^ args first = false ].
					args second = (PhratchTranslator translationFor: 'true')
						ifTrue: [ ^ args first = true ].
					args second = (PhratchTranslator translationFor: 'false')
						ifTrue: [ ^ args first = false ] ] ].
	(#(#< #= #>) includes: selector)
		ifTrue: [ 
			((args first isKindOf: String) or: [ args second isKindOf: String ])
				ifTrue: [ 
					arg1 := receiver interpretStringAsNumberIfPossible: args first.
					arg2 := receiver interpretStringAsNumberIfPossible: args second.
					((arg1 isKindOf: String) and: [ arg2 isKindOf: String ])
						ifTrue: [ 
							result := args first compare: args second.
							#< = selector
								ifTrue: [ ^ result = 1 ].
							#= = selector
								ifTrue: [ ^ result = 2 ].
							#> = selector
								ifTrue: [ ^ result = 3 ] ].
					((arg1 isKindOf: Number) and: [ arg2 isKindOf: Number ])
						ifTrue: [ ^ arg1 perform: selector with: arg2 ].
					^ false ]
				ifFalse: [ 
					(args first isKindOf: PhratchListMorph)
						ifTrue: [ ^ args first equals: args second ].
					(args second isKindOf: PhratchListMorph)
						ifTrue: [ ^ args second equals: args first ] ] ]
		ifFalse: [ 
			(PhratchTranslator isRTLMath and: [ selector ~= #\\ ])
				ifTrue: [ args := args reversed ] ].	"RTLMath operators are RTL"
	(#(#& #|) includes: selector)
		ifTrue: [ ^ args first perform: selector with: args second ].
	((args first isKindOf: ScriptablePhratchMorph) or: [ args second isKindOf: ScriptablePhratchMorph ])
		ifTrue: [ ^ args first = args second ].
	^ args first asNumberNoError perform: selector with: args second asNumberNoError
]

{ #category : #evaluation }
CommandBlockMorph >> evaluateWithArgs: rawArgs [
	"Evalue this block with the given argument list."

	| args |
	"special case for math and boolean infix operators"
	selector isInfix ifTrue: [^ self evaluateInfixWithArgs: rawArgs].

	args := self coerceArgs: rawArgs..

	"special case for unary operators"
	(#(abs not rounded sqrt truncated) includes: selector) ifTrue: [^ args first perform: selector].

	^ receiver perform: selector withArguments: args

]

{ #category : #'object i/o' }
CommandBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #private }
CommandBlockMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	self fixBlockLayoutWrap
]

{ #category : #private }
CommandBlockMorph >> fixBlockLayoutNoWrap [
	"Update the positions of my submorphs."

	| isFirst h x minXForArgs hAdjust nextB w oldPos oldExtent space |
	blockLayoutNeeded
		ifFalse: [ ^ self ].
	space := 4.
	self isCustomBlock
		ifTrue: [ 
			self isTemplate
				ifTrue: [ space := 2 ] ].
	super fixBlockLayout.
	oldPos := self position.
	oldExtent := self extent.
	hAdjust := 4.
	isFirst := true.
	h := 14.	"minimum height"
	self nonControlFlowSubmorphs
		do: [ :m | 
			(m isKindOf: BlockMorph)
				ifTrue: [ m fixBlockLayout ].
			(m isKindOf: ArgMorph)
				ifTrue: [ m fixArgLayout ].
			(isFirst and: [ (m isKindOf: StringMorph) not ])
				ifTrue: [ 
					"extra space when an arg overlaps with notch"
					h := h max: m height + 3.
					hAdjust := 1 ].
			isFirst := false.
			h := ((m isKindOf: CommandBlockMorph) and: [ m isBlockTemplate ])
				ifTrue: [ h max: m height + 2 ]
				ifFalse: [ h max: m height ] ].
	minXForArgs := ((self isKindOf: CBlockMorph) or: [ self isKindOf: IfElseBlockMorph ])
		ifTrue: [ self left + PuzzleInset + PuzzleWidth + 8 ]
		ifFalse: [ self left ].
	h := h + 10.
	self isReporter
		ifTrue: [ 
			h := h - 2.
			hAdjust := 2 ].
	self isStop
		ifTrue: [ 
			h := h - 5.
			hAdjust := 0 ].
	x := self left + 5.
	self nonControlFlowSubmorphs
		do: [ :m | 
			(m isKindOf: StringMorph)
				ifTrue: [ 
					(m isKindOf: BlockLabelFragmentMorph)
						ifFalse: [ m color: self labelColor ] ]
				ifFalse: [ x := x max: minXForArgs ].
			m position: x @ (self top + ((h - hAdjust - m height) // 2)).
			x := x + m width + space ].
	w := x - self left max: 37.
	((self isKindOf: CBlockMorph) or: [ self isKindOf: IfElseBlockMorph ])
		ifTrue: [ w := w max: 71 ].
	self extent: w @ h.
	PhratchTranslator isRTL
		ifTrue: [ self left: oldPos x + (oldExtent x - self width) ].
	(nextB := self nextBlock)
		ifNotNil: [ 
			(self isKindOf: CBlockMorph)
				ifFalse: [ 
					PhratchTranslator isRTL
						ifTrue: [ nextB position: (self right - nextB width) @ (self bottom - 4) ]
						ifFalse: [ nextB position: self left @ (self bottom - 4) ] ].
			nextB fixBlockLayout ]
]

{ #category : #byob }
CommandBlockMorph >> fixBlockLayoutWrap [
	"Update the positions of my submorphs."

	| parts lines line h x y minXForArgs nextB w space left maxX maxHeight mh |
	(self isCustomBlock and: [ self isTemplate ])
		ifTrue: [ ^ self fixBlockLayoutNoWrap ].
	blockLayoutNeeded
		ifFalse: [ ^ self ].
	cachedForm := nil.
	cachedFeedbackForm := nil.
	parts := self nonControlFlowSubmorphs.
	lines := OrderedCollection new.	"distribute parts horizontally and cut up into lines"
	line := OrderedCollection new.
	x := self left + 5.
	left := x.
	maxX := x.
	minXForArgs := self left.
	space := 4.
	parts
		do: [ :m | 
			((m isKindOf: CArgSlotMorph)
				or: [ (m isKindOf: CReporterSlotMorph) or: [ (m isKindOf: MultiArgMorph) and: [ m isWrapping ] ] ])
				ifTrue: [ 
					line isEmpty
						ifFalse: [ lines add: line ].
					m left: left.	"self"
					lines add: (OrderedCollection with: m).
					(m isKindOf: MultiArgMorph)
						ifTrue: [ m fixArgLayout ]
						ifFalse: [ m fixBlockLayout ].
					((m isKindOf: CArgSlotMorph) or: [ m isKindOf: CReporterSlotMorph ])
						ifTrue: [ m width: 40 ].
					line := OrderedCollection new.
					maxX := maxX max: left + m width.
					x := left ]
				ifFalse: [ 
					x - left > 400
						ifTrue: [ 
							lines add: line.
							line := OrderedCollection new.
							x := left ].
					(m isKindOf: BlockMorph)
						ifTrue: [ m fixBlockLayout ].
					(m isKindOf: ArgMorph)
						ifTrue: [ m fixArgLayout ].
					(m isKindOf: StringMorph)
						ifTrue: [ m color: self labelColor ]
						ifFalse: [ x := x max: minXForArgs ].
					m left: x.
					(m fullBounds right - left > 400 and: [ line isEmpty not ])
						ifTrue: [ 
							lines add: line.
							line := OrderedCollection new.
							m left: left.
							line add: m.
							x := left ]
						ifFalse: [ line add: m ].
					x := x + m fullBounds width + space.
					maxX := maxX max: x ] ].
	x = left
		ifFalse: [ lines add: line ].
	w := maxX - self left max: 37.	"distribute lines vertically"
	space := 2.
	y := self top + 2.	"4"	"space"
	lines
		do: [ :eachLine | 
			maxHeight := 14.
			eachLine
				do: [ :m | 
					mh := ((m isKindOf: ReporterBlockMorph)
						and: [ m isBlockTemplate or: [ ((m isKindOf: CArgSlotMorph) or: [ m isKindOf: OSlotMorph ]) and: [ m isEmptySlot not ] ] ])
						ifTrue: [ 
							m == eachLine first
								ifTrue: [ m height + 10 ]
								ifFalse: [ m height + 5 ] ]
						ifFalse: [ 
							((m isKindOf: CArgSlotMorph) or: [ m isKindOf: OSlotMorph ])
								ifTrue: [ m height + 5 ]
								ifFalse: [ m height ] ].
					maxHeight := mh max: maxHeight.
					((m isKindOf: CArgSlotMorph) or: [ m isKindOf: CReporterSlotMorph ])
						ifTrue: [ maxHeight := m height - 4 ] ].
			eachLine do: [ :m | m top: y + ((maxHeight - m height) // 2) + 1 ].
			y := y + maxHeight + space ].	"adjust CArgSlots"
	parts
		do: [ :m | 
			((m isKindOf: CArgSlotMorph) or: [ m isKindOf: CReporterSlotMorph ])
				ifTrue: [ m width: w - 5 ] ].
	h := self isStop
		ifTrue: [ y - self top + space ]
		ifFalse: [ y - self top + space + 4 ].
	parts size > 0
		ifTrue: [ 
			((parts last isKindOf: CArgSlotMorph) or: [ parts last isKindOf: CReporterSlotMorph ])
				ifTrue: [ h := h + space + 5 ] ].
	self extent: w @ h.	"adjust Multi-CArgSlots"
	parts
		do: [ :m | 
			(m isKindOf: MultiArgMorph)
				ifTrue: [ m loopsWidth: w - 5 ] ].
	(nextB := self nextBlock)
		ifNotNil: [ 
			nextB position: self left @ (self bottom - 4).
			nextB fixBlockLayout ]
]

{ #category : #accessing }
CommandBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this block, or nil if no help is available."

	selector isInfix ifTrue: [
		'+' = selector ifTrue: [^ 'minus'].
		'-' = selector ifTrue: [^ 'minus'].
		'*' = selector ifTrue: [^ 'minus'].
		'/' = selector ifTrue: [^ 'minus'].

		'<' = selector ifTrue: [^ 'lessThan'].
		'=' = selector ifTrue: [^ 'equals'].
		'>' = selector ifTrue: [^ 'greaterThan'].

		'&' = selector ifTrue: [^ 'and'].
		'|' = selector ifTrue: [^ 'or'].

		'\\' = selector ifTrue: [^ 'mod'].

		^ nil].

	"answer the selector with colons mapped to underscores"
	^ selector asString collect: [:ch | ch = $: ifTrue: [$_] ifFalse: [ch]]

]

{ #category : #'object i/o' }
CommandBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		commandSpec
		argMorphs
		titleMorph
		receiver
		selector
		isReporter
		isTimed
		wantsName
		wantsPossession
	) from: anObjStream.

]

{ #category : #initialization }
CommandBlockMorph >> initialize [

	super initialize.
	commandSpec := ''.
	argMorphs := OrderedCollection new.
	receiver := nil.
	selector := nil.
	isTimed := false.

]

{ #category : #byob }
CommandBlockMorph >> isCShape [

	^ argMorphs anySatisfy: [:am | 
		am isKindOf: CArgSlotMorph]
]

{ #category : #accessing }
CommandBlockMorph >> isForever [

	^ (selector = #doForever) | (selector = #doForeverIf)

]

{ #category : #byob }
CommandBlockMorph >> isMaxNestedAt: int [
	"kludge-alert!"

	(receiver isKindOf: VariableFrame)
		ifFalse: [^ false].
	^ receiver isMaxNestedAt: int + 1

]

{ #category : #accessing }
CommandBlockMorph >> isStop [

	^ #(doReturn stopAll doAnswer doStopBlock) includes: selector

]

{ #category : #accessing }
CommandBlockMorph >> isTimed [

	^ isTimed

]

{ #category : #accessing }
CommandBlockMorph >> isTimed: aBoolean [
	"Indicates that this block's evaluate method will be called repeatedly throughout some time interval."

	isTimed := aBoolean.
]

{ #category : #evaluation }
CommandBlockMorph >> key [
	^ key
]

{ #category : #evaluation }
CommandBlockMorph >> key: aKey [
	key := aKey 
]

{ #category : #private }
CommandBlockMorph >> labelColor [
	"Answer a label color, either black or white, that maximizes the contrast with my color."

	^ LabelColor

"old:
	^ self color luminance > 0.8
		ifTrue: [Color black]
		ifFalse: [Color white]
"

]

{ #category : #private }
CommandBlockMorph >> labelMorphFor: aString [

	| s |
	s := aString.
	^ (StringMorph contents: s font: (PhratchFrameMorph getFont: #Label))
		color: self labelColor

]

{ #category : #private }
CommandBlockMorph >> mapReceiver: oldObj to: newObj [
	"Used in cloning an object to make blocks that refererred to the original object new refer to the new copy."

	receiver == oldObj ifTrue: [receiver := newObj].
	argMorphs do: [:arg |
		(arg isKindOf: CommandBlockMorph) ifTrue: [
			arg mapReceiver: oldObj to: newObj]].

]

{ #category : #byob }
CommandBlockMorph >> nests: aCommandBlock [

	| cslots |
	cslots := argMorphs select: [:am | am isKindOf: CArgSlotMorph].
	cslots do: [:cs |
		cs nestedBlock ifNotNil: [
			(cs nestedBlock blockSequence includes: aCommandBlock)
				ifTrue: [^ true]]].
	^ false

]

{ #category : #private }
CommandBlockMorph >> nextBlock [
	"Answer the block following myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [(argMorphs includes: m) not]]
		ifNone: [nil]

]

{ #category : #private }
CommandBlockMorph >> nextBlock: aBlock [
	"Add the given block as the block following me. Delete old nextBlock, if any."

	self nextBlock ifNotNil: [self nextBlock delete].
	self addMorph: aBlock.

]

{ #category : #accessing }
CommandBlockMorph >> numberArgFlags [
	"Answer an array of booleans indicating which of my arguments must be numbers. Compute on first use and cache the result."

	| argSpecs argM |
	numberArgFlags ifNotNil: [^ numberArgFlags].

	argSpecs := (CommandBlockMorph parseCommandSpec: commandSpec) select: [:s | CommandBlockMorph isArgSpec: s].
	argSpecs := self organizeArgs: argSpecs.
	numberArgFlags := argSpecs collect: [:spec |
		argM := self uncoloredArgMorphFor: spec.
		(argM isKindOf: ExpressionArgMorph)
			ifTrue: [
				(argM isKindOf: ExpressionArgMorphWithMenu)
					ifTrue: [
						argM isNumberExpression or:
						[#(listIndexMenu listIndexForDeleteMenu) includes: argM menuSelector]]
					ifFalse: [argM isNumberExpression]]
			ifFalse: [false]].

	^ numberArgFlags

]

{ #category : #private }
CommandBlockMorph >> oldUncoloredArgMorphFor: specString [
	"Answer an argument morph for the given argument specification string."

	| code |
	code := specString copyFrom: 2 to: specString size-1.
	
	$a			= code ifTrue: [^ AttributeArgMorph new choice: ''].
	$b			= code ifTrue: [^ BooleanArgMorph new].
	$c				= code ifTrue: [^ ColorArgMorph new showPalette: true].
	$C		= code ifTrue: [^ ColorArgMorph new showPalette: false]. 
	$d			= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '0'; menuSelector: #directionMenu;
		yourself].
	$D				= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '48'; menuSelector: #midiDrumMenu;
		yourself].
	$e				= code ifTrue: [^ EventTitleMorph new].
	$f		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #mathFunctionNames; choice: #sqrt;
		yourself].
	$3			= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #constantNames].
	$g				= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #graphicEffectNames; choice: #color;
		yourself].
	$4 		= code ifTrue: [^ ExpressionArgMorphWithMenu new stringExpression: 'a color'; menuSelector: #colorsMenu;
		yourself].
	$H 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #hookupSensorNames].
	$h 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #hookupBooleanSensorNames].
	$I 		= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #midiInstrumentMenu;
		yourself].
	$i 			= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #listIndexMenu;
		yourself].
	$k 				= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #keyNames; choice: 'space';
		yourself].
	$5 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #namedColors; choice: #black;
		yourself].
	$L 				= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #listVarMenu].
	$l 			= code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #costumeNames; choice: 'costume1';
		yourself].
	$m 				= code ifTrue: [^ SpriteArgMorph new].
	$M 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #motorNames].
	$n 			= code ifTrue: [^ ExpressionArgMorph new numExpression: '10'].
	$N 				= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '60'; menuSelector: #noteSelector;
		yourself].
	$s 				= code ifTrue: [^ ExpressionArgMorph new stringExpression: ''].
	$S 		= code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #soundNames; choice: 'pop';
		yourself].
	$6 			= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #timeDates; choice: 'time';
		yourself].
	$7 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #layoutStyles; choice: 'large';
		yourself].
	$v 			= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #varNamesMenu; choice: '';
		yourself].
	$W 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #motorDirection].
	$x 		= code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #sceneNames; choice: '';
		yourself].
	$8 		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #newCostumeTypes; choice: 'camera';
		yourself].
	$y 			= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #listIndexForDeleteMenu;
		yourself].

	$B  = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #blockId; choice: '';
		yourself].
	"special args for BYOB"
	$o  = code ifTrue: [ ^ CSlotMorph new "SpecialArgMorph new type: #command"].
	$E  = code ifTrue: [ ^ CSlotMorph new "SpecialArgMorph new type: #command"].
	$O  = code ifTrue: [ ^ MultiArgMorph type: #command].
	$r  = code ifTrue: [ ^ OSlotMorph new receiver: receiver; type: #reporterslot; yourself "SpecialArgMorph new type: #reporter"].
	$R  = code ifTrue: [ ^ MultiArgMorph type: #reporter].
	$p  = code ifTrue: [ ^ OSlotMorph new receiver: receiver; type: #booleanslot; yourself "SpecialArgMorph new type: #predicate"].
	$P  = code ifTrue: [ ^ MultiArgMorph type: #predicate].
	$t  = code ifTrue: [ ^ SpecialArgMorph new type: #list].
	$u  = code ifTrue: [ ^ MultiArgMorph type: #list].
	$T  = code ifTrue: [ ^ ExpressionArgMorph new stringExpression: ''; isText: true;
		yourself.  "SpecialArgMorph new type: #text"].
	$U  = code ifTrue: [ ^ MultiArgMorph type: #text].
	$V  = code ifTrue: [ ^ MultiArgMorph type: #boolean].
	$w  = code ifTrue: [ ^ MultiArgMorph type: #number].
	$X  = code ifTrue: [ ^ MultiArgMorph type: #any].
	$z  = code ifTrue: [ ^ VariableBlockMorph new 
							isSpecialForm: true; 
							selector: #getVar:;
							commandSpec: '?';
		yourself].
	$Z  = code ifTrue: [ ^ SpecialArgMorph new type: #reporterslot].
	$Y  = code ifTrue: [ ^ SpecialArgMorph new type: #booleanslot].
	
	$A = code ifTrue: [ ^ ChoiceArgMorph new options: {'with inputs' localized. 'with input list' localized}; choice: 'with inputs';
		yourself].
	$F  = code ifTrue: [ ^ ChoiceArgMorph new options: {'number' localized. 'text' localized. 'boolean' localized. 'list' localized. 'command' localized. 'reporter' localized. 'predicate' localized. 'object' localized}; choice: 'number' localized;
		yourself].

	$G  = code ifTrue: [ ^ CArgSlotMorph new].
	$J  = code ifTrue: [ ^ MultiArgMorph type: #loop].

	$j  = code ifTrue: [ ^ UnevaluatedExpressionArgMorph new stringExpression: ''].
	$q  = code ifTrue: [ ^ MultiArgMorph type: #unevaluated].
	$Q  = code ifTrue: [ ^ UnevaluatedBooleanArgMorph new].
	$K  = code ifTrue: [ ^ MultiArgMorph type: #unevaluatedBoolean].

	$1  = code ifTrue: [ ^ SpecialArgMorph new type: #objSlot].
	$2  = code ifTrue: [ ^ MultiArgMorph type: #objSlot].	
	
	$r  = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #rotationStyleChanger; choice: 'normal';
		yourself].
			
	^ ExpressionArgMorph new numExpression: '10'
]

{ #category : #evaluation }
CommandBlockMorph >> organizeArgs: argList [
	"Answer an arugments array in which all arguments have been rearranged to the original English permutation"

	| newArgList |
	argPermutation ifNil: [^ argList].
	(#(+ - / * =) includes: selector) ifTrue: [^ argList].
	newArgList := #().
	1 to: argPermutation size do: [:i |
		newArgList := newArgList copyWith: (argList at: (argPermutation at: i))].
	^ newArgList

]

{ #category : #byob }
CommandBlockMorph >> phratchObject [

	| be sm sf so |
	be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
	be isNil
		ifTrue: [
			sm := self ownerOrYourselfThatIsA: PhratchScriptsMorph.
			sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
			sm isNil | sf isNil ifTrue: [^ nil].
			so := sf phratchObjects detect: [:obj | obj blocksBin = sm] ifNone: [sf workPane]]
		ifFalse: [so := be template receiver].
	^so
]

{ #category : #private }
CommandBlockMorph >> printCodeOn: aStream indent: indent [
	"Append a human-readable string for this block on the given stream."

	| nextB hasFinalSpace |
	indent timesRepeat: [aStream nextPutAll: '    '].
	nextB := self nextBlock.
	hasFinalSpace := false.
	submorphs do: [:m |
		m ~~ nextB ifTrue: [
			self printCodeSubmorph: m on: aStream.
			hasFinalSpace := true.
			aStream space]].
	hasFinalSpace ifTrue: [aStream skip: -1].
	aStream cr.
	self nextBlock ifNotNil: [self nextBlock printCodeOn: aStream indent: indent].

]

{ #category : #byob }
CommandBlockMorph >> rcvr [
	"answer a String description of my receiver which can be used in a tuple"

	| rcvr |
	rcvr := (receiver isKindOf: ScriptablePhratchMorph)
		ifTrue: [ 
			(receiver isKindOf: PhratchStageMorph)
				ifTrue: [ 'Stage' ]
				ifFalse: [ receiver objName ] ]
		ifFalse: [ '' ].
	^ rcvr
]

{ #category : #accessing }
CommandBlockMorph >> receiver [

	^ receiver

]

{ #category : #accessing }
CommandBlockMorph >> receiver: anObject [
	"Set my receiver object."

	receiver := anObject.

]

{ #category : #byob }
CommandBlockMorph >> references: obj [
	"kludge-alert: answer true if any part of me contains a reference to obj"

	(receiver isKindOf: VariableFrame)
		ifFalse: [^ false].
	^ receiver references: obj
]

{ #category : #private }
CommandBlockMorph >> replaceArgMorph: oldMorph by: newMorph [
	"Replace oldMorph with newMorph in my argMorphs and submorphs lists. This is done when dropping a reporter block onto one of my arguments."

	argMorphs := argMorphs collect: [:m |
		m == oldMorph ifTrue: [newMorph] ifFalse: [m]].
	self replaceSubmorph: oldMorph by: newMorph.

	"attempt at a more graceful way to embed ReporterScripts,
	has some issues, commented out for now (jens) "

"
	(newMorph = argMorphs first and: [ 
		(newMorph isKindOf: ReporterScriptBlockMorph) or: [
			oldMorph isKindOf: ReporterScriptBlockMorph]]) ifTrue: [
			self addLabel].
"
	self layoutChanged.

]

{ #category : #byob }
CommandBlockMorph >> rightButtonMenu [

	| menu sFrame choice spec |
	menu := MenuMorphNG new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.

	(owner isKindOf: PhratchBlockPaletteMorph) ifFalse: [
		menu addLine.
		(#(+ - * / \\) includes: selector) ifTrue: [
			#(+ - * / mod) with: #(+ - * / \\) do: [:s :op | menu add: s value: op]].
		(#(< = >) includes: selector) ifTrue: [
			#(< = >) do: [:op | menu add: op value: op]].
		(#(& |) includes: selector) ifTrue: [
			#(and or) with: #(& |) do: [:s :op | menu add: s value: op]].

		menu addLine.
		menu add: 'duplicate' value: #duplicate.
		(self isKindOf: ReporterBlockMorph) ifFalse: [
			menu add: '- this block' value: #fastDuplicate].
		(self isKindOf: VariableBlockMorph) ifTrue: [
			menu add: 'relabel' value: #rename].
		(self owner isKindOf: BlockMorph) ifFalse: [  "can't yet delete a blocks inside a script"
			menu add: 'delete' value: #delete]].

	menu addLine.

	self isInheritableAttribute ifTrue: [
		self isDeletedAttribute 
			ifTrue: [menu add: 'disinherit' value: #disinheritAttribute]
			ifFalse: [menu add: 'inherit' value: #inheritAttribute]].
	
	menu add: 'show block' value: #showElements.
	
	ScriptablePhratchMorph noviceMode ifFalse:[
		menu add: 'edit block for developer' value: #editElements.
	].
	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	(sFrame notNil and: [#(sensor: sensorPressed:) includes: selector]) ifTrue: [
		menu addLine.
		menu add: 'show PhratchBoard watcher' value: #showSensorBoard.
		sFrame workPane phratchServer
			ifNil: [menu add: 'enable remote sensor connections' value: #enableRemoteSensors]
			ifNotNil: [menu add: 'disable remote sensor connections' value: #exitPhratchSession]].

	DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' value: #showTuples].
	
	(choice := (menu localize; invokeModal"popUpAt: World activeHand position  inWorld:   World"; yourself)selectedValue) ifNil: [^ self].
	(#(presentHelpScreen duplicate fastDuplicate rename delete showElements editElements inheritAttribute disinheritAttribute) includes: choice) ifTrue: [^ self perform: choice].
	choice = #showSensorBoard ifTrue: [sFrame showSensorBoard. ^ self].
	choice = #enableRemoteSensors ifTrue: [sFrame enableRemoteSensors. ^ self].
	choice = #exitPhratchSession ifTrue: [sFrame exitPhratchSession. ^ self].
	choice = #showTuples ifTrue: [^ self showTuples].

	"change operator"
	spec := '$Number$ ', choice, ' $Number$'.
	'\\' = choice ifTrue: [spec := PhratchTranslator translationFor: '$Number$ mod $Number$'].
	'&' = choice	ifTrue: [spec := PhratchTranslator translationFor: '$Boolean$ and $Boolean$'].
	'|' = choice	ifTrue: [spec := PhratchTranslator translationFor: '$Boolean$ or $Boolean$'].

	self commandSpec: spec.
	self selector: choice.

]

{ #category : #byob }
CommandBlockMorph >> scriptVars [
	"private - answer the names of all script variables reachable by myself"

	| blockVars o be |

	blockVars := Set new.
	o := owner.
	[ (o isKindOf: BlockMorph) or: [o isKindOf: ArgMorph]] whileTrue: [
		o isLambdaForm ifTrue: [
			blockVars addAll: o allVarNames ].
		(o isKindOf: VariableDeclarationBlockMorph) ifTrue: [
			blockVars addAll: o variables ].
		(o isKindOf: ProcedureHatBlockMorph) ifTrue: [
			blockVars addAll: o argMorph allVarNames ].
		(o isKindOf: ReporterBlockDropTargetMorph)
			ifTrue: [
				be := o ownerOrYourselfThatIsA: BlockEditorFrameMorph.
				blockVars addAll: be template allVarNames.
				o := be hat bottomBlock.
				(o isKindOf: VariableDeclarationBlockMorph) ifTrue: [
					blockVars addAll: o variables ].
				(o isKindOf: ProcedureHatBlockMorph) ifTrue: [
					blockVars addAll: o argMorph allVarNames ]].
		o := o owner].
	^blockVars
]

{ #category : #accessing }
CommandBlockMorph >> selector [

	^ selector

]

{ #category : #accessing }
CommandBlockMorph >> selector: aSymbol [

	selector := aSymbol.

]

{ #category : #accessing }
CommandBlockMorph >> selectorAndArg [
	"Answer an array containing my selector and argument (if any)."

	| args |
	args := self args.
	^ Array with: selector with: (args size = 0 ifTrue: [nil] ifFalse: [args first])

]

{ #category : #elements }
CommandBlockMorph >> showElements [
	| cls sel |
	sel := selector.
	cls := receiver class classThatUnderstands: sel.

	cls ifNil: [cls := PhratchProcess].
	(cls canUnderstand: sel)
		ifFalse: [isSpecialForm ifTrue: [
			(#(getBlockVar: getVar:) includes: sel) ifTrue: [sel := #getVar].
			(#(setBlockVar:to: setVar:to:) includes: sel) ifTrue: [sel := #setVar].
			(#(changeBlockVar:by: changeVar:by:) includes: sel) ifTrue: [sel := #changeVar]]].
	
	ElementsEditorFrameMorph new 
		onMethod: sel ofClass: cls
]

{ #category : #byob }
CommandBlockMorph >> start [

	| stage rcvr |
	self stop.
	self receiver ifNil: [^ self].
	phratchProc ifNotNil: [^ self].  "this stack is already running"

	rcvr := self receiver.
	(rcvr isKindOf: ScriptablePhratchMorph)
		ifTrue: [ (stage := rcvr ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self]]
		ifFalse: [stage := (self ownerOrYourselfThatIsA: PhratchFrameMorph) workPane].	

	phratchProc := stage startProcessFor: self.
	self changed.

]

{ #category : #byob }
CommandBlockMorph >> stopFrame [
	^ stopFrame
]

{ #category : #byob }
CommandBlockMorph >> stopFrame: aFrame [

		stopFrame := aFrame
]

{ #category : #'object i/o' }
CommandBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		commandSpec
		argMorphs
		titleMorph
		receiver
		selector
		isReporter
		isTimed
		wantsName
		wantsPossession
	) on: anObjStream.

]

{ #category : #private }
CommandBlockMorph >> tabToNextField: evt [
	"Move the keyboard focus to the next submorph that responds to keyboard events."

	| fields current |
	fields := self topBlock tabFields "allMorphs select: [:m | m isKindOf: ExpressionArgMorph]".

	current := (1 to: fields size) detect: [:i | (fields at: i) labelMorph == evt hand keyboardFocus] ifNone: [fields size].
	evt hand newKeyboardFocus: (fields at: (current \\ fields size) + 1) labelMorph.

]

{ #category : #byob }
CommandBlockMorph >> tabToPreviousField: evt [
	"Move the keyboard focus to the previous submorph that responds to keyboard events."

	| fields current |
	fields := self topBlock tabFields  " allMorphs select: [:m | m isKindOf: ExpressionArgMorph]".

	current := (1 to: fields size) detect: [:i | (fields at: i) labelMorph == evt hand keyboardFocus] ifNone: [fields size].
	evt hand newKeyboardFocus: (fields at: ((current - 1 \\ fields size) max: 1)) labelMorph.


]

{ #category : #byob }
CommandBlockMorph >> typeOfArg: aMorph [
	"answer a symbol representing the type of my argument morph being aMorph"

	| idx tokens args spec specs |
	idx := argMorphs indexOf: aMorph.
	tokens := CommandBlockMorph parseCommandSpec: commandSpec.
	args := tokens select: [:s | CommandBlockMorph isArgSpec: s].
	args size < idx ifTrue: [^ #any].
	spec := args at: idx.
	'$String$' = spec ifTrue: [^#any].

	specs := Dictionary new.
	specs
		at: #command put: '$CSlot$';
		at: #commandList put: '$MACommand$';
		at: #reporter put: '$OSReporter$';
		at: #colorReporter put: '$Effects$';
		at: #repoerterList put: '$MAReporter$';
		at: #predicate put: '$OSBoolean$';
		at: #predicateList put: '$MAPredicate$';
		at: #list put: '$SAList$';
		at: #listList put: '$MAList$';
		at: #text put: '$Text$';
		at: #textList put: '$MAText$';
		at: #any put: '$String$';
		at: #anyList put:  '$MAAny$';
		at: #boolean put: '$Boolean$';
		at: #booleanList put: '$MABoolean$';
		at: #number put: '$Number$';
		at: #numberList put: '$MANumber$';
		at: #template put: '$SpecialVar$';
		at: #booleanslot put: '$SABoolean$';
		at: #unevaluated put: '$UnEExp$';
		at: #unevaluatedList put: '$MAUneval$';
		at: #loop put: '$CArgSlot$';
		at: #unevaluatedBoolean put: '$UnEBool$';
		at: #unevaluatedBooleanList put: '$MAUnEBool$'.

	specs keysDo: [:t |
		spec = (specs at: t) ifTrue: [^t]].
	^#any
]

{ #category : #private }
CommandBlockMorph >> uncoloredArgMorphFor: specString [
	"Answer an argument morph for the given argument specification string."

	| code |
	code := specString copyFrom: 2 to: specString size-1.
	
	"%a"'Attributes'			= code ifTrue: [^ AttributeArgMorph new choice: ''].
	"b"'Boolean'			= code ifTrue: [^ BooleanArgMorph new].
	""'CheckBox'			= code ifTrue: [^ CheckBoxArgMorph new].
	"c"'Color'				= code ifTrue: [^ ColorArgMorph new showPalette: true].
	"C"'ScreenColor'		= code ifTrue: [^ ColorArgMorph new showPalette: false]. 
	"d"'Directions'			= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '0'; menuSelector: #directionMenu;
		yourself].
	"D"'Drums'				= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '48'; menuSelector: #midiDrumMenu;
		yourself].
	"e"'Event'				= code ifTrue: [^ EventTitleMorph new].
	"f"'MathFunctions'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #mathFunctionNames; choice: #sqrt;
		yourself].
	"3"'Constants'			= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #constantNames;
		yourself].
	"g"'Effects'				= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #graphicEffectNames; choice: #color;
		yourself].
	"4"'ColorVar'			= code ifTrue: [^ ExpressionArgMorphWithMenu new stringExpression: 'a color'; menuSelector: #colorsMenu;
		yourself].
	"H"'SensorNames'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #hookupSensorNames;
		yourself].
	"h"'SensorBooleans'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #hookupBooleanSensorNames;
		yourself].
	"I"'Instruments'		= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #midiInstrumentMenu;
		yourself].
	"i"'ListIndex'			= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #listIndexMenu;
		yourself].
	"k"'Keys'				= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #keyNames; choice: 'space';
		yourself].
	"5"'NamedColors'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #namedColors; choice: #black;
		yourself].
	"L"'List'				= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #listVarMenu;
		yourself].
	"l"'Costumes'			= code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #costumeNames; choice: 'costume1';
		yourself].
	"m"'Sprite'				= code ifTrue: [^ SpriteArgMorph new].
	"M"'MotorNames'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #motorNames].
	"n"'Number'			= code ifTrue: [^ ExpressionArgMorph new numExpression: '10'].
	"N"'Notes'				= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '60'; menuSelector: #noteSelector;
		yourself].
	"s"'String'				= code ifTrue: [^ ExpressionArgMorph new stringExpression: '';
		yourself].
	"S"'SoundNames'		= code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #soundNames; choice: 'pop';
		yourself].
	"6"'TimeDates'			= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #timeDates; choice: 'time';
		yourself].
	"7"'LayoutStyles'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #layoutStyles; choice: 'large';
		yourself].
	"v"'Variable'			= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #varNamesMenu; choice: '';
		yourself].
	"W"'MotorDirection'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #motorDirection;
		yourself].
	"x"'SceneNames'		= code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #sceneNames; choice: '';
		yourself].
	"8"'NewCostume'		= code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #newCostumeTypes; choice: 'camera';
		yourself].
	"y"'ListDelete'			= code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #listIndexForDeleteMenu;
		yourself].
	
	"$B"'BlockId' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #blockId; choice: '';
		yourself].
	"special args for BYOB"
	"$o $E"'CSlot' = code ifTrue: [ ^ CSlotMorph new "SpecialArgMorph new type: #command"].
	"$O"'MACommand' = code ifTrue: [ ^ MultiArgMorph type: #command].
	"$r"'OSReporter' = code ifTrue: [ ^ OSlotMorph new receiver: receiver; type: #reporterslot; yourself "SpecialArgMorph new type: #reporter"].
	"$R"'MAReporter' = code ifTrue: [ ^ MultiArgMorph type: #reporter].
	"$p"'OSBoolean' = code ifTrue: [ ^ OSlotMorph new receiver: receiver; type: #booleanslot; yourself "SpecialArgMorph new type: #predicate"].
	"$P"'MAPredicate' = code ifTrue: [ ^ MultiArgMorph type: #predicate;
		yourself].
	"$t"'SAList' = code ifTrue: [ ^ SpecialArgMorph new type: #list;
		yourself].
	"$u"'MAList' = code ifTrue: [ ^ MultiArgMorph type: #list;
		yourself].
	"$T"'Text' = code ifTrue: [ ^ ExpressionArgMorph new stringExpression: ''; isText: true;
		yourself.  "SpecialArgMorph new type: #text"].
	"$U"'MAText' = code ifTrue: [ ^ MultiArgMorph type: #text;
		yourself].
	"$V"'MABoolean' = code ifTrue: [ ^ MultiArgMorph type: #boolean;
		yourself].
	"$w"'MANumber' = code ifTrue: [ ^ MultiArgMorph type: #number;
		yourself].
	"$X"'MAAny' = code ifTrue: [ ^ MultiArgMorph type: #any;
		yourself].
	"$z"'SpecialVar' = code ifTrue: [ ^ VariableBlockMorph new 
							isSpecialForm: true; 
							selector: #getVar:;
							commandSpec: '?';
		yourself].
	"$Z"'SAReporter' = code ifTrue: [ ^ SpecialArgMorph new type: #reporterslot;
		yourself].
	"$Y"'SABoolean' = code ifTrue: [ ^ SpecialArgMorph new type: #booleanslot;
		yourself].
	
	"$A"'Input' = code ifTrue: [ ^ ChoiceArgMorph new options: {'with inputs' localized. 'with input list' localized}; choice: 'with inputs';
		yourself].
	"$F"'Type' = code ifTrue: [ ^ ChoiceArgMorph new options: {'number' localized. 'text' localized. 'boolean' localized. 'list' localized. 'command' localized. 'reporter' localized. 'predicate' localized. 'object' localized}; choice: 'number' localized;
		yourself].

	"$G"'CArgSlot' = code ifTrue: [ ^ CArgSlotMorph new].
	"$J"'Loop' = code ifTrue: [ ^ MultiArgMorph type: #loop].

	"$j"'UnEExp' = code ifTrue: [ ^ UnevaluatedExpressionArgMorph new stringExpression: ''].
	"$q"'MAUneval' = code ifTrue: [ ^ MultiArgMorph type: #unevaluated].
	"$Q"'UnEBool' = code ifTrue: [ ^ UnevaluatedBooleanArgMorph new].
	"$K"'MAUnEBool' = code ifTrue: [ ^ MultiArgMorph type: #unevaluatedBoolean].

	"$1"'SAObjS' = code ifTrue: [ ^ SpecialArgMorph new type: #objSlot].
	"$2"'MAObjS' = code ifTrue: [ ^ MultiArgMorph type: #objSlot].	
	
	"$r"'Rotation' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #rotationStyleChanger; choice: 'normal';
		yourself].
	
	^self oldUncoloredArgMorphFor: specString.
	"^ ExpressionArgMorph new numExpression: '10'"
]

{ #category : #private }
CommandBlockMorph >> updateReferencesUsing: aDictionary [
	"Update my arg morphs."

	super updateReferencesUsing: aDictionary.
	argMorphs := argMorphs collect: [:m | aDictionary at: m ifAbsent: [m]].

]

{ #category : #byob }
CommandBlockMorph >> varNamesMenu [

	| blockVars objVars obj | 

	obj := self phratchObject.
	obj ifNil: [^#()].
	blockVars := self scriptVars asSortedCollection asArray.
	objVars := obj varNamesMenu asOrderedCollection.
	objVars removeAllSansError: blockVars.

	(#(
		doRun
		doRunBlockWithArgs
		doFork
		doForkBlockWithArgs
		doReport
		doCallBlockWithArgs
	) includes: selector )	
		ifTrue: [ ^ (objVars copyWith: #-), blockVars, #('')].

	^ (objVars copyWith: #-), blockVars
]

{ #category : #copying }
CommandBlockMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	receiver := deepCopier references at: receiver ifAbsent: [receiver].
	argMorphs := argMorphs collect: [:m | deepCopier references at: m ifAbsent: [m]]
]

{ #category : #copying }
CommandBlockMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	argPermutation := argPermutation veryDeepCopyWith: deepCopier.
	titleMorph := titleMorph veryDeepCopyWith: deepCopier.
	stopFrame := nil
]
