"
I display a graph of numbers, normalized so the full range of values just fits my height. I support a movable cursor that can be dragged with the mouse.

Implementation notes: Some operations on me may be done at sound sampling rates (e.g. 11-44 thousand times/second). To allow such high bandwidth application, certain operations that change my appearance do not immediately report a damage rectangle. Instead, a flag is set indicating that my display needs to refreshed and a step method reports the damage rectangle if that flag is set. Also, I cache a bitmap of my graph to allow the cursor to be moved without redrawing the graph.

All indices, like startIndex, cursor, etc are in terms of the graph data.

IMPORTANT!  The current implementation cannot stand alone, it needs to be a submorph of SoundEditor.

"
Class {
	#name : #PhratchGraphMorph,
	#superclass : #GraphMorph,
	#instVars : [
		'selection',
		'scale',
		'ruler',
		'viewer',
		'negVals',
		'posVals',
		'editor'
	],
	#classVars : [
		'MinScale'
	],
	#category : #'Phratch-Sound'
}

{ #category : #'instance creation' }
PhratchGraphMorph class >> MinScale [

	^MinScale
]

{ #category : #'instance creation' }
PhratchGraphMorph class >> MinScale: aNumber [

	"aNumber should be equal to: viewer extent x/ graph data size"
	MinScale := aNumber asFloat.

]

{ #category : #'instance creation' }
PhratchGraphMorph class >> openOn: dataCollection [
	"Open a new GraphMorph on the given sequencable collection of data."

	^ (self new data: dataCollection) openInWorld

]

{ #category : #initialization }
PhratchGraphMorph >> addRuler [

	ruler := PhratchRulerMorph graphMorph: self.
	self addMorphBack: ruler.
	ruler position: self bottomLeft.

]

{ #category : #menu }
PhratchGraphMorph >> adjustSelection [
	"Adjust the selection, if any, to the current cursor position. Do nothing if there is no selection."

	editor selectionNil ifTrue: [^ self]. 
	editor selection: editor cursor scd: editor startSelection.


]

{ #category : #private }
PhratchGraphMorph >> calculateDataArray [

	| currIndex neg pos |

	negVals := OrderedCollection new.
	posVals := OrderedCollection new.

	data isEmpty ifTrue: [^ self]. 
	currIndex:= neg:=pos := 0.

	1 to: data size do: [ :i |
		((i * scale) truncated > currIndex)
			ifTrue: [
			
					currIndex := (i*scale) truncated.		
					neg := neg min: (data at: i).
					pos := pos max: (data at: i).
			
					posVals add: pos.
					negVals	add: neg.
		
					pos := neg := 0.]
			ifFalse: [
						neg := neg min: (data at: i).
						pos := pos max: (data at: i).].].
]

{ #category : #viewing }
PhratchGraphMorph >> computeSlider [
	
	editor slider sliderThickness: ((bounds width//scale)/data size)*(editor slider extent x).
	editor slider changed.
]

{ #category : #accessing }
PhratchGraphMorph >> customScale [
	"Called when the user wants to input a scale value."

	| answer |
	answer := UIManager default request: 'Please type desired scale:' initialAnswer: '2x'.
	answer size = 0 ifTrue: [^ self].
	answer := answer copyWithout: $x.
	self zoom: answer asNumber.

]

{ #category : #private }
PhratchGraphMorph >> drawCursorOn: aCanvas [

	| ptr x r c |
	ptr := (editor cursor asInteger max: 1) min: data size.
	c := cursorColor. 
	((ptr > 1) and: [ptr < data size]) ifTrue: [
		(data at: ptr) sign ~= (data at: ptr + 1) sign
			ifTrue: [c := cursorColorAtZeroCrossings]].
	r := self innerBounds.
	x := r left + ((ptr - startIndex)*scale).
	((x >= r left) and: [x <= r right]) ifTrue: [
		aCanvas fillRectangle: (x@r top corner: x + 1@r bottom) color: c].

]

{ #category : #private }
PhratchGraphMorph >> drawDataOn: aCanvas [

	| x start end left right yScale baseLine top bottom |
	super drawOn: aCanvas.

	viewer ifTrue: [self drawViewOn: aCanvas.].
	self drawSelectionOn: aCanvas.

	(posVals isNil) ifTrue: [^ self].

	maxVal = minVal ifTrue: [yScale := 1.] 
					ifFalse: [yScale := (bounds height - (2 * borderWidth)) asFloat / (maxVal - minVal)].
	baseLine := bounds bottom - borderWidth + (minVal * yScale) truncated.
 
	left := 0. right := 10.
	x := bounds left + borderWidth.

	start := (startIndex*scale) truncated min: data size max: 1.
	end := start + bounds width min: data size.

	start to: end do: [:i |
		i > posVals size ifTrue: [^self].
					
		left := x truncated. right := x + 1.
		right > (bounds right - borderWidth) ifTrue: [^ self].

		top := baseLine min: (baseLine - (yScale*(posVals at: i))) truncated.
		bottom := (baseLine max: baseLine - (yScale*(negVals at: i))) truncated.
											
		aCanvas fillRectangle: (left@top corner: right@bottom) color: dataColor.
		x := x + 1].
]

{ #category : #drawing }
PhratchGraphMorph >> drawOn: aCanvas [

	| |

	super drawOn: aCanvas.
	self drawPlayCursorOn: aCanvas.
	
]

{ #category : #private }
PhratchGraphMorph >> drawPlayCursorOn: aCanvas [

	| ptr x r c | 

	editor playCursor ifNil: [^self].
	(editor endPlaying ~= data size) & (editor playCursor >= (editor endPlaying)) ifTrue: [^self].

	ptr := (editor playCursor asInteger max: 1) min: data size.
	c := cursorColor.
	r := self innerBounds.
	x := r left + ((ptr - startIndex)*scale).
	((x >= r left) and: [x <= r right]) ifTrue: [
		aCanvas fillRectangle: (x@r top corner: x + 1@r bottom) color: c].

]

{ #category : #private }
PhratchGraphMorph >> drawSelectionOn: aCanvas [

	| x y lightColor darkColor v1 v2 offsetX s1 s2 bottom |

	editor selectionNil ifTrue: [^ self].

	lightColor := Color lightBlue. "(Color r: 0.2 g: 1.0 b: 0.907)."
	darkColor := lightColor darker darker darker.

	v1 := (editor graph startIndex asInteger max: 1) min: data size.
	v2 := v1 + (bounds width/(editor graph scale)) min: data size.
	
 
	offsetX := bounds left + borderWidth.
	x := (offsetX + ((selection first - startIndex)*scale)).
	y := bounds top + borderWidth.

	viewer 
		ifFalse: [
			selection first > v2 ifTrue: [^ self].  "selection is not visible"
			selection last < v1 ifTrue: [^ self].  "selection is not visible"

			aCanvas
				fillRectangle: (x@y extent: ((selection last - selection first)*scale)@(self height - (2 * borderWidth)))
				color: lightColor. "lightYellow"]
		ifTrue: [
			s1 := selection first.
			s2 := selection second.

			bottom := self height - (2 * borderWidth).


			((s1 max: s2) <= v1) | ((s1 min: s2) >= v2)
				ifTrue: [^aCanvas 				
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((s2-s1)*scale)@bottom)
							color: darkColor.].
			
			(s1 <= v1) & (s2 >= v2)
				ifTrue: [^aCanvas fillRectangle: ((offsetX + (s1*scale))@y extent: ((v1-s1)*scale)@bottom)
								color: darkColor;
								fillRectangle: ((offsetX + (v1*scale))@y extent: ((v2-v1)*scale)@bottom)
								color: lightColor;
								fillRectangle: (( offsetX + (v2*scale))@y extent: ((s2-v2)*scale)@bottom)
								color: darkColor.].
			
			(s1 >= v1) & (s2 <= v2)
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((s2-s1)*scale)@bottom)
							color: lightColor.].
	
			(s1 < v1) & (s2 > v1) & (s2 < v2)
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((v1-s1)*scale)@bottom)
							color: darkColor;
							fillRectangle: ((offsetX + (v1*scale))@y extent: ((s2- v1)*scale)@bottom)
							color: lightColor.].
		
			(s1 >= v1) & (s2 >= v2) 
				ifTrue: [^aCanvas
							fillRectangle: ((offsetX + (s1*scale))@y extent: ((v2-s1)*scale)@bottom)
							color: lightColor;
							fillRectangle: ((offsetX + (v2*scale))@y extent: ((s2 - v2)*scale)@bottom)
							color: darkColor.].

			"Transcript show: 'no category :(';cr."

			].




]

{ #category : #private }
PhratchGraphMorph >> drawViewOn: aCanvas [

	"highlights the part of the graph morph we're viewing."
	| y ex start x |

	viewer ifFalse: [^self]. 
	
	
	start := ((editor graph startIndex*bounds width)/data size) truncated min: data size.
	ex:= ((editor slider sliderThickness/editor slider extent x)*(bounds width)) min: data size.

	x := (bounds left + borderWidth + start).
	y := bounds top + borderWidth.

	aCanvas
		fillRectangle: (x@y extent: ex@(self height - (2 * borderWidth)))
		color: Color white. "lightYellow".

]

{ #category : #accessing }
PhratchGraphMorph >> editor [

	^editor 
]

{ #category : #accessing }
PhratchGraphMorph >> editor: aSoundEditor [

	editor := aSoundEditor. 
]

{ #category : #events }
PhratchGraphMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
PhratchGraphMorph >> initialize [

	super initialize.
	self color: (Color r: 0.8 g: 0.8 b: 0.6).
	self borderWidth: 2.
	playCursorColor := Color blue.
	viewer := false.
	selection := {nil. nil}.
	scale := 1.0.
	posVals := negVals := nil.
	
	

]

{ #category : #events }
PhratchGraphMorph >> mouseDown: evt [

	"Handles mouse down and drag events.  Updates the cursor's position and sets the selection to an array containing two copies of the current cursor value."
	| x s |

	 x := evt cursorPoint x - (bounds left + borderWidth).

	s := editor startSelection.
	editor startSelection: editor cursor.   
	editor cursor: startIndex + (x/scale).
		
	evt shiftPressed
		ifTrue: [  editor selectionNil 
					ifFalse: [
						editor startSelection: s.
				  		self adjustSelection.].]
		ifFalse: [
				 ((editor selectionNil not) and: [(selection at: 2) - (selection at: 1) > 3])
						ifTrue: [ editor selection: nil.
			  				      self flushCachedForm.
				 				 self changed.].
			  	 editor startSelection: editor cursor.
				 editor selection: {editor cursor. editor cursor}.].


	 
	
	
]

{ #category : #events }
PhratchGraphMorph >> mouseMove: evt [

	"Updates the cursor position as the mouse moves.  Adjusts the selection only if the mouse is currently being pressed"
	| x w |

	x := evt cursorPoint x - (bounds left + borderWidth). 
	w := self width - (2 * borderWidth).

	(viewer not and: [x < 0]) ifTrue: [
		editor cursor: startIndex + (x /scale).
		self adjustSelection.
		editor slider setValue: (startIndex/data size).
		^ self startIndex: self editor cursor].
	(viewer not and: [x > w]) ifTrue: [
		editor cursor: startIndex + (x /scale).
		self adjustSelection.
		editor slider setValue: (startIndex/data size).
		^ self startIndex: editor cursor - (w/scale) truncated.
		"^ editor cursor = data size
			ifTrue: [ self startIndex: editor cursor - (w/(scale*2)) truncated.]
			ifFalse: [ self startIndex: editor cursor - (w/scale) truncated.]."].


	evt anyButtonPressed 
		ifTrue: [editor cursor: (startIndex + (x/scale) truncated).
				self adjustSelection.]

]

{ #category : #events }
PhratchGraphMorph >> mouseUp: evt [

	((editor selectionNil not) and: [(selection at: 2) - (selection at: 1) <=3])
		ifTrue: [editor selection: nil.
				editor startSelection: nil.]. 

]

{ #category : #menu }
PhratchGraphMorph >> readDataFromFile [

	| result fName menu |
	menu := MenuMorph new defaultTarget: self.
	#(aif aiff au wav) do:[:aVarName |
		menu add: aVarName
			target: self 
			selector: #readDataKind:
			argument: aVarName.
	].
	menu localize; popUpInWorld.
	
]

{ #category : #menu }
PhratchGraphMorph >> readDataKind: aKind [
	
	| fName |
	fName :=  FileSystem workingDirectory / 'Sound' / aKind.
	self data: (SampledSound fromFileNamed: fName) samples.


]

{ #category : #accessing }
PhratchGraphMorph >> scale [
	
	^scale.
]

{ #category : #accessing }
PhratchGraphMorph >> scale: aNumber [

	"setting the absolute scale of how the graph is display.  It is relative to MinScale, the minimum scale possible, which is the scale value of the viewer."

	aNumber < 1 ifTrue: [^self]. 
	scale := (aNumber*MinScale) asFloat min: 1.
	
	self calculateDataArray.
	self flushCachedForm; changed.
	editor viewer flushCachedForm; changed.

	editor updateSlider.

]

{ #category : #accessing }
PhratchGraphMorph >> selection [

	^ selection

]

{ #category : #accessing }
PhratchGraphMorph >> selection: anArrayOrNil [
	"Set the selection to the given (startIndex, stopIndex) pair to to nil."

	anArrayOrNil
		ifNil: [	selection at: 1 put: nil. selection at: 2 put: nil]
		ifNotNil: [ selection := anArrayOrNil.].


]

{ #category : #viewing }
PhratchGraphMorph >> setScale [

	| menu choice |

	menu := MenuMorph new defaultTarget: self.
	menu add: '1x' target: self selector: #setScaleBy: argument: 1;
		   add: '2x' target: self selector: #setScaleBy: argument: 2;
		   add: '3x' target: self selector: #setScaleBy: argument: 3;
		   add: '4x' target: self selector: #setScaleBy: argument: 4;
		   add: '5x' target: self selector: #setScaleBy: argument: 5;
		   add: 'other' target: self selector: #setScaleBy: argument: #customScale.
	menu popUpInWorld.
	
	
]

{ #category : #'as yet unclassified' }
PhratchGraphMorph >> setScaleBy: choice [

	choice = #customScale 
		ifFalse: [self scale: choice.]	
		ifTrue: [ self customScale].
]

{ #category : #stepping }
PhratchGraphMorph >> stepTime [

	^150
]

{ #category : #viewing }
PhratchGraphMorph >> viewSelection [ 

	| diff |
	selection ifNil: [^self].
	scale := (MinScale*(data size/(selection second - selection first)) asFloat min: 1).
	self calculateDataArray.

	diff := (selection second - selection first) - bounds width.
	diff < 0
		ifTrue: [ self startIndex: selection first asInteger + (diff//2)]
		ifFalse: [self startIndex: selection first asInteger.].
	
	
	editor updateSlider.


	
]

{ #category : #accessing }
PhratchGraphMorph >> viewer: aBoolean [

	viewer := aBoolean. "whether or not this graphMorph is the viewer graph Morph"
	
	viewer ifFalse: [self color: Color white.]. 
]

{ #category : #viewing }
PhratchGraphMorph >> zoom: aNumber [ 

	scale := ((scale*aNumber asFloat) max: MinScale asFloat) min: 1.
	
	self calculateDataArray.
	self flushCachedForm; changed.
	editor viewer flushCachedForm; changed.

	editor updateSlider.
]

{ #category : #viewing }
PhratchGraphMorph >> zoomIn [

	self zoom: 2.
]

{ #category : #viewing }
PhratchGraphMorph >> zoomOut [

	self zoom: 0.5.
]
