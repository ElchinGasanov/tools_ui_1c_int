//Sign of using settings
&AtClient
Var mUseSettings Export;

//Types of objects for which processing can be used.
//To default for everyone.
&AtClient
Var mTypesOfProcessedObjects Export;

&AtClient
Var mSetting;

////////////////////////////////////////////////////////////////////////////////
// AUXILIARY PROCEDURES AND FUNCTIONS

// Performs object processing.
//
// Parameters:
//  ProcessedObject                 - processed object.
//  SequenceNumberObject - serial number of the processed object.
//
&AtServer
Procedure ProcessObject(Reference, SequenceNumberObject, ParametersWriteObjects)

	ProcessedObject = Reference.GetObject();
	If UT_Common.WriteObjectToDB(ProcessedObject, ParametersWriteObjects, "SetDeletionMark") Then
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Объект %1 УСПЕХ!!!';en = 'Object %1 SUCCESS!!!'"), ProcessedObject));
	EndIf;
//	ProcessedObject.SetDeletionMark(DeletionMark);

EndProcedure // ProcessObject()

// Performs object processing.
//
// Parameters:
//  None.
//
&AtClient
Function ExecuteProcessing(ParametersWriteObjects) Export

	Indicator = UT_FormsClient.GetProcessIndicator(FoundObjects.Count());
	For IndexOf = 0 To FoundObjects.Count() - 1 Do
		UT_FormsClient.ProcessIndicator(Indicator, IndexOf + 1);

		RowFoundObjectValue = FoundObjects.Get(IndexOf).Value;
		ProcessObject(RowFoundObjectValue, IndexOf, ParametersWriteObjects);
	EndDo;

	If IndexOf > 0 Then
		//NotifyChanged(Type(SearchObject.Type + "Reference." + SearchObject.Name));
	EndIf;

	Return IndexOf;
EndFunction // ExecuteProcessing()

////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS

&AtClient
Procedure OnOpen(Cancel)
	If mUseSettings Then
		UT_FormsClient.SetNameSettings(ThisForm);
		UT_FormsClient.DownloadSettings(ThisForm, mSetting);
	Else
		Items.CurrentSetting.Enabled = False;
		Items.SaveSettings.Enabled = False;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	UT_FormsServer.FillSettingByParametersForm(ThisForm);

	DeletionMark=True;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS CALLED FROM FORM ELEMENTS

&AtClient
Procedure ExecuteCommand(Command)
	ProcessedObjects = ExecuteProcessing(UT_CommonClientServer.FormWriteSettings(
		ThisObject.FormOwner));

	Message = StrTemplate(Nstr("ru = 'Обработка <%1> завершена! 
					 |Обработано объектов: %2.';en = 'Processing of <%1> completed!
					 |Objects processed: %2.'"), TrimAll(ThisForm.Title), ProcessedObjects);
	ShowMessageBox(, Message);
EndProcedure

&AtClient
Procedure SaveSettings(Command)
	UT_FormsClient.SaveSetting(ThisForm, mSetting);
EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessing(Item, SelectedValue, StandardProcessing)
	StandardProcessing = False;

	If Not CurrentSetting = SelectedValue Then

		If ThisForm.Modified Then
			ShowQueryBox(New NotifyDescription("CurrentSettingChoiceProcessingEnd", ThisForm,
				New Structure("SelectedValue", SelectedValue)), Nstr("ru = 'Сохранить текущую настройку?';en = 'Save current setting?'"),
				QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
			Return;
		EndIf;

		CurrentSettingChoiceProcessingFragment(SelectedValue);

	EndIf;
EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessingEnd(ResultQuestion, AdditionalParameters) Export

	SelectedValue = AdditionalParameters.SelectedValue;
	If ResultQuestion = DialogReturnCode.Yes Then
		UT_FormsClient.SaveSetting(ThisForm, mSetting);
	EndIf;

	CurrentSettingChoiceProcessingFragment(SelectedValue);

EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessingFragment(Val SelectedValue)

	CurrentSetting = SelectedValue;
	UT_FormsClient.SetNameSettings(ThisForm);

	UT_FormsClient.DownloadSettings(ThisForm, mSetting);

EndProcedure

&AtClient
Procedure CurrentSettingOnChange(Item)
	ThisForm.Modified = True;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// INITIALIZING MODULAR VARIABLES

mUseSettings = False;

//Attributes settings and defaults.
mSetting = New Structure("");

//mSetting.<Name attribute> = <Value attribute>;

mTypesOfProcessedObjects = "Catalog,Document";