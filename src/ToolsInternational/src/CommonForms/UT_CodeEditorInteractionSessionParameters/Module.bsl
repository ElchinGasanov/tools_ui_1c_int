
#Region Variables

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UserName = UserFullName();
EndProcedure



#EndRegion

#Region FormHeaderItemsEventHandlers

//Code of procedures and functions

#EndRegion

#Region FormTableItemsEventHandlers //<TableNameForm>

//Code of procedures and functions

#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure Connect(Command)
	SessionParam = UT_CodeEditorClientServer.NewOptionsSessionInteractions();
	SessionParam.UserName = UserName;
	If ValueIsFilled(SessionID) Then
		SessionParam.ID = SessionID; 
	EndIf;
	
	If ValueIsFilled(InteractionURL) Then
		SessionParam.InteractionURL = InteractionURL;
	EndIf;
	
	Close(SessionParam);
EndProcedure

#EndRegion

#Region Private

//Code of procedures and functions

#EndRegion
