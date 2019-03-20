"
/// <summary>
	/// Sensor mode when using a NXT light sensor
    /// </summary>
    public enum LightMode { 
		/// <summary>
		/// Use the lgith sensor to read reflected light
		/// </summary>
		Relection = SensorMode.Mode0, 
		
		/// <summary>
		/// Use the light sensor to detect the light intensity
		/// </summary>
		Ambient  = SensorMode.Mode1,
	};
	
	/// <summary>
	/// Class for the NXT light sensor
	/// </summary>
	public class LightSensor : Sensor{
		/// <summary>
		/// Initializes a new instance of the <see cref=""MonoBrick.EV3.LightSensor""/> class.
		/// </summary>
		public LightSensor () : base((SensorMode)LightMode.Relection)
		{
			
		}
		
		/// <summary>
		/// Initializes a new instance of the <see cref=""MonoBrick.EV3.LightSensor""/> class.
		/// </summary>
		/// <param name=""mode"">Mode.</param>
		public LightSensor (LightMode mode) :  base((SensorMode)mode)
		{
		
		}
		/// <summary>
		/// Gets or sets the light mode.
		/// </summary>
		/// <value>The mode.</value>
		public LightMode Mode {
			get{return (LightMode) this.mode;}
			set{SetMode((SensorMode) value);}
		}

		/// <summary>
		/// Reads the sensor value as a string.
		/// </summary>
		/// <returns>The value as a string</returns>
		public override string ReadAsString ()
		{
			string s = """";
			switch (mode)
			{
			    case (SensorMode)LightMode.Ambient:
			        s = Read().ToString();
			        break;
			   case (SensorMode)LightMode.Relection:
			        s = Read().ToString();
			        break;
			}
			return s;
		}
		
		/// <summary>
		/// Read this instance.
		/// </summary>
		public int Read()
		{
			int value = 0;
			switch (mode)
			{
			    case (SensorMode)LightMode.Ambient:
			        value = GetRead();
			        break;
			   case (SensorMode)LightMode.Relection:
			        value = GetRead();
			        break;
			}
			return value;			
		}
		
		/// <summary>
		/// Reads the raw sensor value.
		/// </summary>
		/// <returns>The raw sensor value.</returns>
		public int ReadRaw ()
		{
			return GetRaw();
		}
		
	}
	
	
	/// <summary>
	/// Sensor mode when using a sound sensor
    /// </summary>
    public enum SoundMode { 
		/// <summary>
		/// The sound level is measured in A-weighting decibel
		/// </summary>
		SoundDBA = SensorMode.Mode1, 
		/// <summary>
		/// The sound level is measured in decibel 
		/// </summary>
		SoundDB = SensorMode.Mode0 };
    
	/// <summary>
	/// Class for the NXT sound sensor
	/// </summary>
	public class SoundSensor : Sensor{
		/// <summary>
		/// Initializes a new instance of the <see cref=""MonoBrick.EV3.SoundSensor""/> class.
		/// </summary>
		public SoundSensor () : base((SensorMode)SoundMode.SoundDBA)
		{
			
		}
		
		/// <summary>
		/// Initializes a new instance of the <see cref=""MonoBrick.EV3.SoundSensor""/> class.
		/// </summary>
		/// <param name=""mode"">Mode.</param>
		public SoundSensor (SoundMode mode) :  base((SensorMode)mode)
		{
		
		}
		
		/// <summary>
		/// Reads the sensor value as a string.
		/// </summary>
		/// <returns>The value as a string</returns>
		public override string ReadAsString ()
		{
			string s = """";
			switch (mode)
			{
			    case (SensorMode)SoundMode.SoundDB:
			        s = Read().ToString();
			        break;
			   case (SensorMode)SoundMode.SoundDBA:
			        s = Read().ToString();
			        break;
			}
			return s;
		}
		
		/// <summary>
		/// Read the sensor value
		/// </summary>
		public int Read()
		{
			int value = 0;
			switch (mode)
			{
			    case (SensorMode)SoundMode.SoundDB:
			        value = GetRead();
			        break;
			   case (SensorMode)SoundMode.SoundDBA:
			        value = GetRead();
			        break;
			}
			return value;			
		}
		
		/// <summary>
		/// Reads the raw sensor value
		/// </summary>
		/// <returns>The raw value.</returns>
		public int ReadRaw ()
		{
			return GetRaw();
		}
		
		/// <summary>
		/// Gets or set the sound mode.
		/// </summary>
		/// <value>The mode.</value>
		public SoundMode Mode {
			get{return (SoundMode) this.mode;}
			set{SetMode((SensorMode) value);}
		}

	}
	
	/// <summary>
	/// Sensor modes when using a ultrasonic sensor
	/// </summary>
	public enum UltrasonicMode { 
		#pragma warning disable 
			/// <summary>
			/// Result will be in centimeter
			/// </summary>
			Centimeter = SensorMode.Mode0,
			/// <summary>
			/// Result will be in inch
			/// </summary>
			Inch = SensorMode.Mode1,
			
			/// <summary>
			/// Sensor is in listen mode
			/// </summary>
			Listen = SensorMode.Mode2
		#pragma warning restore
	};
	
	/// <summary>
	/// Class for the EV3 and NXT ultrasonic sensor
	/// </summary>
	class UltrasonicSensor : Sensor{
		/// <summary>
		/// Initializes a new instance of the <see cref=""MonoBrick.EV3.UltrasonicSensor""/> class.
		/// </summary>
		public UltrasonicSensor () : base((SensorMode)UltrasonicMode.Centimeter)
		{
			
		}
		
		/// <summary>
		/// Initializes a new instance of the <see cref=""MonoBrick.EV3.UltrasonicSensor""/> class.
		/// </summary>
		/// <param name=""mode"">Mode.</param>
		public UltrasonicSensor (UltrasonicMode mode) :  base((SensorMode)mode)
		{
		
		}
		
		/// <summary>
		/// Gets or sets the ultrasonic mode.
		/// </summary>
		/// <value>The mode.</value>
		public UltrasonicMode Mode {
			get{return (UltrasonicMode) this.mode;}
			set{SetMode((SensorMode) value);}
		}

		/// <summary>
		/// Reads the sensor value as a string.
		/// </summary>
		/// <returns>The value as a string</returns>
		public override string ReadAsString ()
		{
			string s = """";
			switch (mode)
			{
			    case (SensorMode)UltrasonicMode.Centimeter:
			        s = Read().ToString() + "" cm"";
			        break;
			   	case (SensorMode)UltrasonicMode.Inch:
			        s = Read().ToString() +  "" inch"";
			        break;
			    case (SensorMode)UltrasonicMode.Listen:
			        s = Read().ToString();
			        break;
			}
			return s;
		}
		
		/// <summary>
		/// Read the sensor value. Result depends on the mode
		/// </summary>
		public float Read()
		{
			return ReadSi();			
		}
	}
	

"
Class {
	#name : #Ev3Sensor,
	#superclass : #Ev3Block,
	#instVars : [
		'brickPort',
		'type',
		'mode',
		'sensorPort'
	],
	#classVars : [
		'SensorMode',
		'SensorPort',
		'SensorType'
	],
	#category : #EV3Bricks
}

{ #category : #accessing }
Ev3Sensor class >> mode [

	^{ 
		#Mode0->#Mode0. 
		#Mode1->#Mode1.
		#Mode2->#Mode2
	} asDictionary 
]

{ #category : #accessing }
Ev3Sensor class >> sensorFormat [
	^ { #Percent -> 16r10. #Raw -> 16r11. #SI -> 16r12 } asDictionary.
]

{ #category : #accessing }
Ev3Sensor class >> sensorMode [
	^ { #Mode0 -> 0. #Mode1 -> 1. #Mode2 -> 2. #Mode3 -> 3. #Mode4 -> 4. #Mode5 -> 5. #Mode6 -> 6 } asDictionary.
]

{ #category : #accessing }
Ev3Sensor class >> sensorPort [
	^  { #In1 -> 0. #In2 -> 1. #In3 -> 2. #In4 -> 3} asDictionary.
]

{ #category : #accessing }
Ev3Sensor class >> sensorType [
	^ { #Unknown -> 16rff. #NXTTouch -> 1. #NXTLight -> 2. #NXTSound -> 3. #NXTColor -> 4. #NXTUltraSonic -> 5. #NXTTemperature -> 6. 
	
	#LargeMotor -> 7 . 
	#MediumMotor -> 8.
	#OtherDevice -> 14.
	#Touch -> 16. 
	#Test -> 21. 
	#OtherScale -> 28.
	#Color -> 29. 
	#Ultrasonic -> 30. 
	#Gyro -> 32. 
	#IR -> 33. 
	#EnergyMeter -> 99.
	#IIC -> 100. 
	#NXTTest -> 101.   
	
	
	#None -> 126 . 
	#Initializing -> 16r7d . 
	#Empty -> 16r7e . 
	#WrongPort -> 16r7f} asDictionary.
]

{ #category : #accessing }
Ev3Sensor class >> typeString [

	^ self subclassResponsibility 
]

{ #category : #accessing }
Ev3Sensor >> brickPort [
	
	^ brickPort
]

{ #category : #accessing }
Ev3Sensor >> brickPort: anObject [
	
	brickPort := anObject
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> clearAll [

	^ self clearAllReply: false.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> clearAllReply: aBool [

	|command reply  |
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #ClearAll).
	command appendByte: self daisyChainLayer.
		
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> clearChanges [

	^ self clearChangesReply: false.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> clearChangesReply: aBool [

	|command reply  |
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #ClrChanges).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
		
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getBumbs [

	|command reply  |
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetBumps).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getFloatAt: 4
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getChanges [

	|command reply  |
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetChanges).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getFloatAt: 4
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getFigures [

	|command reply figures decimals |
	command := Ev3Command newGlobal: 2 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetFigures).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 1.
	
	reply := self brick sendCommand: command withReply: true.
	
	figures := reply getByteAt: 4.
	decimals := reply getByteAt: 5.
	
	^ Dictionary newFrom: {#figures->figures. #decimals->decimals}
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getMinMax [

	|command reply min max  |
	command := Ev3Command newGlobal: 8 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetMinMax).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 4.
	
	reply := self brick sendCommand: command withReply: true.
	
	min := reply getFloatAt: 4.
	max := reply getFloatAt: 8.
	
	^ Dictionary newFrom: {#min->min. #max->max}
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getModeName [

	^ self getModeName: self mode
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getModeName: aSensorMode [

	|command reply|
	command := Ev3Command newGlobal: (Ev3Command shortValueMax) local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetModeName).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	command addLongByteValue: (Ev3Sensor sensorMode at: self mode).
	
	command addLongByteValue: (Ev3Command shortValueMax).
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getDataStringFrom: 3 size: (Ev3Command shortValueMax).
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getName [

	|command reply|
	command := Ev3Command newGlobal: (Ev3Command shortValueMax) local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetName).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: (Ev3Command shortValueMax).
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getDataStringFrom: 4 size: (Ev3Command shortValueMax) .
	
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getRaw [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetRaw).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getInt32At: 4
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getRead [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputRead).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: 0.
	command appendByte: (Ev3Sensor sensorMode at: self mode).
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getByteAt: 4.
	
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getSensorMode [

	"self getTypeAndMode."
	^ mode.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getSensorType [

	self getTypeAndMode.
	^ type.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getSymbole [

	|command reply|
	command := Ev3Command newGlobal: (Ev3Command shortValueMax) local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetSymbol).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: (Ev3Command shortValueMax).
	command addShortByteGlobalVariableAtAddress: 0.

	reply := self brick sendCommand: command withReply: true.
	^ reply getDataStringFrom: 4 size: (Ev3Command shortValueMax).
	
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> getTypeAndMode [

	|command reply|
	command := Ev3Command newGlobal: 2 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #GetTypeMode).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 1.
	
	reply := self brick sendCommand: command withReply: true.
	type := Ev3Sensor sensorType keyAtValue: (reply getByteAt: 4).
	"mode := Ev3Sensor sensorMode keyAtValue: (reply getByteAt: 5)."
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> initialize [

	super initialize.
	mode := #Mode0.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> initializeSensor [

	self setMode: mode.
	self readyRaw.
]

{ #category : #accessing }
Ev3Sensor >> mode [
	
	^ mode
]

{ #category : #accessing }
Ev3Sensor >> modeName [

	^ self class mode keyAtValue: mode.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> read [

	^ self getRead.
	
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> readAsString [

	|s|
	s := String new writeStream.
	s nextPutAll: self getRaw asString.
	s nextPutAll: ' '.
	s nextPutAll: self getSymbole asString.
	^ s contents. 
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> readSi [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputReadSI).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: 0.
	command appendByte: (Ev3Sensor sensorMode at: self mode).
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getFloatAt: 4.
	
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> readyPct [

	|command reply  |
	command := Ev3Command newGlobal: 1 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #ReadyPCT).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: 0.
	command appendByte: (Ev3Sensor sensorMode at: self mode).
	command addLongByteValue: 1.
	
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getByteAt: 4
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> readyRaw [

	|command reply  |
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #ReadyRaw).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: 0.
	command appendByte: (Ev3Sensor sensorMode at: self mode).
	command addLongByteValue: 1.
	
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getInt32At: 4
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> readySi [

	|command reply  |
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #ReadySI).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addShortValue: 0.
	command appendByte: (Ev3Sensor sensorMode at: self mode).
	command addShortValue: 1.
	
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply getFloatAt: 4
]

{ #category : #accessing }
Ev3Sensor >> sensorPort [
	
	^ sensorPort
]

{ #category : #accessing }
Ev3Sensor >> sensorPort: anObject [
	
	sensorPort := anObject
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> setMode: aModeSymbol [

	|command reply|
	mode:= aModeSymbol.
	
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputReadSI).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: 0.
	command appendByte: (Ev3Sensor sensorMode at: mode).
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^ reply
	
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> setUpRepeat: repeat time: repeatTime data: writeData [

	|command reply  |
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #Setup).
	command appendByte: self daisyChainLayer.
	command appendByte: self brickPort.
	
	command addLongByteValue: repeat.
	command addInt16Value: repeatTime.
	
	command addInt32Value: writeData size.
	command addLongByteValue: 1.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^reply getByteAt: 4
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> stopAll [

	^ self stopAllReply: false.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> stopAllReply: aBool [

	|command reply  |
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #StopAll).
	command appendByte: self daisyChainLayer.
		
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> write: aByteArray [

	^ self write: aByteArray reply: false.
]

{ #category : #'as yet unclassified' }
Ev3Sensor >> write: aByteArray reply: aBool [ 
	
	|command reply  |
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #InputWrite).
	command appendByte: self daisyChainLayer.
	command addShortValue: aByteArray size.
	
	aByteArray do:[:aByte|
		command appendByte: aByte.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]
