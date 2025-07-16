

#Region Variables

#EndRegion

#Region FormEventHandlers

// Code of procedures and functions


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	BinaryData = Undefined;
	If Parameters.Property("ValueStorageContainer") Then
		ReturningStorageForValueContainer = True;
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueStorageContainer;//см. УИ_ОбщегоНазначенияКлиентСервер.НовыйХранилищеЗначенияTypeаДвоичныеДанные
		
		If ContainerStorage <> Undefined Then
			BinaryData = UT_Common.ValueFromBinaryDataContainerStorage(ContainerStorage);
		EndIf;
	EndIf;
	
	If BinaryData <> Undefined Then
		BinaryDataAdress = PutToTempStorage(BinaryData, UUID);
	EndIf;
	
	FillAuxiliaryDataByBinaryData(BinaryData);
EndProcedure



#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure Apply(Command)
	Close(ReturnValue());
EndProcedure


&AtClient
Procedure LoadFromFile(Command)
	FileReadingParameters = UT_CommonClient.NewFileReadingParameters(UUID);
	FileReadingParameters.EndingCallbackDescription = New CallbackDescription("LoadFromFileFinishPutingInTempStorage",
		ThisObject);
	
	FileDialog = New FileDialog(FileDialogMode.Open);
	FileDialog.Title = NStr("ru = 'Выбор файла'; en = 'Chose file'");
	FileDialog.Multiselect = False;
	FileDialog.CheckFileExistence = True;
	FileReadingParameters.FileDialog = FileDialog;

	UT_CommonClient.BeginFileReading(FileReadingParameters);
EndProcedure

&AtClient
Procedure SaveToFile(Command)
	SaveParameters = UT_CommonClient.NewFileSavingParameters();
	SaveParameters.TempStorageFileDirectory = BinaryDataAdress;
	
	FileDialog = New FileDialog(FileDialogMode.Save);
	FileDialog.Title = NStr("ru = 'Сохранение файла'; en = 'Save file'");
	FileDialog.Multiselect = False;
	SaveParameters.FileDialog = FileDialog;
	
	UT_CommonClient.BeginFileSaving(SaveParameters);
EndProcedure

#EndRegion

#Region Private

&AtServer
Function ReturnValue()
	BinaryData = Undefined;
	If IsTempStorageURL(BinaryDataAdress) Then
		BinaryData = GetFromTempStorage(BinaryDataAdress);
	EndIf;

	Return UT_Common.ValueStorageContainerBinaryData(BinaryData);
EndFunction

&AtClient
Procedure LoadFromFileFinishPutingInTempStorage(FileArray, ExtraParameters) Export
	If FileArray = Undefined Then
		Return;
	EndIf;
	If FileArray.Count() = 0 Then
		Return;
	EndIf;
	
	SetFormDataByReadFile(FileArray[0]);
EndProcedure

&AtServer
Procedure SetFormDataByReadFile(ReadFile)
	BinaryDataAdress = ReadFile.Location;
	
	BinaryData = GetFromTempStorage(BinaryDataAdress);
	FillAuxiliaryDataByBinaryData(BinaryData);
EndProcedure

// Fill auxiliary data on binary data.
// 
// Параметры:
//  BinaryData - Undefined, BinaryData -  Binary data
&AtServer
Procedure FillAuxiliaryDataByBinaryData(BinaryData)
	Presentation = BinaryData;
	If TypeOf(BinaryData) = Type("BinaryData") Then
		Size = BinaryData.Size();
	Else
		Size = 0;
	EndIf;	
EndProcedure

#EndRegion
