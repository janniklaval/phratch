Class {
	#name : #TableSpriteArgMorph,
	#superclass : #SpriteArgMorph,
	#category : #PhratchEducationalBureau
}

{ #category : #'as yet unclassified' }
TableSpriteArgMorph >> presentMenu [
	"Let the user select a Phratch object or the special value #mouse."

	| frame sel objList menu choice be |

	(frame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [
		be := self ownerOrYourselfThatIsABlockEditorFrameMorph.
		be ifNil: [^self].
		(frame := be phratchFrame) ifNil: [^ self]].

	(owner isCommandBlockMorph) ifTrue: [sel := owner selector].

	objList := frame phratchObjects select:[:e | e isKindOf: BlocksBoardMorph ].
	objList sort: [:obj1 :obj2 | obj1 objName asLowercase < obj2 objName asLowercase].

	menu := MenuMorph new.

"	menu add: '' action: #null.
"

	"(#(getAttribute:of: getObject: getSpawnOf: deleteSprite: attribute:of: stickTo: deleteObject:) includes: sel)
		ifFalse: [
			sel = #touching: ifTrue: [
				menu add: 'edge' localized
				target: self
				selector: #selectedItem:
				argument: #edge].
			objList := objList copyWithout: owner receiver]."

	objList size > 0 ifTrue: [menu addLine].
	objList do: [:obj | menu add: obj objName
		target: self
		selector: #selectedItem:
		argument: obj].

	(choice := menu invokeModal) ifNil: [^ self].
	morph := choice.
	self fixGetAttribueBlock.
	self updateLabel.

]
