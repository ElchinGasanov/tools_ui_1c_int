#Region Public

#Region ConfigurationMethodsEvents

Procedure OnStart() Export 
	SessionStartParameters=UT_CommonServerCall.SessionStartParameters();

	If SessionStartParameters.ExtensionRightsAdded Then
		Exit(False, True);
	EndIf;

	UT_ApplicationParameters.Insert("SessionNumber", SessionStartParameters.SessionNumber);
	UT_ApplicationParameters.Insert("ConfigurationScriptVariant", SessionStartParameters.ConfigurationScriptVariant);

	UT_ApplicationParameters.Insert("IsLinuxClient", UT_CommonClientServer.IsLinux());
	UT_ApplicationParameters.Insert("IsWindowsClient", UT_CommonClientServer.IsWindows());
	UT_ApplicationParameters.Insert("IsWebClient", IsWebClient());
	UT_ApplicationParameters.Insert("IsPortableDistribution", UT_CommonClientServer.IsPortableDistribution());
	UT_ApplicationParameters.Insert("HTMLFieldBasedOnWebkit",
		UT_CommonClientServer.HTMLFieldBasedOnWebkit());
	UT_ApplicationParameters.Insert("AppVersion",
		UT_CommonClientServer.CurrentAppVersion());
	//UT_ApplicationParameters.Insert("ConfigurationMetadataDescriptionAdress", UT_CommonServerCall.ConfigurationMetadataDescriptionAdress());
	
	SessionParametersInStorage = New Structure;
	SessionParametersInStorage.Insert("IsLinuxClient", UT_ApplicationParameters["IsLinuxClient"]);
	SessionParametersInStorage.Insert("IsWebClient", UT_ApplicationParameters["IsWebClient"]);
	SessionParametersInStorage.Insert("IsWindowsClient", UT_ApplicationParameters["IsWindowsClient"]);
	SessionParametersInStorage.Insert("IsPortableDistribution", UT_ApplicationParameters["IsPortableDistribution"]);
	SessionParametersInStorage.Insert("HTMLFieldBasedOnWebkit", UT_ApplicationParameters["HTMLFieldBasedOnWebkit"]);
	SessionParametersInStorage.Insert("AppVersion", UT_ApplicationParameters["AppVersion"]);
	//SessionParametersInStorage.Insert("ConfigurationMetadataDescriptionAdress", UT_ApplicationParameters["ConfigurationMetadataDescriptionAdress"]);

	UT_CommonServerCall.CommonSettingsStorageSave(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey(), SessionParametersInStorage);

EndProcedure

#EndRegion

// Displays the text, which users can copy.
//
// Parameters:
//   Handler - NotifyDescription - description of the procedure to be called after showing the message.
//       Returns a value like ShowQuestionToUser().
//   Text - String - an information text.
//   Title - String - Optional. window title. "Details" by default.
//
Procedure ShowDetailedInfo(Handler, Text, Title = Undefined) Export
	DialogSettings = New Structure;
	DialogSettings.Insert("SuggestDontAskAgain", False);
	DialogSettings.Insert("Picture", Undefined);
	DialogSettings.Insert("ShowPicture", False);
	DialogSettings.Insert("CanCopy", True);
	DialogSettings.Insert("DefaultButton", 0);
	DialogSettings.Insert("HighlightDefaultButton", False);
	DialogSettings.Insert("Title", Title);
	
	If Not ValueIsFilled(DialogSettings.Title) Then
		DialogSettings.Title = NStr("ru = 'Подробнее'; en = 'Details'");
	EndIf;
	
	Buttons = New ValueList;
	Buttons.Add(0, NStr("ru = 'Закрыть'; en = 'Close'"));
	
	ShowQuestionToUser(Handler, Text, Buttons, DialogSettings);
EndProcedure

// Show the question form.
//
// Parameters:
//   CompletionNotifyDescription - NotifyDescription - description of the procedures to be called 
//                                                     after the question window is closed with the following parameters:
//                                                     QuestionResult - Structure - a structure with the following properties:
//                                                     	Value - a user selection result: a 
//                                                              system enumeration value or 
//                                                              a value associated with the clicked button. 
//                                                              If the dialog is closed by a timeout - value
//                                                              Timeout.
//                                                      DontAskAgain - Boolean - a user                                                     
//                                                          					 selection result in the check box with the same name.
//                                                     AdditionalParameters - Structure
//   QuestionText - String - a question text.
//   Buttons - QuestionDialogMode, ValueList - a value list may be specified in which:
//                                       Value - contains the value connected to the button and 
//                                                  returned when the button is selected. You can 
//                                                  pass a value of the DialogReturnCode enumeration 
//                                                  or any value that can be XDTO serialized.
//                                                  
//                                       Presentation - sets the button text.
//
//   AdditionalParameters - Structure - see StandardSubsystemsClient.QuestionToUserParameters 
//
//
// Returns:
//   The user selection result is passed to the method specified in the NotifyDescriptionOnCompletion parameter.
//
Procedure ShowQuestionToUser(CompletionNotifyDescription, QuestionText, Buttons,
 	AdditionalParameters = Undefined) Export

	If AdditionalParameters <> Undefined Then
		Parameters = AdditionalParameters;
	Else
		Parameters = New Structure;
	EndIf;

	UT_CommonClientServer.SupplementStructure(Parameters, QuestionToUserParameters(), False);

	ButtonsParameter = Buttons;

	If TypeOf(Parameters.DefaultButton) = Type("DialogReturnCode") Then
		//@skip-warning
		Parameters.DefaultButton = DialogReturnCodeToString(Parameters.DefaultButton);
	EndIf;
	
	If TypeOf(Parameters.TimeoutButton) = Type("DialogReturnCode") Then
		Parameters.TimeoutButton = DialogReturnCodeToString(Parameters.TimeoutButton);
	EndIf;
	
	Parameters.Insert("Buttons",         ButtonsParameter);
	Parameters.Insert("MessageText", QuestionText);
	
	NotifyDescriptionForApplicationRun=CompletionNotifyDescription;
	If NotifyDescriptionForApplicationRun = Undefined Then
		NotifyDescriptionForApplicationRun=ApplicationRunEmptyNotifyDescription();
	EndIf;

	ShowQueryBox(NotifyDescriptionForApplicationRun, QuestionText, ButtonsParameter, , Parameters.DefaultButton, "",
		Parameters.TimeoutButton);

EndProcedure

// Returns a new structure with additional parameters for the ShowQuestionToUser procedure.
//
// Returns:
//  Structure - structure with the following properties:
//    * DefaultButton - Arbitrary - defines the default button by the button type or by the value 
//                                                     associated with it.
//    * Timeout - Number - a period of time in seconds in which the question window waits for user 
//                                                     to respond.
//    * TimeoutButton - Arbitrary - a button (by button type or value associated with it) on which 
//                                                     the timeout remaining seconds are displayed.
//                                                     
//    * Title - String - a question title.
//    * SuggestDontAskAgain - Boolean - if True, a check box with the same name is available in the window.
//    * DontAskAgain - Boolean - a value set by the user in the matching check box.
//                                                     
//    * LockWholeInterface - Boolean - if True, the question window opens locking all other opened 
//                                                     windows including the main one.
//    * Picture - Picture - a picture displayed in the question window.
//
Function QuestionToUserParameters() Export
	
	Parameters = New Structure;
	Parameters.Insert("DefaultButton", Undefined);
	Parameters.Insert("Timeout", 0);
	Parameters.Insert("TimeoutButton", Undefined);
	Parameters.Insert("Title", ClientApplication.GetCaption());
	Parameters.Insert("SuggestDontAskAgain", True);
	Parameters.Insert("DoNotAskAgain", False);
	Parameters.Insert("LockWholeInterface", False);
	Parameters.Insert("Picture", PictureLib.Question32);
	Return Parameters;
	
EndFunction

// Returns String Representation of type DialogReturnCode 
Function DialogReturnCodeToString(Value)

	Result = "DialogReturnCode." + String(Value);

	If Value = DialogReturnCode.Yes Then
		Result = "DialogReturnCode.Yes";
	ElsIf Value = DialogReturnCode.No Then
		Result = "DialogReturnCode.No";
	ElsIf Value = DialogReturnCode.OK Then
		Result = "DialogReturnCode.OK";
	ElsIf Value = DialogReturnCode.Cancel Then
		Result = "DialogReturnCode.Cancel";
	ElsIf Value = DialogReturnCode.Retry Then
		Result = "DialogReturnCode.Retry";
	ElsIf Value = DialogReturnCode.Abort Then
		Result = "DialogReturnCode.Abort";
	ElsIf Value = DialogReturnCode.Ignore Then
		Result = "DialogReturnCode.Ignore";
	EndIf;

	Return Result;

EndFunction

#Region ExecuteAlgorithms

Function ExecuteAlgorithm(AlgorithmRef, IncomingParameters = Undefined, ExecutionError = False,
	ErrorMessage = "") Export
	Return UT_AlgorithmsClientServer.ExecuteAlgorithm(AlgorithmRef, IncomingParameters, ExecutionError,
		ErrorMessage)
EndFunction

#EndRegion

#Region Debug

Procedure OpenDebuggingConsole(DebuggingObjectType, DebuggingData, ConsoleFormUnique = Undefined) Export
	If Upper(DebuggingObjectType) = "QUERY" Then
		ConsoleFormName = "DataProcessor.UT_QueryConsole.Form";
	ElsIf Upper(DebuggingObjectType) = "DATACOMPOSITIONSCHEMA" Then
		ConsoleFormName = "Report.UT_ReportsConsole.Form";
	ElsIf Upper(DebuggingObjectType) = "DATABASEOBJECT" Then
		ConsoleFormName = "DataProcessor.UT_ObjectsAttributesEditor.ObjectForm";
	ElsIf Upper(DebuggingObjectType) = "HTTPREQUEST" Then
		ConsoleFormName = "DataProcessor.UT_HTTPRequestConsole.Form";
	Else
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("DebuggingData", DebuggingData);

	If ConsoleFormUnique = Undefined Then
		Uniqueness = New UUID;
	Else
		Uniqueness = ConsoleFormUnique;
	EndIf;

	OpenForm(ConsoleFormName, FormParameters, , Uniqueness);

EndProcedure

Procedure  RunDebugConsoleByDebugDataSettingsKey(DebugSettingsKey, IsFile, DebuggingObjectType, 
	User = Undefined, FormID = Undefined) Export
	If Not ValueIsFilled(DebugSettingsKey) Then
		Return;
	EndIf;

	If IsFile Then 
		DebuggingObjectAdress = UT_CommonServerCall.DebuggingObjectTempPathFromDebugDataCatalog(DebugSettingsKey, 
			FormID);
	Else 
		DebuggingObjectAdress = UT_CommonServerCall.DebuggingObjectTempPathFromSystemSettingsStorage(DebugSettingsKey, 
			User, 
			FormID);
	EndIf;
	If DebuggingObjectAdress = Undefined Then
		Return;
	EndIf;

	OpenDebuggingConsole(DebuggingObjectType, DebuggingObjectAdress);
EndProcedure


#EndRegion

// This is a web client.
// 
// Returns:
// 	Boolean - This is a web client
Function IsWebClient() Export
	Return UT_CommonClientServer.IsWebClient();
EndFunction


#Region ApplicationsRun

Function ApplicationRunEmptyNotifyDescription() Export
	Return New NotifyDescription("BeginRunningApplicationEndEmpty", ThisObject);
EndFunction

Procedure BeginRunningApplicationEndEmpty(ReturnCode, AdditionalParameters) Export
	If ReturnCode = Undefined Then
		Return;
	EndIf;
EndProcedure

// Begin running the application with attaching file system extension.
// 
// Parameters:
// 	CallbackDescription - CallbackDescription - Contains a description of the procedure that will be called upon completion
// 	CommandString - String - The command string to run the application or the name of a file associated with some application.
// 	CurrentDirectory - Undefined, String - Specifies the current directory of the application to be launched. Ignored in web client mode.
// 	WaitToComplete - Boolean - Wait for the running application to complete before proceeding
Procedure BeginRunningApplicationWithFilesWorkingExt(CallbackDescription, CommandString, CurrentDirectory = Undefined, WaitToComplete = False) Export
	CallbackParameters = New Structure;
	CallbackParameters.Insert("CallbackDescription", CallbackDescription);
	CallbackParameters.Insert("CommandString", CommandString);
	CallbackParameters.Insert("CurrentDirectory", CurrentDirectory);
	CallbackParameters.Insert("WaitToComplete", WaitToComplete);
	
	AttachFileSystemExtensionWithPossibleInstallation(New CallbackDescription("BeginRunningApplicationWithFilesWorkingExtFinalizationAttachingFileSystemExtension", ThisObject, CallbackParameters));	
EndProcedure

// Begin running the application with attaching file system extension (finalize attaching file system extension).
// 
// Parameters:
// 	Result - Boolean - Extension connected successfully
// 	AdditionalParameters - Structure - Callback parameters:
// 		* CallbackParameters - CallbackDescription - Contains a description of the procedure that will be called upon completion
// 		* CommandString - String - The command string to run the application or the name of a file associated with some application.
// 		* CurrentDirectory - Undefined, String - Specifies the current directory of the application to be launched. Ignored in web client mode.
// 		* WaitToComplete - Boolean - Wait for the running application to complete before proceeding
Procedure BeginRunningApplicationWithFilesWorkingExtFinalizationAttachingFileSystemExtension(Result, AdditionalParameters) Export
	If Not Result Then
		Return;
	EndIf;
	
	BeginRunningApplication(AdditionalParameters.CallbackParameters, AdditionalParameters.CommandString, AdditionalParameters.CurrentDirectory, AdditionalParameters.WaitToComplete);
EndProcedure

#EndRegion

#Region TypesEditing

// Opens a special text editing form
// 
// Parameters:
// 	Text - String
// 	CallbackDescriptionOnClose - Undefined - Callback description on close.
// 	Title - String - Title
// 	FormWindowOpeningMode - Undefined - Opening mode
Procedure OpenTextEditingForm(Text, CallbackDescriptionOnClose, Title = "",
	FormWindowOpeningMode = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("Text", Text);
	FormParameters.Insert("Title", Title);

	If FormWindowOpeningMode = Undefined Then
		OpenForm("CommonForm.UT_TextEditingForm", FormParameters, , , , , CallbackDescriptionOnClose);
	Else
		OpenForm("CommonForm.UT_TextEditingForm", 
			FormParameters, 
			, 
			, 
			, 
			, 
			CallbackDescriptionOnClose,
			FormWindowOpeningMode);
	EndIf;
EndProcedure

// Start selecting an enumeration value.
// 
// Parameters:
// 	Value - EnumRefEnumerationName, Type - Value
// 	CallbackDescriptionOnClose - CallbackDescription - Callback description on close
// 	Owner - ClientApplicationForm, FormField - FormOwner
Procedure StartSelectingEnumerationValue(Value, CallbackDescriptionOnClose = Undefined,
	Owner = Undefined) Export
	FormParameters = New Structure;

	If TypeOf(Value) = Type("Type") Then
		FormParameters.Insert("EnumerationType", Value);
	Else
		FormParameters.Insert("EnumerationValue", Value);
	EndIf;

	OpenForm("ОбщаяФорма.УИ_ФормаВыбораЗначенияПеречисления",
				 FormParameters,
				 Owner,
				 String(New UUID),
				 ,
				 ,
				 CallbackDescriptionOnClose);
EndProcedure

// Start editing the UUID.
// 
// Parameters:
// 	Value - Undefined, UUID - Value
// 	CallbackDescriptionOnClose - Undefined, CallbackDescription - Callback description on close
// 	Owner - Undefined, ClientApplicationForm, FormField - FormOwner
Procedure StartEditingUUID(Value = Undefined,
	CallbackDescriptionOnClose = Undefined, Owner = Undefined) Export
	FormParameters = New Structure;

	If Value <> Undefined Then
		FormParameters.Insert("Value", Value);
	EndIf;

	OpenForm("ОбщаяФорма.УИ_РедакторУникальногоИдентификатора",
				 FormParameters,
				 Owner,
				 String(New UUID),
				 ,
				 ,
				 CallbackDescriptionOnClose);
	
EndProcedure

#EndRegion

Procedure OpenValueListChoiceItemsForm(List, OnCloseNotifyDescription, Title = "",
	ItemsType = Undefined, CheckVisible = True, PresentationVisible = True, PickMode = True,
	ReturnOnlySelectedValues = True, WindowOpeningMode = Undefined, AvailableValues = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("List", List);
	FormParameters.Insert("Title", Title);
	FormParameters.Insert("ReturnOnlySelectedValues", ReturnOnlySelectedValues);
	FormParameters.Insert("CheckVisible", CheckVisible);
	FormParameters.Insert("PresentationVisible", PresentationVisible);
	FormParameters.Insert("PickMode", PickMode);
	If ItemsType <> Undefined Then
		FormParameters.Insert("ItemsType", ItemsType);
	EndIf;
	If AvailableValues <> Undefined Then
		FormParameters.Insert("AvailableValues", AvailableValues);
	Endif;

	If WindowOpeningMode = Undefined Then
		OpenForm("CommonForm.UT_ValueListEditingForm", FormParameters, , , , ,
			OnCloseNotifyDescription);
	Else
		OpenForm("CommonForm.UT_ValueListEditingForm", FormParameters, , , , ,
			OnCloseNotifyDescription, WindowOpeningMode);
	EndIf;
EndProcedure

Procedure EditObject(ObjectRef) Export
	AvailableForEditingObjectsArray=UT_CommonClientCached.DataBaseObjectEditorAvailableObjectsTypes();
	If AvailableForEditingObjectsArray.Find(TypeOf(ObjectRef)) = Undefined Then
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("mObjectRef", ObjectRef);

	OpenForm("DataProcessor.UT_ObjectsAttributesEditor.Form", FormParameters);
EndProcedure

Procedure EditJSON(JSONString, ViewMode, OnEndNotifyDescription = Undefined) Export
	Parameters=New Structure;
	Parameters.Insert("JSONString", JSONString);
	Parameters.Insert("ViewMode", ViewMode);

	If OnEndNotifyDescription = Undefined then
		OpenForm("DataProcessor.UT_JSONEditor.Form", Parameters);
	else
		OpenForm("DataProcessor.UT_JSONEditor.Form", Parameters, , , , , OnEndNotifyDescription);
	Endif;
EndProcedure

Procedure ОpenDynamicList(MetadataObjectName, OnEndNotifyDescription = Undefined) Export
	ParametersStructure = New Structure("MetadataObjectName", MetadataObjectName);

	If OnEndNotifyDescription = Undefined Then
		OpenForm("DataProcessor.UT_DynamicList.Form", ParametersStructure, , MetadataObjectName);
	Else
		OpenForm("DataProcessor.UT_DynamicList.Form", ParametersStructure, , MetadataObjectName, , ,
			OnEndNotifyDescription);
	EndIf;

EndProcedure

Procedure FindObjectRefs(ObjectRef) Export
	FormParameters=New Structure;
	FormParameters.Insert("SearchObject", ObjectRef);

	OpenForm("DataProcessor.UT_ObjectReferencesSearch.Form", FormParameters);

EndProcedure

Procedure AskQuestionToDeveloper() Export
	BeginRunningApplication(ApplicationRunEmptyNotifyDescription(),
		"https://github.com/i-neti/tools_ui_1c_int/issues");

EndProcedure

Procedure OpenAboutPage() Export
	BeginRunningApplication(ApplicationRunEmptyNotifyDescription(), "https://github.com/i-neti/tools_ui_1c_int");

EndProcedure

Procedure OpenPortableToolsDebugSpecificityPage () Export
	BeginRunningApplication(ApplicationRunEmptyNotifyDescription(),
		"https://github.com/cpr1c/tools_ui_1c/wiki/Portable-Tools-Debug-Specificity");

EndProcedure

Procedure RunToolsUpdateCheck() Export
	FormParameters = New Structure;;
	OpenForm("DataProcessor.UT_Support.Form.UpdateTools", FormParameters);
EndProcedure

Procedure OpenNewToolForm(SourceForm)
	OpenForm(SourceForm.FormName, , , New UUID, , , , FormWindowOpeningMode.Independent);
EndProcedure

Procedure CompareSpreadsheetDocumentsFiles(FilePath1, FilePath2, LeftTitle = "Left", RightTitle = "Right") Export

	FilesToBePlaced = New Array;
	FilesToBePlaced.Add(New TransferableFileDescription(FilePath1));
	FilesToBePlaced.Add(New TransferableFileDescription(FilePath2));
	PlacedFiles = New Array;
	If Not PutFiles(FilesToBePlaced, PlacedFiles, , False) Then
		Return;
	EndIf;
	LeftSpreadsheetDocument  = PlacedFiles[0].Location;
	RightSpreadsheetDocument = PlacedFiles[1].Location;

	CompareSpreadsheetDocuments(LeftSpreadsheetDocument, RightSpreadsheetDocument, LeftTitle, RightTitle);

EndProcedure

Procedure CompareSpreadsheetDocuments(SpreadsheetDocumentAddressInTempStorage1,
	SpreadsheetDocumentAddressInTempStorage2, LeftTitle = "Left", RightTitle = "Right") Export

	SpreadsheetDocumentsStructure = New Structure("Left, Right", SpreadsheetDocumentAddressInTempStorage1,
		SpreadsheetDocumentAddressInTempStorage2);
	SpreadsheetDocumentsAddress = PutToTempStorage(SpreadsheetDocumentsStructure, Undefined);

	FormOpenParameters = New Structure("SpreadsheetDocumentsAddress, LeftTitle, RightTitle",
		SpreadsheetDocumentsAddress, LeftTitle, RightTitle);
	OpenForm("CommonForm.UT_SpreadsheetDocumentsComparison", FormOpenParameters, ThisObject);

EndProcedure

Function OpenInformationForSupportService() Export
	Info = InformationForSupportService();
	
	OutputString = InformationForSupportServiceAsString(Info);
	
    OpenTextEditingForm(OutputString,Undefined ,NStr("ru = 'Информация для тех поддержки';en = 'Information for Support Service'", ));
EndFunction

#Region ToolsAttachableCommandMethods

Procedure Attachable_ExecuteToolsCommonCommand(Form, Command) Export
	If Command.Name = "UT_OpenNewToolForm" Then
		OpenNewToolForm(Form);
	Endif;

EndProcedure

#EndRegion

#Region SSLCommands

Procedure AddObjectsToComparison(ObjectsArray, Context) Export
	UT_CommonClientServer.AddObjectsArrayToCompare(ObjectsArray);
EndProcedure

Procedure UploadObjectsToXML(ObjectsArray, Context) Export
	FileURLInTempStorage="";
	UT_CommonServerCall.UploadObjectsToXMLonServer(ObjectsArray, FileURLInTempStorage,
		Context.Form.UUID);

	If IsTempStorageURL(FileURLInTempStorage) Then
		FileName="Uploading file.xml";
		GetFile(FileURLInTempStorage, FileName);
	EndIf;

EndProcedure

Procedure EditObjectCommandHandler(ObjectRef, Context) Export
	EditObject(ObjectRef);
EndProcedure

Procedure FindObjectRefsCommandHandler(ObjectRef, Context) Export
	FindObjectRefs(ObjectRef);
EndProcedure

Procedure OpenAdditionalDataProcessorDebugSettings(ObjectRef) Export
	FormParameters=New Structure;
	FormParameters.Insert("AdditionalDataProcessor", ObjectRef);

	OpenForm("CommonForm.UT_AdditionalDataProcessorDebugSettings", FormParameters);
EndProcedure

#EndRegion
#Region TypesEditingAndVariables

#Region TypesEditingParameters

// New parameters of value table editing
//
// Returns:
//  Structure - New parameters of value table editing:
//  	* SerializeToXML - boolean - If TRUE, then the string presentation of VT wiil be computed with UT_Common.ValueFromXMLString and UT_Common.ValueToXMLString.
// 								     If FALSE, then with platform methods ValueToStringInternal and ValueFromStringInternal
// 		* ReadOnly - boolean - if true table will open to readonly ( only view)
Function ValueTableNewEditingParameters() Export
	Structure = New Structure;
	Structure.Insert("SerializeToXML", False);
	Structure.Insert("ReadOnly", False);
	
	Return Structure;
EndFunction

// New parameters of value list editing.
// 
// Returns:
// 	Structure - New parameters of value list editing:
// * Title - String. 
// * ReturnOnlySelectedValues - Boolean - 
// * ElementsType - Undefined, TypeDescription, String - 
// * DeletionMarkVisible - Boolean - 
// * PresentationVisible - Boolean - 
// * ChoiceMode - Boolean -
// * AvailableValues - Undefined, ValueList of Arbitrary -
// * OpeningMode - Undefined, FormWindowOpeningMode - 
Function ValueListNewEditingParameters() Export
	EditParameters = New Structure;
	EditParameters.Insert("Title", "");
	EditParameters.Insert("ReturnOnlySelectedValues", True);
	EditParameters.Insert("ElementsType", Undefined);
	EditParameters.Insert("DeletionMarkVisible", True);
	EditParameters.Insert("PresentationVisible", True);
	EditParameters.Insert("ChoiceMode", True);
	EditParameters.Insert("AvailableValues", Undefined);
	EditParameters.Insert("OpeningMode", Undefined);
	
	Return EditParameters;	
EndFunction


#EndRegion

// Procedure - Edit type
//
// Parameters:
//  DataType					 - TypeDescription , Undefined -  Current value type
//  StartMode					 - Number - type editor start mode
// 0- selection of stored types
// 1- type for query
// 2- type for field DCS
// 3- type for parameter DCS 
// 4-Reference types without composite types
//  StandardProcessing			 - Boolean - StartChoise event standard processing
//  FormOwner					 - 
//  CallbackDescriptionOnClose	 - CallbackDescription
//
Procedure EditType(DataType, StartMode, StandardProcessing, FormOwner, CallbackDescriptionOnClose,
	TypesSet=Undefined) Export
	StandardProcessing=False;

	FormParameters=New Structure;
	FormParameters.Insert("DataType", DataType);
	If TypesSet = Undefined Then
		FormParameters.Insert("StartMode", StartMode);
	Else
		FormParameters.Insert("TypesSet", TypesSet);
	EndIf;
	OpenForm("CommonForm.UT_ValueTypeEditor", 
		FormParameters, 
		FormOwner, 
		, 
		, 
		, 
		CallbackDescriptionOnClose,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

// Edit type as container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure SelectValueTypeAsContainerStorageType(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export
	
	FormParameters = New Structure;
	FormParameters.Insert("ContainerValuesType", ContainerValues);
	FormParameters.Insert("TypeSet", UT_CommonClientServer.AllEditingTypeSets());
	FormParameters.Insert("CompositeTypeAvailable", False);
	FormParameters.Insert("ChoiceMode", True);
	OpenForm("CommonForm.UT_ValueTypeEditor",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose,
				 FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

// Edit type as type description container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditValueTypeAsContainerStoreDescriptionType(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export
	
	FormParameters=New Structure;
	FormParameters.Insert("ContainerValuesDescriptionType", ContainerValues);
	FormParameters.Insert("TypeSet", UT_CommonClientServer.AllEditingTypeSets());
	OpenForm("CommonForm.UT_ValueTypeEditor",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose,
				 FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

// Edit value table
//
// Parameters:
//  ValueTableAsString - String - Value table string presentation
//  FormOwner - ClientApplicationForm - 
//  OnEndNotifyDescription - NotifyDescription - Will be executed on end
//  EditingParameters - See ValueTableNewEditingParameters
Procedure EditValueTable(ValueTableAsString, FormOwner,
	OnEndNotifyDescription = Undefined, EditingParameters = Undefined) Export
	FormParameters=New Structure;
	FormParameters.Insert("ValueTableAsString", ValueTableAsString);
	If EditingParameters <> Undefined Then
		For Each KeyValue In EditingParameters Do
			FormParameters.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;

	OpenForm("CommonForm.UT_ValueTableEditor", FormParameters, FormOwner, , , ,
		OnEndNotifyDescription);
EndProcedure

// Edit the value table as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageValueTableType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditValueTableAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export
	
	FormParameters=New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("CommonForm.UT_ValueTableEditor",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
EndProcedure

// Edit the value tree as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageValueTreeType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditValueTreeAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters=New Structure;
	FormParameters.Insert("ContainerValuesTree", ContainerValues);

	OpenForm("CommonForm.UT_ValueTableEditor",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
EndProcedure

// Edit spreadsheet document.
// 
// Parameters:
// SpreadsheetDocument - SpreadsheetDocument
// FormTitle - String - Form Title
// CallbackDescriptionOnClose - Undefined, CallbackDescription -
// FormOwner - Undefined, ClientApplicationForm, FormField - 
Procedure EditSpreadsheetDocument(SpreadsheetDocument, FormTitle, CallbackDescriptionOnClose
	, FormOwner = Undefined) Export
	
	FormParameters = New Structure;
	FormParameters.Insert("DocumentName", FormTitle);
	FormParameters.Insert("SpreadsheetDocument", SpreadsheetDocument);
	FormParameters.Insert("Edit", True);

	OpenForm("CommonForm.UT_SpreadsheetDocumentEditor", FormParameters, , , , , CallbackDescriptionOnClose);
	
EndProcedure

// Edit spreadsheet as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageSpreadsheetDocumentType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditSpreadsheetDocumentAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);
	FormParameters.Insert("Edit", True);

	OpenForm("CommonForm.UT_SpreadsheetDocumentEditor",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);

EndProcedure

// Edit point in time type.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStoragePointInTimeType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditPointInTimeType(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export
	
	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторМоментаВремени",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);

EndProcedure

// Edit boundary type.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageBoundaryType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditBoundaryType(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторГраницы",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);

EndProcedure

// Edit structure type.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageStructureType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditStructureType(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторСтруктуры",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit map type.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageMapType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditMapType(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторСоответствия",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit value storage type.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageValueStorageType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditValueStorageTypeAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторХранилищаЗначения",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit value storage type.
// 
// Parameters:
// 	ValueStorage - ValueStorage
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditValueStorageType(ValueStorage, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ValueStorage);

	OpenForm("ОбщаяФорма.УИ_РедакторХранилищаЗначения",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit value list as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStoreValueListTypeValueList
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditValueListAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_ФормаСпискаЗначений",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit array as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageArrayType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditArrayAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValuesArray", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_ФормаСпискаЗначений",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit picture.
// 
// Parameters:
// 	Picture - Picture
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditPicture(Picture, CallbackDescriptionOnClose, FormOwner = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("Picture", Picture);

	OpenForm("ОбщаяФорма.УИ_РедакторКартинки",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);
		
EndProcedure

// Edit picture as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStoragePictureType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditPictureAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторКартинки",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);

EndProcedure

// Edit binary data as a container store.
// 
// Parameters:
// 	ContainerValues - see UT_CommonClientServer.NewValueStorageBinaryDataType
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - Form Owner
Procedure EditBinaryDataAsContainerStorage(ContainerValues, CallbackDescriptionOnClose,
	FormOwner = Undefined) Export

	FormParameters = New Structure;
	FormParameters.Insert("ContainerValues", ContainerValues);

	OpenForm("ОбщаяФорма.УИ_РедакторДвоичныхДанных",
				 FormParameters,
				 FormOwner,
				 ,
				 ,
				 ,
				 CallbackDescriptionOnClose);

EndProcedure

// Begin selecting ref to edit specific value.
// 
// Parameters:
// 	Value - Arbitrary - Value
// 	CallbackDescriptionOnClose - CallbackDescription
// 	FormOwner - Undefined, ClientApplicationForm, FormField - 
// 	ContainerValue - see UT_CommonClientServer.NewValueContainer
// 	UseDynamicListForSelectingRefValue - Boolean
// 	StandardProcessing - Boolean
Procedure BeginSelectingRefEditSpecificValue(Value, CallbackDescriptionOnClose, FormOwner,
	ContainerValue = Undefined, UseDynamicListForSelectingRefValue = False,
	StandardProcessing = True) Export
	If ContainerValue <> Undefined Then
		StandardProcessing = False;
		
		ContainerTypes = UT_CommonClientServer.ContainerValuesTypes();		
		
		If ContainerValue.Type = ContainerTypes.Boundary then
			EditBoundaryType(ContainerValue.ValueStorage, CallbackDescriptionOnClose, FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.PointInTime Then
			EditPointInTimeType(ContainerValue.ValueStorage, CallbackDescriptionOnClose, FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.ValueTable Then
			EditValueTableAsContainerStorage(ContainerValue.ValueStorage,
											 CallbackDescriptionOnClose, 
											 FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.ValueTree Then
			EditValueTreeAsContainerStorage(ContainerValue.ValueStorage,
											CallbackDescriptionOnClose, 
											FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.Type Then
			SelectValueTypeAsContainerStorageType(ContainerValue.ValueStorage,
											CallbackDescriptionOnClose, 
											FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.TypeDescription Then
			EditValueTypeAsContainerStoreDescriptionType(ContainerValue.ValueStorage,
											CallbackDescriptionOnClose, 
											FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.Structure 
			Or ContainerValue.Type = ContainerTypes.FixedStructure Then
			EditStructureType(ContainerValue.ValueStorage, CallbackDescriptionOnClose, FormOwner);	
		ElsIf ContainerValue.Type = ContainerTypes.Map 
			Or ContainerValue.Type = ContainerTypes.FixedMap Then
			EditMapType(ContainerValue.ValueStorage, CallbackDescriptionOnClose, FormOwner);	
		ElsIf ContainerValue.Type = ContainerTypes.SpreadsheetDocument Then
			EditSpreadsheetDocumentAsContainerStorage(ContainerValue.ValueStorage, 
													  CallbackDescriptionOnClose, 
													  FormOwner);	
		ElsIf ContainerValue.Type = ContainerTypes.ValueStorage Then
			EditValueStorageTypeAsContainerStorage(ContainerValue.ValueStorage, 
												   CallbackDescriptionOnClose, 
												   FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.ValueList Then
			EditValueListAsContainerStorage(ContainerValue.ValueStorage, 
											CallbackDescriptionOnClose, 
											FormOwner);	
		ElsIf ContainerValue.Type = ContainerTypes.Array 
			Or ContainerValue.Type = ContainerTypes.FixedArray Then
			EditArrayAsContainerStorage(ContainerValue.ValueStorage, 
										CallbackDescriptionOnClose, 
										FormOwner);
		ElsIf ContainerValue.Type = ContainerTypes.Picture Then
			EditPictureAsContainerStorage(ContainerValue.ValueStorage, 
										  CallbackDescriptionOnClose, 
										  FormOwner);	
		ElsIf ContainerValue.Type = ContainerTypes.BinaryData Then
			EditBinaryDataAsContainerStorage(ContainerValue.ValueStorage, 
										  	 CallbackDescriptionOnClose, 
										  	 FormOwner);
		EndIf;
	Else
		ValueType = TypeOf(Value);
		If ValueType = Type("String") Then
			OpenTextEditingForm(Value, CallbackDescriptionOnClose);
		ElsIf ValueType = Type("ValueStorage") Then
			EditValueStorageType(Value, CallbackDescriptionOnClose, FormOwner);
		ElsIf UT_CommonServerCall.ThisEnumerationByType(ValueType) Then
			StandardProcessing = False;
			StartSelectingEnumerationValue(Value, CallbackDescriptionOnClose, FormOwner);
		ElsIf UT_Common.IsReference(ValueType) Then
			StandardProcessing = False;
			ObjectName = UT_Common.TableNameByRef(ValueType);	
			If UseDynamicListForSelectingRefValue Then
				FormParameters = New Structure;
				FormParameters.Insert("MetaDataObjectName", ObjectName);
				FormParameters.Insert("ChoiceMode", True);
				
				OpenForm("DataProcessor.UT_DynamicList.Form", FormParameters, FormOwner);
			Else
				OpenForm(ObjectName + ".ChoiceForm", , FormOwner);
			EndIf;
			
		ElsIf ValueType = Type("UUID") Then
			StartEditingUUID(Value, CallbackDescriptionOnClose);
		EndIf;
			
	EndIf;
EndProcedure
																   
#EndRegion

#Region ContainerValuesStoredOnForm



#EndRegion

#Region FormItemsEvents

// New form processors events base parameters.
// 
// Parameters:
// 	Form - ClientApplicationForm - Form
// 	Element - FormField - Element
// 	FieldName - String - Field name in form structure
// 
// Returns:
// Structure - New form field events processor base parameters:
// * Form - ClientApplicationForm
// * Element -FormField - Element
// * AvailableContainer - Boolean - 
// * StructureValueStorage - Undefined, ClientApplicationForm, FormDataStructure, FormDataTreeItem, FormDataCollectionItem -  
// * FieldNameStructure - String - 
// * ContainerFieldName - String, Undefined - 
// * FieldNameValueType - String, Undefined - 
// * FieldNamePresentationValueType - String, Undefined - 
// * CurrentDescriptionValueTypes - Undefined, TypeDescription - 
Function NewFormProcessorsEventsBaseParameters(Form, Element, FieldName) Export
	ProcessorParameters = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer(FieldName);
	ProcessorParameters.Insert("Form", Form);
	ProcessorParameters.Insert("Element", Element);
	ProcessorParameters.Insert("AvailableContainer", False);
	ProcessorParameters.Insert("StructureValueStorage", Undefined);
	ProcessorParameters.Insert("CurrentDescriptionValueTypes", Undefined);

	Return ProcessorParameters;
EndFunction

// New processor value choice starting events.
// 
// Parameters:
// 	Form - ClientApplicationForm - Form
// 	Element - FormField - Element
// 	FieldName - String - Field name in form structure
// 
// Returns:
// Structure - New processor value choice starting events:
// * Form - ClientApplicationForm
// * Element -FormField - Element 
// * StructureValueStorage - Undefined, ClientApplicationForm, FormDataStructure, FormDataTreeItem, FormDataCollectionItem -  
// * FieldNameStructure - String - 
// * ContainerFieldName - String, Undefined - 
// * FieldNameValueType - String, Undefined - 
// * FieldNamePresentationValueType - String, Undefined - 
// * AvailableContainer - Boolean -
// * Value - Undefined, Arbitrary -
// * CurrentDescriptionValueTypes - Undefined, TypeDescription -
// * TypesSet - String, Undefined -
// * CallBackEmptyValueChoiceNotifications - Undefined, TypeDescription -
// * CallBackTypeChoiceNotifications - Undefined, TypeDescription -
// * CallBackChoiceNotificationsEnding - Undefined, TypeDescription - 
Function NewProcessorValueChoiceStartingEvents(Form, Element, FieldName) Export
	ProcessorParameters = NewFormProcessorsEventsBaseParameters(Form, Element, FieldName);
	ProcessorParameters.Insert("Value", Undefined);
	ProcessorParameters.Insert("TypesSet", Undefined);
	ProcessorParameters.Insert("CallBackEmptyValueChoiceNotifications", Undefined);
	ProcessorParameters.Insert("CallBackTypeChoiceNotifications", Undefined);
	ProcessorParameters.Insert("CallBackChoiceNotificationsEnding", Undefined);

	Return ProcessorParameters;
EndFunction
 
// New processor clearing events parameters.
// 
// Parameters:
// 	Form - ClientApplicationForm - Form
// 	Element - FormField - Element
// 	FieldName - String - Field name in form structure
// 
// Returns:
// 	Structure - see NewFormProcessorsEventsBaseParameters
Function NewProcessorClearingEventsParameters(Form, Element, FieldName) Export
	ProcessorParameters = NewFormProcessorsEventsBaseParameters(Form, Element, FieldName);
	
	Return ProcessorParameters;
	
EndFunction

// New processor in changing events parameters.
// 
// Parameters:
// 	Form - ClientApplicationForm - Form
// 	Element - FormField - Element
// 	FieldName - String - Field name in form structure
// 
// Returns:
// 	Structure - see NewFormProcessorsEventsBaseParameters
Function NewProcessorInChangingEventsParameters(Form, Element, FieldName) Export
	ProcessorParameters = NewFormProcessorsEventsBaseParameters(Form, Element, FieldName);
	
	Return ProcessorParameters;
	
EndFunction

// New processor clearing events.
// 
// Parameters:
// 	ProcessorParameters - see NewProcessorClearingEventsParameters
// 	StandardProcessing - Boolean - 
Procedure FormFieldClear(ProcessorParameters, StandardProcessing) Export
	// Item.TypeRestriction = New TypeDescription;
	
	NewValue = Undefined;
	If ProcessorParameters.CurrentDescriptionValueTypes <> Undefined Then
		// NewTypeDescription = ProcessorParameters.CurrentDescriptionValueTypes
		NewValue = UT_CommonClientServer.EmptyTypeValue(ProcessorParameters.CurrentDescriptionValueTypes);
	EndIf;
	
	If ProcessorParameters.AvailableContainer Then
		UT_CommonClientServer.SetContainerFieldValue(ProcessorParameters.StructureValueStorage,
													 ProcessorParameters,
													 NewValue);
	Else
		ProcessorParameters.Element.TypeRestriction = New TypeDescription;
		
		ProcessorParameters.StructureValueStorage[ProcessorParameters.FieldNameStructure] = NewValue;
	EndIf;
	
EndProcedure

// New processor in changing events.
// 
// Parameters:
// 	ProcessorParameters - see NewProcessorInChangingEventsParameters
Procedure FormFieldInChangeProcessor(ProcessorParameters) Export
	If Not ProcessorParameters.AvailableContainer Then
		Return;
	EndIf;
	
	ContainerValue = ProcessorParameters.StructureValueStorage[ProcessorParameters.ContainerFieldName];
	If ContainerValue = Undefined Then
		Return;
	EndIf;
	
	ProcessorParameters.StructureValueStorage[ProcessorParameters.FieldNameStructure] = ContainerValue.Presentation;
EndProcedure

// New processor value choice starting events.
// 
// Parameters:
// 	ProcessorParameters - see NewProcessorValueChoiceStartingEvents
// 	StandardProcessing - Boolean - 
Procedure FormFieldValueStartChoiceProcessor(ProcessorParameters, StandardProcessing) Export
	Value = ProcessorParameters.StructureValueStorage[ProcessorParameters.FieldNameStructure];
	ContainerValue = Undefined;
	
	If ProcessorParameters.AvailableContainer Then
		ContainerValue = ProcessorParameters.StructureValueStorage[ProcessorParameters.ContainerFieldName];
	EndIf;
	If ProcessorParameters.AvailableContainer And ContainerValue <> Undefined Then
		CallBackChoiceEndingNotifications = New NotifyDescription("FormFieldValueStartChoiceProcessorValueChoiceEnding", 
			ThisObject, ProcessorParameters);
	BeginSelectingRefEditSpecificValue(Value
		, CallBackChoiceEndingNotifications
		, ProcessorParameters.Element
		, ContainerValue
		,
		, StandardProcessing);
		
	ElsIf Value = Undefined Then
		StandardProcessing = False;
		
		CallBackTypeChoiceNotifications = New NotifyDescription("FormFieldValueStartChoiceProcessorTypeChoiceEnding"
			, ThisObject, ProcessorParameters);
			
		FormParameters = New Structure;
		FormParameters.Insert("CompositeTypeAvailable", False);
		FormParameters.Insert("ChoiceMode", True);
		IF ProcessorParameters.TypesSet = Undefined Then
			FormParameters.Insert("TypesSet", "Refs, Primitive, UUID");
		Else
			FormParameters.Insert("TypesSet", ProcessorParameters.TypesSet);
		Endif;

		If ProcessorParameters.CurrentDescriptionValueTypes <> Undefined Then
			TypesArray = ProcessorParameters.CurrentDescriptionValueTypes.Types();
			If TypesArray.Count() = 1 Then
				ChosenTypes = New Structure;
				ChosenTypes.Insert("Description", ProcessorParameters.CurrentDescriptionValueTypes);
				ChosenTypes.Insert("UseDynamicListForSelectingRefValue", False);
				
				ExecuteNotifyProcessing(CallBackTypeChoiceNotifications, ChosenTypes);
				Return;
			EndIf;
			
			FormParameters.Insert("TypeRestriction", ProcessorParameters.CurrentDescriptionValueTypes);
		EndIf;
		
		
		OpenForm("CommonForm.UT_ValueTypeEditor"
			, FormParameters
			, ProcessorParameters.Element
			, 
			, 
			, 
			, CallBackTypeChoiceNotifications
			, FormWindowOpeningMode.LockOwnerWindow);
	Else//If Item.TypeRestriction <> New TypeDescription Then
		CallBackTypeChoiceNotifications = New NotifyDescription("FormFieldValueStartChoiceProcessorValueChoiceEnding",
			ThisObject, ProcessorParameters);
		BeginSelectingRefEditSpecificValue(Value
			, CallBackTypeChoiceNotifications
			, ProcessorParameters.Element
			, 
			,
			, StandardProcessing);
	EndIf;
	
EndProcedure

// New processor value choice starting events parameters type choice ending.
// 
// Parameters:
// 	Result - Structure
// 	* Description - TypeDescription -
// 	* UseDynamicListForSelectingRefValueProcessing - Boolean -
// 	AdditionalParameters - see NewProcessorValueChoiceStartingEvents
Procedure FormFieldValueStartChoiceProcessorTypeChoiceEnding(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	If Result.Description.Types().Count() = 0 Then
		Return;
	EndIf;

	AdditionalParameters.Form.Modified = True;
	
	ValueType = Result.Description.Types()[0];
	
	FieldNameValueType = AdditionalParameters.FieldNameValueType;
	FieldNamePresentationValueType = AdditionalParameters.FieldNamePresentationValueType;
	ContainerFieldName = AdditionalParameters.ContainerFieldName;
	
	StoringInContainer = UT_CommonClientServer.TypeStoringInContainer(ValueType);
	
	If StoringInContainer And Not AdditionalParameters.AvailableContainer Then
		UT_CommonClientServer.MessageToUser(NStr("ru = 'Данное поле не поддерживает данный тип'; en = 'Field does not support this type'"));
		Return;
	EndIf;
	
	// AdditionalParameters.CurrentDescriptionValueTypes = Result.Description;
	
	EmptyValueTypeDescription = Result.Description;
	
	If AdditionalParameters.AvailableContainer Then
	
		If StoringInContainer Then
			AdditionalParameters.StructureValueStorage[FieldNameValueType] = UT_CommonClientServer.DescriptionTypeString(100);
			
			AdditionalParameters.StructureValueStorage[ContainerFieldName] = UT_CommonClientServer.NewValueContainerByType(ValueType);
		
		Else
			AdditionalParameters.StructureValueStorage[FieldNameValueType] = Result.Description;
			
		EndIf;
		EmptyValueTypeDescription = AdditionalParameters.StructureValueStorage[FieldNameValueType];
		
		AdditionalParameters.StructureValueStorage[FieldNamePresentationValueType] = String(Result.Description);
	Else
		AdditionalParameters.Element.TypeRestriction = EmptyValueTypeDescription;
	EndIf;
			
	EmptyTypeValue = UT_CommonClientServer.EmptyTypeValue(ValueType, StoringInContainer);
	AdditionalParameters.StructureValueStorage[AdditionalParameters.FieldNameStructure] = EmptyTypeValue;
		
	If ValueType = Type("Number") 
		Or ValueType = Type("String")  
		Or ValueType = Type("Date")  
		Or ValueType = Type("Boolean") Then 
		Return;
	EndIf;

	CallBackChoiceNotificationsEnding = New NotifyDescription("FormFieldValueStartChoiceProcessorValueChoiceEnding"
		, ThisObject, AdditionalParameters);
	
	If AdditionalParameters.AvailableContainer Then
		BeginSelectingRefEditSpecificValue(EmptyTypeValue
			, CallBackChoiceNotificationsEnding
			, AdditionalParameters.Element
			, AdditionalParameters.StructureValueStorage[ContainerFieldName]
			, Result.UseDynamicListForSelectingRefValue);		
	Else
		BeginSelectingRefEditSpecificValue(EmptyTypeValue
			, CallBackChoiceNotificationsEnding
			, AdditionalParameters.Element
			, 
			, Result.UseDynamicListForSelectingRefValue);
	EndIf;


EndProcedure

// New processor value choice starting events parameters value choice ending.
// 
// Parameters:
// 	Result - Arbitrary, Undefined -
// 	AdditionalParameters - see NewProcessorValueChoiceStartingEvents
Procedure FormFieldValueStartChoiceProcessorValueChoiceEnding(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	AdditionalParameters.Form.Modified = True;
	
	ContainerFieldName = AdditionalParameters.ContainerFieldName;
	
	If AdditionalParameters.AvailableContainer Then
		CurrentContainerValue = AdditionalParameters.StructureValueStorage[ContainerFieldName]; // see UT_CommonClientServer.NewValueContainer
		If CurrentContainerValue <> Undefined Then
			CurrentContainerValue.ValueStorage = Result;
			UT_CommonClientServer.SetContainerPresentation(CurrentContainerValue);
			
			AdditionalParameters.StructureValueStorage[AdditionalParameters.FieldNameStructure] = CurrentContainerValue.Presentation;
		Else
			AdditionalParameters.StructureValueStorage[AdditionalParameters.FieldNameStructure] = Result;
		EndIf;
	Else
		AdditionalParameters.StructureValueStorage[AdditionalParameters.FieldNameStructure] = Result;
	EndIf;
	
	If TypeOf(AdditionalParameters.CallBackChoiceNotificationsEnding) = Type("NotifyDescription") Then
		ExecuteNotifyProcessing(AdditionalParameters.CallBackChoiceNotificationsEnding);
	EndIf;
EndProcedure


Procedure FormFieldFileNameStartChoice (FileDescriptionStructure, Item, ChoiseData, StandardProcessing,
	DialogMode, OnEndNotifyDescription) Export
	StandardProcessing=False;

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("Item", Item);
	NotifyAdditionalParameters.Insert("FileDescriptionStructure", FileDescriptionStructure);
	NotifyAdditionalParameters.Insert("DialogMode", DialogMode);
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);

	AttachFileSystemExtensionWithPossibleInstallation(New NotifyDescription("FormFieldFileNameStartChoiceEndAttachFileSystemExtension",
		ThisObject, NotifyAdditionalParameters));
EndProcedure

Procedure FormFieldFileNameStartChoiceEndAttachFileSystemExtension(Connected,
	AdditionalParameters) Export
	FileChoise = FileSelectionDialogByDescriptionStructureOfSelectedFile(AdditionalParameters.DialogMode,
		AdditionalParameters.FileDescriptionStructure);
	FileChoise.Show(AdditionalParameters.OnEndNotifyDescription);
EndProcedure

#EndRegion

#Region ToolsAssistiveLibraries

Procedure SaveAssistiveLibrariesAtClientOnStart() Export
	LibrariesDirectory=UT_AssistiveLibrariesDirectory();
	
	//1. Clear directory . it's separate for each database 
	Message(LibrariesDirectory);
EndProcedure

// Assistive libraries directory
// 
// Return type:
//  String - Assistive libraries directory
Function UT_AssistiveLibrariesDirectory() Export
	FileVariablesStructure=SessionFileVariablesStructure();
	If Not FileVariablesStructure.Property("UserDataWorkingDirectory") Then
		Return "";
	EndIf;
	
	Return UT_CommonClientServer.SatelliteLibrariesCatalog(
		FileVariablesStructure.UserDataWorkingDirectory);
EndFunction


#EndRegion

#Region ValueStorage

Procedure EditValueStorage(Form, ValueTempStorageUrlOrValue,
	NotifyDescription = Undefined) Export

	If NotifyDescription = Undefined Then
		NotifyDescriptionParameters = New Structure;
		NotifyDescriptionParameters.Insert("Form", Form);
		NotifyDescriptionParameters.Insert("ValueTempStorageUrlOrValue",
			ValueTempStorageUrlOrValue);
		OnCloseNotifyDescription = New NotifyDescription("EditWriteSettingsOnEnd", ThisObject,
			NotifyDescriptionParameters);
	Else
		OnCloseNotifyDescription = NotifyDescription;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("ValueStorageData", ValueTempStorageUrlOrValue);

	OpenForm("CommonForm.UT_ValueStorageForm"
		, FormParameters
		, Form
		, Form.UUID
		, 
		, 
		, OnCloseNotifyDescription
		, FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

Procedure EditValueStorageOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	//	Form=AdditionalParameters.Form;
EndProcedure

#EndRegion

#Region WriteSettings

Procedure EditWriteSettings(Form) Export
	FormParameters = New Structure;
	FormParameters.Insert("WriteSettings", UT_CommonClientServer.FormWriteSettings(Form));
	
	If Form.FormName ="DataProcessor.UT_ObjectsAttributesEditor.Form.ObjectForm" Then
		TypeArray = New Array;
		TypeArray.Add(TypeOf(Form.mObjectRef));
		
		FormParameters.Insert("ObjectType", New TypeDescription(TypeArray));
	EndIf;

	NotifyDescriptionParameters = New Structure;
	NotifyDescriptionParameters.Insert("Form", Form);
	OnCloseNotifyDescription = New NotifyDescription("EditWriteSettingsOnEnd", ThisObject,
		NotifyDescriptionParameters);

	OpenForm("CommonForm.UT_WriteSettings", FormParameters, Form, , , , OnCloseNotifyDescription,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

Procedure EditWriteSettingsOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	Form = AdditionalParameters.Form;

	UT_CommonClientServer.SetOnFormWriteParameters(Form, Result);
EndProcedure

#EndRegion

#Region SaveAndReadConsoleData
#Region SaveConsoleData

// Description
// 
// Parameters:
// 	SaveAs - Boolean - Is file saving mode enabled AS. I.e. always ask where to save, even if there is already a file name
// 	SavedFilesDescriptionStructure -Structure - Contains the information necessary to identify the file to save
// 		Contains the fields:
// 			FileName- String - Name of the saved file. If not specified, a dialog for saving will appear
// 			Extension- String- Extension of the saved file
// 			SavedFormatName- String- description of the saved file format
// 	SavedDataUrl - String- The address in the temporary storage with the stored value. The stored data will be additionally implemented using a JSON serializer.
// 	OnEndNotifyDescription- NotifyDescription- Notify description after data saved to file
Procedure SaveConsoleDataToFile(ConsoleName, SaveAs, SavedFilesDescriptionStructure,
	SavedDataUrl, OnEndNotifyDescription) Export

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("SaveAs", SaveAs);
	NotifyAdditionalParameters.Insert("SavedFilesDescriptionStructure", SavedFilesDescriptionStructure);
	NotifyAdditionalParameters.Insert("SavedDataUrl", SavedDataUrl);
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);
	NotifyAdditionalParameters.Insert("ConsoleName", ConsoleName);

	AttachFileSystemExtensionWithPossibleInstallation(New  NotifyDescription ("SaveConsoleDataToFileAfterFileSystemExtensionConnection", 
		ThisObject,	NotifyAdditionalParameters));

EndProcedure

Procedure SaveConsoleDataToFileAfterFileSystemExtensionConnection(Connected, AdditionalParameters) Export
	SaveAS = AdditionalParameters.SaveAs;
	SavedFilesDescriptionStructure=AdditionalParameters.SavedFilesDescriptionStructure;

	If SaveAS Or SavedFilesDescriptionStructure.FileName = "" Then
		FileSelection = FileSelectionDialogByDescriptionStructureOfSelectedFile(FileDialogMode.Save,
			SavedFilesDescriptionStructure);
		FileSelection.Show(New NotifyDescription("SaveConsoleDataToFileAfterFileNameChoose", ThisObject,
			AdditionalParameters));
	Else
		SaveConsoleDataToFileBeginGettingFile(SavedFilesDescriptionStructure.FileName,
			AdditionalParameters);
	EndIf;

EndProcedure

Procedure SaveConsoleDataToFileAfterFileNameChoose(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	Endif;

	If SelectedFiles.Count() = 0 Then
		Return;
	Endif;

	SaveConsoleDataToFileBeginGettingFile(SelectedFiles[0], AdditionalParameters);
EndProcedure

Procedure SaveConsoleDataToFileBeginGettingFile(FileName, AdditionalParameters) Export

	PreparedDateToSave=UT_CommonServerCall.ConsolePreparedDataForFileWriting(AdditionalParameters.ConsoleName
		, FileName
		, AdditionalParameters.SavedDataUrl
		, AdditionalParameters.SavedFilesDescriptionStructure);
	ReceivedFiles = New Array;
	ReceivedFiles.Add(New TransferableFileDescription(FileName, PreparedDateToSave));
	BeginGettingFiles(New NotifyDescription("SaveConsoleDataToFileAfterGettingFiles", ThisObject,
		AdditionalParameters), ReceivedFiles, FileName, False);
EndProcedure

Procedure SaveConsoleDataToFileAfterGettingFiles(ReceivedFiles, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.OnEndNotifyDescription;

	If ReceivedFiles = Undefined Then

		If NotificationProcessing <> Undefined Then
			ExecuteNotifyProcessing(NotificationProcessing, Undefined);
		EndIf;
	Else
		If UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Then
			FileName = ReceivedFiles[0].FullName;
		Else
			FileName = ReceivedFiles[0].Name;
		EndIf;
		If NotificationProcessing <> Undefined Then
			ExecuteNotifyProcessing(NotificationProcessing, FileName);
		EndIf;

	EndIf;

EndProcedure

#EndRegion

#Region ConsoleDataReading

Procedure ReadConsoleFromFile(ConsoleName, ReadableFileDescriptionStructure, OnEndNotifyDescription, 
	WithoutFileSelection = False) Export

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("ReadableFileDescriptionStructure", ReadableFileDescriptionStructure);
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);
	NotifyAdditionalParameters.Insert("ConsoleName", ConsoleName);
	NotifyAdditionalParameters.Insert("WithoutFileSelection", WithoutFileSelection);

	AttachFileSystemExtensionWithPossibleInstallation(New NotifyDescription("ReadConsoleFromFileAfterExtensionConnection", 
		ThisObject, NotifyAdditionalParameters));

EndProcedure

Procedure ReadConsoleFromFileAfterExtensionConnection(Connected, AdditionalParameters) Export

	UploadFileName  = AdditionalParameters.ReadableFileDescriptionStructure.FileName;
	WithoutFileSelection = AdditionalParameters.WithoutFileSelection;

	If Connected Then

		If WithoutFileSelection Then
			If ValueIsFilled(UploadFileName) Then
				PutableFiles=New Array;
				PutableFiles.Add(New TransferableFileDescription(UploadFileName));

				BeginPuttingFiles(New NotifyDescription("ReadConsoleFromFileAfterPutFiles", 
					ThisObject, AdditionalParameters), PutableFiles, , False);
			EndIf;
		Else
			FileChoose = FileSelectionDialogByDescriptionStructureOfSelectedFile(FileDialogMode.Open,
				AdditionalParameters.ReadableFileDescriptionStructure);

			FileChoose.Show(New NotifyDescription("ReadConsoleFromFileAfterFileChoose", ThisObject,
				AdditionalParameters));
		EndIf;
	Else
		PutableFiles=New Array;
		PutableFiles.Add(New TransferableFileDescription(UploadFileName));

		BeginPuttingFiles(New NotifyDescription("ReadConsoleFromFileAfterPutFiles", 
			ThisObject, AdditionalParameters), PutableFiles, , UploadFileName = "");

	EndIf;

EndProcedure

Procedure ReadConsoleFromFileAfterFileChoose(SelectedFiles, AdditionalParameters) Export

	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	PutableFiles=New Array;
	PutableFiles.Add(New TransferableFileDescription(SelectedFiles[0]));

	BeginPuttingFiles(
		New NotifyDescription("ReadConsoleFromFileAfterPutFiles", ThisObject,
		AdditionalParameters), PutableFiles, , False);
EndProcedure

Procedure ReadConsoleFromFileAfterPutFiles(PuttedFiles, AdditionalParameters) Export

	If PuttedFiles = Undefined Then
		Return;
		
	EndIf;

	ReadConsoleFromFileProcessingFileUploading(PuttedFiles, AdditionalParameters);
EndProcedure

Procedure ReadConsoleFromFileProcessingFileUploading(PuttedFiles, AdditionalParameters)

	ResultStructure=Undefined;

	For Each PuttedFile In PuttedFiles Do

		If PuttedFile.Location <> "" Then

			ResultStructure=New Structure;
			ResultStructure.Insert("Url", PuttedFile.Location);
			If UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Then
				ResultStructure.Insert("FileName", PuttedFile.FullName);
			Else
				ResultStructure.Insert("FileName", PuttedFile.Name);
			EndIf;
		
			Break;
		
		EndIf;

	EndDo;

	ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, ResultStructure);

EndProcedure

#EndRegion

#EndRegion

#Region FileSystemExtensionConnectAndSetup

Procedure AttachFileSystemExtensionWithPossibleInstallation(OnEndNotifyDescription, AfterInstall = False) Export
	
	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);
	NotifyAdditionalParameters.Insert("AfterInstall", AfterInstall);

	BeginAttachingFileSystemExtension(
		New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionConnect",
		ThisObject, NotifyAdditionalParameters));

EndProcedure

Procedure AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionConnect(Connected,
	AdditionalParameters) Export

	If Connected Then
		SessionFileVariablesStructure=UT_ApplicationParameters[SessionFileVariablesParameterName()];
		If SessionFileVariablesStructure = Undefined Then
			ReadMainSessionFileVariablesToApplicationParameters(New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndSessionFileVariablesReading",
				ThisObject, AdditionalParameters));
		ElsIf Not SessionFileVariablesStructure.Property("UserDataWorkingDirectory") Then
			ReadMainSessionFileVariablesToApplicationParameters(New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndSessionFileVariablesReading",
				ThisObject, AdditionalParameters));
		
		Else
			ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, True);
		EndIf;
	ElsIf Not AdditionalParameters.AfterInstall Then
		BeginInstallFileSystemExtension(
		New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionInstallation",
			ThisObject, AdditionalParameters));
	Else
		ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, False);
	EndIf;

EndProcedure

Procedure AttachFileSystemExtensionWithPossibleInstallationOnEndSessionFileVariablesReading(Result,
	AdditionalParameters) Export

	ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, True);

EndProcedure

Procedure AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionInstallation(AdditionalParameters) Export
	AttachFileSystemExtensionWithPossibleInstallation(AdditionalParameters.OnEndNotifyDescription,
		True);
EndProcedure

#EndRegion

#Region ApplicationParameters

Function SessionNumber() Export
	Return UT_ApplicationParameters["SessionNumber"];
EndFunction

#EndRegion

#Region SessionFileParametersReadingToApplicationParameters

Function SessionFileVariablesParameterName () Export	
	Return "FILE_VARIABLES";
EndFunction

// Sesstion file variables structure
//
// Returns:
//  Structure - Sesstion file variables:
//  	*TempFilesDirectory - String -
//  	*UserDataWorkingDirectory - String -
Function SessionFileVariablesStructure() Export
	CurrentApplicationParameters=UT_ApplicationParameters;

	FileVariablesStructure=CurrentApplicationParameters[SessionFileVariablesParameterName()];
	If FileVariablesStructure = Undefined Then
		CurrentApplicationParameters[SessionFileVariablesParameterName()]=New Structure;
		FileVariablesStructure=CurrentApplicationParameters[SessionFileVariablesParameterName()];
	EndIf;

	Return FileVariablesStructure;
EndFunction

Procedure ReadMainSessionFileVariablesToApplicationParameters(OnEndNotifyDescription) Export
	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);

	//1. Temp files directory
	BeginGettingTempFilesDir(
		New NotifyDescription("ReadMainSessionFileVariablesToApplicationParametersOnEndGettingTempFilesDir",
		ThisObject, NotifyAdditionalParameters));
EndProcedure

Procedure ReadMainSessionFileVariablesToApplicationParametersOnEndGettingTempFilesDir(DirectoryName,
	AdditionalParameters) Export
	FileVariablesStructure=SessionFileVariablesStructure();
	FileVariablesStructure.Insert("TempFilesDirectory", DirectoryName);

	BeginGettingUserDataWorkDir(
		New NotifyDescription("ReadMainSessionFileVariablesToApplicationParametersOnEndGettingUserDataWorkDir",
		ThisObject, AdditionalParameters));
EndProcedure

Procedure ReadMainSessionFileVariablesToApplicationParametersOnEndGettingUserDataWorkDir(DirectoryName,
	AdditionalParameters) Export
	FileVariablesStructure=SessionFileVariablesStructure();
	FileVariablesStructure.Insert("UserDataWorkingDirectory", DirectoryName);
	
	ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, True);
EndProcedure

#EndRegion
#Region ApplicationRun1С


// Description
// 
// Parameters:
// 	ClientType - Number - Run mode code
// 		1 - Designer
// 		2 - Thick client ordinary mode
// 		3 - Thick client managed application
// 		4 - Thin client
// 	User - String - Name of Database User , to run application 
// 	UnderUserRunMode - Boolean - Determines whether the user's password will be changed before launching. After the launch, the password will be returned back
// Returns:
// 	
Function Run1CSession(ClientType, User, UnderUserRunMode = False,
	PauseBeforePasswordRestore = 20) Export
	#If WebClient Then

	#Else
	Directory1C = BinDir();

	LaunchString = Directory1C;
	
	LaunchFileExtension = "";
	If UT_CommonClientServer.IsWindows() Then
		LaunchFileExtension=".EXE";
	EndIf;
	
	If ClientType = 1 Then
		LaunchString = LaunchString + "1cv8" + LaunchFileExtension + " DESIGNER";
	ElsIf ClientType = 2 Then
		LaunchString = LaunchString + "1cv8" + LaunchFileExtension + " ENTERPRISE /RunModeOrdinaryApplication";
	ElsIf ClientType = 3 Then
		LaunchString = LaunchString + "1cv8" + LaunchFileExtension + " ENTERPRISE /RunModeManagedApplication";
	Else
		LaunchString = LaunchString + "1cv8c" + LaunchFileExtension + " ENTERPRISE";
	Endif;
	
	ConnectionString=InfoBaseConnectionString();
	ConnectionStringParametersArray = StrSplit(ConnectionString, ";");
	
	MatchOfConnectionStringParameters = New Structure;
	For Each StringParameterOfConnectionString In ConnectionStringParametersArray Do
		ParameterArray = StrSplit(StringParameterOfConnectionString, "=");
		
		If ParameterArray.Count() <> 2 Then
			Continue;
		Endif;
		
		Parameter = Lower(ParameterArray[0]);
		ParameterValue = ParameterArray[1];
		MatchOfConnectionStringParameters.Insert(Parameter, ParameterValue);
	EndDo;
	
	If MatchOfConnectionStringParameters.Property("file") Then
		LaunchString = LaunchString + " /F" + MatchOfConnectionStringParameters.File;
	ElsIf MatchOfConnectionStringParameters.Property("srvr") Then
		DataBasePath = UT_StringFunctionsClientServer.PathWithoutQuotes(MatchOfConnectionStringParameters.srvr) + "\"
		+ UT_StringFunctionsClientServer.PathWithoutQuotes(MatchOfConnectionStringParameters.ref);
		DataBasePath = UT_StringFunctionsClientServer.WrapInOuotationMarks(DataBasePath);
		LaunchString = LaunchString + " /S " + DataBasePath;
	ElsIf MatchOfConnectionStringParameters.Property("ws") Then
		LaunchString = LaunchString + " /WS " + MatchOfConnectionStringParameters.ws;
	Else
		Message(ConnectionString);
	EndIf;
	
	LaunchString = LaunchString + " /N""" + User + """";
	
	StoredIBUserPasswordData = Undefined;
	If UnderUserRunMode Then
		
		//+issue558
		PasswordStrengthCheck = New Structure;
		PasswordStrengthCheck = UT_CommonServerCall.GetPasswordStrengthLengthCheck(PasswordStrengthCheck);		
		UT_CommonServerCall.SetPasswordStrengthLengthCheck(PasswordStrengthCheck, True);
		//+
		
		TempPassword = "qwerty123456";
		StoredIBUserPasswordData = UT_CommonServerCall.StoredIBUserPasswordData(
		User);
		UT_CommonServerCall.SetIBUserPassword(User, TempPassword);
		
		LaunchString = LaunchString + " /P" + TempPassword;
		
		//+issue558
		UT_CommonServerCall.SetPasswordStrengthLengthCheck(PasswordStrengthCheck);
		//+		
	EndIf;
	
	NotifyAdditionalParameters = New Structure;
	NotifyAdditionalParameters.Insert("UnderUserRunMode", UnderUserRunMode);
	NotifyAdditionalParameters.Insert("StoredIBUserPasswordData",
		StoredIBUserPasswordData);
	NotifyAdditionalParameters.Insert("User", User);
	NotifyAdditionalParameters.Insert("PauseBeforePasswordRestore", PauseBeforePasswordRestore);
	
	Try
		BeginRunningApplication(New NotifyDescription("Run1CSessionEndLaunch", ThisObject,
			NotifyAdditionalParameters), LaunchString);
	Except
		Message(BriefErrorDescription(ErrorInfo()));
	EndTry;
	#EndIf
EndFunction

Procedure Run1CSessionEndLaunch(ReturnCode, AdditionalParameters) Export
	If Not AdditionalParameters.UnderUserRunMode Then
		Return;
	EndIf;

	LaunchTime = CurrentDate();
	While (CurrentDate() - LaunchTime) < AdditionalParameters.PauseBeforePasswordRestore Do
		UserInterruptProcessing();
	EndDo;

	UT_CommonServerCall.RestoreUserDataAfterUserSessionStart(
		AdditionalParameters.User, AdditionalParameters.StoredIBUserPasswordData);
EndProcedure

#EndRegion

#Region FileWorkMethods

#Region FileDialog

// Empty description structure of the selected file.
// 
// Returns:
// 	Structure - Empty description structure of the selected file:
// * FileName - String 
// * SerializableFileFormats - Array of String 
// * Formats - Array of see EmptySelectedFileFormatDescription
Function EmptyDescriptionStructureOfSelectedFile() Export
	DescriptionStructure=New Structure;
	DescriptionStructure.Insert("FileName", "");
	DescriptionStructure.Insert("SerializableFileFormats", New Array);
	DescriptionStructure.Insert("Formats", New Array);

	Return DescriptionStructure;
EndFunction

// Empty selected file format description.
// 
// Returns:
// Structure - Empty selected file format description:
// * Extension - String - 
// * Name - String - 
// * Filter - String - 
Function EmptySelectedFileFormatDescription() Export
	Description=New Structure;
	Description.Insert("Extension", "");
	Description.Insert("Name", "");
	Description.Insert("Filter", "");

	Return Description;
EndFunction

// Add format to saving file description.
// 
// Parameters:
//	DescriptionStructureOfSelectedFile - see EmptyDescriptionStructureOfSelectedFile
// 	FormatName - String - FormatName
// 	FileExtension - String - File extension
// 	Filter - String - Filter
Procedure AddFormatToSavingFileDescription(DescriptionStructureOfSelectedFile, FormatName, FileExtension, 
	Filter = "") Export
	
	FileFormat=EmptySelectedFileFormatDescription();
	FileFormat.Name=FormatName;
	FileFormat.Extension=FileExtension;
	FileFormat.Filter = Filter;
	
	DescriptionStructureOfSelectedFile.Formats.Add(FileFormat);
EndProcedure

// File selection dialog by description structure of selected file.
// 
// Parameters:
// Mode - FileDialogMode - Mode
// SelectedFileDescriptionStructure - see EmptyDescriptionStructureOfSelectedFile.
// 
// Returns:
// 	FileDialog - File selection dialog based on the description structure of the file being selected
Function FileSelectionDialogByDescriptionStructureOfSelectedFile(Mode, DescriptionStructureOfSelectedFile) Export
	// You need to request a file name.
	FileSelection = New FileDialog(Mode);
	FileSelection.Multiselect = False;
	
	//Linux has problems with selecting a file if there is a dash in the existing one
	If Not (UT_CommonClientServer.IsLinux() And Find(DescriptionStructureOfSelectedFile.FileName, "-") > 0) Then
		
		FileSelection.FullFileName = DescriptionStructureOfSelectedFile.FileName;
	EndIf;

	Filter="";
	For each CurrentFileFormat In DescriptionStructureOfSelectedFile.Formats Do
		FormatExtension=CurrentFileFormat.Extension;
		If ValueIsFilled(FormatExtension) Then
			FormatFilter="*." + FormatExtension;
		Else
			FormatFilter="*.*";
		EndIf;
		
		If ValueIsFilled(CurrentFileFormat.Filter) Then
			FormatFilter = CurrentFileFormat.Filter;
		EndIf;

		Filter=Filter + ?(ValueIsFilled(Filter), "|", "") + StrTemplate("%1|%2", CurrentFileFormat.Name, FormatFilter);
	EndDo;

	FileSelection.Filter = Filter;

	If DescriptionStructureOfSelectedFile.SerializableFileFormats.Count() > 0 Then
		FileSelection.DefaultExt=DescriptionStructureOfSelectedFile.SerializableFileFormats[0];
	ElsIf DescriptionStructureOfSelectedFile.Formats.Count() > 0 Then
		FileSelection.DefaultExt=DescriptionStructureOfSelectedFile.Formats[0].Extension;
	EndIf;

	Return FileSelection;
EndFunction



#EndRegion

// Begin providing required directory. The file system extension should be attached earlier
// 
// Parameters:
// 	Catalog - String - Catalog
// 	EndingCallbackDescription - CallbackDescription - Ending callback description
Procedure BeginCatalogProviding(Catalog, EndingCallbackDescription) Export

	NotificationParameters = New Structure;
	NotificationParameters.Insert("Catalog", Catalog);
	NotificationParameters.Insert("EndingCallbackDescription", EndingCallbackDescription);

	File = New File(Catalog);
	File.BeginCheckingExistence(New NotifyDescription("BeginDirectoryProvidingCheckingExistenceEnding",
		ThisObject, NotificationParameters));

EndProcedure

// New file saving parameters.
// 
// Returns:
// 	Structure - New file saving parameters:
// * FileSystemExtensionAttached - Boolean -. 
// * TempStorageFileDirectory - String - - 
// * EndingCallbackDescription - Undefined, CallbackDescription - 
// * FullFileName - String - 
// * FileDialog - Undefined, FileDialog -
Function NewFileSavingParameters() Export
	SavingParameters = New Structure;
	SavingParameters.Insert("FileSystemExtensionAttached", False);
	SavingParameters.Insert("TempStorageFileDirectory", "");
	SavingParameters.Insert("EndingCallbackDescription", Undefined);
	SavingParameters.Insert("FullFileName", "");
	SavingParameters.Insert("FileDialog", Undefined);
	
	Return SavingParameters;
	
EndFunction

// Begin file saving.
// 
// Parameters:
// 	SavingParameters - see NewFileSavingParameters.
Procedure BeginFileSaving(SavingParameters) Export
	
	If SavingParameters.FileSystemExtensionAttached Then
		BeginFileSavingAttachingFileSystemExtensionEnding(True, SavingParameters);
	Else
		AttachFileSystemExtensionWithPossibleInstallation(New NotifyDescription("BeginFileSavingAttachingFileSystemExtensionEnding",
			ThisObject, SavingParameters));
	EndIf;
		
EndProcedure

// New file reading parameters into binary data.
// 
// Parameters:
//	FormUUID - UUID - Form UUID
// 
// Returns:
// 	Structure - New file reading parameters into binary data:
// * FormUUID - Undefined, UUID - 
// * FileSystemExtensionAttached - Boolean 
// * EndingCallbackDescription - Undefined, CallbackDescription - 
// * FullFileName - String
// * FileDialog - Undefined, FileDialog -
Function NewFileReadingParameters(FormUUID) Export
	ReadingsParameters = New Structure;
	ReadingsParameters.Insert("FormUUID", FormUUID);
	ReadingsParameters.Insert("FileSystemExtensionAttached", False);
	ReadingsParameters.Insert("EndingCallbackDescription", Undefined);
	ReadingsParameters.Insert("FullFileName", "");
	ReadingsParameters.Insert("FileDialog", Undefined);
	
	Return ReadingsParameters;
EndFunction

// Begin file reading.
// 
// Parameters:
// 	ReadingParameters - see NewFileReadingParameters.
Procedure BeginFileReading(ReadingParameters) Export
	If ReadingParameters.ExtensionWorkingWithFilesEnabled Then
		BeginFileReadingAttachingFileSystemExtensionEnding(True, ReadingParameters);
	Else
		AttachFileSystemExtensionWithPossibleInstallation(New NotifyDescription("BeginFileReadingAttachingFileSystemExtensionEnding",
			ThisObject, ReadingParameters));
	EndIf;

EndProcedure

Procedure BeginFilesSelecting(EndingCallbackDescription, Title = "Choose files", Filter = "",
	Multiselect = False) Export
	

EndProcedure

// Shows the file dialog.
// When working in a web client, the user will be shown a dialog of attaching file system extension, if required.
//
//
// Parameters:
// 	EndingProcessor - CallbackDescription -  a description of the procedure that will be called after the
//  	closing the file dialog with the parameters:
// 		 Result - Array of String - selected file names.
// 		 	- String - an empty string if the user refused to install the extension.
// 			- Undefined - if the user refused to select a file.
// 		 AdditionalParameters - Structure - additional notification parameters.
// Dialog - FileDialog - file dialog.
//
Procedure ShowFileDialog(EndingProcessor, Dialog) Export
	
	Context = New Structure;
	Context.Insert("EndingProcessor", EndingProcessor);
	Context.Insert("Dialog", Dialog);
	
	CallbackDescription = New NotifyDescription(
		"ShowDialogSelectDialogWhenExpansionWorkingWithFiles", ThisObject, Context);
	
	AttachFileSystemExtensionWithPossibleInstallation(CallbackDescription);
	
EndProcedure



#EndRegion

// Find forms by unique key.
// 
// Parameters:
// UniqueKey - Arbitrary - unique key
// FormName - String - Name of the form for the filter
// 
// Returns:
// 	Array of ClientApplicationForm.
Function FormsByUniqueKey(UniqueKey, FormName = "") Export
	FormsArray = New Array(); //Array of ClientApplicationForm
	
	FormType = UT_CommonClientServer.ManagedFormType();
	
	For Each CurrentWindow In GetWindows() Do
		For Each CurrentContent In CurrentWindow.Content Do
			If TypeOf(CurrentContent) <> FormType Then
				Continue;
			EndIf;
			
			If CurrentContent.UniqueKey <> UniqueKey Then
				Continue;
			EndIf;
			
			If ValueIsFilled(FormName) And Lower(CurrentContent.FormName) <> Lower(FormName) Then
				Continue;
			EndIf;
			
			FormsArray.Add(CurrentContent);
		EndDo;
	EndDo;
	
	Return FormsArray;
EndFunction

// Begin clearing cache tool at the client.
// 
// Parameters:
// 	EndingCallbackDescription - Undefined, CallbackDescription - Ending callback description
Procedure BeginCleanToolsCacheAtClient(EndingCallbackDescription = Неопределено) Export
	AssistiveLibraryToolsCatalog = UT_AssistiveLibrariesDirectory();
	If Not ValueIsFilled(AssistiveLibraryToolsCatalog) Then
		Return;
	КонецЕсли;
	//@skip-check empty-except-statement
	Try
		BeginDeletingFiles(,AssistiveLibraryToolsCatalog);
	Except
		
EndTry;

EndProcedure

// Opens a URL in an application associated with URL protocol.
//
// Valid protocols: http, https, e1c, v8help, mailto, tel, skype.
//
// Do not use protocol file:// to open Explorer or a file.
// - To Open Explorer, use OpenExplorer. 
// - To open a file in an associated application, use OpenFileInViewer. 
//
// Parameters:
//  URL - Reference - a link to open.
//  Notification - NotifyDescription - notification on file open attempt.
//      If the notification is not specified and an error occurs, the method shows a warning.
//      - ApplicationStarted - Boolean - True if the external application opened successfully.
//      - AdditionalParameters - Arbitrary - a value that was specified when creating the NotifyDescription object.
//
// Example:
//  FileSystemClient.OpenURL("e1cib/navigationpoint/startpage"); // Home page.
//  FileSystemClient.OpenURL("v8help://1cv8/QueryLanguageFullTextSearchInData");
//  FileSystemClient.OpenURL("https://1c.ru");
//  FileSystemClient.OpenURL("mailto:help@1c.ru");
//  FileSystemClient.OpenURL("skype:echo123?call");
//
Procedure OpenURL(URL, Val Notification = Undefined) Export
	
	// CAC:534-off safe start methods are provided with this function
	
	Context = New Structure;
	Context.Insert("URL", URL);
	Context.Insert("Notification", Notification);
	
	ErrorDescription = StringFunctionsClientServer.SubstituteParametersToString(
		NStr("ru = 'Не удалось перейти по ссылке ""%1"" по причине: Неверно задана навигационная ссылка.'; 
		           |en = 'Cannot follow link %1. The URL is invalid.'"),
		URL);
	
	If Not IsAllowedRef(URL) Then 
		
		OpenURLNotifyOnError(ErrorDescription, Context);
		
	ElsIf IsWebURL(URL)
		Or CommonInternalClient.IsURL(URL) Then 
		
		Try
		
#If ThickClientOrdinaryApplication Then
			
			BeginRunningApplicationWithFilesWorkingExt(Notification, URL);
#Else
			GotoURL(URL);
#EndIf
			
			If Notification <> Undefined Then 
				ApplicationStarted = True;
				ExecuteNotifyProcessing(Notification, ApplicationStarted);
			EndIf;
			
		Except
			OpenURLNotifyOnError(ErrorDescription, Context);
		EndTry;
		
//	ElsIf FileSystemInternalClient.IsHelpRef(URL) Then 
//		
//		OpenHelp(URL);
		
	Else 
		
		BeginRunningApplicationWithFilesWorkingExt(Notification, URL);
//		Notification = New NotifyDescription(
//			"OpenURLAfterCheckFileSystemExtension", FileSystemInternalClient, Context);
//		
//		SuggestionText = StringFunctionsClientServer.SubstituteParametersToString(
//			NStr("ru = 'Для открытия ссылки ""%1"" необходимо установить расширение работы с файлами.'; en = 'To be able to open link ""%1"", install the file system extension.'"),
//			URL);
//		AttachFileOperationsExtension(Notification, SuggestionText, False);
		
	EndIf;
	
	// CAC:534-enable
	
EndProcedure


// Open a code string in a special form.
// 
// Parameters:
// 	Text - String - Text
// 	Title - String - Title
// 	UniqueKey - String - Form unique key
Procedure OpenCodeStringCodeSpecialForm(Text, Title, UniqueKey = "") Export
	FormParameters = New Structure;
	FormParameters.Insert("Code", Text);
	FormParameters.Insert("ModuleName", Title);

	OpenForm("ОбщаяФорма.УИ_ФормаКода",
				 FormParameters,
				 ,
				 UniqueKey);
EndProcedure

#Region ObsoletePrivate

#EndRegion


#EndRegion

#Region Internal

#Region FileWorkMethods

// Begin directory providing checking existence ending.
// 
// Parameters:
// 	Exists - Boolean - Indication of catalog existence
// 	AdditionalParameters - Structure - Callback parameters:
// 		EndingCallbackDescription - CallbackDescription
// 		Directory - String
Procedure BeginDirectoryProvidingCheckingExistenceEnding(Exists, AdditionalParameters) Export
	If Exists Then
		ExecuteNotifyProcessing(AdditionalParameters.EndingCallbackDescription, True);
		Return;
	EndIf;
	CallBack = New NotifyDescription("BeginDirectoryProvidingCreatingDirectoryEnding", ThisObject,
		AdditionalParameters, "BeginDirectoryProvidingCreatingDirectoryEndingWithError", ThisObject);

	BeginCreatingDirectory(CallBack, AdditionalParameters.Directory);
EndProcedure

// Begin directory providing checking existence ending.
// 
// Parameters:
// 	CatalogDirectory - String - a string containing the path to the created catalog,
// 	AdditionalParameters - Structure - Callback parameters:
//  	EndingCallbackDescription - CallbackDescription
//  	Directory - String
Procedure BeginDirectoryProvidingCreatingDirectoryEnding(CatalogDirectory, AdditionalParameters) Export
	ExecuteNotifyProcessing(AdditionalParameters.EndingCallbackDescription, True);
EndProcedure

// Begin directory providing checking existence ending.
// 
// Parameters:
// 	ErrorInfo - ErrorInfo.
// 	StandardProcessing - Boolean -
// 	AdditionalParameters - Structure - Callback parameters:
//  	EndingCallbackDescription - CallbackDescription
// 		Directory - String
Procedure BeginDirectoryProvidingCreatingDirectoryEndingWithError(ErrorInfo, StandardProcessing,
	AdditionalParameters) Export
	StandardProcessing = False;
	ExecuteNotifyProcessing(AdditionalParameters.EndingCallbackDescription, False);
EndProcedure


// Begin file saving, attaching file system extension ending.
// 
// Parameters:
// 	Attached - Boolean - Connected
// 	AdditionalParameters - see NewFileSavingParameters
Procedure BeginFileSavingAttachingFileSystemExtensionEnding(Attached, AdditionalParameters) Export
	If Attached <> True Then
		Return;
	EndIf;
	AdditionalParameters.FileSystemExtensionAttached = True;
	
	If ValueIsFilled(AdditionalParameters.FullFileName) Then
		BeginFileSavingFileNameSettingEnding(AdditionalParameters);
	Else
		Dialog = AdditionalParameters.FileDialog;
		If Dialog = Undefined Then
			Dialog = New FileDialog(FileDialogMode.Save);
		EndIf;
		Dialog.Show(New NotifyDescription("BeginFileSavingFileNameChoosing",
			ThisObject, AdditionalParameters));
	EndIf;
	
EndProcedure

// Begin file saving, file name choosing.
//  
// Parameters:
// 	SelectedFiles - Array of String - SelectedFiles
// 	AdditionalParameters - see NewFileSavingParameters.
Procedure BeginFileSavingFileNameChoosing(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	EndIf;
	If SelectedFiles.Count()= 0 Then
		Return;
	EndIf;
	
	AdditionalParameters.FullFileName = SelectedFiles[0];

	BeginFileSavingFileNameSettingEnding(AdditionalParameters);
EndProcedure

// Begin file saving, file full name setting ending.
// 
// Parameters:
// 	AdditionalParameters - see NewFileSavingParameters.
Procedure BeginFileSavingFileNameSettingEnding(AdditionalParameters) Export
	ReceivedFiles = New Array;
	ReceivedFiles.Add(New TransferableFileDescription(AdditionalParameters.FullFileName,
		AdditionalParameters.TempStorageFileDirectory));

	BeginGettingFiles(New NotifyDescription("BeginFileSavingPuttingFileEnding", ThisObject,
		AdditionalParameters), ReceivedFiles, AdditionalParameters.FullFileName, False);

EndProcedure

// Begin non-interactive file saving, file putting ending.
// 
// Parameters:
// 	ReceivedFiles - Array of TransferableFileDescription - Received Files
// 	AdditionalParameters - see NewNonInteractiveFileSavingParameters.
Procedure BeginFileSavingPuttingFileEnding(ReceivedFiles, AdditionalParameters) Export
	If AdditionalParameters.EndingCallbackDescription = Undefined Then
		Return;
	EndIf;
	
	CallbackProcessor = AdditionalParameters.EndingCallbackDescription;
	
	If ReceivedFiles = Undefined Then
		ExecuteNotifyProcessing(CallbackProcessor, Undefined);
		Return;
	EndIf;

	If UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Then
		FileName = ReceivedFiles[0].FullName;
	Else
		FileName = ReceivedFiles[0].Name;
	EndIf;
	ExecuteNotifyProcessing(CallbackProcessor, FileName);
EndProcedure


// Begin file reading, attaching file system extension ending.
// 
// Parameters:
// 	Attached - Boolean - Connected
// 	AdditionalParameters - see NewFileReadingParameters 
Procedure BeginFileReadingAttachingFileSystemExtensionEnding(Attached, AdditionalParameters) Export
	If Attached <> True Then
		Return;
	EndIf;
	AdditionalParameters.FileSystemExtensionAttached = True;
	
	If ValueIsFilled(AdditionalParameters.FullFileName) Then
		BeginFileReadingFileNameSettingEnding(AdditionalParameters);
	Else
		Dialog = AdditionalParameters.FileDialog;
		If Dialog = Undefined Then
			Dialog = New FileDialog(FileDialogMode.Open);
		EndIf;
		Dialog.Show(New NotifyDescription("BeginFileReadingFileNameChoosing", ThisObject,
			AdditionalParameters));
	EndIf;
	
EndProcedure

// Begin file reading, file name choosing
// 
// Parameters:
// 	SelectedFiles - Array of String - SelectedFiles
// AdditionalParameters - see NewFileReadingParameters.
Procedure BeginFileReadingFileNameChoosing(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	EndIf;
	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;
	
	AdditionalParameters.FullFileName = SelectedFiles[0];

	BeginFileReadingFileNameSettingEnding(AdditionalParameters);
EndProcedure

// Begin file reading, file full name setting ending.
// 
// Parameters:
// 	AdditionalParameters - see NewFileReadingParameters.
Procedure BeginFileReadingFileNameSettingEnding(AdditionalParameters) Export
	PutedFiles = New Array;
	PutedFiles.Add(New TransferableFileDescription(AdditionalParameters.FullFileName));

	BeginPuttingFiles(New NotifyDescription("BeginFileReadingPuttingFileEnding", ThisObject,
		AdditionalParameters), PutedFiles, , False, AdditionalParameters.FormUUID);

EndProcedure

// Begin file saving reading, file putting ending.
// 
// Parameters:
// 	PutedFiles - Array of TransferableFileDescription - Puted Files
// 	AdditionalParameters - see NewFileReadingParameters.
Procedure BeginFileReadingPuttingFileEnding(PutedFiles, AdditionalParameters) Export
	If PutedFiles = Undefined Then
		Return;
	EndIf;
	
	If AdditionalParameters.EndingCallbackDescription = Undefined Then
		Return;
	EndIf;
	
	Files = New Array;
	
	For Each PutedFile In PutedFiles Do

		If PutedFile.Location = "" Then
			Continue;
		EndIf;

		FileDescription = New Structure;
		FileDescription.Insert("Location", PutedFile.Storage);
		If UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Then
			FileDescription.Insert("FullName", PutedFile.FullName);
		Else
			FileDescription.Insert("FullName", PutedFile.Name);
		EndIf;

		Files.Add(FileDescription);
	EndDo;
	

	ExecuteNotifyProcessing(AdditionalParameters.EndingCallbackDescription, Files);
	
EndProcedure

// Show file dialog while attaching file system extension.
// 
// Parameters:
// 	ExtensionAttached - Boolean - Expansion attached
// 	Context - Structure:
//  	EndingCallbackProcessor - CallbackDescription
//  	FileDialog - FileDialog
Procedure ShowDialogSelectDialogWhenExpansionWorkingWithFiles(ExtensionAttached, Context) Export
	If Not ExtensionAttached Then
		ExecuteNotifyProcessing(Context.EndingCallbackProcessor, "");
		Return;
	EndIf;
	
	Context.FileDialog.Show(Context.EndingCallbackProcessor);
	
EndProcedure

#EndRegion

// Checks whether the passed string is an internal URL.
//  
// Parameters:
//  String - String - URL.
//
// Returns:
//  Boolean -  a check result.
//
Function IsURL(Row) Export
	
	Return StrStartsWith(Row, "e1c:")
		Or StrStartsWith(Row, "e1cib/")
		Or StrStartsWith(Row, "e1ccs/");
	
EndFunction

// Checks whether the passed string is a web URL.
// 
// Parameters:
//  String - String - passed URL.
//
// Returns:
//	Boolean
//
Function IsWebURL(String) Export
	
	Return StrStartsWith(String, "http://")  // a usual connection.
		Or StrStartsWith(String, "https://");// a secure connection.
	
EndFunction

// Checks whether the passed string is a reference to the online help.
// 
// Parameters:
//  String - String - passed URL.
//
// Returns:
//	Boolean
//
Function IsHelpRef(String) Export
	
	Return StrStartsWith(String, "v8help://");
	
EndFunction



// Checks whether the passed string is a valid reference to the protocol whitelist.
// 
// Parameters:
//  String - String - passed URL.
//
// Returns:
//	Boolean
//
Function IsAllowedRef(String) Export
	
	Return StrStartsWith(String, "e1c:")
		Or StrStartsWith(String, "e1cib/")
		Or StrStartsWith(String, "e1ccs/")
		Or StrStartsWith(String, "v8help:")
		Or StrStartsWith(String, "http:")
		Or StrStartsWith(String, "https:")
		Or StrStartsWith(String, "mailto:")
		Or StrStartsWith(String, "tel:")
		Or StrStartsWith(String, "skype:")
		Or StrStartsWith(String, "market:")
		Or StrStartsWith(String, "itms-apps:");
		
EndFunction


// Continue the CommonClient.OpenURL procedure.
Procedure OpenURLNotifyOnError(ErrorDescription, Context) Export
	
	Notification = Context.Notification;
	
	If Notification = Undefined Then
		If Not IsBlankString(ErrorDescription) Then 
			ShowMessageBox(, ErrorDescription);
		EndIf;
	Else 
		ApplicationStarted = False;
		ExecuteNotifyProcessing(Notification, ApplicationStarted);
	EndIf;
	
EndProcedure

#EndRegion


#Region Private

//@skip-check code-never-compiled
Function InformationForSupportService() 
	InformationStructure = New Structure;
	InformationStructure.Insert("OptionSupplies", UT_CommonClientServer.DistributionType());
	InformationStructure.Insert("ToolsVersion", UT_CommonClientServer.Version());
	
	SystemInformation = New SystemInfo;
	
	InformationStructure.Insert("Platform", SystemInformation.AppVersion);
	InformationStructure.Insert("Client", UT_CommonClientServer.DescriptionOSForTechnicalSupport());
	#If WebClient Then
		InformationStructure.Insert("ClientType", "WebClient");
	#ElsIf ThinClient Then
		InformationStructure.Insert("ClientType", "ThinClient");
	#ElsIf MobileAppClient Then
		InformationStructure.Insert("ClientType", "MobileAppClient");
	#ElsIf ThickClientOrdinaryApplication Then
		InformationStructure.Insert("ClientType", "ThickClientOrdinaryApplication");
	#ElsIf ThickClientManagedApplication Then
		InformationStructure.Insert("ClientType", "ThickClientManagedApplication");
	#ElsIf MobileClient Then
		InformationStructure.Insert("ClientType", "MobileClient");
	#Else
		
		InformationStructure.Insert("ClientType", "Undefined");
	#EndIf	
	
	UT_CommonServerCall.AddInformationForSupportOnTheServer(InformationStructure);
	
	Return InformationStructure;
EndFunction

Function InformationForSupportServiceAsString(Info, Prefix = "") 
	SupportAsString = "";
	
	For Each Iterator In Info Do
		If TypeOf(Iterator) = Type("KeyAndValue") Then
			If TypeOf(Iterator.Value) = Type("Structure") OR TypeOf(Iterator.Value) = Type("Array") Then
				SupportAsString = SupportAsString + InformationForSupportServiceAsString(Iterator.Value,
																				  ?(ValueIsFilled(Prefix),
																					Prefix + ".",
																					"") + Iterator.Key);
			Else
				SupportAsString = SupportAsString
								  + ?(ValueIsFilled(Prefix), Prefix + ".", "")
								  + Iterator.Key
								  + "="
								  + Iterator.Value
								  + ";"
								  + Chars.LF;
			EndIf;
		ElsIf TypeOf(Iterator) = Type("Structure") Then
			SupportAsString = SupportAsString + InformationForSupportServiceAsString(Iterator, Prefix);
		Else
			SupportAsString = SupportAsString
							  + ?(ValueIsFilled(Prefix), Prefix + ".", "")
							  + Iterator
							  + ";"
							  + Chars.LF;
		EndIf;
	EndDo;
		
	Return SupportAsString;
EndFunction

#EndRegion
