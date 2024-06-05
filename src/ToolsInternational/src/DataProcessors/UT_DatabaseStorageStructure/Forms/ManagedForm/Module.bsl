#Region Variables

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	MethodsForObtainingDatabaseTablesSize = MethodsForObtainingDatabaseTablesSize();

	Items.MethodForDeterminingTableSize.ChoiceList.Clear();

	AvailableMethods = AvailableMethodsOfObtainingDatabaseSize(MethodsForObtainingDatabaseTablesSize);

	For Each CurrentMethod In AvailableMethods Do

		Items.MethodForDeterminingTableSize.ChoiceList.Add(CurrentMethod.Name, CurrentMethod.Presentation);
	EndDo;

	MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.None.Name;
	OnChangeMethodOfDefiningSizeOfTablesAtServer();

	UnitsOfMeasurementSizeTables = UnitsOfMeasurementSizeTables();
	Items.TableSizeUnit.ChoiceList.Clear();
	For Each KeyValue In UnitsOfMeasurementSizeTables Do
		Items.TableSizeUnit.ChoiceList.Add(KeyValue.Value);
	EndDo;
	TableSizeUnit = UnitsOfMeasurementSizeTables.KB;
	SetColumnHeadersSizeTables();

	DataBaseStructureAddress = PutToTempStorage(Undefined, UUID);
	FillBaseStorageStructure();
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	If UT_CommonClientServer.IsWindows() Then
		Items.SQLUtilityPath.InputHint = "psql.exe";
		Items.SQLUtilityCMDPath.InputHint = "sqlcmd.exe";
	Else
		Items.SQLUtilityPath.InputHint = "psql";
		Items.SQLUtilityCMDPath.InputHint = "sqlcmd";
	EndIf;
EndProcedure

&AtServer
Procedure OnLoadDataFromSettingsAtServer(Settings)
	OnChangeMethodOfDefiningSizeOfTablesAtServer();
EndProcedure
#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure IncludingFieldsOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure

&AtClient
Procedure ExactMapOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure

&AtClient
Procedure FilterOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure
&AtClient
Procedure MethodForDeterminingTableSizeOnChange(Item)
	OnChangeMethodOfDefiningSizeOfTablesAtServer();
EndProcedure

&AtClient
Procedure TableSizeUnitOnChange(Item)
	SetColumnHeadersSizeTables();
	OutputTableSaziesIntoResultTable();
EndProcedure
&AtClient
Procedure SQLUtilityCMDPathStartChoice(Item, ChoiceData, StandardProcessing)
	SQLUtilityPathСhoiceStart(Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure SQLUtilityPathStartChoice(Item, ChoiceData, StandardProcessing)
	SQLUtilityPathСhoiceStart(Item, ChoiceData, StandardProcessing);
EndProcedure
#EndRegion

#Region FormTableItemsEventHandlersFormTableFilterByPurposies

&AtClient
Procedure FilterByPurposiesOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersFormTableFilterByTypesOfMetadataObjects

&AtClient
Procedure FilterByTypesOfMetadataObjectsOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers
&AtClient
Procedure UpdateDatabaseTableSize(Command)
	FillTableSizesOfTablesBases();
EndProcedure
&AtClient
Procedure SetFilter(Command)

	SetFiltersOnResultTable();

EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure SQLUtilityPathСhoiceStart(Item, ChosenData, StandardProcessing)
	StandardProcessing = False;

	FileDescription = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	FileDescription.FileName = SQLUtilityPath;

	If UT_CommonClientServer.IsWindows() Then
		UT_CommonClient.AddFormatToSavingFileDescription(FileDescription,
								NStr("ru = 'Исполняемый файл утилиты (*.exe)'; en = 'Executable utility file (*.exe)'"),
								"exe",
								"*.exe");
	EndIf;

	UT_CommonClient.FormFieldFileNameStartChoice(FileDescription,
								Item,
								ChosenData,
								StandardProcessing,
								FileDialogMode.Open,
								New CallbackDescription("SQLUtilityPathStartSelectionFinish",
		ThisObject));

EndProcedure

&AtClient
Procedure SQLUtilityPathStartSelectionFinish(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	EndIf;
	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	SQLUtilityPath = SelectedFiles[0];
EndProcedure

&AtServer
Procedure OutputTableSaziesIntoResultTable()

	Divider = 1;
	If TableSizeUnit = UnitsOfMeasurementSizeTables().MB Then
		Divider = 1024;
	EndIf;
	For Each TableRow In Result Do
		SearchStructure = New Structure;
		SearchStructure.Insert("TableName", Lower(TableRow.StorageTableName));

		TableRow.DataSize = 0;
		TableRow.IndexSize =  0;
		TableRow.Reserved = 0;
		TableRow.FreeSize = 0;
		TableRow.RowCount = 0;

		FounRows = BaseTableDimensions.FindRows(SearchStructure);
		For Each Str Из FounRows Do
			TableRow.DataSize = TableRow.DataSize + Str.DataSize;
			TableRow.IndexSize = TableRow.IndexSize + Str.IndexSize;
			TableRow.Reserved = TableRow.Reserved + Str.Reserved;
			TableRow.FreeSize = TableRow.FreeSize + Str.FreeSize;
			TableRow.RowCount = TableRow.RowCount + Str.RowCount;
		EndDo;
		If Divider <> 1 Then
			TableRow.DataSize = TableRow.DataSize / Divider;
			TableRow.IndexSize = TableRow.IndexSize / Divider;
			TableRow.Reserved = TableRow.Reserved / Divider;
			TableRow.FreeSize = TableRow.FreeSize / Divider;
		EndIf;
	EndDo;
EndProcedure

&AtClient
Procedure FillTableSizesOfTablesBases()
	If MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.Platform.Name Then
		FillTableSizesOfDatabaseTablesPlatformMethod();
		OutputTableSaziesIntoResultTable();
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Name Then
		UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(New CallbackDescription("FillTableSizesBaseViaConsoleUtilityAfterConnectingExtensionsWorkingWithFiles",
			ThisObject));

	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.sqlcmd.Name Then
		UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(New CallbackDescription("FillTableSizesBaseViaConsoleUtilityAfterConnectingExtensionsWorkingWithFiles",
			ThisObject));
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.tool1cd.Name Then 
		FillTableSizesOfDatabaseTablesFromTOOL1CDUtility();
		OutputTableSaziesIntoResultTable();
	EndIf;
EndProcedure

&AtServer
Procedure FillTableSizesOfDatabaseTablesPlatformMethod()
	BaseTableDimensions.Clear();
	BaseStructure = GetFromTempStorage(DataBaseStructureAddress);

	For Each StructureRow In BaseStructure Do
		If Lower(StructureRow.Purpose) <> NStr("ru = 'основная'; en = 'main'") Then
			Continue;
		EndIf;
		If Not ValueIsFilled(StructureRow.Metadata) Then
			Continue;
		EndIf;

		NewRow = BaseTableDimensions.Add();
		NewRow.TableName = Lower(StructureRow.StorageTableName);

		NameArray = New Array;
		NameArray.Add(StructureRow.Metadata);

		Try
			// Appeared only at 8.3.15. On older platforms it won't even launch without such a call
			DataSize = UT_Common.CalculateInSafeMode(NStr("ru = 'ПолучитьРазмерДанныхБазыДанных(,Параметры)'; en = 'GetDatabaseDataSize(,Parameters)'"),
																		  NameArray);
		Except
			DataSize = 0;
		EndTry;
		NewRow.DataSize = DataSize / 1024;

	EndDo;
EndProcedure

&AtServer
Procedure ProvideExecutableFileTool1CDAtServer(DirectoryTool1CD, ExecutableFileTool1CD)
	ExecutableFile = New File(ExecutableFileTool1CD);
	If ExecutableFile.Exists() Then
		Return;
	EndIf;
	
	TemporaryFileName = GetTempFileName("zip");
	
	LayoutBinaryData = GetCommonTemplate("UT_ctool1cd");
	LayoutBinaryData.Write(TemporaryFileName);
	
	ReaderZIP = New ZipFileReader(TemporaryFileName);
	ReaderZIP.ExtractAll(DirectoryTool1CD, ZIPRestoreFilePathsMode.Restore);
	ReaderZIP.Close();
	
	DeleteFiles(TemporaryFileName);
EndProcedure

&AtServerNoContext
Function DatabaseFileNameFromConnectionString()
	ConnectionString = InfoBaseConnectionString();
	PartsConnectionString = StrSplit(ConnectionString, ";");

	DataBaseDirectory = "";

	For Each CurrentPart In PartsConnectionString Do
		If Not ValueIsFilled(CurrentPart) Then
			Continue;
		EndIf;
		
		KeyValue = StrSplit(CurrentPart, "=");
		If KeyValue.Count() <> 2 Then
			Continue;
		EndIf;
		
		If Lower(KeyValue[0])="file" Then
			DataBaseDirectory = Mid(KeyValue[1],2);
			DataBaseDirectory = Left(DataBaseDirectory, StrLen(DataBaseDirectory)-1);
			Break;
		EndIf;
	EndDo;
	If Not ValueIsFilled(DataBaseDirectory) Then
		Return "";
	EndIf;
	
	Return UT_CommonClientServer.MergePaths(DataBaseDirectory, "1Cv8.1CD");
EndFunction

&AtServer
Procedure FillTableSizesOfDatabaseTablesFromTOOL1CDUtility()
	BaseTableDimensions.Clear();
	
	DirectoryTool1CD = UT_Common.Tool1CDfileDirectoryAtServer();

	If UT_CommonClientServer.IsWindows() Then
		ExecutableFileTool1CD = UT_CommonClientServer.MergePaths(DirectoryTool1CD,
																	"windows",
																	"ctool1cd.exe");
	Else
		ExecutableFileTool1CD = UT_CommonClientServer.MergePaths(DirectoryTool1CD, "linux", "ctool1cd");
	EndIf;
	ProvideExecutableFileTool1CDAtServer(DirectoryTool1CD, ExecutableFileTool1CD);
	
	ResultFileName = GetTempFileName("csv");
	LogFileName = GetTempFileName("txt");
	DatabaseFileName = DatabaseFileNameFromConnectionString();

	ExecuteString = StrTemplate("""%1"" -ne -sts ""%2"" -q ""%3"" -l ""%4""",
							  ExecutableFileTool1CD,
							  ResultFileName,
							  DatabaseFileName,
							  LogFileName);

	ReturnCode = Undefined;
	RunApp(ExecuteString, , True, ReturnCode);

	If ReturnCode <> 0 Then
		TextDocumentResult = New TextDocument();
		TextDocumentResult.Прочитать(LogFileName, TextEncoding.UTF8);
	Else
		TextDocumentResult = New TextDocument();
		TextDocumentResult.Прочитать(ResultFileName, TextEncoding.UTF8);
	EndIf;

	DeleteFiles(ResultFileName);
	DeleteFiles(LogFileName);

	If ReturnCode <> 0 Then
		UT_CommonClientServer.MesageToUser(TextDocumentResult.GetText());
		Return;
	EndIf;

	If TextDocumentResult.LineCount() <=1 Then
		Return;
	EndIf;
	
	ColumnNames = StrSplit(TextDocumentResult.GetLine(1), "|");
	
	For RowNumber = 2 To TextDocumentResult.LineCount() Do
		CurrentRow = TextDocumentResult.GetLine(RowNumber);
		If Not ValueIsFilled(CurrentRow) Then
			Continue;
		EndIf;
		
		ArrayRows = StrSplit(CurrentRow, "|");
		
		RowDate = New Structure;
		For ном = 0 To ColumnNames.Количество()-1 Do
			RowDate.Insert(ColumnNames[ном], ArrayRows[ном]);
		EndDo;

		NewRow = BaseTableDimensions.Add();
		NewRow.TableName = Lower(RowDate.table_name);
		NewRow.RowCount = Max(UT_StringFunctionsClientServer.StringToNumber(RowDate.records_count), 0);
		NewRow.DataSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.data_size)
								   / 1024
								   + UT_StringFunctionsClientServer.StringToNumber(RowDate.blob_size)
									 / 1024;
		NewRow.IndexSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.index_size) / 1024;
		NewRow.Reserved = NewRow.DataSize + NewRow.IndexSize;
		NewRow.FreeSize = 0;
	EndDo;
	
EndProcedure



&AtClient
Procedure FillTableSizesBaseViaConsoleUtilityAfterConnectingExtensionsWorkingWithFiles(Connected, AdditionalParameters) Export
	If Not Connected Then
		Return;
	EndIf;
	FileVariables = UT_CommonClient.SessionFileVariablesStructure();
	DirectoryNameForQuery = UT_CommonClientServer.MergePaths(FileVariables.TempFilesDirectory,
		UT_CommonClientServer.RandomFileName());
	
	AdditionalCallBackParameters = New Structure;
	AdditionalCallBackParameters.Insert("DirectoryNameForQuery", DirectoryNameForQuery);
	If UT_CommonClientServer.IsWindows() Then
		AdditionalCallBackParameters.Insert("EncodingOfSupportingFiles", "windows-1251");
	Else
		AdditionalCallBackParameters.Insert("EncodingOfSupportingFiles", "utf-8");
	EndIf;

	UT_CommonClient.BeginCatalogProviding(DirectoryNameForQuery,
		New CallbackDescription("FillTableSizesBaseViaConsoleUtilityAfterProvidingDerectory",
			ThisObject, AdditionalCallBackParameters));
EndProcedure

&AtClient
Procedure FillTableSizesBaseViaConsoleUtilityAfterProvidingDerectory(Successfully, AdditionalParameters) Export
	If Not Successfully Then
		Return;
	EndIf;
	
	If MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Name Then
		QueryText =
		"SELECT
		|tablename AS table_name,
		|pg_class.reltuples as records_count,
		|pg_total_relation_size(schemaname||'.'||tablename) / 1024 AS total_usage_kb,
		|pg_table_size(schemaname||'.'||tablename) / 1024 AS table_usage_kb,
		|pg_indexes_size(schemaname||'.'||tablename) / 1024 as index_usage_kb,
		|0 as table_free_kb
		|FROM pg_catalog.pg_tables, pg_catalog.pg_class
		|where pg_tables.tablename = pg_class.relname  
		|and schemaname = 'public';
		|";
		
		IsPossibleGetRequestLogsFile = True;
	Else
		QueryText =
		"CREATE TABLE #t(table_name varchar(255), records_count varchar(255), total_usage_kb varchar(255), table_usage_kb varchar(255), index_usage_kb varchar(255), table_free_kb varchar(255));
		|INSERT INTO #t
		|exec sp_msforeachtable N'exec sp_spaceused ''?''';
		|SELECT * FROM #t;
		|DROP TABLE #t
		|";

		IsPossibleGetRequestLogsFile = False;
	EndIf;

	AdditionalParameters.Insert("RequestFileName",
									 UT_CommonClientServer.MergePaths(AdditionalParameters.DirectoryNameForQuery,
										UT_CommonClientServer.RandomFileName("sql",
											"req")));
	AdditionalParameters.Insert("ResultFileName",
									 UT_CommonClientServer.MergePaths(AdditionalParameters.DirectoryNameForQuery,
										UT_CommonClientServer.RandomFileName("csv",
											"res")));
	If IsPossibleGetRequestLogsFile Then
		AdditionalParameters.Insert("LogFileName",
										 UT_CommonClientServer.MergePaths(AdditionalParameters.DirectoryNameForQuery,
											UT_CommonClientServer.RandomFileName("txt",
												"log")));
	EndIf;
	
	TextDocument = New TextDocument;
	TextDocument.SetText(QueryText);
	TextDocument.BeginWriting(New CallbackDescription("FillSizeTableViaConsoleUtilityAfterRecordingRequestFile",
		ThisObject, AdditionalParameters),
					   AdditionalParameters.RequestFileName,
					   AdditionalParameters.EncodingOfSupportingFiles);

EndProcedure

&AtClient
Function ExecuteStringPsql(AdditionalParameters)
	If Not ValueIsFilled(SQLUtilityPath) Then
		ExecuteFileName = "psql";
	Else
		ExecuteFileName = SQLUtilityPath;
	EndIf;

	Return StrTemplate("""%1"" --host=%2 --dbname=%3 --username=%4 --csv --file=""%5"" --output=""%6"" --log-file=""%7""",
									ExecuteFileName,
									SQLServer,
									SQLDataBase,
									SQLUser,
									AdditionalParameters.RequestFileName,
									AdditionalParameters.ResultFileName,
									AdditionalParameters.LogFileName);
EndFunction

&AtClient
Function StartStringSqlcmd(AdditionalParameters)
	If Not ValueIsFilled(SQLUtilityPath) Then
		ExecuteFileName = "sqlcmd";
	Else
		ExecuteFileName = SQLUtilityPath;
	EndIf;

	Return StrTemplate("""%1"" -S %2 -U %3 -P%4  -d %5 -C -i""%6"" -o ""%7"" -u -I -s ""|"" -W -b",
					  ExecuteFileName,
					  SQLServer,
					  SQLUser,
					  SQLPassword,
					  SQLDataBase,
					  AdditionalParameters.RequestFileName,
					  AdditionalParameters.ResultFileName);

EndFunction

&AtClient
Procedure FillSizeTableViaConsoleUtilityAfterRecordingRequestFile(Result, AdditionalParameters) Export
	If Result <> True Then
		UT_CommonClientServer.MesageToUser(NStr("ru = 'Не удалось записать файл с текстом запроса'; en = 'Failed to write file with request text'"));
		Return;
	EndIf;

	ExecuteViaScript = False;
	If MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Name Then
		If UT_CommonClientServer.IsWindows() Then
			ExecuteViaScript = True;
			ExecuteScriptText = StrTemplate("chcp 65001
											|set PGPASSWORD=%1
											|%2", SQLPassword, ExecuteStringPsql(AdditionalParameters));
		Else
			ExecuteScriptText = StrTemplate("echo ""%1"" | %2", SQLPassword, ExecuteStringPsql(AdditionalParameters));
		EndIf;
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.sqlcmd.Name Then
		ExecuteScriptText = StartStringSqlcmd(AdditionalParameters);
	EndIf;

	If ExecuteViaScript Then
		AdditionalParameters.Insert("StartedScript",
			UT_CommonClientServer.MergePaths(AdditionalParameters.DirectoryNameForQuery,
				UT_CommonClientServer.RandomFileName("bat",
				"run")));
		
		ScriptTextForRecording = New TextDocument;
		ScriptTextForRecording.SetText(ExecuteScriptText);
		ScriptTextForRecording.BeginWriting(New CallbackDescription("FillSizeTableViaConsoleUtilityAfterSavingScriptRun",
			ThisObject, AdditionalParameters),
				AdditionalParameters.StartedScript,
				AdditionalParameters.EncodingOfSupportingFiles);
	Else
	
		AdditionalParameters.Insert("StartedScript", ExecuteScriptText);
		FillSizeTableViaConsoleUtilityAfterSavingScriptRun(True,
			AdditionalParameters);
	EndIf;
	

EndProcedure

&AtClient
Procedure FillSizeTableViaConsoleUtilityAfterSavingScriptRun(Result, AdditionalParameters) Export
	If Result <> True Then
		Return;
	EndIf;
	BeginRunningApplication(New CallbackDescription("FillTableSizesBaseViaConsoleUtilityAfterCommandExecution",
		ThisObject, AdditionalParameters), AdditionalParameters.StartedScript, , True);
	
EndProcedure

&AtClient
Procedure FillTableSizesBaseViaConsoleUtilityAfterCommandExecution(ReturnCode, AdditionalParameters) Export
	ResultText = New TextDocument();
	
	AdditionalParameters.Insert("ReturnCode", ReturnCode);
	AdditionalParameters.Insert("TextDocumentResult", ResultText);
	
	ReadingFileName = AdditionalParameters.ResultFileName;
	If ReturnCode <> 0 And AdditionalParameters.Property("LogFileName") Then
		ReadingFileName = AdditionalParameters.LogFileName;
	EndIf;

	ResultText.BeginReading(New CallbackDescription("FillTableSizesBaseViaConsoleUtilityAfterReadingResultExecution",
		ThisObject, AdditionalParameters), ReadingFileName);

EndProcedure

&AtClient
Procedure FillTableSizesBaseViaConsoleUtilityAfterReadingResultExecution(AdditionalParameters) Export

	If AdditionalParameters.ReturnCode <> 0 Then
		UT_CommonClientServer.MesageToUser(AdditionalParameters.TextDocumentResult.GetText());
		BaseTableDimensions.Clear();
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Name Then
		FillTableSizesOfDatabaseTablesFromStockResultPSQL(AdditionalParameters.TextDocumentResult);
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.sqlcmd.Name Then
		FillTableSizesOfDatabaseTablesFromStockResultSQLCMD(AdditionalParameters.TextDocumentResult);
	EndIf;
		
	OutputTableSaziesIntoResultTable();
	
	BeginDeletingFiles(New CallbackDescription, AdditionalParameters.DirectoryNameForQuery);

EndProcedure

// Fill in the table of database table sizes from the result line PSQL.
// 
// Parameters:
//  TextDocumentResult - TextDocument - Result text document
&AtClient
Procedure FillTableSizesOfDatabaseTablesFromStockResultPSQL(TextDocumentResult)
	BaseTableDimensions.Clear();
	
	If TextDocumentResult.LineCount() <=1 Then
		Return;
	EndIf;
	
	ColumnNames = StrSplit(TextDocumentResult.GetLine(1), ",");
	
	For RowNumber = 2 To TextDocumentResult.LineCount() Do
		CurrentRow = TextDocumentResult.GetLine(RowNumber);
		If Not ValueIsFilled(CurrentRow) Then
			Continue;
		EndIf;
		
		ArrayRows = StrSplit(CurrentRow, ",");
		
		RowDate = New Structure;
		For num = 0 To ColumnNames.Count()-1 Do
			RowDate.Insert(ColumnNames[num], ArrayRows[num]);
		EndDo;

		NewRow = BaseTableDimensions.Add();
		NewRow.TableName = Lower(RowDate.table_name);
		NewRow.RowCount = Max(UT_StringFunctionsClientServer.StringToNumber(RowDate.records_count), 0);
		NewRow.DataSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.table_usage_kb);
		NewRow.IndexSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.index_usage_kb);
		NewRow.Reserved = UT_StringFunctionsClientServer.StringToNumber(RowDate.total_usage_kb);
		NewRow.FreeSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.table_free_kb);
	EndDo;
EndProcedure

// Fill in the table of database table sizes from the result line PSQL.
// 
// Parameters:
//  TextDocumentResult - TextDocument - Result text document
&AtClient
Procedure FillTableSizesOfDatabaseTablesFromStockResultSQLCMD(TextDocumentResult)
	BaseTableDimensions.Clear();
	
	If TextDocumentResult.LineCount() <= 1 Then
		Return;
	EndIf;
	
	RowNumberTableStart = 0;
	For RowNumber = 1 To TextDocumentResult.LineCount() Do
		CurrentRow = TextDocumentResult.GetLine(RowNumber);
			
		ColumnNames = StrSplit(CurrentRow, "|");
		If ColumnNames.Count() > 1 Then
			RowNumberTableStart = RowNumber;
			Break;
		EndIf;
	EndDo;
	
	If Not ValueIsFilled(RowNumberTableStart) Then
		Return;
	EndIf;
	
	For RowNumber = RowNumberTableStart+2 To TextDocumentResult.LineCount() Do
		CurrentRow = TextDocumentResult.GetLine(RowNumber);
		If Not ValueIsFilled(CurrentRow) Then
			Break;
		EndIf;
		
		ArrayRows = StrSplit(CurrentRow, "|");
		
		RowDate = New Structure;
		For num = 0 To ColumnNames.Count()-1 Do
			RowValue = StrReplace(ArrayRows[num],"KB","");
			RowValue = StrReplace(RowValue, " ", "");
			
			RowDate.Insert(ColumnNames[num], RowValue);
		EndDo;

		NewRow = BaseTableDimensions.Add();
		NewRow.TableName = Lower(RowDate.table_name);
		NewRow.RowCount = Max(UT_StringFunctionsClientServer.StringToNumber(RowDate.records_count), 0);
		NewRow.DataSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.table_usage_kb);
		NewRow.IndexSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.index_usage_kb);
		NewRow.Reserved = UT_StringFunctionsClientServer.StringToNumber(RowDate.total_usage_kb);
		NewRow.FreeSize = UT_StringFunctionsClientServer.StringToNumber(RowDate.table_free_kb);
	EndDo;
EndProcedure

&AtServer
Procedure FillBaseStorageStructure()

	BaseStructure = GetFromTempStorage(DataBaseStructureAddress);

	If BaseStructure = Undefined Then

		BaseStructure = GetDBStorageStructureInfo(,True);
		PutToTempStorage(BaseStructure, DataBaseStructureAddress);

	EndIf;

	FillResultTable(BaseStructure);
EndProcedure

&AtServer
Procedure FillResultTable(BaseStructure, FounRows = Undefined)
	Result.Clear();
	FilterByPurposies.Clear();
	FilterByTypesOfMetadataObjects.Clear();

	If FounRows = Undefined Then
		RowsForResult = BaseStructure;
	Else
		RowsForResult = FounRows;
	EndIf;

	DisplaySizies = MethodForDeterminingTableSize <> MethodsForObtainingDatabaseTablesSize.None.Name;

	For Each Row In RowsForResult Do
		NewRow = Result.Add();
		NewRow.TableName = Row.TableName;
		If Not ValueIsFilled(NewRow.TableName) Then
			NewRow.TableName = Row.Metadata;
		EndIf;
		NewRow.Metadata = Row.Metadata;
		NewRow.Purpose = Row.Purpose;
		NewRow.StorageTableName = Row.StorageTableName;
		NewRow.Found = True;
		NewRow.MetadataObjectType = MetadataObjectTypeFromMetadataName(Row.Metadata);

		For Each Field In Row.Fields Do
			NewFieldsRow = NewRow.Fields.Add();
			NewFieldsRow.StorageFieldName = Field.StorageFieldName;
			NewFieldsRow.FieldName = Field.FieldName;
			NewFieldsRow.Metadata = Field.Metadata;
		EndDo;

		For Each Index In Row.Indexes Do
			NewIndexRow = NewRow.Indexes.Add();
			NewIndexRow.StorageIndexName = Index.StorageIndexName;

			// Index fields
			For Each Field In Index.Fields Do
				NewIndexFieldRow = NewIndexRow.IndexFields.Add();
				NewIndexFieldRow.StorageFieldName = Field.StorageFieldName;
				NewIndexFieldRow.FieldName = Field.FieldName;
				NewIndexFieldRow.Metadata = Field.Metadata;
			EndDo;

		EndDo;
	
		If FilterByPurposies.FindByValue(NewRow.Purpose) = Undefined Then
			FilterByPurposies.Добавить(NewRow.Purpose, , True);
		EndIf;

		If FilterByTypesOfMetadataObjects.FindByValue(NewRow.MetadataObjectType) = Undefined Then
			MetedataTypePresentation = NewRow.MetadataObjectType;
			If Not ValueIsFilled(MetedataTypePresentation) Then
				MetedataTypePresentation = "<Empty>";
			EndIf;
			FilterByTypesOfMetadataObjects.Add(NewRow.MetadataObjectType,
													 MetedataTypePresentation,
													 True);
		EndIf;

	EndDo;

	If DisplaySizies Then
		OutputTableSaziesIntoResultTable();
	EndIf;
	Result.Sort("Metadata Asc,TableName Asc");
	FilterByPurposies.SortByValue();
	FilterByTypesOfMetadataObjects.SortByValue();
EndProcedure

&AtServer
Function SelectedAsFilterAllPurposies()
	AllSelected = True;
	
	For Each ListItem In FilterByPurposies Do
		If Not ListItem.Check Then
			AllSelected = False;
			Break;
		EndIf;
	EndDo;
	
	Return AllSelected;
EndFunction


&AtServer
Function SelectedAsFilterAllTypesOfObjectsMetadata()
	AllSelected = True;
	
	For Each ListItem In FilterByTypesOfMetadataObjects Do
		If Not ListItem.Check Then
			AllSelected = False;
			Break;
		EndIf;
	EndDo;
	
	Return AllSelected;
EndFunction

&AtServer
Function MetadataObjectTypeFromMetadataName(NameMetadata)
	NameArray = StrSplit(NameMetadata, ".");
	If NameArray.Count() = 0 Then
		Return "";
	EndIf;
	
	Return NameArray[0];
	
EndFunction

&AtServer
Procedure SetFiltersOnResultTable()
	SearchName = Upper(TrimAll(Filter));
	
	SelectedAllPurposies = SelectedAsFilterAllPurposies();
	SelectedAllTypesOfMetadataObjects = SelectedAsFilterAllTypesOfObjectsMetadata();

	If Not ValueIsFilled(SearchName) And SelectedAllPurposies And SelectedAllTypesOfMetadataObjects Then
		Items.Result.RowFilter = Undefined;
		Return;
	EndIf;
	
	If Not ExactMap And Left(SearchName, 1) = "_" Then
		SearchName = Mid(SearchName, 2);
	EndIf;
	
	For Each ResultString In Result Do
		ResultString.Found = False;
		
		If IncludingFields Then
			For Each RowField In ResultString.Fields Do
				If ExactMap Then
					If Upper(RowField.StorageFieldName) = SearchName Or Upper(RowField.FieldName) = SearchName Then
						ResultString.Found = True;
					EndIf;
				Else

					If StrFind(Upper(RowField.StorageFieldName), SearchName) > 0
						 Or StrFind(Upper(RowField.FieldName), SearchName) Then
						ResultString.Found = True;
					EndIf;
				EndIf;
			EndDo;
		EndIf;

		If ExactMap Then
			If Upper(ResultString.StorageTableName) = SearchName
				 Or Upper(ResultString.TableName) = SearchName
				 Or Upper(ResultString.Metadata) = SearchName
				 Or Upper(ResultString.Purpose) = SearchName Then
				ResultString.Found = True;
			EndIf;
		Else
			If StrFind(Upper(ResultString.StorageTableName), SearchName) > 0
				 Or StrFind(Upper(ResultString.TableName), SearchName)
				 Or StrFind(Upper(ResultString.Metadata), SearchName)
				 Or StrFind(Upper(ResultString.Purpose), SearchName) Then
				ResultString.Found = True;
			EndIf;
		EndIf;
	
		If Not SelectedAllPurposies Then
			ListItem = FilterByPurposies.FindByValue(ResultString.Purpose);
			If ListItem = Undefined Then
				ResultString.Found = False;
			EndIf; 
			
			If Not ListItem.Check Then
				ResultString.Found = False;
			EndIf;
		EndIf;
		
		If Not SelectedAllTypesOfMetadataObjects Then
			ListItem = FilterByTypesOfMetadataObjects.FindByValue(ResultString.MetadataObjectType);
			If ListItem = Undefined Then
				ResultString.Found = False;
			EndIf; 
			
			If Not ListItem.Check Then
				ResultString.Found = False;
			EndIf;
			
		EndIf;
	EndDo;

	SearchStructure = New Structure;
	SearchStructure.Insert("Found", True);
	Items.Result.RowFilter = New FixedStructure(SearchStructure);

EndProcedure

// Ways to get the size of database tables.
// 
// Return values:
//  Structure - Ways to get the size of database tables:
// * None - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * Platform - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * psql - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * sqlcmd - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * tool1cd - Structure - :
// ** Name - String - 
// ** Presentation - String - 
&AtServerNoContext
Function MethodsForObtainingDatabaseTablesSize()
	Methods = New Structure;
	Methods.Insert("None", NewMethodOfObtainingBaseTablesSize("None", NStr("ru = 'Не получать размеры таблиц'; en = 'Do not get table sizes'")));
	Methods.Insert("Platform", NewMethodOfObtainingBaseTablesSize("Platform",
																		NStr("ru = 'Платформенный метод ""ПолучитьРазмерДанныхБазыДанных""'; en = 'Platform method ""GetDatabaseDataSize""'")));
	
	Methods.Insert("tool1cd", NewMethodOfObtainingBaseTablesSize("tool1cd", NStr("ru = 'Утилита ""tool1cd"". Для файловых баз'; en = 'Utility ""tool1cd"". For file databases'")));

	Methods.Insert("psql", NewMethodOfObtainingBaseTablesSize("psql", NStr("ru = 'Утилита ""psql"". PostgreSQL'; en = 'Utility ""psql"". PostgreSQL'")));
	Methods.Insert("sqlcmd", NewMethodOfObtainingBaseTablesSize("sqlcmd", NStr("ru = 'Утилита ""sqlcmd"". MSSQL'; en = 'Utility ""sqlcmd"". MSSQL'")));

	Return Methods;
EndFunction

// Available methods for obtaining database size.
// 
// Parameters:
//  MethodsForObtainingDatabaseTablesSize- см. MethodsForObtainingDatabaseTablesSize
// 
// Return values:
// Array of см. NewMethodOfObtainingBaseTablesSize 
&AtServerNoContext
Function AvailableMethodsOfObtainingDatabaseSize(MethodsForObtainingDatabaseTablesSize)
	Methods = New Array; //Array look at см. NewMethodOfObtainingBaseTablesSize
	Methods.Add(MethodsForObtainingDatabaseTablesSize.None);
	If UT_CommonClientServer.PlatformVersionNotLess("8.3.15") Then
		Methods.Добавить(MethodsForObtainingDatabaseTablesSize.Platform);
	EndIf;
	If UT_Common.FileInfobase()
		 And Not (UT_CommonClientServer.IsLinux() And Not UT_CommonClientServer.IsTheX64Bitness())
		 And Not UT_CommonClientServer.IsMacOs() Then
		Methods.Add(MethodsForObtainingDatabaseTablesSize.tool1cd);
	EndIf;

//	If Not UT_Common.FileInfobase() Then
	Methods.Add(MethodsForObtainingDatabaseTablesSize.psql);
	Methods.Add(MethodsForObtainingDatabaseTablesSize.sqlcmd);
//	EndIf;


	Return Methods;
EndFunction

&AtServerNoContext
Function NewMethodOfObtainingBaseTablesSize(Name, Presentation)
	Method = New Structure;
	Method.Insert("Name", Name);
	Method.Insert("Presentation", Presentation);

	Return Method;
EndFunction

&AtServerNoContext
Function UnitsOfMeasurementSizeTables()
	Units = New Structure;
	Units.Insert("KB","KB");
	Units.Insert("MB","MB");

	Return Units;
EndFunction

&AtServer
Procedure OnChangeMethodOfDefiningSizeOfTablesAtServer()
	BaseTableDimensions.Clear();

	IsPlatformMethod = MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.Platform.Name;
	GetTableSizes = MethodForDeterminingTableSize <> MethodsForObtainingDatabaseTablesSize.None.Name;

	Items.ResultGroupSiziesTables.Visible = GetTableSizes;
	Items.ResultRowCount.Visible = GetTableSizes And Not IsPlatformMethod;
	Items.ResultIndexSize.Visible = GetTableSizes And Not IsPlatformMethod;
	Items.ResultReserved.Visible = GetTableSizes And Not IsPlatformMethod;
	Items.ResultFreeSize.Visible = GetTableSizes And Not IsPlatformMethod;

	Items.PageSettingsReceiptDimensions.CurrentPage = Items["PageSettingsReceiptDimensions"
																					   + MethodForDeterminingTableSize];

	Items.TableSizesGroup.CollapsedRepresentationTitle = NStr("ru = 'Размеры таблиц базы данных:'; en = 'Database table sizes:'")
																  + " " + MethodsForObtainingDatabaseTablesSize[MethodForDeterminingTableSize].Presentation;
EndProcedure
&AtServer
Procedure SetColumnHeadersSizeTables()
	Items.ResultDataSize.Title = NStr("ru = 'Данные ('; en = 'Data ('") + TableSizeUnit + ")";
	Items.ResultIndexSize.Title = NStr("ru = 'Индексы ('; en = 'Indexes ('") + TableSizeUnit + ")";
	Items.ResultReserved.Title = NStr("ru = 'Зарезервировано всего ('; en = 'Total reserved ('") + TableSizeUnit + ")";
	Items.ResultFreeSize.Title = NStr("ru = 'Свободно ('; en = 'Free ('") + TableSizeUnit + ")";
EndProcedure
#EndRegion
