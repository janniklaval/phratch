Class {
	#name : #MetaRepoSearcher,
	#superclass : #Object,
	#category : #'Phratch-Addons'
}

{ #category : #projects }
MetaRepoSearcher class >> listOfProjects [
	^ ((Metacello new
		githubUser: 'grype'
		project: 'PhratchMetaRepo'
		commitish: 'master'
		path: 'src')
		baseline: [ :spec | true ];
		list) roots collect: [ :e | e name -> e className ]
	"^ ((Metacello new
		smalltalkhubUser: 'JLaval'
		project: 'PhratchMetaRepo')
		configuration: [ :spec | true ];
		list) roots collect: [ :e | e name -> e className ]"
]

{ #category : #projects }
MetaRepoSearcher class >> loadProject: aConfigurationString [
	[ Metacello new
		baseline: (aConfigurationString withoutPrefix: 'BaselineOf');
		repository: 'github://grype/PhratchMetaRepo';
		load ]
		on: Error
		do: [ : err | ^ PhratchError
				errorWithDialog: 'You need an Internet connection to load AddOns.' ].

	"[Gofer it
		url:'http://smalltalkhub.com/mc/JLaval/PhratchMetaRepo/main';
		package: aConfigurationString asString;
		load.
	((Smalltalk at: (aConfigurationString asString asSymbol)) 
		project version: #bleedingEdge)
		silently: true;
		load.] on: Error do: [ ^ PhratchError errorWithDialog: 'You need an Internet connection to load AddOns.']."
	
	DialogBoxMorph inform: aConfigurationString , ' installed'.
	PhratchFrameMorph rebuildUI
]
