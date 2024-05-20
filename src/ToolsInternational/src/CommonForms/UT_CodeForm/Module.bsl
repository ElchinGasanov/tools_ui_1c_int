
 
#Region ОписаниеПеременных

&AtClient
Var UT_CodeEditorClientData Export;

#EndRegion

#Region ОбработчикиСобытийФормы

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Not Parameters.Property("Code") Then
		Cancel = True;
	EndIf;
	
	Code = Parameters.Code;
	
	If Parameters.Property("MethodNameToGoToDefinition") Then
		MethodNameToGoToDefinition = Parameters.MethodNameToGoToDefinition;
	EndIf;
	
	If Parameters.Property("ModuleName") Then
		Caption = Parameters.ModuleName;
	EndIf;
	
	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Code", Items.CodeField);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	UT_CodeEditorClient.FormOnOpen(ThisObject, Undefined);
EndProcedure



#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы

// Code of procedures and functions

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыФормы //<ИмяТаблицыФормы>

// Code of procedures and functions

#EndRegion

#Region ОбработчикиКомандФормы


&AtClient
Procedure CopyToClipboard(Command)
	UT_ClipboardClient.BeginCopyTextToClipboard(UT_CodeEditorClient.EditorCodeText(ThisObject, "Code"),
													   New CallbackDescription("CopyToClipboardFinish",
		ThisObject));
EndProcedure


&AtClient
Procedure Share(Command)
	TextCode = UT_CodeEditorClient.EditorCodeText(ThisObject, "Code");
	UT_CodeEditorClient.ShareCode(TextCode, False, ThisObject);
EndProcedure

#EndRegion

#Region СлужебныеПроцедурыИФункции

// Copy to clipboard finish.
// 
// Parameters:
//  Result - Булево - Result
//  CallOptions - Arbitrary -
//  ExtraParameters - Undefined - Extra parameters
&AtClient
Procedure CopyToClipboardFinish(Result, CallOptions, ExtraParameters) Export
	If Result = True Then
		Title = NStr("ru = 'Код скопирован в буфер обмена'; en = 'The code has been copied to the clipboard'");
	Иначе
		Title = NStr("ru = 'Не удалось скопировать в буфер обмена'; en = 'Failed to copy to clipboard'");
	EndIf;
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ПолеРедактораДокументСформирован(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ПолеРедактораПриНажатии(Item, EventData, StandardProcessing)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, EventData, StandardProcessing);
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_РедакторКодаОтложеннаяИнициализацияРедакторов()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient 
Procedure Подключаемый_РедакторКодаЗавершениеИнициализации() Export
	UT_CodeEditorClient.SetEditorText(ThisObject, "Code", Code);
	UT_CodeEditorClient.SetEditorViewOnlyMode(ThisObject, "Code", True);
	
	If ValueIsFilled(MethodNameToGoToDefinition) Then
		UT_CodeEditorClient.GotoEditorMethodDefinition(ThisObject, "Code", MethodNameToGoToDefinition);
	EndIf;
EndProcedure

&AtClient
Procedure Подключаемый_РедакторКодаОтложеннаяОбработкаСобытийРедактора() Export
	UT_CodeEditorClient.EditorEventsDeferProcessing(ThisObject);
EndProcedure





#EndRegion
