Extension { #name : #PhratchSpriteEv3Morph }

{ #category : #'*PhratchFile' }
PhratchSpriteEv3Morph >> readFile: aFileName [
	<phratchItem: 'read file $String$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #('/aFile') subCategory: #file special: #()>
	^ (ev3 fileSystem)readFile: aFileName
]
