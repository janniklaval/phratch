"
I generate code that can be loaded dynamically from external libraries (e.g., DSOs on Unix or DLLs on Windows).

"
Class {
	#name : #PluggableCodeGenerator,
	#superclass : #CCodeGenerator,
	#instVars : [
		'cExtras'
	],
	#category : #'Phratch-Primitives-C Translator'
}

{ #category : #'C code generator' }
PluggableCodeGenerator >> cExtras [

	^ cExtras

]

{ #category : #'C code generator' }
PluggableCodeGenerator >> cExtras: aString [
	"Set a string of additional C declarations to be included in the generated file. This feature can be used to add global variable declarations or to import additional header files."

	cExtras := aString.

]

{ #category : #'C code generator' }
PluggableCodeGenerator >> emitCHeaderOn: aStream [
	"Write a C file header onto the given stream."

	aStream nextPutAll: '/* Automatically generated from Squeak on '.
	aStream nextPutAll: Time dateAndTimeNow printString.
	aStream nextPutAll: ' */';cr.

	aStream nextPutAll: '
#if defined(WIN32) || defined(:=WIN32) || defined(Win32)
 #ifdef :=:=cplusplus
  #define DLLEXPORT extern "C" :=:=declspec(dllexport)
 #else
  #define DLLEXPORT :=:=declspec(dllexport)
 #endif /* C++ */
#else
 #define DLLEXPORT
#endif /* WIN32 */'; cr.

	aStream nextPutAll: '
#include "sqVirtualMachine.h"

/* memory access macros */
#define byteAt(i) (*((unsigned char *) (i)))
#define byteAtput(i, val) (*((unsigned char *) (i)) = val)
#define longAt(i) (*((int *) (i)))
#define longAtput(i, val) (*((int *) (i)) = val)
'.

	"additional header files and C extras:"
	headerFiles do: [:hdr | aStream nextPutAll:'#include '; nextPutAll: hdr; cr].
	cExtras ifNotNil: [aStream nextPutAll: cExtras; cr].

	aStream cr.

]

{ #category : #testing }
PluggableCodeGenerator >> isGeneratingPluginCode [

	^ true

]
