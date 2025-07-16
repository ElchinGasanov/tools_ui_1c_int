


#Region Variables

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ValueListSource = New ValueList;
	
	If Parameters.Property("ValueStorageContainer") Then
		ReturningStorageForValueContainer = True;
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueStorageContainer;//look at UT_CommonClientServer.NewValueStoreValueListTypeValueList
		
		If ContainerStorage <> Undefined Then
			ValueListSource = UT_Common.ValueFromValueListContainerStorage(ContainerStorage);
		EndIf;
	ElsIf Parameters.Property("ArrayValueStorageContainer") Then 
		ReturningStorageForValueContainer = True;
		IsArray = True;
		
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ArrayValueStorageContainer;//look at UT_CommonClientServer.NewValueStorageArrayType
		
		If ContainerStorage <> Undefined Then
			ValueArraySource = UT_Common.ValueFromArrayContainerStorage(ContainerStorage);
			If ValueArraySource <> Undefined Then
				ValueListSource.LoadValues(ValueArraySource);
			EndIf;
		EndIf;
		
	ElsIf Parameters.Property("List") Then 
		//@skip-check unknown-form-parameter-access
		ValueListSource = Parameters.List;
	EndIf;
	
	If IsArray Then
		Items.ListTableCheck.Visible = False;
		Items.ListTablePresentation.Visible = False;
		Title = NStr("ru = 'Редактор массива'; en = 'Array editor'");
	EndIf;
	
	ReadListOfValuesInTable(ValueListSource);
EndProcedure



#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure ListValueTypeOnChange(Item)
	ListValueTypeOnChangeAtServer();
EndProcedure

// Код процедур и функций
&AtClient
Procedure ListValueTypeStartChoice(Item, ChosenData, StandardProcessing)
	StandardProcessing = False;

	UT_CommonClient.EditType(ListValueType,
		1,
		StandardProcessing,
		ThisObject,
		New CallbackDescription("ListTableValueStartChoiceFinish",
		ThisObject));
EndProcedure


#EndRegion

#Region FormTableItemsEventHandlersListTable

&AtClient
Procedure ListTableValueStartChoice(Item, ChosenData, StandardProcessing)
	CurrentData = Items.ListTable.CurrentData;
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
	HandlerParameters.CurrentDescriptionValueTypes = ListValueType;

	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure ListTableValueOnChange(Item)
	CurrentData = Items.ListTable.CurrentData;
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
Procedure ListTableValueСlearing(Item, StandardProcessing)
	CurrentData = Items.ListTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;
	HandlerParameters.CurrentDescriptionValueTypes = ListValueType;

	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure ListTablePictureClick(Item, StandardProcessing)
	CurrentData = Items.ListTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	TableListPictureStartChose(Items.ListTable.CurrentRow);
EndProcedure

&AtClient
Procedure ListTableChose(Item, ChosenRow, Field, StandardProcessing)
	If Field.Name <> "ListTablePicture" Then
		Return;
	EndIf;
	StandardProcessing = False;
	
	TableListPictureStartChose(ChosenRow);
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure Apply(Command)
	Close(ReturnValueOfForm());
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure TableListPictureStartChose(RowID)
	CurrentData = ListTable.FindByID(RowID);
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	CallbackSettings = New Structure;
	CallbackSettings.Insert("RowID", RowID);

	UT_CommonClient.EditPicture(CurrentData.Picture,
		New CallbackDescription("ListTablePictureClickFinish",
		ThisObject, CallbackSettings));
	
EndProcedure

&AtClient
Procedure ListTablePictureClickFinish(Result, ExtraParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	TableRow = ListTable.FindByID(ExtraParameters.RowID);
	If TableRow = Undefined Then
		Return;
	EndIf;
	
	TableRow.Picture = Result;
EndProcedure

&AtServer
Function EditedList()
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");

	List = New ValueList();
	List.ValueType = ListValueType;
	
	For Each TableRow In ListTable Do
		List.Add(UT_CommonClientServer.ValueContainerFieldValue(TableRow,
						ValueStorageStructure),
						TableRow.Presentation,
						TableRow.Check,
						TableRow.Picture);
	EndDo;
	
	Return List;	
EndFunction

&AtServer
Function ReturnValueOfForm()
	List = EditedList();
	
	If ReturningStorageForValueContainer Then
		If IsArray Then
			Return UT_Common.ValueStorageContainerArrayFromValueList(List);
		Else
			Return UT_Common.ValueStorageContainerValueList(List);
		EndIf;
	Else
		If IsArray Then
			Return List.UnloadValues();
		Else
			Return List;
		EndIf;
	EndIf;
EndFunction

// Read a list of values ​​into a table.
// 
// Parameters:
//  SourceList - ValueList of Arbitrary - Source list
&AtServer
Procedure ReadListOfValuesInTable(SourceList)
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");

	ListValueType = SourceList.ValueType;
		
	ListTable.Clear();
	For Each ItemList In SourceList Do
		NewRow = ListTable.Add();
		NewRow.Check = ItemList.Check;
		NewRow.Presentation = ItemList.Presentation;
		NewRow.Picture = ItemList.Picture;

		UT_CommonClientServer.SetContainerFieldValue(NewRow,
																		   ValueStorageStructure,
																		   ItemList.Value);
	EndDo;
	
EndProcedure

&AtClient
Procedure ListTableValueStartChoiceFinish(Result, ExtraParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ListValueType = Result;

	ListValueTypeOnChangeAtServer();
EndProcedure

&AtServer
Procedure ListValueTypeOnChangeAtServer()
	BringListValueToListValueType();
EndProcedure

&AtServer
Procedure BringListValueToListValueType() 
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	For Each TableRow In ListTable Do
		FieldValue = UT_CommonClientServer.ValueContainerFieldValue(TableRow,
																	ValueStorageStructure);
		NewFieldValue = ListValueType.AdjustValue(FieldValue);

		If FieldValue <> NewFieldValue Or TypeOf(FieldValue) <> TypeOf(NewFieldValue) Then
			UT_CommonClientServer.SetContainerFieldValue(TableRow,
														ValueStorageStructure,
														NewFieldValue);
		EndIf;

	EndDo;
EndProcedure
#EndRegion
