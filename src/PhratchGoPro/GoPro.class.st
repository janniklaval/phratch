Class {
	#name : #GoPro,
	#superclass : #Object,
	#instVars : [
		'ipAddr',
		'portAddr',
		'password'
	],
	#category : #PhratchGoPro
}

{ #category : #'as yet unclassified' }
GoPro class >> Command [

	^ #(
#('bacpac' 'PW' '00' 'Turn GoPro OFF' 'basics')
#('bacpac' 'PW' '01' 'Turn GoPro ON' 'basics')
#('bacpac' 'SH' '01' 'Shutter basics' 'basics')
#('bacpac' 'SH' '00' 'Stop basics' 'basics')
#('camera' 'PV' '02' 'Preview ON' 'basics')
#('camera' 'PV' '00' 'Preview OFF' 'basics')
#('camera' 'CM' '00' 'Video Mode' 'mode')
#('camera' 'CM' '01' 'Photo Mode' 'mode')
#('camera' 'CM' '02' 'Burst Mode' 'mode')
#('camera' 'CM' '03' 'Timelapse Mode' 'mode')
#('camera' 'CM' '04' 'Timer Mode (hero2)' 'mode')
#('camera' 'CM' '05' 'Play HDMI' 'mode')
#('camera' 'UP' '00' 'Orientation 'UP'' 'orientation')
#('camera' 'UP' '01' 'Orientation DOWN' 'orientation')
#('camera' 'VR' '00' 'WVGA 60' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '01' 'WVGA 120' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '02' '720 30' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '03' '720 60' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '04' '960 30' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '05' '960 48' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '06' '1080 30' 'Video resolutions HERO2 and HERO3 silver')
#('camera' 'VV' '08' '4kCin12' 'Video resolutions Black edition')
#('camera' 'VV' '07' '2.7kCin24' 'Video resolutions Black edition')
#('camera' 'VV' '06' '4k 15' 'Video resolutions Black edition')
#('camera' 'VV' '05' '2.7k 30' 'Video resolutions Black edition')
#('camera' 'VV' '04' '1440p 40' 'Video resolutions Black edition')
#('camera' 'VV' '03' '1080 60' 'Video resolutions Black edition')
#('camera' 'VR' '05' '1080 30' 'Video resolutions Black edition')
#('camera' 'VR' '06' '960 48' 'Video resolutions Black edition')
#('camera' 'VV' '02' '960 100' 'Video resolutions Black edition')
#('camera' 'VV' '01' '720 120' 'Video resolutions Black edition')
#('camera' 'VV' '00' 'WVGA 240' 'Video resolutions Black edition')
#('camera' 'VV' '06' '4K' 'Video resolutions HERO3+Black')
#('camera' 'VV' '08' '4K 17:9' 'Video resolutions HERO3+Black')
#('camera' 'FS' '01' '4K 15FPS' 'Video resolutions HERO3+Black')
#('camera' 'FS' '00' '4K 12FPS' 'Video resolutions HERO3+Black')
#('camera' 'VV' '07' '2K' 'Video resolutions HERO3+Black')
#('camera' 'VV' '05' '2.7k' 'Video resolutions HERO3+Black')
#('camera' 'FS' '02' '2.7k 24FPS' 'Video resolutions HERO3+Black')
#('camera' 'FS' '04' '2.7k 30FPS' 'Video resolutions HERO3+Black')
#('camera' 'VV' '04' '1440p' 'Video resolutions HERO3+Black')
#('camera' 'FS' '05' '1440 48FPS' 'Video resolutions HERO3+Black')
#('camera' 'VV' '09' '1080 SuperView' 'Video resolutions HERO3+Black')
#('camera' 'VV' '03' '1080' 'Video resolutions HERO3+Black')
#('camera' 'VV' '02' '960p' 'Video resolutions HERO3+Black')
#('camera' 'VV' '0a' '720 SuperView' 'Video resolutions HERO3+Black')
#('camera' 'VV' '01' '720p' 'Video resolutions HERO3+Black')
#('camera' 'FS' '00' 'FPS12' 'Frame rate')
#('camera' 'FS' '01' 'FPS15' 'Frame rate')
#('camera' 'FS' '0b' 'FPS12p5' 'Frame rate')
#('camera' 'FS' '02' 'FPS24' 'Frame rate')
#('camera' 'FS' '03' 'FPS25' 'Frame rate')
#('camera' 'FS' '04' 'FPS30' 'Frame rate')
#('camera' 'FS' '05' 'FPS4' 'Frame rate')
#('camera' 'FS' '06' 'FPS50' 'Frame rate')
#('camera' 'FS' '07' 'FPS60' 'Frame rate')
#('camera' 'FS' '08' 'FPS100' 'Frame rate')
#('camera' 'FS' '09' 'FPS120' 'Frame rate')
#('camera' 'FS' '0a' 'FPS240' 'Frame rate')
#('camera' 'FV' '00' 'wide' 'Fov')
#('camera' 'FV' '01' 'medium' 'Fov')
#('camera' 'FV' '02' 'narrow' 'Fov')
#('camera' 'PR' '00' '11mpW' 'Photo resolution HERO2 and HERO3 silver')
#('camera' 'PR' '01' '8mpM' 'Photo resolution HERO2 and HERO3 silver')
#('camera' 'PR' '02' '5mpW' 'Photo resolution HERO2 and HERO3 silver')
#('camera' 'PR' '03' '5mpM' 'Photo resolution HERO2 and HERO3 silver')
#('camera' 'TI' '00' '0,5 sec' 'Timelapse Interval')
#('camera' 'TI' '01' '1sec' 'Timelapse Interval')
#('camera' 'TI' '05' '5sec' 'Timelapse Interval')
#('camera' 'TI' '0a' '10sec' 'Timelapse Interval')
#('camera' 'TI' '1e' '30sec' 'Timelapse Interval')
#('camera' 'TI' '3c' '60sec' 'Timelapse Interval')
#('camera' 'BS' '00' 'no sound' 'Volume')
#('camera' 'BS' '01' '70%' 'Volume')
#('camera' 'BS' '02' '100%' 'Volume')
#('camera' 'WB' '00' 'auto' 'White Balance HERO3 ONLY IF Protune ON')
#('camera' 'WB' '01' '3000k' 'White Balance HERO3 ONLY IF Protune ON')
#('camera' 'WB' '02' '5500k' 'White Balance HERO3 ONLY IF Protune ON')
#('camera' 'WB' '03' '6500k' 'White Balance HERO3 ONLY IF Protune ON')
#('camera' 'WB' '04' 'CAMRAW' 'White Balance HERO3 ONLY IF Protune ON')
#('camera' 'CS' '00' 'Single' 'Continuous Shot (HERO3)')
#('camera' 'CS' '03' '3SPS' 'Continuous Shot (HERO3)')
#('camera' 'CS' '05' '5SPS' 'Continuous Shot (HERO3)')
#('camera' 'CS' '0a' '10SPS' 'Continuous Shot (HERO3)')
#('camera' 'BU' '00' '3/1s' 'Burst Rate HERO3')
#('camera' 'BU' '02' '10/1s' 'Burst Rate HERO3')
#('camera' 'BU' '03' '10/2s' 'Burst Rate HERO3')
#('camera' 'BU' '04' '30/1s' 'Burst Rate HERO3')
#('camera' 'BU' '05' '30/2s' 'Burst Rate HERO3')
#('camera' 'BU' '06' '30/3s' 'Burst Rate HERO3')
#('camera' 'LO' '00' 'OFF' 'Loop Video HERO3')
#('camera' 'LO' '01' '5min' 'Loop Video HERO3')
#('camera' 'LO' '02' '20Min' 'Loop Video HERO3')
#('camera' 'LO' '03' '60Min' 'Loop Video HERO3')
#('camera' 'LO' '05' 'Max' 'Loop Video HERO3')
#('camera' 'PT' '01' 'ON' 'Protune ON/OFF')
#('camera' 'PT' '00' 'OFF' 'Protune ON/OFF')
#('camera' 'DL' '' 'last' 'Delete')
#('camera' 'DA' '' 'all' 'Delete')
#('camera' 'PR' '05' '12mpW' 'Photo resolution Black ed')
#('camera' 'PR' '04' '7mpW' 'Photo resolution Black ed')
#('camera' 'PR' '06' '7mpM' 'Photo resolution Black ed')
#('camera' 'PR' '03' '5mpM' 'Photo resolution Black ed')
#('bacpac' 'LB' '00' 'no leds' 'Leds')
#('camera' 'LB' '01' '2 leds' 'Leds')
#('camera' 'LB' '02' '4 leds' 'Leds')
#('camera' 'EX' '00' 'OFF' 'Spot Meter')
#('camera' 'EX' '01' 'ON' 'Spot Meter')
#('camera' 'OB' '00' 'OFF' 'One Button Mode')
#('camera' 'OB' '01' 'ON' 'One Button Mode')
#('camera' 'VR' '07' '1080 30 Protune' 'Protune Resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '08' '1080 24 Protune' 'Protune Resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '11' '1080 25 Protune' 'Protune Resolutions HERO2 and HERO3 silver')
#('camera' 'VR' '09' '960 60 Protune' 'Protune Resolutions HERO2 and HERO3 silver')
#('camera' 'VV' '00' '720 120T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '02' '960 100T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '03' '1080 60T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '04' '1440 48T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '05' '2.7k 30T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '06' '4k 15T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '07' '2.7KCin24T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'VV' '08' '4kCin12T' 'Protune Resolutions HERO3 black ONLY IF PROTUNE IS ON')
#('camera' 'AO' '00' 'NEVER' 'Auto Power Off')
#('camera' 'AO' '01' '60s' 'Auto Power Off')
#('camera' 'AO' '02' '120s' 'Auto Power Off')
#('camera' 'AO' '03' '300s' 'Auto Power Off')
#('camera' 'DM' '00' 'Video' 'Default Mode')
#('camera' 'DM' '01' 'Photo' 'Default Mode')
#('camera' 'DM' '02' 'Burst' 'Default Mode')
#('camera' 'DM' '03' 'Timelapse' 'Default Mode')
#('camera' 'OS' '00' 'OFF' 'OnScreen Display')
#('camera' 'OS' '01' 'ON' 'OnScreen Display')
#('camera' 'LL' '01' 'Start' 'Locate')
#('camera' 'LL' '00' 'Stop' 'Locate')
#('camera' 'VM' '00' 'NTSC' 'Video Mode')
#('camera' 'VM' '01' 'PAL' 'Video Mode')
)
]

{ #category : #'as yet unclassified' }
GoPro >> buildUrlFrom: anArray [

	 "self new buildUrlFrom:#('bacpac' 'PW' '00' 'Turn GoPro OFF' 'basics')"
	
	^ 'http://', ipAddr, '/', (anArray at:1), '/', (anArray at: 2), '?t=', password, '&p=%', (anArray at: 3)
]

{ #category : #'as yet unclassified' }
GoPro >> command: aNumber [
	"self new command: 133"
	"self new command: 134"
	^ (self send: (self buildUrlFrom: (self class Command at: aNumber))).
]

{ #category : #initialization }
GoPro >> initialize [
	super initialize.
	ipAddr := '10.5.5.9'.
	portAddr := '8080'.
	password := 'goprohero3'
]

{ #category : #accessing }
GoPro >> ipAddr [
	
	^ ipAddr
]

{ #category : #accessing }
GoPro >> ipAddr: anObject [
	
	ipAddr := anObject
]

{ #category : #accessing }
GoPro >> password [
	
	^ password
]

{ #category : #accessing }
GoPro >> password: anObject [
	
	password := anObject
]

{ #category : #accessing }
GoPro >> portAddr [
	
	^ portAddr
]

{ #category : #accessing }
GoPro >> portAddr: anObject [
	
	portAddr := anObject
]

{ #category : #'as yet unclassified' }
GoPro >> send: aURLString [

	^ (ZnHTTPSocketFacade httpGet: aURLString).
]
