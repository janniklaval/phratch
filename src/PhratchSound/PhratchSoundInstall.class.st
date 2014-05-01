Class {
	#name : #PhratchSoundInstall,
	#superclass : #Object,
	#category : #PhratchSound
}

{ #category : #'as yet unclassified' }
PhratchSoundInstall class >> initialize [

	PhratchCategorySound visible: true.
	PhratchFrameMorph rebuildUI.
]
