
#Region Public

// Start promise executio.
// 
// Parameters:
//  Promise - Promise, Произвольный -
//  CallbackDescriptionAboutFinish - CallbackDescription - Callback description about finish
//  CallbackDescriptionAboutError - CallbackDescription, Undefined - Callback description about error
Async Procedure SetCallbackDescriptionForPromise(Promise, CallbackDescriptionAboutFinish,
	CallbackDescriptionAboutError = Undefined) Export
	If TypeOf(Promise) = Type("Promise") Then
		Попытка
			Result = Await Promise;
		Исключение
			ErrorInfo = ErrorInfo();

			If CallbackDescriptionAboutError = Undefined Then
				RunCallback(CallbackDescriptionAboutError, ErrorInfo);
			Else
				RunCallback(CallbackDescriptionAboutFinish, ErrorInfo);
			EndIf;
		КонецПопытки;
	Else
		Result = Promise;
	EndIf;

	RunCallback(CallbackDescriptionAboutFinish, Result);

EndProcedure

#EndRegion

#Region Internal

// Code of procedures and functions

#EndRegion

#Region Private

// Code of procedures and functions

#EndRegion
