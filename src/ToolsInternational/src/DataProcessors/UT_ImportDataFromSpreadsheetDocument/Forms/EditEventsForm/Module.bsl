#Region Variables

&AtClient
Var UT_CodeEditorClientData Export;

#EndRegion

#Region FormEventHandlers

&AtClient
Procedure OnOpen(Cancel)

	SetExpressionTextLabel();

	UT_CodeEditorClient.FormOnOpen(ThisObject);

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ImportMode = Parameters.ImportMode;
	If ImportMode = 2 Then
		Items.BeforeWriteObjectGroup.Title 	= NStr("ru = 'Перед записью'; en = 'Before write'");
		Items.OnWriteObjectGroup.Title 		= NStr("ru = 'При записи'; en = 'On write'");
	EndIf;

	Items.AfterAddRowGroup.Visible = ImportMode = 1;

	BeforeWriteObject 	= Parameters.BeforeWriteObject;
	OnWriteObject 		= Parameters.OnWriteObject;
	AfterAddRow 		= Parameters.AfterAddRow;
	
	ObjectType = Parameters.ObjectType;

	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "BeforeWriteObject", Items.BeforeWriteObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "OnWriteObject", Items.OnWriteObject);

	If ImportMode = 1 Then
		UT_CodeEditorServer.CreateCodeEditorItems(ThisObject,
														   "AfterAddRow",
														   Items.AfterAddRow);
	EndIf;
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers
// Page change handler
//
&AtClient
Procedure BarOnCurrentPageChange(Item, CurrentPage)
	SetExpressionTextLabel();
EndProcedure

#EndRegion
#Region FormCommandsEventHandlers
// OK button handler
//
&AtClient
Procedure OK(Command)
	BeforeWriteObject = CurrentExpressionText("BeforeWriteObject");
	OnWriteObject = CurrentExpressionText("OnWriteObject");
	If ImportMode = 1 Then
		AfterAddRow = CurrentExpressionText("AfterAddRow");
	EndIf;
	NotifyChoice(New Structure("Source, Result, BeforeWriteObject, OnWriteObject, AfterAddRow",
		"EditEventsForm", True, BeforeWriteObject,
		OnWriteObject,AfterAddRow));
EndProcedure

#EndRegion

#Region Private
// Sets a label with a text of an expression.
//
&AtClient
Procedure SetExpressionTextLabel()
	If ImportMode = 1 Then

		If Items.BarGroup.CurrentPage.Name = "AfterAddRowGroup" Then

			ExpressionTextLabel =
			NStr("ru = 'В тексте выражения можно использовать следующие предопределенные параметры:
			|	Object			- Записываемый Object
			|	ТекущиеДанные	- Содержит данные загружаемой строки табличной части.
			|	CellsTexts		- Array текстов ячеек строки
			|Встроенные функции, функции общих модулей.';
			|en = 'The following predefined parameters are available in the expression text:
			|	Object			- Written object.
			|	CurrentData		- Imported table row data.
			|	CellsTexts		- An array of row cells texts.
			|Embedded functions, common module functions.'");
		Else

			ExpressionTextLabel =
			NStr("ru = 'В тексте выражения можно использовать следующие предопределенные параметры:
			|	Object			- Записываемый Object
			|	Cancel			- Признак Cancelа от записи Objectа
			|Встроенные функции, функции общих модулей.';
			|en = 'The following predefined parameters are available in the expression text:
			|	Object			- Written object.
			|	Cancel			- Write cancel flag.
			|Embedded functions, common module functions.'");

		EndIf;

	ElsIf ImportMode = 0 Then

		ExpressionTextLabel =
		NStr("ru = 'В тексте выражения можно использовать следующие предопределенные параметры:
		|	Object			- Записываемый Object
		|	Cancel			- Признак Cancelа от записи Objectа
		|	CellsTexts		- Array текстов ячеек строки
		|Встроенные функции, функции общих модулей.';
		|en = 'The following predefined parameters are available in the expression text:
		|	Object			- Written object.
		|	Cancel			- Write cancel flag.
		|	CellsTexts		- An array of row cells texts.
		|Embedded functions, common module functions.'");

	ElsIf ImportMode = 2 Then
		ExpressionTextLabel =
		NStr("ru = 'В тексте выражения можно использовать следующие предопределенные параметры:
		|	Object			- Менеджер записи регистра сведений
		|	Cancel			- Признак Cancelа от записи Objectа
		|	CellsTexts		- Array текстов ячеек строки
		|Встроенные функции, функции общих модулей.';
		|en = 'The following predefined parameters are available in the expression text:
		|	Object			- Information register record manager.
		|	Cancel			- Write cancel flag.
		|	CellsTexts		- An array of row cells texts.
		|Embedded functions, common module functions.;");
	EndIf;

EndProcedure // ()


#Region CodeEditor

&AtClient
Procedure SetEditorText(EditorID, NewText, SetOriginalText = False,
	NewOriginalText = "")
	UT_CodeEditorClient.SetEditorText(ThisObject, EditorID, NewText);

	If SetOriginalText Then
		UT_CodeEditorClient.SetEditorOriginalText(ThisObject,
												EditorID,
												NewOriginalText);
	EndIf;
EndProcedure

&AtClient
Function CurrentExpressionText(EditorID)
	Return UT_CodeEditorClient.EditorCodeText(ThisObject, EditorID);
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
	SetEditorText("BeforeWriteObject", BeforeWriteObject, True, BeforeWriteObject);
	SetEditorText("OnWriteObject", OnWriteObject, True, OnWriteObject);
	If ImportMode = 1 Then
		SetEditorText("AfterAddRow", AfterAddRow, True, AfterAddRow);
	EndIf;
	
	UT_AddContextFields();
EndProcedure

&AtClient
Procedure Attachable_CodeEditorDeferProcessingOfEditorEvents() Export
	UT_CodeEditorClient.EditorEventsDeferProcessing(ThisObject);
EndProcedure

#EndRegion

&AtClient
Function RecordObjectType()
	If TypeOf(ObjectType) = Type("String") Then
		Return ObjectType;
	EndIf;
	
	Types = ObjectType.Types();
	If Types.Count() > 0 Then
		Return Types[0];
	Else
		Return "";
	EndIf;
EndFunction

&AtClient
Procedure AddContextBeforeWrite()
	AdditionalContextStructure = New Structure;

	EmptyTypeDescription = New TypeDescription;

	AdditionalContextStructure.Insert("Cancel", "Boolean");
	AdditionalContextStructure.Insert("Object", RecordObjectType());

	If ImportMode <> 1 Then
		VariableStructure = New Structure;
		VariableStructure.Insert("Type", "Array");
		VariableStructure.Insert("ChildProperties", New Structure);
		AdditionalContextStructure.Insert("CellsTexts", VariableStructure);
	EndIf;

	UT_CodeEditorClient.AddCodeEditorContext(ThisObject,
											"BeforeWriteObject",
											AdditionalContextStructure);
EndProcedure

&AtClient
Procedure AddContextOnWrite()
	AdditionalContextStructure = New Structure;

	EmptyTypeDescription = New TypeDescription;

	AdditionalContextStructure.Insert("Cancel", "Boolean");
	AdditionalContextStructure.Insert("Object", RecordObjectType());

	If ImportMode <> 1 Then
		VariableStructure = New Structure;
		VariableStructure.Insert("Type", "Array");
		VariableStructure.Insert("ChildProperties", New Structure);
		AdditionalContextStructure.Insert("CellsTexts", VariableStructure);
	EndIf;

	UT_CodeEditorClient.AddCodeEditorContext(ThisObject,
											"OnWriteObject",
											AdditionalContextStructure);
EndProcedure

&AtClient
Procedure AddContexAfterAddRow()
	AdditionalContextStructure = New Structure;

	EmptyTypeDescription = New TypeDescription;

//			НадписьТекстВыражения =
//			"В тексте выражения можно использовать следующие предопределенные параметры:
//			|   Object         - Записываемый Object
//			|   ТекущиеДанные  - Содержит данные загружаемой строки табличной части.
//			|   CellsTexts    - Array текстов ячеек строки
//			|Встроенные функции, функции общих модулей.";

	AdditionalContextStructure.Insert("Cancel", "Boolean");
	AdditionalContextStructure.Insert("Object", RecordObjectType());

	If ImportMode <> 1 Then
		VariableStructure = New Structure;
		VariableStructure.Insert("Type", "Array");
		VariableStructure.Insert("ChildProperties", New Structure);
		AdditionalContextStructure.Insert("CellsTexts", VariableStructure);
	EndIf;

	UT_CodeEditorClient.AddCodeEditorContext(ThisObject,
											"OnWriteObject",
											AdditionalContextStructure);
EndProcedure

&AtClient
Procedure UT_AddContextFields()
	AddContextBeforeWrite();
	AddContextOnWrite();
	If ImportMode = 1 Then
		AddContexAfterAddRow();
	EndIf;

EndProcedure


#EndRegion
