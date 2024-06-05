//Sign of using settings
&AtClient
Var mUseSettings Export;

//Types of objects for which processing can be used.
//To default for everyone.
&AtClient
Var mTypesOfProcessedObjects Export;

&AtClient
Var mSetting;

&AtServer
Var FoundObjectsValueTable;

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
	//RowTP=
	//
	ProcessedObject = Reference.GetObject();
	If ProcessTabularParts Then
		RowTP=ProcessedObject[FoundObjects[SequenceNumberObject].T_TP][FoundObjects[SequenceNumberObject].T_LineNumber
			- 1];
	EndIf;

	For Each Attribute In Attributes Do
		If Attribute.Choose Then
			If Attribute.AttributeTP Then
				RowTP[Attribute.Attribute] = Attribute.Value;
			Else
				ProcessedObject[Attribute.Attribute] = Attribute.Value;
			EndIf;
		EndIf;
	EndDo;

//		ProcessedObject.Write();
	If UT_Common.WriteObjectToDB(ProcessedObject, ParametersWriteObjects) Then
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Объект %1 УСПЕХ!!!';en = 'Object %1 SUCCESS!!!'"), ProcessedObject));
	EndIf;

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

		RowFoundObjects = FoundObjects.Get(IndexOf);

		If RowFoundObjects.Choose Then//

			ProcessObject(RowFoundObjects.Object, IndexOf, ParametersWriteObjects);
		EndIf;
	EndDo;

	If IndexOf > 0 Then
		//NotifyChanged(Type(SearchObject.Type + "Reference." + SearchObject.Name));
	EndIf;

	Return IndexOf;
EndFunction // ExecuteProcessing()

// Saves the values ​​of form details.
//
// Parameters:
//  None.
//
&AtClient
Procedure SaveSettings() Export

	If IsBlankString(CurrentSettingRepresentation) Then
		ShowMessageBox( ,
			NStr("ru = 'Задайте имя новой настройки для сохранения или выберите существующую настройку для перезаписи.'; en = 'Specify a name for the new setting to save, or select an existing setting to overwrite.'"));
	EndIf;

	NewSetting = New Structure;
	NewSetting.Insert("Processing", CurrentSettingRepresentation);
	NewSetting.Insert("Прочее", New Structure);
	
	//@skip-warning
	AttributesForSaving = GetArrayOfAttributes();

	For Each SettingAttribute In mSetting Do
		Execute ("NewSetting.Прочее.Insert(String(SettingAttribute.Key), " + String(SettingAttribute.Key)
			+ ");");
	EndDo;

	AvailableDataProcessors = ThisForm.FormOwner.AvailableDataProcessors;
	CurrentAvailableSetting = Undefined;
	For Each CurrentAvailableSetting In AvailableDataProcessors.GetItems() Do
		If CurrentAvailableSetting.GetID() = Parent Then
			Break;
		EndIf;
	EndDo;

	If CurrentSetting = Undefined Or Not CurrentSetting.Processing = CurrentSettingRepresentation Then
		If CurrentAvailableSetting <> Undefined Then
			NewRow = CurrentAvailableSetting.GetItems().Add();
			NewRow.Processing = CurrentSettingRepresentation;
			NewRow.Setting.Add(NewSetting);

			ThisForm.FormOwner.Items.AvailableDataProcessors.CurrentRow = NewRow.GetID();
		EndIf;
	EndIf;

	If CurrentAvailableSetting <> Undefined И CurrentLine > -1 Then
		For Each CurrentSetting Из CurrentAvailableSetting.GetItems() Do
			If CurrentSetting.GetID() = CurrentLine Then
				Break;
			EndIf;
		EndDo;

		If CurrentSetting.Setting.Count() = 0 Then
			CurrentSetting.Setting.Add(NewSetting);
		Else
			CurrentSetting.Setting[0].Value = NewSetting;
		EndIf;
	EndIf;

	CurrentSetting = NewSetting;
	ThisForm.Modified = False;
EndProcedure // SaveSettings()

&AtServer
Function GetArrayOfAttributes()
	ArrayAttributes = New Array;
	For Each Row In Attributes Do
		If Not Row.Choose Then
			Continue;
		EndIf;

		StructureAttribute = New Structure;
		StructureAttribute.Insert("Choose", Row.Choose);
		StructureAttribute.Insert("Attribute", Row.Attribute);
		StructureAttribute.Insert("ID", Row.ID);
		StructureAttribute.Insert("Type", Row.Type);
		StructureAttribute.Insert("Value", Row.Value);

		ArrayAttributes.Add(StructureAttribute);
	EndDo;

	Return ArrayAttributes;
EndFunction

&AtServer
Procedure LoadAttributesFromArray(ArrayAttributes)
	TableAttributes = FormAttributeToValue("Attributes");
	
	//Clean up existing installations before installation
	For Each RowAttribute In TableAttributes Do
		RowAttribute.Choose = False;
		RowAttribute.Value = RowAttribute.Type.AdjustValue();
	EndDo;

	For Each Row In ArrayAttributes Do
		If Not Row.Choose Then
			Continue;
		EndIf;

		SearchStructure = New Structure;
		SearchStructure.Insert("Attribute", Row.Attribute);

		ArrayString = TableAttributes.FindRows(SearchStructure);
		If ArrayString.Count() = 0 Then
			Continue;
		EndIf;

		ТекСтр = ArrayString[0];
		FillPropertyValues(ТекСтр, Row);
	EndDo;

	ValueToFormAttribute(TableAttributes, "Attributes");
EndProcedure

// Restores saved form attribute values.
//
// Parameters:
//  None.
//
&AtClient
Procedure DownloadSettings() Export

	If Items.CurrentSetting.ChoiceList.Count() = 0 Then
		UT_FormsClient.SetNameSettings(ThisForm, Nstr("ru = 'Новая настройка';en = 'New setting'"));
	Else
		If Not CurrentSetting.Other = Undefined Then
			mSetting = CurrentSetting.Other;
		EndIf;
	EndIf;

	AttributesForSaving = Undefined;

	For Each AttributeSetting In mSetting Do
		//@skip-warning
		Value = mSetting[AttributeSetting.Key];
		Execute (String(AttributeSetting.Key) + " = Value;");
	EndDo;

	If AttributesForSaving <> Undefined And AttributesForSaving.Count() Then
		LoadAttributesFromArray(AttributesForSaving);
	EndIf;

EndProcedure //DownloadSettings()

// Sets the value of the attribute "CurrentSetting" by setting name or randomly.
//
// Parameters:
//  SettingName   - arbitrary name of the setting that needs to be set.
//
&AtClient
Procedure SetSettingName(SettingName = "") Export

	If IsBlankString(SettingName) Then
		If CurrentSetting = Undefined Then
			CurrentSettingRepresentation = "";
		Else
			CurrentSettingRepresentation = CurrentSetting.Processing;
		EndIf;
	Else
		CurrentSettingRepresentation = SettingName;
	EndIf;

EndProcedure // SetSettingName()

// Gets a structure to indicate loop progress.
//
// Parameters:
//  NumberOfPasses - Number - maximum counter value;
//  ProcessPresentation - String, "Done" - process display name;
//  InternalCounter - Boolean, *True - use internal counter with initial value 1,
//                    otherwise you will need to pass the counter value every time you call the indicator update;
//  NumberOfUpdates - Number, *100 - total number of indicator updates;
//  liShowTime - Boolean, *True - display the approximate time until the end of the process;
//  AllowInterrupt - Boolean, *True - allows the user to interrupt the process.
//
// Return values:
//  Structure - which will then need to be passed to the method ProcessIndicator.
//
&AtClient
Function GetProcessIndicator(NumberOfPasses, ProcessPresentation = "Done", InternalCounter = True,
	NumberOfUpdates = 100, liShowTime = True, AllowInterrupt = True) Export

	Indicator = New Structure;
	Indicator.Insert("NumberOfPasses", NumberOfPasses);
	Indicator.Insert("ProcessStartDate", CurrentDate());
	Indicator.Insert("ProcessPresentation", ProcessPresentation);
	Indicator.Insert("liShowTime", liShowTime);
	Indicator.Insert("AllowInterrupt", AllowInterrupt);
	Indicator.Insert("InternalCounter", InternalCounter);
	Indicator.Insert("Step", NumberOfPasses / NumberOfUpdates);
	Indicator.Insert("NextCounter", 0);
	Indicator.Insert("Counter", 0);
	Return Indicator;

EndFunction // GetProcessIndicator()

// Checks and updates the indicator. Must be called on each pass of the displayed loop.
//
// Parameters:
//  Indicator   - Structure - indicator obtained by the method GetProcessIndicator;
//  Counter     - Number - external loop counter, used when InternalCounter = False.
//
&AtClient
Procedure ProcessIndicator(Indicator, Counter = 0) Export

	If Indicator.InternalCounter Then
		Indicator.Counter = Indicator.Counter + 1;
		Counter = Indicator.Counter;
	EndIf;
	If Indicator.AllowInterrupt Then
		UserInterruptProcessing();
	EndIf;

	If Counter > Indicator.NextCounter Then
		Indicator.NextCounter = Int(Counter + Indicator.Step);
		If Indicator.liShowTime Then
			PassedTime = CurrentDate() - Indicator.ProcessStartDate;
			Balance = PassedTime * (Indicator.NumberOfPasses / Counter - 1);
			Hours = Int(Balance / 3600);
			Balance = Balance - (Hours * 3600);
			Minutes = Int(Balance / 60);
			Seconds = Int(Int(Balance - (Minutes * 60)));
			TimeBalance = Format(Hours, "ND=2; NZ=00; NLZ=") + ":" + Format(Minutes, "ND=2; NZ=00; NLZ=") + ":"
				+ Format(Seconds, "ND=2; NZ=00; NLZ=");
			BalanceText = NStr("ru = 'Осталось: ~'; en = 'Balance: ~'") + TimeBalance;
		Else
			BalanceText = "";
		EndIf;

		If Indicator.NumberOfPasses > 0 Then
			StatusText = BalanceText;
		Else
			StatusText = "";
		EndIf;

		Status(Indicator.ProcessPresentation, Counter / Indicator.NumberOfPasses * 100, StatusText);
	EndIf;

	If Counter = Indicator.NumberOfPasses Then
		Status(Indicator.ProcessPresentation, 100, StatusText);
	EndIf;

EndProcedure // ProcessIndicator()

// Allows you to create type descriptions based on the string representation of the type.
//
// Parameters: 
//  StringAsType - String - String representation of type.
//
// Return values:
//  Type description.
//
&AtServer
Function TypeDescription(StringAsType) Export

	TypesArray = New Array;
	TypesArray.Add(Type(StringAsType));
	TypeDescription = New TypeDescription(TypesArray);

	Return TypeDescription;

EndFunction // TypeDescription()

////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS

&AtClient
Procedure OnOpen(Cancel)
	If mUseSettings Then
		UT_FormsClient.SetNameSettings(ThisForm);
		DownloadSettings();
	Else
		Items.CurrentSetting.Enabled = False;
		Items.SaveSettings.Enabled = False;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Setting") Then
		CurrentSetting = Parameters.Setting;
	EndIf;
	If Parameters.Property("FoundObjectsTP") Then
		
		FoundObjectsValueTable = Parameters.FoundObjectsTP.Unload();
		
		FoundObjects.Load(FoundObjectsValueTable);
	EndIf;
	CurrentLine = -1;
	If Parameters.Property("CurrentLine") Then
		If Parameters.CurrentLine <> Undefined Then
			CurrentLine = Parameters.CurrentLine;
		EndIf;
	EndIf;
	If Parameters.Property("Parent") Then
		Parent = Parameters.Parent;
	EndIf;

	Items.CurrentSetting.ChoiceList.Clear();
	If Parameters.Property("Settingы") Then
		For Each Row In Parameters.Settingы Do
			Items.CurrentSetting.ChoiceList.Add(Row, Row.Processing);
		EndDo;
	EndIf;
	If Parameters.Property("ProcessTabularParts") Then
		ProcessTabularParts = Parameters.ProcessTabularParts;
	EndIf;
	If Parameters.Property("TableAttributes") Then
		TabAttributes = Parameters.TableAttributes;
		TabAttributes.Sort("ThisTP");
		For Each Attribute In TabAttributes Do
			NewRow = Attributes.Add();
			NewRow.Attribute      	= Attribute.Name;//?(IsBlankString(Attribute.Synonym), Attribute.Name, Attribute.Synonym);
			NewRow.ID 				= Attribute.Presentation;
			NewRow.Type           	= Attribute.Type;
			NewRow.Value      		= NewRow.Type.AdjustValue();
			NewRow.AttributeTP		= Attribute.ThisTP;
		EndDo;

	EndIf;	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS CALLED FROM FORM ELEMENTS

&AtClient
Procedure ExecuteCommand(Command)
	ProcessedObjects = ExecuteProcessing(UT_CommonClientServer.FormWriteSettings(
		ThisObject.FormOwner));

	ShowMessageBox( , Nstr("ru = 'Обработка <'; en = 'Processing <'") + TrimAll(ThisForm.Title) + NStr("ru = '> завершена!'; en = '> completed!'")
		+ Chars.LF + NStr("ru = 'Обработано объектов:'; en = 'Objects processed:'") + " " + ProcessedObjects
		+ ".");
EndProcedure

&AtClient
Procedure SaveSettingsCommand(Command)
	SaveSettings();
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
		SaveSettings();
	EndIf;

	CurrentSettingChoiceProcessingFragment(SelectedValue);

EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessingFragment(Val SelectedValue)

	CurrentSetting = SelectedValue;
	UT_FormsClient.SetNameSettings(ThisForm);

	DownloadSettings();

EndProcedure

&AtClient
Procedure CurrentSettingOnChange(Item)
	ThisForm.Modified = True;
EndProcedure

&AtClient
Procedure CooseAll(Command)
	SelectItems(True);
EndProcedure

&AtClient
Procedure CancelChoice(Command)
	SelectItems(False);
EndProcedure

&AtServer
Procedure SelectItems(Selection)
	For Each Row In Attributes Do
		Row.Choose = Selection;
	EndDo;
EndProcedure

&AtClient
Procedure AttributesValueClearing(Item, StandardProcessing)
	Items.AttributesValue.ChooseType = True;
EndProcedure

&AtClient
Procedure AttributesValueOnChange(Item)
	Items.Attributes.CurrentData.Choose = True;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// INITIALIZING MODULAR VARIABLES

mUseSettings = True;

//Attributes settings and defaults.
mSetting = New Structure("AttributesForSaving");

//mSetting.<Name attribute> = <Value attribute>;

mTypesOfProcessedObjects = "Catalog,Document";