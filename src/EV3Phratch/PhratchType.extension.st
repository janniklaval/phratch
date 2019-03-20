Extension { #name : #PhratchType }

{ #category : #'*EV3Phratch' }
PhratchType >> ev3Buttons [
	
	<phratchType: #'ev3Buttons'>
	^ ChoiceArgMorph new options: #(buttonUp buttonEnter buttonDown buttonRight buttonLeft buttonBack buttonAny); choice: #buttonAny;
		yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> ev3FontType [
	
	<phratchType: #'ev3FontType'>
	^ ChoiceArgMorph new options: #(Small Medium Large); choice: #Medium;
		yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> ev3Leds [
	
	<phratchType: #'ev3Leds'>
	^ ChoiceArgMorph new options: #(#Black #Green #Red #Orange #GreenFlash #RedFlash #OrangeFlash #GreenPulse #RedPulse #OrangePulse ); choice: #Black;
		yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> ev3Motors [
	
	<phratchType: #'ev3Motors'>
	^ ChoiceArgMorph new options: #(#motorA #motorB #motorC #motorD #motorSync); choice: #motorA;
		yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> ev3ScreenColor [
	
	<phratchType: #'ev3ScreenColor'>
	^ ChoiceArgMorph new options: #(Background Foreground); choice: #Foreground;
		yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> ev3SensorType [
	
	<phratchType: #'ev3SensorType'>
	^ ChoiceArgMorph new options: (Ev3Sensor allSubclasses collect:[:e | e asString] );
		yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> ev3Sensors [
	
	<phratchType: #'ev3Sensors'>
	^ ChoiceArgMorph new options: #(#sensor1 #sensor2 #sensor3 #sensor4); choice: #sensor1; yourself
]

{ #category : #'*EV3Phratch' }
PhratchType >> sensorMode [
	
	<phratchType: #'sensorMode'>
	"^ ExpressionArgMorphWithMenu new numExpression: 1; menuSelector: #sensorMode; yourself"
	^ ChoiceArgMorph new options: #(#Mode0 #Mode1 #Mode2 #Mode3 #Mode4 #Mode5 #Mode6); choice: #Mode0; yourself
]
