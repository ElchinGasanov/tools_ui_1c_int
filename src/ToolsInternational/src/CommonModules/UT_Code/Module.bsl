
#Region Public

// Replace variables in a text.
// 
// Parameters:
//  Source - String - Source
//  ReplaceableVariables - Structure from KeyAndValue:
//  	* Key - String - current variable name
//  	* Value - String - New variable name
// 
// Return values:
//  String
Function ReplaceVariablesInText(Source, ReplaceableVariables) Export
	PluginOptions = New Structure;
	PluginOptions.Вставить("RenamingVariables", ReplaceableVariables);
	Return ResultChangesText(Source, PluginOptions);

EndFunction

// Set compilation directives for module methods.
// 
// Parameters:
//  Source - String - Source
//  Директива - String - Директива. &AtClient, &AtServer и т.п.
// 
// Return values:
//  String - Set compilation directives for module methods
Function SetCompilationDirectivesUMethodsModule(Source, Directive) Export
	PluginOptions = New Structure;
	PluginOptions.Вставить("InstallationOfCompilationDirectivesModuleMethods", Directive);
	Return ResultChangesText(Source, PluginOptions);
EndFunction

// Change text.
// 
// Parameters:
//  Source - String - Source
//  PluginOptions - Структура Из KeyAndValue:
//  	* Key - String - Plugin name
//  	* Value - Произвольный - Plugin options
// 
// Return values:
//  String
Function ResultChangesText(Source, PluginOptions) Export
	ProcessingResult = ProcessModuleUsingPlugins(Source, PluginOptions);
	
	Substitutions = ProcessingResult.Parser.ТаблицаЗамен();
	Если Substitutions.Количество() > 0 Then
		Return ProcessingResult.Parser.ВыполнитьЗамены();
	EndIf;
	
	Return Source;	
EndFunction

// Text Processing Results.
// 
// Parameters:
//  Source - String - Source
//  PluginOptions - Structure from KeyAndValue:
//  	* Key - String - Plugin name
//  	* Value - Произвольный - Plugin options
// 
// Return values:
//  Array of Произвольный - Results обработки текста
Function TextProcessingResults(Source, PluginOptions) Export
	ProcessingResult = ProcessModuleUsingPlugins(Source, PluginOptions);

	Return ProcessingResult.ProcessingResults;	
EndFunction

Function ModuleStructure(Source) Export
	PluginOptions = New Structure;
	PluginOptions.Insert("GettingModuleStructure", Undefined);

	Results = TextProcessingResults(Source, PluginOptions);

	Return Results[0];
EndFunction

// Text of algorithm execution processing module.
// 
// Parameters:
//  AlgorithmText - String -
//  NamesOfPredefinedVariables - Array of String -
//  ExecutionOnClient - Boolean - Execution on the client. If true, the form module code will be generated, 
//  	otherwise processing module code
// 
// Return values:
//  String
Function TextOfAlgorithmExecutionProcessingModule(AlgorithmText, NamesOfPredefinedVariables ,ExecutionOnClient) Export
	PluginOptions = New Structure;
	If ExecutionOnClient Then
		PluginOptions.Insert("InstallationOfCompilationDirectivesModuleMethods", "&AtClient");
	EndIf;
	
	PluginParametersTextModificationsOfTheAlgorithm = New Structure;
	PluginParametersTextModificationsOfTheAlgorithm.Insert("ExecutionOnClient", ExecutionOnClient);
	PluginParametersTextModificationsOfTheAlgorithm.Insert("VariableNames", NamesOfPredefinedVariables);
	PluginOptions.Insert("RefinementOfTheTextOfTheAlgorithmForProcessing", PluginParametersTextModificationsOfTheAlgorithm);
	
	Return ResultChangesText(AlgorithmText, PluginOptions);
	
EndFunction

#EndRegion

#Region Internal


#EndRegion

#Region Private

// Process module using plugins.
// 
// Parameters:
//  Source - String - Source
//  PluginOptions - Structure of KeyAndValue:
//  	* Key - String - Plugin name
//  	* Value - Произвольный - Plugin options
// 
// Return values:
//  Structure - Process a module using plugins:
// * ProcessingResults - Array of Произвольный -
// * Parser - ОбработкаОбъект.УИ_ПарсерВстроенногоЯзыка -
Function ProcessModuleUsingPlugins(Source, PluginOptions)
	Parser = Обработки.УИ_ПарсерВстроенногоЯзыка.Создать();
	
	Plugins = New Array();
	PluginOptionsExecution = New Map;

	For Each KeyAndValue In PluginOptions Do
		CurrentPlugin = NewParserPluginBuiltInLanguage(KeyAndValue.Key);
		
		Plugins.Add(CurrentPlugin);
		PluginOptionsExecution[CurrentPlugin.ЭтотОбъект] = KeyAndValue.Value;
	EndDo;

	ProcessingResults = Parser.Пуск(Source, Plugins, PluginOptionsExecution);
		
	ProcessingResultStructure = New Structure;
	ProcessingResultStructure.Вставить("ProcessingResults", ProcessingResults);
	ProcessingResultStructure.Вставить("Parser", Parser);
	
	Return ProcessingResultStructure;	
	
EndFunction

// New parser plugin built-in language.
// 
// Parameters:
//  PluginName - String - Plugin name
// 
// Return values:
//  ExternalDataProcessor
// Return values:
//  Undefined - Failed to connect plugin
Function NewParserPluginBuiltInLanguage(PluginName)
	ConnectedProcessingName = NameOfPlugInProcessingParserPlugInBuiltInLanguage(PluginName);
	If Metadata.DataProcessors.Find(ConnectedProcessingName) <> Undefined Then
		Return DataProcessors[ConnectedProcessingName].Create();
	EndIf;
	
	Try
		Return ExternalDataProcessors.Create(ConnectedProcessingName);
	Except
		Try
			ConnectPluginToSession(PluginName);
			Return ExternalDataProcessors.Create(ConnectedProcessingName);
		Except
			Return Undefined;
		EndTry;
	EndTry;
EndFunction

// Connect a plugin to a session.
// 
// Parameters:
//  PluginName - String - Plugin name
Procedure ConnectPluginToSession(PluginName)
	BinaryDataPlugin = Обработки.УИ_ПарсерВстроенногоЯзыка.GetTemplate("Plugin_" + PluginName);
	PluginAddressInTemporaryStorage = PutToTempStorage(BinaryDataPlugin);

	УИ_ОбщегоНазначения.ПодключитьВнешнююОбработкуКСеансу(PluginAddressInTemporaryStorage,
														  NameOfPlugInProcessingParserPlugInBuiltInLanguage(PluginName));

EndProcedure

Function NameOfPlugInProcessingParserPlugInBuiltInLanguage(PluginName)
	Return PrefixOfPluginProcessing() + "_" + Upper(PluginName);	
EndFunction

Function PrefixOfPluginProcessing()
	Return "PluginParserBuiltInLanguage";
EndFunction

#EndRegion
