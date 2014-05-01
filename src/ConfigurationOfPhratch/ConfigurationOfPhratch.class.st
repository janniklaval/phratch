Class {
	#name : #ConfigurationOfPhratch,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfPhratch
}

{ #category : #private }
ConfigurationOfPhratch class >> bootstrapPackage: aString from: aPath [ 
	| repository version |
	repository := MCHttpRepository
				location: aPath
				user: ''
				password: ''.
	repository
		versionReaderForFileNamed: aString , '.mcz'
		do: [:reader | 
			version := reader version.
			version load.
			version workingCopy repositoryGroup addRepository: repository]
]

{ #category : #catalog }
ConfigurationOfPhratch class >> catalogChangeLog [
	"Returns a paragraph describing the most important changes in the configuration class."
	^ '- 1.0 - October 2013 - first release
[[[
	ConfigurationOfPhratch project version: ''1.0'' ) load					
]]]
- 2.0 - March 2014 - have a lot of new things to create your own addons (not available in Pharo2.0).
[[[
	ConfigurationOfPhratch project version: ''2.0'' ) load					
]]]
- 3.0 - 2014 - not yet released but have a lot of new optimizations and cleanings (not available in Pharo2.0).
[[[
	ConfigurationOfPhratch project version: ''3.0'' ) load					
]]]'
]

{ #category : #catalog }
ConfigurationOfPhratch class >> catalogContactInfo [
	"Returns a paragraph describing contact information such as email, mailing lists and website."
	^ 'You can get in contact with the programmer at phratch@googlegroups.com. You can send issues on: https://code.google.com/p/phratch/issues/list'
]

{ #category : #catalog }
ConfigurationOfPhratch class >> catalogDescription [
	"Returns a paragraph describing the project"
	^ 'Phratch is a visual programming language that makes it easy to create your own software. It is a port of Scratch (http://scratch.mit.edu/) on recent platforms (Phrao 2.0 and Pharo 3.0).
	
	It is more that a port of Scratch: it allows one to create and to extend it easily with small knowledge of programming languages. Phratch can be plugged on top of any API available in Pharo. One example is the JetStorm software that allows one to control Lego Mindstorms robots with Phratch.
	
	More information on Phratch.com'
]

{ #category : #catalog }
ConfigurationOfPhratch class >> catalogKeyClassesAndExample [
	"Returns a paragraph or more describing the key classes of your project. You can use Pillar/Pier syntax to layout out the text i.e., ==Code== and - for bullet."
	^ 'MyProject is composed of one key class named ==PhratchFrameMorph==. Just send the message open o this class to open Phratch.'
]

{ #category : #catalog }
ConfigurationOfPhratch class >> catalogKeywords [
	"Returns an array of symbols"
	^ #(fun scratch pharo visual programming language) 
]

{ #category : #private }
ConfigurationOfPhratch class >> ensureMetacello [
	"Bootstrap Gofer (if necessary), load latest mcz file for ConfigurationOfMetacello (using old 
	 Gofer API), then load the latest version of Metacello itself."

	Smalltalk at: #MetacelloProject ifAbsent: [ | error |
		"list of repositories to try, in case primary repository is not accessible"
		(Array 
			with: 'http://www.squeaksource.com/MetacelloRepository' 
			with: 'http://seaside.gemstone.com/ss/metacello') do: [:repositoryUrl |
				([
					Smalltalk at: #Gofer ifAbsent: [
					"Current version of Gofer from which to bootstrap - as of 1.0-beta.21"
						self bootstrapPackage: 'Gofer-Core-lr.115' from: repositoryUrl ].
					Smalltalk at: #Gofer ifPresent: [:goferClass | | gofer |
						gofer := goferClass new
							url: repositoryUrl;
							yourself.
						[ gofer addPackage: 'ConfigurationOfMetacello' ] on: Warning do: [:ex | ex resume ].
						gofer load ]]
							on: Error
							do: [ :ex |
								error := ex.
								Transcript 
									cr; 
									show: 'failed ensureMetacello: ';
									show: ex description printString;
									show: '...retrying'.
								"try again"
								ex return: nil ]) ~~ nil
					ifTrue: [
						"load 'default' group of Metacello"
						(Smalltalk at: #ConfigurationOfMetacello) perform: #load.
						^self ]].
		"shouldn't get here unless the load failed ... throw an error"
		self error: 'retry with alternate repository failed: ', error description printString ]
]

{ #category : #'metacello tool support' }
ConfigurationOfPhratch class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #'metacello tool support' }
ConfigurationOfPhratch class >> lastMetacelloVersionLoad [
	"Answer the last version loaded and the list of packages loaded for that version."

	LastVersionLoad == nil ifTrue: [ LastVersionLoad := nil -> 'default' ].
	^LastVersionLoad
]

{ #category : #loading }
ConfigurationOfPhratch class >> load [
	"self load"

	^self project latestVersion load
]

{ #category : #loading }
ConfigurationOfPhratch class >> loadBleedingEdge [
	(self project version: #bleedingEdge) load.
]

{ #category : #'metacello tool support' }
ConfigurationOfPhratch class >> metacelloVersion: versionString loads: anArrayOrString [
	"Stash the last version loaded and the list of packages loaded for that version. The list
	 of packages will be used by the tools when doing 'Load Package Version'"

	LastVersionLoad := versionString -> anArrayOrString
]

{ #category : #accessing }
ConfigurationOfPhratch class >> project [

	^self new project
]

{ #category : #'unloading metacello' }
ConfigurationOfPhratch class >> unloadMetacello [

	Smalltalk at: #ConfigurationOfMetacello ifPresent: [:cls | cls unloadMetacello ]
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> baseline10: spec [
	<version:'1.0-baseline'>
	spec for: #common do: [
			spec blessing: #baseline.
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			
			spec project: 'Sound' with: [
				spec 
					className: 'ConfigurationOfPharoSound';
					file: 'ConfigurationOfPharoSound' ;
					version: #stable;
					repository: 'http://smalltalkhub.com/mc/PharoExtras/Sound/main'.
			].
			spec project: 'OSProcess' with: [
				spec
					repository: 'http://www.squeaksource.com/MetacelloRepository'; 
					className: 'ConfigurationOfOSProcess';
					version: #stable ].
	].
	spec for: #'pharo2.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess')
			].
			spec
				package: 'PhratchObjStream' with: [ 
					spec requires: #('Phratch')
			]
	].
	spec for: #'pharo3.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'PhratchCompatibilityPharo3'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess' 'PhratchCompatibilityPharo3')
			].
			spec
				package: 'PhratchObjStream' with: [ 
					spec requires: #('Phratch')
			]
	]
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> baseline20: spec [
	<version:'2.0-baseline'>
	spec for: #common do: [
			spec blessing: #baseline.
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			
			spec project: 'Sound' with: [
				spec 
					className: 'ConfigurationOfPharoSound';
					file: 'ConfigurationOfPharoSound' ;
					version: #stable;
					repository: 'http://smalltalkhub.com/mc/PharoExtras/Sound/main'.
			].
			spec project: 'OSProcess' with: [
				spec
					repository: 'http://www.squeaksource.com/MetacelloRepository'; 
					className: 'ConfigurationOfOSProcess';
					version: #stable ].
	].
	spec for: #'pharo2.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess')
			].
	].
	spec for: #'pharo3.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess')
			].
	]
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> baseline30: spec [
	<version:'3.0-baseline'>
	spec for: #common do: [
			spec blessing: #baseline.
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			
			spec project: 'Sound' with: [
				spec 
					className: 'ConfigurationOfPharoSound';
					file: 'ConfigurationOfPharoSound' ;
					version: #stable;
					repository: 'http://smalltalkhub.com/mc/PharoExtras/Sound/main'.
			].
			spec project: 'OSProcess' with: [
				spec
					repository: 'http://www.squeaksource.com/MetacelloRepository'; 
					className: 'ConfigurationOfOSProcess';
					version: #stable ].
	].
	spec for: #'pharo2.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess')
			].
			spec
				package: 'Phratch3CleanSound' with: [ 
					spec requires: #('Phratch')
			].
	].
	spec for: #'pharo3.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess')
			].
			spec
				package: 'Phratch3CleanSound' with: [ 
					spec requires: #('Phratch')
			].
	]
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> baseline40: spec [
	<version:'4.0-baseline'>
	spec for: #common do: [
			spec blessing: #baseline.
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			
			spec project: 'Sound' with: [
				spec 
					className: 'ConfigurationOfPharoSound';
					file: 'ConfigurationOfPharoSound' ;
					version: #stable;
					repository: 'http://smalltalkhub.com/mc/PharoExtras/Sound/main'.
			].
			spec project: 'OSProcess' with: [
				spec
					repository: 'http://www.squeaksource.com/MetacelloRepository'; 
					className: 'ConfigurationOfOSProcess';
					version: #stable ].
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: [ 
					spec requires: #('Sound' 'OSProcess')
			].
	].
			
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> project [
	^ project ifNil: [
		 | constructor |
		
		"Bootstrap Metacello if it is not already loaded"
		self class ensureMetacello.
		
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		project loadType: #linear. "change to #atomic if desired"
		project 
	].


]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> stable: spec [ 
	<symbolicVersion: #stable>
	
	spec for: #'pharo2.0.x' version: '1.0'. 
	spec for: #'pharo3.0.x' version: '1.0'. 
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> version10: spec [
	<version:'1.0' imports: #('1.0-baseline' )>
	spec for: #common do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: 'Phratch-janniklaval-pharo20.240';
				package: 'PhratchObjStream' with: 'PhratchObjStream-janniklaval.5'.
			spec
				project: 'Sound' with: #stable;
				project: 'OSProcess' with: #stable.
	].
	spec for: #'pharo3.x' do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'PhratchCompatibilityPharo3' with: 'PhratchCompatibilityPharo3-janniklaval.5'.
	]
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> version20: spec [
	<version:'2.0' imports: #('2.0-baseline' )>
	spec for: #common do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: 'Phratch-janniklaval.277'.
			spec
				project: 'Sound' with: #stable;
				project: 'OSProcess' with: #stable.
	].
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> version30: spec [
	<version:'3.0' imports: #('3.0-baseline' )>
	spec for: #common do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch' with: 'Phratch-jlaval.340';
				package: 'Phratch3CleanSound' with: 'Phratch3CleanSound-jlaval.1'.
			spec
				project: 'Sound' with: #stable;
				project: 'OSProcess' with: #stable.
	].
]

{ #category : #'as yet unclassified' }
ConfigurationOfPhratch >> version40: spec [
	<version:'4.0' imports: #('4.0-baseline' )>
	spec for: #common do: [
			spec repository: 'http://smalltalkhub.com/mc/JLaval/Phratch/main'.
			spec
				package: 'Phratch'.
			spec
				project: 'Sound' with: #stable;
				project: 'OSProcess' with: #stable.
	].
]
