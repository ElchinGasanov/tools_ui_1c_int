
#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	StructureSource = New Structure;
	If Parameters.Property("ValueStorageContainer") Then
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueStorageContainer;//look at UT_CommonClientServer.NewValueStorageStructureType
		
		If ContainerStorage <> Undefined Then
			StructureSource = UT_Common.ValueFromStructureContainerStorage(ContainerStorage);
		EndIf;
	ElsIf Parameters.Property("StructureForChange") Then 
		//@skip-check unknown-form-parameter-access
		StructureSource = Parameters.StructureForChange;
	EndIf;
	
	ReadStructureInTable(StructureSource);
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersStructureTable


&AtClient
Procedure StructureTableBeforeFinishingEditing(Item, NewRow, CancelEditing, Cancel)
	If CancelEditing Then
		Return;
	EndIf;
	CurrentData = Items.StructureTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	If Not UT_CommonClientServer.IsCorrectVariableName(CurrentData.Key) Then
		Cancel = True;
	EndIf;
EndProcedure


&AtClient
Procedure StructureTableValueOnChange(Item)
	CurrentData = Items.StructureTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	HandlerParameters = UT_CommonClient.NewProcessorInChangingEventsParameters(ThisObject,
																				Item,
																				"Value");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;

	UT_CommonClient.FormFieldInChangeProcessor(HandlerParameters);
EndProcedure

&AtClient
Procedure StructureTableValueStartSelection(Item, ChosenData, StandardProcessing)
	CurrentData = Items.StructureTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
																										  Item,
																										  "Value");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.Value = CurrentData.Value;
	HandlerParameters.StructureValueStorage = CurrentData;
	HandlerParameters.TypesSet = UT_CommonClientServer.AllEditingTypeSets();

	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure StructureTableValueCleaning(Item, StandardProcessing)
	CurrentData = Items.StructureTable.CurrentData; 
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;

	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure Apply(Команда)
	Close(EditedStructureStorage());
EndProcedure


#EndRegion

#Region Private

&AtServer
Функция EditedStructureStorage()
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");

	ReturnStructure = New Structure;

	For Each  TableRow In StructureTable Do
		ReturnStructure.Insert(TableRow.Key,
								   UT_CommonClientServer.ValueContainerFieldValue(TableRow,
																				ValueStorageStructure));
	EndDo;

	Return UT_Common.ValueStorageContainerStructure(ReturnStructure);
EndFunction

&AtServer
Procedure ReadStructureInTable(StructureSource)
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	
	StructureTable.Clear();
	For Each  KeyValue In StructureSource Do
		NewRow = StructureTable.Add();
		NewRow.Key = KeyValue.Key;
		UT_CommonClientServer.SetContainerFieldValue(NewRow,
												ValueStorageStructure,
												KeyValue.Value);
	EndDo;
EndProcedure

#EndRegion
