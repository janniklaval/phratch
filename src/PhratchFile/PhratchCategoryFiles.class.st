"
I represent the File category of phratch. Inside, there is a lot of blocks for manipulating files
"
Class {
	#name : #PhratchCategoryFiles,
	#superclass : #PhratchCategory,
	#category : #PhratchFile
}

{ #category : #accessing }
PhratchCategoryFiles class >> color [
	^(Color r: 0.17254901960784313725490196078431 g: 0.47058823529411764705882352941176 b: 0.76470588235294117647058823529412)
]

{ #category : #accessing }
PhratchCategoryFiles class >> label [
	^'files'
]

{ #category : #accessing }
PhratchCategoryFiles class >> order [
	^9
]
