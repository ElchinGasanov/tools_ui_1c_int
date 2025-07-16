///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, 1C-Soft LLC
// All Rights reserved. This application and supporting materials are provided under the terms of 
// Attribution 4.0 International license (CC BY 4.0)
// The license text is available at:
// https://creativecommons.org/licenses/by/4.0/legalcode
// Translated by Universal Tools 1C Word Edition Team
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Region EventHandlers
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	// Checking the access rights must be the first action in this procedure.
	If Not AccessRight("Administration", Metadata) Then
		Raise NStr("ru = 'Использование обработки в интерактивном режиме доступно только администратору.'; en = 'Running the data processor manually requires administrator rights.'; tr = 'Veri işlemciyi manuel çalıştırmak yönetici hakları gerektirir.'");
	EndIf;
	
	Object.ExchangeFileName = Parameters.ExchangeFileName;
	Object.ExchangeRulesFileName = Parameters.ExchangeRulesFileName;
	Object.EventHandlerExternalDataProcessorFileName = Parameters.EventHandlerExternalDataProcessorFileName;
	Object.AlgorithmDebugMode = Parameters.AlgorithmDebugMode;
	Object.ReadEventHandlersFromExchangeRulesFile = Parameters.ReadEventHandlersFromExchangeRulesFile;

	FormHeader = NStr("ru = 'Настройка отладки обработчиков при %Event% данных'; en = 'Configure debugguing upon data %Event%'; tr = '%Event% verisi üzerinde hata ayıklamayı yapılandır'");	
	Event = ?(Parameters.ReadEventHandlersFromExchangeRulesFile, NStr("ru = 'выгрузке'; en = 'export'; tr = 'dışa aktarma'"), NStr("ru = 'загрузке'; en = 'import'; tr = 'içe aktarma'"));
	FormHeader = StrReplace(FormHeader, "%Event%", Event);
	Title = FormHeader;
	
	ButtonTitle = NStr("ru = 'Сформировать модуль отладки %Event%'; en = 'Generate %Event% debug module'; tr = '%Event% hata ayıklama modülünü oluştur'");
	Event = ?(Parameters.ReadEventHandlersFromExchangeRulesFile, NStr("ru = 'выгрузки'; en = 'export'; tr = 'dışa aktarma'"), NStr("ru = 'загрузки'; en = 'import'; tr = 'içe aktarma'"));
	ButtonTitle = StrReplace(ButtonTitle, "%Event%", Event);
	Items.ExportHandlersScript.Title = ButtonTitle;

	SpecialTextColor = StyleColors.SpecialTextColor;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	SetVisibility();
	
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure AlgorithmDebugModeOnChange(Item)
	
	OnChangeDebugModeChange();
	
EndProcedure

&AtClient
Procedure EventHandlerExternalDataProcessorFileNameStartChoice(Item, ChoiceData, StandardProcessing)
	
	FileSelectionDialog = New FileDialog(FileDialogMode.Open);
	
	FileSelectionDialog.Filter     = NStr("ru = 'Файл внешней обработки обработчиков событий (*.epf)|*.epf'; en = 'Event handler external data processor file (*.epf)|*.epf'; tr = 'Olay işleyici harici veri işlemci dosyası (*.epf)|*.epf'");
	FileSelectionDialog.DefaultExt = "epf";
	FileSelectionDialog.Title = NStr("ru = 'Выберите файл'; en = 'Select file'; tr = 'Dosya seç'");
	FileSelectionDialog.Preview = False;
	FileSelectionDialog.FilterIndex = 0;
	FileSelectionDialog.FullFileName = Item.EditText;
	FileSelectionDialog.CheckFileExist = True;
	
	AdditionalParameters = New Structure;
	AdditionalParameters.Insert("Item", Item);

	Notification = New NotifyDescription("EventHandlerExternalDataProcessorFileNameChoiceProcessing", ThisObject, 
		AdditionalParameters);
	FileSelectionDialog.Show(Notification);
	
EndProcedure

// Parameters:
//   SelectedFiles - Array:
//     - String, Undefined - a file selection result.
//   AdditionalParameters - Structure:
//     * Item - FormField - a file selection source.
&AtClient
Procedure EventHandlerExternalDataProcessorFileNameChoiceProcessing(SelectedFiles, AdditionalParameters) Export
	
	If SelectedFiles = Undefined Then
		Return;
	EndIf;
	
	Object.EventHandlerExternalDataProcessorFileName = SelectedFiles[0];
	
	EventHandlerExternalDataProcessorFileNameOnChange(AdditionalParameters.Item);
	
EndProcedure

&AtClient
Procedure EventHandlerExternalDataProcessorFileNameOnChange(Item)
	
	SetVisibility();
	
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure Finish(Command)
	
	ClearMessages();
	
	If IsBlankString(Object.EventHandlerExternalDataProcessorFileName) Then
		
		MessageToUser(NStr("ru = 'Укажите имя файла внешней обработки.'; en = 'Enter the external data processor file name.'; tr = 'Harici veri işlemci dosyası adını girin.'"), 
			"EventHandlerExternalDataProcessorFileName");
		Return;
		
	EndIf;
	
	EventHandlerExternalDataProcessorFile = New File(Object.EventHandlerExternalDataProcessorFileName);
	
	Notification = New NotifyDescription("EventHandlerExternalDataProcessorFileExistenceCheckCompletion", 
		ThisObject);
	EventHandlerExternalDataProcessorFile.BeginCheckingExistence(Notification);
	
EndProcedure

&AtClient
Procedure EventHandlerExternalDataProcessorFileExistenceCheckCompletion(Exists, AdditionalParameters) Export
	
	If Not Exists Then
		MessageToUser(NStr("ru = 'Указанный файл внешней обработки не существует.'; en = 'The specified external data processor file does not exist.'; tr = 'Belirtilen harici veri işlemci dosyası mevcut değil.'"),
			"EventHandlerExternalDataProcessorFileName");
		Return;
	EndIf;
	
	ClosingParameters = New Structure;
	ClosingParameters.Insert("EventHandlerExternalDataProcessorFileName",
		Object.EventHandlerExternalDataProcessorFileName);
	ClosingParameters.Insert("AlgorithmDebugMode", Object.AlgorithmDebugMode);
	ClosingParameters.Insert("ExchangeRulesFileName", Object.ExchangeRuleFileName);
	ClosingParameters.Insert("ИмяФайлаОбмена", Object.ExchangeFileName);

	Close(ClosingParameters);

EndProcedure

&AtClient
Procedure OpenFile(Command)
	
	ShowEventHandlersInWindow();
	
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure SetVisibility()
	
	OnChangeDebugModeChange();
	
	// Highlighting wizard steps that require corrections with red color.
	SelectExternalDataProcessorName(IsBlankString(Object.EventHandlerExternalDataProcessorFileName));
	
	Items.OpenFile.Enabled = Not IsBlankString(Object.EventHandlersTempFileName);
	
EndProcedure

&AtClient
Procedure SelectExternalDataProcessorName(NeedToSelect = False) 
	
	Items.Step4Pages.CurrentPage = ?(NeedToSelect, Items.RedPage, Items.GreenPage);
	
EndProcedure

&AtClient
Procedure ExportHandlersScript(Command)
	
	// Data was exported earlier...
	If Not IsBlankString(Object.EventHandlersTempFileName) Then
		
		ButtonsList = New ValueList;
		ButtonsList.Add(DialogReturnCode.Yes, NStr("ru = 'Выгрузить повторно'; en = 'Repeat export'; tr = 'Aktarımı tekrarla'"));
		ButtonsList.Add(DialogReturnCode.No, NStr("ru = 'Открыть модуль'; en = 'Open module'; tr = 'Modülü aç'"));
		ButtonsList.Add(DialogReturnCode.Cancel);
		
		NotifyDescription = New NotifyDescription("ExportHandlersScriptCompletion", ThisObject);
		ShowQueryBox(NotifyDescription, NStr("ru = 'Модуль отладки с кодом обработчиков уже выгружен.'; en = 'The debug module with the handler script is already exported.'; tr = 'İşleyici kodu içeren hata ayıklama modülü zaten dışa aktarıldı.'"), 
			ButtonsList,,DialogReturnCode.No);
		
	Else
		
		ExportHandlersScriptCompletion(DialogReturnCode.Yes, Undefined);
		
	EndIf;
	
EndProcedure

&AtClient
Procedure ExportHandlersScriptCompletion(Result, AdditionalParameters) Export
	
	HasExportErrors = False;
	
	If Result = DialogReturnCode.Yes Then
		
		ExportedWithErrors = False;
		ExportEventHandlersAtServer(ExportedWithErrors);
		
	ElsIf Result = DialogReturnCode.Cancel Then
		
		Return;
		
	EndIf;
	
	If Not HasExportErrors Then
		
		SetVisibility();
		
		ShowEventHandlersInWindow();
		
	EndIf;
	
EndProcedure

&AtClient
Procedure ShowEventHandlersInWindow()
	
	EventHandlers = EventHandlers();
	If EventHandlers <> Undefined Then
		EventHandlers.Show(NStr("ru = 'Модуль отладки обработчиков'; en = 'Handler debug module'; tr = 'İşleyici hata ayıklama modülü'"));
	EndIf;
	ExchangeLog = ExchangeLog();
	If ExchangeLog <> Undefined Then
		ExchangeLog.Show(NStr("ru = 'Ошибки выгрузки модуля обработчиков'; en = 'Handler debug module export errors'; tr = 'İşleyici hata ayıklama modülü dışa aktarma hataları'"));
	EndIf;
	
EndProcedure

&AtServer
Function EventHandlers()
	
	EventHandlers = Undefined;
	
	HandlersFile = New File(Object.EventHandlersTempFileName);
	If HandlersFile.Exist() And HandlersFile.Size() <> 0 Then
		EventHandlers = New TextDocument;
		EventHandlers.Read(Object.EventHandlersTempFileName);
	EndIf;
	
	Return EventHandlers;
	
EndFunction

&AtServer
Function ExchangeLog()
	
	ExchangeLog = Undefined;
	
	ErrorLogFile = New File(Object.ExchangeLogTempFileName);
	If ErrorLogFile.Exist() And ErrorLogFile.Size() <> 0 Then
		ExchangeLog = New TextDocument;
		ExchangeLog.Read(Object.EventHandlersTempFileName);
	EndIf;
	
	Return ExchangeLog;
	
EndFunction

&AtServer
Procedure ExportEventHandlersAtServer(Cancel)
	
	ObjectForServer = FormAttributeToValue("Object");
	FillPropertyValues(ObjectForServer, Object);
	ObjectForServer.ExportEventHandlers(Cancel);
	ValueToFormAttribute(ObjectForServer, "Object");
	
EndProcedure

&AtClient
Procedure OnChangeDebugModeChange()
	
	Tooltip = Items.AlgorithmsDebugTooltip;
	
	Tooltip.CurrentPage = Tooltip.ChildItems["Group_"+Object.AlgorithmDebugMode];
	
EndProcedure

&AtClientAtServerNoContext
Procedure MessageToUser(Text, DataPath = "")
	
	Message = New UserMessage;
	Message.Text = Text;
	Message.DataPath = DataPath;
	Message.Message();
	
EndProcedure

#EndRegion