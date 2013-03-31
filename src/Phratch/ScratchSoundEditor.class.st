"
A sound editor, based on the wave editor.  It can be brought up by the SoundMorph.  When the soundEditor is brought up, it is created with a copy of the sound in the sound morph. It contains the sound of the soundmorph and is capable of editing that sound.  That sound is set in the method ""sound:""

""viewing""
graph 					GraphMorph			
viewer					GraphMorph
selection 				    Array				an array of 2 #s that are the start and end of the selection.  This and the next 2 												variables are in terms of indices of the graph data
startSelection 			   Number				a number indicating the constant pt in a selection (mouse down loc)
cursor					   Number				a number indicating the location of the cursor

""Scrolling in view""
scrollDelta			        Number				a number telling us how much to scroll by, used in stepping to allow scrolling by 												buttons
slider					   slider morph			a slider for the graph
time					   a number			where we are in the graph in terms os msecs
deltaVal 					number				how much the cursor scrolls by, scrolldelta is set to +- this value
fwdButton 					button				scolling
backButton     				button				scrolling

""Playing variables"" 
origSamplingRate 		  big number			indicates the sampling rate of the song @ loading
												so u can reset to that sampling rate.
samplingRate 	         another big number		indicates current sampling rate.	
(2 above aren't currently used)

volume					   slider morph			indicates volume, (0 to 1.0)		
preview						boolean 			whether we're in play all mode or play 	from 												cursor mode, where the cursor moves along with 												the music
""Sound manipulation""
snd 						SampledSound		Current sound used for playing from cursor + selection
completeSnd 				SampledSound		The entire song after editing (doesn't change with playing)
soundMorphSound   			SampledSound		a ref to the sound of the SoundMorph that created this, 
												so that u can change the sound within that sound editor

""Editing tools""
copy						SoundBuffer		the portion of the graph data that has been copied
undoSound 					SampledSound		the sound before any cuts/pastes crops
undoSel 					Array				a copy of the selection bf any cut/paste/crop


rateSlider 					currently not implemented
keyboard
"
Class {
	#name : #ScratchSoundEditor,
	#superclass : #AlignmentMorph,
	#instVars : [
		'client',
		'soundName',
		'graph',
		'viewer',
		'selection',
		'startSelection',
		'playCursor',
		'cursor',
		'origSamplingRate',
		'samplingRate',
		'rateSlider',
		'slider',
		'volume',
		'snd',
		'completeSnd',
		'soundMorphSound',
		'copy',
		'time',
		'scrollDelta',
		'deltaVal',
		'fwdButton',
		'backButton',
		'undoSound',
		'undoSel',
		'undoCursor',
		'undoScale',
		'endPlaying'
	],
	#category : #'Phratch-Sound'
}

{ #category : #icons }
ScratchSoundEditor class >> downArrow [

	^ Form
		extent: 10@12
		depth: 4
		fromArray: #(3722304989 3707764736 3722304989 3707764736 3704479196 3170893824 3692739489 3170893824 3550548241 1023410176 3720417563 3707764736 3711570339 3707764736 3722121645 3707764736 3722252605 3707764736 3722296285 3707764736 3722261469 3707764736 3722304989 3707764736)
		offset: 0@0

]

{ #category : #'instance creation' }
ScratchSoundEditor class >> openOn: dataCollection [
	"Open a new WaveEditor on the given sequencable collection of data."

	^ (self new data: dataCollection) openInWorld

]

{ #category : #icons }
ScratchSoundEditor class >> upArrow [
	"Uparrow form used in slider." 

	^ Form
		extent: 6@3
		fromArray: #(2r11e28 2r1111e27 2r111111e26)
		offset: 0@0

]

{ #category : #initialization }
ScratchSoundEditor >> addControls [

	| b r spacer |
	b := SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners.
	b borderColor: #raised; borderWidth: 3.
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	spacer := Morph new color: r color; extent: 40@5.  "spacer"
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'undo';		actionSelector: #undo).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'copy';		actionSelector: #copy).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'paste';		actionSelector: #paste).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'cut';		actionSelector: #cut).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'crop';		actionSelector: #crop).	
	r addMorphBack: (spacer fullCopy width: 25).
	r addMorphBack: (b copy target: graph;
							label: 'zoom selection';	actionSelector: #viewSelection).

	r addMorphBack: (spacer fullCopy width: 25).
	r addMorphBack: (b fullCopy label: 'okay';			actionSelector: #save).
	r addMorphBack: (spacer fullCopy width: 5).
	r addMorphBack: (b fullCopy label: 'cancel';		actionSelector: #cancel).

	self addMorphBack: r.


]

{ #category : #initialization }
ScratchSoundEditor >> addGraph [

	| r |
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: graph.
	r addMorphBack: (AlignmentMorph newSpacer: r color).
	self addMorphBack: r.

]

{ #category : #initialization }
ScratchSoundEditor >> addPlayButtons [

	| b r m space n scaleSelector |
	b := SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners.
	b borderColor: #raised; borderWidth: 3.
	r := AlignmentMorph newColumn.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #topCenter.

	m := AlignmentMorph newRow.
	m color: Color transparent; borderWidth: 0; inset: 0.
	m hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	m centering: #center; cellPositioning: #leftCenter.

	space := Morph new color: r color; extent: 3@5.

	n := ScratchStringMorph new contents: 'Zoom to: '.
	m addMorphBack: n.

	scaleSelector :=  (IconicButton new
		labelGraphic: self class downArrow;
		extent: 15@15;
		color: Color transparent;
		borderWidth: 0;
		target: graph;
		actWhen: #buttonDown;
		actionSelector: #setScale).
	m addMorphBack: scaleSelector.
	m addMorphBack: (Morph new color: r color; extent: 5@5).
	m addMorphBack: (b copy target: graph; label: '+';			actionSelector: #zoomIn).
	m addMorphBack: (Morph new color: r color; extent: 5@5).
	m addMorphBack: (b copy target: graph; label: '-';			actionSelector: #zoomOut).

	"n := UpdatingStringMorph new
	target: graph;
	getSelector: #scale; 
	growable: false; width: 25; step.
	m addMorphBack: n."


	m addMorphBack: (Morph new color: r color; extent: 50@5).
	
	
	m addMorphBack: (b fullCopy label: 'Play All';			actionSelector: #playAll).
	m addMorphBack: space copy.
	m addMorphBack: (b fullCopy label: 'Play';				actionSelector: #playAfterCursor).
	m addMorphBack: space copy.
	m addMorphBack: (b fullCopy label: 'Stop';				actionSelector: #stop).

	m addMorphBack: (Morph new color: r color; extent: 50@5).
	m addMorphBack: (ScratchStringMorph new contents: 'Volume').
	m addMorphBack: space copy.
	
	volume := SimpleSliderMorph new
	color: Color veryVeryLightGray;
	extent: 60@2;
	target: self;
	actionSelector: #setVolume:.

	m addMorphBack: volume.

	m addMorphBack: (Morph new color: r color; extent: 50@5).

	r addMorphBack: (Morph new color: r color; extent: 5@5).
	r addMorphBack: m.
	

	self addMorphBack: r.


]

{ #category : #initialization }
ScratchSoundEditor >> addSlider [

	| r m spacer |
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.	
	
	spacer := Morph new color: r color; extent: (graph left -10)@5.
	backButton := self makeSliderButton: 10@13.
	backButton addMorphCentered: (ImageMorph new form: (self class upArrow rotateBy: #left centerAt: 0@0)).

	fwdButton := self makeSliderButton: 10@13.
	fwdButton addMorphCentered: (ImageMorph new form: (self class upArrow rotateBy: #right centerAt: 0@0)).
	
	slider := SimpleSliderMorph new
		color: Color veryVeryLightGray;
		extent: (graph width)@2;
		target: self;
		setMaxVal: (graph bounds width/(graph scale*graph data size));
		actionSelector: #scrollTime:.
	
	r addMorph: spacer.
	r addMorph: fwdButton.
	r addMorph: slider.
	r addMorph: backButton.
	
	m := Morph new color: r color; extent: 15@5.  "spacer"
	r addMorphBack: m.
	time := UpdatingStringMorph new
		target: self;
		getSelector: #startTime; 
		width: 40; step.
	time useStringFormat.
	r addMorphBack: time.

	self addMorphBack: r.

]

{ #category : #initialization }
ScratchSoundEditor >> addValueSelectors [

	| r m b |
	b := SimpleButtonMorph new target: self; borderColor: Color black; useSquareCorners.
	b borderColor: #raised; borderWidth: 3.
	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	r addMorphBack: (Morph new color: r color; extent: 5@5).

	"r addMorphBack: (b fullCopy label: '<<';					actionSelector: #slower)."
	r addMorphBack: (b fullCopy label: 'Reset Play Rate';	actionSelector: #resetSamplingRate).
	"r addMorphBack: (b fullCopy label: '>>';					actionSelector: #faster)."

	r addMorphBack: (Morph new color: r color; extent: 25@5).
	m := ScratchStringMorph new contents: 'Sampling Rate'.
	r addMorphBack: m.
	m := Morph new color: r color; extent: 5@5. "spacer"
	r addMorphBack: m.

	rateSlider := SimpleSliderMorph new
	color: Color veryVeryLightGray;
	extent: 60@2;
	target: self;
	minVal: 0.2;
	maxVal: 2.5;
	actionSelector: #samplingRate:.
	r addMorphBack: rateSlider.
	r addMorphBack: (Morph new color: r color; extent: 30@5).

	m := ScratchStringMorph new contents: 'Index: '.
	r addMorphBack: m.
	m := UpdatingStringMorph new
		target: graph; getSelector: #cursor; putSelector: #cursor:;
		growable: false; width: 30; step.
	r addMorphBack: m.
	
	m:= Morph new color: r color; extent: 20@5. "spacer"
	r addMorphBack: m.

	m := ScratchStringMorph new contents: 'Value: '.
	r addMorphBack: m.
	m := UpdatingStringMorph new
		target: graph; getSelector: #valueAtCursor; putSelector: #valueAtCursor:;
		growable: false; width: 40; step.
	r addMorphBack: m.

	m := Morph new color: r color; extent: 20@5. "spacer"
	r addMorphBack: m.

	"r addMorphBack: ( b fullCopy label: 'zoom to selection';		actionSelector: #zoomToSelection).
	m := Morph new color: r color; extent: 5@5.
	r addMorphBack: m."

	self addMorphBack: r.


]

{ #category : #initialization }
ScratchSoundEditor >> addViewer [

	| r |

	r := AlignmentMorph newRow.
	r color: Color transparent; borderWidth: 0; inset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r centering: #center; cellPositioning: #leftCenter.

	r addMorphBack: (AlignmentMorph newSpacer: r color).
	r addMorphBack: viewer.
	r addMorphBack: (AlignmentMorph newSpacer: r color).

	self addMorphBack: r.
	

]

{ #category : #'graph ops' }
ScratchSoundEditor >> back [
	"Moves the cursor back in the music score."

	scrollDelta := -5.  
	self cursor: cursor + scrollDelta.
]

{ #category : #'graph ops' }
ScratchSoundEditor >> cancel [

	self delete.

]

{ #category : #accessing }
ScratchSoundEditor >> client: anObject [

	client := anObject.

]

{ #category : #'graph ops' }
ScratchSoundEditor >> copy [

	"copies the current selection if there is one."
	(selection at: 1) ifNotNil:
		[copy := graph data copyFrom: (graph selection at: 1) to: (graph selection at: 2).]
]

{ #category : #'graph ops' }
ScratchSoundEditor >> crop [
	
	| sel |

	"Crops the sound in the sound editor to be only the selected region"

	sel := ((selection at: 1) notNil and: [(selection at: 2) - (selection at: 1) > 3]).
	sel ifFalse: [^self].

	undoSel := graph selection copy.
	undoSound := SampledSound samples: graph data samplingRate: samplingRate.
	undoCursor := cursor.
	undoScale := graph scale/ScratchGraphMorph MinScale.

	sel := graph data copyFrom: (selection at: 1) to: (selection at: 2).
	graph data: sel.
	viewer data: graph data.
	cursor := ((cursor - (selection at: 1)) truncated max: 1) min: graph data size truncated.

	"scales the botton viewer so that the data fits on the entire screen." 
	(selection second - selection first)/graph data size >= 0.05
		ifTrue: [ScratchGraphMorph MinScale: (viewer extent x/ graph data size min: 1). "the mult factor in all scales, the minimum scale allowed...to get this just do self scale: 1, since this multiplied by input"
				viewer scale: 1.
				graph scale: 1.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: sel samplingRate: samplingRate.
	completeSnd setSamples: sel samplingRate: samplingRate.

	selection at: 1 put: 1.
	selection at: 2 put: graph data size.

]

{ #category : #accessing }
ScratchSoundEditor >> cursor [

	^cursor.
]

{ #category : #accessing }
ScratchSoundEditor >> cursor: aNumber [

	graph data ifNil: [^self].

	cursor ~= aNumber ifTrue:  [
	cursor := ((aNumber truncated max: 1) min: graph data size) truncated.
	"graph keepIndexInView: cursor."
	].
]

{ #category : #'graph ops' }
ScratchSoundEditor >> cut [ 

	| data1 data2 |
	(selection at: 1) ifNil: [^ self.].

	undoSound := SampledSound samples: graph data samplingRate: samplingRate.
	undoSel := graph selection copy.
	undoCursor := cursor.
	undoScale := graph scale/ScratchGraphMorph MinScale.

	self copy.
	data1 := graph data copyFrom: 1 to: (selection at: 1).
	data2 := graph data copyFrom: (selection at: 2) to: graph data size.
	
	graph data: (data1, data2).
	viewer data: graph data.
		
	"scales the botton viewer so that the data fits on the entire screen." 
	((selection second - selection first)/graph data size asFloat) >= 0.05
		ifTrue: [ScratchGraphMorph MinScale: (viewer extent x/ graph data size min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.
	cursor := (selection at: 1).
	
	selection at: 1 put: nil. 
	selection at: 2 put: nil.
]

{ #category : #accessing }
ScratchSoundEditor >> data: newData [

	graph data: newData.

]

{ #category : #accessing }
ScratchSoundEditor >> endPlaying [

	^endPlaying.
]

{ #category : #menu }
ScratchSoundEditor >> faster [

	| rate |
	rate := rateSlider getScaledValue*1.1.
	rateSlider setScaledValue: rate.
	self samplingRate: rate.

	
]

{ #category : #'graph ops' }
ScratchSoundEditor >> fixSliderRange [

	slider maxVal: (1 -(slider sliderThickness/slider extent x)).
	^slider
]

{ #category : #'graph ops' }
ScratchSoundEditor >> fwd [
	
	"moves the cursor forward in the music."
	scrollDelta := 5.
	self cursor: cursor + 5.
]

{ #category : #accessing }
ScratchSoundEditor >> graph [

	^ graph

]

{ #category : #'event handling' }
ScratchSoundEditor >> handlesMouseDown: evt [

	| p |
	p := evt cursorPoint.
	^ (Rectangle origin: backButton topLeft corner: fwdButton bottomRight) containsPoint: p.
]

{ #category : #'event handling' }
ScratchSoundEditor >> handlesMouseOver: evt [

	^true.
]

{ #category : #initialization }
ScratchSoundEditor >> initialize [

	super initialize.
	copy := nil.
	selection := {nil. nil}.
	scrollDelta := 0.
	deltaVal := 10.
	cursor := 200.
	playCursor := nil.
	samplingRate := SoundPlayer samplingRate.
	soundName := 'sound'.
	self extent: 5@5;
		orientation: #vertical;
		centering: #centered;
		cellPositioning: #topCenter;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		inset: 3;
		color: Color lightGray;
		borderWidth: 2.
	graph := ScratchGraphMorph new extent: 380@150.
	graph editor: self.
	graph selection: selection.
	graph addRuler.
	graph viewer: false.

	viewer := ScratchGraphMorph new extent: 380@30.
	viewer editor: self.
	viewer cursorColorAtZeroCrossings: Color red.
	viewer viewer: true.
	viewer selection: selection.

	self addControls.
	self addPlayButtons.
	self addMorphBack: (Morph new color: self color; extent: 10@5).

	self addGraph.
	self addMorphBack: (Morph newBounds: (0@0 extent: 0@3) color: Color transparent).
	self addSlider.

	self addViewer.
	viewer left: backButton right.

]

{ #category : #menu }
ScratchSoundEditor >> invokeMenu [
	"Invoke a menu of additonal functions."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addList:	#(
		('save to file'		saveToFile)
		('read from file'	readFromFile)).
	aMenu popUpInWorld.


]

{ #category : #'event handling' }
ScratchSoundEditor >> keyStroke: evt [

	| keyVal |
	keyVal := evt keyCharacter asciiValue.

	keyVal = 28 ifTrue: [ cursor := cursor + (( -10) / graph scale)].
	keyVal = 29 ifTrue: [ cursor := cursor + (10/graph scale)].
]

{ #category : #initialization }
ScratchSoundEditor >> makeSliderButton: buttonExtent [

	| button |
	button := BorderedMorph
		newBounds: (self innerBounds bottomRight - buttonExtent extent: buttonExtent)
		color: Color lightGray.

	button setBorderWidth: 1 borderColor: #raised.
	^ button

]

{ #category : #'event handling' }
ScratchSoundEditor >> mouseDown: evt [

	| p |
	"do stuff"
	p := evt cursorPoint.
	

	(slider containsPoint: p) ifTrue: [ 
		slider descending ifTrue: [scrollDelta := deltaVal negated.]
						  ifFalse: [scrollDelta := deltaVal.].].
	(backButton containsPoint: p) ifTrue: [ backButton borderInset. scrollDelta := deltaVal negated ].
	(fwdButton containsPoint: p) ifTrue: [ fwdButton borderInset. scrollDelta := deltaVal].
]

{ #category : #'event handling' }
ScratchSoundEditor >> mouseEnter: evt [

	evt hand newKeyboardFocus: self.
]

{ #category : #'event handling' }
ScratchSoundEditor >> mouseUp: evt [

	"do stuff"
	scrollDelta := 0.
	fwdButton borderRaised.
	backButton borderRaised.

]

{ #category : #other }
ScratchSoundEditor >> normalize: sampleArray [
	"Return a copy of the given sample array scaled to use the maximum 16-bit sample range. Remove any D.C. offset."

	| max abs scale out |
	max := 0.
	sampleArray do: [:s |
		s > 0 ifTrue: [abs := s] ifFalse: [abs := 0 - s].
		abs > max ifTrue: [max := abs]].
	scale := ((1 << 15) - 1) asFloat / max.

	out := sampleArray species new: sampleArray size.
	1 to: sampleArray size do: [:i |
		out at: i put: (scale * (sampleArray at: i)) truncated].
	^ out

]

{ #category : #menu }
ScratchSoundEditor >> origSamplingRate [

	^origSamplingRate.

]

{ #category : #'graph ops' }
ScratchSoundEditor >> paste [
	| data1 data2 |
	"inserts the copied data into the dataset where the cursor is."
	
	copy ifNil: [^self ].
	
	"self selectionNil ifTrue: [undoSel := nil.] ifFalse: [undoSel := selection copy.]."
	undoSel := selection copy.
	undoSound := SampledSound samples: graph data samplingRate: samplingRate.
	undoCursor := cursor.
	undoScale := graph scale/ScratchGraphMorph MinScale.


	((self selectionNil not) and: [(selection at: 2) - (selection at: 1) > 3])
		ifTrue: [data1 := graph data copyFrom: 1 to: (graph selection at: 1).
			     data2 := graph data copyFrom: (graph selection at: 2) to: graph data size.]
		ifFalse: [data1 := graph data copyFrom: 1 to: graph cursor truncated.
				 data2 := graph data copyFrom: graph cursor truncated + 1 to: graph data size.].
	
	graph data: (data1, copy, data2).
	viewer data: graph data.

	"scales the botton viewer so that the data fits on the entire screen." 
	(copy size)/graph data size >= 0.05
		ifTrue: [ScratchGraphMorph MinScale: (viewer extent x/ graph data size min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				self fixSliderRange.
				viewer startIndex: 1.
				graph computeSlider.].

	

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.

	self selection: {data1 size. (data1 size) + (copy size).}.
	cursor := selection at: 2.
	graph startIndex: (slider getScaledValue)*(graph data size).

	viewer flushCachedForm.
		
]

{ #category : #menu }
ScratchSoundEditor >> pause [

	(snd notNil and: [snd isPlaying])
		ifTrue: [snd pause.].

]

{ #category : #initialization }
ScratchSoundEditor >> playAfterCursor [

	| sel currSel |
	graph data size < 2 ifTrue: [^ self].
	

	sel := ((selection at: 1) notNil and: [(selection at: 2) - (selection at: 1) > 3]).
	sel ifTrue: [currSel := graph data copyFrom: (selection at: 1) asInteger to: (selection at: 2) asInteger. playCursor := selection at: 1.
			    endPlaying := selection at: 2.]
	    ifFalse: [currSel := graph data copyFrom: (cursor max: 1) asInteger to: graph data size.
				playCursor := cursor.
				endPlaying := graph data size].
	
		self changed.


	snd isNil
		ifTrue: [
				 snd := (SampledSound samples: currSel samplingRate: origSamplingRate).
				 snd play.]
		ifFalse: [
			currSel = snd samples
				ifTrue: [snd samplesRemaining = 0 ifTrue: [snd reset].
						 snd resumePlaying.]
				ifFalse: [ snd setSamples: currSel samplingRate: origSamplingRate.
						 snd play]].


]

{ #category : #menu }
ScratchSoundEditor >> playAll [

	"Resumes playing the selection if there is one, otherwise resumes playing the entire soundtrack."

	graph data size < 2 ifTrue: [^ self].
	playCursor := 1.
	endPlaying := graph data size.

	snd isNil
		ifTrue: [
				 snd := (SampledSound samples: graph data samplingRate: origSamplingRate).
				 snd play.]
		ifFalse: [
			snd reset.
			(graph data = snd samples)
				ifTrue: [snd samplesRemaining = 0 ifTrue: [snd reset].
						 snd resumePlaying.]
				ifFalse: [snd setSamples: graph data samplingRate: origSamplingRate.
						 snd play]]

]

{ #category : #accessing }
ScratchSoundEditor >> playCursor [
	
	^playCursor.
]

{ #category : #accessing }
ScratchSoundEditor >> playCursor: aNumber [

	graph data ifNil: [^self].

	"allows the graph to set where the playing cursor is"

	cursor ~= aNumber ifTrue:  [
	cursor := ((aNumber truncated max: 1) min: graph data size) truncated.
	].
]

{ #category : #menu }
ScratchSoundEditor >> playFrom: start to: end [

	| sz i1 i2 snd2 |
	sz := graph data size.
	i1 := ((start + 1) min: sz) max: 1.
	i2 := ((end + 1) min: sz) max: i1.
	(i1 + 2) >= i2 ifTrue: [^ self].
	snd2 := SampledSound
		samples: (graph data copyFrom: i1 to: i2)
		samplingRate: samplingRate.
	snd2 play.

]

{ #category : #menu }
ScratchSoundEditor >> readFromFile [
	"Read my samples from a file selected by the user."

	| result menu |
	
	menu := MenuMorph new defaultTarget: self.
	#(aif aiff au wav) do:[:aVarName |
		menu add: aVarName
			target: self 
			selector: #readFromFile:
			argument: (FileSystem workingDirectory / 'Sound' / aVarName).
	].
	menu localize; popUpInWorld.
]

{ #category : #menu }
ScratchSoundEditor >> readFromFile: fName [
	"Read my samples from the file with the given name."

	( fName) exists
		ifFalse: [^ self inform: 'File not found' withDetails: fName].
	snd := SampledSound fromFileNamed: fName.

	completeSnd := snd copy.
	graph cursor: 200.
	samplingRate := snd originalSamplingRate.
	origSamplingRate := snd originalSamplingRate.
	graph data: snd samples.
	graph scale: 2.0.

	self setVolume: 0.5.
	volume setScaledValue: 0.5.
	
	graph data size > 5000
		ifTrue: [deltaVal := 50]
		ifFalse: [deltaVal := graph data size // 10].


]

{ #category : #menu }
ScratchSoundEditor >> resetSamplingRate [

	snd ifNil: [^self].

	snd setSamples: snd samples samplingRate: origSamplingRate.
	rateSlider setScaledValue: 1.0.
]

{ #category : #accessing }
ScratchSoundEditor >> samplingRate [

	^ samplingRate


]

{ #category : #menu }
ScratchSoundEditor >> samplingRate: sampleRate [

"Sets the samplingRate to somewhere btw 0.1 and 2.5 the original samplingRate, given a number btw 0.2 and 2.5 (sampleRate)"

	snd ifNil: [^self.].

	origSamplingRate = 0 
		ifFalse: [snd setSamples: snd samples samplingRate: (sampleRate*origSamplingRate)]
		ifTrue: [ snd setSamples: snd samples samplingRate: (sampleRate*10000)].

	

]

{ #category : #'graph ops' }
ScratchSoundEditor >> save [

	snd := SampledSound samples: completeSnd samples samplingRate: samplingRate.
	client ifNotNil: [client saveSound: snd name: soundName].
	self delete.

]

{ #category : #menu }
ScratchSoundEditor >> saveToFile [
	"Export my samples to a WAV file."

	| fileName samples f |
	fileName := StringDialog ask: 'File name?'.
	fileName size = 0 ifTrue: [^ self].
	(fileName asLowercase endsWith: '.wav') ifFalse: [fileName := fileName, '.wav'].
	(graph data isKindOf: SoundBuffer)
		ifTrue: [samples := graph data]
		ifFalse: [samples := SoundBuffer fromArray: graph data].
	f := (FileStream newFileNamed: fileName) binary.
	(SampledSound samples: samples samplingRate: samplingRate) storeWAVSamplesOn: f.
	f close.

]

{ #category : #accessing }
ScratchSoundEditor >> scrollTime: relativeValue [

	graph startIndex: relativeValue*(graph data size).

	viewer flushCachedForm; changed.





]

{ #category : #accessing }
ScratchSoundEditor >> selection [

	^selection.
]

{ #category : #accessing }
ScratchSoundEditor >> selection: anArrayorNil [

	anArrayorNil ifNil: [selection := {nil. nil}.]
			 ifNotNil: [selection := anArrayorNil.].
	graph selection: selection.
	viewer selection: selection
]

{ #category : #accessing }
ScratchSoundEditor >> selection: aNumber scd: anotherNumber [

	selection := { aNumber min: anotherNumber. aNumber max: anotherNumber}.
	graph selection: selection.
	viewer selection: selection.
	graph flushCachedForm; changed.
	viewer flushCachedForm; changed.
]

{ #category : #accessing }
ScratchSoundEditor >> selectionNil [
	
	(selection at: 1) ifNil: [^ true].
	
	^false.
]

{ #category : #menu }
ScratchSoundEditor >> setVolume: aFloat [

	"aFloat is a value btw 0 and 1.0"
	
	snd ifNil: [^self].
	snd adjustVolumeTo: aFloat overMSecs: 50.
]

{ #category : #accessing }
ScratchSoundEditor >> slider [ 
	^slider.
]

{ #category : #menu }
ScratchSoundEditor >> slower [

	| rate |
	rate := rateSlider getScaledValue/1.1.
	rateSlider setScaledValue: rate.
	self samplingRate: rate.

	
]

{ #category : #accessing }
ScratchSoundEditor >> sound [

	^snd.
]

{ #category : #'graph ops' }
ScratchSoundEditor >> sound: aSampledSound [

	"completeSnd is a version of the sound that is unaffected by the play mechanism.  This method is called when a SoundMorph brings up a SoundEditor. soundMorphSound is a copy of the initial sampledSound, used for saving and cancelling edits purposes.  It serves as a reference to the original sound so that we can actually change the sound in the soundMorph"

	soundMorphSound := aSampledSound.
	snd := aSampledSound copy.
	completeSnd := snd copy.
	graph cursor: 200.
	samplingRate := snd originalSamplingRate.
	origSamplingRate := snd originalSamplingRate.

	ScratchGraphMorph MinScale: (graph extent x/completeSnd samples size).

	graph data: completeSnd samples.  "SHOULD IT BE COPY?/"
	graph scale: 2.
	graph calculateDataArray.
	"self fixSliderRange.
	graph computeSlider."
	
	viewer data: completeSnd samples.
	viewer scale: 1.
	viewer calculateDataArray.
	self setVolume: snd loudness.
	volume setScaledValue: snd loudness.
	
	(graph data size > 5000)
		ifTrue: [deltaVal := 200]
		ifFalse: [deltaVal := (graph data size) // 10].

	self updateSlider
]

{ #category : #accessing }
ScratchSoundEditor >> soundName: aString [
	"Note the sound name to use when saving."

	soundName := aString.

]

{ #category : #accessing }
ScratchSoundEditor >> startSelection [
		
	^ startSelection.
]

{ #category : #accessing }
ScratchSoundEditor >> startSelection: aNumber [


	startSelection := aNumber.
]

{ #category : #'graph ops' }
ScratchSoundEditor >> startTime [
	
	| ss |
	"secs := cursor / samplingRate.
	hrs := secs // 3600.
	mins := (secs \\ 3600) // 60.
	secs := secs \\ 60 asFloat.
	ms := ((secs \\ 1) * 100) asFloat truncated.
	secs := secs // 1."

	" hrs asString,':',mins asString, ':', secs asString, '.', ms asString."
	
	origSamplingRate isNil
		ifTrue: [ss := 20000]
		ifFalse: [ss := origSamplingRate].
	^ ((cursor asFloat/ss) roundTo: 0.01) asString.
]

{ #category : #'graph ops' }
ScratchSoundEditor >> startTime: hrMinSecs [
	
	| secs hrs mins hms |
	hms := hrMinSecs findTokens: ' :.'.
	hrs := hms at: 1.
	mins := hms at: 2.
	secs := hms at: 3.
	self startIndex: ((hrs asNumber * 3600) + (mins asNumber * 60) + secs asNumber) * samplingRate.

]

{ #category : #stepping }
ScratchSoundEditor >> step [

	| played prev |
	(SoundPlayer isPlaying: snd) ifTrue: [
		played := ((snd millisecondsSinceStart) * snd samples size) / (1000.0 * snd duration).
		prev := (completeSnd samples size - snd samples size).
		playCursor := (played + prev truncated min: graph data size).
		self changed].

	time contents: self startTime.

	scrollDelta = 0 ifFalse: [
		graph startIndex: graph startIndex + (scrollDelta/graph scale).
		self updateSliderValue.].

	graph computeSlider.
	self fixSliderRange.

]

{ #category : #stepping }
ScratchSoundEditor >> stepTime [


	^ 150

]

{ #category : #menu }
ScratchSoundEditor >> stop [

	snd pause.
	playCursor := nil.
	
]

{ #category : #other }
ScratchSoundEditor >> stretch: sampleArray by: stretchFactor [
	"Return an array consisting of the given samples \stretched in time by the given factor."

	| out end incr i frac index |
	out := OrderedCollection new: (stretchFactor * sampleArray size) asInteger + 1.
	end := (sampleArray size - 1) asFloat.
	incr := 1.0 / stretchFactor.
	i := 1.0.
	[i < end] whileTrue: [
		frac := i fractionPart.
		index := i truncated.
		i := i + incr.
		out addLast:
			(((1.0 - frac) * (sampleArray at: index)) + (frac * (sampleArray at: index + 1))) rounded].
	^ out asArray

]

{ #category : #'graph ops' }
ScratchSoundEditor >> undo [


	| tmpSound tmpSel tmpCursor tmpScale |

	undoSound ifNil: [^self].

	tmpSound := SampledSound samples: graph data samplingRate: samplingRate.
	tmpSel := graph selection copy.
	tmpCursor := cursor.
	tmpScale := graph scale/ScratchGraphMorph MinScale.

	graph data: undoSound samples copy.
	viewer data: graph data.
	
	"scales the botton viewer so that the data fits on the entire screen." 
	(tmpSound samples size - graph data size) abs > 3
		ifTrue: [ScratchGraphMorph MinScale: ((viewer extent x/ graph data size) min: 1).
				viewer scale: 1.
				graph scale: undoScale.
				viewer startIndex: 1.
				graph computeSlider.
				self fixSliderRange.].

	graph calculateDataArray.
	viewer calculateDataArray.

	snd setSamples: graph data samplingRate: samplingRate.
	completeSnd setSamples: graph data samplingRate: samplingRate.
	self selection: undoSel copy.
	cursor := undoCursor.

	undoSound := tmpSound.
	undoSel := tmpSel.
	undoCursor := tmpCursor.
	undoScale := tmpScale.

]

{ #category : #other }
ScratchSoundEditor >> updateSlider [

	"this is the order that these methods have to be called in order to update slider!!!"
	graph computeSlider.  
	self fixSliderRange.
	self updateSliderValue.
]

{ #category : #accessing }
ScratchSoundEditor >> updateSliderValue [

	slider setScaledValue: ((graph startIndex/graph data size min: slider maxVal) max: 0).





]

{ #category : #accessing }
ScratchSoundEditor >> viewer [

	^viewer.
]
