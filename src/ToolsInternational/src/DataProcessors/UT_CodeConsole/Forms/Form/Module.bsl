#Region Variables

&AtClient
Var FormCloseConfirmed;

&AtClient
Var UT_CodeEditorClientData Export;

&AtClient
Var UT_CurrentAlgorithmRowID; //Number

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject
		, "Code"
		, Items.FieldAlgorithm
		,
		,
		, Items.GroupFieldAlgorithmCommandPanel);
		
		
		UT_Common.ToolFormOnCreateAtServer(ThisObject
			, Cancel
			, StandardProcessing
			, Items.MainCommandBar);
	
	NewAlgorithmRow = Algorithms.GetItems().Add();
	NewAlgorithmRow.Name = "Algorithms";
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Not FormCloseConfirmed Then
		Cancel = True;
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	FormCloseConfirmed = False;
	UT_CodeEditorClient.FormOnOpen(ThisObject, New NotifyDescription("OnOpenEnd",ThisObject));
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldDocumentGenerated(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldOnClick(Item, EventData, StandardProcessing)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, EventData, StandardProcessing);
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersAlgorithmsVariables

&AtClient
Procedure AlgorithmsVariablesOnEditEnd(Item, NewRow, CancelEdit)
	AddAdditionalContextToCodeEditor();
EndProcedure

&AtClient
Procedure AlgorithmsVariablesBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	If CancelEdit Then
		Return;
	EndIf;
		
	CurrentData = Items.AlgorithmsVariables.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	If Not UT_CommonClientServer.IsCorrectVariableName(CurrentData.Name) Then
		Cancel = True;
	EndIf;
EndProcedure

&AtClient
Procedure AlgorithmsVariablesValueStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData = Items.AlgorithmsVariables.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject
		, Items
		, "Value");	
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.Value = CurrentData.Value;
	HandlerParameters.StructureValueStorage = CurrentData;
	HandlerParameters.TypesSet = UT_CommonClientServer.AllEditingTypeSets();
	
	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure AlgorithmsVariablesValueOnChange(Item)
	CurrentData = Items.AlgorithmsVariables.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorInChangingEventsParameters(ThisObject
		, Items
		, "Value");		
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;
	
	UT_CommonClient.FormFieldInChangeProcessor(HandlerParameters);
EndProcedure

&AtClient
Procedure AlgorithmsVariablesValueClearing(Item, StandardProcessing)
	CurrentData = Items.AlgorithmsVariables.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject
		, Items
		, "Value");		
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;
	
	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
	
EndProcedure


#EndRegion

#Region FormTableItemsEventHandlersAlgorithms

&AtClient
Procedure AlgorithmsBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	If CancelEdit Then
		Return;
	EndIf;
	
	CurrentData = Items.Algorithms.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	If Not UT_CommonClientServer.IsCorrectVariableName(CurrentData.Name) Then
		Cancel = True;
	EndIf;
EndProcedure

&AtClient
Procedure AlgorithmsOnActivateRow(Item)
	SaveEditorDataInAlgorithmsTable();
	
	CurrentData = Items.Algorithms.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	UT_CurrentAlgorithmRowID = CurrentData.GetID();
	
	UT_CodeEditorClient.SetEditorText(ThisObject, "Code", CurrentData.Text);
	UT_CodeEditorClient.SetEditorOriginalText(ThisObject, "Code", CurrentData.OriginalText);
	UT_CodeEditorClient.SetUseModeDataProcessorToExecuteEditorCode(ThisObject
		, "Code"
		, CurrentData.UseProcessorForCodeExecution);
	
	AddAdditionalContextToCodeEditor();
EndProcedure


&AtClient
Procedure AlgorithmsOnStartEdit(Item, NewRow, Clone)
	CurrentData = Items.Algorithms.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	If NewRow Then
		CurrentData.Name = "Algorithms" + Format(CurrentData.GetID(), "NG=0;");
	EndIf;
EndProcedure


#EndRegion

#Region FormCommandsEventHandlers
&AtClient
Procedure CloseConsole(Command)
	ShowQueryBox(New NotifyDescription("CloseConsoleEnd", ThisObject),NStr("ru = 'Выйти из консоли кода?';en = 'Exit code console ?'"),
		QuestionDialogMode.YesNo);
EndProcedure

&AtClient
Procedure ExecuteCode(Command)
	If UT_CurrentAlgorithmRowID = Undefined Then
		Return;
	EndIf;
	
	SaveEditorDataInAlgorithmsTable();
	
	AlgorithmRow = Algorithms.FindByID(UT_CurrentAlgorithmRowID);
	
	AdditionalInfo = New Structure;
	AdditionalInfo.Insert("AlgorithmRow", AlgorithmRow);
	
	If SaveBeforeExecution And ValueIsFilled(AlgorithmFileName) Then
		SaveFileToDisk(, New CallbackDescription("ExecuteCodeAlgorithmFileSavingEnd", ThisObject
		, AdditionalInfo));
	Else
		ExecuteCodeAlgorithmFileSavingEnd(True, AdditionalInfo);
	EndIf;
			

EndProcedure

&AtClient
Procedure EditVariableValue(Command)
	CurrentData = Items.AlgorithmsVariables.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditObject(CurrentData.Value);
EndProcedure


&AtClient
Procedure NewAlgorithm(Command)
	AlgorithmsRows = Algorithms.GetItems();
	AlgorithmsRows.Clear();
	
	NewAlgorithmRow = AlgorithmsRows.Add();
	NewAlgorithmRow.Name = "Algorithm";
	
	AlgorithmFileName="";

	SetTitle();
EndProcedure

&AtClient
Procedure OpenFile(Command)
	UT_CommonClient.ReadConsoleFromFile("CodeConsole", SavedFilesDescriptionStructure(),
		New NotifyDescription("OpenFileEnd", ThisObject));
EndProcedure

&AtClient
Procedure SaveFile(Command)
	SaveFileToDisk();
EndProcedure

&AtClient
Procedure SaveFileAs(Command)
	SaveFileToDisk(True);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

&AtClient
Procedure Attachable_ExecuteCodeEditorCommand(Command) 
	UT_CodeEditorClient.ExecuteCodeEditorCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

// Execute code - algorithm saving in file end.
// 
// Parameters:
// 	Result - Boolean - Result
//	 AdditionalParameters - Structure - Additional Parameters:
//	 * AlgorithmString - FormDataTreeItem.
&AtClient
Procedure ExecuteCodeAlgorithmFileSavingEnd(Result, AdditionalParameters) Export
	AlgorithmRow = AdditionalParameters.AlgorithmRow;
	
	ClientEditors = New Array;
	If AlgorithmRow.AtClient Then
		ClientEditors.Add("Code");
	EndIf;
	
	StructureVariableEditorsNames = New Structure;
	
	ArrayNames = New Array;
	For Each CurrentVar In AlgorithmRow.Variables Do
		ArrayNames.Add(CurrentVar.Name);
	EndDo;
	ArrayNames.Add("TransmissionStructure");
	StructureVariableEditorsNames.Insert("Code", ArrayNames);
	
	CallBackParameters = New Structure;
	CallBackParameters.Insert("Begin", CurrentUniversalDateInMilliseconds());
	CallBackParameters.Insert("AlgorithmRow", AlgorithmRow);

	UT_CodeEditorClient.StartBuildDataProcessorForCodeExecution(ThisObject,
		New CallbackDescription("ExecuteCodeAssemblingProcessorsEnd",
			ThisObject, CallBackParameters)
		, StructureVariableEditorsNames
		, ClientEditors);

	
EndProcedure

&AtClient
Procedure SaveEditorDataInAlgorithmsTable()
	If UT_CurrentAlgorithmRowID = Undefined Then
		Return;
	EndIf;
	CurrentData = Algorithms.FindByID(UT_CurrentAlgorithmRowID);
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	CurrentData.Text = UT_CodeEditorClient.EditorCodeText(ThisObject, "Code");
	CurrentData.UseProcessorForCodeExecution = UT_CodeEditorClient.UsageModeDataProcessorToExecuteEditorCode(ThisObject, "Code");

EndProcedure

&AtClient
Procedure ExecuteCodeAssemblingProcessorsEnd(Result, AdditionalParameters) Export

	AlgorithmRow = AdditionalParameters.AlgorithmRow;
	If Not ValueIsFilled(TrimAll(AlgorithmRow)) Then
		Return;
	EndIf;

	If AlgorithmRow.AtClient Then
		ExecuteCodeAtClient(AlgorithmRow.GetID());
	Else
		ExecuteCodeAtServer(AlgorithmRow.GetID());
	EndIf;

EndProcedure

&AtClient
Procedure ExecuteCodeAtClient(AlgorithmRowID)
	ExecuteAlgorithmCode(ThisObject, Algorithms, AlgorithmRowID);
EndProcedure

&AtServer
Procedure ExecuteCodeAtServer(AlgorithmRowID)
	ExecuteAlgorithmCode(ThisObject, Algorithms, AlgorithmRowID);
EndProcedure

&AtClientAtServerNoContext
Procedure ExecuteAlgorithmCode(Form, Algorithms, AlgorithmRowID)
	AlgorithmRow = Algorithms.FindByID(AlgorithmRowID);
	
	ExecutionContext = AlgorithmExecutionContext(AlgorithmRow.Variables);
	
	Result = UT_CodeEditorClientServer.ExecuteAlgorithm(AlgorithmRow.Text
		, ExecutionContext
		, AlgorithmRow.AtClient
		, Form
		, "Code");
		
	AlgorithmRow.Info = String((Result.ExecutionTime) / 1000) + " sec.";

EndProcedure

&AtClient
Function ContextVariables(VariablesTabularSection)
	VariablesArray=New Array;
	For Each CurrentVariable In VariablesTabularSection Do
		VariableStructure=New Structure;
		VariableStructure.Insert("Name", CurrentVariable.Name);
		VariableStructure.Insert("Type", TypeOf(CurrentVariable.Value));

		VariablesArray.Add(VariableStructure);
	EndDo;
	
	Return VariablesArray;
EndFunction


&AtClient
Procedure AddAdditionalContextToCodeEditor()
	If UT_CurrentAlgorithmRowID = Undefined Then
		Return;
	EndIf;
	
	AlgorithmRow = Algorithms.FindByID(UT_CurrentAlgorithmRowID);
	
	AdditionalContextStructure = New Structure;
		
	ContextVariables = ContextVariables(AlgorithmRow.Variables); 
	For Each Variable In ContextVariables Do
		If Not UT_CommonClientServer.IsCorrectVariableName(Variable.Name) Then
			Continue;
		EndIf;
		
		AdditionalContextStructure.Insert(Variable.Name, Variable.Type);
	EndDo;
	
	UT_CodeEditorClient.AddCodeEditorContext(ThisObject, "Code", AdditionalContextStructure);
EndProcedure

&AtClient
Procedure OnOpenEnd(Result, AdditionalParameters) Export

EndProcedure

&AtClient
Function SavedFilesDescriptionStructure()
	Structure=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Structure.FileName=AlgorithmFileName;

	UT_CommonClient.AddFormatToSavingFileDescription(Structure,NStr("ru = 'Файл алгоритма(*.xbsl)';en = 'Algorithm file (*.xbsl)'"), "xbsl");
	Return Structure;
EndFunction

&AtClient
Procedure SaveFileToDisk(SaveAs = False, CallbackDescriptionOnClose = Undefined)
	SaveEditorDataInAlgorithmsTable();

	AdditionalCallBackParameters = Undefined;
	If CallbackDescriptionOnClose <> Undefined Then
		AdditionalCallBackParameters = New Structure;
		AdditionalCallBackParameters.Insert("CallbackDescriptionOnClose", CallbackDescriptionOnClose);
	EndIf;
			
	UT_CommonClient.SaveConsoleDataToFile("CodeConsole", SaveAs,
		SavedFilesDescriptionStructure(), GetSaveString(),
		New NotifyDescription("SaveFileEnd", ThisObject, AdditionalCallBackParameters));
EndProcedure

&AtClient
Procedure SaveFileEnd(SaveFileName, AdditionalParameters) Export
	If SaveFileName = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(SaveFileName) Then
		Return;
	EndIf;

	Modified=False;
	AlgorithmFileName=SaveFileName;
	SetTitle();
	
	UT_CodeEditorClient.SetEditorOriginalTextEqualToCurrent(ThisObject, "Code");
	
	If AdditionalParameters <> Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.CallbackDescriptionOnClose, True);
	EndIf;
//	Message("The algorithm has been successfully saved");

EndProcedure

&AtClient
Procedure OpenFileEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	Modified=False;
	AlgorithmFileName = Result.FileName;

	OpenAlgorithmAtServer(Result.URL);

	SetTitle();
EndProcedure

&AtClient
Procedure CloseConsoleEnd(Result, AdditionalParameters) Export

	If Result = DialogReturnCode.Yes Then
		FormCloseConfirmed = True;
		Close();
	EndIf;

EndProcedure

&AtClientAtServerNoContext
Function AlgorithmExecutionContext(Variables)
	ExecutionContext = New Structure;
	
	For Each CurrentRow In Variables Do
		StorageFieldStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	
		ExecutionContext.Insert(CurrentRow.Name
			, UT_CommonClientServer.ValueContainerFieldValue(CurrentRow
				, StorageFieldStructure));
	EndDo;
	
	Return ExecutionContext;
EndFunction

&AtServer
Function GetSaveString()

	StoredData = New Structure;
	StoredData.Insert("FormatVersion", 2);
	StoredData.Insert("Algorithms", New Array);

	For Each AlgorithmRow In Algorithms.GetItems() Do
		StoredData.Algorithms.Add(AlgorithmDescriptionForSavingToFile(AlgorithmRow));
	EndDo;

	Return UT_CommonClientServer.mWriteJSON(StoredData);

EndFunction

&AtServer
Function AlgorithmDescriptionForSavingToFile(AlgorithmRow)
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	
	AlgorithmDescription = New Structure;
	AlgorithmDescription.Insert("Name", AlgorithmRow.Name);
	AlgorithmDescription.Insert("Text", AlgorithmRow.Text);
	AlgorithmDescription.Insert("AtClient", AlgorithmRow.AtClient);
	AlgorithmDescription.Insert("UseProcessorForCodeExecution"
		, AlgorithmRow.UseProcessorForCodeExecution);

	AlgorithmDescription.Insert("Variables", New Array);
	For Each Variable In AlgorithmRow.Variables Do
		VariableStructure = New Structure;
		VariableStructure.Insert("Name", Variable.Name);
		
		VariableValue = UT_CommonClientServer.ValueContainerFieldValue(Variable
			, ValueStorageStructure);
			
		VariableStructure.Insert("Value", ValueToStringInternal(VariableValue));
		VariableStructure.Insert("Type", ValueToStringInternal(TypeOf(VariableValue)));
		
		AlgorithmDescription.Variables.Add(VariableStructure);
	EndDo;
	
	AlgorithmDescription.Insert("Rows", New Array);
	
	For Each CurrentRow In AlgorithmRow.GetItems() Do
		AlgorithmDescription.Rows.Add(AlgorithmDescriptionForSavingToFile(CurrentRow));
	EndDo;
		
	Return AlgorithmDescription;	
EndFunction

&AtServer
Procedure OpenAlgorithmAtServer(FileURLInTempStorage)
	FileData = GetFromTempStorage(FileURLInTempStorage);

	JSONReader = New JSONReader;
	JSONReader.OpenStream(FileData.OpenStreamForRead());

	FileStructure = ReadJSON(JSONReader);
	JSONReader.Close();

	FormatVersion = 1;
	If FileStructure.Property("FormatVersion") Then
		FormatVersion = FileStructure.FormatVersion;
	EndIf;	

	Algorithms.GetItems().Clear();

	If FormatVersion = 1 Then
		FillFormFormatVersion_1(FileStructure);
	Else
		FillAlgorithmsFormatVersion_2(FileStructure);				
	EndIf;
	
EndProcedure

&AtServer
Procedure FillFormFormatVersion_1(FileStructure)
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");		
	
	AlgorithmItems = Algorithms.GetItems();
	
	If ValueIsFilled(FileStructure.TextAlgorithmClient) Or FileStructure.ClientVariables.Count() > 0 Then
		NewAlgorithmRow = AlgorithmItems.Add();
		NewAlgorithmRow.OriginalText = FileStructure.TextAlgorithmClient;
		NewAlgorithmRow.Text = FileStructure.TextAlgorithmClient;
		NewAlgorithmRow.AtClient = True;
		NewAlgorithmRow.Name = "Client";
	
		For Each Variable In FileStructure.ClientVariables Do
			NewVariable = NewAlgorithmRow.Variables.Add();
			NewVariable.Name = Variable.Name;
			
			UT_CommonClientServer.SetContainerFieldValue(NewVariable
				, ValueStorageStructure
				, ValueFromStringInternal(Variable.Value));
		EndDo;
	EndIf;
	
	If ValueIsFilled(FileStructure.TextAlgorithmServer) Or FileStructure.ServerVariables.Count() > 0 Then
		NewAlgorithmRow = AlgorithmItems.Add();
		NewAlgorithmRow.OriginalText = FileStructure.TextAlgorithmServer;
		NewAlgorithmRow.Text = FileStructure.TextAlgorithmServer;
		NewAlgorithmRow.AtClient = False;
		NewAlgorithmRow.Name = "Server";
	
		For Each Variable In FileStructure.ServerVariables Do
			NewVariable = NewAlgorithmRow.Variables.Add();
			NewVariable.Name = Variable.Name;
			
			UT_CommonClientServer.SetContainerFieldValue(NewVariable
				, ValueStorageStructure
				, ValueFromStringInternal(Variable.Value));
		EndDo;
	EndIf;
	
EndProcedure

&AtServer
Procedure FillAlgorithmsFormatVersion_2(FileStructure)
	AlgorithmItems = Algorithms.GetItems();
	
	For Each CurrentAlgorithm In FileStructure.Algorithms Do
		FillAlgorithmsFromFile(CurrentAlgorithm, AlgorithmItems);
	EndDo;		
	
EndProcedure

&AtServer
Procedure FillAlgorithmsFromFile(FileAlgorithm, AlgorithmItemsCollection)
	ValueStorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer("Value");
	
	NewAlgorithmRow = AlgorithmItemsCollection.Add();
	NewAlgorithmRow.Name = FileAlgorithm.Name;
	NewAlgorithmRow.Text = FileAlgorithm.Text;
	NewAlgorithmRow.OriginalText = FileAlgorithm.Text;
	NewAlgorithmRow.AtClient = FileAlgorithm.AtClient;
	NewAlgorithmRow.UseProcessorForCodeExecution = FileAlgorithm.UseProcessorForCodeExecution;
	
	For Each Variable In FileAlgorithm.Variables Do
		NewVariable = NewAlgorithmRow.Variables.Add();	
		NewVariable.Add = Variable.Name;
		
		UT_CommonClientServer.SetContainerFieldValue(NewVariable
			, ValueStorageStructure
			, ValueFromStringInternal(Variable.Value));
	EndDo;
	
	RowCollection = NewAlgorithmRow.GetItems();
	For Each SubAlgorithm In FileAlgorithm.Rows Do
		FillAlgorithmsFromFile(SubAlgorithm, RowCollection);
	EndDo;	
	
EndProcedure

&AtClient
Procedure SetTitle()
	Title = AlgorithmFileName;
EndProcedure


//@skip-warning
&AtClient
Procedure Attachable_CodeEditorDeferredInitializingEditors()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient 
Procedure Attachable_CodeEditorInitializingCompletion() Export
	If ValueIsFilled(AlgorithmFileName) Then
		UT_CommonClient.ReadConsoleFromFile("CodeConsole", SavedFilesDescriptionStructure(),
			New NotifyDescription("OpenFileEnd", ThisObject), True);
	EndIf;
EndProcedure

&AtClient
Procedure Attachable_CodeEditorDeferProcessingOfEditorEvents() Export
	UT_CodeEditorClient.EditorEventsDeferProcessing(ThisObject)
EndProcedure






#EndRegion

