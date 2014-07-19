Class {
	#name : #MetaRepoSearcher,
	#superclass : #Object,
	#category : #'Phratch-Addons'
}

{ #category : #'as yet unclassified' }
MetaRepoSearcher class >> listOfProjects [

	| lst res conf proj |
	lst := (MetacelloConfigurationBrowserPane retrieveConfigurationsFrom: 'http://smalltalkhub.com/mc/JLaval/PhratchMetaRepo/main').
	res := OrderedCollection new.
	lst do:[:e |
		conf := ((e subStrings: '-') first).
		proj := conf copyFrom: 16 to: conf size.
		res add: (proj -> conf)
	].
	^res
]

{ #category : #'as yet unclassified' }
MetaRepoSearcher class >> loadProject: aConfigurationString [

	[Gofer it
		url:'http://smalltalkhub.com/mc/JLaval/PhratchMetaRepo/main';
		package: aConfigurationString asString;
		load.
	((Smalltalk at: (aConfigurationString asString asSymbol)) 
		project version: #bleedingEdge)
		silently: true;
		load.] on: Error do: [ ^ PhratchError errorWithDialog: 'You need an Internet connection to load AddOns.'].
	DialogBoxMorph inform: aConfigurationString, ' installed'.
	PhratchFrameMorph rebuildUI.
]
