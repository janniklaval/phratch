Extension { #name : #MenuMorph }

{ #category : #'*Phratch' }
MenuMorph >> add: aString toolTip: tString action: aSelector [

	^ self add: aString action: aSelector
]

{ #category : #'*Phratch' }
MenuMorph >> addIcon: aForm tooltip: aString selector: aSymbol argument: arg [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	| item |
	item := FormMenuItemMorph new
		form: aForm;
		contents: '';
		setBalloonText: aString;
		target: defaultTarget;
		selector: aSymbol;
		arguments: {arg}.
	self addMorphBack: item.



]

{ #category : #'*Phratch' }
MenuMorph class >> fromScratch: aPopupMenu title: titleStringOrNil [
	"Answer a MenuMorph constructed from the given PopUpMenu. Used to simulate MVC-style menus in a Morphic-only world."

	| menu items lines selections labelString j forms |
	menu := self new.
	titleStringOrNil ifNotNil: [
		titleStringOrNil isEmpty ifFalse: [menu addTitle: titleStringOrNil]].
	
	labelString := aPopupMenu labelString.
	items := labelString asString lines.
	labelString isText ifTrue:
		["Pass along text emphasis if present"
		j := 1.
		items := items collect:
			[:item | | emphasis |
			j := labelString asString findString: item startingAt: j.
			emphasis := TextEmphasis new emphasisCode: (labelString emphasisAt: j).
			item asText addAttribute: emphasis]].
	lines := aPopupMenu lineArray.
	lines ifNil: [lines := #()].
	menu cancelValue: 0.
	menu defaultTarget: menu.
	selections := (1 to: items size) asArray.
	
	forms := aPopupMenu forms.
	forms ifNil: [forms := Array empty ].
	(forms size = items size) ifFalse: [
		forms := Array new: items size ].
	
	1 to: items size do: [:i |
		| icon |
		icon := forms at: i.
		icon isNil
		ifTrue: [ menu add: (items at: i) selector: #selectMVCItem: argument: (selections at: i) ]
		ifFalse: [ menu addIcon: icon first tooltip: icon second selector: #selectMVCItem: argument: (selections at: i)].
		(lines includes: i) ifTrue: [menu addLine]].
	^ menu

]

{ #category : #'*Phratch' }
MenuMorph >> labels [

	^ self menuItems 
]

{ #category : #'*Phratch' }
MenuMorph >> localize [

	"not yet implemented"
]

{ #category : #'*Phratch' }
MenuMorph >> popUpAt: aPosition inWorld: aWorld [
	"Present this menu under control of the given hand."
	^self popUpAt: aPosition forHand: aWorld primaryHand in: aWorld

]
