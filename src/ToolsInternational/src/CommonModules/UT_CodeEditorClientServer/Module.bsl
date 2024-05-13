

#Region Public

// Новый данные библиотеки редактора.
// 
// Возвращаемое значение:
//  Структура -  Новый данные библиотеки редактора:
//  	* Скрипты - Массив из Строка - Массив адресов файлов библиотеки во временном хранилище
//  	* Стили - Массив из Строка- Массив адресов файлов библиотеки во временном хранилище
Функция NewDataLibraryEditor() Экспорт
	ДанныеБиблиотеки = New Structure;
	ДанныеБиблиотеки.Вставить("Скрипты", New Array);
	ДанныеБиблиотеки.Вставить("Стили", New Array);
	
	Возврат ДанныеБиблиотеки;
КонецФункции

// Имя подключаемой обработки для исполнения кода редактора.
// 
// Параметры:
//  Идентификатор -Строка- Идентификатор
// 
// Возвращаемое значение:
//  Строка
Функция ИмяПодключаемойОбработкиДляИсполненияКодаРедактора(Идентификатор) Экспорт
	Возврат "УИ_РедакторКода_ОбработкаИсполнения_"+Идентификатор;
КонецФункции

Function CodeEditorItemsPrefix() Export
	Return "CodeEditor1C";
EndFunction

Function AttributeNameCodeEditor(EditorID) Export
	Return CodeEditorItemsPrefix() + "_" + EditorID;
EndFunction

Function AttributeNameCodeEditorTypeOfEditor() Export
	Return CodeEditorItemsPrefix() + "_EditorType";
EndFunction

// Имя реквизита редактора кода библиотеки редакторов.
// 
// Возвращаемое значение:
//  Строка -  Имя реквизита редактора кода библиотеки редакторов
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

Функция ИмяКнопкиКоманднойПанели(ИмяКоманды, ИдентификаторРедактора) Экспорт
	Возврат ПрефиксЭлементовРедактораКода() + "_" + ИмяКоманды + "_" + ИдентификаторРедактора;
КонецФункции

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

// Редактор кода использует поле HTML.
// 
// Параметры:
//  ВидРедактора -Строка- Вид редактора
// 
// Возвращаемое значение:
//  Булево -  Редактор кода использует поле HTML
Function CodeEditorUsesHTMLField(EditorType) Export
	Variants=CodeEditorVariants();
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
//  InitializationPassed - Булево
Procedure SetFlagCodeEditorsInitialInitializationPassed(Form, InitializationPassed) Export
	Form[AttributeNameCodeEditorInitialInitializationPassed()] = InitializationPassed;
EndProcedure

Function EditorIDByFormItem(Form, Item) Export
	FormEditors = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	For Each KeyValue In FormEditors Do
		If KeyValue.Value.EditorField = Item.Name Then
			Return KeyValue.Key;
		EndIf;
	EndDo;

	Return Undefined;
EndFunction

Функция СтруктураИмениКомандыФормы(ИмяКоманды) Экспорт
	МассивИмени = СтрРазделить(ИмяКоманды, "_");

	СтруктураИмени = New Structure;
	СтруктураИмени.Вставить("ИмяКоманды", МассивИмени[1]);
	СтруктураИмени.Вставить("ИдентификаторРедактора", МассивИмени[2]);

	Возврат СтруктураИмени;
КонецФункции

Function ExecuteAlgorithm(__AlgorithmText__, __Context__, ИсполнениеНаКлиенте = Ложь, Форма = Неопределено,
	ИдентификаторРедактора = Неопределено) Export
	УИ__Успешно__ = Истина;
	УИ__ОписаниеОшибки__ = "";
	УИ__НачалоВыполнения__ = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Если ЗначениеЗаполнено(__ТекстАлготима__) Тогда
		ВыполнятьЧерезОбработку = Ложь;
		Если Форма <> Неопределено И ИдентификаторРедактора <> Неопределено Тогда
			РедакторыФормы = РедакторыФормы(Форма);
			ДанныеРедактора = РедакторыФормы[ИдентификаторРедактора];
			ВыполнятьЧерезОбработку = ДанныеРедактора.ИспользоватьОбработкуДляВыполненияКода;
		КонецЕсли;

		Если ВыполнятьЧерезОбработку Тогда
			Попытка
				Если ИсполнениеНаКлиенте Тогда
#Если НаКлиенте Тогда
					//@skip-check use-non-recommended-method
					ИсполнительОбработка = ПолучитьФорму("ВнешняяОбработка."
														 + ИмяПодключаемойОбработкиДляИсполненияКодаРедактора(ИдентификаторРедактора)
														 + ".Форма");
#КонецЕсли
				Иначе
#Если Не НаКлиенте Или ТолстыйКлиентОбычноеПриложение Или ТолстыйКлиентУправляемоеПриложение Тогда
					ИсполнительОбработка = ВнешниеОбработки.Создать(ИмяПодключаемойОбработкиДляИсполненияКодаРедактора(ИдентификаторРедактора));
#КонецЕсли
				КонецЕсли;
				ИсполнительОбработка.УИ_ИнициализироватьПеременные(__Контекст__);
				ИсполнительОбработка.УИ_ВыполнитьАлгоритм();

			Исключение
				УИ__Успешно__ = Ложь;
				УИ__ОписаниеОшибки__ = ОписаниеОшибки();
				Сообщить(УИ__ОписаниеОшибки__);
			КонецПопытки;
		Иначе
			ВыполняемыйТекстАлгоритма = ДополненныйКонтекстомКодАлгоритма(__ТекстАлготима__, __Контекст__);

			Попытка
				//@skip-check unsupported-operator
				Выполнить (ВыполняемыйТекстАлгоритма);
			Исключение
				УИ__Успешно__ = Ложь;
				УИ__ОписаниеОшибки__ = ОписаниеОшибки();
				Сообщить(УИ__ОписаниеОшибки__);
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;

	ОкончаниеВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();

	РезультатВыполнения = New Structure;
	РезультатВыполнения.Вставить("Успешно", УИ__Успешно__);
	РезультатВыполнения.Вставить("ВремяВыполнения", ОкончаниеВыполнения - УИ__НачалоВыполнения__);
	РезультатВыполнения.Вставить("ОписаниеОшибки", УИ__ОписаниеОшибки__);

	Возврат РезультатВыполнения;
EndFunction

Function FormCodeEditorType(Form) Export
	Return Form[UT_CodeEditorClientServer.AttributeNameCodeEditorTypeOfEditor()];
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

#Область ИменаКомандКоманднойПанели


// Имя команды режим выполнения через обработку.
// 
// Возвращаемое значение:
//  Строка -  Имя команды режим выполнения через обработку
Функция ИмяКомандыРежимВыполненияЧерезОбработку() Экспорт
	Возврат "РежимВыполненияЧерезОбработку";
КонецФункции

// Имя команды конструктор запроса.
// 
// Возвращаемое значение:
//  Строка -  Имя команды конструктор запроса
Функция ИмяКомандыКонструкторЗапроса() Экспорт
	Возврат "КонструкторЗапроса";
КонецФункции

// Имя команды поделиться алгоритмом.
// 
// Возвращаемое значение:
//  Строка -  Имя команды поделиться алгоритмом
Функция ИмяКомандыПоделитьсяАлгоритмом() Экспорт
	Возврат "ПоделитьсяАлгоритмом";
КонецФункции

// Имя команды загрузить алгоритм.
// 
// Возвращаемое значение:
//  Строка -  Имя команды загрузить алгоритм
Функция ИмяКомандыЗагрузитьАлгоритм() Экспорт
	Возврат "ЗагрузитьАлгоритм";
КонецФункции

// Имя команды начать сессию взаимодействия.
// 
// Возвращаемое значение:
//  Строка -  Имя команды начать сессию взаимодействия
Функция ИмяКомандыНачатьСессиюВзаимодействия() Экспорт
	Возврат "НачатьСессиюВзаимодействия";
КонецФункции

// Имя команды закончить сессию взаимодействия.
// 
// Возвращаемое значение:
//  Строка -  Имя команды закончить сессию взаимодействия
Функция ИмяКомандыЗакончитьСессиюВзаимодействия() Экспорт
	Возврат "ЗакончитьСессиюВзаимодействия";
КонецФункции


#КонецОбласти

// Имя библиотеки взаимодействия для данных формы.
// 
// Параметры:
//  ВидРедактора - Строка- Вид редактора
// 
// Возвращаемое значение:
//  Строка - Имя библиотеки взаимодействия для данных формы
Функция ИмяБиблиотекиВзаимодействияДляДанныхФормы(ВидРедактора) Экспорт
	Возврат "БиблиотекаВзаимодействия"+ВидРедактора;
КонецФункции

// Редакторы формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения-Форма
// 
// Возвращаемое значение:
//  Структура из КлючИЗначение:
//  	* Ключ - Строка - Идентификатор редактора
//  	* Значение - см. НовыйДанныеРедактораФормы
Функция РедакторыФормы(Форма) Экспорт
	Возврат Форма[ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];
КонецФункции

// Новый данные редактора формы.
// 
// Возвращаемое значение:
//  Структура - Новый данные редактора формы:
// * СобытияРедактора - см. NewEditorEventOptions
// * Инициализирован - Булево -
// * Видимость - Булево -
// * ТолькоПросмотр - Булево -
// * КэшТекстаРедактора - см. УИ_РедакторКодаКлиентСервер.НовыйКэшТекстовРедактора
// * Язык - Строка -
// * ПолеРедактора - Строка -
// * ИмяРеквизита - Строка -
// * ИмяКоманднойПанелиРедактора - Строка -
// * Идентификатор - Строка -
// * ИспользоватьОбработкуДляВыполненияКода - Булево -
// * ПараметрыРедактора - см. ПараметрыРедактораКодаПоУмолчанию
// * КэшРезультатовПодключенияОбработкиИсполнения -  см. НовыйКэшРезультатовИсполненияЧерезОбработку 
// * ПараметрыСессииВзаимодействия - см. НовыйПараметрыСессииВзаимодействия
Функция НовыйДанныеРедактораФормы() Экспорт
	ДанныеРедактора = New Structure;
	ДанныеРедактора.Вставить("Идентификатор", "");
	ДанныеРедактора.Вставить("СобытияРедактора", Неопределено);
	ДанныеРедактора.Вставить("Инициализирован", Ложь);
	ДанныеРедактора.Вставить("Видимость", Истина);
	ДанныеРедактора.Вставить("ТолькоПросмотр", Ложь);
	ДанныеРедактора.Вставить("КэшТекстаРедактора", Неопределено);
	ДанныеРедактора.Вставить("Язык", "bsl");
	ДанныеРедактора.Вставить("ПолеРедактора", "");
	ДанныеРедактора.Вставить("ИмяКоманднойПанелиРедактора", "");
	ДанныеРедактора.Вставить("ИмяРеквизита", "");
	ДанныеРедактора.Вставить("ИспользоватьОбработкуДляВыполненияКода", Ложь);
	ДанныеРедактора.Вставить("ПараметрыРедактора", Неопределено);
	ДанныеРедактора.Вставить("КэшРезультатовПодключенияОбработкиИсполнения", Неопределено);
	ДанныеРедактора.Вставить("ПараметрыСессииВзаимодействия", Неопределено);
	
	Возврат ДанныеРедактора;
КонецФункции

// Новый параметры событий редактора.
// 
// Возвращаемое значение:
//  Структура - Новый параметры событий редактора:
// * OnChange - Строка -
Function NewEditorEventOptions() Export
	EditorEvents = New Structure;
	EditorEvents.Insert("OnChange", "");
	
	Return EditorEvents;
EndFunction
 
// Новый данные редактора для сборки обработки.
// 
// Возвращаемое значение:
//  Структура - Новый данные редактора для сборки обработки:
// * Идентификатор - Строка -
// * ИменаПредустановленныхПеременных - Массив из Строка -
// * ТекстРедактора - Строка -
// * ТекстРедактораДляОбработки - Строка -
// * ИсполнениеНаКлиенте - Булево -
// * ИмяПодключаемойОбработки - Строка -
Function NewEditorDataForAssemblyProcessing() Export
	Data = New Structure;
	Data.Вставить("ID", "");
	Data.Вставить("NamesOfPredefinedVariables", New Array);
	Data.Вставить("TextEditor", "");
	Data.Вставить("TextEditorForProcessing", "");
	Data.Вставить("ExecutionOnClient", False);
	Data.Вставить("ConnectedProcessingName", "");
		
	Return Data;
EndFunction

// Новый кэш результатов исполнения через обработку.
// 
// Возвращаемое значение:
//  Структура - Новый кэш результатов исполнения через обработку:
// * ИсполнениеНаКлиенте - Булево -
// * ТекстРедактора - Строка -
// * ИменаПредустановленныхПеременных - Массив Из Строка-
Функция НовыйКэшРезультатовПодключенияОбработкиИсполнения() Экспорт
	Кэш = New Structure;
	Кэш.Вставить("ИсполнениеНаКлиенте", Ложь);
	Кэш.Вставить("ТекстРедактора", "");
	Кэш.Вставить("ИменаПредустановленныхПеременных", New Array);
	
	Возврат Кэш;
КонецФункции

// Новый параметры сессии взаимодействия.
// 
// Возвращаемое значение:
//  Структура -  Новый параметры сессии взаимодействия:
// * ИмяПользователя - Строка - 
// * Идентификатор - Строка - 
// * URLВзаимодействия - Строка - 
Функция НовыйПараметрыСессииВзаимодействия() Экспорт
	ПараметрыСессииВзаимодействия = New Structure;
	ПараметрыСессииВзаимодействия.Вставить("ИмяПользователя", "");
	ПараметрыСессииВзаимодействия.Вставить("Идентификатор","");
	ПараметрыСессииВзаимодействия.Вставить("URLВзаимодействия","");
	
	Возврат ПараметрыСессииВзаимодействия;
КонецФункции

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
// Возвращаемое значение:
//  Структура -  Параметры редактора monaco по умолчанию:
// * ВысотаСтрок - Число - 
// * Тема - Строка - 
// * ЯзыкСинтаксиса - Строка - 
// * ИспользоватьКартуКода - Булево - 
// * СкрытьНомераСтрок - Булево - 
// * ОтображатьПробелыИТабуляции - Булево - 
// * КаталогиИсходныхФайлов - Массив Из Строка - 
// * ФайлыШаблоновКода - Массив из Строка- 
// * ИспользоватьСтандартныеШаблоныКода - Булево - 
// * ИспользоватьКомандыРаботыСБуферомВКонтекстномМеню - Булево - 
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
	ПараметрыРедактора.Вставить("ИспользоватьКомандыРаботыСБуферомВКонтекстномМеню", Ложь);
	
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
	PreparedCode="";

	For Each KeyValue In Context Do
		PreparedCode = PreparedCode +"
		|"+KeyValue.Key+"=__Context__."+KeyValue.Key+";";
	EndDo;

	PreparedCode=PreparedCode + Chars.LF + AlgorithmText;

	Return PreparedCode;
EndFunction



#EndRegion