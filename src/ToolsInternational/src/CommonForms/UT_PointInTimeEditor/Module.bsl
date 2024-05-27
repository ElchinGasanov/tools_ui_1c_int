

#Region Variables

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ValueStorageContainer = Undefined;
	If Parameters.Property("ValueStorageContainer") Then
		//@skip-check unknown-form-parameter-access
		ValueStorageContainer = Parameters.ValueStorageContainer; //look at UT_CommonClientServer.NewValueStoragePointInTimeType
	EndIf;

	If ValueStorageContainer <> Undefined Then
		Date = ValueStorageContainer.Date;
		Ref = ValueStorageContainer.Ref;
	EndIf;

EndProcedure



#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure RefStartChoice(Item, ChosenData, StandardProcessing)
	AvailableSets = UT_CommonClientServer.AvailableEditingTypesSets();
	
	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
																			Item,
																			"Ref");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.Value = Ref;
	HandlerParameters.StructureValueStorage = ThisObject;
	HandlerParameters.TypesSet = AvailableSets.Ссылки;

	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure RefClearing(Item, StandardProcessing)

	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"Ref");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.StructureValueStorage = ThisObject;
	
	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
EndProcedure



#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure Apply(Command)
	If Not CheckFilling() Then
		Return;
	EndIf;

	Close(UT_CommonClientServer.ValueOfTheTimeMomentStorageContainerByDateAndReference(Date, Ref));
EndProcedure


#EndRegion

#Region Private

// Code of procedures and functions

#EndRegion
