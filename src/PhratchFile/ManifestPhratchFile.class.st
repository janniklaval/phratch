"
I stores metadata on true and false positive critics. These meta data are used by the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPhratchFile,
	#superclass : #Object,
	#category : #PhratchFile
}

{ #category : #'meta data' }
ManifestPhratchFile class >> rejectClasses [
^ #()
]

{ #category : #'meta data' }
ManifestPhratchFile class >> rejectRules [
^ #()
]
