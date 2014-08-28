"
to make it work, you need to generate methods and blocks.
Just execute these lines:

MinecraftConstants compileInstanceGetters.
PhratchMinecraftMorph compileBlocks
"
Class {
	#name : #PhratchMinecraftMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'minecraftObj'
	],
	#category : #MinecraftPhratch
}

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> compileBlockFor: anItem filedUnder: aProtocol on: aClass [
	aClass compile: (
		self methodTemplate
			format: {
					"{1}" anItem withFirstCharacterDownshifted.
					'<phratchItem: ''',anItem withFirstCharacterDownshifted,''' kind: #ReporterBlockMorph category: ''minecraft'' defaultValues: #() subCategory: #''', (aProtocol "subStrings: '-'")"second" asSymbol, ''' special: #()>'.
					
					"{2}" '^ minecraftObj ', anItem withFirstCharacterDownshifted})
			classified: aProtocol
			notifying: nil
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> compileBlocks [
	"Add instance methods to Minecraft that will return our values."

	self compileBlocks: self categoryPrefix:  'generated-'.

]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> compileBlocks: aClass categoryPrefix: aString [

	'Compiling blocks on ', aClass asString
		displayProgressFrom: 0
		to: MinecraftConstants minecraftConstantsCategories size
		during: [ :bar |
			| count |
			count := 0.
			MinecraftConstants minecraftConstantsCategories keysAndValuesDo: [:categoryName :items |
				items
					do: [ :item | self compileBlockFor: item filedUnder: aString, categoryName on: aClass ]
					displayingProgress: 'Compiling ', categoryName ].
				bar value: (count := count + 1). ]
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> initialize [
	"MinecraftConstants compileInstanceGetters.
	PhratchMinecraftMorph compileBlocks
	"
	MinecraftConstants compileInstanceGetters.
	self compileBlocks
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph class >> methodTemplate [
^ '{1}
	{2}
	{3}
	'
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> closeConnection [
	<phratchItem: 'disconnect' kind: #- category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	minecraftObj connection close.
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> connectTo: ip [
	<phratchItem: 'connect to $String$' kind: #- category: 'minecraft' defaultValues: #('localhost') subCategory: #a special: #()>
	minecraftObj connection: (MinecraftConnection host: ip port: 4711)
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> connectTo: ip port: aPort [
	<phratchItem: 'connect to $String$ port $Number$' kind: #- category: 'minecraft' defaultValues: #('localhost' 4711) subCategory: #a special: #()>
	minecraftObj connection: (MinecraftConnection host: ip port: aPort)
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> initialize [
	super initialize.
	minecraftObj := Minecraft new.
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> isConnected [
	<phratchItem: 'is connected ?' kind: #BooleanWatcherBlockMorph category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	^ [minecraftObj connection isConnected] on: Error do: [false].
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> playerPosition [
	<phratchItem: 'player position' kind: #ReporterWatcherBlockMorph category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	^ minecraftObj playerTile
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> playerPositionX [
	<phratchItem: 'player x position' kind: #ReporterWatcherBlockMorph category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	^ minecraftObj playerTile at: 1
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> playerPositionY [
	<phratchItem: 'player y position' kind: #ReporterWatcherBlockMorph category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	^ minecraftObj playerTile at: 2
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> playerPositionz [
	<phratchItem: 'player z position' kind: #ReporterWatcherBlockMorph category: 'minecraft' defaultValues: #() subCategory: #a special: #()>
	^ minecraftObj playerTile at: 3
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> put: aBlock atX: aX y: aY z: aZ [
	<phratchItem: 'put $Array$ at x $Number$ y $Number$ z $Number$' kind: #- category: 'minecraft' defaultValues: #(0 0 0 0) subCategory: #a special: #()>

	^ minecraftObj blockAt: {aX. aY. aZ} put: aBlock
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> rainbow [
	<phratchItem: 'rainbow' kind: #- category: 'minecraft demo' defaultValues: #() subCategory: #a special: #()>
	|pos radius|
	radius := 30.
	pos := minecraftObj playerTile.
	0 to: 360 by: 30.0 / radius do: [:phi | | x y z |
		{minecraftObj purpleWool. minecraftObj blueWool. minecraftObj lightBlueWool. minecraftObj limeWool. minecraftObj yellowWool. minecraftObj orangeWool. minecraftObj redWool} withIndexDo: [:block :i |
			x := (radius + i) * phi degreeCos.
			y := (radius + i) * phi degreeSin.
			z := radius.	"distance from player"
			(minecraftObj blockAt: pos + {x. y. z}) = minecraftObj air ifTrue: [
				minecraftObj blockAt: pos + {x. y. z} put: block]]].
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> safePut: aBlock atX: aX y: aY z: aZ [
	<phratchItem: 'empty put $Array$ at x $Number$ y $Number$ z $Number$' kind: #- category: 'minecraft' defaultValues: #('' 0 0 0) subCategory: #a special: #()>
	(minecraftObj blockAt: {aX. aY. aZ}) = minecraftObj air ifTrue: [
	^ minecraftObj blockAt: {aX. aY. aZ} put: aBlock]
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> table [
	<phratchItem: 'table' kind: #- category: 'minecraft demo' defaultValues: #() subCategory: #a special: #()>
	|pos size|
	size := 30.
	pos := minecraftObj playerTile.
	"Table top"
	1 to: size do: [ :x | 
		1 to: size do: [ :z | 
			minecraftObj blockAt: (pos + {x. size. z})
				put: minecraftObj stone.
		]
	].

	"Legs"
	1 to: size do: [ :i |
		minecraftObj blockAt: (pos + {1. i. 1}) put: minecraftObj stone.
		minecraftObj blockAt: (pos + {size. i. 1}) put: minecraftObj stone.
		minecraftObj blockAt: (pos + {1. i. size}) put: minecraftObj stone.
		minecraftObj blockAt: (pos + {size. i. size}) put: minecraftObj stone.
	].
]

{ #category : #'as yet unclassified' }
PhratchMinecraftMorph >> tree [
	<phratchItem: 'tree' kind: #- category: 'minecraft demo' defaultValues: #() subCategory: #a special: #()>
	|pos treePos height|
	height := 30.
	pos := minecraftObj playerTile.
	treePos := pos + {1. 0. 5}.

	"Trunk"
	1 to: height do: [ :i |
		minecraftObj blockAt: (treePos + {0. i. 0}) put: minecraftObj birchWood.
	].

	"Leaves"
	3 to: height do: [ :i |
		|spread |
		spread := 1 + ((height - i) / 2) asInteger.
		"Place random blocks within a square sized by spread"
		spread * spread timesRepeat: [ | x z | 
			x := spread atRandom - (spread / 2).
			z := spread atRandom - (spread / 2).
			minecraftObj blockAt: (treePos + {x. i. z}) put: minecraftObj birchLeaves.	
		].
	].

]
