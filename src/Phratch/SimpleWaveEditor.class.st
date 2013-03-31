Class {
	#name : #SimpleWaveEditor,
	#superclass : #WaveEditor,
	#category : #'Phratch-Sound'
}

{ #category : #'as yet unclassified' }
SimpleWaveEditor class >> includeInNewMorphMenu [
	^ true
]

{ #category : #'as yet unclassified' }
SimpleWaveEditor >> addControls [
	| t1 t2 t3 t4 |
	t2 := SimpleButtonMorph new target: self;
			 borderColor: Color black;
			 useSquareCorners.
	t3 := AlignmentMorph newRow.
	t3 color: t2 color;
	 borderWidth: 0;
	 inset: 0.
	t3 hResizing: #shrinkWrap;
	 vResizing: #shrinkWrap;
	 extent: 5 @ 5.
	t3 centering: #topLeft.
	t3 addMorphBack: (t2 fullCopy label: 'X';
		 actionSelector: #delete).
	t3 addMorphBack: (t2 fullCopy label: 'Menu';
		 actWhen: #buttonDown;
		 actionSelector: #invokeMenu).
	t3 addMorphBack: (t2 fullCopy label: 'Play';
		 actionSelector: #play).
	t3 addMorphBack: (t2 fullCopy label: 'Play Before Cursor';
		 actionSelector: #playBeforeCursor).
	t3 addMorphBack: (t2 fullCopy label: 'Play After Cursor';
		 actionSelector: #playAfterCursor).
	t3 addMorphBack: (t2 fullCopy label: 'Save to File';
		 actionSelector: #saveToFile).
	self addMorphBack: t3.
	t3 := AlignmentMorph newRow.
	t3 color: self color;
	 borderWidth: 0;
	 inset: 0.
	t3 hResizing: #spaceFill;
	 vResizing: #rigid;
	 extent: 5 @ 20;
	 centering: #center.
	t4 := StringMorph new contents: 'Cursor: '.
	t3 addMorphBack: t4.
	t4 := UpdatingStringMorph new target: graph;
			 getSelector: #cursor;
			 putSelector: #cursor:;
			 growable: false;
			 width: 50;
			 step.
	t3 addMorphBack: t4.
	t4 := Morph new color: t3 color;
			 extent: 15 @ 5.
	t3 addMorphBack: t4.
	t4 := StringMorph new contents: 'Value: '.
	t3 addMorphBack: t4.
	t4 := UpdatingStringMorph new target: graph;
			 getSelector: #valueAtCursor;
			 putSelector: #valueAtCursor:;
			 growable: false;
			 width: 50;
			 step.
	t3 addMorphBack: t4.
	t4 := Morph new color: t3 color;
			 extent: 15 @ 5.
	t3 addMorphBack: t4.
	t1 := SimpleSliderMorph new color: color;
			 extent: 200 @ 2;
			 target: self;
			 actionSelector: #scrollTime:.
	t3 addMorphBack: t1.
	self addMorphBack: t3
]

{ #category : #'as yet unclassified' }
SimpleWaveEditor >> addLoopPointControls [
	^ self
]

{ #category : #'as yet unclassified' }
SimpleWaveEditor >> invokeMenu [
	| t1 |
	t1 := MenuMorphNG  new.
	t1 addList: #(('show envelope' #showEnvelope) #- ('trim before cursor' #trimBeforeCursor) ('trim after cursor' #trimAfterCursor) #- ('add to instrument library' #saveInstrument) ('delete instrument' #deleteInstrument) #- ('save to file' #saveToFile) ('read from file' #readFromFile) ).
	t1 invokeOn: self defaultSelection: nil
]
