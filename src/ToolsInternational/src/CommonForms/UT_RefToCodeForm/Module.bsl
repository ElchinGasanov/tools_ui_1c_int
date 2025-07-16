

#Region Variables

#EndRegion

#Region FormEventHandlers

// Code of procedures and functions


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Ref") Then
		Ref = Parameters.Ref;
	EndIf;
	If Parameters.Property("InsertMode") Then
		InsertMode = Parameters.InsertMode;
	EndIf;
	
	SetVisibilityAvailability();
EndProcedure


#EndRegion

#Region FormHeaderItemsEventHandlers

// Code of procedures and functions

#EndRegion

#Region FormTableItemsEventHandlers //<TableNameForm>

// Code of procedures and functions

#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure CopyToClipboard(Command)
	UT_ClipboardClient.BeginCopyTextToClipboard(Ref,
		New CallbackDescription("CopyToClipboardFinish",
		ThisObject));
EndProcedure


&AtClient
Procedure FollowTheLink(Command)
	UT_CommonClient.OpenURL(Ref);
EndProcedure

&AtClient
Procedure PasteFromClipboard(Command)
	UT_ClipboardClient.BeginGettingTextFormClipboard(New CallbackDescription("PasteFromClipboardFinish",
		ThisObject));

EndProcedure

&AtClient
Procedure Download(Command)
	Close(Ref);
EndProcedure

#EndRegion

#Region Private

// Copy to clipboard finish.
// 
// Parameters:
//  Result - Boolean - Result
//  CallOptions - Arbitrary -
//  ExtraParameters - Undefined - Extra parameters
&AtClient
Procedure CopyToClipboardFinish(Result, CallOptions, ExtraParameters) Export
	If Result = True Then
		Title = NStr("ru = 'Код скопирован в буфер обмена'; en = 'The code has been copied to the clipboard'");
	Else
		Title = NStr("ru = 'Не удалось скопировать в буфер обмена'; en = 'Failed to copy to clipboard'");
	EndIf;
EndProcedure

// Paste from clipboard finish.
// 
// Parameters:
//  Result - Строка - Result
//  ExtraParameters - Undefined - Extra parameters
&AtClient
Procedure PasteFromClipboardFinish(Result, ExtraParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Not ValueIsFilled(Result) Then
		Return;
	EndIf;
	
	Ref = Result;
EndProcedure

&AtServer
Procedure SetVisibilityAvailability()
	If InsertMode Then
		Items.CopyToClipboard.Visible = False;
	Else
		Items.PasteFromClipboard.Visible = False;
		Items.Download.Visible = False;
	EndIf;	
EndProcedure

#EndRegion
