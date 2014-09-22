Class {
	#name : #PhratchSoundInstall,
	#superclass : #Object,
	#category : #PhratchSound
}

{ #category : #'as yet unclassified' }
PhratchSoundInstall class >> initialize [
	
	AbstractSound initialize.
	SampledSound initialize.
	
	SoundSystem soundEnabled: true.
	SoundPlayer initialize; shutDown; startUp.
	SoundPlayer stopReverb.
	PhratchCategorySound visible: true.
	PhratchFrameMorph rebuildUI.

]
