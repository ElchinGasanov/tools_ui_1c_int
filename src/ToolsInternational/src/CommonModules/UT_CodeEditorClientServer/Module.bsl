

#Region Public

// New data library editor.
// 
// Return values:
//  Structure -  New data library editor
//  	* Scripts - Array of Strings - Array of library file addresses in temporary storage
//  	* Styles - Array of Strings - Array of library file addresses in temporary storage
Function NewDataLibraryEditor() Export
	LibraryData = New Structure;
	LibraryData.Insert("Scripts", New Array);
	LibraryData.Insert("Styles", New Array);
	
	Return LibraryData;
EndFunction

// Name of connected DataProcessor for execution code editor.
// 
// Parameters:
//  Идентификатор - String - Идентификатор
// 
// Return values:
//  String
Function NameOfConnectedDataProcessorForExecutionCodeEditor(ID) Export
	Return "UT_CodeEditorа_DataProcessorExecution_" + ID;
EndFunction

Function CodeEditorItemsPrefix() Export
	Return "CodeEditor1C";
EndFunction

Function AttributeNameCodeEditor(EditorID) Export
	Return CodeEditorItemsPrefix() + "_" + EditorID;
EndFunction

Function AttributeNameCodeEditorTypeOfEditor() Export
	Return CodeEditorItemsPrefix() + "_EditorType";
EndFunction

// Attribute name code editor library.
// 
// Return values:
//  String - Attribute name code editor library
Function AttributeNameCodeEditorLibraryURL() Export
	Return CodeEditorItemsPrefix() + "_LibraryUrlInTempStorage";
EndFunction

Function AttributeNameCodeEditorFormCodeEditors() Export
	Return CodeEditorItemsPrefix() + "_FormEditorsList";
EndFunction

// Attribute Name Code Editor Initial Initialization Passed.
// 
// Return :
// String 
Function AttributeNameCodeEditorInitialInitializationPassed() Export
	Return CodeEditorItemsPrefix()+"_InitialInitializationPassed";
EndFunction

Function AttributeNameCodeEditorFormEditors(EditorID) Export
	Return CodeEditorItemsPrefix()+"_FormEditors";
EndFunction

Function CommandBarButtonName(CommandName, EditorID) Export
	Return CodeEditorItemsPrefix() + "_" + CommandName + "_" + EditorID;
EndFunction

Function CodeEditorVariants() Export
	Variants = New Structure;
	Variants.Insert("Text", "Text");
	Variants.Insert("Ace", "Ace");
	Variants.Insert("Monaco", "Monaco");

	Return Variants;
EndFunction

Function EditorVariantByDefault() Export
	Return CodeEditorVariants().Monaco;
EndFunction

// Code editor uses HTML field.
// 
// Parameters:
//  EditorType - String - Editor type
// 
// Return values:
//  Boolean -  Code editor uses HTML field
Function CodeEditorUsesHTMLField(EditorType) Export
	Variants = CodeEditorVariants();
	Return EditorType = Variants.Ace
		Or EditorType = Variants.Monaco;
EndFunction

// Initial Initialization of Code editors passed
// 
// Parameters:
//  Form - ClientApplicationForm
// 
// Return:
//  Boolean
Function CodeEditorsInitialInitializationPassed(Form) Export
	Return Form[AttributeNameCodeEditorInitialInitializationPassed()];
EndFunction 

// Set Flag Code Editors Initial Initialization Passed.
// 
// Parameters:
//  Form - ClientApplicationForm
//  InitializationPassed - Boolean
Procedure SetFlagCodeEditorsInitialInitializationPassed(Form, InitializationPassed) Export
	Form[AttributeNameCodeEditorInitialInitializationPassed()] = InitializationPassed;
EndProcedure

Function EditorIDByFormItem(Form, Item) Export
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	For Each KeyAndValue In FormEditors Do
		If KeyAndValue.Value.EditorField = Item.Name Then
			Return KeyAndValue.Key;
		EndIf;
	EndDo;

	Return Undefined;
EndFunction

Function StructureNameCommandForms(CommandName) Export
	ArrayName = StrSplit(CommandName, "_");

	StructureName = New Structure;
	StructureName.Insert("CommandName", ArrayName[1]);
	StructureName.Insert("EditorID", ArrayName[2]);

	Return StructureName;
EndFunction

Function ExecuteAlgorithm(__AlgorithmText__, __Context__, ExecutionAtClient = False, Form = Undefined,
	EditorID = Undefined) Export
	UT__Successfully__ = True;
	UT__DescriptionErrors__ = "";
	UT__StartOfExecution__ = CurrentUniversalDateInMilliseconds();

	If ValueIsFilled(__AlgorithmText__) Then
		ExecuteThroughDataProcessor = False;
		If Form <> Undefined And EditorID <> Undefined Then
			FormEditors = FormEditors(Form);
			EditorData = FormEditors[EditorID];
			ExecuteThroughDataProcessor = EditorData.UseDataProcessorToExecuteCode;
		EndIf;

		If ExecuteThroughDataProcessor Then
			Try
				If ExecutionAtClient Then
#If AtClient Then
					//@skip-check use-non-recommended-method
					PerformerDataProcessor = GetForm("ExternalDataProcessor."
														 + NameOfConnectedDataProcessorForExecutionCodeEditor(EditorID)
														 + ".Form");
#EndIf
				Else
#If Not AtClient Or ThickClientOrdinaryApplication Or ThickClientManagedApplication Then
					PerformerDataProcessor = ExternalDataProcessors.Create(NameOfConnectedDataProcessorForExecutionCodeEditor(EditorID));
#EndIf
				EndIf;
				PerformerDataProcessor.UT_InitializeVariables(__Context__);
				PerformerDataProcessor.UT_RunAlgorithm();

			Except
				UT__Successfully__ = False;
				UT__DescriptionErrors__ = ErrorDescription();
				Message(UT__DescriptionErrors__);
			EndTry;
		Else
			ExecutableTextAlgorithm = AlgorithmCodeSupplementedWithContext(__AlgorithmText__, __Context__);

			Try
				//@skip-check unsupported-operator
				Execute (ExecutableTextAlgorithm);
			Except
				UT__Successfully__ = False;
				UT__DescriptionErrors__ = ErrorDescription();
				Message(UT__DescriptionErrors__);
			EndTry;
		EndIf;
	EndIf;

	FinishOfExecution = CurrentUniversalDateInMilliseconds();

	ExecutionResult = New Structure;
	ExecutionResult.Insert("Successfully", UT__Successfully__);
	ExecutionResult.Insert("ExecutionTime", FinishOfExecution - UT__StartOfExecution__);
	ExecutionResult.Insert("ErrorDescription", UT__DescriptionErrors__);

	Return ExecutionResult;
EndFunction

Function FormCodeEditorType(Form) Export
	Return Form[AttributeNameCodeEditorTypeOfEditor()];
EndFunction

// New Text Cache Of Editor.
// 
// Return:
//  Structure - New Text Cache Of Editor:
// * Text - String -
// * OriginalText - String -
Function NewTextCacheOfEditor() Export
	Structure = New Structure;
	Structure.Insert("Text", "");
	Structure.Insert("OriginalText", "");
	
	Return Structure;
EndFunction

#Область CommandBarCommandNames


// Command name execution mode through DataProcessor
// 
// Return values:
//  String - Command name execution mode through DataProcessor
Function CommandNameExecutionModeThroughDataProcessor() Export
	Return "ExecutionModeThroughDataProcessor";
EndFunction

// Command name query constructor.
// 
// Return values:
//  String - Command name query constructor
Function CommandNameQueryConstructor() Export
	Return "QueryConstructor";
EndFunction

// Command name share algorithm.
// 
// Return values:
//  String - Command name share algorithm
Function CommandNameShareAlgorithm() Export
	Return "ShareAlgorithm";
EndFunction

// Command name load algorithm.
// 
// Return values:
//  String - Имя команды загрузить алгоритм
Function CommandNameLoadAlgorithm() Export
	Return "LoadAlgorithm";
EndFunction

// Command name start session interactions.
// 
// Return values:
//  String - Command name start session interactions
Function CommandNameStartSessionInteractions() Export
	Return "StartSessionInteractions";
EndFunction

// Command name finish session interactions.
// 
// Return values:
//  String - Command name finish session interactions
Function CommandNameFinishSessionInteractions() Export
	Return "FinishSessionInteractions";
EndFunction


#EndRegion

// Library name interaction for data forms.
// 
// Parameters:
//  EditorType - String - Editor type
// 
// Return values:
//  String - Library name interaction for data forms
Function LibraryNameInteractionForDataForms(EditorType) Export
	Return "LibraryInteractions" + EditorType;
EndFunction

// Editors forms.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
// 
// Return values:
//  Structure of KeyAndValue:
//  	* Key - String - Editor ID
//  	* Value - см. NewEditorFormData
Function FormEditors(Form) Export
	Return Form[AttributeNameCodeEditorFormCodeEditors()];
EndFunction

// Новый данные редактора формы.
// 
// Return values:
//  Structure - Новый данные редактора формы:
// * СобытияРедактора - см. NewEditorEventOptions
// * Инициализирован - Boolean -
// * Видимость - Boolean -
// * ViewOnly - Boolean -
// * TextEditorCache - см. УИ_РедакторКодаКлиентСервер.НовыйКэшТекстовРедактора
// * Язык - String -
// * ПолеРедактора - String -
// * ИмяРеквизита - String -
// * ИмяКоманднойПанелиРедактора - String -
// * Идентификатор - String -
// * UseDataProcessorToExecuteCode - Boolean -
// * ПараметрыРедактора - см. ПараметрыРедактораКодаПоУмолчанию
// * CacheResultsConnectionsDataProcessorExecution -  см. НовыйКэшРезультатовИсполненияЧерезОбработку 
// * SettingsSessionsInteractions - см. НовыйSettingsSessionsInteractions
Function NewEditorFormData() Export
	EditorData = New Structure;
	EditorData.Insert("ID", "");
	EditorData.Insert("EditorEvents", Undefined);
	EditorData.Insert("Initialized", False);
	EditorData.Insert("Visibility", True);
	EditorData.Insert("ViewOnly", False);
	EditorData.Insert("TextEditorCache", Undefined);
	EditorData.Insert("Language", "bsl");
	EditorData.Insert("EditorField", "");
	EditorData.Insert("EditorCommandBarName", "");
	EditorData.Insert("PropsName", "");
	EditorData.Insert("UseDataProcessorToExecuteCode", False);
	EditorData.Insert("EditorOptions", Undefined);
	EditorData.Insert("CacheResultsConnectionsDataProcessorExecution", Undefined);
	EditorData.Insert("SettingsSessionsInteractions", Undefined);
	
	Return EditorData;
EndFunction

// New editor event options.
// 
// Return values:
//  Structure - New editor event options:
// * OnChange - String -
Function NewEditorEventOptions() Export
	EditorEvents = New Structure;
	EditorEvents.Insert("OnChange", "");
	
	Return EditorEvents;
EndFunction
 
// New editor data for build DataProcessor.
// 
// Return values:
//  Structure - New editor data for build DataProcessor:
// * Идентификатор - String -
// * NamesOfPredefinedVariables - Array of String -
// * TextEditor - String -
// * ТекстРедактораДляОбработки - String -
// * ExecutionAtClient - Boolean -
// * ИмяПодключаемойОбработки - String -
Function NewEditorDataForBuildDataProcessor() Export
	Data = New Structure;
	Data.Insert("ID", "");
	Data.Insert("NamesOfPredefinedVariables", New Array);
	Data.Insert("TextEditor", "");
	Data.Insert("TextEditorForDataProcessor", "");
	Data.Insert("ExecutionAtClient", False);
	Data.Insert("ConnectedDataProcessorName", "");
		
	Return Data;
EndFunction

// New cache results connections DataProcessor execution.
// 
// Return values:
//  Structure - New cache results connections DataProcessor execution:
// * ExecutionAtClient - Boolean -
// * TextEditor - String -
// * NamesOfPredefinedVariables - Array of Строка-
Function NewCacheResultsConnectionsDataProcessorExecution() Export
	Cache = New Structure;
	Cache.Insert("ExecutionAtClient", False);
	Cache.Insert("TextEditor", "");
	Cache.Insert("NamesOfPredefinedVariables", New Array);
	
	Return Cache;
EndFunction

// New options session interactions.
// 
// Return values:
//  Structure - New options session interactions:
// * UserName - String - 
// * ID - String - 
// * InteractionURL - String - 
Function NewOptionsSessionInteractions() Export
	SettingsSessionsInteractions = New Structure;
	SettingsSessionsInteractions.Insert("UserName", "");
	SettingsSessionsInteractions.Insert("ID","");
	SettingsSessionsInteractions.Insert("InteractionURL","");
	
	Return SettingsSessionsInteractions;
EndFunction

#EndRegion

#Region Internal

Function MonacoEditorSyntaxLanguageVariants() Export
	SyntaxLanguages = New Structure;
	SyntaxLanguages.Insert("Auto", "Auto");
	SyntaxLanguages.Insert("Russian", "Russian");
	SyntaxLanguages.Insert("English", "English");
	
	Return SyntaxLanguages;
EndFunction

Function MonacoEditorThemeVariants() Export
	Variants = New Structure;
	
	Variants.Insert("Light", "Light");
	Variants.Insert("Dark", "Dark");
	
	Return Variants;
EndFunction

Function MonacoEditorThemeVariantByDefault() Export
	EditorThemes = MonacoEditorThemeVariants();
	
	Return EditorThemes.Light;
EndFunction
Function MonacoEditorSyntaxLanguageByDefault() Export
	Variants = MonacoEditorSyntaxLanguageVariants();
	
	Return Variants.Auto;
EndFunction

// Параметры редактора monaco по умолчанию.
// 
// Return values:
//  Structure -  Параметры редактора monaco по умолчанию:
// * ВысотаСтрок - Number - 
// * Тема - String - 
// * ЯзыкСинтаксиса - String - 
// * ИспользоватьКартуКода - Boolean - 
// * СкрытьНомераСтрок - Boolean - 
// * ОтображатьПробелыИТабуляции - Boolean - 
// * КаталогиИсходныхФайлов - Array of String -
// * ФайлыШаблоновКода - Array of String - 
// * ИспользоватьСтандартныеШаблоныКода - Boolean - 
// * UseCommandsForWorkingWithBufferInContextMenu - Boolean - 
Function  MonacoEditorParametersByDefault() Export
	EditorSettings = New Structure;
	EditorSettings.Insert("LinesHeight", 0);
	EditorSettings.Insert("Theme", MonacoEditorThemeVariantByDefault());
	EditorSettings.Insert("ScriptVariant", MonacoEditorSyntaxLanguageByDefault());
	EditorSettings.Insert("UseScriptMap", False);
	EditorSettings.Insert("HideLineNumbers", False);
	EditorSettings.Insert("DisplaySpacesAndTabs", False);
	EditorSettings.Insert("SourceFilesDirectories", New Array);
	EditorSettings.Insert("CodeTemplatesFiles", New Array);
	EditorSettings.Insert("UseStandartCodeTemplates", True);
	EditorSettings.Insert("UseCommandsForWorkingWithBufferInContextMenu", False);
	
	Return EditorSettings;
EndFunction

Function CodeEditorCurrentSettingsByDefault() Export
	EditorSettings = New Structure;
	EditorSettings.Insert("Variant",  EditorVariantByDefault());
	EditorSettings.Insert("FontSize", 0);
	EditorSettings.Insert("Monaco", MonacoEditorParametersByDefault());
	
	Return EditorSettings;
EndFunction

Function NewDescriptionOfConfigurationSourceFilesDirectory() Export
	Description = New Structure;
	Description.Insert("Directory", "");
	Description.Insert("Source", "");
	
	Return Description;
EndFunction


#EndRegion

#Region Private

Function AlgorithmCodeSupplementedWithContext(AlgorithmText, Context)
	PreparedCode = "";

	For Each KeyAndValue In Context Do
		PreparedCode = PreparedCode +"
		|" + KeyAndValue.Key + "=__Context__." + KeyAndValue.Key + ";";
	EndDo;

	PreparedCode = PreparedCode + Chars.LF + AlgorithmText;

	Return PreparedCode;
EndFunction



#EndRegion