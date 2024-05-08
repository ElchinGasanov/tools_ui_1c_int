
#Region Public

#Region StorageOfAlgorithms

// Algorithm data.
// 
// Параметры:
//  ID - Строка - Identifier
// 
// Возвращаемое значение:
//  look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
// Возвращаемое значение: 
// 	Undefined - Алгоритм не найден
Function AlgorithmData(ID) Export
	//Сначала ищем в ДБФ
	БазаАлгоритмов = AlgorithmStorageBase();
	
	БазаАлгоритмов.ТекущийИндекс = БазаАлгоритмов.Индексы.IDXID;
	Найдено = БазаАлгоритмов.Найти(ID, "=");
	
	AlgorithmDescription = Undefined;
	If Найдено Then
		AlgorithmDescription = UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm();
		FillAlgorithmHeaderByStorageBase(AlgorithmDescription, БазаАлгоритмов);
		FillDescriptionAlgorithmAfterReadingHeader(AlgorithmDescription);
	EndIf;
	БазаАлгоритмов.ЗакрытьФайл();

	If AlgorithmDescription <> Undefined Then
		Return AlgorithmDescription;
	EndIf;

	

	Return AlgorithmDescription;
EndFunction

// Список алгоритмов.
// 
// Возвращаемое значение:
//  Массив из look УИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма
Function СписокАлгоритмов() Export
	МассивАлгоритмов = Новый Массив;//Массив из look УИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма
	
	ДополнитьСписокАлгоритмовИзДБФ(МассивАлгоритмов);
	ДополнитьСписокАлгоритмовИзХранилищаОбщихНастроек(МассивАлгоритмов);	
	
	Return МассивАлгоритмов;
EndFunction

// Записать алгоритм.
// 
// Параметры:
//  AlgorithmData - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
//  Отказ - Булево
Procedure ЗаписатьАлгоритм(AlgorithmData, Отказ) Export
	If AlgorithmData.ВХранилищеНастроек Then
		ЗаписатьАлгоритмВХранилищеНастроек(AlgorithmData, Отказ);
	Иначе
		ЗаписатьАлгоритмВДБФ(AlgorithmData, Отказ);
	EndIf;
EndProcedure

// Удалить алгоритм.
// 
// Параметры:
//  ID - Строка - Identifier
Procedure УдалитьАлгоритм(ID) Export
	
EndProcedure

Procedure АлгоритмыНайтиПоНаименованию(Наименование) Export
	
EndProcedure

Procedure АлгоритмыНайтиПоКоду(Код) Export
	
EndProcedure

Function АлгоритмыПустаяСсылка() Export
	
EndFunction

#EndRegion

// Description
// 
// Parametrs:
// 	AlgorithmName - String -  Algoritms catalog item name , searched by name 
// 	AlgorithmText - String - Attribute "AlgorithmText" value
// 	ParameterN - Value of any type
// Return value:
// 	String - Result of algorithm saving execution
Function CreatingOfAlgorithm(AlgorithmName, AlgorithmText = "", Val Parameter1 = Undefined, 
	Val Parameter2 = Undefined, Val Parameter3 = Undefined, Val Parameter4 = Undefined, 
	Val Parameter5 = Undefined, Val Parameter6 = Undefined, Val Parameter7 = Undefined, 
	Val Parameter8 = Undefined, Val Parameter9 = Undefined, Val ParametersNamesArray = Undefined)  Export
	
	AlgorithRef = Catalogs.UT_Algorithms.FindByDescription(AlgorithmName);
	If AlgorithRef = Catalogs.UT_Algorithms.EmptyRef() Then
		AlgorithmsObject = Catalogs.UT_Algorithms.CreateItem();
		AlgorithmsObject.Description = AlgorithmName;	
	Else	
		AlgorithmsObject = AlgorithRef.GetObject();
	EndIf;
	If ValueIsFilled(AlgorithmText) Then
		AlgorithmsObject.AlgorithmText = AlgorithmText;
	EndIF;
	
	ParametersStructure = New Structure;
	ParameterValue = Undefined;
	
	SetSafeMode(True);
	If TypeOf(ParametersNamesArray) <> Type("Array") Then
		ParametersNamesArray = New Array;
	EndIf;
	For Parameter = 1 To 9 Do
		VariableName = "Parameter" + Parameter;
		Execute("ParameterValue = " + VariableName);
		ParameterName = ?(ParametersNamesArray.Count() >= Parameter, ParametersNamesArray[Parameter-1],"Parameter" + Parameter); 
		If ParameterValue <> Undefined Then
			ParametersStructure.Insert(ParameterName, ParameterValue);	
		EndIf;
	EndDo;	
	SetSafeMode(False);
	
	AlgorithmsObject.Storage = New ValueStorage(ParametersStructure);
	Try
		AlgorithmsObject.Записать();
	Except
		Return NSTR("ru = 'Ошибка выполнения записи ';en = 'Writing execution error'") + ErrorDescription();
	Endtry;
	
	Return NStr("ru = 'Успешно сохранено';en = 'Successfully saved'");
EndFunction

Function ExecuteAlgorithm(Algorithm) Export
	If Not ValueIsFilled(TrimAll(Algorithm.AlgorithmText)) Then
		Return Undefined;
	EndIf;
	
	ExecutionContext = GetParameters(Algorithm);

	ExecutionResult =  UT_CodeEditorClientServer.ExecuteAlgorithm(Algorithm.AlgorithmText, ExecutionContext);
	
	Return ExecutionResult;
EndFunction

Function GetParameters(Algorithm) Export
	StorageParameters = Algorithm.Storage.Get();
	If StorageParameters = Undefined Or TypeOf(StorageParameters) <> Type("Structure")Then 
		StorageParameters =  New Structure;
	EndIf;
	Return StorageParameters;
EndFunction


#EndRegion

#Region Internal


// Каталог хранения алгоритмов.
// 
// Возвращаемое значение:
//  Строка -  Каталог хранения алгоритмов
Function КаталогХраненияАлгоритмов() Export
	Return УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(УИ_ОбщегоНазначения.КаталогДанныхИнструментовНаСервере(),
														   "Алгоритмы");
EndFunction
#EndRegion

#Region Private



#Region StorageOfAlgorithmsStorageOfGeneralSettings

Function КлючДанныхОбъектаАлгоритмовВХранилищеНастроек() Export
	Return "УИ_УниверсальныеИнструменты_ХранилищеАлгоритмов";
EndFunction

// Список алгоритмов.
// 
// Параметры:
//  МассивАлгоритмов - Массив из lookУИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма 
// 
Procedure ДополнитьСписокАлгоритмовИзХранилищаОбщихНастроек(МассивАлгоритмов) 
	УстановитьПривилегированныйРежим(Истина);
	
	СтруктураПоиска=Новый Структура;
	СтруктураПоиска.Вставить("КлючОбъекта", КлючДанныхОбъектаАлгоритмовВХранилищеНастроек());

	Выборка=ХранилищеСистемныхНастроек.Выбрать(СтруктураПоиска);

	Пока Выборка.Следующий() Цикл
		ОписаниеШапки = УИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма();
		ДанныеНастройки = Выборка.Настройки;
		Попытка
			ЗаполнитьЗначенияСвойств(ОписаниеШапки, ДанныеНастройки);
		Исключение
		КонецПопытки;
		
		МассивАлгоритмов.Добавить(ОписаниеШапки);
	КонецЦикла;
	
EndProcedure

// Записать алгоритм в хранилище настроек.
// 
// Параметры:
//  AlgorithmData - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
//  Отказ - Булево -
Procedure ЗаписатьАлгоритмВХранилищеНастроек(AlgorithmData, Отказ)
	КлючНастроек = AlgorithmData.ID;// + "/" + ИмяПользователя() + "/" + Формат(ТекущаяДата(), "ДФ=yyyyMMddHHmmss;");

//		If ЗначениеЗаполнено(Наименование) Then
//			КлючНастроек = КлючНастроек + "/" + Наименование;
//		EndIf;

	КлючОбъектаАлгоритмов=КлючДанныхОбъектаАлгоритмовВХранилищеНастроек();

	Попытка
		УИ_ОбщегоНазначения.ХранилищеСистемныхНастроекСохранить(КлючОбъектаАлгоритмов, КлючНастроек, AlgorithmData);
	Исключение
		Отказ = Истина;
	КонецПопытки;
EndProcedure

#EndRegion

#Region ДБФХранениеАлгоритма

// Каталог хранения доп данных алгоритма.
// 
// Параметры:
//  ID - Строка - Identifier
// 
// Возвращаемое значение:
//  Строка
Function КаталогХраненияДопДанныхАлгоритма(ID)
	Return УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(UT_CommonCached.КаталогХраненияАлгоритмов(),
														   "ДанныеАлгоритмов",
														   ID);
EndFunction

// Записать алгоритм ВДБФ.
// 
// Параметры:
//  AlgorithmData - look UT_AlgorithmsClientServer.NewDescriptionOfAlgorithm
//  Отказ - Булево -
Procedure ЗаписатьАлгоритмВДБФ(AlgorithmData, Отказ)
	БазаАлгоритмов = AlgorithmStorageBase(Истина);
	
	БазаАлгоритмов.ТекущийИндекс = БазаАлгоритмов.Индексы.IDXID;
	Найдено = БазаАлгоритмов.Найти(AlgorithmData.ID, "=");
	
	If Не Найдено Then
		БазаАлгоритмов.Добавить();
	EndIf;
	
	If Не ЗначениеЗаполнено(AlgorithmData.ID) Then
		AlgorithmData.ID = Строка(Новый УникальныйИдентификатор);
	EndIf;
	БазаАлгоритмов.id = AlgorithmData.ID;
	БазаАлгоритмов.name = AlgorithmData.Наименование;
	БазаАлгоритмов.comment = AlgorithmData.Комментарий;
	БазаАлгоритмов.cashed = AlgorithmData.Кэшировать;
	БазаАлгоритмов.catch = AlgorithmData.ВыбрасыватьИсключение;
	БазаАлгоритмов.transact = AlgorithmData.ВыполнятьВТранзакции;
	БазаАлгоритмов.savejour = AlgorithmData.ЗаписыватьОшибкиВЖР;
	БазаАлгоритмов.httpid = AlgorithmData.ИдентификаторHTTP;
	БазаАлгоритмов.shedid = AlgorithmData.ИдентификаторРегламентногоЗадания;
	БазаАлгоритмов.sheduled = AlgorithmData.ВыполнятьПоРасписанию;
	БазаАлгоритмов.onclient = AlgorithmData.НаКлиенте;
	БазаАлгоритмов.CODE = AlgorithmData.Код;
	
	БазаАлгоритмов.Записать();
	БазаАлгоритмов.ЗакрытьФайл();
	
	КаталогХраненияДопДанныхАлгоритма = КаталогХраненияДопДанныхАлгоритма(AlgorithmData.ID);
	УИ_ОбщегоНазначения.ОбеспечитьКаталог(КаталогХраненияДопДанныхАлгоритма);

	ИмяФайлаТекста = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогХраненияДопДанныхАлгоритма,
																	УИ_АлгоритмыКлиентСервер.ИмяФайлаТекстаАлгоритмаDBF());
	
	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(AlgorithmData.ТекстАлгоритма);
	Текст.Записать(ИмяФайлаТекста, КодировкаТекста.UTF8);
EndProcedure


// Шапка алгоритма из базы хранения.
// 
// Параметры:
// 	ОписаниеШапки - look УИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма
//  БазаХранения - XBase -База хранения
Procedure FillAlgorithmHeaderByStorageBase(ОписаниеШапки,БазаХранения)
	ОписаниеШапки.ID = СокрЛП(БазаХранения.id);
	ОписаниеШапки.Наименование = СокрЛП(БазаХранения.name);
	ОписаниеШапки.Комментарий = СокрЛП(БазаХранения.comment);
	ОписаниеШапки.Кэшировать = БазаХранения.cashed;
	ОписаниеШапки.ВыбрасыватьИсключение = БазаХранения.catch;
	ОписаниеШапки.ВыполнятьВТранзакции = БазаХранения.transact;
	ОписаниеШапки.ЗаписыватьОшибкиВЖР = БазаХранения.savejour;
	ОписаниеШапки.ИдентификаторHTTP = СокрЛП(БазаХранения.httpid);
	ОписаниеШапки.ИдентификаторРегламентногоЗадания = СокрЛП(БазаХранения.shedid);
	ОписаниеШапки.ВыполнятьПоРасписанию = БазаХранения.sheduled;
	ОписаниеШапки.НаКлиенте = БазаХранения.onclient;
	ОписаниеШапки.Код = СокрЛП(БазаХранения.CODE);

EndProcedure

Procedure FillDescriptionAlgorithmAfterReadingHeader(AlgorithmDescription) Export
	КаталогДОпДанныхАлгоритма = КаталогХраненияДопДанныхАлгоритма(AlgorithmDescription.Идентификатор);
	ИмяФайлаАлгоритма = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогДОпДанныхАлгоритма,
																	   УИ_АлгоритмыКлиентСервер.ИмяФайлаТекстаАлгоритмаDBF());
	
	Текст = Новый ТекстовыйДокумент();
	Текст.Прочитать(ИмяФайлаАлгоритма, КодировкаТекста.UTF8);
	
	AlgorithmDescription.ТекстАлгоритма = Текст.ПолучитьТекст();
EndProcedure

// Список алгоритмов.
// 
// Параметры:
//  МассивАлгоритмов - Массив из look УИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма 
// 
Procedure ДополнитьСписокАлгоритмовИзДБФ(МассивАлгоритмов) 
	БазаАлгоритмов = AlgorithmStorageBase();
	ЕстьЗаписи = БазаАлгоритмов.Первая();
	If Не ЕстьЗаписи Then
		Return;
	EndIf;
	
	Пока Истина Цикл
		ОписаниеШапки = УИ_АлгоритмыКлиентСервер.НовыйОписаниеШапкиАлгоритма();
		FillAlgorithmHeaderByStorageBase(ОписаниеШапки, БазаАлгоритмов);
		
		МассивАлгоритмов.Добавить(ОписаниеШапки);

		If Не БазаАлгоритмов.Следующая() Then
			Прервать;
		EndIf;
	КонецЦикла;
	БазаАлгоритмов.ЗакрытьФайл();
	
EndProcedure

// Создать базу хранения алгоритмов.
// 
// Параметры:
//  ИмяФайлаХранения - Строка -  Имя файла хранения
//  ИмяФайлаИндексов - Строка -  Имя файла индексов
Procedure СоздатьБазуХраненияАлгоритмов(ИмяФайлаХранения, ИмяФайлаИндексов) 
	ДБФ = ОбъектXBaseХраненияАлгоритмов();
	UpdateStorageStructureHeader(ДБФ);
	ДБФ.СоздатьФайл(ИмяФайлаХранения);
	//ДБФ.СоздатьИндексныйФайл(ИмяФайлаИндексов);
	ДБФ.ЗакрытьФайл();
EndProcedure

// Algorithm storage base.
// 
// Параметры:
//  ДляИзменения - Булево -  Для изменения
// 
// Возвращаемое значение:
//  XBase -  Algorithm storage base
Function AlgorithmStorageBase(ДляИзменения = False) 
	КаталогХранения = UT_CommonCached.КаталогХраненияАлгоритмов();
	УИ_ОбщегоНазначения.ОбеспечитьКаталог(КаталогХранения);

	ИмяФайлов = ИмяФайлаХранилищаАлгоритмов();
	
	ИмяФайлаХранения = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогХранения, ИмяФайлов+".DBF");
	ИмяФайлаИндексов = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогХранения, ИмяФайлов+".CDX");
		
	File = New File(ИмяФайлаХранения);
	If не File.Exists() Then
		СоздатьБазуХраненияАлгоритмов(ИмяФайлаХранения, ИмяФайлаИндексов);
	EndIf;
		
	ДБФ = ОбъектXBaseХраненияАлгоритмов();
	ДБФ.ОткрытьФайл(ИмяФайлаХранения, ИмяФайлаИндексов, Не ДляИзменения);
		
	Return ДБФ;	
EndFunction

// Обновить структуру хранения шапки.
// 
// Параметры:
//  ДБФ -XBase-ДБФ
Procedure UpdateStorageStructureHeader(ДБФ)
	ДобавитьПолеХранения(ДБФ, "ID", "S", 40);
	ДобавитьПолеХранения(ДБФ, "NAME", "S", 150);
	ДобавитьПолеХранения(ДБФ, "CODE", "S", 9);
	ДобавитьПолеХранения(ДБФ, "COMMENT", "S", 150);
	ДобавитьПолеХранения(ДБФ, "CASHED", "L");
	ДобавитьПолеХранения(ДБФ, "CATCH", "L");
	ДобавитьПолеХранения(ДБФ, "TRANSACT", "L");
	ДобавитьПолеХранения(ДБФ, "SAVEJOUR", "L");
	ДобавитьПолеХранения(ДБФ, "HTTPID", "S", 25);
	ДобавитьПолеХранения(ДБФ, "SHEDID", "S", 50);
	ДобавитьПолеХранения(ДБФ, "SHEDULED", "L");
	ДобавитьПолеХранения(ДБФ, "ONCLIENT", "L");
	
	ДобавитьИндексПоПолюХранения(ДБФ, "IDXID", "ID", Истина);
	ДобавитьИндексПоПолюХранения(ДБФ, "IDXNAME", "NAME", Ложь);
	ДобавитьИндексПоПолюХранения(ДБФ, "IDXHTTPID", "HTTPID", Ложь);
	ДобавитьИндексПоПолюХранения(ДБФ, "IDXSHEDID", "SHEDID", Ложь);
EndProcedure

// Добавить индекс по полю хранения.
// 
// Параметры:
//  ДБФ - XBase - ДБФ
//  Имя - Строка - Имя
//  Выражение - Строка- Выражение
//  Уникальность - Булево -Уникальность
Procedure ДобавитьИндексПоПолюХранения(ДБФ, Имя, Выражение, Уникальность)
	Индекс = ДБФ.Индексы.Найти(Имя);
	If Индекс <> Undefined Then
		Return;
	EndIf;
	
	ДБФ.Индексы.Добавить(Имя, Выражение, Уникальность);
EndProcedure

Procedure ДобавитьПолеХранения(ДБФ, Имя, Тип, Длина = 0, Точность = 0)
	Поле = ДБФ.Поля.Найти(Имя);
	If Поле <> Undefined Then
		Return;
	EndIf;
	
	ДБФ.Поля.Добавить(Имя, Тип, Длина, Точность);
EndProcedure

Function ИмяФайлаХранилищаАлгоритмов()
	Return "ALGO";
EndFunction

// Объект x base хранения алгоритмов.
// 
// Возвращаемое значение:
//  XBase -  Объект x base хранения алгоритмов
Function ОбъектXBaseХраненияАлгоритмов() 
	ДБФ = Новый XBase;
	ДБФ.Кодировка = КодировкаXBase.ANSI;
	ДБФ.ОтображатьУдаленные = Ложь;
		
	Return ДБФ;
EndFunction

#EndRegion

#EndRegion
