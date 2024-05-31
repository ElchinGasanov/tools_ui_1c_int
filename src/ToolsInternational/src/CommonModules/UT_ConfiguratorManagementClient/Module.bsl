///////////////////////////////////////////////////////////////////////////////////
// MANAGEMENT OF LAUNCH COMMANDS 1C:Enterprise 8
// Library adaptation v8runner  https://github.com/oscript-library/v8runner
// for 1C platform
#Region Public

// The current context is running on the operating system Windows
// 
// Return values:
//  Boolean - It is windows
Function IsWindows() Export
	Return UT_CommonClientServer.IsWindows();
EndFunction

// Start getting configurator command contextа.
// 
// Parameters:
//  CallbackDescriptionAboutCompletion - CallbackDescription - 
Procedure StartGettingContextConfiguratorCommand(CallbackDescriptionAboutCompletion) Export
	CallbackSettings = New Structure;
	CallbackSettings.Insert("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(New CallbackDescription("StartGettingContextConfiguratorCommandAfterConnectingExtensionsWorkingWithFiles",
		ThisObject, CallbackSettings));
EndProcedure

// Path to temporary base.
// 
// Parameters:
//  CommandContext - см. NewContextConfiguratorCommand 
// 
// Return values:
//  Строка - Path to temporary base
Function PathToTemporaryBase(CommandContext) Export
	Return UT_CommonClientServer.MergePaths(CommandContext.BuildCatalog, "v8r_TempDB");
EndFunction

// Start creating a temporary base.
// 
// Parameters:
//  CommandContext - см. NewContextConfiguratorCommand
//  CallbackDescriptionAboutCompletion - CallbackDescription - Описание оповещения о завершении
Procedure StartCreatingTemporaryBase(CommandContext, CallbackDescriptionAboutCompletion = Undefined) Export

	PathToTemporaryBase = PathToTemporaryBase(CommandContext);

	StartCreatingFileDatabase(CommandContext, PathToTemporaryBase, CallbackDescriptionAboutCompletion);

EndProcedure

// Start checking for the existence of a temporary base.
// 
// Parameters:
//  Context - см. NewContextConfiguratorCommand
// 	CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartCheckingTheExistenceOfTemporaryBase(Context, CallbackDescriptionAboutCompletion) Export
	FileBase = New File(UT_CommonClientServer.MergePaths(PathToTemporaryBase(Context), "1Cv8.1CD"));
	FileBase.BeginCheckingExistence(CallbackDescriptionAboutCompletion);
EndProcedure

// Start creating a file database.
// 
// Parameters:
//  CommandContext - см. NewContextConfiguratorCommand
//  BaseCatalog - String - Каталог базы
//  CallbackDescriptionAboutCompletion - CallbackDescription - Описание оповещения о завершении
//  PathToTemplate - String - Путь к шаблону
Procedure StartCreatingFileDatabase(CommandContext, BaseCatalog, CallbackDescriptionAboutCompletion = Undefined,
	PathToTemplate = "") Export

	CallbackSettings = New Structure;
	CallbackSettings.Insert("CommandContext", CommandContext);
	CallbackSettings.Insert("BaseCatalog", BaseCatalog);
	CallbackSettings.Insert("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	CallbackSettings.Insert("PathToTemplate", PathToTemplate);

	UT_CommonClient.BeginCatalogProviding(BaseCatalog,
														New CallbackDescription("StartCreatingFileDatabaseCompletingProvidingDirectory",
		ThisObject, CallbackSettings));

EndProcedure

// Start building processing from files.
// 
// Parameters:
//  CommandContext - см. NewContextConfiguratorCommand
//  ProcessingSourceFileName - String - Имя главного файла обработки, выгруженной в файлы
//  ResultingFileName - String - Имя собранного файла обработки
//  CallbackDescriptionAboutCompletion - Undefined - Описание оповещения о завершении
Procedure StartBuildProcessingFromFiles(CommandContext, ProcessingSourceFileName, ResultingFileName,
	CallbackDescriptionAboutCompletion = Undefined) Export
	LaunchParameters = StandardConfiguratorLaunchParameters(CommandContext);
	LaunchParameters.Add("/LoadExternalDataProcessorOrReportFromFiles """
							  + ProcessingSourceFileName
							  + """  """
							  + ResultingFileName
							  + """");

	StartExecuteCommand(CommandContext, LaunchParameters, CallbackDescriptionAboutCompletion);
EndProcedure

// Start executing a command.
// 
// Parameters:
//  CommandContext -  см. NewContextConfiguratorCommand
//  Parameters - Array of Строка 
//  CallbackDescriptionAboutCompletion - CallbackDescription - Описание оповещения о завершении
Procedure StartExecuteCommand(CommandContext, Parameters, CallbackDescriptionAboutCompletion) Export
	CallbackSettings = New Structure;
	CallbackSettings.Insert("Context", CommandContext);
	CallbackSettings.Insert("Parameters", Parameters);
	CallbackSettings.Insert("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);

	StartCheckingCapabilitiesExecutingCommands(CommandContext,
		New CallbackDescription("StartExecutingCommandsFinishCheckingCapabilitiesExecutingCommands",
			ThisObject, CallbackSettings));

EndProcedure


// Start uploading the infobase to a file.
// 
// Parameters:
//  CommandContext - см. NewContextConfiguratorCommand
//  ПутьВыгрузкиИБ - String - Путь выгрузки ИБ
//  CallbackDescriptionAboutCompletion - CallbackDescription -
//Procedure НачатьВыгрузкуИнформационнойБазыВФайл(CommandContext, ПутьВыгрузкиИБ, CallbackDescriptionAboutCompletion) Export
//
//	Файл = Новый Файл(ПутьВыгрузкиИБ);
//	КаталогВыгрузкиИБ = Файл.Путь;
//
//	UT_CommonClient.BeginCatalogProviding(BaseCatalog,
//														New CallbackDescription("StartUploadingInformationBaseToFileCompleteCatalogProvision",
//		ThisObject, CallbackSettings));
//
//
//	ОбеспечитьКаталог(КаталогВыгрузкиИБ);
//
//
//EndProcedure

#EndRegion

#Region Internal

// Начать выполнение команды завершение проверки возможности выполнения команды.
// 
// Parameters:
//  ExecutionPossible - Boolean - Признак, что все проверки прошли успешно
//  ExtraParameters - Structure - Параметры оповещения:
//  	* Контекст - см. NewContextConfiguratorCommand
//  	* Параметры - Array of Строка
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartExecutingCommandsFinishCheckingCapabilitiesExecutingCommands(ExecutionPossible,
	ExtraParameters) Export
	File = New File(ExtraParameters.Context.InformationFileName);

	File.BeginCheckingExistence(New CallbackDescription("StartExecuteCommandCompleteCheckingExistenceofFileInformation",
		ThisObject, ExtraParameters));
EndProcedure

// Start executing the command to complete checking the existence of the information file.
// 
// Parameters:
//  Exists - Boolean - Признак существования файла
//  ExtraParameters - Structure - Параметры оповещения:
//  	* Контекст - см. NewContextConfiguratorCommand
//  	* Параметры - Array of Строка
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartExecuteCommandCompleteCheckingExistenceofFileInformation(Exists, ExtraParameters) Export
	If Exists Then
		BeginDeletingFiles(New CallbackDescription("StartExecuteCommandCompletingDeletionInformationFile",
			ThisObject, ExtraParameters, "StartExecuteCommandCompletingDeletionInformationFileWithError",
			ThisObject), ExtraParameters.Context.InformationFileName);
	Else
		RunAndWait(ExtraParameters.Context,
					ExtraParameters.Parameters,
					ExtraParameters.CallbackDescriptionAboutCompletion);
	EndIf;
EndProcedure

// Start executing the command to complete deleting the information file.
// 
// Parameters:
//  ExtraParameters - Structure - Параметры оповещения:
//  	* Контекст - см. NewContextConfiguratorCommand
//  	* Параметры - Array of Строка
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartExecuteCommandCompletingDeletionInformationFile(ExtraParameters) Export
	RunAndWait(ExtraParameters.Context,
				ExtraParameters.Parameters,
				ExtraParameters.CallbackDescriptionAboutCompletion);
EndProcedure

// Start executing the command to complete deletion of an information file with an error.
// 
// Parameters:
//  ExtraParameters - Structure - Параметры оповещения:
//  	* Контекст - см. NewContextConfiguratorCommand
//  	* Параметры - Array of Строка
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartExecuteCommandCompletingDeletionInformationFileWithError(ExtraParameters) Export
	RunAndWait(ExtraParameters.Context,
				ExtraParameters.Parameters,
				ExtraParameters.CallbackDescriptionAboutCompletion);
EndProcedure


// Start receiving the configurator command context after connecting the file processing extension.
// 
// Parameters:
//  Connected - Boolean -
//  ExtraParameters - Structure - Параметры оповещения:
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartGettingContextConfiguratorCommandAfterConnectingExtensionsWorkingWithFiles(Connected,
	ExtraParameters) Export
	If Not Connected Then
		Return;
	EndIf;
	
	Context = NewContextConfiguratorCommand();
	RunCallback(ExtraParameters.CallbackDescriptionAboutCompletion, Context);
EndProcedure

// Start creating the file base finish provisioning the directory.
// 
// Parameters:
//  Successfully - Boolean - Успешно удалось обеспечить каталог
//  ExtraParameters - Structure - Параметры оповещения:
//  	* CommandContext - см. NewContextConfiguratorCommand
//  	* BaseCatalog - String -
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* PathToTemplate - String
Procedure StartCreatingFileDatabaseCompletingProvidingDirectory(Successfully, ExtraParameters) Export
	If Не Successfully Then
		Return;
	EndIf;
		
	BeginDeletingFiles(New CallbackDescription("StartCreatingFileBaseCompleteCleaningDirectory", ThisObject,
		ExtraParameters), ExtraParameters.BaseCatalog, "*.*");
	
EndProcedure

// Start creating a file database finish cleaning the directory.
// 
// Parameters:
//  ExtraParameters - Structure - Параметры оповещения:
//  	* CommandContext - см. NewContextConfiguratorCommand
//  	* BaseCatalog - String -
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* PathToTemplate - String
Procedure StartCreatingFileBaseCompleteCleaningDirectory(ExtraParameters) Export

	LaunchParameters = New Array;
	LaunchParameters.Add("CREATEINFOBASE");
	LaunchParameters.Add("File=""" + ExtraParameters.BaseCatalog + """");
	LaunchParameters.Add("/Out""" + ExtraParameters.CommandContext.InformationFileName + """");
	
//	If ИмяБазыВСписке <> "" Then
//        LaunchParameters.Add("/AddInList"""+ ИмяБазыВСписке + """");
//    EndIf;
	If ValueIsFilled(ExtraParameters.PathToTemplate) Then
        LaunchParameters.Add("/UseTemplate"""+ ExtraParameters.PathToTemplate + """");
    EndIf;

	If ValueIsFilled(ExtraParameters.CommandContext.LanguageCode) Then
		LaunchParameters.Add("/L"+ExtraParameters.CommandContext.LanguageCode);
	EndIf;
	If ValueIsFilled(ExtraParameters.CommandContext.SessionLanguageCode) Then
		LaunchParameters.Add("/VL"+ExtraParameters.CommandContext.SessionLanguageCode);
	EndIf;
	
	RunAndWait(ExtraParameters.CommandContext,
						LaunchParameters,
						ExtraParameters.CallbackDescriptionAboutCompletion);

EndProcedure

// Start creating a file database complete execution.
// 
// Parameters:
//  ReturnCode - Число
//  ExtraParameters - Structure - Параметры оповещения:
//  	* CommandContext - см. NewContextConfiguratorCommand
//  	* BaseCatalog - String -
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* PathToTemplate - String
Procedure RunAndWaitCompleteExecution(ReturnCode, ExtraParameters) Export
	If ReturnCode = 0 Then
		RunCallback(ExtraParameters.CallbackDescriptionAboutCompletion, True);
		Return;
	EndIf;
		
	RunCallback(ExtraParameters.CallbackDescriptionAboutCompletion, False);
//
//	ReturnCode = RunAndWait(LaunchParameters);
//	УстановитьВывод(ПрочитатьФайлИнформации());
//	If ReturnCode <> 0 Then
//		ВызватьИсключение ВыводКоманды();
//	EndIf; 

//	УстановитьВывод(ПрочитатьФайлИнформации());
//	If ReturnCode <> 0 Then
//		Лог.Ошибка("Получен ненулевой код Returnа "+ReturnCode+". Выполнение скрипта остановлено!");
//		ВызватьИсключение ВыводКоманды();
//	Else
//		Лог.Отладка("Код Returnа равен 0");
//	EndIf;

EndProcedure

// Start checking whether the command can be executed, finish checking the existence of the temporary base.
// 
// Parameters:
//  Exists - Boolean -
//  ExtraParameters - Structure - Параметры оповещения:
//  	* Контекст - см. NewContextConfiguratorCommand
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartCheckingCapabilitiesExecutingCommandsFinishCheckingExistenceTemporaryBase(Exists,
	ExtraParameters) Export
	If Exists Then
		RunCallback(ExtraParameters.CallbackDescriptionAboutCompletion, True);
		Return;
	EndIf;


	StartCreatingTemporaryBase(ExtraParameters.Context, ExtraParameters.CallbackDescriptionAboutCompletion);

EndProcedure


// Start creating the file base finish provisioning the director.
// 
// Parameters:
//  Successfully - Boolean - Успешно удалось обеспечить каталог
//  ExtraParameters - Structure - Параметры оповещения:
//  	* CommandContext - см. NewContextConfiguratorCommand
//  	* BaseCatalog - String -
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* PathToTemplate - String
Procedure StartUploadingInformationBaseToFileCompleteCatalogProvision(Successfully, ExtraParameters) Export
	If Not Successfully Then
		Return;
	EndIf;
		
	LaunchParameters = StandardConfiguratorLaunchParameters(ExtraParameters.CommandContext);

//	LaunchParameters.Add("/DumpIB " + ОбернутьВКавычки(ПутьВыгрузкиИБ));
//
//	ExecuteCommand(LaunchParameters);
//	
EndProcedure

#EndRegion

#Region Private

// New context configurator command.
// 
// Return values:
//  Структура - Новый контекст команды:
// * KeyConnectionWithBase - String -
// * UserName - String -
// * Password - String -
// * StartPermissionKey - String -
// * LanguageCode - String -
// * SessionLanguageCode - String -
// * Platform1CPath - String - Путь к исполняемому файлу конфигуратора
// * InformationFileName - String - Имя файла результата выполнения команды
// * BuildCatalog - String - Каталог всех временных файлов
Function NewContextConfiguratorCommand() 
	Structure = New Structure;
	Structure.Insert("BuildCatalog", BuildCatalog());
	Structure.Insert("InformationFileName", InformationFileName(Structure.BuildCatalog));
	Structure.Insert("KeyConnectionWithBase", "");
	Structure.Insert("UserName", "");
	Structure.Insert("Password", "");
	Structure.Insert("StartPermissionKey", "");
	Structure.Insert("LanguageCode", "");
	Structure.Insert("SessionLanguageCode", "");
	Structure.Insert("Platform1CPath", DefaultPathPlatform());

	Return Structure;
EndFunction

// Defines the path to the configurator startup file of the currently running platform
// 
// Return values:
//  String - Default platform path
Function DefaultPathPlatform()
#If WebClient Then
	Return "";
#Else
	Return UT_CommonClientServer.MergePaths(BinDir(), ?(IsWindows(), "1cv8.exe", "1cv8"));
#EndIf
EndFunction

Function BuildCatalog(Знач Catalog = "") Export

	Return UT_CommonClientServer.MergePaths(UT_CommonClient.UT_AssistiveLibrariesDirectory(),
														   "configexecutor");

EndFunction

Function InformationFileName(BuildCatalog) Export
	If Not ValueIsFilled(BuildCatalog) Then
		Return "";
	EndIf;

	Return UT_CommonClientServer.MergePaths(BuildCatalog,
		Format(CurrentUniversalDateInMilliseconds(), "NG=0;")
			+ ".txt")
EndFunction


// Temporal context key.
// 
// Parameters:
//  Context - см. NewContextConfiguratorCommand
// 
// Return values:
//  String - Temporary context key
Function TemporalContextKey(Context)
	Return "/F""" + PathToTemporaryBase(Context) + """";
EndFunction


// Key connection with base.
// 
// Parameters:
//  Context - см. NewContextConfiguratorCommand
// 
// Return values:
// Строка 
Function KeyConnectionWithBase(Context)
	If IsBlankString(Context.KeyConnectionWithBase) Then
		Return TemporalContextKey(Context);
	Else
		Return Context.KeyConnectionWithBase;
	EndIf;
EndFunction

// Standard configurator launch parameters.
// 
// Parameters:
//  Context - см. NewContextConfiguratorCommand
// 
// Return values:
//  Array of Строка - Стандартные параметры запуска конфигуратора
Function StandardConfiguratorLaunchParameters(Context)

	LaunchParameters = New Array;
	LaunchParameters.Add("DESIGNER");
	LaunchParameters.Add(KeyConnectionWithBase(Context));

	LaunchParameters.Add("/Out" + UT_StringFunctionsClientServer.WrapInOuotationMarks(Context.InformationFileName));
	If Not IsBlankString(Context.UserName) Then
		LaunchParameters.Add("/N" + UT_StringFunctionsClientServer.WrapInOuotationMarks(Context.UserName));
	EndIf;
	If Not IsBlankString(Context.Password) Then
		LaunchParameters.Add("/P" + UT_StringFunctionsClientServer.WrapInOuotationMarks(Context.Password));
	EndIf;
	LaunchParameters.Add("/WA+");
	If Not IsBlankString(Context.StartPermissionKey) Then
		LaunchParameters.Add("/UC"
			+ UT_StringFunctionsClientServer.WrapInOuotationMarks(Context.StartPermissionKey));
	EndIf;
	If Not IsBlankString(Context.LanguageCode) Then
		LaunchParameters.Add("/L" + Context.LanguageCode);
	EndIf;
	If Not IsBlankString(Context.SessionLanguageCode) Then
		LaunchParameters.Add("/VL" + Context.SessionLanguageCode);
	EndIf;
	LaunchParameters.Add("/DisableStartupMessages");
	LaunchParameters.Add("/DisableStartupDialogs");

	Return LaunchParameters;

EndFunction

//Run and Wait.
// 
// Parameters:
//  CommandContext - см. NewContextConfiguratorCommand
//  Parameters - Array of Строка
//  CallbackDescriptionAboutCompletion - CallbackDescription - 
Procedure RunAndWait(CommandContext, Parameters, CallbackDescriptionAboutCompletion)

	StartString = "";
	StringForLog = "";
	For Each  Parameter In Parameters Do

		StartString = StartString + " " + Parameter;

		If Left(Parameter,2) <> "/P" And Left(Parameter,25) <> "/ConfigurationRepositoryP" Then
			StringForLog = StringForLog + " " + Parameter;
		EndIf;

	EndDo;

	Application = UT_StringFunctionsClientServer.WrapInOuotationMarks(CommandContext.Platform1CPath);

	If Not IsWindows() Then 
		StartString = "sh -c '" + Application + StartString + "'";
	Else
		StartString = Application + StartString;
	EndIf;

	CallbackSettings = New Structure;
	CallbackSettings.Insert("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	Callback = New CallbackDescription("RunAndWaitCompleteExecution", ThisObject, CallbackSettings);

	BeginRunningApplication(Callback, StartString, , True);

EndProcedure


// Start checking capabilities executing commands.
// 
// Parameters:
//  Context - см. NewContextConfiguratorCommand
//  CallbackDescriptionAboutCompletion - CallbackDescription - Описание оповещения о завершении
Procedure StartCheckingCapabilitiesExecutingCommands(Context, CallbackDescriptionAboutCompletion)

	If Not ValueIsFilled(Context.Platform1CPath) Then
		RunCallback(CallbackDescriptionAboutCompletion, False);
		Return;
	EndIf;
	If KeyConnectionWithBase(Context) <> TemporalContextKey(Context) Then
		RunCallback(CallbackDescriptionAboutCompletion, True);
		Return;
	EndIf;

	CallbackSettings = New Structure;
	CallbackSettings.Insert("Context", Context);
	CallbackSettings.Insert("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	StartCheckingTheExistenceOfTemporaryBase(Context,
		New CallbackDescription("StartCheckingCapabilitiesExecutingCommandsFinishCheckingExistenceTemporaryBase",
		ThisObject, CallbackSettings));
	
EndProcedure


#EndRegion
