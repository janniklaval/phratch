Extension { #name : #MediaItemMorph }

{ #category : #'*PhratchSound' }
MediaItemMorph >> editSound [

	| sFrame workPane editor |
	sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	sFrame ifNil: [^ self].
	workPane := sFrame workPane.

	editor := PhratchSoundEditor new client: phratchObj; sound: media sound;
		yourself.
	editor soundName: media mediaName.
	editor position: workPane topLeft + (10@10).
	workPane addMorph: editor.
	workPane world ifNotNil: [workPane world startSteppingSubmorphsOf: editor].

]
