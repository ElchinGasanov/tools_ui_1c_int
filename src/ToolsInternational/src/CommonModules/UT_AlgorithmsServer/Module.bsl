
#Region Public

#Region StorageOfAlgorithms

// Algorithm data.
// 
// Parameters:
//  ID - String - Identifier
// 
// Return values:
//  look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
// Return values: 
// 	Undefined - Алгоритм не найден
Function AlgorithmData(ID) Export
	// First we look in DBF
	AlgorithmsDatabase = AlgorithmStorageBase();
	
	AlgorithmsDatabase.CurrentIndex = AlgorithmsDatabase.Индексы.IDXID;
	Found = AlgorithmsDatabase.Find(ID, "=");
	
	AlgorithmDescription = Undefined;
	If Found Then
		AlgorithmDescription = UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm();
		FillAlgorithmHeaderByStorageBase(AlgorithmDescription, AlgorithmsDatabase);
		FillDescriptionAlgorithmAfterReadingHeader(AlgorithmDescription);
	EndIf;
	AlgorithmsDatabase.CloseFile();

	If AlgorithmDescription <> Undefined Then
		Return AlgorithmDescription;
	EndIf;

	

	Return AlgorithmDescription;
EndFunction

// List of algorithms.
// 
// Return values:
// Array of look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders
Function ListOfAlgorithms() Export
	AlgorithmsArray = New Array;//Array of look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders
	
	AddToListOfAlgorithmsFromDBF(AlgorithmsArray);
	AddToListOfAlgorithmsFromTheGeneralSettingsStorage(AlgorithmsArray);	
	
	Return AlgorithmsArray;
EndFunction

// Write algorithm.
// 
// Parameters:
//  AlgorithmData - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
//  Refusal - Boolean
Procedure WriteAlgorithm(AlgorithmData, Refusal) Export
	If AlgorithmData.InSettingsStorage Then
		WriteAlgorithmToSettingsStorage(AlgorithmData, Refusal);
	Иначе
		WriteAlgorithmToDBF(AlgorithmData, Refusal);
	EndIf;
EndProcedure

// Remove algorithm.
// 
// Parameters:
//  ID - String - Identifier
Procedure RemoveAlgorithm(ID) Export
	
EndProcedure

Procedure AlgorithmsFindByName(Name) Export
	
EndProcedure

Procedure AlgorithmsFindByCode(Code) Export
	
EndProcedure

Function AlgorithmsEmptyLink() Export
	
EndFunction

#EndRegion

// Description
// 
// Parametrs:
// 	AlgorithmName - String - Algoritms catalog item name , searched by name 
// 	AlgorithmText - String - Attribute "AlgorithmText" value
// 	ParameterN - Value of any type
// Return value:
// 	String - Result of algorithm saving execution
Function CreatingOfAlgorithm(AlgorithmName, AlgorithmText = "", Val Parameter1 = Undefined, 
	Val Parameter2 = Undefined, Val Parameter3 = Undefined, Val Parameter4 = Undefined, 
	Val Parameter5 = Undefined, Val Parameter6 = Undefined, Val Parameter7 = Undefined, 
	Val Parameter8 = Undefined, Val Parameter9 = Undefined, Val ParametersNamesArray = Undefined)  Export
	
	AlgorithRef = Catalogs.UT_Algorithms.FindByDescription(AlgorithmName);
	If AlgorithRef = Catalogs.UT_Algorithms.EmptyRef() Then
		AlgorithmsObject = Catalogs.UT_Algorithms.CreateItem();
		AlgorithmsObject.Description = AlgorithmName;	
	Else	
		AlgorithmsObject = AlgorithRef.GetObject();
	EndIf;
	If ValueIsFilled(AlgorithmText) Then
		AlgorithmsObject.AlgorithmText = AlgorithmText;
	EndIF;
	
	ParametersStructure = New Structure;
	ParameterValue = Undefined;
	
	SetSafeMode(True);
	If TypeOf(ParametersNamesArray) <> Type("Array") Then
		ParametersNamesArray = New Array;
	EndIf;
	For Parameter = 1 To 9 Do
		VariableName = "Parameter" + Parameter;
		Execute("ParameterValue = " + VariableName);
		ParameterName = ?(ParametersNamesArray.Count() >= Parameter, ParametersNamesArray[Parameter-1],"Parameter" + Parameter); 
		If ParameterValue <> Undefined Then
			ParametersStructure.Insert(ParameterName, ParameterValue);	
		EndIf;
	EndDo;	
	SetSafeMode(False);
	
	AlgorithmsObject.Storage = New ValueStorage(ParametersStructure);
	Try
		AlgorithmsObject.Записать();
	Except
		Return NStr("ru = 'Ошибка выполнения записи ';en = 'Writing execution error'") + ErrorDescription();
	Endtry;
	
	Return NStr("ru = 'Успешно сохранено';en = 'Successfully saved'");
EndFunction

Function ExecuteAlgorithm(Algorithm) Export
	If Not ValueIsFilled(TrimAll(Algorithm.AlgorithmText)) Then
		Return Undefined;
	EndIf;
	
	ExecutionContext = GetParameters(Algorithm);

	ExecutionResult =  UT_CodeEditorClientServer.ExecuteAlgorithm(Algorithm.AlgorithmText, ExecutionContext);
	
	Return ExecutionResult;
EndFunction

Function GetParameters(Algorithm) Export
	StorageParameters = Algorithm.Storage.Get();
	If StorageParameters = Undefined Or TypeOf(StorageParameters) <> Type("Structure")Then 
		StorageParameters =  New Structure;
	EndIf;
	Return StorageParameters;
EndFunction


#EndRegion

#Region Internal


// Algorithm storage directory.
// 
// Return values:
//  String -  Algorithm storage directory
Function DirectoryStorageAlgorithms() Export
	Return УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(УИ_ОбщегоНазначения.КаталогДанныхИнструментовНаСервере(),
														   "Algorithms");
EndFunction
#EndRegion

#Region Private



#Region StorageOfAlgorithmsStorageOfGeneralSettings

Function DataKeyOfAlgorithmObjectInSettingsStorage() Export
	Return "UT_UniversalTools_StorageOfAlgorithms";
EndFunction

// List of algorithms.
// 
// Parameters:
//  AlgorithmsArray - Array from look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders 
// 
Procedure AddToListOfAlgorithmsFromTheGeneralSettingsStorage(AlgorithmsArray) 
	SetPrivilegedMode(True);
	
	SearchStructure = New Structure;
	SearchStructure.Insert("ObjectKey", DataKeyOfAlgorithmObjectInSettingsStorage());

	Selection = SystemSettingsStorage.Select(SearchStructure);

	While Selection.Next() Do
		HeaderDescription = UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders();
		DataSettings = Selection.Настройки;
		Try
			FillPropertyValues(HeaderDescription, DataSettings);
		Except
		EndTry;
		
		AlgorithmsArray.Добавить(HeaderDescription);
	EndDo;
	
EndProcedure

// Write algorithm to settings storage.
// 
// Parameters:
//  AlgorithmData - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
//  Refusal - Boolean -
Procedure WriteAlgorithmToSettingsStorage(AlgorithmData, Refusal)
	SettingsKey = AlgorithmData.ID;// + "/" + UserName() + "/" + Format(CurrentDate(), "DF=yyyyMMddHHmmss;");

//		If ValueIsFilled(Name) Then
//			SettingsKey = SettingsKey + "/" + Name;
//		EndIf;

	AlgorithmObjectKey = DataKeyOfAlgorithmObjectInSettingsStorage();

	Try
		УИ_ОбщегоНазначения.ХранилищеСистемныхНастроекСохранить(AlgorithmObjectKey, SettingsKey, AlgorithmData);
	Except
		Refusal = True;
	EndTry;
EndProcedure

#EndRegion

#Region DBFStorageAlgorithm

// Directory storage additional data algorithm.
// 
// Parameters:
//  ID - String - Identifier
// 
// Return values:
//  String
Function DirectoryStorageAdditionalDataAlgorithm(ID)
	Return УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(УИ_ОбщегоНазначенияПовтИсп.КаталогХраненияАлгоритмов(),
														   "AlgorithmData",
														   ID);
EndFunction

// Write algorithm to the DBF.
// 
// Parameters:
//  AlgorithmData - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
//  Refusal - Boolean -
Procedure WriteAlgorithmToDBF(AlgorithmData, Refusal)
	AlgorithmsDatabase = AlgorithmStorageBase(True);
	
	AlgorithmsDatabase.CurrentIndex = AlgorithmsDatabase.Indexes.IDXID;
	Found = AlgorithmsDatabase.Find(AlgorithmData.ID, "=");
	
	If Not Found Then
		AlgorithmsDatabase.Add();
	EndIf;
	
	If Not ValueIsFilled(AlgorithmData.ID) Then
		AlgorithmData.ID = String(New UUID);
	EndIf;
	AlgorithmsDatabase.id 		= AlgorithmData.ID;
	AlgorithmsDatabase.name 	= AlgorithmData.Name;
	AlgorithmsDatabase.comment 	= AlgorithmData.Comment;
	AlgorithmsDatabase.cashed 	= AlgorithmData.Cache;
	AlgorithmsDatabase.catch 	= AlgorithmData.ThrowException;
	AlgorithmsDatabase.transact = AlgorithmData.ExecuteInTransaction;
	AlgorithmsDatabase.savejour = AlgorithmData.RecordErrorsORL;
	AlgorithmsDatabase.httpid 	= AlgorithmData.HTTPID;
	AlgorithmsDatabase.shedid 	= AlgorithmData.RegularTaskID;
	AlgorithmsDatabase.sheduled = AlgorithmData.ExecuteOnSchedule;
	AlgorithmsDatabase.onclient = AlgorithmData.AtClient;
	AlgorithmsDatabase.CODE 	= AlgorithmData.Code;
	
	AlgorithmsDatabase.Save();
	AlgorithmsDatabase.CloseFile();
	
	DirectoryStorageAdditionalDataAlgorithm = DirectoryStorageAdditionalDataAlgorithm(AlgorithmData.ID);
	УИ_ОбщегоНазначения.ОбеспечитьКаталог(DirectoryStorageAdditionalDataAlgorithm);

	FileNameText = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(DirectoryStorageAdditionalDataAlgorithm,
																	UT_AlgorithmsClientServer.AlgorithmTextFileNameDBF());
	
	Text = New TextDocument();
	Text.SetText(AlgorithmData.TextOfTheAlgorithm);
	Text.Write(FileNameText, TextEncoding.UTF8);
EndProcedure


// Algorithm header from the storage database.
// 
// Parameters:
// 	HeaderDescription - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders
//  StorageBase - XBase - Storage Base
Procedure FillAlgorithmHeaderByStorageBase(HeaderDescription,StorageBase)
	HeaderDescription.ID 					= TrimAll(StorageBase.id);
	HeaderDescription.Name 					= TrimAll(StorageBase.name);
	HeaderDescription.Comment 				= TrimAll(StorageBase.comment);
	HeaderDescription.Cache 				= StorageBase.cashed;
	HeaderDescription.ThrowException 		= StorageBase.catch;
	HeaderDescription.ExecuteInTransaction 	= StorageBase.transact;
	HeaderDescription.RecordErrorsORL 		= StorageBase.savejour;
	HeaderDescription.HTTPID 				= TrimAll(StorageBase.httpid);
	HeaderDescription.RegularTaskID 		= TrimAll(StorageBase.shedid);
	HeaderDescription.ExecuteOnSchedule 	= StorageBase.sheduled;
	HeaderDescription.AtClient 				= StorageBase.onclient;
	HeaderDescription.Code 					= TrimAll(StorageBase.CODE);

EndProcedure

Procedure FillDescriptionAlgorithmAfterReadingHeader(AlgorithmDescription) Export
	CatalogAlgorithmsAdditionalData = DirectoryStorageAdditionalDataAlgorithm(AlgorithmDescription.ID);
	AlgorithmFileName = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(CatalogAlgorithmsAdditionalData,
																	   UT_AlgorithmsClientServer.AlgorithmTextFileNameDBF());
	
	Text = New TextDocument();
	Text.Read(AlgorithmFileName, TextEncoding.UTF8);
	
	AlgorithmDescription.TextOfTheAlgorithm = Text.GetText();
EndProcedure

// List of algorithms.
// 
// Parameters:
//  AlgorithmsArray - Массив из look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders 
// 
Procedure AddToListOfAlgorithmsFromDBF(AlgorithmsArray) 
	AlgorithmsDatabase = AlgorithmStorageBase();
	ThereIsRecords = AlgorithmsDatabase.First();
	If Not ThereIsRecords Then
		Return;
	EndIf;
	
	While True Do
		HeaderDescription = UT_AlgorithmsClientServer.NewDescriptionOfAlgorithmHeaders();
		FillAlgorithmHeaderByStorageBase(HeaderDescription, AlgorithmsDatabase);
		
		AlgorithmsArray.Add(HeaderDescription);

		If Not AlgorithmsDatabase.Next() Then
			Break;
		EndIf;
	EndDo;
	AlgorithmsDatabase.CloseFile();
	
EndProcedure

// Create a storage database of algorithms.
// 
// Parameters:
//  FileNameStorage - String - File name of storage
//  IndexFileName - String - Name of index file 
Procedure CreateStorageDatabaseOfAlgorithms(FileNameStorage, IndexFileName) 
	DBF = AlgorithmsXBaseStorageObject();
	UpdateStorageStructureHeader(DBF);
	DBF.CreateFile(FileNameStorage);
	//DBF.CreateIndex(IndexFileName);
	DBF.CloseFile();
EndProcedure

// Algorithm storage base.
// 
// Parameters:
//  ForChange - Boolean -  For change
// 
// Return values:
//  XBase -  Algorithm storage base
Function AlgorithmStorageBase(ForChange = False) 
	StorageCatalog = ОбщегоНазначенияПовтИсп.КаталогХраненияАлгоритмов();
	УИ_ОбщегоНазначения.ОбеспечитьКаталог(StorageCatalog);

	FileName = FileNameStorageAlgorithms();
	
	FileNameStorage = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(StorageCatalog, FileName + ".DBF");
	IndexFileName = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(StorageCatalog, FileName + ".CDX");
		
	File = New File(FileNameStorage);
	If Not File.Exists() Then
		CreateStorageDatabaseOfAlgorithms(FileNameStorage, IndexFileName);
	EndIf;
		
	DBF = AlgorithmsXBaseStorageObject();
	DBF.OpenFile(FileNameStorage, IndexFileName, Not ForChange);
		
	Return DBF;	
EndFunction

// Update storage structure header.
// 
// Parameters:
//  DBF - XBase - DBF
Procedure UpdateStorageStructureHeader(DBF)
	AddStorageField(DBF, "ID", 			"S", 40);
	AddStorageField(DBF, "NAME", 		"S", 150);
	AddStorageField(DBF, "CODE", 		"S", 9);
	AddStorageField(DBF, "COMMENT", 	"S", 150);
	AddStorageField(DBF, "CASHED", 		"L");
	AddStorageField(DBF, "CATCH", 		"L");
	AddStorageField(DBF, "TRANSACT", 	"L");
	AddStorageField(DBF, "SAVEJOUR", 	"L");
	AddStorageField(DBF, "HTTPID", 		"S", 25);
	AddStorageField(DBF, "SHEDID", 		"S", 50);
	AddStorageField(DBF, "SHEDULED", 	"L");
	AddStorageField(DBF, "ONCLIENT", 	"L");
	
	AddIndexByStorageField(DBF, "IDXID", 		"ID", 		True);
	AddIndexByStorageField(DBF, "IDXNAME", 		"NAME", 	False);
	AddIndexByStorageField(DBF, "IDXHTTPID", 	"HTTPID", 	False);
	AddIndexByStorageField(DBF, "IDXSHEDID", 	"SHEDID", 	False);
EndProcedure

// Add index by storage field.
// 
// Parameters:
//  DBF - XBase - DBF
//  Name - String - Имя
//  Expression - String - Expression
//  Uniqueness - Boolean - Uniqueness
Procedure AddIndexByStorageField(DBF, Name, Expression, Uniqueness)
	Index = DBF.Indexes.Find(Name);
	If Index <> Undefined Then
		Return;
	EndIf;
	
	DBF.Indexes.Add(Name, Expression, Uniqueness);
EndProcedure

Procedure AddStorageField(DBF, Name, Type, Length = 0, Precision = 0)
	Fild = DBF.Fields.Find(Name);
	If Fild <> Undefined Then
		Return;
	EndIf;
	
	DBF.Fields.Add(Name, Type, Length, Precision);
EndProcedure

Function FileNameStorageAlgorithms()
	Return "ALGO";
EndFunction

// Object XBase for storing algorithms.
// 
// Return values:
//  XBase -  Object XBase for storing algorithms.
Function AlgorithmsXBaseStorageObject() 
	DBF = New XBase;
	DBF.Encoding = XBaseEncoding.ANSI;
	DBF.ShowDeleted = False;
		
	Return DBF;
EndFunction

#EndRegion

#EndRegion
