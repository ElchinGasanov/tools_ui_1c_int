#Region FormEvents

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	StartHeader = Заголовок;

	ИнициализироватьФорму();

	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("Системная");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("ANSI");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("OEM");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("UTF8");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("UTF16");

	Если Параметры.Свойство("ДанныеОтладки") Тогда
		ЗаполнитьПоДаннымОтладки(Параметры.ДанныеОтладки);
	КонецЕсли;

	УстановитьДоступностьТелаЗапроса(ThisObject);
	
	UT_Common.ФормаИнструментаПриСозданииНаСервере(ThisObject, Отказ, СтандартнаяОбработка, Элементы.ГруппаКоманднаяПанельФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

#EndRegion

#Region FormItemsEvents

&НаКлиенте
Процедура ИсторияЗапросовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ЗаполнитьДанныеТекущегоЗапросаПоИстории(ВыбраннаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ИсторияЗапросовПриАктивизацииСтроки(Элемент)
	ТекДанные = Элементы.ИсторияЗапросов.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ТекДанные.RequestBodyFormat = "Строкой" Тогда
		НоваяСтраница = Элементы.ГруппаИсторияЗапросовТелоЗапросаСтраницаСтрока;
	ИначеЕсли ТекДанные.RequestBodyFormat = "ДвоичныеДанные" Тогда
		НоваяСтраница = Элементы.ГруппаИсторияЗапросовТелоЗапросаСтраницаДвоичныеДанные;
	Иначе
		НоваяСтраница = Элементы.ГруппаИсторияЗапросовТелоЗапросаСтраницаФайл;
	КонецЕсли;

	Элементы.ГруппаИсторияЗапросовТелоЗапросаСтраницы.ТекущаяСтраница = НоваяСтраница;

	Если ЭтоАдресВременногоХранилища(ТекДанные.АдресТелаОтветаСтрокой) Тогда
		ResponseBodyString = ПолучитьИзВременногоХранилища(ТекДанные.АдресТелаОтветаСтрокой);
	Иначе
		ResponseBodyString = "";
	КонецЕсли;

	ProxyInspectionOptionsHeader = ЗаголовокНастроекПроксиПоПараметрам(ТекДанные.ИспользоватьПрокси,
		ТекДанные.ПроксиСервер, ТекДанные.ПроксиПорт, ТекДанные.ПроксиПользователь, ТекДанные.ПроксиПароль,
		ТекДанные.ПроксиАутентификацияОС);
КонецПроцедуры

&НаКлиенте
Процедура ИсторияЗапросовТелоЗапросаИмяФайлаОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;

	ТекДанные = Элементы.ИсторияЗапросов.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	НачатьЗапускПриложения(UT_CommonClient.ПустоеОписаниеОповещенияДляЗапускаПриложения(),
		ТекДанные.ТелоЗапросаИмяФайла);
КонецПроцедуры

&НаКлиенте
Процедура РедактированиеЗаголовковТаблицейПриИзменении(Элемент)
	УстановитьСтраницуРедактированияЗаголовковЗапроса();
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗаголовковЗапросаКлючАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание,
	СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;

	Если Не ЗначениеЗаполнено(Текст) Тогда
		Возврат;
	КонецЕсли;

	ДанныеВыбора = Новый СписокЗначений;

	Для Каждого ЭлементСписка Из СписокИспользованныхЗаголовков Цикл
		Если СтрНайти(НРег(ЭлементСписка.Значение), НРег(Текст)) > 0 Тогда
			ДанныеВыбора.Добавить(ЭлементСписка.Значение);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ВидТелаЗапросаПриИзменении(Элемент)
	ТолькоПросмотрГруппыПараметровСтроковогоТела = Истина;

	Если RequestBodyFormat = "Строкой" Тогда
		НоваяСтраница = Элементы.ГруппаСтраницаТелаЗапросаСтрокой;
		ТолькоПросмотрГруппыПараметровСтроковогоТела = Ложь;
	ИначеЕсли RequestBodyFormat = "ДвоичныеДанные" Тогда
		НоваяСтраница = Элементы.ГруппаСтраницаТелаЗапросаДвоичныеДанные;
	Иначе
		НоваяСтраница = Элементы.ГруппаСтраницаТелаЗапросаИмяФайлаТела;
	КонецЕсли;

	Элементы.ГруппаСтраницыТелаЗапроса.ТекущаяСтраница = НоваяСтраница;
	Элементы.ГруппаСвойстваСтроковогоТелаЗапроса.ТолькоПросмотр = ТолькоПросмотрГруппыПараметровСтроковогоТела;
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаТелаЗапросаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДВФ.МножественныйВыбор = Ложь;
	ДВФ.ПолноеИмяФайла = RequestBodyFileName;

	ДВФ.Показать(Новый ОписаниеОповещения("ИмяФайлаТелаЗапросаНачалоВыбораЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура ЗапросHTTPПриИзменении(Элемент)
	УстановитьДоступностьТелаЗапроса(ThisObject);
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьПроксиПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиСерверПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиПортПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиПользовательПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиПарольПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиАутентификацияОСПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

#EndRegion

#Region FormCommandEvents

&НаКлиенте
Процедура ВыполнитьЗапрос(Команда)
	Если RequestBodyFormat = "Файл" Тогда
		RequestBodyFileAddress = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(RequestBodyFileName),
			RequestBodyFileAddress);
	КонецЕсли;
	ВыполнитьЗапросНаСервере();
	
	//позиционируем историю запросов на текущую строку
	Если ИсторияЗапросов.Количество() > 0 Тогда
		Элементы.ИсторияЗапросов.ТекущаяСтрока=ИсторияЗапросов[ИсторияЗапросов.Количество()
			- 1].ПолучитьИдентификатор();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДвоичныеДанныеТелаИзФайла(Команда)
	НачатьПомещениеФайла(Новый ОписаниеОповещения("ЗаполнитьДвоичныеДанныеТелаИзФайлаЗавершение", ThisObject),
		RequestBodyBinaryDataAddress, "", Истина, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьДвоичныеДанныеТелаЗапросаИзИстории(Команда)
	ТекДанныеИсторииЗапроса = Элементы.ИсторияЗапросов.ТекущиеДанные;
	Если ТекДанныеИсторииЗапроса = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Не ЭтоАдресВременногоХранилища(ТекДанныеИсторииЗапроса.ТелоЗапросаАдресДвоичныхДанных) Тогда
		Возврат;
	КонецЕсли;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = Ложь;

	ПолучаемыеФайлы = Новый Массив;
	ПолучаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(, ТекДанныеИсторииЗапроса.ТелоЗапросаАдресДвоичныхДанных));

	НачатьПолучениеФайлов(Новый ОписаниеОповещения("СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении",
		ThisObject), ПолучаемыеФайлы, ДВФ, Истина);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьТелоОтветаДвоичныеДанныеВФайл(Команда)
	ТекДанныеИсторииЗапроса = Элементы.ИсторияЗапросов.ТекущиеДанные;
	Если ТекДанныеИсторииЗапроса = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Не ЭтоАдресВременногоХранилища(ТекДанныеИсторииЗапроса.ТелоОтветаАдресДвоичныхДанных) Тогда
		Возврат;
	КонецЕсли;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = Ложь;

	ПолучаемыеФайлы = Новый Массив;
	ПолучаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(, ТекДанныеИсторииЗапроса.ТелоОтветаАдресДвоичныхДанных));

	НачатьПолучениеФайлов(Новый ОписаниеОповещения("СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении",
		ThisObject), ПолучаемыеФайлы, ДВФ, Истина);
КонецПроцедуры

&НаКлиенте
Процедура НовыйФайлЗапросов(Команда)
	Если ИсторияЗапросов.Количество() = 0 Тогда
		ИнициализироватьКонсоль();
	Иначе
		ПоказатьВопрос(Новый ОписаниеОповещения("НовыйФайлЗапросовЗавершение", ThisObject),
			"История запросов непустая. Продолжить?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайлЗапросов(Команда)
	Если ИсторияЗапросов.Количество() = 0 Тогда
		ЗагрузитьФайлКонсоли();
	Иначе
		ПоказатьВопрос(Новый ОписаниеОповещения("ОткрытьФайлОтчетовЗавершение", ThisObject),
			"История запросов непустая. Продолжить?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция СтруктураОписанияСохраняемогоФайла()
	Структура=UT_CommonClient.ПустаяСтруктураОписанияВыбираемогоФайла();
	Структура.ИмяФайла=RequestsFileName;

	// Пока закоментим сохранение в JSON, т.к. библиотека ошибки выдает на двоичных данных
	UT_CommonClient.ДобавитьФорматВОписаниеФайлаСохранения(Структура,
		"Файл запросов консоли HTPP в JSON (*.jhttp)", "jhttp");
	UT_CommonClient.ДобавитьФорматВОписаниеФайлаСохранения(Структура, "Файл запросов консоли HTPP (*.xhttp)",
		"xhttp");

	Возврат Структура;
КонецФункции

&НаКлиенте
Процедура СохранитьЗапросыВФайл(Команда)
	UT_CommonClient.СохранитьДанныеКонсолиВФайл("КонсольHTTPЗапросов", Ложь,
		СтруктураОписанияСохраняемогоФайла(), ПоместитьДанныеИсторииВоВременноеХранилище(),
		Новый ОписаниеОповещения("СохранениеВФайлЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура СохранитьЗапросыВФайлКак(Команда)
	UT_CommonClient.СохранитьДанныеКонсолиВФайл("КонсольHTTPЗапросов", Истина,
		СтруктураОписанияСохраняемогоФайла(), ПоместитьДанныеИсторииВоВременноеХранилище(),
		Новый ОписаниеОповещения("СохранениеВФайлЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоЗапросаВРедактореJSON(Команда)
	UT_CommonClient.РедактироватьJSON(RequestBody, Ложь,
		Новый ОписаниеОповещения("РедактироватьТелоЗапросаВРедактореJSONЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоЗапросаВРедактореJSONАнализируемогоЗапроса(Команда)
	UT_CommonClient.РедактироватьJSON(Элементы.ИсторияЗапросов.ТекущиеДанные.ТелоЗапросаСтрока, Истина);
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоОтветаВРедактореJSONАнализируемогоЗапроса(Команда)
	UT_CommonClient.РедактироватьJSON(ResponseBodyString, Истина);
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Команда) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Команда);
КонецПроцедуры

#EndRegion

#Region RequestFiles

// Отработка загрузки файла с отчетами из адреса.
&НаКлиенте
Процедура ОтработкаЗагрузкиИзАдреса(Адрес)
	Попытка
		ЗагрузитьФайлКонсолиНаСервере(Адрес);
		ИнициализироватьЗапрос();
	Исключение
		RequestsFileName = "";
		Возврат;
	КонецПопытки;
	ОбновитьЗаголовок();
КонецПроцедуры

// Загрузить файл консоли на сервере.
//
// Параметры:
//  Адрес - адрес хранилища, из которого нужно загрузить файл.
&НаСервере
Процедура ЗагрузитьФайлКонсолиНаСервере(Адрес)

	ТаблицаИстории = Обработки.UT_HTTPRequestConsole.ДанныеСохраненияИзСериализованнойСтроки(Адрес, RequestsFileName);

	ИсторияЗапросов.Очистить();

	Для Каждого СтрокаТз Из ТаблицаИстории Цикл
		НС = ИсторияЗапросов.Добавить();
		ЗаполнитьЗначенияСвойств(НС, СтрокаТз);

		НС.ТелоЗапросаАдресДвоичныхДанных = ПоместитьВоВременноеХранилище(СтрокаТз.ТелоЗапросаДвоичныеДанные,
			УникальныйИдентификатор);
		НС.ТелоОтветаАдресДвоичныхДанных = ПоместитьВоВременноеХранилище(СтрокаТз.ТелоОтветаДвоичныеДанные,
			УникальныйИдентификатор);
		НС.АдресТелаОтветаСтрокой = ПоместитьВоВременноеХранилище(СтрокаТз.ТелоОтвета, УникальныйИдентификатор);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлКонсолиПослеПомещенияФайла(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestsFileName = Результат.ИмяФайла;
	ОтработкаЗагрузкиИзАдреса(Результат.Адрес);

КонецПроцедуры

// Загрузить файл.
//
// Параметры:
//  ЗагружаемоеИмяФайла - имя файла, из которого нужно загрузить. Если имя файла
//						  пустое, то нужно запросить у пользователя имя файла.
&НаКлиенте
Процедура ЗагрузитьФайлКонсоли()

	UT_CommonClient.ПрочитатьДанныеКонсолиИзФайла("КонсольHTTPЗапросов",
		СтруктураОписанияСохраняемогоФайла(), Новый ОписаниеОповещения("ЗагрузитьФайлКонсолиПослеПомещенияФайла",
		ThisObject));

КонецПроцедуры

// Завершение обработчика открытия файла.
&НаКлиенте
Процедура ОткрытьФайлОтчетовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	ЗагрузитьФайлКонсоли();

КонецПроцедуры

&НаКлиенте
Процедура ИнициализироватьКонсоль()
	ИсторияЗапросов.Очистить();
	ИнициализироватьЗапрос();
КонецПроцедуры

// Завершение обработчика создания нового файла запросов.
&НаКлиенте
Процедура НовыйФайлЗапросовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;

	ИнициализироватьКонсоль();

КонецПроцедуры

// Завершение обработчика открытия файла.
&НаКлиенте
Процедура СохранениеВФайлЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestsFileName=Результат;
	Модифицированность = Ложь;
	ОбновитьЗаголовок();

КонецПроцедуры

// Поместить файл во временное хранилище.
&НаСервере
Функция ПоместитьДанныеИсторииВоВременноеХранилище()

	ТаблицаЗначенийИстории = РеквизитФормыВЗначение("ИсторияЗапросов");

	ТаблицаЗначенийИстории.Колонки.Добавить("ТелоЗапросаДвоичныеДанные");
	ТаблицаЗначенийИстории.Колонки.Добавить("ТелоОтветаДвоичныеДанные");
	ТаблицаЗначенийИстории.Колонки.Добавить("ТелоОтвета");
	Для Каждого СтрокаТЗ Из ТаблицаЗначенийИстории Цикл
		Если ЭтоАдресВременногоХранилища(СтрокаТЗ.ТелоЗапросаАдресДвоичныхДанных) Тогда
			СтрокаТЗ.ТелоЗапросаДвоичныеДанные = ПолучитьИзВременногоХранилища(СтрокаТЗ.ТелоЗапросаАдресДвоичныхДанных);
		КонецЕсли;
		Если ЭтоАдресВременногоХранилища(СтрокаТЗ.ТелоОтветаАдресДвоичныхДанных) Тогда
			СтрокаТЗ.ТелоОтветаДвоичныеДанные = ПолучитьИзВременногоХранилища(СтрокаТЗ.ТелоОтветаАдресДвоичныхДанных);
		КонецЕсли;
		Если ЭтоАдресВременногоХранилища(СтрокаТЗ.АдресТелаОтветаСтрокой) Тогда
			СтрокаТЗ.ТелоОтвета = ПолучитьИзВременногоХранилища(СтрокаТЗ.АдресТелаОтветаСтрокой);
		КонецЕсли;
	КонецЦикла;

	ТаблицаЗначенийИстории.Колонки.Удалить("ТелоЗапросаАдресДвоичныхДанных");
	ТаблицаЗначенийИстории.Колонки.Удалить("ТелоОтветаАдресДвоичныхДанных");
	ТаблицаЗначенийИстории.Колонки.Удалить("АдресТелаОтветаСтрокой");

	Результат = ПоместитьВоВременноеХранилище(ТаблицаЗначенийИстории, УникальныйИдентификатор);
	Возврат Результат;

	СериализаторJSON=Обработки.УИ_ПреобразованиеДанныхJSON.Создать();

	СтруктураИстории=СериализаторJSON.ЗначениеВСтруктуру(ТаблицаЗначенийИстории);
	JSONСтрокаИстории=СериализаторJSON.ЗаписатьОписаниеОбъектаВJSON(СтруктураИстории);
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();

	ЗначениеВФайл(ИмяВременногоФайла, ТаблицаЗначенийИстории);
	Результат = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ИмяВременногоФайла));

	Попытка
		УдалитьФайлы(ИмяВременногоФайла);
	Исключение
	КонецПопытки;

	Возврат Результат;

КонецФункции

#EndRegion

#Region RequestExecute

&НаСервере
Функция ПодготовленноеСоединение(СтруктураURL)
	Порт = Неопределено;
	Если ЗначениеЗаполнено(СтруктураURL.Порт) Тогда
		Порт = СтруктураURL.Порт;
	КонецЕсли;
	Если UseProxy Тогда
		НастройкаПрокси = Новый ИнтернетПрокси(Истина);
		НастройкаПрокси.Установить(СтруктураURL.Схема, ProxyServer, ProxyPort, ProxyUser, ProxyPassword,
			OSAuthentificationProxy);
	Иначе
		НастройкаПрокси = Неопределено;
	КонецЕсли;

	Если НРег(СтруктураURL.Схема) = "https" Тогда
		СоединениеHTTP = Новый HTTPСоединение(СтруктураURL.Сервер, Порт, , , НастройкаПрокси, Timeout,
			Новый ЗащищенноеСоединениеOpenSSL);
	Иначе
		СоединениеHTTP = Новый HTTPСоединение(СтруктураURL.Сервер, Порт, , , НастройкаПрокси, Timeout);
	КонецЕсли;

	Возврат СоединениеHTTP;
КонецФункции

&НаСервере
Функция ПодготовленныйЗапросHTTP(СтруктураURL)
	НовыйЗапрос = Новый HTTPЗапрос;

	СтрокаЗапроса = СтруктураURL.Путь;

	СтрокаПараметров = "";
	Для Каждого КлючЗначение Из СтруктураURL.ПараметрыЗапроса Цикл
		СтрокаПараметров = СтрокаПараметров + ?(ЗначениеЗаполнено(СтрокаПараметров), "?", "&") + КлючЗначение.Ключ + "="
			+ КлючЗначение.Значение;
	КонецЦикла;

	НовыйЗапрос.АдресРесурса = СтрокаЗапроса + СтрокаПараметров;
	Если Не ЗапросБезТелаЗапроса(HTTPRequest) Тогда
		Если RequestBodyFormat = "Строкой" Тогда
			Если ЗначениеЗаполнено(RequestBody) Тогда
				Если UseBOM = 0 Тогда
					БОМ = ИспользованиеByteOrderMark.Авто;
				ИначеЕсли (UseBOM = 1) Тогда
					БОМ = ИспользованиеByteOrderMark.Использовать;
				Иначе
					БОМ = ИспользованиеByteOrderMark.НеИспользовать;
				КонецЕсли;

				Если RequestBodyEncoding = "Авто" Тогда
					НовыйЗапрос.УстановитьТелоИзСтроки(RequestBody, , БОМ);
				Иначе

					НовыйЗапрос.УстановитьТелоИзСтроки(RequestBody, RequestBodyEncoding, БОМ);
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли RequestBodyFormat = "ДвоичныеДанные" Тогда
			ДвоичныеДанныеТела = ПолучитьИзВременногоХранилища(RequestBodyBinaryDataAddress);
			Если ТипЗнч(ДвоичныеДанныеТела) = Тип("ДвоичныеДанные") Тогда
				НовыйЗапрос.УстановитьТелоИзДвоичныхДанных(ДвоичныеДанныеТела);
			КонецЕсли;
		Иначе
			ДвоичныеДанныеТела = ПолучитьИзВременногоХранилища(RequestBodyFileAddress);
			Если ТипЗнч(ДвоичныеДанныеТела) = Тип("ДвоичныеДанные") Тогда
				Файл = Новый Файл(RequestBodyFileName);
				ВременныйФайл = ПолучитьИмяВременногоФайла(Файл.Расширение);
				ДвоичныеДанныеТела.Записать(ВременныйФайл);

				НовыйЗапрос.УстановитьИмяФайлаТела(ВременныйФайл);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	//Теперь нужно установить заголовки запроса
	Если TableHeadersEditor Тогда
		Заголовки = Новый Соответствие;

		Для Каждого СтрокаЗаголовка Из ТаблицаЗаголовковЗапроса Цикл
			Заголовки.Вставить(СтрокаЗаголовка.Ключ, СтрокаЗаголовка.Значение);
		КонецЦикла;
	Иначе
		Заголовки = UT_CommonClientServer.HTTPRequestHeadersFromString(HeadersString);
	КонецЕсли;

	НовыйЗапрос.Заголовки = Заголовки;

	Возврат НовыйЗапрос;
КонецФункции

&НаСервере
Процедура ВыполнитьЗапросНаСервере()
	СтруктураURL = UT_HTTPConnector.РазобратьURL(RequestURL);

	СоединениеHTTP = ПодготовленноеСоединение(СтруктураURL);

	НачалоВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Запрос = ПодготовленныйЗапросHTTP(СтруктураURL);
	ДатаНачала = ТекущаяДата();
	Попытка
		Если HTTPRequest = "GET" Тогда
			Ответ = СоединениеHTTP.Получить(Запрос);
		ИначеЕсли HTTPRequest = "POST" Тогда
			Ответ = СоединениеHTTP.ОтправитьДляОбработки(Запрос);
		ИначеЕсли HTTPRequest = "DELETE" Тогда
			Ответ = СоединениеHTTP.Удалить(Запрос);
		ИначеЕсли HTTPRequest = "PUT" Тогда
			Ответ = СоединениеHTTP.Записать(Запрос);
		ИначеЕсли HTTPRequest = "PATCH" Тогда
			Ответ = СоединениеHTTP.Изменить(Запрос);
		Иначе
			Возврат;
		КонецЕсли;
	Исключение

	КонецПопытки;
	ОкончаниеВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();

	ДлительностьВМилисекундах = ОкончаниеВыполнения - НачалоВыполнения;

	ЗафиксироватьЛогЗапроса(СтруктураURL.Сервер, СтруктураURL.Схема, Запрос, Ответ, ДатаНачала,
		ДлительностьВМилисекундах);

	ДополнитьСписокИспользованныхРанееЗаголовков(Запрос.Заголовки);
КонецПроцедуры

&НаСервере
Процедура ДополнитьСписокИспользованныхРанееЗаголовков(Заголовки)
	Для Каждого КлючЗначение Из Заголовки Цикл
		Если СписокИспользованныхЗаголовков.НайтиПоЗначению(КлючЗначение.Ключ) = Неопределено Тогда
			СписокИспользованныхЗаголовков.Добавить(КлючЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ЗафиксироватьЛогЗапроса(АдресСервера, Протокол, HTTPЗапрос, HTTPОтвет, ДатаНачала, Длительность)

		//	Если HTTPОтвет = Неопределено Тогда 
	//		Ошибка = Истина;
	//	Иначе 
	//		Ошибка=Не ПроверитьУспешностьВыполненияЗапроса(HTTPОтвет);//.КодСостояния<>КодУспешногоЗапроса;
	//	КонецЕсли;
	ЗаписьЛога = ИсторияЗапросов.Добавить();
	ЗаписьЛога.URL = RequestURL;

	ЗаписьЛога.HTTPФункция = HTTPRequest;
	ЗаписьЛога.АдресСервера = АдресСервера;
	ЗаписьЛога.Дата = ДатаНачала;
	ЗаписьЛога.ДлительностьВыполнения = Длительность;
	ЗаписьЛога.Запрос = HTTPЗапрос.АдресРесурса;
	ЗаписьЛога.ЗаголовкиЗапроса = UT_CommonClientServer.GetHTTPHeadersString(HTTPЗапрос.Заголовки);
	ЗаписьЛога.BOM = UseBOM;
	ЗаписьЛога.КодировкаТелаЗапроса = RequestBodyEncoding;
	ЗаписьЛога.RequestBodyFormat = RequestBodyFormat;
	ЗаписьЛога.Таймаут = Timeout;

	ЗаписьЛога.ТелоЗапросаСтрока = HTTPЗапрос.ПолучитьТелоКакСтроку();

	ДвоичныеДанныеТела = HTTPЗапрос.ПолучитьТелоКакДвоичныеДанные();
	ЗаписьЛога.ТелоЗапросаАдресДвоичныхДанных = ПоместитьВоВременноеХранилище(ДвоичныеДанныеТела,
		УникальныйИдентификатор);
	ЗаписьЛога.ТелоЗапросаДвоичныеДанныеСтрокой = Строка(ДвоичныеДанныеТела);
	ЗаписьЛога.ТелоЗапросаИмяФайла = RequestBodyFileName;
	ЗаписьЛога.Протокол = Протокол;

	// Прокси
	ЗаписьЛога.ИспользоватьПрокси = UseProxy;
	ЗаписьЛога.ПроксиСервер = ProxyServer;
	ЗаписьЛога.ПроксиПорт = ProxyPort;
	ЗаписьЛога.ПроксиПользователь = ProxyUser;
	ЗаписьЛога.ПроксиПароль = ProxyPassword;
	ЗаписьЛога.ПроксиАутентификацияОС = OSAuthentificationProxy;

	ЗаписьЛога.КодСостояния = ?(HTTPОтвет = Неопределено, 500, HTTPОтвет.КодСостояния);

	Если HTTPОтвет = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ЗаписьЛога.ЗаголовкиОтвета = UT_CommonClientServer.GetHTTPHeadersString(HTTPОтвет.Заголовки);

	ТелоОтветаСтрокойЛог = HTTPОтвет.ПолучитьТелоКакСтроку();
	Если ЗначениеЗаполнено(ТелоОтветаСтрокойЛог) Тогда
		Если НайтиНедопустимыеСимволыXML(ТелоОтветаСтрокойЛог) = 0 Тогда
			ЗаписьЛога.АдресТелаОтветаСтрокой = ПоместитьВоВременноеХранилище(ТелоОтветаСтрокойЛог,
				УникальныйИдентификатор);
		Иначе
			ЗаписьЛога.АдресТелаОтветаСтрокой = ПоместитьВоВременноеХранилище("Содержит недопустимые символы XML",
				УникальныйИдентификатор);
		КонецЕсли;
	КонецЕсли;
	ДвоичныеДанныеОтвета = HTTPОтвет.ПолучитьТелоКакДвоичныеДанные();
	Если ДвоичныеДанныеОтвета <> Неопределено Тогда
		ЗаписьЛога.ТелоОтветаАдресДвоичныхДанных = ПоместитьВоВременноеХранилище(ДвоичныеДанныеОтвета,
			УникальныйИдентификатор);
		ЗаписьЛога.ТелоОтветаДвоичныеДанныеСтрокой = Строка(ДвоичныеДанныеОтвета);
	КонецЕсли;

	ИмяФайлаОтвета = HTTPОтвет.ПолучитьИмяФайлаТела();
	Если ИмяФайлаОтвета <> Неопределено Тогда
		Файл = Новый Файл(ИмяФайлаОтвета);
		Если Файл.Существует() Тогда
			ДвоичныеДанныеОтвета = Новый ДвоичныеДанные(ИмяФайлаОтвета);
			ЗаписьЛога.ТелоОтветаАдресДвоичныхДанных = ПоместитьВоВременноеХранилище(ДвоичныеДанныеОтвета,
				УникальныйИдентификатор);
			ЗаписьЛога.ТелоОтветаДвоичныеДанныеСтрокой = Строка(ДвоичныеДанныеОтвета);

		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

#EndRegion

#Region UtilizationProceduresAndFunctions

// Обновить заголовок формы.
&НаКлиенте
Процедура ОбновитьЗаголовок()

	Заголовок = StartHeader + ?(RequestsFileName <> "", ": " + RequestsFileName, "");

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ЗаголовокНастроекПроксиПоПараметрам(ИспользоватьПрокси, Сервер, Порт, Пользователь, Пароль, АутентификацияОС)

	ПрефиксЗаголовка = "";

	Если ИспользоватьПрокси Тогда
		ЗаголовокГруппыПрокси = ПрефиксЗаголовка + Сервер;
		Если ЗначениеЗаполнено(Порт) Тогда
			ЗаголовокГруппыПрокси = ЗаголовокГруппыПрокси + ":" + Формат(Порт, "ЧГ=0;");
		КонецЕсли;

		Если АутентификацияОС Тогда
			ЗаголовокГруппыПрокси = ЗаголовокГруппыПрокси + "; Аутентификация ОС";
		ИначеЕсли ЗначениеЗаполнено(Пользователь) Тогда
			ЗаголовокГруппыПрокси = ЗаголовокГруппыПрокси + ";" + Пользователь;
		КонецЕсли;

	Иначе
		ЗаголовокГруппыПрокси = ПрефиксЗаголовка + " Не используется";
	КонецЕсли;

	Возврат ЗаголовокГруппыПрокси;
КонецФункции

&НаКлиенте
Процедура СформироватьЗаголовокНастроекПрокси()
	ProxyOptionsHeader = ЗаголовокНастроекПроксиПоПараметрам(UseProxy, ProxyServer, ProxyPort,
		ProxyUser, ProxyPassword, OSAuthentificationProxy);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении(ПолученныеФайлы, ДополнительныеПараметры) Экспорт
	Если ПолученныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ЗапросБезТелаЗапроса(ВидЗапросаHTTP)
	МассивЗапросовБезТела = Новый Массив;
	МассивЗапросовБезТела.Добавить("GET");
	МассивЗапросовБезТела.Добавить("DELETE");

	Возврат МассивЗапросовБезТела.Найти(ВРег(ВидЗапросаHTTP)) <> Неопределено;

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьТелаЗапроса(Форма)
	Форма.Элементы.ГруппаТелоЗапроса.ТолькоПросмотр = ЗапросБезТелаЗапроса(Форма.HTTPRequest);
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДвоичныеДанныеТелаИзФайлаЗавершение(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	Если Не Результат Тогда
		Возврат;
	КонецЕсли;

	RequestBodyBinaryDataAddress = Адрес;

	RequestBodyBinaryDataString = Строка(ПолучитьИзВременногоХранилища(Адрес));
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаТелаЗапросаНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт

	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ВыбранныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	RequestBodyFileName = ВыбранныеФайлы[0];
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуЗаголовковПоСтроке(СтрокаЗаголовков)
	ЗаголовкиПоСтроке = UT_CommonClientServer.HTTPRequestHeadersFromString(СтрокаЗаголовков);

	ТаблицаЗаголовковЗапроса.Очистить();

	Для Каждого КлючЗначение Из ЗаголовкиПоСтроке Цикл
		НС = ТаблицаЗаголовковЗапроса.Добавить();
		НС.Ключ = КлючЗначение.Ключ;
		НС.Значение = КлючЗначение.Значение;
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтраницуРедактированияЗаголовковЗапроса()
	Если TableHeadersEditor Тогда
		НоваяСтраница = Элементы.ГруппаСтраницаРедактированияЗаголовковЗапросаТаблицей;
	Иначе
		НоваяСтраница = Элементы.ГруппаСтраницаРедактированияЗаголовковЗапросаТекстом;
	КонецЕсли;

	Элементы.ГруппаСраницыРедактированияЗаголовковЗапроса.ТекущаяСтраница = НоваяСтраница;

	//Теперь нужно заполнить заголовки на новой странице по старой странице
	Если TableHeadersEditor Тогда
		ЗаполнитьТаблицуЗаголовковПоСтроке(HeadersString);
	Иначе
		HeadersString = UT_CommonClientServer.GetHTTPHeadersString(ТаблицаЗаголовковЗапроса);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДанныеТекущегоЗапросаПоИстории(ВыбраннаяСтрока)

//Нужно установить текущую строку в параметры выполнения запроса
	ТекДанные = ИсторияЗапросов.НайтиПоИдентификатору(ВыбраннаяСтрока);

	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	HTTPRequest = ТекДанные.HTTPФункция;
	RequestURL = ТекДанные.URL;
	ЗаголовкиСтрока = ТекДанные.ЗаголовкиЗапроса;
	RequestBody = ТекДанные.ТелоЗапросаСтрока;
	RequestBodyEncoding = ТекДанные.КодировкаТелаЗапроса;
	UseBOM = ТекДанные.BOM;
	RequestBodyFormat = ТекДанные.RequestBodyFormat;
	ВидТелаЗапросаПриИзменении(Элементы.ВидТелаЗапроса);
	RequestBodyFileName = ТекДанные.ТелоЗапросаИмяФайла;
	Timeout=ТекДанные.Таймаут;

	UseProxy = ТекДанные.ИспользоватьПрокси;
	ProxyServer = ТекДанные.ПроксиСервер;
	ProxyPort = ТекДанные.ПроксиПорт;
	ProxyUser = ТекДанные.ПроксиПользователь;
	ProxyPassword = ТекДанные.ПроксиПароль;
	OSAuthentificationProxy = ТекДанные.ПроксиАутентификацияОС;

	Если ЭтоАдресВременногоХранилища(ТекДанные.ТелоЗапросаАдресДвоичныхДанных) Тогда
		ДвоичныеДанныеТелаЗапроса = ПолучитьИзВременногоХранилища(ТекДанные.ТелоЗапросаАдресДвоичныхДанных);
		RequestBodyBinaryDataString = Строка(ДвоичныеДанныеТелаЗапроса);
		Если ТипЗнч(ДвоичныеДанныеТелаЗапроса) = Тип("ДвоичныеДанные") Тогда
			RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(ДвоичныеДанныеТелаЗапроса,
				RequestBodyBinaryDataAddress);
		КонецЕсли;
	КонецЕсли;

	ТаблицаЗаголовковЗапроса.Очистить();
	Если TableHeadersEditor Тогда
		ЗаполнитьТаблицуЗаголовковПоСтроке(ЗаголовкиСтрока);
	КонецЕсли;

	Элементы.ГруппаСтраницыЗапроса.ТекущаяСтраница = Элементы.ГруппаЗапрос;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПоДаннымОтладки(АдресДанныхОтладки)
	ДанныеДляОтладки = ПолучитьИзВременногоХранилища(АдресДанныхОтладки);

	RequestURL = "";
	Если Не ЗначениеЗаполнено(ДанныеДляОтладки.Протокол) Тогда
		RequestURL = "http";
	Иначе
		RequestURL = ДанныеДляОтладки.Протокол;
	КонецЕсли;

	RequestURL = RequestURL + "://" + ДанныеДляОтладки.АдресСервера;

	Если ЗначениеЗаполнено(ДанныеДляОтладки.Порт) Тогда
		RequestURL = RequestURL + ":" + Формат(ДанныеДляОтладки.Порт, "ЧГ=0;");
	КонецЕсли;

	Если Не СтрНачинаетсяС(ДанныеДляОтладки.Запрос, "/") Тогда
		RequestURL = RequestURL + "/";
	КонецЕсли;

	RequestURL = RequestURL + ДанныеДляОтладки.Запрос;
	TableHeadersEditor = Истина;

	Элементы.ГруппаСраницыРедактированияЗаголовковЗапроса.ТекущаяСтраница = Элементы.ГруппаСтраницаРедактированияЗаголовковЗапросаТаблицей;

	Заголовки = ДанныеДляОтладки.Заголовки;

	//Удаляем неиспользуемые символы из строки заголовков
	ПозицияСимвола = НайтиНедопустимыеСимволыXML(Заголовки);
	Пока ПозицияСимвола > 0 Цикл
		Если ПозицияСимвола = 1 Тогда
			Заголовки = Сред(Заголовки, 2);
		ИначеЕсли ПозицияСимвола = СтрДлина(Заголовки) Тогда
			Заголовки = Лев(Заголовки, СтрДлина(Заголовки) - 1);
		Иначе
			НовыеЗаголовки = Лев(Заголовки, ПозицияСимвола - 1) + Сред(Заголовки, ПозицияСимвола + 1);
			Заголовки = НовыеЗаголовки;
		КонецЕсли;

		ПозицияСимвола = НайтиНедопустимыеСимволыXML(Заголовки);
	КонецЦикла;

	ЗаполнитьТаблицуЗаголовковПоСтроке(Заголовки);

	Если ДанныеДляОтладки.ТелоЗапроса = Неопределено Тогда
		RequestBody = "";
	Иначе
		RequestBody = ДанныеДляОтладки.ТелоЗапроса;
	КонецЕсли;

	Если ДанныеДляОтладки.Свойство("ДвоичныеДанныеТела") Тогда
		Если ТипЗнч(ДанныеДляОтладки.ДвоичныеДанныеТела) = Тип("ДвоичныеДанные") Тогда
			RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(ДанныеДляОтладки.ДвоичныеДанныеТела,
				RequestBodyBinaryDataAddress);
			RequestBodyBinaryDataString = ДанныеДляОтладки.ДвоичныеДанныеТелаСтрокой;
		КонецЕсли;
	КонецЕсли;
	Если ДанныеДляОтладки.Свойство("ИмяФайлаЗапроса") Тогда
		RequestBodyFileName = ДанныеДляОтладки.ИмяФайлаЗапроса;
	КонецЕсли;

	Если ЗначениеЗаполнено(ДанныеДляОтладки.ПроксиСервер) Тогда
		UseProxy = Истина;

		ProxyServer = ДанныеДляОтладки.ПроксиСервер;
		ProxyPort = ДанныеДляОтладки.ПроксиПорт;
		ProxyUser = ДанныеДляОтладки.ПроксиПользователь;
		ProxyPassword = ДанныеДляОтладки.ПроксиПароль;
		OSAuthentificationProxy = ДанныеДляОтладки.ИспользоватьАутентификациюОС;
	Иначе
		UseProxy = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьФорму()
	HTTPRequest = "GET";
	RequestBodyEncoding = "Авто";
	RequestBodyFormat = "Строкой";
	Timeout=30;
	RequestBodyFileAddress = ПоместитьВоВременноеХранилище(Новый Структура, УникальныйИдентификатор);
	RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура ИнициализироватьЗапрос()
	HTTPRequest = "GET";
	RequestBodyEncoding = "Авто";
	RequestBodyFormat = "Строкой";
	RequestBodyFileAddress = ПоместитьВоВременноеХранилище(Новый Структура, УникальныйИдентификатор);
	RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
	RequestURL = "";
	UseBOM = 0;

	//прокси
	UseProxy = Ложь;
	ProxyServer = "";
	ProxyPort = 0;
	ProxyUser = "";
	ProxyPassword = "";
	OSAuthentificationProxy = Ложь;

	HeadersString = "";
	ТаблицаЗаголовковЗапроса.Очистить();

	RequestBody = "";
	RequestBodyBinaryDataString = "";
	RequestBodyFileName = "";
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоЗапросаВРедактореJSONЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestBody=Результат;
КонецПроцедуры

#EndRegion