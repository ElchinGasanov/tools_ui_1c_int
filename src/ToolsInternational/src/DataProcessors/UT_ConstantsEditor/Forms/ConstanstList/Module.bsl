
#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ShowSynonym = True;
	SetFormConditionalAppearance();
	
	FillConstantsTable();

	UT_Forms.CreateWriteParametersAttributesFormOnCreateAtServer(ThisObject,
		Items.GroupWriteParametrs);
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers


&AtClient
Procedure SearchBarOnChange(Item)
	ProcessSearchConstant();
EndProcedure

&AtClient
Procedure SearchBarClearing(Item, StandardProcessing)
	ProcessSearchConstant();
EndProcedure

&AtClient
Procedure ShowSynonymOnChange(Item)
	Items.ConstantsTableConstantSynonym.Visible = ShowSynonym;	
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlers_ConstantsTable

&AtClient
Procedure ConstantsTableConstantValueStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentDate = Items.ConstantsTable.CurrentData;
	Если CurrentDate = Undefined Then
		Return;
	EndIf;

	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
																			Item,
																			"ConstantValue");

	HandlerParameters.AvailableContainer = False;
	HandlerParameters.StructureValueStorage = CurrentDate;
	HandlerParameters.Value = CurrentDate.ConstantValue;
	HandlerParameters.CurrentDescriptionValueTypes = CurrentDate.TypeDescription;

	CallbackParameters = New Structure;
	CallbackParameters.Insert("CurrentRow", CurrentDate.GetID());

	HandlerParameters.CallBackChoiceNotificationsEnding = New CallbackDescription("ConstantsTableConstantValueStartSelectionFinish",
		ThisObject, CallbackParameters);
	
	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure ConstantsTableConstantValueOnChange(Item)
	CurrentDate = Items.ConstantsTable.CurrentData;
	Если CurrentDate = Undefined Then
		Return;
	EndIf;
	
	ConstantOnChange(CurrentDate);
EndProcedure

&AtClient
Procedure ConstantsTableConstantValueClearing(Item, StandardProcessing)
	CurrentDate = Items.ConstantsTable.CurrentData;
	Если CurrentDate = Undefined Then
		Return;
	EndIf;

	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"ConstantValue");

	HandlerParameters.AvailableContainer = False;
	HandlerParameters.StructureValueStorage = CurrentDate;
	HandlerParameters.CurrentDescriptionValueTypes = CurrentDate.TypeDescription;

	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
	
	ConstantOnChange(CurrentDate);
EndProcedure


#EndRegion


#Region FormCommandsEventHandlers


&AtClient
Procedure Reread(Command)
	If IsChangedConstants() Then
		ShowQueryBox(New NotifyDescription("RereadEnd", ThisObject),
		NStr("en = 'Some constants has changed. Write changed before rereading?'; ru = 'Есть измененные константы. Произвести запись перед чтением?'"), QuestionDialogMode.YesNoCancel);
	Иначе
		ReadConstants();
	EndIf;
EndProcedure

&AtClient
Procedure WriteConstants(Command)
	WriteAtServer();
EndProcedure

//@skip-warning 
&AtClient
Procedure Attachable_SetWriteSettings(Command)
	UT_CommonClient.EditWriteSettings(ThisObject);
EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure
#EndRegion

#Region Private


&AtClient
Procedure ConstantsTableConstantValueStartSelectionFinish(Result, AdditionalParameters) Export
	CurrentDate = ConstantsTable.FindByID(AdditionalParameters.CurrentRow);
	Если CurrentDate = Undefined Then
		Return;
	EndIf;
	
	ConstantOnChange(CurrentDate);
EndProcedure

&AtServer
Procedure SetFormConditionalAppearance()
	ConditionalAppearance.Items.Clear();
	
	// Highlight changed constants with color
	NewItemAppearance = ConditionalAppearance.Items.Add();
	NewItemAppearance.Use = True;
	
	UT_CommonClientServer.SetFilterItem(NewItemAppearance.Filter,
															"ConstantsTable.IsChanged",
															True);
	
	NewItemAppearance.Appearance.SetParameterValue("BackColor", WebColors.PaleTurquoise);
	
	AppearanceField = NewItemAppearance.Fields.Items.Add();
	AppearanceField.Use = True;
	AppearanceField.Field = New DataCompositionField("ConstantsTable");
EndProcedure

&AtClient
Procedure ConstantOnChange(ConstantRow)
	ConstantRow.IsChanged = True;
EndProcedure

&AtServer
Procedure FillConstantsTable()

	SetPrivilegedMode(True);

	ConstantsTable.Clear();
	
	For Each Constant In Metadata.Constants Do
		
		NewRow = ConstantsTable.Add();
		NewRow.ConstantName = Constant.Name;
		NewRow.ConstantSynonym = Constant.Synonym;
		NewRow.TypeDescription = Constant.Type;
		NewRow.ConstantValue = Constants[Constant.Name].Get();
		
	EndDo;
	
	// Fill constants functional options
	For Each FunctionalOption In Metadata.FunctionalOptions do
		If Not Metadata.Constants.Contains(FunctionalOption.Location) Then
			Continue;
		EndIf;

		SearchStructure = New Structure;
		SearchStructure.Insert("ConstantName",FunctionalOption.Location.Name);

		FoundRows = ConstantsTable.FindRows(SearchStructure);
		If FoundRows.Count() = 0 Then
			Continue;
		EndIf;

		FoundRows[0].FunctionalOption = FunctionalOption.Name;
		FoundRows[0].PrivilegedGetMode = FunctionalOption.PrivilegedGetMode;
	EndDo;

EndProcedure



&AtServer
Procedure WriteAtServer()
	IsSuccessfully = True;
	For each ConstantRow In ConstantsTable Do
		If Не ConstantRow.IsChanged Then
			Continue;
		EndIf;

		ConstantManager = Constants[ConstantRow.ConstantName].CreateValueManager();
		ConstantManager.Read();
		ConstantManager.Value = ConstantRow.ConstantValue;

		If UT_Common.WriteObjectToDB(ConstantManager,
			UT_CommonClientServer.FormWriteSettings(ThisObject)) Then
			ConstantRow.IsChanged = False;

		Else
			IsSuccessfully = False;
			
		EndIf;

	EndDo;

	If IsSuccessfully Then
		ThisObject.Modified = False;
	EndIf;
EndProcedure

&AtServer
Procedure ReadConstants()
	FillConstantsTable();
	Modified = False;
EndProcedure

&AtClient
Function IsChangedConstants()
	IsChanged = False;
	For Each ConstantRow In ConstantsTable Do
		If ConstantRow.IsChanged Then
			IsChanged = True;
			Break;
		EndIf;
	EndDo;

	Return IsChanged;
EndFunction

&AtClient
Procedure RereadEnd(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.Cancel Then
		Return;
	ElsIF Result = DialogReturnCode.Yes Then
		WriteAtServer();
	EndIf;

	ReadConstants();
EndProcedure

&AtClient
Procedure ProcessSearchConstant()
	Search = TrimAll(Lower(SearchBar));
	
	If Not ValueIsFilled(Search) Then
		Items.ConstantsTable.RowFilter = Undefined;
	EndIf;	
	
	RowFilter = New Structure;
	RowFilter.Insert("Found", True);
	Items.ConstantsTable.RowFilter = New FixedStructure(RowFilter);
	
	For Each CurrentRowConstants In ConstantsTable Do
		CurrentRowConstants.Found = StrFind(Lower(CurrentRowConstants.ConstantName), Search) > 0
								   Or StrFind(Lower(CurrentRowConstants.ConstantSynonym), Search) > 0;
	EndDo;

EndProcedure


#EndRegion

