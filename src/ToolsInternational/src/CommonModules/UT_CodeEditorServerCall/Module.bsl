#Region Public

Function MetaDataDescriptionForMonacoEditorInitialize() Export
	Return UT_CodeEditorServer.MetaDataDescriptionForMonacoEditorInitialize();
EndFunction

Function ConfigurationMetadataObjectDescriptionByName(ObjectType, ObjectName) Export
	Return UT_CodeEditorServer.ConfigurationMetadataObjectDescriptionByName(ObjectType, ObjectName);	
EndFunction

Function ConfigurationMetadataDescription(IncludeAttributesDescription = True) Export
	Return UT_CodeEditorServer.ConfigurationMetadataDescription(IncludeAttributesDescription);
EndFunction

Function MetadataListByType(MetadataType) Export
	Return UT_CodeEditorServer.MetadataListByType(MetadataType);
EndFunction

Function ReferenceTypesMap() Export
	Return UT_CodeEditorServer.ReferenceTypesMap();
EndFunction

// Editors for Build with converted module text.
// 
// Parameters:
//  EditorsForBuild - Массив из look at UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor - Editors for Build
// 
// Return values:
// Массив из look at UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor 
Function EditorsForBuildWithConvertedTextModule(EditorsForBuild) Export
	Return UT_CodeEditorServer.EditorsForBuildWithConvertedTextModule(EditorsForBuild);	
EndFunction

// Link to the code in the service after downloading.
// 
// Parameters:
//  TextOfAlgorithm - String - Текст алгоритма
//  QueryMode - Boolean - Режим запроса
// 
// Return values:
//  String -  Link to the code in the service after downloading
Function LinkToCodeInServiceAfterDownload(TextOfAlgorithm, QueryMode) Export
	ResultOfSubmission = UT_Paste1CAPI.LoadingResultAlgorithmIntoService(TextOfAlgorithm, QueryMode);
	If ResultOfSubmission = Undefined Then
		UT_CommonClientServer.MesageToUser(NStr("ru = 'Не удалось загрузить алгоритм в сервис'; en = 'Failed to load the algorithm into the service'"));
		Return "";
	EndIf;
	
	If Not ResultOfSubmission.Successfully Then
		UT_CommonClientServer.MesageToUser(NStr("ru = 'Не удалось загрузить алгоритм в сервис: '; en = 'Failed to load the algorithm into the service'")
															 + ResultOfSubmission.Errors);
		Return "";

	EndIf;

	Return ResultOfSubmission.Link;
EndFunction

// Algorithm data in service.
// 
// Parameters:
//  Link - String - Link
// 
// Return values:
// look at UT_Paste1CAPI.NewAlgorithmData
// Return values:
// Undefined - Failed to receive data from the service
Function AlgorithmDataInService(Link) Export
	StructureLinks = УИ_КоннекторHTTP.РазобратьURL(Link);	
	
	ArrayPaths = StrSplit(StructureLinks.Путь, "/", False);
	If ArrayPaths.Count() = 0 Then
		UT_CommonClientServer.MesageToUser(NStr("ru = 'Указан невалидный адрес кода'; en = 'Invalid code address specified'"));
		Return Undefined;
	EndIf;
		
	AlgorithmID = ArrayPaths[ArrayPaths.Count()-1];	
	
	Return  UT_Paste1CAPI.ServiceAlgorithmData(AlgorithmID);
	
EndFunction

// Data library general layout.
// 
// Parameters:
//  LayoutName - String - Layout name
//  FormID - UUID
// 
// Return values:
//  look at UT_CodeEditorClientServer.NewDataLibraryEditor
Function DataLibraryGeneralLayout(LayoutName, FormID) Export
	Return UT_CodeEditorServer.DataLibraryCommonTemplate(LayoutName, FormID);
EndFunction

#EndRegion