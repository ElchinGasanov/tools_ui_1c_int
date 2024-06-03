
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	ItemListReceived = FormAttributeToValue("Object").Container_RestoreValue(Parameters.Value);
	ContainerType = Parameters.ContainerType;
	
	If ContainerType = 2 Then
		Title = Parameters.Title + NStr("ru = ' (массив)'; en = ' (array)'");
		ItemList.LoadValues(ItemListReceived);
	Else
		Title = Parameters.Title + NStr("ru = ' (список значений)'; en = ' (value list)'");
		ItemList = ItemListReceived;
	EndIf;
	
	ItemList.ValueType = Parameters.ValueType;
	
	arNoPickupTypes = New Array;
	arNoPickupTypes.Add(Type("Number"));
	arNoPickupTypes.Add(Type("String"));
	arNoPickupTypes.Add(Type("Date"));
	arNoPickupTypes.Add(Type("Undefined"));
	arNoPickupTypes.Add(Type("Type"));
	arNoPickupTypes.Add(Type("AccumulationRecordType"));
	arNoPickupTypes.Add(Type("AccountingRecordType"));
	arNoPickupTypes.Add(Type("AccountType"));
	arNoPickupTypes.Add(Type("UUID"));
	arNoPickupTypes.Add(Type("NULL"));
	NoPickupTypes = New TypeDescription(arNoPickupTypes);
	
	arTypes = Parameters.ValueType.Types();
	Items.ItemListPickup.Visible = True;
	For Each Type In arTypes Do
		If NoPickupTypes.ContainsType(Type) Then
			Items.ItemListPickup.Visible = False;
			Break;
		EndIf;
	EndDo;
	
EndProcedure

&AtClient
Function FullFormName(FormName)
	Return StrTemplate("%1.Form.%2", Object.MetadataPath, FormName);
EndFunction

&AtClient
Procedure CommandFillFromClipboard(Command)
	If Not ItemList.ValueType.ContainsType(Type("String")) Then
		Return;
	EndIf;

	UT_ClipboardClient.BeginGettingTextFormClipboard(New CallbackDescription("CommandFillFromClipboardFinish",
		ThisObject));
EndProcedure

&AtClient
Procedure CommandFillFromClipboardFinish(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(Result) Then
		Return;
	EndIf;

	TextDocument = New TextDocument();
	TextDocument.SetText(Result);
	LineCount = TextDocument.LineCount();
	For i = 1 To LineCount Do
		TextLine = TextDocument.GetLine(i);
		ItemList.Add(TextLine);
	EndDo;

EndProcedure

&AtClient
Procedure CommandFillFromFile(Command)

	Mode = FileDialogMode.Open;
	OpenFileDialog = New FileDialog(Mode);
	OpenFileDialog.FullFileName = "";
	Filter = НСтр("ru = 'Текст'; en = 'Text'") + "(*.txt)|*.txt";
	OpenFileDialog.Filter = Filter;
	OpenFileDialog.Multiselect = True;
	OpenFileDialog.Title = NStr("ru = 'Выберите файлы'; en = 'Choose files'");

	CallbackDescription = New CallbackDescription("ChooseFileFinish", ThisObject);

	OpenFileDialog.Show(CallbackDescription);
	
EndProcedure

&AtClient
Procedure CommandTransferToStringInternal(Command)

	Mode = FileDialogMode.Save;
	OpenFileDialog = New FileDialog(Mode);
	OpenFileDialog.FullFileName = ""; Filter = НСтр("ru = 'Текст'; en = 'Text'") + "(*.txt)|*.txt"; OpenFileDialog.Filter = Filter; // bugfix 31.05.2024
	OpenFileDialog.Title = NStr("ru = 'Сохранить файл'; en = 'Save file'");
	AdditionalParameters = Новый Структура("FileAddress", GetFileListValuesInRowInternal());
	CallbackDescription = New CallbackDescription("SavingFileFinish", 
												  ThisObject,
												  AdditionalParameters);

	OpenFileDialog.Show(CallbackDescription);
EndProcedure

&AtClient
Procedure SavingFileFinish(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	BinaryData = GetFromTempStorage(AdditionalParameters.FileAddress);
	BinaryData.Write(Result[0]);

EndProcedure

&AtClient
Procedure CommandFillFromStringInternal(Command)

	Mode = FileDialogMode.Open;
	OpenFileDialog = New FileDialog(Mode);
	OpenFileDialog.FullFileName = "";
	OpenFileDialog.Multiselect = Ложь;
	OpenFileDialog.Title = NStr("ru = 'Выберите файлы'; en = 'Choose files'");


	CallbackDescription = New CallbackDescription("CommandFillFromLineIntFinish", 
												  ThisObject);

	OpenFileDialog.Show(CallbackDescription);
EndProcedure

&AtClient
Procedure CommandFillFromLineIntFinish(ChosenFiles, AdditionalParameters) Export
	If ChosenFiles = Undefined Then
		Return;
	EndIf;
	BinaryData = New BinaryData(ChosenFiles[0]);

	StorageAddress = PutToTempStorage(BinaryData, UUID);
	FillStringsInternalListAtServer(StorageAddress);

EndProcedure
&AtServer
Procedure FillStringsInternalListAtServer(StorageAddress)
	VTRowInternal = GetStringFromBinaryData(GetFromTempStorage(StorageAddress));
	VList = ValueFromStringInternal(VTRowInternal);
	If TypeOf(VList) = Type("ValueList") Then
		ItemList = VList;
	EndIf;
EndProcedure
&AtServer
Function GetFileListValuesInRowInternal()
	Return PutToTempStorage(GetBinaryDataFromString(ValueToStringInternal(ItemList)),
										  UUID);	
EndFunction

&AtClient
Procedure ChooseFileFinish(ChosenFiles, AdditionalParameters) Export
	If ChosenFiles = Undefined Then
		Return;
	EndIf;
	BinaryDataArray = New Array();
	If TypeOf(ChosenFiles) = Type("Array") Then
		For Each CurrenRow In ChosenFiles Do
			BinaryData = New BinaryData(CurrenRow);
			BinaryDataArray.Add(BinaryData);
		EndDo;
		StorageAddress = PutToTempStorage(BinaryDataArray, UUID);
		FillFilesListAtServer(StorageAddress);
	EndIf;

EndProcedure
&AtServer
Procedure FillFilesListAtServer(StorageAddress)
	FileArray = GetFromTempStorage(StorageAddress);
	For Each CurrentFile In FileArray Do
		FileName = GetTempFileName("txt");
		CurrentFile.Write(FileName);

		TextDocument = New TextDocument();
		TextDocument.Read(FileName);
		LineCount = TextDocument.LineCount();
		For i = 1 To LineCount Do
			TextLine = TextDocument.GetLine(i);
			ItemList.Add(TextLine);
		EndDo;

		DeleteFiles(FileName);
	EndDo;
EndProcedure

&AtClient
Procedure CommandTransferToClipboard(Command)

		UT_ClipboardClient.BeginCopyTextToClipboard(GenerateTextForCopying(),
			New CallbackDescription("CommandTransferToClipboardFinish", ThisObject));
EndProcedure

&AtServer
Function GenerateTextForCopying()

	TextDocument = New TextDocument();
	For Each CurrenRow In ItemList Do
		TextDocument.AddLine(TrimAll(CurrenRow));
	EndDo;	

	Return TextDocument.GetText();
EndFunction

&AtClient
Procedure CommandTransferToClipboardFinish(Result, CallOptions, AdditionalParameters) Export
	If Result = True Then
		Status(NStr("ru = 'Скопировано в буфер обмена'; en = 'Copied to clipboard'"));
	EndIf;
EndProcedure

&AtServer
Function GetReturnValue()
	
	If ContainerType = 2 Then
		Return FormAttributeToValue("Object").Container_SaveValue(ItemList.UnloadValues());
	EndIf;
	
	Return FormAttributeToValue("Object").Container_SaveValue(ItemList);
	
EndFunction

&AtClient
Procedure OKCommand(Command)

	ReturnValue = New Structure("Value", GetReturnValue());
	
	Close(ReturnValue);
	
EndProcedure

&AtClient
Procedure ClearCommand(Command)
	ItemList.Clear();
EndProcedure

&AtClient
Procedure EditValue()
	
	Value = Items.ItemList.CurrentData.Value;
	If TypeOf(Value) = Type("Type") Then

		NotifyParameters = New Structure("Row", Items.ItemList.CurrentRow);
		//@skip-warning
		CloseFormNotifyDescription = New NotifyDescription("TypeEditFinish", ThisForm, NotifyParameters);
		
		If TypeOf(Value) <> Type("Type") Then
			Value = Type("Undefined");
		EndIf;
		
		OpeningParameters = New Structure("Object, ValueType", Object, Value);
		OpenForm(FullFormName("TypeEdit"), OpeningParameters, ThisForm, True, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
		
	ElsIf TypeOf(Value) = Type("UUID") Then

		NotifyParameters = New Structure("Row", Items.ItemList.CurrentRow);
		//@skip-warning
		CloseFormNotifyDescription = New NotifyDescription("TypeEditFinish", ThisForm, NotifyParameters);
		
		OpeningParameters = New Structure("Object, Value", Object, Value);
		OpenForm(FullFormName("UUIDEdit"), OpeningParameters, ThisForm, True, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
		
	EndIf;
	
EndProcedure

&AtClient
Procedure ItemListValueStartChoice(Item, ChoiceData, StandardProcessing)
	
	Value = Items.ItemList.CurrentData.Value;
	
	EditingValueType = TypeOf(Value);
	
	If EditingValueType = Type("Type") Or EditingValueType = Type("UUID") Then
		EditValue();
		StandardProcessing = False;
	EndIf;
	
EndProcedure

&AtClient
Procedure ItemListValueChoiceProcessing(Item, ValueSelected, StandardProcessing)
	
	If ValueSelected = Type("Type") Then
		ItemList.FindByID(Items.ItemList.CurrentRow).Value = Type("Undefined");
		EditValue();
	ElsIf ValueSelected = Type("UUID") Then
		ItemList.FindByID(Items.ItemList.CurrentRow).Value = New UUID;
		EditValue();
	EndIf;
	
EndProcedure

Procedure TypeEditFinish(Result, NotifyParameters) Export
	Var Value;
	
	If Result <> Undefined Then
		
		If Result.Property("Value", Value) Then
			
			ItemList.FindByID(NotifyParameters.Row).Value = Value;
			
		Else
		
			ItemList.FindByID(NotifyParameters.Row).Value = Type(Result.ContainerDescription.TypeName);
			
		EndIf;
		
	EndIf;
	
EndProcedure

