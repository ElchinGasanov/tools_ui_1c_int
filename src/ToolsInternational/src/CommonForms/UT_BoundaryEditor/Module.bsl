
#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	BoundaryType = "Including";
	
	ValueStorageContainer = Undefined;
	If Parameters.Property("ValueStorageContainer") Then
		//@skip-check unknown-form-parameter-access
		ValueStorageContainer = Parameters.ValueStorageContainer; //look at UT_CommonClientServer.NewValueStorageBoundaryType
		
	EndIf;

	If ValueStorageContainer <> Undefined Then
		Date = ValueStorageContainer.Дата;
		BoundaryType = ValueStorageContainer.BoundaryType;
	EndIf;

EndProcedure



#EndRegion

#Region FormHeaderItemsEventHandlers


#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure Apply(Command)
	If Not CheckFilling() Then
		Возврат;
	EndIf;

	Close(UT_CommonClientServer.ValueOfTheBoundaryStorageContainer(Date, BoundaryType));
EndProcedure


#EndRegion

#Region Private

// Code of procedures and functions

#EndRegion
