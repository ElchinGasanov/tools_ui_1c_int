#Region Public

#Region СборкаОбработкиДляИсполнения

// Начать сборку обработок для исполнения кода.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
//  CallbackDescriptionAboutCompletion - CallbackDescription - Description of the completion alert
//  NamesOfPredefinedVariables - Structure, Undefined -
//  EditorsIDForExecutionAtClient - Array of Строка, Undefined -
Procedure StartBuildDataProcessorForCodeExecution(Form, CallbackDescriptionAboutCompletion,
	NamesOfPredefinedVariables = Undefined, EditorsIDForExecutionAtClient = Undefined) Export
	CodeEditors = UT_CodeEditorClientServer.FormEditors(Form);

	EditorsForBuild = New Array;
	For Each  KeyAndValue In CodeEditors Do
		If Not KeyAndValue.Value.UseDataProcessorToExecuteCode Then
			Continue;
		EndIf;

		EditorDataForBuild = UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor();
		EditorDataForBuild.ID = KeyAndValue.Key;
		If EditorsIDForExecutionAtClient <> Undefined Then
			EditorDataForBuild.ExecutionAtClient = EditorsIDForExecutionAtClient.Find(KeyAndValue.Key) <> Undefined;
		EndIf;
		EditorDataForBuild.TextEditor = EditorCodeText(Form, KeyAndValue.Key);
		EditorDataForBuild.ConnectedDataProcessorName = UT_CodeEditorClientServer.NameOfConnectedDataProcessorForExecutionCodeEditor(KeyAndValue.Key);

		If NamesOfPredefinedVariables <> Undefined Then
			If NamesOfPredefinedVariables.Property(KeyAndValue.Key) Then
				EditorDataForBuild.NamesOfPredefinedVariables = NamesOfPredefinedVariables[KeyAndValue.Key];
			EndIf;
		EndIf;

		NeedBuild	= True;

		EditorDataProcessorCache = KeyAndValue.Value.CacheResultsConnectionsProcessingExecution; //см. UT_CodeEditorClientServer.NewCacheResultsConnectionsProcessingExecution
		If EditorDataProcessorCache <> Undefined Then
			ВсеПеременныеЕстьВСобраннойОбработке = True;
			
			For Each Str In EditorDataForBuild.NamesOfPredefinedVariables Do
				If EditorDataProcessorCache.NamesOfPredefinedVariables.Найти(Lower(Str)) = Undefined Then
					ВсеПеременныеЕстьВСобраннойОбработке = False;
					Break;
				EndIf;
			EndDo;

			NeedBuild = EditorDataForBuild.ExecutionAtClient <> EditorDataProcessorCache.ExecutionAtClient
						  Or EditorDataForBuild.TextEditor <> EditorDataProcessorCache.TextEditor
						  Or Not ВсеПеременныеЕстьВСобраннойОбработке;
		EndIf;

		If Not NeedBuild Then
			Continue;
		EndIf;
		
		If Not ValueIsFilled(EditorDataForBuild.TextEditor) Then
			Continue;
		EndIf;
		
		EditorsForBuild.Add(EditorDataForBuild);

	EndDo;
	
	If EditorsForBuild.Count() = 0 Then
		RunCallback(CallbackDescriptionAboutCompletion, True);
		Return;
	EndIf;

	DataProcessorsBuildOptions = NewBuildParametersDataProcessorsForEditors();
	DataProcessorsBuildOptions.Form = Form;
	DataProcessorsBuildOptions.EditorsForBuild = UT_CodeEditorServerCall.EditorsForBuildWithConvertedTextModule(EditorsForBuild);
	DataProcessorsBuildOptions.CallbackDescriptionAboutCompletion = CallbackDescriptionAboutCompletion;
	DataProcessorsBuildOptions.CatalogTemplateProcessing = UT_CommonClientServer.MergePaths(UT_CommonClient.UT_AssistiveLibrariesDirectory(),
																									  "DataProcessorTemplate");

	StartSavingProcessingTemplateToDisk(DataProcessorsBuildOptions.CatalogTemplateProcessing,
										   New CallbackDescription("StartBuildDataProcessorForCodeExecutionDataProcessorsCompletingSavingTemplate",
		ThisObject, DataProcessorsBuildOptions));

EndProcedure

#EndRegion

#Region FormEventsWithEditor

Procedure FormOnOpen(Form, CompletionNotifyDescription = Undefined) Export
	Form.UT_CodeEditorClientData = New Structure;
	Form.UT_CodeEditorClientData.Insert("Events", new Array);
	Form.UT_CodeEditorClientData.Insert("EventsHandlers", New Structure);
	
	AdditionalParameters = New Structure;
	AdditionalParameters.Insert("CompletionNotifyDescription", CompletionNotifyDescription);
	AdditionalParameters.Insert("Form", Form);

	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
			New NotifyDescription("FormOnOpenEndAttachFileSystemExtension", ThisObject, 
			AdditionalParameters));
EndProcedure

Procedure HTMLEditorFieldDocumentGenerated(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	EditorSettings = FormEditors[EditorID];
	EditorSettings.Insert("Initialized", True);

	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;
	Form.AttachIdleHandler("Attachable_CodeEditorDeferredInitializingEditors", 0.2, True);
EndProcedure

Procedure HTMLEditorFieldOnClick(Form, Item, EventData, StandardProcessing) Export
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);
	EditorTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	
	Event = Undefined;

	If EditorType = EditorTypes.Monaco Then
		Event = HTMLEditorFieldOnClickMonaco(Form, Item, EventData, StandardProcessing);
	ElsIf EditorType = EditorType.Ace Then 
		Event = EventToHandleWhenClickedAce(Form, Item, EventData)		
	EndIf;

	If Event = Undefined Then
		Return;
	EndIf;
	Form.UT_CodeEditorClientData.Events.Add(Event);

	Form.AttachIdleHandler("Attachable_CodeEditorDeferProcessingOfEditorEvents", 0.1, True);

	
EndProcedure

Procedure EditorEventsDeferProcessing(Form) Export

	For Each CurrentEvent In Form.UT_CodeEditorClientData.Events Do
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Form", Form);
		AdditionalParameters.Insert("Item", CurrentEvent.Item);

		If CurrentEvent.EventName = "EVENT_QUERY_CONSTRUCT" Then
			OpenMonacoQueryWizard(CurrentEvent.EventData, AdditionalParameters);
		ElsIf CurrentEvent.EventName = "EVENT_FORMAT_CONSTRUCT" Then
			OpenMonacoFormatStringWizard(CurrentEvent.EventData, AdditionalParameters);
		ElsIf CurrentEvent.EventName = "EVENT_GET_METADATA" Then
			AdditionalParameters.Insert("EventData", CurrentEvent.EventData);
			
			MetadataName = CurrentEvent.EventData.MetadataName;
			MetadataNameArray = StrSplit(MetadataName, ".");

			If MetadataNameArray[0] = "module" Then
				
				SetModuleDescriptionForMonacoEditor(MetadataName, AdditionalParameters);
				
			Else
				
				SetMetadataDescriptionForMonacoEditor(MetadataName, AdditionalParameters);
				
			EndIf;
		Elsif CurrentEvent.EventName = "EVENT_CONTENT_CHANGED" 
			Or CurrentEvent.EventName = "ACE_EVENT_CONTENT_CHANGED" Then
			FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
			EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form,
				CurrentEvent.Item);		
			EditorEvents = FormEditors[EditorID].EditorEvents;

			If ValueIsFilled(EditorEvents.OnChange) Then
				ExecuteNotifyProcessing(New NotifyDescription(EditorEvents.OnChange, Form,
					AdditionalParameters), CurrentEvent.Item);
			EndIf;
		ElsIf CurrentEvent.EventName = "INSERT_MACRO_COLUMN" Then
			InsertFormItemQueryEditorMacroColumn(Form, CurrentEvent.Item);
		ElsIf CurrentEvent.EventName = "EVENT_GET_DEFINITION" Then
			If ValueIsFilled(CurrentEvent.EventData.Module) Then
				ModuleName = "module." + CurrentEvent.EventData.Module;

				OpenFormsViewDefinitions = UT_CommonClient.FormsByUniqueKey(Upper(CurrentEvent.EventData.Module),
																									   "CommonForm.UT_CodeForm");
				If OpenFormsViewDefinitions.Count() > 0 Then
					CodeForm = OpenFormsViewDefinitions[0];
					GotoEditorMethodDefinition(CodeForm, "Код", CurrentEvent.EventData.Word);
					CodeForm.Activate();
				Else

					FormEditors = AdditionalParameters.Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
					EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form,
																											   CurrentEvent.Элемент);
					EditorOptions = FormEditors[EditorID];

					CallbackSettings = New Structure;
					CallbackSettings.Вставить("EditorID", EditorID);
					CallbackSettings.Вставить("Form", Form);
					CallbackSettings.Вставить("CurrentEvent", CurrentEvent);

					StartGettingModuleTextFromSourceFiles(ModuleName,
																EditorOptions.EditorOptions.DirectoriesOfSourceFiles,
																New CallbackDescription("OpenModuleProcedureDefinitionCompletionOfReceivingTextModule",
						ThisObject, CallbackSettings));
				EndIf;
			EndIf;
		ElsIf CurrentEvent.EventName = "TOOLS_UI_1C_COPY_TO_CLIPBOARD" Then
			SelectedText = EditorSelectedTextFormItem(Form, CurrentEvent.Item);
			UT_ClipboardClient.BeginCopyTextToClipboard(SelectedText,
				New CallbackDescription("StartCopyingSelectedTextToClipboardFinish",
				ThisObject, AdditionalParameters));
		ElsIf CurrentEvent.EventName = "TOOLS_UI_1C_PASTE_FROM_CLIPBOARD" Then
			UT_ClipboardClient.BeginGettingTextFormClipboard(New CallbackDescription("StartPastingFromClipboardCompletingReceiveText",
				ThisObject, AdditionalParameters));
		ElsIf CurrentEvent.EventName = "COLABORATOR_READY" Then 
			ItemFormStartCodeEditorInteractionSession(Form, CurrentEvent.Item);
		EndIf;
		
	EndDo;

	Form.UT_CodeEditorClientData.Events.Clear();
EndProcedure

// Выполнить команду редактора кода.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
//  Сommand - FormCommand - Сommand
Procedure ExecuteCodeEditorCommand(Form, Сommand) Export
	CommandStructure = UT_CodeEditorClientServer.StructureNameCommandForms(Сommand.Name);

	FormEditors =  UT_CodeEditorClientServer.FormEditors(Form);
	EditorOptions = FormEditors[CommandStructure.EditorID];
	
	If CommandStructure.CommandName = UT_CodeEditorClientServer.CommandNameExecutionModeThroughProcessing() Then
		EditorOptions.UseDataProcessorToExecuteCode = Not EditorOptions.UseDataProcessorToExecuteCode;
		Form.Items[Сommand.Name].Mark = EditorOptions.UseDataProcessorToExecuteCode;
	ElsIf CommandStructure.CommandName = UT_CodeEditorClientServer.CommandNameShareAlgorithm() Then
		TextOfAlgorithm = EditorCodeText(Form, CommandStructure.EditorID);
		isRequest = EditorOptions.Language = "bsl_query";

		ShareCode(TextOfAlgorithm, isRequest, Form);
	ElsIf CommandStructure.CommandName = UT_CodeEditorClientServer.CommandNameLoadAlgorithm() Then
		CallbackSettings = New Structure;
		CallbackSettings.Вставить("Form", Form);
		CallbackSettings.Вставить("EditorID", CommandStructure.EditorID);

		StartLoadingCodeFromService(New CallbackDescription("StartLoadingCodeFromServiceCompletion", ThisObject,
			CallbackSettings));
	ElsIf CommandStructure.CommandName = UT_CodeEditorClientServer.CommandNameQueryConstructor() Then
	ElsIf CommandStructure.CommandName = UT_CodeEditorClientServer.CommandNameStartSessionInteractions() Then
		 StartSessionInteractionWithCodeEditorParametersRequest(Form, CommandStructure.EditorID);
	ElsIf CommandStructure.CommandName = UT_CodeEditorClientServer.CommandNameFinishSessionInteractions() Then
		 FinishCodeEditorInteractionSession(Form, CommandStructure.EditorID);
	EndIf;
EndProcedure

#EndRegion

Function AllFormEditorsInitialized(FormEditors)
	Result = True;
	For Each KeyValue In FormEditors Do
		If Not KeyValue.Value.Initialized 
			And KeyValue.Value.Visibility Then
			Result = False;
			Break;
		EndIf;
	EndDo;

	Return Result;
EndFunction

Procedure InitializeFormEditorsAfterFieldsGeneration(Form, FormEditors, EditorType, EditorTypes)
	For Each KeyValue In FormEditors Do
		EditorSettings = KeyValue.Value;
		If Not EditorSettings.Initialized Then
			Continue;
		EndIf;
		
		EditorFormItem = Form.Items[EditorSettings.EditorField];

		If EditorType = EditorTypes.Text Then
			If ValueIsFilled(EditorSettings.EditorSettings.FontSize) Then
				EditorFormItem.Font = New Font(, EditorSettings.EditorSettings.FontSize);
			EndIf;
		ElsIf EditorType = EditorTypes.Ace Then
			DocumentView = EditorFormItem.Document.defaultView;
			If ValueIsFilled(EditorSettings.EditorSettings.FontSize) Then
				DocumentView.editor.setFontSize(EditorSettings.EditorSettings.FontSize);
			EndIf;
 			DocumentView.editor.setAutoScrollEditorIntoView(True);
			DocumentView.editor.resize();
			
			CurrentLanguage = Lower(EditorSettings.Language);
			If CurrentLanguage = "bsl" Then
				CurrentLanguage="_1c";
			EndIf;
			
			DocumentView.appTo1C.setMode(CurrentLanguage);
			
			If ValueIsFilled(EditorSettings.СобытияРедактора.ПриИзменении) Then
				DocumentView.appTo1C.setGenerateModificationEvent(True);
			EndIf;
						
		ElsIf EditorType = EditorTypes.Monaco Then
			DocumentView = EditorFormItem.Document.defaultView;

			ThereAreAddedCommandsForEditorContextMenuMonaco = ThereAreAddedCommandsForEditorContextMenuMonaco(DocumentView);

			Info = New SystemInfo;
			DocumentView.init(Info.AppVersion);
			If EditorSettings.Language <> "bsl" Then
				DocumentView.setLanguageMode(EditorSettings.Language);

				If EditorSettings.Language = "bsl_query" Then
					DocumentView.setOption("renderQueryDelimiters", True);
					
					AddMenuItem(DocumentView,
									  ThereAreAddedCommandsForEditorContextMenuMonaco,
									  "INSERT_MACRO_COLUMN",
									  NStr("ru = 'Вставить макроколонку'; en = 'Insert macrocolumn'"));
				EndIf;
			EndIf;
			DocumentView.hideScrollX();
			DocumentView.hideScrollY();
			DocumentView.showStatusBar();
			DocumentView.enableQuickSuggestions();
			If ValueIsFilled(EditorSettings.EditorSettings.FontSize) Then
				DocumentView.setFontSize(EditorSettings.EditorSettings.FontSize);
			EndIf;
			If ValueIsFilled(EditorSettings.EditorSettings.LinesHeight) Then
				DocumentView.setLineHeight(EditorSettings.EditorSettings.LinesHeight);
			EndIf;

			DocumentView.disableKeyBinding(9);//esc
//			DocumentView.disableKeyBinding(2081); //ctrl+c
			DocumentView.setOption("generateDefinitionEvent", True);
			DocumentView.setOption("disableDefinitionMessage", True);
//			DocumentView.setOption("generateSnippetEvent", True);
			DocumentView.setOption("autoResizeEditorLayout", True);
			
			
			DocumentView.setOption("dragAndDrop", True);

			EditorThemes = UT_CodeEditorClientServer.MonacoEditorThemeVariants();
			If EditorSettings.EditorSettings.Theme = EditorThemes.Dark Then
				If EditorSettings.Language = "bsl_query" Then
					DocumentView.setTheme("bsl-dark-query");
				Else
					DocumentView.setTheme("bsl-dark");
				EndIf;
			Else
				If EditorSettings.Language = "bsl_query" Then
					DocumentView.setTheme("bsl-white-query");
				Else
					DocumentView.setTheme("bsl-white");
				EndIf;
			EndIf;

			ScriptVariants = UT_CodeEditorClientServer.MonacoEditorSyntaxLanguageVariants();
			If EditorSettings.EditorSettings.ScriptVariant = ScriptVariants.English Then
				DocumentView.switchLang("en");
			ElsIf EditorSettings.EditorSettings.ScriptVariant = ScriptVariants.Auto Then
				ScriptVariant = UT_ApplicationParameters["ConfigurationScriptVariant"];
				If ScriptVariant = "English" Then
					DocumentView.switchLang("en");
				EndIf;
			EndIf;

			DocumentView.minimap(EditorSettings.EditorSettings.UseScriptMap);

			If EditorSettings.EditorSettings.HideLineNumbers Then
				DocumentView.hideLineNumbers();
			EndIf;

			If EditorSettings.EditorSettings.DisplaySpacesAndTabs Then
				DocumentView.renderWhitespace(True);
			EndIf;

			If ValueIsFilled(EditorSettings.EditorEvents.OnChange) Then
				DocumentView.setOption("generateModificationEvent", True);
			EndIf;
						
			If EditorSettings.EditorSettings.UseCommandsForWorkingWithBufferInContextMenu Then
				AddMenuItem(DocumentView,
								  ThereAreAddedCommandsForEditorContextMenuMonaco,
								  "TOOLS_UI_1C_COPY_TO_CLIPBOARD",
								  "Копировать");
				AddMenuItem(DocumentView,
								  ThereAreAddedCommandsForEditorContextMenuMonaco,
								  "TOOLS_UI_1C_PASTE_FROM_CLIPBOARD",
								  "Вставить");
			EndIf;
			
			DocumentView.clearMetadata();

			ConfigurationDescriptionForInitialization = MetadataDescriptionForMonacoEditorInitialization();

			DocumentView.updateMetadata(UT_CommonClientServer.mWriteJSON(
				GetMetadataObjectsListFromCollectionForMonacoEditor(
				ConfigurationDescriptionForInitialization.CommonModules)), "commonModules.items");
				
			If Not EditorSettings.EditorSettings.Monaco.UseStandartCodeTemplates Then
				DocumentView.clearSnippets();
			EndIf;
		EndIf;
	
		If EditorSettings.TextEditorCache <> Undefined Then
			SetEditorText(Form, KeyValue.Key, EditorSettings.TextEditorCache.Text);
			SetEditorOriginalText(Form, KeyValue.Key, EditorSettings.TextEditorCache.OriginalText);
			EditorSettings.TextEditorCache = Undefined;
		EndIf;
		
		If EditorSettings.ViewOnly Then
			SetEditorViewOnlyMode(Form, KeyValue.Key, True);
		EndIf;		
	EndDo;
EndProcedure

Procedure CodeEditorDeferredInitializingEditors(Form) Export
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);
	EditorTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	InitializeFormEditorsAfterFieldsGeneration(Form, FormEditors, EditorType, EditorTypes);
	If Not UT_CodeEditorClientServer.CodeEditorsInitialInitializationPassed(Form) Then
		Form.Attachable_CodeEditorInitializingCompletion();
		UT_CodeEditorClientServer.SetFlagCodeEditorsInitialInitializationPassed(Form, True);
	EndIf;

	If EditorType = EditorTypes.Monaco Then
		BeginLoadingCodeTemplatesToEditors(Form, FormEditors);
	EndIf;
EndProcedure

#Region EditorInteraction

// Sets a text of an editor by a form item.
// 
//  Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField -An editor form field.
//  Text - String - An editor new text.
//  SetOriginalText - Boolean - if True, an original text of an editor is also sets.
Procedure SetFormItemEditorText(Form, Item, Text, SetOriginalText = False) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SetEditorText(Form, EditorID, Text, SetOriginalText);
EndProcedure

// Sets a text of an editor by an editor ID.
// 
//  Parameters:
//  Form - ClientApplicationForm - A form.
//  EditorID - String - An editor ID.
//  Text - String - An editor new text.
//  SetOriginalText - Boolean - if True, an original text of an editor is also sets.
Procedure SetEditorText(Form, EditorID, Text, SetOriginalText = False) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;
	
	If EditorType = EditorsTypes.Text Then
		Form[EditorSettings.AttributeName] = Text;
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.editor.setValue(Text, -1);
	ElsIf EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.updateText(Text);
		If SetOriginalText Then 
			HTMLDocument.setOriginalText(Text);
		EndIf;
	EndIf;
EndProcedure

// Sets an original text of an editor by a form item.
// Only for Monaco editor. 
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField -An editor form field.
//  Text - String - An editor original text.
Procedure SetFormItemEditorOriginalText(Form, Item, Text) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SetEditorOriginalText(Form, EditorID, Text);
EndProcedure

// Sets an original text of an editor by an editor ID.
// Only for Monaco editor. 
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
//  Text - String - An editor original text.
Procedure SetEditorOriginalText(Form, EditorID, Text) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;
	
	If EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.setOriginalText(Text);
	EndIf;
EndProcedure

// Sets an original text of an editor as equal to current editor.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String -An editor ID.
Procedure SetEditorOriginalTextEqualToCurrent(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;
	
	If EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.getText();
		HTMLDocument.setOriginalText(CodeText);
	Endif;
EndProcedure

// Returns a text of the editor code. 
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
// 
// Return value:
//  String - A form item editor code text.
Function EditorCodeText(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType    = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return "";
	EndIf;
	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		If Not EditorSettings.Visible
			And EditorSettings.TextEditorCache <> Undefined Then
				
			Return EditorSettings.TextEditorCache.Text;
		EndIf;
			
		Return "";
	EndIf;

	CodeText="";

	If EditorType = EditorsTypes.Text Then
		CodeText = Form[EditorSettings.AttributeName];
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.editor.getValue();
	ElsIf EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.getText();
	EndIf;

	Return TrimAll(CodeText);
EndFunction

// Returns a text of the editor code by the form item. 
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form item.
// 
// Return value:
//  String - A form item editor code text.
Function EditorCodeTextItemForm(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return "";
	EndIf;

	Return EditorCodeText(Form, EditorID);
EndFunction

// Return code editor original text.
// for editors other than monaco returns an empty string
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - string of ID
// 
// Return Value :
//  String
Function CodeEditorOriginalText(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	EditorParameters = FormEditors[EditorID];
	If Not EditorParameters.Initialized Then
		If Not EditorParameters.Visible
			And EditorParameters.TextEditorCache <> Undefined Then
				
			Return EditorParameters.TextEditorCache.OriginalText;
		EndIf;
	
		Return "";
	Endif;
	
	If EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorParameters.EditorField].Document.defaultView;
		Return HTMLDocument.getOriginalText();
	Else 
		Return "";
	EndIf;
	
EndFunction

/// Return code editor original text.
// for editors other than monaco returns an empty string
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField - Editor Item Form
// 
// Return 
//  String
Function CodeEditorOriginalTextFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return "";
	EndIf;

	Return CodeEditorOriginalText(Form, EditorID);
	
EndFunction

// Return current selection borders at editor.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - string of ID
// 
// Return Value :
//  SelectionBounds
Function EditorSelectionBorders(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return NewSelectionBorders();
	EndIf;

	EditorSettings = FormEditors[EditorID];

	SelectionBounds = NewSelectionBorders();
	If Not EditorSettings.Initialized Then
		Return SelectionBounds;
	EndIf;
		
	If EditorType = EditorsTypes.Text Then
		EditorItem = Form.Items[EditorSettings.EditorField];

		EditorItem.GetTextSelectionBounds(SelectionBounds.RowBeginning, SelectionBounds.ColumnBeginning,
			SelectionBounds.RowEnd, SelectionBounds.ColumnEnd);
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		SelectedArea = HTMLDocument.editor.getSelectionRange();

		SelectionBounds.RowBeginning= SelectedArea.start.row;
		SelectionBounds.ColumnBeginning = SelectedArea.start.column;
		SelectionBounds.RowEnd = SelectedArea.end.row;
		SelectionBounds.ColumnEnd = SelectedArea.end.column;
	ElsIf EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;

		Select = HTMLDocument.getSelection();
		SelectionBounds.RowBeginning= Select.startLineNumber;
		SelectionBounds.ColumnBeginning = Select.startColumn;
		SelectionBounds.RowEnd = Select.endLineNumber;
		SelectionBounds.ColumnEnd = Select.endColumn;
	EndIf;

	Return SelectionBounds;

EndFunction

// Return editor selection borders by form item.
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField - Editor Item Form
// 
// Return 
//  NewSelectionBorders()
//
Function EditorSelectionBordersFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return NewSelectionBorders();
	EndIf;

	Return EditorSelectionBorders(Form, EditorID);
EndFunction

// Sets a selection borders for an editor.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
//  RowBeginning - Number - Beginning of a row.
//  ColumnBeginning - Number - Beginning of a column.
//  RowEnd - Number - End of a row.
//  ColumnEnd - Number - End of a column.
//
Procedure SetTextSelectionBorders(Form, EditorID, RowBeginning, ColumnBeginning, RowEnd, ColumnEnd) Export

	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Text Then
		EditorItem = Form.Items[EditorSettings.EditorField];

		EditorItem.SetTextSelectionBorders(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.setSelection(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);
	ElsIf EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.setSelection(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);
	EndIf;

EndProcedure

// Sets a selection borders for an editor by a form item.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form item.
//  RowBeginning - Number - Beginning of a row.
//  ColumnBeginning - Number - Beginning of a column.
//  RowEnd - Number - End of a row.
//  ColumnEnd - Number - End of a column.
Procedure SetTextSelectionBordersFormItem(Form, Item, RowBeginning, ColumnBeginning, LineEnd, 
	ColumnEnd) Export

	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SetTextSelectionBorders(Form, EditorID, RowBeginning, ColumnBeginning, LineEnd, ColumnEnd);

EndProcedure

// Inserts text into cursor location
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
//  Text - String - A text to insert.
Procedure InsertTextInCursorLocation(Form, EditorID, Text) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Text Then
		EditorItem = Form.Items[EditorSettings.EditorField];
		EditorItem.SelectedText = Text;
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.editor.insert(Text);
	ElsIf EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		HTMLDocument.selectedText(Text);
	EndIf;
EndProcedure

// Inserts text into cursor location by form item
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form field.
//  Text - String - A text to insert.
Procedure InsertTextInCursorLocationFormItem(Form, Item, Text) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	InsertTextInCursorLocation(Form, EditorID, Text);

EndProcedure

// Return selected text of editor.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - ID Of Editor
// 
// Return value:
//  String - Editor selected text
//
Function EditorSelectedText(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return "";
	EndIf;
	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return "";
	EndIf;
	CodeText="";

	If EditorType = EditorsTypes.Text Then
		CodeText = Form.Items[EditorSettings.EditorField].SelectedText;
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.editor.getCopyText();
	ElsIf EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.selectedText();
	EndIf;

	Return TrimAll(CodeText);

EndFunction

// Return editor form item selected text. 
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor item form.
// 
// Return 
//  String - An editor selected text.
Function EditorSelectedTextFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return "";
	EndIf;

	Return EditorSelectedText(Form, EditorID);

EndFunction

// Adds the comments for the selected lines.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
Procedure AddCommentsToEditorLines(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;
	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Text Then
		CodeText = Form[EditorSettings.AttributeName];
		SelectionBorders = EditorSelectionBorders(Form, EditorID);

		AddAdditionToTextAtLineBeginningBySelectionBorders(CodeText, SelectionBorders, "//");
		Form[EditorSettings.AttributeName] = CodeText;

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.editor.getValue();

		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		SelectionBorders.RowBeginning= SelectionBorders.RowBeginning + 1;
		SelectionBorders.RowEnd = SelectionBorders.RowEnd + 1;

		AddAdditionToTextAtLineBeginningBySelectionBorders(CodeText, SelectionBorders, "//");

		HTMLDocument.editor.setValue(CodeText, -1);
		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning - 1, SelectionBorders.ColumnBeginning
			+ 2, SelectionBorders.RowEnd - 1, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Monaco Then
		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.addComment();

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);

	EndIf;

EndProcedure

// Adds the comments for the form item selected lines.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form item.
Procedure AddCommentsToEditorLinesFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	AddCommentsToEditorLines(Form, EditorID);
EndProcedure

// Deletes the comments in the selected lines.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
Procedure DeleteEditorLinesComments(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;
	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Text Then
		CodeText = Form[EditorSettings.AttributeName];
		SelectionBorders = EditorSelectionBorders(Form, EditorID);

		DeleteTextAdditionInLineBeginningBySelectionBorders(CodeText, SelectionBorders, "//");
		Form[EditorSettings.AttributeName] = CodeText;

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.editor.getValue();

		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		SelectionBorders.RowBeginning= SelectionBorders.RowBeginning + 1;
		SelectionBorders.RowEnd = SelectionBorders.RowEnd + 1;

		DeleteTextAdditionInLineBeginningBySelectionBorders(CodeText, SelectionBorders, "//");

		HTMLDocument.editor.setValue(CodeText, -1);
		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning - 1, SelectionBorders.ColumnBeginning
			+ 2, SelectionBorders.RowEnd - 1, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Monaco Then
		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.removeComment();

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);

	EndIf;

EndProcedure

// Deletes the comments in the selected lines.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form field.
Procedure DeleteEditorLinesCommentsFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	DeleteEditorLinesComments(Form, EditorID);
EndProcedure

// Adds an editor line breaks.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
Procedure AddEditorLineBreaks(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;
	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Text Then
		CodeText = Form[EditorSettings.AttributeName];
		SelectionBorders = EditorSelectionBorders(Form, EditorID);

		AddAdditionToTextAtLineBeginningBySelectionBorders(CodeText, SelectionBorders, "|");
		Form[EditorSettings.AttributeName] = CodeText;

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.editor.getValue();

		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		SelectionBorders.RowBeginning= SelectionBorders.RowBeginning + 1;
		SelectionBorders.RowEnd = SelectionBorders.RowEnd + 1;

		AddAdditionToTextAtLineBeginningBySelectionBorders(CodeText, SelectionBorders, "|");

		HTMLDocument.editor.setValue(CodeText, -1);
		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning - 1, SelectionBorders.ColumnBeginning
			+ 2, SelectionBorders.RowEnd - 1, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Monaco Then
		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.addWordWrap();

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);

	EndIf;

EndProcedure

// Adds a form item editor line breaks.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form item.
Procedure AddEditorLineBreaksFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	AddEditorLineBreaks(Form, EditorID);
EndProcedure

// Deletes an editor line breaks.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
Procedure DeleteEditorLineBreaks(Form, EditorID) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;
	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Text Then
		CodeText = Form[EditorSettings.AttributeName];
		SelectionBorders = EditorSelectionBorders(Form, EditorID);

		DeleteTextAdditionInLineBeginningBySelectionBorders(CodeText, SelectionBorders, "|");
		Form[EditorSettings.AttributeName] = CodeText;

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Ace Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.editor.getValue();

		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		SelectionBorders.RowBeginning= SelectionBorders.RowBeginning + 1;
		SelectionBorders.RowEnd = SelectionBorders.RowEnd + 1;

		DeleteTextAdditionInLineBeginningBySelectionBorders(CodeText, SelectionBorders, "|");

		HTMLDocument.editor.setValue(CodeText, -1);
		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning - 1, SelectionBorders.ColumnBeginning
			+ 2, SelectionBorders.RowEnd - 1, SelectionBorders.ColumnEnd + 2);
	ElsIf EditorType = EditorsTypes.Monaco Then
		SelectionBorders = EditorSelectionBorders(Form, EditorID);
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		CodeText = HTMLDocument.removeWordWrap();

		SetTextSelectionBorders(Form, EditorID, SelectionBorders.RowBeginning, SelectionBorders.ColumnBeginning + 2,
			SelectionBorders.RowEnd, SelectionBorders.ColumnEnd + 2);

	EndIf;

EndProcedure

// Deletes a form item editor line breaks.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form item.
Procedure DeleteEditorLineBreaksFormItem(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	DeleteEditorLineBreaks(Form, EditorID);
EndProcedure

// Sets new visibility for a code editor by an editor ID.
// If a NewVisibility parameter is passed, then the specified visibility is set.
// If a NewVisibility parameter is not passed, then the editor visibility is switched.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  EditorID - String - An editor ID.
//  NewVisibility -  Boolean - (optional) an editor item new visibility.
Procedure SwitchEditorVisibility(Form, EditorID, NewVisibility = Undefined) Export
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	EditorSettings = FormEditors[EditorID];
	
	Visible = NewVisibility;
	If Visible = Undefined Then
		Visible = Not EditorSettings.Visible;
	EndIf;
	If Not Visible Then
		TextEditorCache = UT_CodeEditorClientServer.NewTextCacheOfEditor();
		TextEditorCache.Text = EditorCodeText(Form, EditorID);
		TextEditorCache.OriginalText = CodeEditorOriginalText(Form, EditorID);
		
		EditorSettings.TextEditorCache = TextEditorCache;
	EndIf;
	
	EditorSettings.Visible = Visible;

	If Not Visible And UT_CodeEditorClientServer.CodeEditorUsesHTMLField(EditorType) Then
		EditorSettings.Initialized = False;
	EndIf;
	
	
	Form.Items[EditorSettings.EditorField].Visible = EditorSettings.Visible;
	
EndProcedure

// Sets new visibility for a code editor by an editor form item.
// If a NewVisibility parameter is passed, then the specified visibility is set.
// If a NewVisibility parameter is not passed, then the editor visibility is switched.
// 
// Parameters:
//  Form - ClientApplicationForm.
//  Item - FormField - An editor form item.
//  NewVisibility -  Boolean - (optional) an editor item new visibility.
Procedure SwitchFormItemEditorVisibility(Form, Item, NewVisibility = Undefined) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SwitchEditorVisibility(Form, EditorID, NewVisibility);
	
EndProcedure

// Получить режим только просмотр редактора.
// 
// Parameters:
//  Form - ClientApplicationForm-
//  EditorID - String - Идентификатор редактора
// 
// Return values:
// Булево 
Function EditorViewOnlyMode(Form, EditorID) Export
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	EditorOptions = FormEditors[EditorID];
	If Not EditorOptions.Initialized Then
		If Not EditorOptions.Visibility Then
				
			Return EditorOptions.ViewOnly;
		EndIf;
	
		Return False;
	EndIf;
	
	If EditorType = TypesOfEditors.Monaco Then
		DocumentHTML=Form.Items[EditorOptions.EditorField].Document.defaultView;
		Return DocumentHTML.getReadOnly();
	ElsIf EditorType = TypesOfEditors.Ace Then
		DocumentHTML=Form.Items[EditorOptions.EditorField].Document.defaultView;
		Return DocumentHTML.editor.getOption("readOnly");
	Иначе 
		Return Form.Items[EditorOptions.EditorField].ViewOnly;
	EndIf;
	
	
EndFunction

// Получить режим только просмотр редактора.
// 
// Parameters:
//  Form - ClientApplicationForm-
//  Элемент - FormField -
// 
// Return values:
// Булево 
Function FormItemEditorViewOnlyMode(Form, Элемент) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Элемент);
	If EditorID = Undefined Then
		Return False;
	EndIf;

	Return EditorViewOnlyMode(Form, EditorID);
EndFunction

// Установить режим только просмотр редактора.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - Идентификатор редактора
//  Mode - Boolean -
Procedure SetEditorViewOnlyMode(Form, EditorID, Mode) Export
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	EditorOptions = FormEditors[EditorID];
	EditorOptions.ViewOnly = Mode;
	
	If Not EditorOptions.Initialized Then
		Return;
	EndIf;
	
	If Not EditorOptions.Visibility Then
		Return;
	EndIf;
	
	If EditorType = TypesOfEditors.Monaco Then
		DocumentHTML = Form.Items[EditorOptions.EditorField].Document.defaultView;
		DocumentHTML.setReadOnly(Mode);
	ElsIf EditorType = TypesOfEditors.Ace Then
		DocumentHTML = Form.Items[EditorOptions.EditorField].Document.defaultView;
		DocumentHTML.editor.setOption("readOnly", Mode);
	Иначе 
		Form.Items[EditorOptions.EditorField].ViewOnly = Mode;
	EndIf;
	
EndProcedure

// Установить режим только просмотр редактора элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField -
//  Mode - Boolean -
Procedure FormItemSetEditorViewOnlyMode(Form, Item, Mode) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SetEditorViewOnlyMode(Form, EditorID, Mode);
EndProcedure

// Перейти к определению метода редактора.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - Идентификатор редактора
//  MethodName - String - Имя метода
Procedure GotoEditorMethodDefinition(Form, EditorID, MethodName) Export
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	EditorOptions = FormEditors[EditorID];
	
	If Not EditorOptions.Initialized Или Не EditorOptions.Visibility Then
		Return;
	EndIf;

	If EditorType = TypesOfEditors.Monaco Then
		DocumentHTML = Form.Items[EditorOptions.EditorField].Document.defaultView;
		DocumentHTML.goToFuncDefinition(MethodName);
		
//	ElsIf EditorType = TypesOfEditors.Ace Then
//		DocumentHTML=Form.Items[EditorOptions.EditorField].Document.defaultView;
//		DocumentHTML.editor.setOption("readOnly", Режим);
	EndIf;
	
	
EndProcedure

// Перейти к определению метода редактора элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField
//  MethodName - String - Имя метода
Procedure FormItemGotoEditorMethodDefinition(Form, Item, MethodName) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	GotoEditorMethodDefinition(Form, EditorID, MethodName);
	
EndProcedure

// Режим использования обработки для выполнения кода редактора.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - Идентификатор редактора
// 
// Return values:
//  Булево
Function UsageModeDataProcessorToExecuteEditorCode(Form, EditorID) Export
	FormEditors = UT_CodeEditorClientServer.FormEditors(Form);
	
	EditorOptions = FormEditors[EditorID];
	
	Return EditorOptions.UseDataProcessorToExecuteCode;
EndFunction

// Режим использования обработки для выполнения кода редактора.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField
// 
// Return values:
//  Булево
Function FormItemUsageModeDataProcessorToExecuteEditorCode(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return False;
	EndIf;

	Return UsageModeDataProcessorToExecuteEditorCode(Form, EditorID);
EndFunction

// Установить режим использования обработки для выполнения кода редактора.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  EditorID - String - Идентификатор редактора
//  Mode - Boolean -
Procedure SetUseModeDataProcessorToExecuteEditorCode(Form, EditorID, Mode) Export
	FormEditors = UT_CodeEditorClientServer.FormEditors(Form);
	
	EditorOptions = FormEditors[EditorID];
	EditorOptions.UseDataProcessorToExecuteCode = Mode;

	ButtonName = UT_CodeEditorClientServer.CommandBarButtonName(UT_CodeEditorClientServer.CommandNameExecutionModeThroughProcessing(),
																			  EditorID);
																			  
	Form.Items[ButtonName].Mark = Mode;

EndProcedure

// Установить режим использования обработки для выполнения кода редактора элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField
//  Mode - Boolean -
Procedure FormItemSetUseModeDataProcessorToExecuteEditorCode(Form, Item, Mode) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SetUseModeDataProcessorToExecuteEditorCode(Form, EditorID, Mode);
EndProcedure

// Начать сессию взаимодействия редактора кода.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
//  EditorID - String - Идентификатор редактора
Procedure StartCodeEditorInteractionSession(Form, EditorID) Export
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	If EditorType = TypesOfEditors.Text Then
		Return;
	EndIf;
	
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorOptions = FormEditors[EditorID]; //см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы
	If Not EditorOptions.Initialized Then
		Return;
	EndIf;
	
	If EditorType <> TypesOfEditors.Ace Then
		Return;
	EndIf;

	DocumentHTML = Form.Items[EditorOptions.EditorField].Document.defaultView;
	
	If Not ToFieldHTMLEditorConnectedInteractionScript(DocumentHTML) Then
		ConnectToFieldHTMLScriptInteraction(Form, EditorOptions, DocumentHTML);	
		Return;			
	EndIf;
	
	SesParameters = EditorOptions.InteractionSessionParameters;
	If SesParameters = Undefined Then
		SesParameters = UT_CodeEditorClientServer.NewOptionsSessionInteractions();
		EditorOptions.InteractionSessionParameters = SesParameters;
	EndIf;

	If Not ValueIsFilled(SesParameters.ID) Then
		SesParameters.ID = Format(CurrentUniversalDateInMilliseconds(), "ЧГ=0;")
										+ Form.UUID;
	EndIf;
	
	If ValueIsFilled(SesParameters.Username) Then
		DocumentHTML.colaborator.setUserName(SesParameters.Username);
	EndIf;
	
	If ValueIsFilled(SesParameters.InteractionsURL) Then
		DocumentHTML.colaborator.setColaborationUrl(SesParameters.InteractionsURL);
	EndIf;

	If EditorType = TypesOfEditors.Ace Then
		DocumentHTML.colaborator.start(SesParameters.ID);
	ElsIf EditorType = TypesOfEditors.Monaco Then
//		DocumentHTML=Form.Items[EditorOptions.EditorField].Document.defaultView;
//		DocumentHTML.updateText(Текст);
//		If УстанавливатьОригинальныйТекст Then
//			DocumentHTML.setOriginalText(Текст);
//		EndIf;
	EndIf;
	
EndProcedure

// Начать сессию взаимодействия редактора кода элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Элемент - FormField - Элемент формы редактора
Procedure ItemFormStartCodeEditorInteractionSession(Form, Элемент) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Элемент);
	If EditorID = Undefined Then
		Return;
	EndIf;

	StartCodeEditorInteractionSession(Form, EditorID);
EndProcedure

// Завершить сессию взаимодействия редактора кода.
// 
// Parameters:
//  Form - ClientApplicationForm
//  EditorID -String -Идентификатор редактора
Procedure FinishCodeEditorInteractionSession(Form, EditorID) Export
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	If EditorType = TypesOfEditors.Text Then
		Return;
	EndIf;
	
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorOptions = FormEditors[EditorID];
	If Not EditorOptions.Initialized Then
		Return;
	EndIf;
	
	If EditorType <> TypesOfEditors.Ace Then
		Return;
	EndIf;

	DocumentHTML = Form.Items[EditorOptions.EditorField].Document.defaultView;
	
	If Not ToFieldHTMLEditorConnectedInteractionScript(DocumentHTML) Then
		Return;			
	EndIf;

	If EditorType = TypesOfEditors.Ace Then
		DocumentHTML.colaborator.close();
	ElsIf EditorType = TypesOfEditors.Monaco Then
//		DocumentHTML=Form.Items[EditorOptions.EditorField].Document.defaultView;
//		DocumentHTML.updateText(Текст);
//		If УстанавливатьОригинальныйТекст Then
//			DocumentHTML.setOriginalText(Текст);
//		EndIf;
	EndIf;
	
	
EndProcedure

// Завершить сессию взаимодействия редактора кода элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField - Элемент формы редактора
Procedure FormItemFinishCodeEditorInteractionSession(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	FinishCodeEditorInteractionSession(Form, EditorID);
	
EndProcedure

// Установить язык редактора кода.
// 
// Parameters:
//  Form - ClientApplicationForm
//  EditorID - Строка - Идентификатор редактора
//  Language - String - Language
Procedure SetCodeEditorLanguage(Form, EditorID, Language) Export
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	If EditorType = TypesOfEditors.Text Then
		Return;
	EndIf;
	
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorOptions = FormEditors[EditorID];
	If Not EditorOptions.Initialized Then
		Return;
	EndIf;
	
	If EditorType <> TypesOfEditors.Ace Then
		Return;
	EndIf;

	DocumentView=Form.Items[EditorOptions.EditorField].Document.defaultView;

	EditorOptions.Language = Language;
	If EditorType = TypesOfEditors.Ace Then
		CurrentLanguage = Language;
		If CurrentLanguage = "bsl" Then
			CurrentLanguage = "_1c";
		EndIf;
		
		DocumentView.appTo1C.setMode(CurrentLanguage);
	ElsIf EditorType = TypesOfEditors.Monaco Then
		DocumentView.setLanguageMode(Language);
	EndIf;
	
EndProcedure

// Установить язык редактора кода элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField - Элемент формы редактора
//  Language - String
Procedure FormItemSetCodeEditorLanguage(Form, Item, Language) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	SetCodeEditorLanguage(Form, EditorID, Language);
EndProcedure

#EndRegion

// Преобразовать текст запроса из выражения встроенного языка редактора кода.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
//  EditorID - String - Идентификатор редактора
Procedure ConvertQueryTextFromExpressionBuiltInLanguageCodeEditor(Form, EditorID) Export
	CallbackSettings = New Structure;
	CallbackSettings.Insert("Form", Form);
	CallbackSettings.Insert("EditorID", EditorID);
	
	TextEditor = EditorCodeText(Form, EditorID);
	
	MinorSymbols = New Array;
	MinorSymbols.Add(" ");
	MinorSymbols.Add(Chars.NBSp);
	MinorSymbols.Add(Chars.Tab);
	MinorSymbols.Add("|");

	EditorTextDocument = New TextDocument();
	EditorTextDocument.SetText(TextEditor);

	FoundStart = False;
	LastSignificantLineNumber = 0;
	For LineNumber = 1 По EditorTextDocument.LineCount() Do
		CurrentCodeLine = EditorTextDocument.GetLine(LineNumber);
		
		For Each  CurrentSymbol In MinorSymbols Do
			While StrStartsWith(CurrentCodeLine, CurrentSymbol) Do
				CurrentCodeLine = Mid(CurrentCodeLine,2);				
			EndDo;
		EndDo;

		If FoundStart Then
			CurrentCodeLine = StrReplace(CurrentCodeLine, """""", """");
		EndIf;

		If StrStartsWith(CurrentCodeLine, """") Then
			CurrentCodeLine = Mid(CurrentCodeLine, 2);
		EndIf;

		EditorTextDocument.ReplaceLine(LineNumber,CurrentCodeLine);	
		If Not ValueIsFilled(CurrentCodeLine) And Not FoundStart Then
			Continue;
		EndIf;
		
		FoundStart = True;

		If ValueIsFilled(CurrentCodeLine) Then
			LastSignificantLineNumber = LineNumber;
		EndIf;
	EndDo;
	
	If LastSignificantLineNumber > 0 Then
		CurrentCodeLine = EditorTextDocument.GetLine(LastSignificantLineNumber);
		If StrEndsWith(CurrentCodeLine, """;") Then
			CurrentCodeLine = Лев(CurrentCodeLine, StrLen(CurrentCodeLine) - 2);
		ElsIf StrEndsWith(CurrentCodeLine, """") Or StrEndsWith(CurrentCodeLine, ";") Then
			CurrentCodeLine = Лев(CurrentCodeLine, StrLen(CurrentCodeLine) - 1);
		EndIf;
		
		EditorTextDocument.ReplaceLine(LastSignificantLineNumber,CurrentCodeLine);	
			
	EndIf;
	
	SetEditorText(Form, EditorID, EditorTextDocument.GetText());
EndProcedure

// Преобразовать текст запроса In выражения встроенного языка редактора кода.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField - Элемент формы редактора
Procedure ПреобразоватьТекстЗапросаИзВыраженияВстроенногоЯзыкаРедактораЭлементаФормы(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	ConvertQueryTextFromExpressionBuiltInLanguageCodeEditor(Form, EditorID);

EndProcedure

// Начать сессию взаимодействия с запросом параметров.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
//  EditorID - String - Идентификатор редактора
Procedure StartSessionInteractionWithCodeEditorParametersRequest(Form, EditorID) Export
	CallbackSettings = New Structure;
	CallbackSettings.Вставить("Form", Form);
	CallbackSettings.Вставить("EditorID", EditorID);

	FormOptions = New Structure;

	OpenForm("CommonForm.UT_CodeEditorInteractionSessionParameters",
				 FormOptions,
				 Form,
				 "" + Form.UUID + EditorID,
				 ,
				 ,
				 New CallbackDescription("StartSessionInteractionWithCodeEditorParametersRequestCompletionOfParameterEntry",
		ThisObject, CallbackSettings),
				 FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

// Начать сессию взаимодействия с запросом параметров редактора элемента формы.
// 
// Parameters:
//  Form - ClientApplicationForm -
//  Item - FormField - Элемент формы редактора
Procedure StartSessionInteractionWithFormItemEditorParametersRequest(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	StartSessionInteractionWithCodeEditorParametersRequest(Form, EditorID);
	
EndProcedure

Procedure AddCodeEditorContext(Form, EditorID, AddedContext) Export
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not AllFormEditorsInitialized(FormEditors) Then
		Return;
	EndIf;

	EditorSettings = FormEditors[EditorID];
	If Not EditorSettings.Initialized Then
		Return;
	EndIf;

	If EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.EditorField].Document.defaultView;
		
		TypesMap = ConfigurationReferenceTypesMap();
		
		AddingObjects = New Structure;
		
		FillMonacoCodeEditorContextStructure(AddingObjects, AddedContext, TypesMap);
		
		HTMLDocument.updateMetadata(UT_CommonClientServer.mWriteJSON(New Structure("customObjects", 
		AddingObjects)));
	EndIf;
EndProcedure

Procedure OpenQueryWizard(QueryText, CompletionNotifyDescription, CompositionMode = False) Export
#If Not MobileClient Then
	Wizard=New QueryWizard;
	If UT_CommonClientServer.PlatformVersionNotLess_8_3_14() Then
		Wizard.DataCompositionMode=CompositionMode;
	EndIf;

	If ValueIsFilled(TrimAll(QueryText)) Then
		Try
			Wizard.Text=QueryText;
		Except
			Message(ErrorDescription());
			Return;
		EndTry;
	EndIf;
	
	Wizard.Show(CompletionNotifyDescription);
#EndIf
EndProcedure

Procedure OpenFormatStringWizard(FormatString, CompletionNotifyDescription) Export
	Wizard = New FormatStringWizard;
	Try
		Wizard.Text = FormatString;
	Except
		Info = ErrorInfo();
		ShowMessageBox( , NStr("ru = 'Ошибка в тексте форматной строки:';|en = 'Error in the text of the format string:'") + Chars.LF + Info.Reason.Description);
		Return;
	EndTry;
	Wizard.Show(CompletionNotifyDescription);
EndProcedure

Procedure SaveConfigurationModulesToFiles(CompletionNotifyDescription, CurrentDirectories) Export
	NotificationAdditionalParameters = New Structure;
	NotificationAdditionalParameters.Insert("CompletionNotifyDescription", CompletionNotifyDescription);
	NotificationAdditionalParameters.Insert("CurrentDirectories", CurrentDirectories);

	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("SaveConfigurationModulesToFilesEndAttachFileSystemExtension", ThisObject,
		NotificationAdditionalParameters));

EndProcedure

Procedure InsertQueryEditorMacroColumn(Form, EditorID) Export
	NotificationParameters = New Structure;
	NotificationParameters.Insert("Form", Form);
	NotificationParameters.Insert("EditorID", EditorID);
	
	SelectedText = EditorSelectedText(Form, EditorID);
	FormParameters = New Structure;
	FormParameters.Insert("QueryColumn", SelectedText);
	OpenForm("DataProcessor.UT_QueryConsole.Form.MacroColumnChoice", FormParameters, Form, , , ,
		New NotifyDescription("InsertQueryEditorMacroColumnCompletion", ThisObject, NotificationParameters),
		FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

Procedure InsertFormItemQueryEditorMacroColumn(Form, Item) Export
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(Form, Item);
	If EditorID = Undefined Then
		Return;
	EndIf;

	InsertQueryEditorMacroColumn(Form, EditorID);
	
EndProcedure

// Поделиться кодом.
// 
// Parameters:
//  Code - String - Код
//  isRequest - Boolean - Это запрос
//  FormOwner - ClientApplicationForm -
Procedure ShareCode(Code, isRequest, FormOwner = Undefined) Export
	LinkToCode = UT_CodeEditorServerCall.LinkToCodeInServiceAfterDownload(Code, isRequest);
	If Not ValueIsFilled(LinkToCode) Then
		Return;
	EndIf;
	
	FormOptions = New Structure;
	FormOptions.Вставить("Link", LinkToCode);
	OpenForm("CommonForm.UT_RefToCodeForm",
				 FormOptions,
				 FormOwner,
				 ,
				 ,
				 ,
				 ,
				 FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

// Начать загрузку кода In сервиса.
// 
// Parameters:
//  CallbackDescription - CallbackDescription -  Описание оповещения
Procedure StartLoadingCodeFromService(CallbackDescription, FormOwner = Undefined) Export
	CallbackSettings = New Structure;
	CallbackSettings.Insert("CallbackDescriptionAboutCompletion", CallbackDescription);

	FormOptions = New Structure;
	FormOptions.Insert("InsertMode", True);
	
	OpenForm("CommonForm.UT_RefToCodeForm",
				 FormOptions,
				 FormOwner,
				 ,
				 ,
				 ,
				 New CallbackDescription("StartLoadingCodeFromServiceLinksInputCompletion", ThisObject,
		CallbackSettings),
				 FormWindowOpeningMode.LockOwnerWindow);
EndProcedure


#EndRegion

#Region Internal


// Начать сессию взаимодействия с запросом параметров редактора кода завершение ввода параметров.
// 
// Parameters:
//  Result - см. UT_CodeEditorClientServer.NewOptionsSessionInteractions
//  AdditionalParameters - Structure :
//  	* Form - ClientApplicationForm
//  	* EditorID - String
Procedure StartSessionInteractionWithCodeEditorParametersRequestCompletionOfParameterEntry(Result,
	AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	FormEditors = AdditionalParameters.Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	EditorOptions = FormEditors[AdditionalParameters.EditorID]; //см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы
	
	EditorOptions.InteractionSessionParameters = Result;
	

	StartCodeEditorInteractionSession(AdditionalParameters.Form,
											AdditionalParameters.EditorID);
EndProcedure

// Начать вставку из буфер обмена завершение получения текста.
// 
// Parameters:
//  Result - String - Result
//  AdditionalParameters - Structure -Дополнительные Parameters:
//  	* Form - ClientApplicationForm
//  	* Item - FormField
Procedure StartPastingFromClipboardCompletingReceiveText(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	InsertTextInCursorLocationFormItem(AdditionalParameters.Form, AdditionalParameters.Item, Result);
EndProcedure

Procedure StartCopyingSelectedTextToClipboardFinish(Result, CallOptions, AdditionalParameters) Export

EndProcedure

// Начать загрузку кода из сервиса завершение ввода ссылки.
// 
// Parameters:
//  Result - String, Undefined - Result
//  AdditionalParameters - Structure - Дополнительные Parameters:
//  	* CallbackDescriptionAboutCompletion - CallbackDescription -
Procedure StartLoadingCodeFromServiceLinksInputCompletion(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Not ValueIsFilled(Result) Then
		Return;
	EndIf;
	
	LinksData = UT_CodeEditorServerCall.AlgorithmDataInService(Result);
	
	If LinksData = Undefined Then
		Return;
	EndIf;
	
	RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, LinksData);
EndProcedure

// Начать загрузку кода In сервиса завершение.
// 
// Parameters:
//  Result - см. УИ_Paste1CAPI.НовыйДанныеАлгоритма
//  AdditionalParameters - Structure -Дополнительные Parameters:
//  	* Form - ClientApplicationForm
//  	* EditorID - String
Procedure StartLoadingCodeFromServiceCompletion(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	SetEditorText(AdditionalParameters.Form,
							 AdditionalParameters.EditorID,
							 Result.Text);
EndProcedure

// Начать сборку обработок для исполнения кода завершение сохранения шаблона обработки.
// 
// Parameters:
//  Successfully - Boolean - Result
//  AdditionalParameters - см. NewBuildParametersDataProcessorsForEditors
Procedure StartBuildDataProcessorForCodeExecutionDataProcessorsCompletingSavingTemplate(Successfully,
	AdditionalParameters) Export
	
	If Not Successfully Then
		Return;
	EndIf;
	
	UT_ConfiguratorManagementClient.StartGettingContextConfiguratorCommand(New CallbackDescription("StartBuildDataProcessorForCodeExecutionCompletingGetContextEditor",
		ThisObject, AdditionalParameters));


EndProcedure

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора.
// 
// Parameters:
//  DataProcessorsBuildOptions - см. NewBuildParametersDataProcessorsForEditors
//  CallbackDescriptionAboutCompletion -CallbackDescription -Description of the completion alert
Procedure StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditor(DataProcessorsBuildOptions,
	CallbackDescriptionAboutCompletion) Export

	EditorForBuild = DataProcessorsBuildOptions.EditorsForBuild[DataProcessorsBuildOptions.EditorIndexForBuild];

	ModuleFileName = UT_CommonClientServer.MergePaths(DataProcessorsBuildOptions.CatalogTemplateProcessing,
																	"DataProcessorTemplate",
																	"Ext",
																	"ObjectModule.bsl");
	
	// Module text
	Text = New TextDocument;
	If EditorForBuild.ExecutionAtClient Then
		Text.SetText("");
	Иначе
		Text.SetText(EditorForBuild.TextEditorForProcessing);
	EndIf;
	
	CallbackSettings = New Structure;
	CallbackSettings.Вставить("DataProcessorsBuildOptions", DataProcessorsBuildOptions);
	CallbackSettings.Вставить("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	CallbackSettings.Вставить("EditorForBuild", EditorForBuild);

	Text.BeginWriting(New CallbackDescription("StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletionOfModuleRecordProcessing",
		ThisObject, CallbackSettings), ModuleFileName, "UTF8");
EndProcedure

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение записи модуля обработки.
// 
// Parameters:
//  Result - Boolean, Undefined -Result
//  AdditionalParameters - Structure- Дополнительные Parameters:
//  	* DataProcessorsBuildOptions - см. NewBuildParametersDataProcessorsForEditors
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* EditorForBuild - см. UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor
Procedure StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletionOfModuleRecordProcessing(Result,
	AdditionalParameters) Export

	If Result <> True Then
		Return;
	EndIf;

	ModuleFileName = UT_CommonClientServer.MergePaths(UT_CommonClientServer.MergePaths(AdditionalParameters.DataProcessorsBuildOptions.CatalogTemplateProcessing,
																												   "DataProcessorTemplate",
																												   "Forms",
																												   "Form"),
																	"Ext", "Form", "Module.bsl");
	
	// Form text
	Text = New TextDocument;
	If AdditionalParameters.EditorForBuild.ExecutionAtClient Then
		Text.SetText(AdditionalParameters.EditorForBuild.TextEditorForProcessing);
	Иначе
		Text.SetText("");
	EndIf;
	Text.BeginWriting(New CallbackDescription("StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletingModuleFormRecord",
		ThisObject, AdditionalParameters), ModuleFileName, "UTF8");
	
EndProcedure

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение записи модуля обработки.
// 
// Parameters:
//  Result - Boolean, Undefined - Result
//  AdditionalParameters - Structure- Дополнительные Parameters:
//  	* DataProcessorsBuildOptions - см. NewBuildParametersDataProcessorsForEditors
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* EditorForBuild - см. UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor
Procedure StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletingModuleFormRecord(Result,
	AdditionalParameters) Export

	If Result <> True Then
		Return;
	EndIf;

	DataProcessorFileName = UT_CommonClientServer.MergePaths(AdditionalParameters.DataProcessorsBuildOptions.CatalogTemplateProcessing,
																	   "DataProcessorForEditor.epf");
	DataProcessorSourceFileName = UT_CommonClientServer.MergePaths(AdditionalParameters.DataProcessorsBuildOptions.CatalogTemplateProcessing,
																				"DataProcessorTemplate.xml");
	AdditionalParameters.Insert("DataProcessorFileName", DataProcessorFileName);

	UT_ConfiguratorManagementClient.StartBuildProcessingFromFiles(AdditionalParameters.DataProcessorsBuildOptions.ConfiguratorCommandContext,
																	DataProcessorSourceFileName,
																	DataProcessorFileName,
																	New CallbackDescription("StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletionOfFileFormationProcessing",
		ThisObject, AdditionalParameters));

EndProcedure

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение формирования файла обработки.
// 
// Parameters:
//  Result - Boolean -Result
//  AdditionalParameters - Structure- Дополнительные Parameters:
//  	* DataProcessorsBuildOptions - см. NewBuildParametersDataProcessorsForEditors
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* EditorForBuild - см. UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor
//  	* DataProcessorFileName - String
Procedure StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletionOfFileFormationProcessing(Result,
	AdditionalParameters) Export
	If Result <> True Then
		Return;
	EndIf;

	BeginCreateBinaryDataFromFile(New CallbackDescription("StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletionOfReceivingBinaryDataProcessing",
		ThisObject, AdditionalParameters), AdditionalParameters.DataProcessorFileName);
EndProcedure

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение получения двоичных данных обработки.
// 
// Parameters:
//  BinaryData - BinaryData- Result
//  AdditionalParameters - Structure- Дополнительные Parameters:
//  	* DataProcessorsBuildOptions - см. NewBuildParametersDataProcessorsForEditors
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
//  	* EditorForBuild - см. UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor
//  	* DataProcessorFileName - String
Procedure StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditorCompletionOfReceivingBinaryDataProcessing(BinaryData,
	AdditionalParameters) Export

	AddressOfBinaryDataInTemporaryStorage = PutToTempStorage(BinaryData,
													AdditionalParameters.DataProcessorsBuildOptions.Form.UUID);
	UT_CommonServerCall.ConnectExternalProcessingSession(AddressOfBinaryDataInTemporaryStorage,
													AdditionalParameters.EditorForBuild.ИмяПодключаемойОбработки);
																	  
		
	FormEditors = UT_CodeEditorClientServer.FormEditors(AdditionalParameters.DataProcessorsBuildOptions.Form);
	EditorOptions = FormEditors[AdditionalParameters.EditorForBuild.ID]; //см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы

	CacheResultsConnectionsProcessingExecution = UT_CodeEditorClientServer.NewCacheResultsConnectionsProcessingExecution();
	CacheResultsConnectionsProcessingExecution.TextEditor = AdditionalParameters.EditorForBuild.TextEditor;
	CacheResultsConnectionsProcessingExecution.ExecutionAtClient = AdditionalParameters.EditorForBuild.ExecutionAtClient;

	For Each Str In AdditionalParameters.EditorForBuild.NamesOfPredefinedVariables Do
		CacheResultsConnectionsProcessingExecution.NamesOfPredefinedVariables.Add(Lower(Str));
	EndDo;
	EditorOptions.CacheResultsConnectionsProcessingExecution = CacheResultsConnectionsProcessingExecution;

	RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, True);
EndProcedure

// Начать сборку обработок для исполнения кода завершение сборки обработки для очередного редактора.
// 
// Parameters:
//  Result -Булево-Result
//  AdditionalParameters - см. NewBuildParametersDataProcessorsForEditors
Procedure StartBuildDataProcessorForCodeExecutionCompletionOfBuildProcessingForNextEditor(Result,
	AdditionalParameters) Export
	If Result <> True Then
		Return;
	EndIf;
	
	AdditionalParameters.EditorIndexForBuild = AdditionalParameters.EditorIndexForBuild + 1;
	If AdditionalParameters.EditorIndexForBuild >= AdditionalParameters.EditorsForBuild.Количество() Then
		RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, True);
	Иначе
		StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditor(AdditionalParameters,
			New CallbackDescription("StartBuildDataProcessorForCodeExecutionCompletionOfBuildProcessingForNextEditor",
			ThisObject, AdditionalParameters));
	EndIf;
		
EndProcedure

// Начать сохранение шаблона обработки на диск завершение обеспечения каталога.
// 
// Parameters:
//  Successfully - Boolean - Successfully
//  AdditionalParameters - Structure:
//  	* CallbackDescriptionAboutCompletion-CallbackDescription
//  	* Directory - String
Procedure StartSavingProcessingTemplateToDiskFinishProvidingDirectory(Successfully, AdditionalParameters) Export
	If Not Successfully Then
		Return;
	EndIf;

	File = New File(UT_CommonClientServer.MergePaths(AdditionalParameters.Directory,
																	 "TemplateProcessing.xml"));
	File.BeginCheckingExistence(New CallbackDescription("StartSavingProcessingTemplateToDiskCompletingExistenceCheckOfSavedTemplate",
		ThisObject, AdditionalParameters));
EndProcedure

// Начать сохранение шаблона обработки на диск завершение проверки существования сохраненного шаблона.
// 
// Parameters:
//  Exists - Boolean - Exists
//  AdditionalParameters - Structure:
//  	* CallbackDescriptionAboutCompletion-CallbackDescription
//  	* Directory - String
Procedure StartSavingProcessingTemplateToDiskCompletingExistenceCheckOfSavedTemplate(Exists,
	AdditionalParameters) Export
	If Exists Then
		RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, True);
	Else
		AddressTemplateProcessingForSaving = UT_CommonServerCall.CommonTemplatesBinaryDataAddress("UT_TemplateProcessing");

		ArchiveFileName = UT_CommonClientServer.MergePaths(AdditionalParameters.Directory, "template.zip");
		AdditionalParameters.Insert("ArchiveFileName", ArchiveFileName);

		BinaryData = GetFromTempStorage(AddressTemplateProcessingForSaving); //BinaryData
		BinaryData.BeginWrite(New CallbackDescription("StartSavingProcessingTemplateToDiskCompletingSavingArchiveTemplate",
			ThisObject, AdditionalParameters), ArchiveFileName);
	EndIf;
EndProcedure

// Начать сохранение шаблона обработки на диск завершение сохранения архива шаблона.
// 
// Parameters:
//  AdditionalParameters - Structure:
//  	* CallbackDescriptionAboutCompletion-CallbackDescription
//  	* Каталог - String
//  	* ArchiveFileName - String
Procedure StartSavingProcessingTemplateToDiskCompletingSavingArchiveTemplate(AdditionalParameters) Export
#If Not WebClient And Not MobileClient Then
	ReadingZIP = New ZipFileReader(AdditionalParameters.ArchiveFileName);
	ReadingZIP.ExtractAll(AdditionalParameters.Directory, ZIPRestoreFilePathsMode.Restore);
	RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, True);
#Иначе
	RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, False);
#EndIf

EndProcedure


// Начать сборку обработок для исполнения кода завершение получения контекста редактора.
// 
// Parameters:
//  ConfiguratorContext - см. UT_ConfiguratorManagementClient.NewContextConfiguratorCommand, Undefined -Контекст конфигуратора
//  BuildOptions - см. NewBuildParametersDataProcessorsForEditors - Параметры сборки
Procedure StartBuildDataProcessorForCodeExecutionCompletingGetContextEditor(ConfiguratorContext,
	BuildOptions) Export

	If ConfiguratorContext = Undefined Then
		Return;
	EndIf;

	BuildOptions.ConfiguratorCommandContext = ConfiguratorContext;
	StartBuildDataProcessorForCodeExecutionBuildProcessingForNextEditor(BuildOptions,
																				New CallbackDescription("StartBuildDataProcessorForCodeExecutionCompletionOfBuildProcessingForNextEditor",
		ThisObject, BuildOptions));
EndProcedure

Procedure OpenModuleProcedureDefinitionCompletionOfReceivingTextModule(ModuleText, AdditionalParameters) Export
	FormOptions = New Structure;
	FormOptions.Insert("Code", ModuleText);
	FormOptions.Insert("ModuleName", AdditionalParameters.CurrentEvent.EventData.Module);
	FormOptions.Insert("MethodNameToGoToDefinition",
							AdditionalParameters.CurrentEvent.EventData.Word);

	OpenForm("CommonForm.UT_CodeForm",
				 FormOptions,
				 ,
				 Upper(AdditionalParameters.CurrentEvent.EventData.Module));
EndProcedure

Procedure FormOnOpenEndAttachFileSystemExtension(Result, AdditionalParameters) Export
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(AdditionalParameters.Form);
	DataLibrariesEditors =  AdditionalParameters.Form[UT_CodeEditorClientServer.AttributeNameCodeEditorLibraryURL()];
	
	LibraryData = DataLibrariesEditors[EditorType];
	If LibraryData = Undefined
		 Or Not ValueIsFilled(LibraryData)
		 Or TypeOf(LibraryData) = Type("Structure") Then
		FormOnOpenEndEditorLibrarySaving(True, AdditionalParameters);
	Иначе
		SaveEditorLibraryToDisk(LibraryData,
										   EditorType,
										   New CallbackDescription("FormOnOpenEndEditorLibrarySaving",
			ThisObject, AdditionalParameters));
	EndIf;
EndProcedure

Procedure FormOnOpenEndEditorLibrarySaving(Result, AdditionalParameters) Export
	Form = AdditionalParameters.Form;
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();

	If UT_CodeEditorClientServer.CodeEditorUsesHTMLField(EditorType) Then
		For Each KeyValue In Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()] Do
			//EditorAttributeName = UT_CodeEditorClientServer.AttributeNameCodeEditor(KeyValue.Value.AttributeName);	

			If EditorType = EditorsTypes.Monaco Then
				Form[KeyValue.Value.PropsName] = EditorSaveDirectory(EditorType) 
				+ GetPathSeparator() + "index.html";
//			ElsIf EditorType = EditorsTypes.Ace Then
//				Form[KeyValue.Value.PropsName] = AceEditorFileNameForLanguage(KeyValue.Value.Language);
			EndIf;
		EndDo;
	Else
		CodeEditorDeferredInitializingEditors(Form);
	EndIf;
	
	// We will notify about the completion of processing initialization of editors when opening the form
	CompletionNotifyDescription= AdditionalParameters.CompletionNotifyDescription;
	If CompletionNotifyDescription = Undefined Then
		Return;
	EndIf;

	ExecuteNotifyProcessing(CompletionNotifyDescription, True);
EndProcedure

Procedure SaveEditorLibraryToDiskEndLibraryDirectoryCreation(DirectoryName, AdditionalParameters) Export

	LibraryURL = AdditionalParameters.LibraryURL;
	
	SavedFilesArray = New Array;
	LibraryFilesMap = GetFromTempStorage(LibraryURL);

	AdditionalParameters.Вставить("SavedFilesArray", SavedFilesArray);
	AdditionalParameters.Вставить("LibraryFilesMap", LibraryFilesMap);

	SaveEditorLibraryWriteBeginWritingNextFile(AdditionalParameters);
EndProcedure

Procedure SaveEditorLibraryUnpackEditorLibraryToDirectory(AdditionalParameters, 
	NotifyDescriptionOnCompletion) Export
#If Not WebClient And Not MobileClient Then
	Stream=AdditionalParameters.LibraryFilesMap[AdditionalParameters.CurrentFileKey].OpenStreamForRead();

	ZipReader = New ZipFileReader(Stream);
	ZipReader.ExtractAll(AdditionalParameters.LibrarySavingDirectory, 
		ZIPRestoreFilePathsMode.Restore);

#EndIf

EndProcedure

Procedure SaveEditorLibraryUnpackEditorLibraryToDirectoryEnd(Result, 
	AdditionalParameters) Export

EndProcedure

Procedure SaveEditorLibraryWriteBeginWritingNextFileEnd(AdditionalParameters) Export
	SavedFilesArray = AdditionalParameters.SavedFilesArray;
	SavedFilesArray.Add(AdditionalParameters.CurrentFileKey);

	File = New File(AdditionalParameters.CurrentFileKey);

	If File.Extension = ".zip" Then
		SaveEditorLibraryUnpackEditorLibraryToDirectory(AdditionalParameters,
			New NotifyDescription("SaveEditorLibraryUnpackEditorLibraryToDirectoryEnd", ThisObject,
			AdditionalParameters));
	EndIf;	
		//Else
	SaveEditorLibraryWriteBeginWritingNextFile(AdditionalParameters);
	//EndIf;
EndProcedure

Procedure SaveEditorLibraryWriteBeginWritingNextFileOfTextDocumentEnd(Result, 
	AdditionalParameters) Export
	SavedFilesArray = AdditionalParameters.SavedFilesArray;
	SavedFilesArray.Add(AdditionalParameters.CurrentFileKey);

	SaveEditorLibraryWriteBeginWritingNextFile(AdditionalParameters);
EndProcedure

Procedure SaveEditorLibraryToDiskEndCheckOfLibraryExistOnDisk(Exists, 
	AdditionalParameters) Export
	If Exists Then
		ExecuteNotifyProcessing(AdditionalParameters.CompletionNotifyDescription);
		Return;
	EndIf;

	LibrarySavingDirectory = AdditionalParameters.LibrarySavingDirectory;

	BeginCreatingDirectory(
		New NotifyDescription("SaveEditorLibraryToDiskEndLibraryDirectoryCreation", ThisObject, AdditionalParameters),
		LibrarySavingDirectory);

EndProcedure

Procedure SaveConfigurationModulesToFilesEndAttachFileSystemExtension(Result, 
	AdditionalParameters) Export
	FormParameters = New Structure;
	FormParameters.Insert("CurrentDirectories", AdditionalParameters.CurrentDirectories);

	NotificationAdditionalParameters = New Structure;
	NotificationAdditionalParameters.Insert("CompletionNotifyDescription",
		AdditionalParameters.CompletionNotifyDescription);

	OpenForm("CommonForm.UT_ConfigurationSourseFilesSaveSettings", FormParameters, , , , ,
		New NotifyDescription("SaveConfigurationModulesToFilesEndSettings", ThisObject,
		NotificationAdditionalParameters), FormWindowOpeningMode.Independent);

EndProcedure

Procedure SaveConfigurationModulesToFilesEndSettings(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ConfigurationMetadataDescription = UT_CodeEditorServerCall.ConfigurationMetadataDescription(False);

	SourceFilesSavingParameters = New Structure;
	SourceFilesSavingParameters.Insert("ConfigurationMetadataDescription", ConfigurationMetadataDescription);
	SourceFilesSavingParameters.Insert("Parameters", Result);
	SourceFilesSavingParameters.Insert("AdditionalParameters", AdditionalParameters);
	SourceFilesSavingParameters.Insert("DirectoryIndex", 0);

	SaveConfigurationModulesToFilesBeginProcessingSourceDirectory(SourceFilesSavingParameters);

EndProcedure

Procedure SaveConfigurationModulesToFilesBeginProcessingSourceDirectory(SaveOptions)
	If SaveOptions.DirectoryIndex >= SaveOptions.Parameters.SourceDirectories.Count() Then
		SaveConfigurationModulesToFilesEnd(SaveOptions);
		Return;
	EndIf;

	SourceDirectoryDescription = SaveOptions.Parameters.SourceDirectories[SaveOptions.DirectoryIndex];

	SaveOptions.Insert("SourceDirectoryDescription", SourceDirectoryDescription);
	
	//First you need to clear the directory
	BeginDeletingFiles(New NotifyDescription("SaveConfigurationModulesToFilesEndOfDirectoryFilesDeleting", ThisObject,
		SaveOptions), SourceDirectoryDescription.Directory, "*");

EndProcedure

Procedure SaveConfigurationModulesToFilesEndOfDirectoryFilesDeleting(SaveOptions) Export
	If SaveOptions.SourceDirectoryDescription.OnlyModules Then
		SaveConfigurationModulesToFilesSaveMetadataListWithModules(SaveOptions);
	Else
		SaveConfigurationModulesToFilesRunDesignerForMetadataDump(SaveOptions);
	EndIf;
EndProcedure

Procedure SaveConfigurationModulesToFilesSaveMetadataListWithModules(SaveOptions) Export
	MetadataText = New TextDocument;

	If SaveOptions.SourceDirectoryDescription.Source <> "MainConfiguration" Then
		ExtensionName = SaveOptions.SourceDirectoryDescription.Source;
	Else
		ExtensionName = Undefined;
	EndIf;

	For Each CurrentCollection In SaveOptions.ConfigurationMetadataDescription Do
		If TypeOf(CurrentCollection.Value) <> Type("Structure") Then
			Continue;
		EndIf;

		If CurrentCollection.Key = "Catalogs" Then
			CollectionNameForFile = "Catalog";
		ElsIf CurrentCollection.Key = "Documents" Then
			CollectionNameForFile = "Document";
		ElsIf CurrentCollection.Key = "InformationRegisters" Then
			CollectionNameForFile = "InformationRegister";
		ElsIf CurrentCollection.Key = "AccumulationRegisters" Then
			CollectionNameForFile = "AccumulationRegister";
		ElsIf CurrentCollection.Key = "AccountingRegisters" Then
			CollectionNameForFile = "AccountingRegister";
		ElsIf CurrentCollection.Key = "CalculationRegisters" Then
			CollectionNameForFile = "CalculationRegister";
		ElsIf CurrentCollection.Key = "DataProcessors" Then
			CollectionNameForFile = "DataProcessor";
		ElsIf CurrentCollection.Key = "Reports" Then
			CollectionNameForFile = "Report";
		ElsIf CurrentCollection.Key = "Enums" Then
			CollectionNameForFile = "Enum";
		ElsIf CurrentCollection.Key = "CommonModules" Then
			CollectionNameForFile = "CommonModule";
		ElsIf CurrentCollection.Key = "ChartsOfAccounts" Then
			CollectionNameForFile = "ChartOfAccounts";
		ElsIf CurrentCollection.Key = "BusinessProcesses" Then
			CollectionNameForFile = "BusinessProcess";
		ElsIf CurrentCollection.Key = "Tasks" Then
			CollectionNameForFile = "Task";
		ElsIf CurrentCollection.Key = "ExchangePlans" Then
			CollectionNameForFile = "ExchangePlan";
		ElsIf CurrentCollection.Key = "ChartsOfCharacteristicTypes" Then
			CollectionNameForFile = "ChartOfCharacteristicTypes";
		ElsIf CurrentCollection.Key = "ChartsOfCalculationTypes" Then
			CollectionNameForFile = "ChartOfCalculationTypes";
		ElsIf CurrentCollection.Key = "Constants" Then
			CollectionNameForFile = "Constant";
		Else
			Continue;
		EndIf;

		For Each MetadataKeyValue In CurrentCollection.Value Do
			If MetadataKeyValue.Value.Extension <> ExtensionName Then
				Continue;
			EndIf;
			MetadataText.AddRow(CollectionNameForFile + "." + MetadataKeyValue.Key);
		EndDo;
	EndDo;

	SessionFileVariablesStructure = UT_CommonClient.SessionFileVariablesStructure();
	SaveFileName = SessionFileVariablesStructure.TempFilesDirectory + GetPathSeparator()+ "tools_ui_1c_int_list_metadata.txt";
	SaveOptions.Insert("MetadataListFileName", SaveFileName);
	MetadataText.BeginWriting(
		New NotifyDescription("SaveConfigurationModulesToFilesSaveMetadataListWithModulesEnd", ThisObject,
		SaveOptions), SaveFileName);

EndProcedure

Procedure SaveConfigurationModulesToFilesSaveMetadataListWithModulesEnd(Result, SaveOptions) Export
	If Result <> True Then
		Message(Nstr("ru = 'Не удалось сохранить список метаданных с модулями в файл для источника';
					 |en = 'The list of metadata with modules could not be saved to a file for the source'")
			+ SaveOptions.SourceDirectoryDescription.Source);
		SaveOptions.DirectoryIndex = SaveOptions.DirectoryIndex + 1;
		SaveConfigurationModulesToFilesBeginProcessingSourceDirectory(SaveOptions);
		Return;
	EndIf;

	SaveConfigurationModulesToFilesRunDesignerForMetadataDump(SaveOptions);

EndProcedure

Procedure SaveConfigurationModulesToFilesRunDesignerForMetadataDump(SaveOptions) Export
	RunAppString = UT_StringFunctionsClientServer.WrapInOuotationMarks(
		SaveOptions.Parameters.PlatformLaunchFile) + " DESIGNER";

	If SaveOptions.Parameters.InfobasePlacement = 0 Then
		RunAppString = RunAppString + " /F " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			SaveOptions.Parameters.InfobaseDirectory);
	Else
		DatabasePath = SaveOptions.Parameters.InfobaseServer + "\" + SaveOptions.Parameters.InfoBaseName;
		RunAppString = RunAppString + " /S " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			DatabasePath);
	EndIf;
	RunAppString = RunAppString + " /N" + UT_StringFunctionsClientServer.WrapInOuotationMarks(
		SaveOptions.Parameters.User);

	If ValueIsFilled(SaveOptions.Parameters.Password) Then
		RunAppString = RunAppString + " /P" + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			SaveOptions.Parameters.Password);
	EndIf;
	RunAppString = RunAppString + " /DisableStartupMessages /DisableStartupDialogs";

	RunAppString = RunAppString + " /DumpConfigToFiles " 
		+ UT_StringFunctionsClientServer.WrapInOuotationMarks(SaveOptions.SourceDirectoryDescription.Directory) 
		+ " -format Hierarchical";

	If SaveOptions.SourceDirectoryDescription.Source <> "MainConfiguration" Then
		RunAppString = RunAppString + " -Extension " 
		+ SaveOptions.SourceDirectoryDescription.Source;
	EndIf;
	If SaveOptions.SourceDirectoryDescription.OnlyModules Then
		RunAppString = RunAppString + " -listFile " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			SaveOptions.MetadataListFileName);

	EndIf;
	SessionFileVariablesStructure = UT_CommonClient.SessionFileVariablesStructure();

	SaveOptions.Insert("RunDesignerLogFileName", 
		SessionFileVariablesStructure.TempFilesDirectory + GetPathSeparator()
		+ "tools_ui_1c_int_list_metadata_out.txt");

	RunAppString = RunAppString + " /Out " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
		SaveOptions.RunDesignerLogFileName);

	BeginRunningApplication(
		New NotifyDescription("SaveConfigurationModulesToFilesOnEndMetadataDumpToDirectory", 
		ThisObject, SaveOptions),RunAppString, , True);
EndProcedure

Procedure SaveConfigurationModulesToFilesOnEndMetadataDumpToDirectory(CompletionCode, 
	SaveOptions) Export
	If CompletionCode <> 0 Then
		TextDocument = New TextDocument;

		NotificationAdditionalParameters = New Structure;
		NotificationAdditionalParameters.Insert("TextDocument", TextDocument);
		NotificationAdditionalParameters.Insert("SaveOptions", SaveOptions);

		TextDocument.BeginReading(
			New NotifyDescription("SaveConfigurationModulesToFilesOnEndMetadataDumpToDirectoryEndLogReading",
			ThisObject, NotificationAdditionalParameters), SaveOptions.RunDesignerLogFileName);
		Return;
	EndIf;
	SaveOptions.DirectoryIndex = SaveOptions.DirectoryIndex + 1;
	SaveConfigurationModulesToFilesBeginProcessingSourceDirectory(SaveOptions);
EndProcedure

Procedure SaveConfigurationModulesToFilesOnEndMetadataDumpToDirectoryEndLogReading(AdditionalParameters) Export
	SaveOptions = AdditionalParameters.SaveOptions;
	TextDocument = AdditionalParameters.TextDocument;
	Message(Nstr("ru = 'Не удалось сохранить исходные файлы для источника';
				 |en = 'Could not save the source files for the source'")
		+ SaveOptions.SourceDirectoryDescription.Source + ":" + Chars.LF + TextDocument.GetText());
	SaveOptions.DirectoryIndex = SaveOptions.DirectoryIndex + 1;
	SaveConfigurationModulesToFilesBeginProcessingSourceDirectory(SaveOptions);

EndProcedure

Procedure SaveConfigurationModulesToFilesEnd(SaveOptions)
	ExecuteNotifyProcessing(SaveOptions.AdditionalParameters.CompletionNotifyDescription,
		SaveOptions.Parameters.SourceDirectories);
EndProcedure

Procedure BeginLoadingCodeTemplatesToEditorsCompletion(Result, AddlParameters) Export
	If Result.Count()=0 Then
		Return;
	EndIf;
	
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(AddlParameters.Form);
	EditorTypes = UT_CodeEditorClientServer.CodeEditorVariants();
	FormEditors = AddlParameters.Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	
	If EditorType<>EditorTypes.Monaco Then
		Return;
	EndIf;
	
	For Each EditorKeyValue In FormEditors Do
		EditorSettings = EditorKeyValue.Value;
		If Not EditorSettings.Initialized Then
			Return;
		EndIf;
		EditorFormItem = AddlParameters.Form.Items[EditorSettings.EditorField];

		DocumentView = EditorFormItem.Document.defaultView;
//		DocumentView.clearSnippets();
		For Each CurrTemplateText In Result Do
			DocumentView.parseSnippets(CurrTemplateText, True);
		EndDo;	
	EndDo;
EndProcedure

Procedure BeginReadingCodeTemplateFileCompletion(AdditionalParameters) Export
	TemplatesText = AdditionalParameters.TextDocument.GetText();
	AdditionalParameters.TemplatesTexts.Add(TemplatesText);
	
	BeginReadingCodeTemplateFile(AdditionalParameters);
EndProcedure


Procedure BeginReadingCodeTemplateFileCheckingExistenceCompletion(Exists, AdditionalParameters) Export

	If Exists Then
		Text = New TextDocument();
		
		AdditionalParameters.Insert("TextDocument", Text);
		NotifyDescription = New NotifyDescription("BeginReadingCodeTemplateFileCompletion", ThisObject,
			AdditionalParameters);
			
		Text.BeginReading(NotifyDescription, AdditionalParameters.FileName);
	Else
		BeginReadingCodeTemplateFile(AdditionalParameters);
	EndIf;
	
EndProcedure

Procedure InsertQueryEditorMacroColumnCompletion(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	UT_CodeEditorClient.InsertTextInCursorLocation(AdditionalParameters.Form,
		AdditionalParameters.EditorID, Result);
	
EndProcedure

// Start searching for a module file in the source file directories. Finish searching for files..
// 
// Parameters:
//  FoundFiles -Array of Файл -Найденные файлы
//  SearchOptions - Structure - Параметры поиска:
// 		* CallbackDescriptionAboutCompletion - CallbackDescription -
// 		* SourcesDirectories - Array of см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
// 		* SourcesDirectoryIndex - Number -
// 		* ModuleName - String -
// 		* ArrayOfModuleNames - Array of String -
// 		* ModuleDirectory - String -
// 		* FileName - String -
// 		* IsCommonModule - Boolean -
// 		* SearchFileDirectoryName - String -
// 		* CallbackDescriptionCompleteSearchFile - CallbackDescription -
Procedure StartSearchingForModuleFileInSourceFileDirectoriesCompletingFileSearch(FoundFiles, SearchOptions) Export
	Если FoundFiles = Неопределено Тогда
		SearchOptions.SourcesDirectoryIndex = SearchOptions.SourcesDirectoryIndex + 1;
		StartSearchingForModuleFilesInSourceFileDirectories(SearchOptions,
													  SearchOptions.CallbackDescriptionCompleteSearchFile);
		Возврат;
	КонецЕсли;

	Если FoundFiles.Count() = 0 Тогда
		SearchOptions.SourcesDirectoryIndex = SearchOptions.SourcesDirectoryIndex + 1;
		StartSearchingForModuleFilesInSourceFileDirectories(SearchOptions,
													  SearchOptions.CallbackDescriptionCompleteSearchFile);
		Возврат;
	КонецЕсли;

	FileName = FoundFiles[0].FullName;
	RunCallback(SearchOptions.CallbackDescriptionCompleteSearchFile, FileName);
	
EndProcedure

// Start retrieving module text In source files finish searching for files.
// 
// Parameters:
//  FileName -Строка-Имя файла
//  AdditionalParameters - Structure - Параметры поиска:
// 		* CallbackDescriptionAboutCompletion - CallbackDescription -
// 		* SourcesDirectories - Array of см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
// 		* SourcesDirectoryIndex - Number -
// 		* ModuleName - String -
// 		* ArrayOfModuleNames - Array of String -
// 		* ModuleDirectory - String -
// 		* FileName - String -
// 		* IsCommonModule - Boolean -
// 		* SearchFileDirectoryName - String -
// 		* CallbackDescriptionCompleteSearchFile - CallbackDescription -
Procedure StartGettingModuleTextFromSourceFilesCompletingFileSearch(FileName, AdditionalParameters) Export
	TextDocument = New TextDocument;

	AdditionalParameters.Вставить("TextDocument", TextDocument);
	TextDocument.BeginReading(New CallbackDescription("StartGettingModuleTextFromSourceFilesCompletingReadingModuleTextFromFile",
		ThisObject, AdditionalParameters), FileName, "UTF8");

EndProcedure

// Start getting module text from source files finish reading module text from file.
// 
// Parameters:
//  AdditionalParameters -Structure -Дополнительные Parameters:
//  	* TextDocument - TextDocument
//  	* CallbackDescriptionAboutCompletion - CallbackDescription
Procedure StartGettingModuleTextFromSourceFilesCompletingReadingModuleTextFromFile(AdditionalParameters) Export
	ModuleText = AdditionalParameters.TextDocument.GetText();
	RunCallback(AdditionalParameters.CallbackDescriptionAboutCompletion, ModuleText);
EndProcedure

#Region Monaco

Procedure OnEndEditMonacoFormattedString(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	FormatString = StrReplace(Text, "'", "");
	FormatString = """" + FormatString + """";

	DocumentView = AdditionalParameters.Form.Items[AdditionalParameters.Item.Name].Document.defaultView;

	If AdditionalParameters.Property("Position") Then
		SetTextMonaco(DocumentView, FormatString, UT_CommonClientServer.mWriteJSON(
			AdditionalParameters.Position), True);
	Else
		SetTextMonaco(DocumentView, FormatString, , True);
	EndIf;
EndProcedure

Procedure OnEndEditMonacoQuery(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	isQueryMode = False;
	If AdditionalParameters.Property("isQueryMode") Then
		isQueryMode = AdditionalParameters.isQueryMode;
	Endif;
	
	If isQueryMode Then
		QueryText = Text;
	Else
		QueryText = StrReplace(Text, Chars.LF, Chars.LF + "|");
		QueryText = StrReplace(QueryText, """", """""");
		QueryText = """" + QueryText + """";
	EndIf;

     DocumentView = AdditionalParameters.Form.Items[AdditionalParameters.Item.Name].Document.defaultView;
     
	If AdditionalParameters.Property("Position") Then
		If AdditionalParameters.Position.startLineNumber = AdditionalParameters.Position.endLineNumber
			And AdditionalParameters.Position.startColumn = AdditionalParameters.Position.endColumn Then
			DocumentView.updateText(QueryText);
		Else
			SetTextMonaco(DocumentView, QueryText, UT_CommonClientServer.mWriteJSON(
			AdditionalParameters.Position), True);
		Endif;
	Else
		SetTextMonaco(DocumentView, QueryText, , True);
	EndIf;
	
	DocumentView.sendEvent("EVENT_CONTENT_CHANGED");
		
EndProcedure

Procedure OpenMonacoQueryWizardQuestionCompletion(Result, AdditionalParameters) Export
	If Result <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	OpenQueryWizard("", New NotifyDescription("OnEndEditMonacoQuery", ThisObject, 
		AdditionalParameters));

EndProcedure

Procedure OpenMonacoFormatStringWizardQuestionCompletion(Result, AdditionalParameters) Export
	If Result <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	OpenFormatStringWizard("", New NotifyDescription("OnEndEditMonacoFormattedString", ThisObject,
		AdditionalParameters));

EndProcedure
#EndRegion
#EndRegion

#Region Private

Procedure StartSavingProcessingTemplateToDisk(Directory, CallbackDescriptionAboutCompletion)
	SettingsCallback = New Structure;
	SettingsCallback.Вставить("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	SettingsCallback.Вставить("Directory", Directory);

	UT_CommonClient.BeginCatalogProviding(Directory,
											New CallbackDescription("StartSavingProcessingTemplateToDiskFinishProvidingDirectory",
		ThisObject, SettingsCallback));
EndProcedure


Procedure BeginLoadingCodeTemplatesToEditors(Form, FormEditors)
	EditorSettings = Undefined;
	For Each KeyValue In FormEditors Do
		EditorSettings = KeyValue.Value.EditorSettings;
		Break;
	EndDo;
	
	If EditorSettings.Monaco.CodeTemplatesFiles.Count() = 0 Then
		Return;
	EndIf;
	
	AddlParameters = New Structure;
	AddlParameters.Insert("CodeTemplatesFiles", EditorSettings.Monaco.CodeTemplatesFiles);
	AddlParameters.Insert("TemplateTexts", New Array);
	AddlParameters.Insert("ReadindFileIndex", 0);
	AddlParameters.Insert("CompletingNotifyDescription",
		New NotifyDescription("BeginLoadingCodeTemplatesToEditorsCompletion", ThisObject, New Structure("Form",
		Form)));

	BeginReadingCodeTemplateFile(AddlParameters);
	
EndProcedure

Procedure BeginReadingCodeTemplateFile(AdditionalParameters)
	If AdditionalParameters.CodeTemplatesFiles.Count() <= AdditionalParameters.ReadindFileIndex Then
		ExecuteNotifyProcessing(AdditionalParameters.CompletingNotifyDescription,
			AdditionalParameters.TemplateTexts);

		Return;
	EndIf;
	
	ReadingFileName = AdditionalParameters.CodeTemplatesFiles[AdditionalParameters.ReadindFileIndex];
	AdditionalParameters.Insert("FileName", ReadingFileName);
	AdditionalParameters.ReadindFileIndex = AdditionalParameters.ReadindFileIndex + 1;

	File = New File(ReadingFileName);
	File.BeginCheckingExistence(
		New NotifyDescription("BeginReadingCodeTemplateFileCheckingExistenceCompletion",
		ThisObject, AdditionalParameters));
EndProcedure

Procedure AddAdditionToTextAtLineBeginningBySelectionBorders(CodeText, SelectionBorders, Addition)
	Text = New TextDocument;
	Text.SetText(CodeText);

	If SelectionBorders = Undefined Then
		RowBeginning = 1;
		RowEnd = Text.Count();
	Else
			
		If Not ValueIsFilled(SelectionBorders.RowBeginning) And Not ValueIsFilled(SelectionBorders.RowEnd) Then
			Return;
		EndIf;
		RowBeginning = SelectionBorders.RowBeginning;
		RowEnd = SelectionBorders.RowEnd;
				
	EndIf;

	For LineNumber = RowBeginning To RowEnd Do
		TextLine = Text.GetLine(LineNumber);
		Text.ReplaceLine(LineNumber, Addition + TextLine);
	EndDo;
	CodeText = Text.GetText();
EndProcedure

Procedure DeleteTextAdditionInLineBeginningBySelectionBorders(CodeText, SelectionBorders, Addition)
	Text = New TextDocument;
	Text.SetText(CodeText);
	
	If SelectionBorders = Undefined Then
		RowBeginning = 1;
		RowEnd = Text.Count();
	Else

		If Not ValueIsFilled(SelectionBorders.RowBeginning) And Not ValueIsFilled(SelectionBorders.RowEnd) Then
			Return;
		EndIf;
		RowBeginning = SelectionBorders.RowBeginning;
		RowEnd = SelectionBorders.RowEnd;

	EndIf;
	
	For LineNumber = RowBeginning To RowEnd Do
		TextLine = Text.GetLine(LineNumber);
		If StrStartsWith(TextLine, Addition) Then
			TextLine = Mid(TextLine, StrLen(Addition) + 1);
		EndIf;

		Text.ReplaceLine(LineNumber, TextLine);
	EndDo;
	CodeText = Text.GetText();
EndProcedure

Function CodeEditorNewEventForProcessing()
	Event = New Structure;
	Event.Insert("Item");
	Event.Insert("EventName");
	Event.Insert("EventData");

	Return Event;
EndFunction

Function PrepareTextForQueryWizard(Text)

	QueryText = StrReplace(Text, "|", "");
	QueryText = StrReplace(QueryText, """""", "$");
	QueryText = StrReplace(QueryText, """", "");
	QueryText = StrReplace(QueryText, "$", """");

	Return QueryText;
EndFunction

Function NewSelectionBorders()
	Borders = New Structure;
	Borders.Insert("RowBeginning", 1);
	Borders.Insert("ColumnBeginning", 1);
	Borders.Insert("RowEnd", 1);
	Borders.Insert("ColumnEnd", 1);

	Return Borders;
EndFunction

#Region Monaco

Procedure FillMonacoCodeEditorContextStructure(AddingObjects, AddedContext, TypesMap)
	For Each KeyValue In AddedContext Do
		AddedObject = New Structure("ref,name");
		AddedObject.name = KeyValue.Key;
		If TypeOf(KeyValue.Value) = Type("Structure") Then
			TypeName = KeyValue.Value.Type;

			If KeyValue.Value.Property("ChildProperties") 
				And KeyValue.Value.ChildProperties.Count() > 0 Then

				AddedObject.Insert("properties", New Structure);

				FillMonacoCodeEditorContextStructure(AddedObject.properties,
													 KeyValue.Value.ChildProperties, 
													 TypesMap);
//				For each Property In KeyValue.Value.ChildProperties Do
//					AddAttributeDescriptionForMonacoEditor(AddedObject.properties,
//																Property,
//																True,
//																TypesMap);
//				EndDo;

			EndIf;

		Else
			TypeName = KeyValue.Value;
		EndIf;
		AddedObject.ref = MonacoEditorTypeBy1CTypeAsString(TypeName, TypesMap);
		AddingObjects.Insert(KeyValue.Key, AddedObject);
	EndDo;

EndProcedure

Function MetadataDescriptionForMonacoEditorInitialization()
	Description = UT_ApplicationParameters["MetadataDescriptionForMonacoEditorInitialization"];
	If Description <> Undefined Then
		Return Description;
	EndIf;

	ConfigurationDescriptionForInitialization = UT_CodeEditorServerCall.MetaDataDescriptionForMonacoEditorInitialize();
	UT_ApplicationParameters.Insert("MetadataDescriptionForMonacoEditorInitialization",
		ConfigurationDescriptionForInitialization);

	Return ConfigurationDescriptionForInitialization;

EndFunction

Procedure SetTextMonaco(DocumentView, Text, Position = Undefined, ConsiderFirstLineIndent = True)
	DocumentView.setText(Text, Position);
EndProcedure

Procedure OpenMonacoFormatStringWizard(EventParameters, AdditionalParameters)
	If EventParameters = Undefined Then
		UT_CommonClient.ShowQuestionToUser(
			New NotifyDescription("OpenMonacoFormatStringWizardQuestionCompletion", ThisObject, AdditionalParameters),
			Nstr("ru = 'Форматная строка не найдена.';
				 |en = 'Format string was not found.'") + Chars.LF + NSTR("ru = 'Создать новую форматную строку?';
																		  |en = 'Create a new format string?'"),QuestionDialogMode.YesNo);
	Else
		FormatString = StrReplace(StrReplace(EventParameters.text, "|", ""), """", "");
		NotificationParameters = AdditionalParameters;

		Position = New Structure;
		Position.Insert("startLineNumber", EventParameters.startLineNumber);
		Position.Insert("startColumn", EventParameters.startColumn);
		Position.Insert("endLineNumber", EventParameters.endLineNumber);
		Position.Insert("endColumn", EventParameters.endColumn);

		NotificationParameters.Insert("Position", Position);

		OpenFormatStringWizard(FormatString, 
			New NotifyDescription("OnEndEditMonacoFormattedString", ThisObject,
			NotificationParameters));
	EndIf;
EndProcedure

Procedure OpenMonacoQueryWizard(EventParameters, AdditionalParameters)
	If EventParameters = Undefined Then
		UT_CommonClient.ShowQuestionToUser(
			New NotifyDescription("OpenMonacoQueryWizardQuestionCompletion", ThisObject, 
			AdditionalParameters), NSTR("ru = 'Не найден текст запроса';en = 'Query text not found'") + Chars.LF + NSTR("ru = 'Создать новый запрос?';en = 'Create a new query?'"), 
			QuestionDialogMode.YesNo);
	Else
		If EventParameters.isQueryMode Then
			QueryText = EventParameters.text;
		Else
			QueryText = PrepareTextForQueryWizard(EventParameters.text);
		EndIf;
		
		NotificationParameters = AdditionalParameters;
		
		Position = New Structure;
		Position.Insert("startLineNumber", EventParameters.startLineNumber);
		Position.Insert("startColumn", EventParameters.startColumn);
		Position.Insert("endLineNumber", EventParameters.endLineNumber);
		Position.Insert("endColumn", EventParameters.endColumn);

		NotificationParameters.Insert("Position", Position);
		NotificationParameters.Insert("isQueryMode", EventParameters.isQueryMode);
		
		OpenQueryWizard(QueryText, New NotifyDescription("OnEndEditMonacoQuery", 
			ThisObject, NotificationParameters));
	EndIf;
EndProcedure

// Событие для обработки при нажатии monaco.
// 
// Parameters:
//  Form - ClientApplicationForm -Form
//  Item - FormField - Item
//  EventData  -ФиксированнаяСтруктура- Данные события
// 
// Return values:
//  см. CodeEditorNewEventForProcessing
// Return values:
//  Undefined - Событие не требует обработки
Function HTMLEditorFieldOnClickMonaco(Form, Item, EventData, StandardProcessing)
	Event = EventData.Event.eventData1C;

	If Event = Undefined Then
		Return Undefined;
	EndIf;
//	StandardProcessing = False;
		
	EventForProcessing = CodeEditorNewEventForProcessing();
	EventForProcessing.Item = Item;
	EventForProcessing.EventName = Event.event;
	
	DataOfEventForProcessing = Undefined;
	If Event.event = "EVENT_GET_METADATA" Then
		DataOfEventForProcessing = New Structure;
		DataOfEventForProcessing.Insert("MetadataName", Event.params.metadata);
		DataOfEventForProcessing.Insert("EventSource", Event.params.trigger);
		If DataOfEventForProcessing.EventSource = "snippet" Then
			DataOfEventForProcessing.Insert("TemplateID", Event.params.snippet_guid);
		EndIf;
		
	ElsIf Event.event = "EVENT_QUERY_CONSTRUCT" Then 
		QueryParameters = Event.params;
		DocumentHTMLView = EventData.Document.defaultView;
		
		If DocumentHTMLView.isQueryMode() Then
			SelectionBorders = EditorSelectionBordersFormItem(Form, Item);
			DataOfEventForProcessing = New Structure;
			DataOfEventForProcessing.Insert("isQueryMode", True);
			DataOfEventForProcessing.Insert("startLineNumber", SelectionBorders.RowBeginning);
			DataOfEventForProcessing.Insert("startColumn", SelectionBorders.ColumnBeginning);
			DataOfEventForProcessing.Insert("endLineNumber", SelectionBorders.RowEnd);
			DataOfEventForProcessing.Insert("endColumn", SelectionBorders.ColumnEnd);
			DataOfEventForProcessing.Insert("text", DocumentHTMLView.getText());
		Else
			If QueryParameters = Undefined Then
				QueryParameters = DocumentHTMLView.getQuery();
			Endif;

			If QueryParameters <> Undefined And ?(TypeOf(QueryParameters) = Type("String"), ValueIsFilled(
				QueryParameters), True) Then
				DataOfEventForProcessing = New Structure;
				DataOfEventForProcessing.Insert("isQueryMode", False);
				DataOfEventForProcessing.Insert("startLineNumber", QueryParameters.range.startLineNumber);
				DataOfEventForProcessing.Insert("startColumn", QueryParameters.range.startColumn);
				DataOfEventForProcessing.Insert("endLineNumber", QueryParameters.range.endLineNumber);
				DataOfEventForProcessing.Insert("endColumn", QueryParameters.range.endColumn);
				DataOfEventForProcessing.Insert("text", QueryParameters.text);
			Endif;
		
		EndIf;
		
	ElsIf Event.event = "EVENT_FORMAT_CONSTRUCT" Then 
		If Event.params <> Undefined And ValueIsFilled(QueryParameters) Then
			DataOfEventForProcessing = New Structure;
			DataOfEventForProcessing.Insert("startLineNumber", Event.params.range.startLineNumber);
			DataOfEventForProcessing.Insert("startColumn", Event.params.range.startColumn);
			DataOfEventForProcessing.Insert("endLineNumber", Event.params.range.endLineNumber);
			DataOfEventForProcessing.Insert("endColumn", Event.params.range.endColumn);
			DataOfEventForProcessing.Insert("text", Event.params.text);
		Endif;
	ElsIf Event.event = "EVENT_GET_DEFINITION" Then 
		DataOfEventForProcessing = New Structure;
		DataOfEventForProcessing.Insert("Слово", Event.params.word);
		DataOfEventForProcessing.Insert("ПолноеВыражение", Event.params.expression);
		DataOfEventForProcessing.Insert("Модуль", Event.params.module);
		DataOfEventForProcessing.Insert("ИмяОбъекта", Event.params.class);
		DataOfEventForProcessing.Insert("НомерСтроки", Event.params.line);
		DataOfEventForProcessing.Insert("НомерКолонки", Event.params.column);
		//DataOfEventForProcessing.Insert("МассивВыражения", Event.params.expression_array);
			
	Endif;	
	
	EventForProcessing.EventData = DataOfEventForProcessing;
	
	Return EventForProcessing;
EndFunction

Function MetadataTypeDirectoryName(MetadataObjectType)
	If MetadataObjectType = "catalogs" Then
		Return "Catalogs";
	ElsIf MetadataObjectType = "documents" Then
		Return "Documents";
	ElsIf MetadataObjectType = "constants" Then
		Return "Constants";
	ElsIf MetadataObjectType = "enums" Then
		Return "Enums";
	ElsIf MetadataObjectType = "reports" Then
		Return "Reports";
	ElsIf MetadataObjectType = "dataprocessors" Then
		Return "DataProcessors";
	ElsIf MetadataObjectType = "chartsofcharacteristictypes" Then
		Return "ChartsOfCharacteristicTypes";
	ElsIf MetadataObjectType = "chartsofaccounts" Then
		Return "ChartsOfAccounts";
	ElsIf MetadataObjectType = "chartsofcalculationtypes" Then
		Return "ChartsOfCalculationTypes";
	ElsIf MetadataObjectType = "informationregisters" Then
		Return "InformationRegisters";
	ElsIf MetadataObjectType = "accumulationregisters" Then
		Return "AccumulationRegisters";
	ElsIf MetadataObjectType = "accountingregisters" Then
		Return "AccountingRegisters";
	ElsIf MetadataObjectType = "calculationregisters" Then
		Return "CalculationRegisters";
	ElsIf MetadataObjectType = "businessprocesses" Then
		Return "BusinessProcesses";
	ElsIf MetadataObjectType = "tasks" Then
		Return "Tasks";
	ElsIf MetadataObjectType = "exchangeplans" Then
		Return "ExchangePlans";
	EndIf;

EndFunction

// Start retrieving module text from source files.
// 
// Parameters:
//  ModuleName - String - Module name. module.УИ_ОбщегоНазначения, module.manager.документы.авансовыйотчет, module.object.документы.авансовыйотчет
//  DirectoriesOfSourceFiles - Array of look at УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
//  CallbackDescriptionAboutCompletion - CallbackDescription - Description of the completion alert
Procedure StartGettingModuleTextFromSourceFiles(ModuleName, DirectoriesOfSourceFiles, CallbackDescriptionAboutCompletion)
	If DirectoriesOfSourceFiles.Count() = 0 Then
		Return;
	EndIf;
	
	ArrayOfModuleNames = StrSplit(ModuleName, ".");

	If ArrayOfModuleNames.Count() < 2 Then
		Return;
	EndIf;
	
	SearchOptions = New Structure;
	SearchOptions.Insert("CallbackDescriptionAboutCompletion", CallbackDescriptionAboutCompletion);
	SearchOptions.Insert("SourcesDirectories", DirectoriesOfSourceFiles);
	SearchOptions.Insert("SourcesDirectoryIndex", 0);
	SearchOptions.Insert("ModuleName", ModuleName);
	SearchOptions.Insert("ArrayOfModuleNames", ArrayOfModuleNames);
	
	ModuleType = ArrayOfModuleNames[1];

	If ModuleType = "manager" Then
		SearchOptions.Insert("MetadataObjectDescription",
								 UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName(ArrayOfModuleNames[2],
																										  ArrayOfModuleNames[3]));
		SearchOptions.Insert("ModuleDirectory", MetadataTypeDirectoryName(ArrayOfModuleNames[2]));
		SearchOptions.Insert("FileName", "ManagerModule.bsl");

		SearchOptions.Insert("IsCommonModule", False);

	ElsIf ModuleType = "object" Then
		SearchOptions.Insert("MetadataObjectDescription",
								 UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName(ArrayOfModuleNames[2],
																										  ArrayOfModuleNames[3]));
		SearchOptions.Insert("ModuleDirectory", MetadataTypeDirectoryName(ArrayOfModuleNames[2]));
		SearchOptions.Insert("FileName", "ObjectModule.bsl");

		SearchOptions.Insert("IsCommonModule", False);
	Иначе
		SearchOptions.Insert("MetadataObjectDescription",
								 UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName("CommonModules",
																										  ArrayOfModuleNames[1]));
		SearchOptions.Insert("ModuleDirectory", "CommonModules");
		SearchOptions.Insert("FileName", "Module.bsl");

		SearchOptions.Insert("IsCommonModule", True);
	EndIf;

	StartSearchingForModuleFilesInSourceFileDirectories(SearchOptions,
												  New CallbackDescription("StartGettingModuleTextFromSourceFilesCompletingFileSearch",
		ThisObject, SearchOptions));
EndProcedure

// Start searching for the module file in the source file directories.
// 
// Parameters:
//  SearchOptions - Structure - Параметры поиска:
// 		* CallbackDescriptionAboutCompletion - CallbackDescription -
// 		* SourcesDirectories - Array of см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
// 		* SourcesDirectoryIndex - Number -
// 		* ModuleName - String -
// 		* ArrayOfModuleNames - Array of String -
// 		* ModuleDirectory - String -
// 		* FileName - String -
// 		* IsCommonModule - Boolean -
//  CallbackDescriptionAboutCompletion - CallbackDescription - Description of the completion alert
Procedure StartSearchingForModuleFilesInSourceFileDirectories(SearchOptions, CallbackDescriptionAboutCompletion)
	If SearchOptions.SourcesDirectories.Count() <= SearchOptions.SourcesDirectoryIndex Then
		Return;
	EndIf;
	
	SourceFilesDirectory = SearchOptions.SourcesDirectories[SearchOptions.SourcesDirectoryIndex].Directory;

	If Not ValueIsFilled(SourceFilesDirectory) Then
		SearchOptions.SourcesDirectoryIndex = SearchOptions.SourcesDirectoryIndex + 1;
		StartSearchingForModuleFilesInSourceFileDirectories(SearchOptions, CallbackDescriptionAboutCompletion);
		Return;
	EndIf;

	SearchFileDirectoryName = UT_CommonClientServer.MergePaths(SourceFilesDirectory,
																			SearchOptions.ModuleDirectory,
																			SearchOptions.MetadataObjectDescription.Name);
	SearchOptions.Insert("SearchFileDirectoryName", SearchFileDirectoryName);
	SearchOptions.Insert("CallbackDescriptionCompleteSearchFile", CallbackDescriptionAboutCompletion);

	BeginFindingFiles(New NotifyDescription("StartSearchingForModuleFileInSourceFileDirectoriesCompletingFileSearch", 
		ThisObject, SearchOptions), SearchFileDirectoryName, SearchOptions.ModuleFileName, True);

EndProcedure

Procedure StartSearchingForModuleFileInSourceFilesDirectory(AdditionalParameters)
	If AdditionalParameters.SourcesDirectories.Count() <= AdditionalParameters.SourcesDirectoryIndex Then
		Return;
	EndIf;
	SourceFilesDirectory = AdditionalParameters.SourcesDirectories[AdditionalParameters.SourcesDirectoryIndex].Directory;

	If Not ValueIsFilled(SourceFilesDirectory) Then
		AdditionalParameters.SourcesDirectoryIndex = AdditionalParameters.SourcesDirectoryIndex + 1;
		StartSearchingForModuleFileInSourceFilesDirectory(AdditionalParameters);
		Return;
	EndIf;

	SearchFileDirectoryName = SourceFilesDirectory + GetPathSeparator() + AdditionalParameters.ModuleDirectory
		+ GetPathSeparator() + AdditionalParameters.MetadataObjectDescription.Name;
	AdditionalParameters.Insert("SearchFileDirectoryName", SearchFileDirectoryName);

	BeginFindingFiles(New CallbackDescription("SetModuleDescriptionForMonacoEditorOnEndModuleFilesSeacrh",
		ThisObject, AdditionalParameters), SearchFileDirectoryName, AdditionalParameters.ModuleFileName, True);

EndProcedure

Procedure SetModuleDescriptionForMonacoEditor(UpdatedMetadataObject, AdditionalParameters)
	MetadataNamesArray = StrSplit(UpdatedMetadataObject, ".");

	If MetadataNamesArray.Count() < 2 Then
		Return;
	EndIf;

	FormEditors = AdditionalParameters.Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	EditorID = UT_CodeEditorClientServer.EditorIDByFormItem(
		AdditionalParameters.Form, AdditionalParameters.Item);
	EditorSettings = FormEditors[EditorID];
	AdditionalParameters.Insert("SourcesDirectories", EditorSettings.EditorSettings.SourceFilesDirectories);

	If AdditionalParameters.SourcesDirectories.Count() = 0 Then
		Return;
	EndIf;

	AdditionalParameters.Insert("SourcesDirectoryIndex", 0);

	ModuleType = MetadataNamesArray[1];

	AdditionalParameters.Insert("UpdatedMetadataObject", UpdatedMetadataObject);
	AdditionalParameters.Insert("MetadataNamesArray", MetadataNamesArray);

	If ModuleType = "manager" Then
		MetadataObjectDescription = UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName(
			MetadataNamesArray[2], MetadataNamesArray[3]);

		ModuleDirectory = MetadataTypeDirectoryName(MetadataNamesArray[2]);
		FileName = "ManagerModule.bsl";

		AdditionalParameters.Insert("IsCommonModule", False);

	ElsIf ModuleType = "object" Then
		MetadataObjectDescription = UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName(
			MetadataNamesArray[2], MetadataNamesArray[3]);

		ModuleDirectory = MetadataTypeDirectoryName(MetadataNamesArray[2]);
		FileName = "ObjectModule.bsl";

		AdditionalParameters.Insert("IsCommonModule", False);
	Else
		MetadataObjectDescription = UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName(
			"CommonModules", MetadataNamesArray[1]);

		ModuleDirectory = "CommonModules";
		FileName = "Module.bsl";

		AdditionalParameters.Insert("IsCommonModule", True);
	EndIf;

	AdditionalParameters.Insert("MetadataObjectDescription", MetadataObjectDescription);
	AdditionalParameters.Insert("ModuleDirectory", ModuleDirectory);
	AdditionalParameters.Insert("ModuleFileName", FileName);

	StartSearchingForModuleFileInSourceFilesDirectory(AdditionalParameters);
EndProcedure
Procedure SetModuleDescriptionForMonacoEditorOnEndModuleFilesSeacrh(FoundFiles, 
AdditionalParameters) Export
	If FoundFiles = Undefined Then
		AdditionalParameters.SourcesDirectoryIndex = AdditionalParameters.SourcesDirectoryIndex + 1;
		StartSearchingForModuleFileInSourceFilesDirectory(AdditionalParameters);
		Return;
	EndIf;

	If FoundFiles.Count() = 0 Then
		AdditionalParameters.SourcesDirectoryIndex = AdditionalParameters.SourcesDirectoryIndex + 1;
		StartSearchingForModuleFileInSourceFilesDirectory(AdditionalParameters);
		Return;
	EndIf;

	FileName = FoundFiles[0].FullName;
	AdditionalParameters.Insert("FileName", FileName);

	TextDocument = New TextDocument;

	AdditionalParameters.Insert("TextDocument", TextDocument);
	TextDocument.BeginReading(
		New NotifyDescription("SetModuleDescriptionForMonacoEditorEndFileReading", ThisObject,
		 AdditionalParameters),AdditionalParameters.FileName);

EndProcedure

Procedure SetModuleDescriptionForMonacoEditorEndFileReading(AdditionalParameters) Export
	ModuleText = AdditionalParameters.TextDocument.GetText();

	DocumentView = AdditionalParameters.Item.Document.defaultView;

	If AdditionalParameters.IsCommonModule Then
		DocumentView.parseCommonModule(AdditionalParameters.MetadataObjectDescription.Name, ModuleText, False);
	Else
		UpdatedMetadataObjectsMap = MapOfMonacoEditorUpdatedMetadataObjectsAndMetadataUpdateEventParameters();
		UpdatedEditorCollection = UpdatedMetadataObjectsMap[AdditionalParameters.MetadataObjectDescription.ObjectType];
		UpdatedEditorCollection = UpdatedEditorCollection + "." 
		+ AdditionalParameters.MetadataObjectDescription.Name + "."
		+ AdditionalParameters.MetadataNamesArray[1];

		DocumentView.parseMetadataModule(ModuleText, UpdatedEditorCollection);
	EndIf;
	DocumentView.triggerSuggestions();

EndProcedure

Procedure SetMetadataDescriptionForMonacoEditor(UpdatedMetadataObject, AdditionalParameters)

	MetadataNamesArray = StrSplit(UpdatedMetadataObject, ".");

	ObjectType = MetadataNamesArray[0];

	UpdatedMetadataObjectsMap = MapOfMonacoEditorUpdatedMetadataObjectsAndMetadataUpdateEventParameters();
	UpdatedEditorCollection = UpdatedMetadataObjectsMap[ObjectType];

	If MetadataNamesArray.Count() = 1 Then
		UpdatedData = New Structure;

		NamesArray = UT_CodeEditorServerCall.MetadataListByType(ObjectType);
		For Each CurrentName In NamesArray Do
			UpdatedData.Insert(CurrentName, New Structure);
		EndDo;
	Else
		MetadataObjectDescription = UT_CodeEditorServerCall.ConfigurationMetadataObjectDescriptionByName(
			ObjectType, MetadataNamesArray[1]);
		Description = MetadataObjectDescriptionForMonacoEditor(MetadataObjectDescription);

		UpdatedData = Description;

		UpdatedEditorCollection = UpdatedEditorCollection + "." + MetadataObjectDescription.Name;
	EndIf;

	DocumentView = AdditionalParameters.Item.Document.defaultView;
	DocumentView.updateMetadata(UT_CommonClientServer.mWriteJSON(
			UpdatedData), UpdatedEditorCollection);

	If AdditionalParameters.EventData.EventSource = "snippet" Then
		DocumentView.updateSnippetByGUID(AdditionalParameters.EventData.TemplateID);
	EndIf;
	DocumentView.triggerSuggestions();
EndProcedure

Function MonacoEditorTypeBy1CTypeAsString(Type1COrString, ReferenceTypesMap)
	If ReferenceTypesMap = Undefined Then
		Return "";
	EndIf;

	Type1C = Type1COrString;
	If TypeOf(Type1C) = Type("String") Then
		If StrFind(Type1COrString, ".") > 0 Then
			Return Type1COrString;
		EndIf;

		Try
			Type1C = Type(Type1C);
		Except
			Return "types." + Type1COrString;
		EndTry;
	ElsIf TypeOf(Type1C) = Type("TypeDescription") Then
		TypesFromType = Type1C.Types();
		If TypesFromType.Count() > 0 Then
			Type1C = TypesFromType[0];
		EndIf;
	EndIf;

	TypeMetadata=ReferenceTypesMap[Type1C];

	If TypeMetadata = Undefined Then
		If TypeOf(Type1COrString) = Type("String") Then
			Try
				Str = New (Type1COrString);
				Return "classes." + Type1COrString;
			Except
				Return "types." + Type1COrString;
			EndTry;
		Else
			Return "";
		EndIf;
	EndIf;

	If TypeMetadata.ObjectType = "Catalog" Then
		Return "catalogs." + TypeMetadata.Name;
	ElsIf TypeMetadata.ObjectType = "Document" Then
		Return "documents." + TypeMetadata.Name;
	ElsIf TypeMetadata.ObjectType = "Task" Then
		Return "tasks." + TypeMetadata.Name;
	ElsIf TypeMetadata.ObjectType = "ChartOfCalculationTypes" Then
		Return "chartsOfCalculationTypes." + TypeMetadata.Name;
	ElsIf TypeMetadata.ObjectType = "ChartOfCharacteristicTypes" Then
		Return "chartsOfCharacteristicTypes." + TypeMetadata.Name;
	ElsIf TypeMetadata.ObjectType = "ExchangePlan" Then
		Return "exchangePlans." + TypeMetadata.Name;
	ElsIf TypeMetadata.ObjectType = "ChartOfAccounts" Then
		Return "сhartsOfAccounts." + TypeMetadata.Name;
	EndIf;

	Return "";
EndFunction

Function GetLinkToMetadataObjectForMonacoEditor(Attribute, TypesMap)

	Link = "";

	Types = Attribute.Type.Types();

	IndexOf = 0;

	For Each CurrentType In Types Do
		Link = MonacoEditorTypeBy1CTypeAsString(CurrentType, TypesMap);

		If ValueIsFilled(Link) Then
			Break;
		EndIf;
	EndDo;
	Return Link;

EndFunction

Procedure AddAttributeDescriptionForMonacoEditor(AttributesDescription, Attribute, GetAttributeLinks,
	TypesMap)

	Link = "";
	If GetAttributeLinks Then
		Link= GetLinkToMetadataObjectForMonacoEditor(Attribute, TypesMap);
	EndIf;

	AttributeDescription = New Structure("name", Attribute.Name);

	If ValueIsFilled(Link) Then
		AttributeDescription.Insert("ref", Link);
	EndIf;

	AttributesDescription.Insert(Attribute.Name, AttributeDescription);

EndProcedure

Function MetadataObjectDescriptionForMonacoEditor(MetadataObjectDescription)
	TypesMap = ConfigurationReferenceTypesMap();
	AttributesDescription = New Structure;
	ResourcesDescription = New Structure;
	PredefinedDescription = New Structure;
	TabularSectionsDescription = New Structure;
	AdditionalProperties = New Structure;

	If MetadataObjectDescription.ObjectType = "Enum" Or MetadataObjectDescription.ObjectType 
	= "enums" Then

		For Each EmunValueKeyValue In MetadataObjectDescription.EnumValues Do
			AttributesDescription.Insert(EmunValueKeyValue.Key, New Structure("name", 
			EmunValueKeyValue.Value));
		EndDo;

	Else

		If MetadataObjectDescription.Property("Attributes") Then
			For Each AttributeKeyValue In MetadataObjectDescription.Attributes Do
				AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, True, 
				TypesMap);
			EndDo;
		EndIf;
		If MetadataObjectDescription.Property("StandardAttributes") Then
			For Each AttributeKeyValue In MetadataObjectDescription.StandardAttributes Do
				AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, False, 
				TypesMap);
			EndDo;
		EndIf;
		If MetadataObjectDescription.Property("Predefined") Then
				
				//If MetadataName(FullName) = "ChartOfAccounts" Then
				//	
				//	Query = New Query(
				//	"SELECT
				//	|	ChartOfAccounts.Code AS Code,
				//	|	ChartOfAccounts.PredefinedDataName AS Name
				//	|FROM
				//	|	&Table AS ChartOfAccounts
				//	|WHERE
				//	|	ChartOfAccounts.Predefined");				
				//						
				//	Query.Text = StrReplace(Query.Text, "&Table", FullName);
				//	
				//	Selection = Query.Execute().Select();
				//	
				//	While Selection.Next() Do 
				//		PredefinedDescription.Insert(Selection.Name, StrTemplate("%1 (%2)", Selection.Name, Selection.Code));
				//	EndDo;
				//	
				//Else				
			For Each NameKeyValue In MetadataObjectDescription.Predefined Do
				PredefinedDescription.Insert(NameKeyValue.Key, "");
			EndDo;
				
				//EndIf;

		EndIf;

		If MetadataObjectDescription.Property("Dimensions") Then

			For Each AttributeKeyValue In MetadataObjectDescription.Dimensions Do
				AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, True, 
					TypesMap);
			EndDo;
			For Each AttributeKeyValue In MetadataObjectDescription.Resources Do
				AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, True, 
					TypesMap);
			EndDo;
				
				//FillRegisterType(AdditionalProperties, MetadataObject, FullName);				

		EndIf;

		If MetadataObjectDescription.Property("TabularSections") Then

			For Each TabularSectionKeyValue In MetadataObjectDescription.TabularSections Do

				TabularSection = TabularSectionKeyValue.Value;
				
				TabularSectionDescription = New Structure;

				If TabularSection.Property("StandardAttributes") Then
					For Each TabularSectionAttribute In TabularSection.StandardAttributes Do
						TabularSectionDescription.Insert(TabularSectionAttribute.Value.Name,TabularSectionAttribute.Value.Synonym);
					EndDo;
				EndIf;

				If TabularSection.Property("Attributes") Then
					For Each TabularSectionAttribute In TabularSection.Attributes Do
						AddAttributeDescriptionForMonacoEditor(TabularSectionDescription, TabularSectionAttribute.Value,
							True, TypesMap);
					EndDo;
				EndIf;

				TabularSectionsDescription.Insert(TabularSection.Name, New Structure("properties",TabularSectionDescription));

			EndDo;

		EndIf;
		If MetadataObjectDescription.Property("StandardTabularSections") Then

			For Each TabularSectionKeyValue In MetadataObjectDescription.StandardTabularSections Do

				TabularSection = TabularSectionKeyValue.Value;
				
				TabularSectionDescription = New Structure;

				If TabularSection.Property("StandardAttributes") Then
					For Each TabularSectionAttribute In TabularSection.StandardAttributes Do
						TabularSectionDescription.Insert(TabularSectionAttribute.Value.Name,TabularSectionAttribute.Value.Synonym);
					EndDo;
				EndIf;

				If TabularSection.Property("Attributes") Then
					For Each TabularSectionAttribute In TabularSection.Attributes Do
						AddAttributeDescriptionForMonacoEditor(TabularSectionDescription, TabularSectionAttribute.Value,
							True, TypesMap);
					EndDo;
				EndIf;

				TabularSectionsDescription.Insert(TabularSection.Name,New Structure("properties", TabularSectionDescription));

			EndDo;

		EndIf;

	EndIf;

	ObjectStructure = New Structure;
	ObjectStructure.Insert("properties", AttributesDescription);

	For Each Iterator In AdditionalProperties Do
		ObjectStructure.Insert(Iterator.Key, Iterator.Value);
	EndDo;

	If ResourcesDescription.Count() > 0 Then
		ObjectStructure.Insert("resources", ResourcesDescription);
	EndIf;

	If PredefinedDescription.Count() > 0 Then
		ObjectStructure.Insert("predefined", PredefinedDescription);
	EndIf;

	If TabularSectionsDescription.Count() > 0 Then
		ObjectStructure.Insert("tabulars", TabularSectionsDescription);
	EndIf;

	Return ObjectStructure;
EndFunction

Function DescribeMetadataObjectsCollectionForMonacoEditor(Collection, TypesMap)

	CollectionDescription = New Structure;

	For Each CollectionItemKeyValue In Collection Do

		AttributesDescription = New Structure;
		ResourcesDescription = New Structure;
		PredefinedDescription = New Structure;
		TabularSectionsDescription = New Structure;
		AdditionalProperties = New Structure;

		MetadataObject = CollectionItemKeyValue.Value;

		If MetadataObject.ObjectType = "Enum" Then

			For Each EmunValueKeyValue In MetadataObject.EnumValues Do
				AttributesDescription.Insert(EmunValueKeyValue.Key, New Structure("name", 
					EmunValueKeyValue.Value));
			EndDo;

		Else

			If MetadataObject.Property("Attributes") Then
				For Each AttributeKeyValue In MetadataObject.Attributes Do
					AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, True,
						TypesMap);
				EndDo;
			EndIf;
			If MetadataObject.Property("StandardAttributes") Then
				For Each AttributeKeyValue In MetadataObject.StandardAttributes Do
					AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, False,
						TypesMap);
				EndDo;
			EndIf;
			If MetadataObject.Property("Predefined") Then
				
				//If MetadataObject(FullName) = "ChartOfAccounts" Then
				//	
				//	Query = New Query(
				//	"SELECT
				//	|	ChartOfAccounts.Code AS Code,
				//	|	ChartOfAccounts.PredefinedDataName AS Name
				//	|FROM
				//	|	&Table AS ChartOfAccounts
				//	|WHERE
				//	|	ChartOfAccounts.Predefined");				
				//						
				//	Query.Text = StrReplace(Query.Text, "&Table", FullName);
				//	
				//	Selection = Query.Execute().Select();
				//	
				//	While Selection.Next() Do 
				//		PredefinedDescription.Insert(Selection.Name, StrTemplate("%1 (%2)", Selection.Name, Selection.Code));
				//	EndDo;
				//	
				//Else				
				For Each NameKeyValue In MetadataObject.Predefined Do
					PredefinedDescription.Insert(NameKeyValue.Key, New Structure("name, ref",
					 NameKeyValue.Key, ""));
				EndDo;
				
				//EndIf;

			EndIf;

			If MetadataObject.Property("Dimensions") Then

				For Each AttributeKeyValue In MetadataObject.Dimensions Do
					AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, True,
						TypesMap);
				EndDo;
				For Each AttributeKeyValue In MetadataObject.Resources Do
					AddAttributeDescriptionForMonacoEditor(AttributesDescription, AttributeKeyValue.Value, True,
						TypesMap);
				EndDo;
				
				//FillRegisterType(AdditionalProperties, MetadataObject, FullName);				

			EndIf;

			If MetadataObject.Property("TabularSections") Then

				For Each TabularSectionKeyValue In MetadataObject.TabularSections Do

					TabularSection = TabularSectionKeyValue.Value;
					AttributesDescription.Insert(TabularSection.Name, New Structure("name", "TS: "
						+ TabularSection.Synonym));

					TabularSectionDescription = New Structure;

					If TabularSection.Property("StandardAttributes") Then
						For Each TabularSectionAttribute In TabularSection.StandardAttributes Do
							TabularSectionDescription.Insert(TabularSectionAttribute.Value.Name,TabularSectionAttribute.Value.Synonym);
						EndDo;
					EndIf;

					If TabularSection.Property("Attributes") Then
						For Each TabularSectionAttribute In TabularSection.Attributes Do
							AddAttributeDescriptionForMonacoEditor(TabularSectionDescription,
								TabularSectionAttribute.Value, True, TypesMap);
						EndDo;
					EndIf;

					TabularSectionsDescription.Insert(TabularSection.Name, TabularSectionDescription);

				EndDo;

			EndIf;
			If MetadataObject.Property("StandardTabularSections") Then

				For Each TabularSectionKeyValue In MetadataObject.StandardTabularSections Do

					TabularSection = TabularSectionKeyValue.Value;
					AttributesDescription.Insert(TabularSection.Name, New Structure("name", "TS: "
						+ TabularSection.Synonym));

					TabularSectionDescription = New Structure;

					If TabularSection.Property("StandardAttributes") Then
						For Each TabularSectionAttribute In TabularSection.StandardAttributes Do
							TabularSectionDescription.Insert(TabularSectionAttribute.Value.Name,TabularSectionAttribute.Value.Synonym);
						EndDo;
					EndIf;

					If TabularSection.Property("Attributes") Then
						For Each TabularSectionAttribute In TabularSection.Attributes Do
							AddAttributeDescriptionForMonacoEditor(TabularSectionDescription,
								TabularSectionAttribute.Value, True, TypesMap);
						EndDo;
					EndIf;

					TabularSectionsDescription.Insert(TabularSection.Name, TabularSectionDescription);

				EndDo;

			EndIf;

		EndIf;

		ObjectStructure = New Structure;
		ObjectStructure.Insert("properties", AttributesDescription);

		For Each Iterator In AdditionalProperties Do
			ObjectStructure.Insert(Iterator.Key, Iterator.Value);
		EndDo;

		If 0 < ResourcesDescription.Count() Then
			ObjectStructure.Insert("resources", ResourcesDescription);
		EndIf;

		If 0 < PredefinedDescription.Count() Then
			ObjectStructure.Insert("predefined", PredefinedDescription);
		EndIf;

		If 0 < TabularSectionsDescription.Count() Then
			ObjectStructure.Insert("tabulars", TabularSectionsDescription);
		EndIf;

		CollectionDescription.Insert(MetadataObject.Name, ObjectStructure);

	EndDo;

	Return CollectionDescription;

EndFunction

Function GetMetadataObjectsListFromCollectionForMonacoEditor(Collection)

	CollectionDescription = New Structure;

	For Each KeyValue In Collection Do
		CollectionDescription.Insert(KeyValue.Key, New Structure);
	EndDo;

	Return CollectionDescription;

EndFunction

Function ConfigurationReferenceTypesMap()
	Map = UT_ApplicationParameters["ConfigurationReferenceTypesMap"];
	If Map <> Undefined Then
		Return Map;
	EndIf;

	TypesMap = UT_CodeEditorServerCall.ReferenceTypesMap();
	UT_ApplicationParameters.Insert("ConfigurationReferenceTypesMap", TypesMap);

	Return TypesMap;
EndFunction

Function ConfigurationMetadataDescriptionForMonacoEditor()
	MetadataDescription = UT_ApplicationParameters["MetadataDescriptionForMonacoEditor"];
	If MetadataDescription <> Undefined Then
		Return MetadataDescription;
	EndIf;

	MetadataDescriptionURL = UT_ApplicationParameters["ConfigurationMetadataDescriptionAdress"];
	If Not IsTempStorageURL(MetadataDescriptionURL) Then
		MetadataDescriptionURL = UT_CommonServerCall.ConfigurationMetadataDescriptionAdress();
		UT_ApplicationParameters.Insert("ConfigurationMetadataDescriptionAdress", MetadataDescriptionURL);
	EndIf;
	ConfigurationMetadata = GetFromTempStorage(MetadataDescriptionURL);

	TypesMap = ConfigurationMetadata.ReferenceTypesMap;

	MetadataCollection = New Structure;
	MetadataCollection.Insert("catalogs", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.Catalogs, TypesMap));
	MetadataCollection.Insert("documents", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.Documents, TypesMap));
	MetadataCollection.Insert("infoRegs", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.InformationRegisters, TypesMap));
	MetadataCollection.Insert("accumRegs", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.AccumulationRegisters, TypesMap));
	MetadataCollection.Insert("accountRegs", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.AccountingRegisters, TypesMap));
	MetadataCollection.Insert("calcRegs", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.CalculationRegisters, TypesMap));
	MetadataCollection.Insert("dataProc", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.DataProcessors, TypesMap));
	MetadataCollection.Insert("reports", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.Reports, TypesMap));
	MetadataCollection.Insert("enums", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.Enums, TypesMap));
	MetadataCollection.Insert("commonModules", GetMetadataObjectsListFromCollectionForMonacoEditor(
		ConfigurationMetadata.CommonModules));
	MetadataCollection.Insert("сhartsOfAccounts", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.ChartsOfAccounts, TypesMap));
	MetadataCollection.Insert("businessProcesses", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.BusinessProcesses, TypesMap));
	MetadataCollection.Insert("tasks", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.Tasks, TypesMap));
	MetadataCollection.Insert("exchangePlans", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.ExchangePlans, TypesMap));
	MetadataCollection.Insert("chartsOfCharacteristicTypes", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.ChartsOfCharacteristicTypes, TypesMap));
	MetadataCollection.Insert("chartsOfCalculationTypes", DescribeMetadataObjectsCollectionForMonacoEditor(
		ConfigurationMetadata.ChartsOfCalculationTypes, TypesMap));
	MetadataCollection.Insert("constants", GetMetadataObjectsListFromCollectionForMonacoEditor(
		ConfigurationMetadata.Constants));

	UT_ApplicationParameters.Insert("MetadataDescriptionForMonacoEditor", UT_CommonClientServer.CopyStructure(
		MetadataCollection));
	UT_ApplicationParameters.Insert("ConfigurationReferenceTypesMap", TypesMap);

	Return MetadataCollection;
EndFunction

// Object metadata type by MetadataType by editor Monaco.
// 
// Parameters:
//  MetadataTypeMonaco - String - Вид метаданных monaco
// 
// Return values:
//  String
Function ВидОбъектаМетаданныхПоВидуМетаданныхОтРедактораMonaco(MetadataTypeMonaco)
	If Lower(MetadataTypeMonaco) = "inforegs" Then
		Return "informationregisters";
	ElsIf Lower(MetadataTypeMonaco) = "accumregs" Then
		Return "accumulationregisters";
	ElsIf Lower(MetadataTypeMonaco) = "accountregs" Then
		Return "accountingregisters";
	ElsIf Lower(MetadataTypeMonaco) = "calcregs" Then
		Return "calculationregisters";
	ElsIf Lower(MetadataTypeMonaco) = "dataproc" Then
		Return "dataprocessors";
	Иначе
		Return MetadataTypeMonaco;
	EndIf;
EndFunction

Function MapOfMonacoEditorUpdatedMetadataObjectsAndMetadataUpdateEventParameters()
	Map = New Structure;
	Map.Insert("справочники", "catalogs.items");
	Map.Insert("catalogs", "catalogs.items");
	Map.Insert("документы", "documents.items");
	Map.Insert("documents", "documents.items");
	Map.Insert("регистрысведений", "infoRegs.items");
	Map.Insert("informationregisters", "infoRegs.items");
	Map.Insert("infoRegs", "infoRegs.items");
	Map.Insert("регистрынакопления", "accumRegs.items");
	Map.Insert("accumulationregisters", "accumRegs.items");
	Map.Insert("accumRegs", "accumRegs.items");	
	Map.Insert("регистрыбухгалтерии", "accountRegs.items");
	Map.Insert("accountingregisters", "accountRegs.items");
	Map.Insert("accountRegs", "accountRegs.items");
	Map.Insert("регистрырасчета", "calcRegs.items");
	Map.Insert("calculationregisters", "calcRegs.items");
	Map.Insert("calcRegs", "calcRegs.items");
	Map.Insert("обработки", "dataProc.items");
	Map.Insert("dataprocessors", "dataProc.items");
	Map.Insert("dataProc", "dataProc.items");
	Map.Insert("отчеты", "reports.items");
	Map.Insert("reports", "reports.items");
	Map.Insert("перечисления", "enums.items");
	Map.Insert("enums", "enums.items");
	Map.Insert("планысчетов", "сhartsOfAccounts.items");
	Map.Insert("chartsofaccounts", "сhartsOfAccounts.items");
	Map.Insert("бизнеспроцессы", "businessProcesses.items");
	Map.Insert("businessprocesses", "businessProcesses.items");
	Map.Insert("задачи", "tasks.items");
	Map.Insert("tasks", "tasks.items");
	Map.Insert("планыобмена", "exchangePlans.items");
	Map.Insert("exchangeplans", "exchangePlans.items");
	Map.Insert("планывидовхарактеристик", "chartsOfCharacteristicTypes.items");
	Map.Insert("chartsofcharacteristictypes", "chartsOfCharacteristicTypes.items");
	Map.Insert("планывидоврасчета", "chartsOfCalculationTypes.items");
	Map.Insert("chartsofcalculationtypes", "chartsOfCalculationTypes.items");
	Map.Insert("константы", "constants.items");
	Map.Insert("constants", "constants.items");
	Map.Insert("module", "commonModules.items");

	Return Map;
EndFunction

Function ThereAreAddedCommandsForEditorContextMenuMonaco(DocumentView)
	EditorCommands = DocumentView.editor.getSupportedActions();
	For Each  CurrentCommand In EditorCommands Do
		If Not StrEndsWith(CurrentCommand.id, "_bsl") Then
			Continue;
		EndIf;
		
		PartsIdentifier = StrSplit(CurrentCommand.id, ":");  
		ID = PartsIdentifier[PartsIdentifier.Count()-1];
		PartsIdentifier = StrSplit(ID, ".");
		If UT_StringFunctionsClientServer.OnlyNumbersInString(PartsIdentifier[0]) Then
			Return True;
		EndIf;
	EndDo;
	
	Return False;
EndFunction

#EndRegion

#Region ACE
// Event to Handle when clicked Ace.
// 
// Parameters:
//  Form - ClientApplicationForm - Form
//  Item - FormField - Item
//  EventData  - FixedStructure- Данные события
// 
// Return values:
//  look at CodeEditorNewEventForProcessing
// Return values:
//  Undefined - Событие не требует обработки
Function EventToHandleWhenClickedAce(Form, Item, EventData)
	Event = EventData.Event.eventData1C;

	If Event = Undefined Then
		Return Undefined;
	EndIf;
//	StandardProcessing = False;
		
	EventForProcessing = CodeEditorNewEventForProcessing();
	EventForProcessing.Item = Item;
	EventForProcessing.EventName = Event.name;
	
	EventDataForProcessing = Undefined;

	//Obtaining special data for an event
	
	EventForProcessing.EventData = EventDataForProcessing;

	Return EventForProcessing;	
EndFunction


#EndRegion

Procedure SaveEditorLibraryToDisk(LibraryURL, EditorType, CompletionNotifyDescription)
	LibrarySavingDirectory=EditorSaveDirectory(EditorType);
	EditorFile=New File(LibrarySavingDirectory);

	AdditionalParameters= New Structure;
	AdditionalParameters.Insert("LibraryURL", LibraryURL);
	AdditionalParameters.Insert("LibrarySavingDirectory", LibrarySavingDirectory);
	AdditionalParameters.Insert("EditorType", EditorType);
	AdditionalParameters.Insert("CompletionNotifyDescription", CompletionNotifyDescription);
	EditorFile.BeginCheckingExistence(
		New NotifyDescription("SaveEditorLibraryToDiskEndCheckOfLibraryExistOnDisk", 
		ThisObject, AdditionalParameters));
EndProcedure

Procedure SaveEditorLibraryWriteBeginWritingNextFile(AdditionalParameters)
	SavedFilesArray = AdditionalParameters.SavedFilesArray;
	LibrarySavingDirectory = AdditionalParameters.LibrarySavingDirectory;
	LibraryFilesMap = AdditionalParameters.LibraryFilesMap;
	IsNotSaved = False;
	For Each KeyValue In LibraryFilesMap Do
		If SavedFilesArray.Find(KeyValue.Key) <> Undefined Then
			Continue;
		EndIf;
		IsNotSaved = True;

		FileName=LibrarySavingDirectory + GetPathSeparator() + KeyValue.Key;
		AdditionalParameters.Insert("CurrentFileKey", KeyValue.Key);

		If TypeOf(KeyValue.Value) = Type("TextDocument") Then
			CompletionNotify = New NotifyDescription("SaveEditorLibraryWriteBeginWritingNextFileOfTextDocumentEnd",
				ThisObject, AdditionalParameters);
		Else
			CompletionNotify = New NotifyDescription("SaveEditorLibraryWriteBeginWritingNextFileEnd", ThisObject,
				AdditionalParameters);
		EndIf;
		
		KeyValue.Value.BeginWrite(CompletionNotify, FileName);
		Break;
	EndDo;

	If Not IsNotSaved Then
		ExecuteNotifyProcessing(AdditionalParameters.CompletionNotifyDescription, True);
	EndIf;
EndProcedure

Function EditorSaveDirectory(EditorType)
	FileVariablesStructure=UT_CommonClient.SessionFileVariablesStructure();
	If Not FileVariablesStructure.Property("TempFilesDirectory") Then
		Return "";
	EndIf;

	Return UT_CommonClient.UT_AssistiveLibrariesDirectory() + GetPathSeparator() 
		+ EditorType;
EndFunction

// New Build parameters processing for editors.
// 
// Return values:
//  Structure - New Build parameters processing for editors:
// * CallbackDescriptionAboutCompletion - CallbackDescription, Undefined -
// * EditorsForBuild - Array of см. UT_CodeEditorClientServer.NewEditorDataForBuildDataProcessor-
// * EditorIndexForBuild - Number -
// * CatalogTemplateProcessing - String -
// * Form - ClientApplicationForm,Undefined -
// * ConfiguratorCommandContext - см. UT_ConfiguratorManagementClient.NewContextConfiguratorCommand, Undefined -
Function NewBuildParametersDataProcessorsForEditors()
	BuildOptions = New Structure();
	BuildOptions.Insert("CallbackDescriptionAboutCompletion", Undefined);
	BuildOptions.Insert("EditorsForBuild", New Array);
	BuildOptions.Insert("EditorIndexForBuild", 0);
	BuildOptions.Insert("CatalogTemplateProcessing", "");
	BuildOptions.Insert("ConfiguratorCommandContext", Undefined);
	BuildOptions.Insert("Form", Undefined);
	
	Return BuildOptions;
EndFunction
	
// An interaction script is connected to the HTMLEditor field.
// 
// Parameters:
//  DocumentView -ExternalObject-Документ view
// 
// Return values:
//  Boolean -  An interaction script is connected to the HTMLEditor field
Function ToFieldHTMLEditorConnectedInteractionScript(DocumentView) 
	Return DocumentView.colaborator <> Undefined;
EndFunction	
	
	
// Connect to field HTML script interaction.
// 
// Parameters:
//  Form - ClientApplicationForm
//  EditorOptions - look at UT_CodeEditorClientServer.NewEditorFormData
//  DocumentHTML - ExternalObject
Procedure ConnectToFieldHTMLScriptInteraction(Form, EditorOptions, DocumentHTML)
	TypesOfEditors = UT_CodeEditorClientServer.CodeEditorVariants();
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);

	LibraryLayoutName = "";
	If EditorType = TypesOfEditors.Ace Then
		LibraryLayoutName = "UT_AceColaborator";
	EndIf;
	
	If Not ValueIsFilled(LibraryLayoutName) Then
		Return;
	EndIf;

	DataLibrariesEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorLibraryURL()];//Structure
	
	LibraryNameInteractionForDataForms = UT_CodeEditorClientServer.LibraryNameInteractionForDataForms(EditorType);
	
	If DataLibrariesEditors.Свойство(LibraryNameInteractionForDataForms) Then
		DataLibrariesInteractions = DataLibrariesEditors[LibraryNameInteractionForDataForms];
	Else
		DataLibrariesInteractions = UT_CodeEditorServerCall.DataLibraryGeneralLayout(LibraryLayoutName,
																								 Form.UUID);
		DataLibrariesEditors.Вставить(LibraryNameInteractionForDataForms, DataLibrariesInteractions);
	EndIf;
	
	ConnectLibraryToDocumentHTMLFields(DocumentHTML, DataLibrariesInteractions);
EndProcedure	
	
// Connect library to document HTML fields.
// 
// Parameters:
//  DocumentView - ExternalObject- Документ view
//  LibraryData - look at UT_CodeEditorServer.
Procedure ConnectLibraryToDocumentHTMLFields(DocumentView, LibraryData)
	For Each  ТекСкрипт In LibraryData.Scripts Do
		Element = DocumentView.document.createElement("script");
		Element.type = "text/javascript";
		Element.src = ТекСкрипт;
		DocumentView.document.body.appendChild(Element);	
	EndDo;
	
	For Each  ТекСкрипт In LibraryData.Styles Do
		Element = DocumentView.document.createElement("style");
		Element.innerHTML = ТекСкрипт;
		DocumentView.document.body.appendChild(Element);	
	EndDo;
EndProcedure	

// Adds a custom menu item to the editor context menu
// 
// Parameters:
//  DocumentView - ExternalObject - 
//  ThereAreAddedCommandsForEditorContextMenuMonaco - Boolean
//  ID - String - Menu command ID
//  Name - String - Name menu commands
Procedure AddMenuItem(DocumentView, ThereAreAddedCommandsForEditorContextMenuMonaco, ID,
	Name)
	If ThereAreAddedCommandsForEditorContextMenuMonaco Then
		Return;
	EndIf;
	DocumentView.addContextMenuItem(Name, ID);
EndProcedure



#EndRegion