#Region Variables

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SettingsObjectKey=UT_CommonClientServer.DebuggingDataObjectDataKeyInSettingsStorage();
	DataDirectoryDebuggingAtServer = UT_Common.DebuggingDataDirectoryAtServer();
	
	RefreshTableAtServer();
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers
// Code of procedures and functions
#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure RunDebug(Command)
	CurrentData=Items.SavedSettingsTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.RunDebugConsoleByDebugDataSettingsKey(CurrentData.DebuggingDataStoreAddress,
													CurrentData.IsFile,
													CurrentData.DebuggingObjectType,
													CurrentData.Author,
													UUID);

EndProcedure

&AtClient
Procedure RefreshTable(Command)
	RefreshTableAtServer();
EndProcedure

&AtClient
Procedure Delete(Command)

	SelectedRows = Items.SavedSettingsTable.SelectedRows;
	If SelectedRows.Count() = 0 Then
		Return;
	Endif;

	DeleteSelectedRows(SelectedRows);

EndProcedure

#EndRegion

#Region Private
&AtServer
Procedure RefreshTableAtServer()
	SavedSettingsTable.Очистить();
	ReadDataFromStorageSettings();
	ReadDataFromDirectory();
	SavedSettingsTable.Sort("CreationDate Desc");
EndProcedure

&AtServer
Procedure ReadDataFromStorageSettings()
	Picture = PictureLib.SettingsStorage;
	
	SearchStructure = New Structure;
	SearchStructure.Insert("ObjectKey", SettingsObjectKey);

	Selection = SystemSettingsStorage.Select(SearchStructure);

	While Selection.Next() Do
		NewRow = SavedSettingsTable.Add();
		NewRow.DebuggingDataStoreAddress = Selection.SettingsKey;
		NewRow.User = Selection.User;
		NewRow.Picture = Picture;

		KeySettingsArray = StrSplit(NewRow.DebuggingDataStoreAddress, "/");

		NewRow.Author = KeySettingsArray[1];
		NewRow.DebuggingObjectType = KeySettingsArray[0];
		Try
			NewRow.CreationDate = Date(KeySettingsArray[2]);
		Except
			NewRow.CreationDate = "";
		EndTry;
		Try
			NewRow.DebuggingObjectName = KeySettingsArray[3];
		Except
			NewRow.DebuggingObjectName = "";
		EndTry;

	EndDo;
EndProcedure

&AtServer
Function DebuggingObjectMetadataFromFile(MetadataFileName)

	Return UT_CommonClientServer.mReadJSONFromFile(MetadataFileName);
	
EndFunction

&AtServer
Procedure ReadDataFromDirectory()
	Picture = PictureLib.OpenFile;
	
	Files = FindFiles(DataDirectoryDebuggingAtServer, "*.json", True);
	
	For Each CurrentFile In Files Do
		ObjectMetadata = DebuggingObjectMetadataFromFile(CurrentFile.FullName);
		
		NewRow = SavedSettingsTable.Add();
		NewRow.DebuggingDataStoreAddress = CurrentFile.Path;
		NewRow.Author = ObjectMetadata.Автор;
		NewRow.Picture = Picture;
		NewRow.DebuggingObjectType = ObjectMetadata.DebuggingObjectType;
		NewRow.IsFile = True;
		NewRow.DebuggingObjectName = ObjectMetadata.Name;
		Try
			NewRow.CreationDate = XMLValue(Type("Date"), ObjectMetadata.Date);
		Except
			NewRow.CreationDate = CurrentFile.GetModificationTime();
		EndTry;
	
	EndDo;
EndProcedure

&AtServer
Procedure DeleteSelectedRows(Val SelectedRows)

	For Each SelectedRow in SelectedRows do
		DeleteAtServer(SelectedRow);
	enddo; 	
	RefreshTableAtServer();

EndProcedure // DeleteSelectedRows()
 
&AtServer
Procedure DeleteAtServer(CurrentRow)

	TabularSectionRow = SavedSettingsTable.FindByID(CurrentRow);

	If TabularSectionRow.IsFile Then
		//@skip-check empty-except-statement
		Try
			DeleteFiles(TabularSectionRow.DebuggingDataStoreAddress);
		Except
			//UT_CommonClientServer.MessageToUser("Failed");
		EndTry;
	Else
		UT_Common.SystemSettingsStorageDelete(SettingsObjectKey, 
			TabularSectionRow.DebuggingDataStoreAddress,
			TabularSectionRow.User);
	EndIf;
EndProcedure


#EndRegion
