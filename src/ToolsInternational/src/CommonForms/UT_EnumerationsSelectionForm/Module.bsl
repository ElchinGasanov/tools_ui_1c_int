
#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing) 
	EnumerationsMetadata = Undefined; //EnumerationMetadataObject
	EnumerationsValue = Undefined; //EnumerationReferenceNameEnumerations
	
	If Parameters.Property("EnumerationsType") Then
		//@skip-check unknown-form-parameter-access
		EnumerationsType = Parameters.EnumerationsType;
		
		If UT_Common.IsEnumbyType(EnumerationsType) Then
			EmptyRef = UT_Common.NewValueByType(EnumerationsType);
			EnumerationsMetadata = EmptyRef.Metadata();
		EndIf;
		
	ElsIf Parameters.Property("EnumerationsValue") Then
		//@skip-check unknown-form-parameter-access
		EnumerationsValue = Parameters.EnumerationsValue;
		If EnumerationsValue <> Undefined Then
			EnumerationsMetadata = EnumerationsValue.Metadata();
		EndIf;
	EndIf;
		
	If EnumerationsMetadata = Undefined Then
		Cancel = True;
		UT_CommonClientServer.MessageToUser(NStr("ru = 'Не удалось открыть выбор перечисления'; en = 'Failed to open enumeration selection'"));
		Return;
	EndIf;
	
	If Not UT_Common.IsEnumbyType(EnumerationsMetadata) Then
		Cancel = True;
		UT_CommonClientServer.MessageToUser(NStr("ru = 'Нельзя выбирать значения перечисления для других типов'; en = 'Cannot select enum values ​​for other types|'"));
		Return;
	EndIf;
	
	Title = EnumerationsMetadata.FullName();
	
	EnumerationManager = Перечисления[EnumerationsMetadata.Name];
	
	EmptyRef = EnumerationManager.EmptyRef();

	For Each EnumerationsItem In EnumerationsMetadata.EnumerationValues Do
		NewRow = EnumerationValues.Add();
		NewRow.Ref = EnumerationManager[EnumerationsItem.Name];
		NewRow.Name = EnumerationsItem.Name;
		NewRow.Presentation = EnumerationsItem.Синоним;
		NewRow.ValueString = "Enums." + EnumerationsMetadata.Name + "." + EnumerationsItem.Name;
	EndDo;

	If EnumerationsValue <> Undefined Then
		FoundRows = EnumerationValues.FindRows(New Structure("Ref", EnumerationsValue));
		If FoundRows.Count() > 0 Then
			Items.EnumerationValues.CurrentRow = FoundRows[0].GetID();
		EndIf;
	EndIf;
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersEnumerationValues

&AtClient
Procedure ValuesEnumerationsSelection(Item, ChosenRow, Field, StandardProcessing)
	SelectionValuesFinish();
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure ChooseValue(Command)
	
	SelectionValuesFinish();
	
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure SelectionValuesFinish()
	
	CurrentData = Items.EnumerationValues.CurrentData;
	If CurrentData <> Undefined Then
		ChosenValue = CurrentData.Ref;
	Else     
		ChosenValue = EmptyRef;
	EndIf;
	
	If FormOwner <> Undefined Then
		NotifyChoice(ChosenValue);
	Else
		Close(ChosenValue);
	EndIf;
EndProcedure

#EndRegion



