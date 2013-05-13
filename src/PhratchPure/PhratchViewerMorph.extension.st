Extension { #name : #PhratchViewerMorph }

{ #category : #'*PhratchPure' }
PhratchViewerMorph >> rebuildCategorySelectors [

	| catList maxExtent buttons label offForm onForm overForm b pad leftColumnX rightColumnX x y |
	catList := #(
		motion		control
		looks		sensing
		sound		operators
		pen			variables
		files		colors
		pure).

	"First, delete the old category buttons"
	submorphs do: [:m | (m isKindOf: ResizableToggleButton2) ifTrue: [m delete]].

	"Create new buttons, keeping track of the maximum extent."
	maxExtent := 75@0.
	buttons := catList collect: [:cat |
		label := (PhratchTranslator translationFor: cat asString) capitalized.
		offForm := (PhratchFrameMorph skinAt: cat).
		onForm := (PhratchFrameMorph skinAt: (cat, 'Pressed')).
		overForm := (PhratchFrameMorph skinAt: (cat, 'Over')).
		PhratchTranslator isRTL
			ifTrue:[
				b := ResizableToggleButton2 new
					offForm:	(offForm flipBy: #horizontal centerAt: offForm center)
					onForm:		(onForm flipBy: #horizontal centerAt: onForm center)
					overForm:	(overForm flipBy: #horizontal centerAt: overForm center)]
			ifFalse:[
				b := ResizableToggleButton2 new
					offForm:	offForm
					onForm:		onForm
					overForm:	overForm].
		b
			label: label font: (PhratchFrameMorph getFont: #Category);
			setLabelColor: Color white;
			target: self;
			actionSelector: #currentCategory:;
			arguments: (Array with: cat);
			toggleButtonMode: true;
			toggleMode: false.
		PhratchTranslator isRTL
			ifTrue:[b rightJustifyInset: 10]
			ifFalse:[b leftJustifyInset: 10].
		maxExtent := maxExtent max: (b extent + (3 @ -6)).
		b].

	"calculate catButtonsExtent"
	pad := 15. "padding on left, right, and betwen the button columns"
	catButtonsExtent := ((2 * maxExtent x) + (3 * pad)) @ (((catList size +1 // 2) * (maxExtent y + 6)) + 25).

	"place the buttons"
	leftColumnX := self left + 12 + pad.
	rightColumnX := leftColumnX + maxExtent x + pad.
	x := leftColumnX.
	y := self top + 17.
	1 to: buttons size do: [:i |
		b := buttons at: i.
		b extent: maxExtent.
		self addMorph: (b position: x@y).
		i even
			ifTrue: [x := leftColumnX. y := y + b height + 6]
			ifFalse: [x := rightColumnX]].

	self width: catButtonsExtent x.
	pageViewer position: self position + (0@catButtonsExtent y).
	topSectionHeight := catButtonsExtent y - 4.

]
