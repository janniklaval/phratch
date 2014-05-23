Class {
	#name : #PhaROSSystemInfo,
	#superclass : #PhratchSpriteMorph,
	#category : #PhratchROS
}

{ #category : #services }
PhaROSSystemInfo >> argsOfService: aService [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosservice args ', aService.
	^ lst subStrings: String lf.
]

{ #category : #topics }
PhaROSSystemInfo >> bandwidthUsedBy: aTopicName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic bw ', aTopicName).
	
]

{ #category : #services }
PhaROSSystemInfo >> callService: aService withArgs: args [

	^ OSProcess thisOSProcess command: '/opt/ros/indigo/bin/rosservice call ', aService, ' ', args.
	
]

{ #category : #nodes }
PhaROSSystemInfo >> cleanup [

	^ OSProcess thisOSProcess waitForCommand: '/opt/ros/indigo/bin/rosnode cleanup'.
	
]

{ #category : #parameters }
PhaROSSystemInfo >> deleteParameter: aParam [

	^ OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosparam delete ', aParam.
	
]

{ #category : #services }
PhaROSSystemInfo >> findServicesFor: aMsgType [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosservice find ', aMsgType).
	^ lst subStrings: String lf.
	
]

{ #category : #topics }
PhaROSSystemInfo >> findTopicsFor: aTopicType [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic find ', aTopicType).
	^ lst subStrings: String lf.
	
]

{ #category : #parameters }
PhaROSSystemInfo >> getParameter: aParam [

	^ OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosparam get ', aParam.
	
]

{ #category : #nodes }
PhaROSSystemInfo >> infoOfNode: aNodeName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosnode info ', aNodeName).
	
]

{ #category : #services }
PhaROSSystemInfo >> infoOfService: aServiceName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosservice info ', aServiceName).
	
]

{ #category : #topics }
PhaROSSystemInfo >> infoOfTopic: aTopicName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic info ', aTopicName).
	
]

{ #category : #nodes }
PhaROSSystemInfo >> killNode: aNodeName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosnode kill ', aNodeName).
	
]

{ #category : #parameters }
PhaROSSystemInfo >> loadParametersFromFile: aFileName [

	^ OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosparam load ', aFileName.
	
]

{ #category : #messages }
PhaROSSystemInfo >> md5OfMessage: aMessageName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosmsg md5 ', aMessageName).
	
]

{ #category : #messages }
PhaROSSystemInfo >> messageList [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosmsg list'.
	^ lst subStrings: String lf.
]

{ #category : #messages }
PhaROSSystemInfo >> messageListOfPackage: aPackageName [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosmsg package ', aPackageName.
	^ lst subStrings: String lf.
]

{ #category : #nodes }
PhaROSSystemInfo >> nodeList [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosnode list'.
	^ lst subStrings: String lf.
]

{ #category : #nodes }
PhaROSSystemInfo >> nodeListOnMachine: aHostname [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosnode machine ', aHostname).
	^ lst subStrings: String lf.
]

{ #category : #messages }
PhaROSSystemInfo >> packagesContainingMessage: aMessageName [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosmsg packages ', aMessageName.
	^ lst subStrings: String lf.
]

{ #category : #parameters }
PhaROSSystemInfo >> parameterList [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosparam list'.
	^ lst subStrings: String lf.
]

{ #category : #nodes }
PhaROSSystemInfo >> pingAllNodes [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosnode ping -a').
	^ lst subStrings: String lf.
]

{ #category : #nodes }
PhaROSSystemInfo >> pingNode: aNodeName [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosnode ping -c 10 ', aNodeName).
	^ lst subStrings: String lf.
]

{ #category : #topics }
PhaROSSystemInfo >> printMessageOf: aTopicName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic echo -n 1 ', aTopicName).
	
]

{ #category : #topics }
PhaROSSystemInfo >> publish: data type: topicType onTopic: aTopic [

	^OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic pub ',aTopic, ' ', topicType, ' ', data).
]

{ #category : #topics }
PhaROSSystemInfo >> publishingRateOf: aTopicName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic hz ', aTopicName).
	
]

{ #category : #run }
PhaROSSystemInfo >> run: node from: package [

	^ OSProcess thisOSProcess command: ('/opt/ros/indigo/bin/rosrun ', package, ' ', node).
	
]

{ #category : #parameters }
PhaROSSystemInfo >> saveParametersInFile: aFileName [

	^ OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosparam dump ', aFileName.
	
]

{ #category : #services }
PhaROSSystemInfo >> serviceList [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosservice list'.
	^ lst subStrings: String lf.
]

{ #category : #parameters }
PhaROSSystemInfo >> setParameter: aParam toValue: aValue [

	^ OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosparam set ', aParam, ' ', aValue.
	
]

{ #category : #messages }
PhaROSSystemInfo >> showMessage: aMessageName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosmsg show ', aMessageName).
	
]

{ #category : #messages }
PhaROSSystemInfo >> sourceCodeContainingMessage: aMessageName [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: '/opt/ros/indigo/bin/rosmsg users ', aMessageName.
	^ lst subStrings: String lf.
]

{ #category : #topics }
PhaROSSystemInfo >> topicList [

	|lst|
	lst := OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic list').
	^ lst subStrings: String lf.
	
]

{ #category : #services }
PhaROSSystemInfo >> typeOfService: aServiceName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosservice type ', aServiceName).
	
]

{ #category : #topics }
PhaROSSystemInfo >> typeOfTopic: aTopicName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rostopic type ', aTopicName).
	
]

{ #category : #services }
PhaROSSystemInfo >> uriOfService: aServiceName [

	^ OSProcess thisOSProcess waitForCommandOutput: ('/opt/ros/indigo/bin/rosservice uri ', aServiceName).
	
]
