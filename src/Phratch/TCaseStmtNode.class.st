Class {
	#name : #TCaseStmtNode,
	#superclass : #TParseNode,
	#instVars : [
		'expression',
		'firsts',
		'lasts',
		'cases'
	],
	#category : #'Phratch-Primitives-C Translator'
}

{ #category : #'as yet unclassified' }
TCaseStmtNode >> bindVariableUsesIn: aDictionary [

	expression := expression bindVariableUsesIn: aDictionary.
	cases := cases collect: [ :c | c bindVariableUsesIn: aDictionary ].
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> bindVariablesIn: aDictionary [

	expression := expression bindVariablesIn: aDictionary.
	cases := cases collect: [ :c | c bindVariablesIn: aDictionary ].
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> cases [

	^cases
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> copyTree [

	^self class new
		setExpression: expression copyTree
		firsts: firsts copy
		lasts: lasts copy
		cases: (cases collect: [ :case | case copyTree ])
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> customizeCase: caseParseTree forVar: varName from: firstIndex to: lastIndex [
	"Return a collection of copies of the given parse tree, each of which has the value of the case index substituted for the given variable."

	| newCases dict newCase |
	newCases := OrderedCollection new.
	firstIndex to: lastIndex do: [ :caseIndex |
		dict := Dictionary new.
		dict at: varName put: (TConstantNode new setValue: caseIndex).
		newCase := caseParseTree copyTree bindVariableUsesIn: dict.
		self fixSharedCodeBlocksForCase: caseIndex in: newCase.
		newCases addLast: newCase.
	].
	^ newCases
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> customizeShortCasesForDispatchVar: varName [
	"Make customized versions of a short bytecode methods, substituting a constant having the case index value for the given variable. This produces better code for short bytecodes such as instance variable pushes that encode the index of the instance variable in the bytecode."

	| newFirsts newLasts newCases l f case expanded |
	newFirsts := OrderedCollection new.
	newLasts := OrderedCollection new.
	newCases := OrderedCollection new.
	1 to: cases size do: [ :i |
		l := lasts at: i.
		f := firsts at: i.
		case := cases at: i.
		expanded := false.
		(l - f) > 1 ifTrue: [  "case code covers multiple cases"
			case nodeCount < 60 ifTrue: [
				newFirsts addAll: (f to: l) asArray.
				newLasts addAll: (f to: l) asArray.
				newCases addAll: (self customizeCase: case forVar: varName from: f to: l).
				expanded := true.
			].
		].
		expanded ifFalse: [
			self fixSharedCodeBlocksForCase: f in: case.
			newFirsts addLast: f.
			newLasts addLast: l.
			newCases addLast: case.
		].
	].
	firsts := newFirsts asArray.
	lasts := newLasts asArray.
	cases := newCases asArray.

]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> emitCCodeOn: aStream level: level generator: aCodeGen [

	| indent |
	indent := (String new: level) collect: [ :ch | Character tab ].
	aStream nextPutAll: 'switch ('.
	expression emitCCodeOn: aStream level: level generator: aCodeGen.
	aStream nextPutAll: ') {'; cr.
	1 to: cases size do: [ :i |
		(firsts at: i) to: (lasts at: i) do: [ :caseIndex |
			aStream nextPutAll: indent, 'case ', caseIndex printString, ':'; cr.
		].
		(cases at: i) emitCCodeOn: aStream level: level + 1 generator: aCodeGen.
		aStream nextPutAll: indent; tab; nextPutAll: 'break;'.
		aStream cr.
	].
	level timesRepeat: [ aStream tab ].
	aStream nextPutAll: '}'.
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> expression [

	^expression
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> fixSharedCodeBlocksForCase: caseIndex in: caseParseTree [
	"Process 'sharedCode' directives in the given parse tree. The sharedCode directive allows code replicated in different arms of a case statement to be shared. The replicated code must be the final code of the case so that it ends with a break out of the case statement. The replicated code will be generated in exactly one arm of the case statement; other instances of the shared code will be replaced by branches to that single instance of the code."

	"NOTE: I have made this work for the nested case (ie several shared entry points in the same case, but it does not really work for methods with arguments.  A mechanism coud be added that would add a preamble of the form,
	innerSharedTemp = outerTemp;
when they differed.  There should at least be a test here."

	| copying oldStmts newStmts stmt codeBlockName |
	caseParseTree  nodesDo: [ :node |
		node isStmtList ifTrue: [
			copying := true.
			oldStmts := node statements asArray.
			newStmts := nil.  "becomes an OrderedCollection if sharedCode block is found"
			1 to: oldStmts size do: [ :i |
				copying ifTrue: [
					stmt := oldStmts at: i.
					(stmt isSend and: [stmt selector = #sharedCodeNamed:inCase:]) ifTrue: [
						newStmts == nil 
							ifTrue: [newStmts := (oldStmts copyFrom: 1 to: i - 1) asOrderedCollection]
							ifFalse: [newStmts removeLast "preserve any prior shared entry points - di"].
						codeBlockName := stmt args first value.
						(stmt args last value = caseIndex) ifTrue: [
							newStmts add: 
								(TLabeledCommentNode new setLabel: codeBlockName comment: '').
						] ifFalse: [
							newStmts add: (TGoToNode new setLabel: codeBlockName).
							copying := false.  "don't copy remaining statements"
						].
					] ifFalse: [
						newStmts = nil ifFalse: [newStmts add: stmt].
					].
				] ifFalse: [	"ikp: this permits explicit returns before 'goto aSharedCodeLabel'"
					stmt := oldStmts at: i.
					(stmt isLabel and: [stmt label ~= nil]) ifTrue: [newStmts add: stmt].
				].
			].
			newStmts = nil ifFalse: [node setStatements: newStmts].
		].
	].
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> inlineMethodsUsing: aDictionary [

	expression inlineMethodsUsing: aDictionary.
	cases do: [ :c | c inlineMethodsUsing: aDictionary ].
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> isCaseStmt [

	^true
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> nodesDo: aBlock [

	expression nodesDo: aBlock.
	cases do: [ :c | c nodesDo: aBlock ].
	aBlock value: self.
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> printOn: aStream level: level [

	aStream crtab: level.
	aStream nextPutAll: 'select '.
	expression printOn: aStream level: level.
	aStream nextPutAll: ' in'.
	1 to: cases size do: [ :i |
		(firsts at: i) to: (lasts at: i) do: [ :caseIndex |
			aStream crtab: level.
			aStream nextPutAll: 'case ', caseIndex printString, ':'.
		].
		aStream crtab: level + 1.
		(cases at: i) printOn: aStream level: level + 1.
	].
	aStream crtab: level.
	aStream nextPutAll: 'end select'.
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> removeAssertions [
	expression removeAssertions.
	cases do: [ :case | case removeAssertions ].
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [
		expression := expression replaceNodesIn: aDictionary.
		cases := cases collect: [ :c | c replaceNodesIn: aDictionary ].
		self]
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> setExpression: aNode firsts: firstsList lasts: lastsList cases: caseList [

	expression := aNode.
	firsts := firstsList.
	lasts := lastsList.
	cases := caseList.
]

{ #category : #'as yet unclassified' }
TCaseStmtNode >> setExpression: aNode selectors: selectorList arguments: anArray [
	"Initialize the node from the given set of selectors."
	"Note: Each case is a statement list with containing one statement, a send to self of a selector from the given selector list. Having statement list nodes makes inlining easier later."

	| selfNode stmt lastSel firstInRun sel |
	expression := aNode.
	selfNode := TVariableNode new setName: 'self'.
	firsts := OrderedCollection new: 400.
	lasts := OrderedCollection new: 400.
	cases := OrderedCollection new: 400.
	lastSel := selectorList first.
	firstInRun := 0.
	1 to: selectorList size do: [ :i |
		sel := selectorList at: i.
		sel ~= lastSel ifTrue: [
			firsts add: firstInRun.
			lasts add: i - 2.
			stmt := TSendNode new setSelector: lastSel receiver: selfNode arguments: anArray.
			cases add: (TStmtListNode new setArguments: #() statements: (Array with: stmt)).
			lastSel := sel.
			firstInRun := i - 1.
		].
	].
	firsts add: firstInRun.
	lasts add: selectorList size - 1.
	stmt := TSendNode new setSelector: lastSel receiver: selfNode arguments: anArray.
	cases add: (TStmtListNode new setArguments: #() statements: (Array with: stmt)).
]
