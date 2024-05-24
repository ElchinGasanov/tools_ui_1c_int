
#Region FormEventHandlers


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Picture = New Picture;
	If Parameters.Property("ValueStorageContainer") Then
		ReturningStorageForValueContainer = True;
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueStorageContainer;//см. УИ_ОбщегоНазначенияКлиентСервер.НовыйХранилищеЗначенияТипаКартинка
		
		If ContainerStorage <> Undefined Then
			Picture = UT_CommonClientServer.ValueFromPictureStorageContainer(ContainerStorage);
		EndIf;
	ElsIf Parameters.Property("Picture") Then 
		//@skip-check unknown-form-parameter-access
		Picture = Parameters.Picture;
	EndIf;
	PlacePictureInTemporaryStorage(Picture);	
	SetPictureParametersOnForm(Picture);
EndProcedure



#EndRegion

#Region FormHeaderItemsEventHandlers

// Code of procedures and functions

#EndRegion

#Region FormCommandsEventHandlers


&AtClient
Procedure Apply(Command)
	Picture = PictureFromTempStorage();
	
	If ReturningStorageForValueContainer Then
		ReturnValue = UT_CommonClientServer.ValueOfThePictureStorageContainer(Picture);
	Else
		ReturnValue = Picture;
	EndIf;
	
	Close(ReturnValue);
EndProcedure

&AtClient
Procedure Clear(Command)
	Picture = New Picture();
	PlacePictureInTemporaryStorage(Picture);
	SetPictureParametersOnForm(Picture);
	RefreshDataRepresentation(Items.PictureAddressBinaryData);
EndProcedure

&AtClient
Procedure SaveToFile(Command)
	Picture = PictureFromTempStorage();
	
	If Picture.Вид = PictureType.Empty Then
		UT_CommonClientServer.MessageToUser(NStr("ru = 'Картинка пустая'; en = 'Picture is empty'"));
		Return;
	EndIf;
	
	SaveParameters = UT_CommonClient.NewFileSavingParameters();
	SaveParameters.TempStorageFileDirectory = PictureAddressBinaryData;
	
	FileDialog = New FileDialog(FileDialogMode.Save);
	FileDialog.Title = NStr("ru = 'Сохранение картинки'; en = 'Picture save'");
	FileDialog.Multiselect = False;
#If Not WebClient Then
	FileDialog.Filter = Picture.FileNameFilter();
#EndIf
	SaveParameters.FileDialog = FileDialog;
	
	UT_CommonClient.BeginFileSaving(SaveParameters);
EndProcedure

&AtClient
Procedure OpenInApplicationByDefault(Command)
	
EndProcedure

&AtClient
Procedure LoadFromFile(Command)
	Picture = New Picture();
	
	FileReadingParameters = UT_CommonClient.NewFileReadingParameters(UUID);
	FileReadingParameters.EndingCallbackDescription = New CallbackDescription("LoadFromFileFinishPutingInTempStorage",
		ThisObject);
	
	FileDialog = New FileDialog(FileDialogMode.Open);
	FileDialog.Title = NStr("ru = 'Чтение картинки'; en = 'Picture reading'");
	FileDialog.Multiselect = False;
	FileDialog.CheckFileExistence = True;
	FileDialog.Preview = True;
#If Not WebClient Then
	FileDialog.Filter = Picture.FileNameFilter();
#EndIf
	FileReadingParameters.FileDialog = FileDialog;

	UT_CommonClient.BeginFileReading(FileReadingParameters);
EndProcedure

#EndRegion

#Region Private

&AtServer
Function PictureFromTempStorage()
	If Not IsTempStorageURL(PictureAddressBinaryData) Then
		Return New Picture();
	EndIf;	
	
	BinaryData = GetFromTempStorage(PictureAddressBinaryData);
	Try
		Return New Picture(BinaryData);
	Except
		Return New Picture();
	EndTry;
EndFunction

&AtClient
Procedure LoadFromFileFinishPutingInTempStorage(FilesArray, ExtraParameters) Export
	If FilesArray = Undefined Then
		Return;
	EndIf;
	If FilesArray.Count() = 0 Then
		Return;
	EndIf;
	
	SetPicturByReadFile(FilesArray[0]);
EndProcedure

&AtServer
Procedure SetPicturByReadFile(ReadFile)
	BinaryDataAddress = ReadFile.Location;
	
	
	PictureBinaryData = GetFromTempStorage(BinaryDataAddress);
	Try
		Picture = New Picture(PictureBinaryData);
		PictureAddressBinaryData = BinaryDataAddress;
	Except
		UT_CommonClientServer.MessageToUser(NStr("ru = 'Не удалось инициализировать картинку:'; en = 'Failed to initialize image:'")
															 + " " + ErrorDescription());
		Picture = New Picture;
		PlacePictureInTemporaryStorage(Picture);
	EndTry;
	SetPictureParametersOnForm(Picture);
EndProcedure

&AtServer
Procedure PlacePictureInTemporaryStorage(Picture)
	PictureBinaryData = Picture.GetBinaryData();
	PictureAddressBinaryData = PutToTempStorage(PictureBinaryData, UUID);
EndProcedure

&AtServer
Procedure SetPictureParametersOnForm(Picture)
	Type = Picture.Type;

	PictureBinaryData =  Picture.GetBinaryData();
	If TypeOf(PictureBinaryData) = Type("BinaryData") Then
		Size = PictureBinaryData.Size();
	Else
		Size = 0;
	EndIf;
EndProcedure

#EndRegion
