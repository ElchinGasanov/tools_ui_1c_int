#Region Variables

&AtClient
Var UT_CodeEditorClientData Export;

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ExpressionTextLabel =
	NStr("ru = 'В тексте выражения можно использовать следующие предопределенные параметры:
	|	Результат		- результат вычисления (на входе - значение по умолчанию)
	|	ТекстЯчейки		- текст текущей ячейки
	|	ТекстыЯчеек		- массив текстов ячеек строки
	|	ТекущиеДанные	- структура загруженных значений
	|	ОписаниеОшибки	- описание ошибки, выводимое в примечание ячейки и в окно сообщений
	|Встроенные функции, функции общих модулей.';
	|en = 'The following predefined parameters are available in the expression text:
	|	Result			- An evaluation result. Default value on start of the procedure.
	|	CellText			- A current cell text.
	|	CellsTexts		- An array of row cells texts.
	|	CurrentData		- A structure with an imported values.
	|	ErrorDescription	- A description of an error which can be put out to cell tootlip and to message window.
	|Embedded functions, common module functions.'");

	ExpressionText = Parameters.Expression;
	ResultType = Parameters.ResultType;
	ColumnsRows = Parameters.ColumnsRows;

	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject,
											"Expression",
											Items.TextDocumentField);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	UT_CodeEditorClient.FormOnOpen(ThisObject);
EndProcedure


#EndRegion

#Region FormCommandsEventHandlers

// OK button handler
//
&AtClient
Procedure OK(Command)

	NotifyChoice(New Structure("Source, Result, Expression", "EditExpressionForm", True,
		CurrentExpressionText()));

EndProcedure

#EndRegion

#Region Private

#Region CodeEditor

&AtClient
Procedure SetExpressionText(NewText, SetOriginalText = False, NewOriginalText = "")
	UT_CodeEditorClient.SetEditorText(ThisObject, "Expression", NewText);

	If SetOriginalText Then
		UT_CodeEditorClient.SetEditorOriginalText(ThisObject, "Expression", NewOriginalText);
	EndIf;
EndProcedure

&AtClient
Function CurrentExpressionText()
	Return UT_CodeEditorClient.EditorCodeText(ThisObject, "Expression");
EndFunction

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

//@skip-warning
&AtClient
Procedure Attachable_CodeEditorDeferredInitializingEditors()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient
Procedure Attachable_CodeEditorInitializingCompletion() Export
	SetExpressionText(ExpressionText, True, ExpressionText);
	UT_AddContextFields();
EndProcedure

&AtClient
Procedure Attachable_CodeEditorDeferProcessingOfEditorEvents() Export
	UT_CodeEditorClient.EditorEventsDeferProcessing(ThisObject);
EndProcedure

#EndRegion

&AtClient
Procedure UT_AddContextFields()
	AdditionalContextStructure = New Structure;

	EmptyTypeDescription = New TypeDescription;

		
	VariableStructure = New Structure;
	VariableStructure.Insert("Type", "Array");
	VariableStructure.Insert("ChildProperties", New Structure);
	AdditionalContextStructure.Insert("CellsTexts", VariableStructure);
	
	ResultTypes = ResultType.Types();
	If ResultTypes.Count() > 0 Then
		AdditionalContextStructure.Insert("Result", ResultTypes[0]);
	Else
		AdditionalContextStructure.Insert("Result", "");
	EndIf;
	AdditionalContextStructure.Insert("CellText", "String");
	AdditionalContextStructure.Insert("ErrorDescription", "String");
	
	VariableStructure = New Structure;
	VariableStructure.Insert("Type", "Structure");
	VariableStructure.Insert("ChildProperties", New Structure);
	
	For Each ColumnKeyValue In ColumnsRows Do
		FieldStructure = New Structure;
		
		ColumnTypes = ColumnKeyValue.Value.TypeDescription.Types();
		
		If ColumnTypes.Count() > 0 Then
			FieldStructure.Insert("Type", ColumnTypes[0]);
		Else
			FieldStructure.Insert("Type", "");
		EndIf;
		FieldStructure.Insert("ChildProperties", New Structure);

		VariableStructure.ChildProperties.Insert(ColumnKeyValue.Value.AttributeName, FieldStructure);
	EndDo;
	
	AdditionalContextStructure.Insert("CurrentData", VariableStructure);
	
	UT_CodeEditorClient.AddCodeEditorContext(ThisObject, "Expression", AdditionalContextStructure);

EndProcedure

#EndRegion
