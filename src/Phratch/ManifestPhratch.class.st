Class {
	#name : #ManifestPhratch,
	#superclass : #Object,
	#category : #Phratch
}

{ #category : #'meta data' }
ManifestPhratch class >> rejectClasses [
^ #()
]

{ #category : #'meta data' }
ManifestPhratch class >> rejectRules [
^ #()
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleClassNotReferencedRuleV1FalsePositive [
^ #(#(#(#RGClassDefinition #(#PhratchCategoryList)) #'2013-08-05T22:37:12.950000012+02:00') #(#(#RGClassDefinition #(#PhratchCategoryOther)) #'2013-08-05T22:37:12.948+02:00') #(#(#RGClassDefinition #(#PhratchCategorySound)) #'2013-08-05T22:37:12.950000003+02:00') #(#(#RGClassDefinition #(#PhratchCategoryOperators)) #'2013-08-05T22:37:12.948000001+02:00') #(#(#RGClassDefinition #(#PhratchCategoryControl)) #'2013-08-05T22:37:12.95+02:00') #(#(#RGClassDefinition #(#PhratchCategoryFiles)) #'2013-08-05T22:37:12.950000002+02:00') #(#(#RGClassDefinition #(#PhratchCategoryMotion)) #'2013-08-05T22:37:12.950000004+02:00') #(#(#RGClassDefinition #(#PhratchCategoryNone)) #'2013-08-05T22:37:12.950000006+02:00') #(#(#RGClassDefinition #(#PhratchCategoryVariables)) #'2013-08-05T22:37:12.950000007+02:00') #(#(#RGClassDefinition #(#PhratchCategoryMotors)) #'2013-08-05T22:37:12.950000005+02:00') #(#(#RGClassDefinition #(#PhratchCategoryColors)) #'2013-08-05T22:37:12.950000009+02:00') #(#(#RGClassDefinition #(#PhratchCategoryCustom)) #'2013-08-05T22:37:12.950000001+02:00') #(#(#RGClassDefinition #(#PhratchCategoryPen)) #'2013-08-05T22:37:12.95000001+02:00') #(#(#RGClassDefinition #(#PhratchCategoryLooks)) #'2013-08-05T22:37:12.950000008+02:00') #(#(#RGClassDefinition #(#PhratchCategorySensing)) #'2013-08-05T22:37:12.950000011+02:00') )
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleImplementedNotSentRuleV1FalsePositive [
^ #(#(#(#RGMethodDefinition #(#PhratchProcess #doWithCamOpen #false)) #'2013-08-07T21:25:26.731+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doPauseThread #false)) #'2013-08-07T21:25:26.731000006+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #getVarNamed: #false)) #'2013-08-07T21:25:26.731000004+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doIf #false)) #'2013-08-07T21:25:26.731000005+02:00') #(#(#RGMethodDefinition #(#PhratchFrameMorph #saveImageForEndUserSilently #false)) #'2013-08-07T21:25:26.731000001+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doWhile #false)) #'2013-08-07T21:25:26.731000002+02:00') #(#(#RGMethodDefinition #(#PhratchProcess #doWaitUntil #false)) #'2013-08-07T21:25:26.731000003+02:00') )
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleJustSendsSuperRuleV1FalsePositive [
^ #(#(#(#RGMethodDefinition #(#PhratchSpriteMorph #height #false)) #'2013-08-07T23:07:38.110000003+02:00') #(#(#RGMethodDefinition #(#ScriptablePhratchMorph #= #false)) #'2013-08-07T23:07:38.110000004+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #width #false)) #'2013-08-07T23:07:38.110000002+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #comeToFront #false)) #'2013-08-07T23:07:38.11+02:00') #(#(#RGMethodDefinition #(#PhratchSpriteMorph #isVisible #false)) #'2013-08-07T23:07:38.110000001+02:00') )
]

{ #category : #'meta data' }
ManifestPhratch class >> ruleOnlyReadOrWrittenTemporaryRuleV1FalsePositive [
^ #(#(#(#RGMethodDefinition #(#WeDoPlugin #primRead #false)) #'2013-08-07T23:07:37.964+02:00') #(#(#RGMethodDefinition #(#CameraPlugin #primOpenCamera #false)) #'2013-08-07T23:07:37.964000001+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primitiveOpenURL #false)) #'2013-08-07T23:07:37.964000002+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primitiveGetFolderPath #false)) #'2013-08-07T23:07:37.964000008+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primWrite #false)) #'2013-08-07T23:07:37.964000014+02:00') #(#(#RGMethodDefinition #(#CameraPlugin #primCloseCamera #false)) #'2013-08-07T23:07:37.964000011+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primitiveShortToLongPath #false)) #'2013-08-07T23:07:37.964000012+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primOpenPortNamed #false)) #'2013-08-07T23:07:37.964000016+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primitiveSetWindowTitle #false)) #'2013-08-07T23:07:37.964000018+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primitiveIsHidden #false)) #'2013-08-07T23:07:37.964000019+02:00') #(#(#RGMethodDefinition #(#CameraPlugin #primCameraName #false)) #'2013-08-07T23:07:37.964000021+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primIsPortOpen #false)) #'2013-08-07T23:07:37.964000009+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primClose #false)) #'2013-08-07T23:07:37.96400001+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primGetOption #false)) #'2013-08-07T23:07:37.964000013+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primitiveSetUnicodePasteBuffer #false)) #'2013-08-07T23:07:37.964000005+02:00') #(#(#RGMethodDefinition #(#CameraPlugin #primGetFrame #false)) #'2013-08-07T23:07:37.964000006+02:00') #(#(#RGMethodDefinition #(#CameraPlugin #primFrameExtent #false)) #'2013-08-07T23:07:37.964000015+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primSetOption #false)) #'2013-08-07T23:07:37.964000017+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primRead #false)) #'2013-08-07T23:07:37.96400002+02:00') #(#(#RGMethodDefinition #(#WeDoPlugin #primWrite #false)) #'2013-08-07T23:07:37.964000004+02:00') #(#(#RGMethodDefinition #(#CameraPlugin #primGetParam #false)) #'2013-08-07T23:07:37.964000003+02:00') #(#(#RGMethodDefinition #(#PhratchPlugin #primPortName #false)) #'2013-08-07T23:07:37.964000007+02:00') )
]
