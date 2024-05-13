#Region Public

#Область СборкаОбработкиДляИсполнения

// Начать сборку обработок для исполнения кода.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения- Форма
//  ОписаниеОповещенияОЗавершении -ОписаниеОповещения-Описание оповещения о завершении
//  ИменаПредустановленныхПеременных - Структура, Неопределено -
//  ИдентификаторыРедакторовДляИсполненияНаКлиенте - Массив из Строка, Неопределено -
Процедура НачатьСборкуОбработокДляИсполненияКода(Форма, ОписаниеОповещенияОЗавершении,
	ИменаПредустановленныхПеременных = Неопределено, ИдентификаторыРедакторовДляИсполненияНаКлиенте = Неопределено) Экспорт
	РедакторыКода = УИ_РедакторКодаКлиентСервер.РедакторыФормы(Форма);

	РедакторыДляСборки = Новый Массив;
	Для Каждого КлючЗначение Из РедакторыКода Цикл
		Если Не КлючЗначение.Значение.ИспользоватьОбработкуДляВыполненияКода Тогда
			Продолжить;
		КонецЕсли;

		ДанныеРедактораДляСборки = УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораДляСборкиОбработки();
		ДанныеРедактораДляСборки.Идентификатор = КлючЗначение.Ключ;
		Если ИдентификаторыРедакторовДляИсполненияНаКлиенте <> Неопределено Тогда
			ДанныеРедактораДляСборки.ИсполнениеНаКлиенте = ИдентификаторыРедакторовДляИсполненияНаКлиенте.Найти(КлючЗначение.Ключ) <> Неопределено;
		КонецЕсли;
		ДанныеРедактораДляСборки.ТекстРедактора = ТекстКодаРедактора(Форма, КлючЗначение.Ключ);
		ДанныеРедактораДляСборки.ИмяПодключаемойОбработки = УИ_РедакторКодаКлиентСервер.ИмяПодключаемойОбработкиДляИсполненияКодаРедактора(КлючЗначение.Ключ);

		Если ИменаПредустановленныхПеременных <> Неопределено Тогда
			Если ИменаПредустановленныхПеременных.Свойство(КлючЗначение.Ключ) Тогда
				ДанныеРедактораДляСборки.ИменаПредустановленныхПеременных = ИменаПредустановленныхПеременных[КлючЗначение.Ключ];
			КонецЕсли;
		КонецЕсли;

		НужнаСборка	= Истина;

		КэшСборкиОбработкиРедактора = КлючЗначение.Значение.КэшРезультатовПодключенияОбработкиИсполнения; //см. УИ_РедакторКодаКлиентСервер.НовыйКэшРезультатовПодключенияОбработкиИсполнения
		Если КэшСборкиОбработкиРедактора <> Неопределено Тогда
			ВсеПеременныеЕстьВСобраннойОбработке = Истина;
			
			Для Каждого Стр Из ДанныеРедактораДляСборки.ИменаПредустановленныхПеременных Цикл
				Если КэшСборкиОбработкиРедактора.ИменаПредустановленныхПеременных.Найти(НРег(Стр)) = Неопределено Тогда
					ВсеПеременныеЕстьВСобраннойОбработке = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;

			НужнаСборка = ДанныеРедактораДляСборки.ИсполнениеНаКлиенте <> КэшСборкиОбработкиРедактора.ИсполнениеНаКлиенте
						  Или ДанныеРедактораДляСборки.ТекстРедактора <> КэшСборкиОбработкиРедактора.ТекстРедактора
						  Или Не ВсеПеременныеЕстьВСобраннойОбработке;
		КонецЕсли;

		Если Не НужнаСборка Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(ДанныеРедактораДляСборки.ТекстРедактора) Тогда
			Продолжить;
		КонецЕсли;
		
		РедакторыДляСборки.Добавить(ДанныеРедактораДляСборки);

	КонецЦикла;
	
	Если РедакторыДляСборки.Количество() = 0 Тогда
		ВыполнитьОбработкуОповещения(ОписаниеОповещенияОЗавершении, Истина);
		Возврат;
	КонецЕсли;

	ПараметрыСборкиОбработок = НовыйПараметрыСборкиОбработокДляРедакторов();
	ПараметрыСборкиОбработок.Форма = Форма;
	ПараметрыСборкиОбработок.РедакторыДляСборки = УИ_РедакторКодаВызовСервера.РедакторыДляСборкиСПреобразованнымТекстомМодуля(РедакторыДляСборки);
	ПараметрыСборкиОбработок.ОписаниеОповещенияОЗавершении = ОписаниеОповещенияОЗавершении;
	ПараметрыСборкиОбработок.КаталогШаблонаОбработки = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(УИ_ОбщегоНазначенияКлиент.КаталогВспомогательныхБиблиотекИнструментов(),
																									  "ШаблонОбработки");

	НачатьСохранениеШаблонаОбработкиНаДиск(ПараметрыСборкиОбработок.КаталогШаблонаОбработки,
										   Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаЗавершениеСохраненияШаблонаОбработки",
		ЭтотОбъект, ПараметрыСборкиОбработок));

КонецПроцедуры

#КонецОбласти

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
	
	Событие = Неопределено;

	If EditorType = EditorTypes.Monaco Then
		Событие = HTMLEditorFieldOnClickMonaco(Form, Item, EventData, StandardProcessing);
	ИначеЕсли ВидРедактора = ВидыРедактора.Ace Тогда 
		Событие = СобытиеДляОбработкиПриНажатииAce(Форма, Элемент, ДанныеСобытия)		
	EndIf;

	Если Событие = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Форма.УИ_РедакторКодаКлиентскиеДанные.События.Добавить(Событие);

	Форма.ПодключитьОбработчикОжидания("Подключаемый_РедакторКодаОтложеннаяОбработкаСобытийРедактора", 0.1, Истина);

	
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
			Или ТекущееСобытие.ИмяСобытия = "ACE_EVENT_CONTENT_CHANGED" Then
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
		ИначеЕсли ТекущееСобытие.ИмяСобытия = "EVENT_GET_DEFINITION" Тогда
			Если ЗначениеЗаполнено(ТекущееСобытие.ДанныеСобытия.Модуль) Тогда
				ИмяМодуля = "module." + ТекущееСобытие.ДанныеСобытия.Модуль;

				ОткрытыеФормыПросмотраОпределений = УИ_ОбщегоНазначенияКлиент.ФормыПоКлючуУникальности(ВРег(ТекущееСобытие.ДанныеСобытия.Модуль),
																									   "ОбщаяФорма.УИ_ФормаКода");
				Если ОткрытыеФормыПросмотраОпределений.Количество() > 0 Тогда
					ФормаКода = ОткрытыеФормыПросмотраОпределений[0];
					ПерейтиКОпределениюМетодаРедактора(ФормаКода, "Код", ТекущееСобытие.ДанныеСобытия.Слово);
					ФормаКода.Активизировать();
				Иначе

					РедакторыФормы = ДополнительныеПараметры.Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];
					ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма,
																											   ТекущееСобытие.Элемент);
					ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];

					ПараметрыОповещения = Новый Структура;
					ПараметрыОповещения.Вставить("ИдентификаторРедактора", ИдентификаторРедактора);
					ПараметрыОповещения.Вставить("Форма", Форма);
					ПараметрыОповещения.Вставить("ТекущееСобытие", ТекущееСобытие);

					НачатьПолучениеТекстаМодуляИзИсходныхФайлов(ИмяМодуля,
																ПараметрыРедактора.ПараметрыРедактора.КаталогиИсходныхФайлов,
																Новый ОписаниеОповещения("ОткрытьОпределениеПроцедурыМодуляЗавершениеПолученияТекстаМодуля",
						ЭтотОбъект, ПараметрыОповещения));
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли ТекущееСобытие.ИмяСобытия = "TOOLS_UI_1C_COPY_TO_CLIPBOARD" Тогда
			ВыделенныйТекст = ВыделенныйТекстРедактораЭлементаФормы(Форма, ТекущееСобытие.Элемент);
			УИ_БуферОбменаКлиент.НачатьКопированиеСтрокиВБуфер(ВыделенныйТекст,
															   Новый ОписаниеОповещения("НачатьКопированиеВыделенногоТекстаВБуферОбменаЗавершение",
				ЭтотОбъект, ДополнительныеПараметры));
		ИначеЕсли ТекущееСобытие.ИмяСобытия = "TOOLS_UI_1C_PASTE_FROM_CLIPBOARD" Тогда
			УИ_БуферОбменаКлиент.НачатьПолучениеСтрокиИзБуфера(Новый ОписаниеОповещения("НачатьВставкуИзБуферОбменаЗавершениеПолученияТекста",
				ЭтотОбъект, ДополнительныеПараметры));
		ИначеЕсли ТекущееСобытие.ИмяСобытия = "COLABORATOR_READY" Тогда 
			НачатьСессиюВзаимодействияРедактораКодаЭлементаФормы(Форма, ТекущееСобытие.Элемент);
		EndIf;
		
	EndDo;

	Form.UT_CodeEditorClientData.Events.Clear();
EndProcedure

// Выполнить команду редактора кода.
// 
// Параметры:
//  Форма -ФормаКлиентскогоПриложения-Форма
//  Команда -КомандаФормы-Команда
Процедура ВыполнитьКомандуРедактораКода(Форма, Команда) Экспорт
	СтруктураКоманды = УИ_РедакторКодаКлиентСервер.СтруктураИмениКомандыФормы(Команда.Имя);

	РедакторыФормы =  УИ_РедакторКодаКлиентСервер.РедакторыФормы(Форма);
	ПараметрыРедактора = РедакторыФормы[СтруктураКоманды.ИдентификаторРедактора];
	
	Если СтруктураКоманды.ИмяКоманды = УИ_РедакторКодаКлиентСервер.ИмяКомандыРежимВыполненияЧерезОбработку() Тогда
		ПараметрыРедактора.ИспользоватьОбработкуДляВыполненияКода = Не ПараметрыРедактора.ИспользоватьОбработкуДляВыполненияКода;
		Форма.Элементы[Команда.Имя].Пометка = ПараметрыРедактора.ИспользоватьОбработкуДляВыполненияКода;
	ИначеЕсли СтруктураКоманды.ИмяКоманды = УИ_РедакторКодаКлиентСервер.ИмяКомандыПоделитьсяАлгоритмом() Тогда
		ТекстАлгоритма = ТекстКодаРедактора(Форма, СтруктураКоманды.ИдентификаторРедактора);
		ЭтоЗапрос = ПараметрыРедактора.Язык = "bsl_query";

		ПоделитьсяКодом(ТекстАлгоритма, ЭтоЗапрос, Форма);
	ИначеЕсли СтруктураКоманды.ИмяКоманды = УИ_РедакторКодаКлиентСервер.ИмяКомандыЗагрузитьАлгоритм() Тогда
		ПараметрыОповещения = Новый Структура;
		ПараметрыОповещения.Вставить("Форма", Форма);
		ПараметрыОповещения.Вставить("ИдентификаторРедактора", СтруктураКоманды.ИдентификаторРедактора);

		НачатьЗагрузкуКодаИзСервиса(Новый ОписаниеОповещения("НачатьЗагрузкуКодаИзСервисаЗавершение", ЭтотОбъект,
			ПараметрыОповещения));
	ИначеЕсли СтруктураКоманды.ИмяКоманды = УИ_РедакторКодаКлиентСервер.ИмяКомандыКонструкторЗапроса() Тогда
	ИначеЕсли СтруктураКоманды.ИмяКоманды = УИ_РедакторКодаКлиентСервер.ИмяКомандыНачатьСессиюВзаимодействия() Тогда
		 НачатьСессиюВзаимодействияСЗапросомПараметровРедактораКода(Форма, СтруктураКоманды.ИдентификаторРедактора);
	ИначеЕсли СтруктураКоманды.ИмяКоманды = УИ_РедакторКодаКлиентСервер.ИмяКомандыЗакончитьСессиюВзаимодействия() Тогда
		 ЗавершитьСессиюВзаимодействияРедактораКода(Форма, СтруктураКоманды.ИдентификаторРедактора);
	КонецЕсли;
КонецПроцедуры

#EndRegion

Function AllFormEditorsInitialized(FormEditors)
	Result = True;
	For Each KeyValue In FormEditors Do
		If Not KeyValue.Value.Initialized 
			And KeyValue.Value.Visible Then
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
 			ДокументView.editor.setAutoScrollEditorIntoView(Истина);
			ДокументView.editor.resize();
			
			ТекЯзык=НРег(ПараметрыРедактора.Язык);
			Если ТекЯзык = "bsl" Тогда
				ТекЯзык="_1c";
			КонецЕсли;
			
			ДокументView.appTo1C.setMode(ТекЯзык);
			
			Если ЗначениеЗаполнено(ПараметрыРедактора.СобытияРедактора.ПриИзменении) Тогда
				ДокументView.appTo1C.setGenerateModificationEvent(Истина);
			КонецЕсли;
						
		ElsIf EditorType = EditorTypes.Monaco Then
			DocumentView = EditorFormItem.Document.defaultView;

			ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco = ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco(ДокументView);

			Info = New SystemInfo;
			DocumentView.init(Info.AppVersion);
			If EditorSettings.EditorLanguage <> "bsl" Then
				DocumentView.setLanguageMode(EditorSettings.EditorLanguage);

				If EditorSettings.EditorLanguage = "bsl_query" Then
					DocumentView.setOption("renderQueryDelimiters", True);
					
					ДобавитьПунктМеню(ДокументView,
									  ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco,
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
			DocumentView.setOption("disableDefinitionMessage", Истина);
//			DocumentView.setOption("generateSnippetEvent", True);
			DocumentView.setOption("autoResizeEditorLayout", True);
			
			
			DocumentView.setOption("dragAndDrop", True);

			EditorThemes = UT_CodeEditorClientServer.MonacoEditorThemeVariants();
			If EditorSettings.EditorSettings.Theme = EditorThemes.Dark Then
				If EditorSettings.EditorLanguage = "bsl_query" Then
					DocumentView.setTheme("bsl-dark-query");
				Else
					DocumentView.setTheme("bsl-dark");
				EndIf;
			Else
				If EditorSettings.EditorLanguage = "bsl_query" Then
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
						
			Если ПараметрыРедактора.ПараметрыРедактора.ИспользоватьКомандыРаботыСБуферомВКонтекстномМеню Тогда
				ДобавитьПунктМеню(ДокументView,
								  ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco,
								  "TOOLS_UI_1C_COPY_TO_CLIPBOARD",
								  "Копировать");
				ДобавитьПунктМеню(ДокументView,
								  ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco,
								  "TOOLS_UI_1C_PASTE_FROM_CLIPBOARD",
								  "Вставить");
			КонецЕсли;
			
			DocumentView.clearMetadata();

			ConfigurationDescriptionForInitialization = MetadataDescriptionForMonacoEditorInitialization();

			DocumentView.updateMetadata(UT_CommonClientServer.mWriteJSON(
				GetMetadataObjectsListFromCollectionForMonacoEditor(
				ConfigurationDescriptionForInitialization.CommonModules)), "commonModules.items");
				
			If Not EditorSettings.EditorSettings.Monaco.UseStandartCodeTemplates Then
				DocumentView.clearSnippets();
			EndIf;
		EndIf;
	
		If EditorSettings.EditorTextCache <> Undefined Then
			SetEditorText(Form, KeyValue.Key, EditorSettings.EditorTextCache.Text);
			SetEditorOriginalText(Form, KeyValue.Key, EditorSettings.EditorTextCache.OriginalText);
			EditorSettings.EditorTextCache = Undefined;
		EndIf;
		
		Если ПараметрыРедактора.ТолькоПросмотр Тогда
			УстановитьРежимТолькоПросмотрРедактора(Форма, КлючЗначение.Ключ, Истина);
		КонецЕсли;		
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
			And EditorSettings.EditorTextCache <> Undefined Then
				
			Return EditorSettings.EditorTextCache.Text;
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
			And EditorParameters.EditorTextCache <> Undefined Then
				
			Return EditorParameters.EditorTextCache.OriginalText;
		EndIf;
	
		Return "";
	Endif;
	
	If EditorType = EditorsTypes.Monaco Then
		HTMLDocument=Form.Элементы[EditorParameters.EditorField].Document.defaultView;
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

	If EditorType = EditorsTypes.Текст Then
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

	If EditorType = EditorsTypes.Текст Then
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
		EditorTextCache = UT_CodeEditorClientServer.NewTextCacheOfEditor();
		EditorTextCache.Text = EditorCodeText(Form, EditorID);
		EditorTextCache.OriginalText = CodeEditorOriginalText(Form, EditorID);
		
		EditorSettings.EditorTextCache = EditorTextCache;
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
// Параметры:
//  Форма - ФормаКлиентскогоПриложения-
//  ИдентификаторРедактора - Строка - Идентификатор редактора
// 
// Возвращаемое значение:
// Булево 
Функция РежимТолькоПросмотрРедактора(Форма, ИдентификаторРедактора) Экспорт
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	РедакторыФормы = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];

	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	Если Не ПараметрыРедактора.Инициализирован Тогда
		Если Не ПараметрыРедактора.Видимость Тогда
				
			Возврат ПараметрыРедактора.ТолькоПросмотр;
		КонецЕсли;
	
		Возврат Ложь;
	КонецЕсли;
	
	Если ВидРедактора = ВидыРедакторов.Monaco Тогда
		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
		Возврат ДокументHTML.getReadOnly();
	ИначеЕсли ВидРедактора = ВидыРедакторов.Ace Тогда
		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
		Возврат ДокументHTML.editor.getOption("readOnly");
	Иначе 
		Возврат Форма.Элементы[ПараметрыРедактора.ПолеРедактора].ТолькоПросмотр;
	КонецЕсли;
	
	
КонецФункции

// Получить режим только просмотр редактора.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения-
//  Элемент - ПолеФормы -
// 
// Возвращаемое значение:
// Булево 
Функция РежимТолькоПросмотрРедактораЭлементаФормы(Форма, Элемент) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат РежимТолькоПросмотрРедактора(Форма, ИдентификаторРедактора);
КонецФункции

// Установить режим только просмотр редактора.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  ИдентификаторРедактора - Строка - Идентификатор редактора
//  Режим - Булево -
Процедура УстановитьРежимТолькоПросмотрРедактора(Форма, ИдентификаторРедактора, Режим) Экспорт
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	РедакторыФормы = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];

	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	ПараметрыРедактора.ТолькоПросмотр = Режим;
	
	Если Не ПараметрыРедактора.Инициализирован Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ПараметрыРедактора.Видимость Тогда
		Возврат;
	КонецЕсли;
	
	Если ВидРедактора = ВидыРедакторов.Monaco Тогда
		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
		ДокументHTML.setReadOnly(Режим);
	ИначеЕсли ВидРедактора = ВидыРедакторов.Ace Тогда
		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
		ДокументHTML.editor.setOption("readOnly", Режим);
	Иначе 
		Форма.Элементы[ПараметрыРедактора.ПолеРедактора].ТолькоПросмотр = Режим;
	КонецЕсли;
	
КонецПроцедуры

// Установить режим только просмотр редактора элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы
//  Режим - Булево -
Процедура УстановитьРежимТолькоПросмотрРедактораЭлементаФормы(Форма, Элемент, Режим) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	УстановитьРежимТолькоПросмотрРедактора(Форма, ИдентификаторРедактора, Режим);
КонецПроцедуры

// Перейти к определению метода редактора.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  ИдентификаторРедактора - Строка - Идентификатор редактора
//  ИмяМетода - Строка -Имя метода
Процедура ПерейтиКОпределениюМетодаРедактора(Форма, ИдентификаторРедактора, ИмяМетода) Экспорт
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	РедакторыФормы = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];

	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	
	Если Не ПараметрыРедактора.Инициализирован Или Не ПараметрыРедактора.Видимость Тогда
		Возврат;
	КонецЕсли;

	Если ВидРедактора = ВидыРедакторов.Monaco Тогда
		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
		ДокументHTML.goToFuncDefinition(ИмяМетода);
		
//	ИначеЕсли ВидРедактора = ВидыРедакторов.Ace Тогда
//		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
//		ДокументHTML.editor.setOption("readOnly", Режим);
	КонецЕсли;
	
	
КонецПроцедуры

// Перейти к определению метода редактора элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы
//  ИмяМетода - Строка -Имя метода
Процедура ПерейтиКОпределениюМетодаРедактораЭлементаФормы(Форма, Элемент, ИмяМетода) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ПерейтиКОпределениюМетодаРедактора(Форма, ИдентификаторРедактора, ИмяМетода);
	
КонецПроцедуры

// Режим использования обработки для выполнения кода редактора.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  ИдентификаторРедактора - Строка - Идентификатор редактора
// 
// Возвращаемое значение:
//  Булево
Функция РежимИспользованияОбработкиДляВыполненияКодаРедактора(Форма, ИдентификаторРедактора) Экспорт
	РедакторыФормы = УИ_РедакторКодаКлиентСервер.РедакторыФормы(Форма);
	
	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	
	Возврат ПараметрыРедактора.ИспользоватьОбработкуДляВыполненияКода;
КонецФункции

// Режим использования обработки для выполнения кода редактора.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы
// 
// Возвращаемое значение:
//  Булево
Функция РежимИспользованияОбработкиДляВыполненияКодаРедактораЭлементаФормы(Форма, Элемент) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат РежимИспользованияОбработкиДляВыполненияКодаРедактора(Форма, ИдентификаторРедактора);
КонецФункции

// Установить режим использования обработки для выполнения кода редактора.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  ИдентификаторРедактора - Строка - Идентификатор редактора
//  Режим - Булево -
Процедура УстановитьРежимИспользованияОбработкиДляВыполненияКодаРедактора(Форма, ИдентификаторРедактора, Режим) Экспорт
	РедакторыФормы = УИ_РедакторКодаКлиентСервер.РедакторыФормы(Форма);
	
	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	ПараметрыРедактора.ИспользоватьОбработкуДляВыполненияКода = Режим;

	ИмяКнопки = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыРежимВыполненияЧерезОбработку(),
																			  ИдентификаторРедактора);
																			  
	Форма.Элементы[ИмяКнопки].Пометка = Режим;

КонецПроцедуры

// Установить режим использования обработки для выполнения кода редактора элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы
//  Режим - Булево -
Процедура УстановитьРежимИспользованияОбработкиДляВыполненияКодаРедактораЭлементаФормы(Форма, Элемент, Режим) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	УстановитьРежимИспользованияОбработкиДляВыполненияКодаРедактора(Форма, ИдентификаторРедактора, Режим);
КонецПроцедуры

// Начать сессию взаимодействия редактора кода.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения- Форма
//  ИдентификаторРедактора -Строка -Идентификатор редактора
Процедура НачатьСессиюВзаимодействияРедактораКода(Форма, ИдентификаторРедактора) Экспорт
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	Если ВидРедактора = ВидыРедакторов.Текст Тогда
		Возврат;
	КонецЕсли;
	
	РедакторыФормы = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];
	Если Не ВсеРедакторыФормыИнициализированы(РедакторыФормы) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора]; //см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы
	Если Не ПараметрыРедактора.Инициализирован Тогда
		Возврат;
	КонецЕсли;
	
	Если ВидРедактора <> ВидыРедакторов.Ace Тогда
		ВозвраТ;
	КонецЕсли;

	ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
	
	Если Не КПолюHTMLРедактораПодключенСкриптВзаимодействия(ДокументHTML) Тогда
		ПодключитьКПолюHTMLСкриптВзаимодействия(Форма, ПараметрыРедактора, ДокументHTML);	
		Возврат;			
	КонецЕсли;
	
	ПараметрыСессии = ПараметрыРедактора.ПараметрыСессииВзаимодействия;
	Если ПараметрыСессии = Неопределено Тогда
		ПараметрыСессии = УИ_РедакторКодаКлиентСервер.НовыйПараметрыСессииВзаимодействия();
		ПараметрыРедактора.ПараметрыСессииВзаимодействия = ПараметрыСессии;
	КонецЕсли;

	Если Не ЗначениеЗаполнено(ПараметрыСессии.Идентификатор) Тогда
		ПараметрыСессии.Идентификатор = Формат(ТекущаяУниверсальнаяДатаВМиллисекундах(), "ЧГ=0;")
										+ Форма.УникальныйИдентификатор;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСессии.ИмяПользователя) Тогда
		ДокументHTML.colaborator.setUserName(ПараметрыСессии.ИмяПользователя);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСессии.URLВзаимодействия) Тогда
		ДокументHTML.colaborator.setColaborationUrl(ПараметрыСессии.URLВзаимодействия);
	КонецЕсли;

	Если ВидРедактора = ВидыРедакторов.Ace Тогда
		ДокументHTML.colaborator.start(ПараметрыСессии.Идентификатор);
	ИначеЕсли ВидРедактора = ВидыРедакторов.Monaco Тогда
//		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
//		ДокументHTML.updateText(Текст);
//		Если УстанавливатьОригинальныйТекст Тогда
//			ДокументHTML.setOriginalText(Текст);
//		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Начать сессию взаимодействия редактора кода элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы - Элемент формы редактора
Процедура НачатьСессиюВзаимодействияРедактораКодаЭлементаФормы(Форма, Элемент) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	НачатьСессиюВзаимодействияРедактораКода(Форма, ИдентификаторРедактора);
КонецПроцедуры

// Завершить сессию взаимодействия редактора кода.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  ИдентификаторРедактора -Строка -Идентификатор редактора
Процедура ЗавершитьСессиюВзаимодействияРедактораКода(Форма, ИдентификаторРедактора) Экспорт
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	Если ВидРедактора = ВидыРедакторов.Текст Тогда
		Возврат;
	КонецЕсли;
	
	РедакторыФормы = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];
	Если Не ВсеРедакторыФормыИнициализированы(РедакторыФормы) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	Если Не ПараметрыРедактора.Инициализирован Тогда
		Возврат;
	КонецЕсли;
	
	Если ВидРедактора <> ВидыРедакторов.Ace Тогда
		ВозвраТ;
	КонецЕсли;

	ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
	
	Если Не КПолюHTMLРедактораПодключенСкриптВзаимодействия(ДокументHTML) Тогда
		Возврат;			
	КонецЕсли;

	Если ВидРедактора = ВидыРедакторов.Ace Тогда
		ДокументHTML.colaborator.close();
	ИначеЕсли ВидРедактора = ВидыРедакторов.Monaco Тогда
//		ДокументHTML=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;
//		ДокументHTML.updateText(Текст);
//		Если УстанавливатьОригинальныйТекст Тогда
//			ДокументHTML.setOriginalText(Текст);
//		КонецЕсли;
	КонецЕсли;
	
	
КонецПроцедуры

// Завершить сессию взаимодействия редактора кода элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы - Элемент формы редактора
Процедура ЗавершитьСессиюВзаимодействияРедактораКодаЭлементаФормы(Форма, Элемент) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ЗавершитьСессиюВзаимодействияРедактораКода(Форма, ИдентификаторРедактора);
	
КонецПроцедуры

// Установить язык редактора кода.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  ИдентификаторРедактора -Строка-Идентификатор редактора
//  Язык -Строка -Язык
Процедура УстановитьЯзыкРедактораКода(Форма, ИдентификаторРедактора, Язык) Экспорт
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	Если ВидРедактора = ВидыРедакторов.Текст Тогда
		Возврат;
	КонецЕсли;
	
	РедакторыФормы = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];
	Если Не ВсеРедакторыФормыИнициализированы(РедакторыФормы) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыРедактора = РедакторыФормы[ИдентификаторРедактора];
	Если Не ПараметрыРедактора.Инициализирован Тогда
		Возврат;
	КонецЕсли;
	
	Если ВидРедактора <> ВидыРедакторов.Ace Тогда
		ВозвраТ;
	КонецЕсли;

	ДокументView=Форма.Элементы[ПараметрыРедактора.ПолеРедактора].Документ.defaultView;

	ПараметрыРедактора.Язык = Язык;
	Если ВидРедактора = ВидыРедакторов.Ace Тогда
		ТекЯзык = Язык;
		Если ТекЯзык = "bsl" Тогда
			ТекЯзык="_1c";
		КонецЕсли;
		
		ДокументView.appTo1C.setMode(ТекЯзык);
	ИначеЕсли ВидРедактора = ВидыРедакторов.Monaco Тогда
		ДокументView.setLanguageMode(Язык);
	КонецЕсли;
	
КонецПроцедуры

// Установить язык редактора кода элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы - Элемент формы редактора
//  Язык - Строка
Процедура УстановитьЯзыкРедактораКодаЭлементаФормы(Форма, Элемент, Язык) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	УстановитьЯзыкРедактораКода(Форма, ИдентификаторРедактора, Язык);
КонецПроцедуры

#EndRegion

// Преобразовать текст запроса из выражения встроенного языка редактора кода.
// 
// Параметры:
//  Форма -ФормаКлиентскогоПриложения-Форма
//  ИдентификаторРедактора -Строка-Идентификатор редактора
Процедура ПреобразоватьТекстЗапросаИзВыраженияВстроенногоЯзыкаРедактораКода(Форма, ИдентификаторРедактора) Экспорт
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("Форма", Форма);
	ПараметрыОповещения.Вставить("ИдентификаторРедактора", ИдентификаторРедактора);
	
	ТекстРедактора = ТекстКодаРедактора(Форма, ИдентификаторРедактора);
	
	НезначащиеСимволы = Новый Массив;
	НезначащиеСимволы.Добавить(" ");
	НезначащиеСимволы.Добавить(Символы.НПП);
	НезначащиеСимволы.Добавить(Символы.Таб);
	НезначащиеСимволы.Добавить("|");

	ТекстовыйДокументРедактора = Новый ТекстовыйДокумент();
	ТекстовыйДокументРедактора.УстановитьТекст(ТекстРедактора);

	НашлиНачало = Ложь;
	НомерПоследнейЗначащейСтроки = 0;
	Для НомерСтроки =1 По ТекстовыйДокументРедактора.КоличествоСтрок() Цикл
		ТекСтрокаКода = ТекстовыйДокументРедактора.ПолучитьСтроку(НомерСтроки);
		
		Для Каждого ТекСимвол Из НезначащиеСимволы Цикл
			Пока СтрНачинаетсяС(ТекСтрокаКода, ТекСимвол) Цикл
				ТекСтрокаКода = Сред(ТекСтрокаКода,2);				
			КонецЦикла;
		КонецЦикла;

		Если НашлиНачало Тогда
			ТекСтрокаКода = СтрЗаменить(ТекСтрокаКода, """""", """");
		КонецЕсли;

		Если СтрНачинаетсяС(ТекСтрокаКода, """") Тогда
			ТекСтрокаКода = Сред(ТекСтрокаКода, 2);
		КонецЕсли;

		ТекстовыйДокументРедактора.ЗаменитьСтроку(НомерСтроки,ТекСтрокаКода);	
		Если Не ЗначениеЗаполнено(ТекСтрокаКода) И Не НашлиНачало Тогда
			Продолжить;
		КонецЕсли;
		
		НашлиНачало = Истина;

		Если ЗначениеЗаполнено(ТекСтрокаКода) Тогда
			НомерПоследнейЗначащейСтроки = НомерСтроки;
		КонецЕсли;
	КонецЦикла;
	
	Если НомерПоследнейЗначащейСтроки > 0 Тогда
		ТекСтрокаКода = ТекстовыйДокументРедактора.ПолучитьСтроку(НомерПоследнейЗначащейСтроки);
		Если СтрЗаканчиваетсяНа(ТекСтрокаКода, """;") Тогда
			ТекСтрокаКода = Лев(ТекСтрокаКода, СтрДлина(ТекСтрокаКода) - 2);
		ИначеЕсли СтрЗаканчиваетсяНа(ТекСтрокаКода, """") Или СтрЗаканчиваетсяНа(ТекСтрокаКода, ";") Тогда
			ТекСтрокаКода = Лев(ТекСтрокаКода, СтрДлина(ТекСтрокаКода) - 1);
		КонецЕсли;
		
		ТекстовыйДокументРедактора.ЗаменитьСтроку(НомерПоследнейЗначащейСтроки,ТекСтрокаКода);	
			
	КонецЕсли;
	
	УстановитьТекстРедактора(Форма, ИдентификаторРедактора, ТекстовыйДокументРедактора.ПолучитьТекст());
КонецПроцедуры

// Преобразовать текст запроса из выражения встроенного языка редактора кода.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы - Элемент формы редактора
Процедура ПреобразоватьТекстЗапросаИзВыраженияВстроенногоЯзыкаРедактораЭлементаФормы(Форма, Элемент) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ПреобразоватьТекстЗапросаИзВыраженияВстроенногоЯзыкаРедактораКода(Форма, ИдентификаторРедактора);

КонецПроцедуры

// Начать сессию взаимодействия с запросом параметров.
// 
// Параметры:
//  Форма -ФормаКлиентскогоПриложения-Форма
//  ИдентификаторРедактора -Строка-Идентификатор редактора
Процедура НачатьСессиюВзаимодействияСЗапросомПараметровРедактораКода(Форма, ИдентификаторРедактора) Экспорт
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("Форма", Форма);
	ПараметрыОповещения.Вставить("ИдентификаторРедактора", ИдентификаторРедактора);

	ПараметрыФормы = Новый Структура;

	ОткрытьФорму("ОбщаяФорма.УИ_ПараметрыСессииВзаимодействияРедактораКода",
				 ПараметрыФормы,
				 Форма,
				 "" + Форма.УникальныйИдентификатор + ИдентификаторРедактора,
				 ,
				 ,
				 Новый ОписаниеОповещения("НачатьСессиюВзаимодействияСЗапросомПараметровРедактораКодаЗавершениеВводаПараметров",
		ЭтотОбъект, ПараметрыОповещения),
				 РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры

// Начать сессию взаимодействия с запросом параметров редактора элемента формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -
//  Элемент - ПолеФормы - Элемент формы редактора
Процедура НачатьСессиюВзаимодействияСЗапросомПараметровРедактораЭлементаФормы(Форма, Элемент) Экспорт
	ИдентификаторРедактора = УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент);
	Если ИдентификаторРедактора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	НачатьСессиюВзаимодействияСЗапросомПараметровРедактораКода(Форма, ИдентификаторРедактора);
	
КонецПроцедуры

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
// Параметры:
//  Код -Строка-Код
//  ЭтоЗапрос -Булево-Это запрос
//  ВладелецФормы - ФормаКлиентскогоПриложения -
Процедура ПоделитьсяКодом(Код, ЭтоЗапрос, ВладелецФормы = Неопределено) Экспорт
	СсылкаНаКод = УИ_РедакторКодаВызовСервера.СсылкаНаКодВСервисеПослеЗагрузки(Код, ЭтоЗапрос);
	Если Не ЗначениеЗаполнено(СсылкаНаКод) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ссылка", СсылкаНаКод);
	ОткрытьФорму("ОбщаяФорма.УИ_ФормаСсылкиНаКод",
				 ПараметрыФормы,
				 ВладелецФормы,
				 ,
				 ,
				 ,
				 ,
				 РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

// Начать загрузку кода из сервиса.
// 
// Параметры:
//  ОписаниеОповещения - ОписаниеОповещения -  Описание оповещения
Процедура НачатьЗагрузкуКодаИзСервиса(ОписаниеОповещения, ВладелецФормы = Неопределено) Экспорт
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("ОповещениеОЗавершении", ОписаниеОповещения);

	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("РежимВставки", Истина);
	
	ОткрытьФорму("ОбщаяФорма.УИ_ФормаСсылкиНаКод",
				 ПараметрыФормы,
				 ВладелецФормы,
				 ,
				 ,
				 ,
				 Новый ОписаниеОповещения("НачатьЗагрузкуКодаИзСервисаЗавершениеВводаСсылки", ЭтотОбъект,
		ПараметрыОповещения),
				 РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры


#EndRegion

#Region Internal


// Начать сессию взаимодействия с запросом параметров редактора кода завершение ввода параметров.
// 
// Параметры:
//  Результат - см. УИ_РедакторКодаКлиентСервер.НовыйПараметрыСессииВзаимодействия
//  ДополнительныеПараметры - Структура :
//  	* Форма - ФормаКлиентскогоПриложения
//  	* ИдентификаторРедактора - Строка
Процедура НачатьСессиюВзаимодействияСЗапросомПараметровРедактораКодаЗавершениеВводаПараметров(Результат,
	ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	РедакторыФормы = ДополнительныеПараметры.Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];
	ПараметрыРедактора = РедакторыФормы[ДополнительныеПараметры.ИдентификаторРедактора]; //см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы
	
	ПараметрыРедактора.ПараметрыСессииВзаимодействия = Результат;
	

	НачатьСессиюВзаимодействияРедактораКода(ДополнительныеПараметры.Форма,
											ДополнительныеПараметры.ИдентификаторРедактора);
КонецПроцедуры

// Начать вставку из буфер обмена завершение получения текста.
// 
// Параметры:
//  Результат - Строка - Результат
//  ДополнительныеПараметры - Структура -Дополнительные параметры:
//  	* Форма - ФормаКлиентскогоПриложения
//  	* Элемент - ПолеФормы
Процедура НачатьВставкуИзБуферОбменаЗавершениеПолученияТекста(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВставитьТекстПоПозицииКурсораЭлементаФормы(ДополнительныеПараметры.Форма, ДополнительныеПараметры.Элемент, Результат);
КонецПроцедуры

Процедура НачатьКопированиеВыделенногоТекстаВБуферОбменаЗавершение(Результат, ПараметрыВызова, ДополнительныеПараметры) Экспорт

КонецПроцедуры

// Начать загрузку кода из сервиса завершение ввода ссылки.
// 
// Параметры:
//  Результат - Строка, Неопределено- Результат
//  ДополнительныеПараметры - Структура - Дополнительные параметры:
//  	* ОповещениеОЗавершении - ОписаниеОповещения -
Процедура НачатьЗагрузкуКодаИзСервисаЗавершениеВводаСсылки(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеСсылки = УИ_РедакторКодаВызовСервера.ДанныеАлгоритмаВСервисе(Результат);
	
	Если ДанныеСсылки = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОповещениеОЗавершении, ДанныеСсылки);
КонецПроцедуры

// Начать загрузку кода из сервиса завершение.
// 
// Параметры:
//  Результат - см. УИ_Paste1CAPI.НовыйДанныеАлгоритма
//  ДополнительныеПараметры - Структура -Дополнительные параметры:
//  	* Форма - ФормаКлиентскогоПриложения
//  	* ИдентификаторРедактора - Строка
Процедура НачатьЗагрузкуКодаИзСервисаЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	УстановитьТекстРедактора(ДополнительныеПараметры.Форма,
							 ДополнительныеПараметры.ИдентификаторРедактора,
							 Результат.Текст);
КонецПроцедуры

// Начать сборку обработок для исполнения кода завершение сохранения шаблона обработки.
// 
// Параметры:
//  Успешно - Булево- Результат
//  ДополнительныеПараметры - см. НовыйПараметрыСборкиОбработокДляРедакторов
Процедура НачатьСборкуОбработокДляИсполненияКодаЗавершениеСохраненияШаблонаОбработки(Успешно,
	ДополнительныеПараметры) Экспорт
	
	Если Не Успешно Тогда
		Возврат;
	КонецЕсли;
	
	УИ_УправлениеКонфигураторомКлиент.НачатьПолучениеКонтекстаКомандыКонфигуратора(Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаЗавершениеПолученияКонтекстаРедактора",
		ЭтотОбъект, ДополнительныеПараметры));


КонецПроцедуры

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора.
// 
// Параметры:
//  ПараметрыСборкиОбработок - см. НовыйПараметрыСборкиОбработокДляРедакторов
//  ОписаниеОповещенияОЗавершении -ОписаниеОповещения -Описание оповещения о завершении
Процедура НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактора(ПараметрыСборкиОбработок,
	ОписаниеОповещенияОЗавершении) Экспорт

	РедакторДляСборки = ПараметрыСборкиОбработок.РедакторыДляСборки[ПараметрыСборкиОбработок.ИндексРедактораДляСборки];

	ИмяФайлаМодуля = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ПараметрыСборкиОбработок.КаталогШаблонаОбработки,
																	"ШаблонОбработки",
																	"Ext",
																	"ObjectModule.bsl");
	
	//Текст модуля
	Текст = Новый ТекстовыйДокумент;
	Если РедакторДляСборки.ИсполнениеНаКлиенте Тогда
		Текст.УстановитьТекст("");
	Иначе
		Текст.УстановитьТекст(РедакторДляСборки.ТекстРедактораДляОбработки);
	КонецЕсли;
	
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("ПараметрыСборкиОбработок", ПараметрыСборкиОбработок);
	ПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	ПараметрыОповещения.Вставить("РедакторДляСборки", РедакторДляСборки);

	Текст.НачатьЗапись(Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеЗаписиМодуляОбработки",
		ЭтотОбъект, ПараметрыОповещения), ИмяФайлаМодуля, "UTF8");
КонецПроцедуры

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение записи модуля обработки.
// 
// Параметры:
//  Результат - Булево, Неопределено -Результат
//  ДополнительныеПараметры - Структура- Дополнительные параметры:
//  	* ПараметрыСборкиОбработок - см. НовыйПараметрыСборкиОбработокДляРедакторов
//  	* ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  	* РедакторДляСборки - см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораДляСборкиОбработки
Процедура НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеЗаписиМодуляОбработки(Результат,
	ДополнительныеПараметры) Экспорт

	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;

	ИмяФайлаМодуля = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ПараметрыСборкиОбработок.КаталогШаблонаОбработки,
																												   "ШаблонОбработки",
																												   "Forms",
																												   "Форма"),
																	"Ext", "Form", "Module.bsl");
	
	//Текст формы
	Текст = Новый ТекстовыйДокумент;
	Если ДополнительныеПараметры.РедакторДляСборки.ИсполнениеНаКлиенте Тогда
		Текст.УстановитьТекст(ДополнительныеПараметры.РедакторДляСборки.ТекстРедактораДляОбработки);
	Иначе
		Текст.УстановитьТекст("");
	КонецЕсли;
	Текст.НачатьЗапись(Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеЗаписиМодуляФормы",
		ЭтотОбъект, ДополнительныеПараметры), ИмяФайлаМодуля, "UTF8");
	
КонецПроцедуры

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение записи модуля обработки.
// 
// Параметры:
//  Результат - Булево, Неопределено -Результат
//  ДополнительныеПараметры - Структура- Дополнительные параметры:
//  	* ПараметрыСборкиОбработок - см. НовыйПараметрыСборкиОбработокДляРедакторов
//  	* ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  	* РедакторДляСборки - см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораДляСборкиОбработки
Процедура НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеЗаписиМодуляФормы(Результат,
	ДополнительныеПараметры) Экспорт

	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;

	ИмяФайлаОбработки = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ПараметрыСборкиОбработок.КаталогШаблонаОбработки,
																	   "ОбработкаДляРедактора.epf");
	ИмяИсходногоФайлаОбработки = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ПараметрыСборкиОбработок.КаталогШаблонаОбработки,
																				"ШаблонОбработки.xml");
	ДополнительныеПараметры.Вставить("ИмяФайлаОбработки", ИмяФайлаОбработки);

	УИ_УправлениеКонфигураторомКлиент.НачатьСборкуОбработкиИзФайлов(ДополнительныеПараметры.ПараметрыСборкиОбработок.КонтекстКомандыКонфигуратора,
																	ИмяИсходногоФайлаОбработки,
																	ИмяФайлаОбработки,
																	Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеФормированияФайлаОбработки",
		ЭтотОбъект, ДополнительныеПараметры));

КонецПроцедуры

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение формирования файла обработки.
// 
// Параметры:
//  Результат - Булево -Результат
//  ДополнительныеПараметры - Структура- Дополнительные параметры:
//  	* ПараметрыСборкиОбработок - см. НовыйПараметрыСборкиОбработокДляРедакторов
//  	* ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  	* РедакторДляСборки - см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораДляСборкиОбработки
//  	* ИмяФайлаОбработки - Строка
Процедура НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеФормированияФайлаОбработки(Результат,
	ДополнительныеПараметры) Экспорт
	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;

	НачатьСозданиеДвоичныхДанныхИзФайла(Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеПолученияДвоичныхДанныхОбработки",
		ЭтотОбъект, ДополнительныеПараметры), ДополнительныеПараметры.ИмяФайлаОбработки);
КонецПроцедуры

// Начать сборку обработок для исполнения кода сборка обработки для очередного редактора завершение получения двоичных данных обработки.
// 
// Параметры:
//  ДвоичныеДанные - ДвоичныеДанные- Результат
//  ДополнительныеПараметры - Структура- Дополнительные параметры:
//  	* ПараметрыСборкиОбработок - см. НовыйПараметрыСборкиОбработокДляРедакторов
//  	* ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  	* РедакторДляСборки - см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораДляСборкиОбработки
//  	* ИмяФайлаОбработки - Строка
Процедура НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактораЗавершениеПолученияДвоичныхДанныхОбработки(ДвоичныеДанные,
	ДополнительныеПараметры) Экспорт

	АдресДвоичныхДанныхВоВременномХранилище = ПоместитьВоВременноеХранилище(ДвоичныеДанные,
																			ДополнительныеПараметры.ПараметрыСборкиОбработок.Форма.УникальныйИдентификатор);
	УИ_ОбщегоНазначенияВызовСервера.ПодключитьВнешнююОбработкуКСеансу(АдресДвоичныхДанныхВоВременномХранилище,
																	  ДополнительныеПараметры.РедакторДляСборки.ИмяПодключаемойОбработки);
																	  
		
	РедакторыФормы = УИ_РедакторКодаКлиентСервер.РедакторыФормы(ДополнительныеПараметры.ПараметрыСборкиОбработок.Форма);
	ПараметрыРедактора = РедакторыФормы[ДополнительныеПараметры.РедакторДляСборки.Идентификатор]; //см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы

	КэшРезультатовПодключенияОбработкиИсполнения = УИ_РедакторКодаКлиентСервер.НовыйКэшРезультатовПодключенияОбработкиИсполнения();
	КэшРезультатовПодключенияОбработкиИсполнения.ТекстРедактора = ДополнительныеПараметры.РедакторДляСборки.ТекстРедактора;
	КэшРезультатовПодключенияОбработкиИсполнения.ИсполнениеНаКлиенте = ДополнительныеПараметры.РедакторДляСборки.ИсполнениеНаКлиенте;

	Для Каждого Стр Из ДополнительныеПараметры.РедакторДляСборки.ИменаПредустановленныхПеременных Цикл
		КэшРезультатовПодключенияОбработкиИсполнения.ИменаПредустановленныхПеременных.Добавить(НРег(Стр));
	КонецЦикла;
	ПараметрыРедактора.КэшРезультатовПодключенияОбработкиИсполнения = КэшРезультатовПодключенияОбработкиИсполнения;

	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);
КонецПроцедуры

// Начать сборку обработок для исполнения кода завершение сборки обработки для очередного редактора.
// 
// Параметры:
//  Результат -Булево-Результат
//  ДополнительныеПараметры - см. НовыйПараметрыСборкиОбработокДляРедакторов
Процедура НачатьСборкуОбработокДляИсполненияКодаЗавершениеСборкиОбработкиДляОчередногоРедактора(Результат,
	ДополнительныеПараметры) Экспорт
	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры.ИндексРедактораДляСборки = ДополнительныеПараметры.ИндексРедактораДляСборки + 1;
	Если ДополнительныеПараметры.ИндексРедактораДляСборки >= ДополнительныеПараметры.РедакторыДляСборки.Количество() Тогда
		ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);
	Иначе
		НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактора(ДополнительныеПараметры,
																					Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаЗавершениеСборкиОбработкиДляОчередногоРедактора",
			ЭтотОбъект, ДополнительныеПараметры));
	КонецЕсли;
		
КонецПроцедуры

// Начать сохранение шаблона обработки на диск завершение обеспечения каталога.
// 
// Параметры:
//  Успешно - Булево - Успешно
//  ДополнительныеПараметры - Структура:
//  	* ОписаниеОповещенияОЗавершении-ОписаниеОповещения
//  	* Каталог - Строка
Процедура НачатьСохранениеШаблонаОбработкиНаДискЗавершениеОбеспеченияКаталога(Успешно, ДополнительныеПараметры) Экспорт
	Если Не Успешно Тогда
		Возврат;
	КонецЕсли;

	Файл = Новый Файл(УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.Каталог,
																	 "ШаблонОбработки.xml"));
	Файл.НачатьПроверкуСуществования(Новый ОписаниеОповещения("НачатьСохранениеШаблонаОбработкиНаДискЗавершениеПроверкиСуществованияСохраненногоШаблона",
		ЭтотОбъект, ДополнительныеПараметры));
КонецПроцедуры

// Начать сохранение шаблона обработки на диск завершение проверки существования сохраненного шаблона.
// 
// Параметры:
//  Существует - Булево - Существует
//  ДополнительныеПараметры - Структура:
//  	* ОписаниеОповещенияОЗавершении-ОписаниеОповещения
//  	* Каталог - Строка
Процедура НачатьСохранениеШаблонаОбработкиНаДискЗавершениеПроверкиСуществованияСохраненногоШаблона(Существует,
	ДополнительныеПараметры) Экспорт
	Если Существует Тогда
		ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);
	Иначе
		АдресШаблонаОбработкиДляСохранения = УИ_ОбщегоНазначенияВызовСервера.АдресДвоичныхДанныхОбщегоМакета("УИ_ШаблонОбработки");

		ИмяФайлаАрхива = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.Каталог, "шаблон.zip");
		ДополнительныеПараметры.Вставить("ИмяФайлаАрхива", ИмяФайлаАрхива);

		Двоичные = ПолучитьИзВременногоХранилища(АдресШаблонаОбработкиДляСохранения); //ДвоичныеДанные
		Двоичные.НачатьЗапись(Новый ОписаниеОповещения("НачатьСохранениеШаблонаОбработкиНаДискЗавершениеСохраненияАрхиваШаблона",
			ЭтотОбъект, ДополнительныеПараметры), ИмяФайлаАрхива);
	КонецЕсли;
КонецПроцедуры

// Начать сохранение шаблона обработки на диск завершение сохранения архива шаблона.
// 
// Параметры:
//  ДополнительныеПараметры - Структура:
//  	* ОписаниеОповещенияОЗавершении-ОписаниеОповещения
//  	* Каталог - Строка
//  	* ИмяФайлаАрхива - Строка
Процедура НачатьСохранениеШаблонаОбработкиНаДискЗавершениеСохраненияАрхиваШаблона(ДополнительныеПараметры) Экспорт
#Если Не ВебКлиент И Не МобильныйКлиент Тогда
	ЧтениеZIP = Новый ЧтениеZipФайла(ДополнительныеПараметры.ИмяФайлаАрхива);
	ЧтениеZIP.ИзвлечьВсе(ДополнительныеПараметры.Каталог, РежимВосстановленияПутейФайловZIP.Восстанавливать);
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);
#Иначе
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Ложь);
#КонецЕсли

КонецПроцедуры


// Начать сборку обработок для исполнения кода завершение получения контекста редактора.
// 
// Параметры:
//  КонтекстКонфигуратора - см. УИ_УправлениеКонфигураторомКлиент.НовыйКонтекстКомандыКонфигуратора, Неопределено -Контекст конфигуратора
//  ПараметрыСборки - см. НовыйПараметрыСборкиОбработокДляРедакторов - Параметры сборки
Процедура НачатьСборкуОбработокДляИсполненияКодаЗавершениеПолученияКонтекстаРедактора(КонтекстКонфигуратора,
	ПараметрыСборки) Экспорт

	Если КонтекстКонфигуратора = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ПараметрыСборки.КонтекстКомандыКонфигуратора = КонтекстКонфигуратора;
	НачатьСборкуОбработокДляИсполненияКодаСборкаОбработкиДляОчередногоРедактора(ПараметрыСборки,
																				Новый ОписаниеОповещения("НачатьСборкуОбработокДляИсполненияКодаЗавершениеСборкиОбработкиДляОчередногоРедактора",
		ЭтотОбъект, ПараметрыСборки));
КонецПроцедуры

Процедура ОткрытьОпределениеПроцедурыМодуляЗавершениеПолученияТекстаМодуля(ТекстМодуля, ДополнительныеПараметры) Экспорт
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Код", ТекстМодуля);
	ПараметрыФормы.Вставить("ИмяМодуля", ДополнительныеПараметры.ТекущееСобытие.ДанныеСобытия.Модуль);
	ПараметрыФормы.Вставить("ИмяМетодаДляПереходаКОпределению",
							ДополнительныеПараметры.ТекущееСобытие.ДанныеСобытия.Слово);

	ОткрытьФорму("ОбщаяФорма.УИ_ФормаКода",
				 ПараметрыФормы,
				 ,
				 ВРег(ДополнительныеПараметры.ТекущееСобытие.ДанныеСобытия.Модуль));
КонецПроцедуры

Procedure FormOnOpenEndAttachFileSystemExtension(Result, AdditionalParameters) Export
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(ДополнительныеПараметры.Форма);
	ДанныеБиблиотекРедакторов =  ДополнительныеПараметры.Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаДанныеБиблиотекРедакторов()];
	
	ДанныеБиблиотеки = ДанныеБиблиотекРедакторов[ВидРедактора];
	Если ДанныеБиблиотеки = Неопределено
		 Или Не ЗначениеЗаполнено(ДанныеБиблиотеки)
		 Или ТипЗнч(ДанныеБиблиотеки) = Тип("Структура") Тогда
		ФормаПриОткрытииЗавершениеСохраненияБиблиотекиРедактора(Истина, ДополнительныеПараметры);
	Иначе
		СохранитьБиблиотекуРедактораНаДиск(ДанныеБиблиотеки,
										   ВидРедактора,
										   Новый ОписаниеОповещения("ФормаПриОткрытииЗавершениеСохраненияБиблиотекиРедактора",
			ЭтотОбъект, ДополнительныеПараметры));
	КонецЕсли;
EndProcedure

Procedure FormOnOpenEndEditorLibrarySaving(Result, AdditionalParameters) Export
	Form = AdditionalParameters.Form;
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);
	EditorsTypes = UT_CodeEditorClientServer.CodeEditorVariants();

	If UT_CodeEditorClientServer.CodeEditorUsesHTMLField(EditorType) Then
		For Each KeyValue In Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()] Do
			//EditorAttributeName = UT_CodeEditorClientServer.AttributeNameCodeEditor(KeyValue.Value.AttributeName);	

			If EditorType = EditorsTypes.Monaco Then
				Form[KeyValue.Value.AttributeName] = EditorSaveDirectory(EditorType) 
				+ GetPathSeparator() + "index.html";
			ElsIf EditorType = EditorsTypes.Ace Then
				Form[KeyValue.Value.AttributeName] = AceEditorFileNameForLanguage(KeyValue.Value.EditorLanguage);
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
	
	МассивСохраненныхФайлов = Новый Массив;
	СоответствиеФайловБиблиотеки=ПолучитьИзВременногоХранилища(АдресБиблиотеки);

	ДополнительныеПараметры.Вставить("МассивСохраненныхФайлов", МассивСохраненныхФайлов);
	ДополнительныеПараметры.Вставить("СоответствиеФайловБиблиотеки", СоответствиеФайловБиблиотеки);

	SaveEditorLibraryWriteBeginWritingNextFile(AdditionalParameters);
EndProcedure

Procedure SaveEditorLibraryUnpackEditorLibraryToDirectory(AdditionalParameters, 
	NotifyDescriptionOnCompletion) Export
#If Not WebClient And Not MobileClient Then
	Stream=AdditionalParameters.LibraryFilesMap[AdditionalParameters.CurrentFileKey].OpenStreamForRead();

	ZipReader=New ZipFileReader(Stream);
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

// Начать поиск файла модуля каталогах исходных файлов завершение поиска файлов.
// 
// Параметры:
//  НайденныеФайлы -Массив Из Файл -Найденные файлы
//  ПараметрыПоиска - Структура - Параметры поиска:
// 		* ОповещениеОЗавершении - ОписаниеОповещения -
// 		* КаталогиИсходников - Массив из см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
// 		* ИндексКаталогаИсходников - Число -
// 		* ИмяМодуля - Строка -
// 		* МассивИменМодуля - Массив из Строка -
// 		* КаталогМодуля - Строка -
// 		* ИмяФайла - Строка -
// 		* ЭтоОбщийМодуль - Булево -
// 		* ИмяКаталогаПоискаФайла - Строка -
// 		* ОписаниеОповещениеЗавершенияПоискаФайла - ОписаниеОповещения -
Процедура НачатьПоискФайлаМодуляКаталогахИсходныхФайловЗавершениеПоискаФайлов(НайденныеФайлы, ПараметрыПоиска) Экспорт
	Если НайденныеФайлы = Неопределено Тогда
		ПараметрыПоиска.ИндексКаталогаИсходников = ПараметрыПоиска.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляКаталогахИсходныхФайлов(ПараметрыПоиска,
													  ПараметрыПоиска.ОписаниеОповещениеЗавершенияПоискаФайла);
		Возврат;
	КонецЕсли;

	Если НайденныеФайлы.Количество() = 0 Тогда
		ПараметрыПоиска.ИндексКаталогаИсходников = ПараметрыПоиска.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляКаталогахИсходныхФайлов(ПараметрыПоиска,
													  ПараметрыПоиска.ОписаниеОповещениеЗавершенияПоискаФайла);
		Возврат;
	КонецЕсли;

	ИмяФайла = НайденныеФайлы[0].ПолноеИмя;
	ВыполнитьОбработкуОповещения(ПараметрыПоиска.ОписаниеОповещениеЗавершенияПоискаФайла, ИмяФайла);
	
КонецПроцедуры

// Начать получение текста модуля из исходных файлов завершение поиска файлов.
// 
// Параметры:
//  ИмяФайла -Строка-Имя файла
//  ДополнительныеПараметры - Структура - Параметры поиска:
// 		* ОповещениеОЗавершении - ОписаниеОповещения -
// 		* КаталогиИсходников - Массив из см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
// 		* ИндексКаталогаИсходников - Число -
// 		* ИмяМодуля - Строка -
// 		* МассивИменМодуля - Массив из Строка -
// 		* КаталогМодуля - Строка -
// 		* ИмяФайла - Строка -
// 		* ЭтоОбщийМодуль - Булево -
// 		* ИмяКаталогаПоискаФайла - Строка -
// 		* ОписаниеОповещениеЗавершенияПоискаФайла - ОписаниеОповещения -
Процедура НачатьПолучениеТекстаМодуляИзИсходныхФайловЗавершениеПоискаФайлов(ИмяФайла, ДополнительныеПараметры) Экспорт
	ТекстовыйДокумент = Новый ТекстовыйДокумент;

	ДополнительныеПараметры.Вставить("ТекстовыйДокумент", ТекстовыйДокумент);
	ТекстовыйДокумент.НачатьЧтение(Новый ОписаниеОповещения("НачатьПолучениеТекстаМодуляИзИсходныхФайловЗавершениеЧтениеТекстаМодуляИзФайла",
		ЭтотОбъект, ДополнительныеПараметры), ИмяФайла, "UTF8");

КонецПроцедуры

// Начать получение текста модуля из исходных файлов завершение чтение текста модуля из файла.
// 
// Параметры:
//  ДополнительныеПараметры -Структура -Дополнительные параметры:
//  	* ТекстовыйДокумент - ТекстовыйДокумент
//  	* ОповещениеОЗавершении - ОписаниеОповещения
Процедура НачатьПолучениеТекстаМодуляИзИсходныхФайловЗавершениеЧтениеТекстаМодуляИзФайла(ДополнительныеПараметры) Экспорт
	ТекстМодуля = ДополнительныеПараметры.ТекстовыйДокумент.ПолучитьТекст();
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОповещениеОЗавершении, ТекстМодуля);
КонецПроцедуры

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

Процедура НачатьСохранениеШаблонаОбработкиНаДиск(Каталог, ОписаниеОповещенияОЗавершении)
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	ПараметрыОповещения.Вставить("Каталог", Каталог);

	УИ_ОбщегоНазначенияКлиент.НачатьОбеспечениеКаталога(Каталог,
														Новый ОписаниеОповещения("НачатьСохранениеШаблонаОбработкиНаДискЗавершениеОбеспеченияКаталога",
		ЭтотОбъект, ПараметрыОповещения));
КонецПроцедуры


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

	Если ГраницыВыделения = Неопределено Тогда
		НачалоСтроки = 1;
		КонецСтроки = Текст.КоличествоСтрок();
	Иначе
			
		If Not ValueIsFilled(SelectionBorders.RowBeginning) And Not ValueIsFilled(SelectionBorders.RowEnd) Then
			Return;
		EndIf;
		НачалоСтроки = ГраницыВыделения.НачалоСтроки;
		КонецСтроки = ГраницыВыделения.КонецСтроки;
				
	КонецЕсли;

	For LineNumber = SelectionBorders.RowBeginning To SelectionBorders.RowEnd Do
		TextLine = Text.GetLine(LineNumber);
		Text.ReplaceLine(LineNumber, Addition + TextLine);
	EndDo;
	CodeText = Text.GetText();
EndProcedure

Procedure DeleteTextAdditionInLineBeginningBySelectionBorders(CodeText, SelectionBorders, Addition)
	Text = New TextDocument;
	Text.SetText(CodeText);
	
	Если ГраницыВыделения = Неопределено Тогда
		НачалоСтроки = 1;
		КонецСтроки = Текст.КоличествоСтрок();
	Иначе

		If Not ValueIsFilled(SelectionBorders.RowBeginning) And Not ValueIsFilled(SelectionBorders.RowEnd) Then
			Return;
		EndIf;
		НачалоСтроки = ГраницыВыделения.НачалоСтроки;
		КонецСтроки = ГраницыВыделения.КонецСтроки;

	КонецЕсли;
	
	For LineNumber = SelectionBorders.RowBeginning To SelectionBorders.RowEnd Do
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
		AddingObjects.Insert(KeyValue.Ключ, AddedObject);
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
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -Форма
//  Элемент - ПолеФормы-Элемент
//  ДанныеСобытия  -ФиксированнаяСтруктура- Данные события
// 
// Возвращаемое значение:
//  см. НовыйСобытиеРедактораКодаДляОбработки
// Возвращаемое значение:
//  Неопределено - Событие не требует обработки
Функция HTMLEditorFieldOnClickMonaco(Form, Item, EventData, StandardProcessing)
	Event = EventData.Event.eventData1C;

	If Event = Undefined Then
		Return Неопределено;
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
		DataOfEventForProcessing.Вставить("Слово", Событие.params.word);
		DataOfEventForProcessing.Вставить("ПолноеВыражение", Событие.params.expression);
		DataOfEventForProcessing.Вставить("Модуль", Событие.params.module);
		DataOfEventForProcessing.Вставить("ИмяОбъекта", Событие.params.class);
		DataOfEventForProcessing.Вставить("НомерСтроки", Событие.params.line);
		DataOfEventForProcessing.Вставить("НомерКолонки", Событие.params.column);
		//DataOfEventForProcessing.Вставить("МассивВыражения", Событие.params.expression_array);
			
	Endif;	
	
	EventForProcessing.EventData = DataOfEventForProcessing;
	
	Возврат EventForProcessing;
КонецФункции

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

// Начать получение текста модуля из исходных файлов.
// 
// Параметры:
//  ИмяМодуля - Строка - Имя модуля. module.УИ_ОбщегоНазначения, module.manager.документы.авансовыйотчет, module.object.документы.авансовыйотчет
//  КаталогиИсходныхФайлов -Массив из см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
//  ОписаниеОповещенияОЗавершении -ОписаниеОповещения -Описание оповещения о завершении
Процедура НачатьПолучениеТекстаМодуляИзИсходныхФайлов(ИмяМодуля, КаталогиИсходныхФайлов, ОписаниеОповещенияОЗавершении)
	Если КаталогиИсходныхФайлов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	МассивИменМодуля = СтрРазделить(ИмяМодуля, ".");

	Если МассивИменМодуля.Количество() < 2 Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("ОповещениеОЗавершении", ОписаниеОповещенияОЗавершении);
	ПараметрыПоиска.Вставить("КаталогиИсходников", КаталогиИсходныхФайлов);
	ПараметрыПоиска.Вставить("ИндексКаталогаИсходников", 0);
	ПараметрыПоиска.Вставить("ИмяМодуля", ИмяМодуля);
	ПараметрыПоиска.Вставить("МассивИменМодуля", МассивИменМодуля);
	
	ВидМодуля = МассивИменМодуля[1];

	Если ВидМодуля = "manager" Тогда
		ПараметрыПоиска.Вставить("ОписаниеОбъектаМетаданных",
								 УИ_РедакторКодаВызовСервера.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(МассивИменМодуля[2],
																										  МассивИменМодуля[3]));
		ПараметрыПоиска.Вставить("КаталогМодуля", ИмяКаталогаВидаМетаданных(МассивИменМодуля[2]));
		ПараметрыПоиска.Вставить("ИмяФайла", "ManagerModule.bsl");

		ПараметрыПоиска.Вставить("ЭтоОбщийМодуль", Ложь);

	ИначеЕсли ВидМодуля = "object" Тогда
		ПараметрыПоиска.Вставить("ОписаниеОбъектаМетаданных",
								 УИ_РедакторКодаВызовСервера.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(МассивИменМодуля[2],
																										  МассивИменМодуля[3]));
		ПараметрыПоиска.Вставить("КаталогМодуля", ИмяКаталогаВидаМетаданных(МассивИменМодуля[2]));
		ПараметрыПоиска.Вставить("ИмяФайла", "ObjectModule.bsl");

		ПараметрыПоиска.Вставить("ЭтоОбщийМодуль", Ложь);
	Иначе
		ПараметрыПоиска.Вставить("ОписаниеОбъектаМетаданных",
								 УИ_РедакторКодаВызовСервера.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени("ОбщиеМодули",
																										  МассивИменМодуля[1]));
		ПараметрыПоиска.Вставить("КаталогМодуля", "CommonModules");
		ПараметрыПоиска.Вставить("ИмяФайла", "Module.bsl");

		ПараметрыПоиска.Вставить("ЭтоОбщийМодуль", Истина);
	КонецЕсли;

	НачатьПоискФайлаМодуляКаталогахИсходныхФайлов(ПараметрыПоиска,
												  Новый ОписаниеОповещения("НачатьПолучениеТекстаМодуляИзИсходныхФайловЗавершениеПоискаФайлов",
		ЭтотОбъект, ПараметрыПоиска));
КонецПроцедуры

// Начать поиск файла модуля каталогах исходных файлов.
// 
// Параметры:
//  ПараметрыПоиска - Структура - Параметры поиска:
// 		* ОповещениеОЗавершении - ОписаниеОповещения -
// 		* КаталогиИсходников - Массив из см. УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации -
// 		* ИндексКаталогаИсходников - Число -
// 		* ИмяМодуля - Строка -
// 		* МассивИменМодуля - Массив из Строка -
// 		* КаталогМодуля - Строка -
// 		* ИмяФайла - Строка -
// 		* ЭтоОбщийМодуль - Булево -
//  ОписаниеОповещенияОЗавершении - ОписаниеОповещения - Описание оповещения о завершении
Procedure StartSearchOfModuleFileInSourceFilesDirectory(ПараметрыПоиска, ОписаниеОповещенияОЗавершении)
	Если ПараметрыПоиска.КаталогиИсходников.Количество() <= ПараметрыПоиска.ИндексКаталогаИсходников Тогда
		Возврат;
	КонецЕсли;
	
	КаталогИсходныхФайлов = ПараметрыПоиска.КаталогиИсходников[ПараметрыПоиска.ИндексКаталогаИсходников].Каталог;

	Если Не ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		ПараметрыПоиска.ИндексКаталогаИсходников = ПараметрыПоиска.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляКаталогахИсходныхФайлов(ПараметрыПоиска, ОписаниеОповещенияОЗавершении);
		Возврат;
	КонецЕсли;

	ИмяКаталогаПоискаФайла = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогИсходныхФайлов,
																			ПараметрыПоиска.КаталогМодуля,
																			ПараметрыПоиска.ОписаниеОбъектаМетаданных.Имя);
	ПараметрыПоиска.Вставить("ИмяКаталогаПоискаФайла", ИмяКаталогаПоискаФайла);
	ПараметрыПоиска.Вставить("ОписаниеОповещениеЗавершенияПоискаФайла", ОписаниеОповещенияОЗавершении);

	BeginFindingFiles(New NotifyDescription("SetModuleDescriptionForMonacoEditorOnEndModuleFilesSeacrh", 
	ThisObject, ПараметрыПоиска), ИмяКаталогаПоискаФайла, ПараметрыПоиска.ModuleFileName, True);

EndProcedure

Процедура НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(ДополнительныеПараметры)
	Если ДополнительныеПараметры.КаталогиИсходников.Количество() <= ДополнительныеПараметры.ИндексКаталогаИсходников Тогда
		Возврат;
	КонецЕсли;
	КаталогИсходныхФайлов = ДополнительныеПараметры.КаталогиИсходников[ДополнительныеПараметры.ИндексКаталогаИсходников].Каталог;

	Если Не ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		ДополнительныеПараметры.ИндексКаталогаИсходников = ДополнительныеПараметры.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(ДополнительныеПараметры);
		Возврат;
	КонецЕсли;

	ИмяКаталогаПоискаФайла = КаталогИсходныхФайлов + ПолучитьРазделительПути() + ДополнительныеПараметры.КаталогМодуля
		+ ПолучитьРазделительПути() + ДополнительныеПараметры.ОписаниеОбъектаМетаданных.Имя;
	ДополнительныеПараметры.Вставить("ИмяКаталогаПоискаФайла", ИмяКаталогаПоискаФайла);

	НачатьПоискФайлов(Новый ОписаниеОповещения("УстановитьОписаниеМодуляДляРедактораMonacoЗавершениеПоискаФайловМодуля",
		ЭтотОбъект, ДополнительныеПараметры), ИмяКаталогаПоискаФайла, ДополнительныеПараметры.ИмяФайлаМодуля, Истина);

КонецПроцедуры

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

	StartSearchOfModuleFileInSourceFilesDirectory(AdditionalParameters);
EndProcedure
Procedure SetModuleDescriptionForMonacoEditorOnEndModuleFilesSeacrh(FoundFiles, 
AdditionalParameters) Export
	If FoundFiles = Undefined Then
		AdditionalParameters.SourcesDirectoryIndex = AdditionalParameters.SourcesDirectoryIndex + 1;
		StartSearchOfModuleFileInSourceFilesDirectory(AdditionalParameters);
		Return;
	EndIf;

	If FoundFiles.Count() = 0 Then
		AdditionalParameters.SourcesDirectoryIndex = AdditionalParameters.SourcesDirectoryIndex + 1;
		StartSearchOfModuleFileInSourceFilesDirectory(AdditionalParameters);
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

// Вид объекта метаданных по виду метаданных от редактора monaco.
// 
// Параметры:
//  ВидМетаданныхMonaco -Строка - Вид метаданных monaco
// 
// Возвращаемое значение:
//  Строка
Функция ВидОбъектаМетаданныхПоВидуМетаданныхОтРедактораMonaco(ВидМетаданныхMonaco)
	Если НРег(ВидМетаданныхMonaco) = "inforegs" Тогда
		Возврат "informationregisters";
	ИначеЕсли НРег(ВидМетаданныхMonaco) = "accumregs" Тогда
		Возврат "accumulationregisters";
	ИначеЕсли НРег(ВидМетаданныхMonaco) = "accountregs" Тогда
		Возврат "accountingregisters";
	ИначеЕсли НРег(ВидМетаданныхMonaco) = "calcregs" Тогда
		Возврат "calculationregisters";
	ИначеЕсли НРег(ВидМетаданныхMonaco) = "dataproc" Тогда
		Возврат "dataprocessors";
	Иначе
		Возврат ВидМетаданныхMonaco;
	КонецЕсли;
КонецФункции

Function MapOfMonacoEditorUpdatedMetadataObjectsAndMetadataUpdateEventParameters()
	Map = New Structure;
	Map.Insert("справочники", "catalogs.items");
	Map.Insert("catalogs", "catalogs.items");
	Map.Insert("документы", "documents.items");
	Map.Insert("documents", "documents.items");
	Map.Insert("регистрысведений", "infoRegs.items");
	Map.Insert("informationregisters", "infoRegs.items");
	Соответствие.Вставить("infoRegs", "infoRegs.items");
	Map.Insert("регистрынакопления", "accumRegs.items");
	Map.Insert("accumulationregisters", "accumRegs.items");
	Соответствие.Вставить("accumRegs", "accumRegs.items");	
	Map.Insert("регистрыбухгалтерии", "accountRegs.items");
	Map.Insert("accountingregisters", "accountRegs.items");
	Соответствие.Вставить("accountRegs", "accountRegs.items");
	Map.Insert("регистрырасчета", "calcRegs.items");
	Map.Insert("calculationregisters", "calcRegs.items");
	Соответствие.Вставить("calcRegs", "calcRegs.items");
	Map.Insert("обработки", "dataProc.items");
	Map.Insert("dataprocessors", "dataProc.items");
	Соответствие.Вставить("dataProc", "dataProc.items");
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

Функция ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco(ДокументView)
	КомандыРедактора = ДокументView.editor.getSupportedActions();
	Для Каждого ТекКоманда Из КомандыРедактора Цикл
		Если Не СтрЗаканчиваетсяНа(ТекКоманда.id, "_bsl") Тогда
			Продолжить;
		КонецЕсли;
		
		ЧастиИдентификатора = СтрРазделить(ТекКоманда.id, ":");  
		Идентификатор = ЧастиИдентификатора[ЧастиИдентификатора.Количество()-1];
		ЧастиИдентификатор = СтрРазделить(Идентификатор, ".");
		Если УИ_СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(ЧастиИдентификатор[0]) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
КонецФункции

#EndRegion

#Область ACE
// Событие для обработки при нажатии monaco.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения -Форма
//  Элемент - ПолеФормы-Элемент
//  ДанныеСобытия  -ФиксированнаяСтруктура- Данные события
// 
// Возвращаемое значение:
//  см. НовыйСобытиеРедактораКодаДляОбработки
// Возвращаемое значение:
//  Неопределено - Событие не требует обработки
Функция СобытиеДляОбработкиПриНажатииAce(Форма, Элемент, ДанныеСобытия)
	Событие = ДанныеСобытия.Event.eventData1C;

	Если Событие = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
//	СтандартнаяОбработка = Ложь;
		
	СобытиеДляОбработки = НовыйСобытиеРедактораКодаДляОбработки();
	СобытиеДляОбработки.Элемент = Элемент;
	СобытиеДляОбработки.ИмяСобытия = Событие.name;
	
	ДанныеСобытияДляОбработки = Неопределено;

	//Тут получение спец данных для события
	
	СобытиеДляОбработки.ДанныеСобытия = ДанныеСобытияДляОбработки;

	Возврат СобытиеДляОбработки;	
КонецФункции


#КонецОбласти

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
		
		KeyValue.Value.BeginWriting(CompletionNotify, FileName);
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

// Новый параметры сборки обработок для редакторов.
// 
// Возвращаемое значение:
//  Структура - Новый параметры сборки обработок для редакторов:
// * ОписаниеОповещенияОЗавершении - ОписаниеОповещения, Неопределено -
// * РедакторыДляСборки - Массив из см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораДляСборкиОбработки-
// * ИндексРедактораДляСборки - Число -
// * КаталогШаблонаОбработки - Строка -
// * Форма - ФормаКлиентскогоПриложения,Неопределено -
// * КонтекстКомандыКонфигуратора - см. УИ_УправлениеКонфигураторомКлиент.НовыйКонтекстКомандыКонфигуратора, Неопределено -
Функция НовыйПараметрыСборкиОбработокДляРедакторов()
	ПараметрыСборки = Новый Структура();
	ПараметрыСборки.Вставить("ОписаниеОповещенияОЗавершении", Неопределено);
	ПараметрыСборки.Вставить("РедакторыДляСборки", Новый Массив);
	ПараметрыСборки.Вставить("ИндексРедактораДляСборки", 0);
	ПараметрыСборки.Вставить("КаталогШаблонаОбработки", "");
	ПараметрыСборки.Вставить("КонтекстКомандыКонфигуратора", Неопределено);
	ПараметрыСборки.Вставить("Форма", Неопределено);
	
	Возврат ПараметрыСборки;
КонецФункции
	
// К полю HTMLРедактора подключен скрипт взаимодействия.
// 
// Параметры:
//  ДокументView -ВнешнийОбъект-Документ view
// 
// Возвращаемое значение:
//  Булево -  К полю HTMLРедактора подключен скрипт взаимодействия
Функция КПолюHTMLРедактораПодключенСкриптВзаимодействия(ДокументView) 
	Возврат ДокументView.colaborator <> Неопределено;
КонецФункции	
	
	
// Подключить к полю HTMLСкрипт взаимодействия.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  ПараметрыРедактора - см. УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы 
//  ДокументHTML - ВнешнийОбъект
Процедура ПодключитьКПолюHTMLСкриптВзаимодействия(Форма, ПараметрыРедактора, ДокументHTML)
	ВидыРедакторов = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	ВидРедактора = УИ_РедакторКодаКлиентСервер.ВидРедактораКодаФормы(Форма);

	ИмяМакетаБиблиотеки = "";
	Если ВидРедактора = ВидыРедакторов.Ace Тогда
		ИмяМакетаБиблиотеки = "УИ_AceColaborator";
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ИмяМакетаБиблиотеки) Тогда
		ВозвраТ;
	КонецЕсли;

	ДанныеБиблиотекРедакторов = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаДанныеБиблиотекРедакторов()];//Структура
	
	ИмяБиблиотекиВзаимодействияДляДанныхФормы = УИ_РедакторКодаКлиентСервер.ИмяБиблиотекиВзаимодействияДляДанныхФормы(ВидРедактора);
	
	Если ДанныеБиблиотекРедакторов.Свойство(ИмяБиблиотекиВзаимодействияДляДанныхФормы) Тогда
		ДанныеБиблитекиВзаимодейтсвия = ДанныеБиблиотекРедакторов[ИмяБиблиотекиВзаимодействияДляДанныхФормы];
	Иначе
		ДанныеБиблитекиВзаимодейтсвия = УИ_РедакторКодаВызовСервера.ДанныеБиблиотекиОбщегоМакета(ИмяМакетаБиблиотеки,
																								 Форма.УникальныйИдентификатор);
		ДанныеБиблиотекРедакторов.Вставить(ИмяБиблиотекиВзаимодействияДляДанныхФормы, ДанныеБиблитекиВзаимодейтсвия);
	КонецЕсли;
	
	ПодключитьБиблиотекуКДокументуПоляHTML(ДокументHTML, ДанныеБиблитекиВзаимодейтсвия);
КонецПроцедуры	
	
// Подключить библиотеку к документу поля HTML.
// 
// Параметры:
//  ДокументView - ВнешнийОбъект- Документ view
//  ДанныеБиблиотеки - см. УИ_РедакторКодаСервер.
Процедура ПодключитьБиблиотекуКДокументуПоляHTML(ДокументView, ДанныеБиблиотеки)
	Для Каждого ТекСкрипт Из ДанныеБиблиотеки.Скрипты Цикл
		Элемент = ДокументView.document.createElement("script");
		Элемент.type = "text/javascript";
		Элемент.src = ТекСкрипт;
		ДокументView.document.body.appendChild(Элемент);	
	КонецЦикла;
	
	Для Каждого ТекСкрипт Из ДанныеБиблиотеки.Стили Цикл
		Элемент = ДокументView.document.createElement("style");
		Элемент.innerHTML = ТекСкрипт;
		ДокументView.document.body.appendChild(Элемент);	
	КонецЦикла;
КонецПроцедуры	

// Добавляет пользовательский пункт меню в контекстное меню редактора
// 
// Параметры:
//  ДокументView - ВнешнийОбъект - 
//  ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco - Булево
//  Идентификатор - Строка - Идентификатор команды меню
//  Наименование - Строка - Наименование команды меню
Процедура ДобавитьПунктМеню(ДокументView, ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco, Идентификатор,
	Наименование)
	Если ЕстьДобавленныеКомандыКонтекстногоМенюРедактораMonaco Тогда
		Возврат;
	КонецЕсли;
	ДокументView.addContextMenuItem(Наименование, Идентификатор);
КонецПроцедуры



#EndRegion