Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchROS' }
ScriptablePhratchMorph >> addGenericROSBlocksTo: page x: x y: startY [
	"Add the generic variable blocks to the given page starting at the given y offset. Answer the new y."

	| y |
	y := startY.

	(self blocksFor: 'ros') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].	"insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5]]	"insert a half space"
			ifFalse: [
				y := self createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: (ScriptablePhratchMorph blockColorFor: 'colors')]].

	^ y
]
