

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	SourceMap = New Map;
	If Parameters.Property("ValueStorageContainer") Then
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueStorageContainer;// look at UT_CommonClientServer.NewValueStorageMapType
		
		If ContainerStorage <> Undefined Then
			SourceMap = UT_Common.ValueFromMapContainerStorage(ContainerStorage);
		EndIf;
	ElsIf Parameters.Property("StructureForChange") Then 
		//@skip-check unknown-form-parameter-access
		SourceMap = Parameters.StructureForChange;
	EndIf;
	
	ReadMapInTable(SourceMap);
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersMapTable

&AtClient
Procedure MapTableValueOnChange(Item)
	
	CurrentData = Items.MapTable.CurrentData;
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
Procedure MapTableValueStartСhoice(Item, ChosenData, StandardProcessing)
	CurrentData = Items.MapTable.CurrentData;
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
Procedure MapTableValueСlearing(Item, StandardProcessing)
	CurrentData = Items.MapTable.CurrentData;
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


&AtClient
Procedure MapTableKeyStartСhoice(Item, ChosenData, StandardProcessing)
	CurrentData = Items.MapTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
																										  Item,
																										  "Key");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.Value = CurrentData.Key;
	HandlerParameters.StructureValueStorage = CurrentData;
	HandlerParameters.TypesSet = UT_CommonClientServer.AllEditingTypeSets();

	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure MapTableKeyСlearing(Item, StandardProcessing)
	CurrentData = Items.MapTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"Key");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;

	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure MapTableKeyOnChange(Item)
	CurrentData = Items.MapTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	HandlerParameters = UT_CommonClient.NewProcessorInChangingEventsParameters(ThisObject,
																				Item,
																				"Key");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;

	UT_CommonClient.FormFieldInChangeProcessor(HandlerParameters);
EndProcedure



#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure Apply(Command)
	Close(MapEditedStorage());
EndProcedure


#EndRegion

#Region Private

&AtServer
Function MapEditedStorage()
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	KeyStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Key");

	ReturnMap = New Map;

	For Each  TableRow In MapTable Do
		ReturnMap.Insert(UT_CommonClientServer.ValueContainerFieldValue(TableRow,
																KeyStorageStructure),
									  UT_CommonClientServer.ValueContainerFieldValue(TableRow,
																ValueStorageStructure));
	EndDo;

	Return UT_Common.ValueStorageContainerMap(ReturnMap);
EndFunction

&AtServer
Procedure ReadMapInTable(SourceMap)
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	KeyStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Key");
	
	MapTable.Clear();
	For Each  KeyValue In SourceMap Do
		NewRow = MapTable.Add();
		UT_CommonClientServer.SetContainerFieldValue(NewRow,
													KeyStorageStructure,
													KeyValue.Key);
		UT_CommonClientServer.SetContainerFieldValue(NewRow,
													ValueStorageStructure,
													KeyValue.Value);
	EndDo;
EndProcedure

#EndRegion
