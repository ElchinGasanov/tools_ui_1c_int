#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	StorageValue = Undefined;
	If Parameters.Property("ValueStorageContainer") Then
		ReturningStorageForValueContainer = False;
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueStorageContainer;//look at UT_CommonClientServer.NewValueStorageValueStorageType
		If ContainerStorage <> Undefined Then
			StorageForValue = UT_Common.ValueFromValueStorageContainerStorage(ContainerStorage); // ValueStorage
			//@skip-check empty-except-statement
			Try
				StorageValue = StorageForValue.Get();
			Except
			EndTry;
		EndIf;
	ElsIf Parameters.Property("ValueStorage") Then 
		//@skip-check unknown-form-parameter-access
		StorageForValue = Parameters.ValueStorage;
			//@skip-check empty-except-statement
		Try
			StorageValue = StorageForValue.Get();
		Except
		EndTry;
	EndIf;

	StorageFieldStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");

	UT_CommonClientServer.SetContainerFieldValue(ThisObject,
												StorageFieldStructure,
												StorageValue);
EndProcedure



#EndRegion

#Region FormHeaderItemsEventHandlers


&AtClient
Procedure ValueStartСhoice(Item, ChosenData, StandardProcessing)
	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.Value = Value;
	HandlerParameters.StructureValueStorage = ThisObject;
	HandlerParameters.TypesSet = UT_CommonClientServer.AllEditingTypeSets();

	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure ValueСlearing(Item, StandardProcessing)
	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.StructureValueStorage = ThisObject;

	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);

EndProcedure


&AtClient
Procedure ValueOnChange(Item)
	HandlerParameters = UT_CommonClient.NewProcessorInChangingEventsParameters(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.StructureValueStorage = ThisObject;

	UT_CommonClient.FormFieldInChangeProcessor(HandlerParameters);
EndProcedure


#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure Apply(Command)
	If ReturningStorageForValueContainer Then
		ReturnValue = StorageContainerFromValuesForm();
	Else
		ReturnValue = StorageValuesFromFormValue();
	EndIf;
	Close(ReturnValue);
EndProcedure
#EndRegion

#Region Private

&AtServer
Function StorageContainerFromValuesForm()
	StorageFieldStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	ValueFromContainer = UT_CommonClientServer.ValueContainerFieldValue(ThisObject,
																		StorageFieldStructure);

	Return UT_Common.ValueStorageContainerStorageArbitraryValue(ValueFromContainer);
EndFunction

&AtServer
Function StorageValuesFromFormValue()
	StorageFieldStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	ValueFromContainer = UT_CommonClientServer.ValueContainerFieldValue(ThisObject,
																		StorageFieldStructure);
	Return New ValueStorage(ValueFromContainer, New Deflation(9));
EndFunction

#EndRegion
