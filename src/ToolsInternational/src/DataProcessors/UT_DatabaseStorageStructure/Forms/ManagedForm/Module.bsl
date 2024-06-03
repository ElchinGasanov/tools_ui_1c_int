#Область ОписаниеПеременных

#EndRegion

#Область ОбработчикиСобытийФор

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	MethodsForObtainingDatabaseTablesSize = MethodsForObtainingDatabaseTablesSize();

	Элементы.СпособОпределенияРазмераТаблицы.СписокВыбора.Clear();

	ДоступныеСпособы = AvailableMethodsOfObtainingDatabaseSize(MethodsForObtainingDatabaseTablesSize);

	For Each ТекСпособ Из ДоступныеСпособы Do

		Элементы.СпособОпределенияРазмераТаблицы.СписокВыбора.Добавить(ТекСпособ.Имя, ТекСпособ.Представление);
	EndDo;

	MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.None.Имя;
	OnChangeMethodOfDefiningSizeOfTablesAtServer();

	UnitsOfMeasurementSizeTables = UnitsOfMeasurementSizeTables();
	Элементы.TableSizeUnit.СписокВыбора.Clear();
	For Each КлючЗначение Из UnitsOfMeasurementSizeTables Do
		Элементы.TableSizeUnit.СписокВыбора.Добавить(КлючЗначение.Значение);
	EndDo;
	TableSizeUnit = UnitsOfMeasurementSizeTables.KB;
	SetColumnHeadersSizeTables();

	АдресСтруктурыБазы = ПоместитьВоВременноеХранилище(Undefined, УникальныйИдентификатор);
	ЗаполнитьСтруктуруХраненияБазы();
	УИ_ОбщегоНазначения.ФормаИнструментаПриСозданииНаСервере(ЭтотОбъект, Отказ, СтандартнаяОбработка);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	Если УИ_ОбщегоНазначенияКлиентСервер.ЭтоWindows() Then
		Элементы.ПутьКУтилитеSQLPSQL.ПодсказкаВвода = "psql.exe";
		Элементы.ПутьКУтилитеSQLSQLCMD.ПодсказкаВвода = "sqlcmd.exe";
	Иначе
		Элементы.ПутьКУтилитеSQLPSQL.ПодсказкаВвода = "psql";
		Элементы.ПутьКУтилитеSQLSQLCMD.ПодсказкаВвода = "sqlcmd";
	EndIf;
EndProcedure

&AtServer
Procedure OnLoadDataFromSettingsAtServer(Settings)
	OnChangeMethodOfDefiningSizeOfTablesAtServer();
EndProcedure
#EndRegion

#Область ОбработчикиСобытийЭлементовШапкиФормы

&AtClient
Procedure IncludingFieldsOnChange(Item)
	FindByStorageTableName();
EndProcedure

&AtClient
Procedure ExactMapOnChange(Item)
	FindByStorageTableName();
EndProcedure

&AtClient
Procedure FilterOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure
&AtClient
Procedure MethodForDeterminingTableSizeOnChange(Item)
	OnChangeMethodOfDefiningSizeOfTablesAtServer();
EndProcedure

&AtClient
Procedure TableSizeUnitOnChange(Item)
	SetColumnHeadersSizeTables();
	OutputTableSaziesIntoResultTable();
EndProcedure
&AtClient
Procedure SQLUtilityCMDPathStartChoice(Item, ChoiceData, StandardProcessing)
	ПутьКУтилитеSQLНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка);
EndProcedure

&AtClient
Procedure SQLUtilityPathStartChoice(Item, ChoiceData, StandardProcessing)
	ПутьКУтилитеSQLНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка);
EndProcedure
#EndRegion

#Область ОбработчикиСобытийЭлементовТаблицыФормыФильтрПоНазначениям

&AtClient
Procedure FilterByPurposiesOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure

#EndRegion

#Область ОбработчикиСобытийЭлементовТаблицыФормыFilterByTypesOfMetadataObjects

&AtClient
Procedure FilterByTypesOfMetadataObjectsOnChange(Item)
	SetFiltersOnResultTable();
EndProcedure

#EndRegion

#Область ОбработчикиКомандФормы
&AtClient
Procedure UpdateDatabaseTableSize(Command)
	ЗаполнитьТаблицуРазмеровТаблицБазы();
EndProcedure
&AtClient
Procedure SetFilter(Command)

	FindByStorageTableName();

EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Procedure ПутьКУтилитеSQLНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	ОписаниеФайла = УИ_ОбщегоНазначенияКлиент.ПустаяСтруктураОписанияВыбираемогоФайла();
	ОписаниеФайла.ИмяФайла = ПутьКУтилитеSQL;

	Если УИ_ОбщегоНазначенияКлиентСервер.ЭтоWindows() Then
		УИ_ОбщегоНазначенияКлиент.ДобавитьФорматВОписаниеФайлаСохранения(ОписаниеФайла,
																		 "Исполняемый файл утилиты (*.exe)",
																		 "exe",
																		 "*.exe");
	EndIf;

	УИ_ОбщегоНазначенияКлиент.ПолеФормыИмяФайлаНачалоВыбора(ОписаниеФайла,
															Элемент,
															ДанныеВыбора,
															СтандартнаяОбработка,
															РежимДиалогаВыбораФайла.Открытие,
															Новый ОписаниеОповещения("ПутьКУтилитеSQLНачалоВыбораЗавершение",
		ЭтотОбъект));

EndProcedure

&НаКлиенте
Procedure ПутьКУтилитеSQLНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	Если ВыбранныеФайлы = Undefined Then
		Return;
	EndIf;
	Если ВыбранныеФайлы.Количество() = 0 Then
		Return;
	EndIf;

	ПутьКУтилитеSQL = ВыбранныеФайлы[0];
EndProcedure

&AtServer
Procedure OutputTableSaziesIntoResultTable()

	Делитель = 1;
	Если TableSizeUnit = UnitsOfMeasurementSizeTables().MB Then
		Делитель = 1024;
	EndIf;
	For Each СтрокаТаблицы Из Результат Do
		СтруктураПоиска = New Structure;
		СтруктураПоиска.Вставить("ИмяТаблицы", НРег(СтрокаТаблицы.StorageTableName));

		СтрокаТаблицы.РазмерДанных = 0;
		СтрокаТаблицы.РазмерИндексов =  0;
		СтрокаТаблицы.Зарезервировано = 0;
		СтрокаТаблицы.Свободно = 0;
		СтрокаТаблицы.КоличествоСтрок = 0;

		FounRows = BaseTableDimensions.НайтиСтроки(СтруктураПоиска);
		For Each Стр Из FounRows Do
			СтрокаТаблицы.РазмерДанных = СтрокаТаблицы.РазмерДанных + Стр.РазмерДанных;
			СтрокаТаблицы.РазмерИндексов = СтрокаТаблицы.РазмерИндексов + Стр.РазмерИндексов;
			СтрокаТаблицы.Зарезервировано = СтрокаТаблицы.Зарезервировано + Стр.Зарезервировано;
			СтрокаТаблицы.Свободно = СтрокаТаблицы.Свободно + Стр.Свободно;
			СтрокаТаблицы.КоличествоСтрок = СтрокаТаблицы.КоличествоСтрок + Стр.КоличествоСтрок;
		EndDo;
		Если Делитель <> 1 Then
			СтрокаТаблицы.РазмерДанных = СтрокаТаблицы.РазмерДанных / Делитель;
			СтрокаТаблицы.РазмерИндексов = СтрокаТаблицы.РазмерИндексов / Делитель;
			СтрокаТаблицы.Зарезервировано = СтрокаТаблицы.Зарезервировано / Делитель;
			СтрокаТаблицы.Свободно = СтрокаТаблицы.Свободно / Делитель;
		EndIf;
	EndDo;
EndProcedure

&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазы()
	Если MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.Platform.Имя Then
		ЗаполнитьТаблицуРазмеровТаблицБазыДанныхПлатформеннымМетодом();
		OutputTableSaziesIntoResultTable();
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Имя Then
		УИ_ОбщегоНазначенияКлиент.ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеПодключенияРасширенияРаботыСФайлами",
			ЭтотОбъект));

	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.sqlcmd.Имя Then
		УИ_ОбщегоНазначенияКлиент.ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеПодключенияРасширенияРаботыСФайлами",
			ЭтотОбъект));
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.tool1cd.Имя Then 
		ЗаполнитьТаблицуРазмеровТаблицБазыДанныхЧерезУтилитуTOOL1CD();
		OutputTableSaziesIntoResultTable();
	EndIf;
EndProcedure

&AtServer
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыДанныхПлатформеннымМетодом()
	BaseTableDimensions.Clear();
	BaseStructure = ПолучитьИзВременногоХранилища(АдресСтруктурыБазы);

	For Each СтрокаСтруктуры Из BaseStructure Do
		Если НРег(СтрокаСтруктуры.Purpose) <> "основная" Then
			Продолжить;
		EndIf;
		Если Не ValueIsFilled(СтрокаСтруктуры.Metadata) Then
			Продолжить;
		EndIf;

		NewRow = BaseTableDimensions.Добавить();
		NewRow.TableName = НРег(СтрокаСтруктуры.StorageTableName);

		МассивИмен = New Array;
		МассивИмен.Добавить(СтрокаСтруктуры.Metadata);

		Попытка
			//Появилось только в 8.3.15. На старых платформах не будет даже запускаться без такого вызова
			РазмерДанных = УИ_ОбщегоНазначения.ВычислитьВБезопасномРежиме("ПолучитьРазмерДанныхБазыДанных(,Параметры)",
																		  МассивИмен);
		Исключение
			РазмерДанных = 0;
		КонецПопытки;
		NewRow.РазмерДанных = РазмерДанных / 1024;

	EndDo;
EndProcedure

&AtServer
Procedure ОбеспечитьНаличиеИсполняемогоФайлаTool1CDНаСервере(КаталогTool1CD, ИсполняемыйФайлTool1CD)
	ФайлИсполняемый = Новый Файл(ИсполняемыйФайлTool1CD);
	Если ФайлИсполняемый.Существует() Then
		Return;
	EndIf;
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("zip");
	
	ДвоичныеДанныеМакета = ПолучитьОбщийМакет("УИ_ctool1cd");
	ДвоичныеДанныеМакета.Записать(ИмяВременногоФайла);
	
	ЧтениеZIP = Новый ЧтениеZipФайла(ИмяВременногоФайла);
	ЧтениеZIP.ИзвлечьВсе(КаталогTool1CD, РежимВосстановленияПутейФайловZIP.Восстанавливать);
	ЧтениеZIP.Закрыть();
	
	УдалитьФайлы(ИмяВременногоФайла);
EndProcedure

&AtServerNoContext
Function ИмяФайлаБазыДанныхИзСтрокиСоединения()
	СтрокаСоединения = СтрокаСоединенияИнформационнойБазы();
	ЧастиСтрокиСоединения = StrSplit(СтрокаСоединения, ";");

	КаталогБазыДанных = "";

	For Each ТекЧасть Из ЧастиСтрокиСоединения Do
		Если Не ValueIsFilled(ТекЧасть) Then
			Продолжить;
		EndIf;
		
		КлючЗначение = StrSplit(ТекЧасть, "=");
		Если КлючЗначение.Количество() <> 2 Then
			Продолжить;
		EndIf;
		
		Если НРег(КлючЗначение[0])="file" Then
			КаталогБазыДанных = Mid(КлючЗначение[1],2);
			КаталогБазыДанных = Left(КаталогБазыДанных, СтрДлина(КаталогБазыДанных)-1);
			Break;
		EndIf;
	EndDo;
	Если Не ValueIsFilled(КаталогБазыДанных) Then
		Return "";
	EndIf;
	
	Return УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогБазыДанных, "1Cv8.1CD");
EndFunction

&AtServer
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыДанныхЧерезУтилитуTOOL1CD()
	BaseTableDimensions.Clear();
	
	КаталогTool1CD = УИ_ОбщегоНазначения.КаталогФайловTool1CDНаСервере();

	Если УИ_ОбщегоНазначенияКлиентСервер.ЭтоWindows() Then
		ИсполняемыйФайлTool1CD = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогTool1CD,
																				"windows",
																				"ctool1cd.exe");
	Иначе
		ИсполняемыйФайлTool1CD = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(КаталогTool1CD, "linux", "ctool1cd");
	EndIf;
	ОбеспечитьНаличиеИсполняемогоФайлаTool1CDНаСервере(КаталогTool1CD, ИсполняемыйФайлTool1CD);
	
	ИмяФайлаРезультата = ПолучитьИмяВременногоФайла("csv");
	ИмяФайлаЛогов = ПолучитьИмяВременногоФайла("txt");
	ИмяФайлаБазыДанных = ИмяФайлаБазыДанныхИзСтрокиСоединения();

	СтрокаЗапуска = СтрШаблон("""%1"" -ne -sts ""%2"" -q ""%3"" -l ""%4""",
							  ИсполняемыйФайлTool1CD,
							  ИмяФайлаРезультата,
							  ИмяФайлаБазыДанных,
							  ИмяФайлаЛогов);

	КодReturnа = Undefined;
	ЗапуститьПриложение(СтрокаЗапуска, , True, КодReturnа);

	Если КодReturnа <> 0 Then
		ТекстовыйДокументРезультата = Новый ТекстовыйДокумент();
		ТекстовыйДокументРезультата.Прочитать(ИмяФайлаЛогов, КодировкаТекста.UTF8);
	Иначе
		ТекстовыйДокументРезультата = Новый ТекстовыйДокумент();
		ТекстовыйДокументРезультата.Прочитать(ИмяФайлаРезультата, КодировкаТекста.UTF8);
	EndIf;

	УдалитьФайлы(ИмяФайлаРезультата);
	УдалитьФайлы(ИмяФайлаЛогов);

	Если КодReturnа <> 0 Then
		УИ_ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстовыйДокументРезультата.ПолучитьТекст());
		Return;
	EndIf;

	Если ТекстовыйДокументРезультата.КоличествоСтрок() <=1 Then
		Return;
	EndIf;
	
	ИменаКолонок = StrSplit(ТекстовыйДокументРезультата.ПолучитьСтроку(1), "|");
	
	Для НомерСтроки = 2 По ТекстовыйДокументРезультата.КоличествоСтрок() Do
		ТекущаяСтрока = ТекстовыйДокументРезультата.ПолучитьСтроку(НомерСтроки);
		Если Не ValueIsFilled(ТекущаяСтрока) Then
			Продолжить;
		EndIf;
		
		МассивСтроки = StrSplit(ТекущаяСтрока, "|");
		
		ДанныеСтроки = New Structure;
		Для ном = 0 По ИменаКолонок.Количество()-1 Do
			ДанныеСтроки.Вставить(ИменаКолонок[ном], МассивСтроки[ном]);
		EndDo;

		NewRow = BaseTableDimensions.Добавить();
		NewRow.TableName = НРег(ДанныеСтроки.table_name);
		NewRow.КоличествоСтрок = Макс(УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.records_count), 0);
		NewRow.РазмерДанных = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.data_size)
								   / 1024
								   + УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.blob_size)
									 / 1024;
		NewRow.РазмерИндексов = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.index_size) / 1024;
		NewRow.Зарезервировано = NewRow.РазмерДанных + NewRow.РазмерИндексов;
		NewRow.Свободно = 0;
	EndDo;
	
EndProcedure



&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеПодключенияРасширенияРаботыСФайлами(Подключено, ДополнительныеПараметры) Экспорт
	Если Не Подключено Then
		Return;
	EndIf;
	ФайловыеПеременные = УИ_ОбщегоНазначенияКлиент.СтруктураФайловыхПеременныхСеанса();
	ИмяКаталогаДляЗапроса = УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ФайловыеПеременные.КаталогВременныхФайлов,
																		   УИ_ОбщегоНазначенияКлиентСервер.СлучайноеИмяФайла());
	
	ДополнительныеПараметрыОповещения = New Structure;
	ДополнительныеПараметрыОповещения.Вставить("ИмяКаталогаДляЗапроса", ИмяКаталогаДляЗапроса);
	Если УИ_ОбщегоНазначенияКлиентСервер.ЭтоWindows() Then
		ДополнительныеПараметрыОповещения.Вставить("КодировкаВспомогательныхФайлов", "windows-1251");
	Иначе
		ДополнительныеПараметрыОповещения.Вставить("КодировкаВспомогательныхФайлов", "utf-8");
	EndIf;

	УИ_ОбщегоНазначенияКлиент.НачатьОбеспечениеКаталога(ИмяКаталогаДляЗапроса,
														Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеОбеспеченияКаталога",
		ЭтотОбъект, ДополнительныеПараметрыОповещения));
EndProcedure

&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеОбеспеченияКаталога(Успешно, ДополнительныеПараметры) Экспорт
	Если Не Успешно Then
		Return;
	EndIf;
	
	Если MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Имя Then
		ТекстЗапроса =
		"SELECT
		|tablename AS table_name,
		|pg_class.reltuples as records_count,
		|pg_total_relation_size(schemaname||'.'||tablename) / 1024 AS total_usage_kb,
		|pg_table_size(schemaname||'.'||tablename) / 1024 AS table_usage_kb,
		|pg_indexes_size(schemaname||'.'||tablename) / 1024 as index_usage_kb,
		|0 as table_free_kb
		|FROM pg_catalog.pg_tables, pg_catalog.pg_class
		|where pg_tables.tablename = pg_class.relname  
		|and schemaname = 'public';
		|";
		
		ЕстьВозможнотьПолучитьФайлЛоговЗапроса = True;
	Иначе
		ТекстЗапроса =
		"CREATE TABLE #t(table_name varchar(255), records_count varchar(255), total_usage_kb varchar(255), table_usage_kb varchar(255), index_usage_kb varchar(255), table_free_kb varchar(255));
		|INSERT INTO #t
		|exec sp_msforeachtable N'exec sp_spaceused ''?''';
		|SELECT * FROM #t;
		|DROP TABLE #t
		|";

		ЕстьВозможнотьПолучитьФайлЛоговЗапроса = False;
	EndIf;

	ДополнительныеПараметры.Вставить("ИмяФайлаЗапроса",
									 УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ИмяКаталогаДляЗапроса,
																					УИ_ОбщегоНазначенияКлиентСервер.СлучайноеИмяФайла("sql",
																																	  "req")));
	ДополнительныеПараметры.Вставить("ИмяФайлаРезультата",
									 УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ИмяКаталогаДляЗапроса,
																					УИ_ОбщегоНазначенияКлиентСервер.СлучайноеИмяФайла("csv",
																																	  "res")));
	Если ЕстьВозможнотьПолучитьФайлЛоговЗапроса Then
		ДополнительныеПараметры.Вставить("ИмяФайлаЛога",
										 УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ИмяКаталогаДляЗапроса,
																						УИ_ОбщегоНазначенияКлиентСервер.СлучайноеИмяФайла("txt",
																																		  "log")));
	EndIf;
	
	Текст = Новый ТекстовыйДокумент;
	Текст.УстановитьТекст(ТекстЗапроса);
	Текст.НачатьЗапись(Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеЗаписиФайлаЗапроса",
		ЭтотОбъект, ДополнительныеПараметры),
					   ДополнительныеПараметры.ИмяФайлаЗапроса,
					   ДополнительныеПараметры.КодировкаВспомогательныхФайлов);

EndProcedure

&НаКлиенте
Function СтрокаЗапускаPsql(ДопПараметры)
	Если Не ValueIsFilled(ПутьКУтилитеSQL) Then
		ИмяЗапускаемогоФайла = "psql";
	Иначе
		ИмяЗапускаемогоФайла = ПутьКУтилитеSQL;
	EndIf;

	Return СтрШаблон("""%1"" --host=%2 --dbname=%3 --username=%4 --csv --file=""%5"" --output=""%6"" --log-file=""%7""",
									ИмяЗапускаемогоФайла,
									СерверSQL,
									БазаДанныхSQL,
									ПользовательSQL,
									ДопПараметры.ИмяФайлаЗапроса,
									ДопПараметры.ИмяФайлаРезультата,
									ДопПараметры.ИмяФайлаЛога);
EndFunction

&НаКлиенте
Function СтрокаЗапускаSqlcmd(ДопПараметры)
	Если Не ValueIsFilled(ПутьКУтилитеSQL) Then
		ИмяЗапускаемогоФайла = "sqlcmd";
	Иначе
		ИмяЗапускаемогоФайла = ПутьКУтилитеSQL;
	EndIf;

	Return СтрШаблон("""%1"" -S %2 -U %3 -P%4  -d %5 -C -i""%6"" -o ""%7"" -u -I -s ""|"" -W -b",
					  ИмяЗапускаемогоФайла,
					  СерверSQL,
					  ПользовательSQL,
					  ПарольSQL,
					  БазаДанныхSQL,
					  ДопПараметры.ИмяФайлаЗапроса,
					  ДопПараметры.ИмяФайлаРезультата);

EndFunction

&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеЗаписиФайлаЗапроса(Результат, ДополнительныеПараметры) Экспорт
	Если Результат <> True Then
		УИ_ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось записать файл с текстом запроса");
		Return;
	EndIf;

	ЗапускатьЧерезСкрипт = False;
	Если MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Имя Then
		Если УИ_ОбщегоНазначенияКлиентСервер.ЭтоWindows() Then
			ЗапускатьЧерезСкрипт = True;
			ТекстСкриптаЗапуска = СтрШаблон("chcp 65001
											|set PGPASSWORD=%1
											|%2", ПарольSQL, СтрокаЗапускаPsql(ДополнительныеПараметры));
		Иначе
			ТекстСкриптаЗапуска = СтрШаблон("echo ""%1"" | %2", ПарольSQL, СтрокаЗапускаPsql(ДополнительныеПараметры));
		EndIf;
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.sqlcmd.Имя Then
		ТекстСкриптаЗапуска = СтрокаЗапускаSqlcmd(ДополнительныеПараметры);
	EndIf;

	Если ЗапускатьЧерезСкрипт Then
		ДополнительныеПараметры.Вставить("ЗапускаемыйСкрипт",
										 УИ_ОбщегоНазначенияКлиентСервер.ОбъединитьПути(ДополнительныеПараметры.ИмяКаталогаДляЗапроса,
																						УИ_ОбщегоНазначенияКлиентСервер.СлучайноеИмяФайла("bat",
																																		  "run")));
		
		ТекстСкриптаДляЗаписи = Новый ТекстовыйДокумент;
		ТекстСкриптаДляЗаписи.УстановитьТекст(ТекстСкриптаЗапуска);
		ТекстСкриптаДляЗаписи.НачатьЗапись(Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеСохраненияСкриптаЗапуска",
			ЭтотОбъект, ДополнительныеПараметры),
										   ДополнительныеПараметры.ЗапускаемыйСкрипт,
										   ДополнительныеПараметры.КодировкаВспомогательныхФайлов);
	Иначе
	
		ДополнительныеПараметры.Вставить("ЗапускаемыйСкрипт", ТекстСкриптаЗапуска);
		ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеСохраненияСкриптаЗапуска(True,
																							  ДополнительныеПараметры);
	EndIf;
	

EndProcedure

&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеСохраненияСкриптаЗапуска(Результат, ДополнительныеПараметры) Экспорт
	Если Результат <> True Then
		Return;
	EndIf;
	НачатьЗапускПриложения(Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеВыполненияКоманды",
		ЭтотОбъект, ДополнительныеПараметры), ДополнительныеПараметры.ЗапускаемыйСкрипт, , True);
	
EndProcedure

&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеВыполненияКоманды(КодReturnа, ДополнительныеПараметры) Экспорт
	ТекстРезультата = Новый ТекстовыйДокумент();
	
	ДополнительныеПараметры.Вставить("КодReturnа", КодReturnа);
	ДополнительныеПараметры.Вставить("ТекстовыйДокументРезультата", ТекстРезультата);
	
	ИмяФайлаЧтения =  ДополнительныеПараметры.ИмяФайлаРезультата;
	Если КодReturnа <> 0 И ДополнительныеПараметры.Свойство("ИмяФайлаЛога") Then
		ИмяФайлаЧтения = ДополнительныеПараметры.ИмяФайлаЛога;
	EndIf;

	ТекстРезультата.НачатьЧтение(Новый ОписаниеОповещения("ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеЧтенияРезультатаВыполнения",
		ЭтотОбъект, ДополнительныеПараметры), ИмяФайлаЧтения);

EndProcedure

&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыЧерезКонсольнуюУтилитуПослеЧтенияРезультатаВыполнения(ДополнительныеПараметры) Экспорт

	If ДополнительныеПараметры.КодReturnа <> 0 Then
		УИ_ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ДополнительныеПараметры.ТекстовыйДокументРезультата.ПолучитьТекст());
		BaseTableDimensions.Clear();
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.psql.Имя Then
		ЗаполнитьТаблицуРазмеровТаблицБазыДанныхИзСтокиРезультатаPSQL(ДополнительныеПараметры.ТекстовыйДокументРезультата);
	ElsIf MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.sqlcmd.Имя Then
		ЗаполнитьТаблицуРазмеровТаблицБазыДанныхИзСтокиРезультатаSQLCMD(ДополнительныеПараметры.ТекстовыйДокументРезультата);
	EndIf;
		
	OutputTableSaziesIntoResultTable();
	
	НачатьУдалениеФайлов(Новый ОписаниеОповещения(), ДополнительныеПараметры.ИмяКаталогаДляЗапроса);

EndProcedure

// Заполнить таблицу размеров таблиц базы данных из стоки результата PSQL.
// 
// Parameters:
//  ТекстовыйДокументРезультата -ТекстовыйДокумент-Текстовый документ результата
&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыДанныхИзСтокиРезультатаPSQL(ТекстовыйДокументРезультата)
	BaseTableDimensions.Clear();
	
	Если ТекстовыйДокументРезультата.КоличествоСтрок() <=1 Then
		Return;
	EndIf;
	
	ИменаКолонок = StrSplit(ТекстовыйДокументРезультата.ПолучитьСтроку(1), ",");
	
	Для НомерСтроки = 2 По ТекстовыйДокументРезультата.КоличествоСтрок() Do
		ТекущаяСтрока = ТекстовыйДокументРезультата.ПолучитьСтроку(НомерСтроки);
		Если Не ValueIsFilled(ТекущаяСтрока) Then
			Продолжить;
		EndIf;
		
		МассивСтроки = StrSplit(ТекущаяСтрока, ",");
		
		ДанныеСтроки = New Structure;
		Для ном = 0 По ИменаКолонок.Количество()-1 Do
			ДанныеСтроки.Вставить(ИменаКолонок[ном], МассивСтроки[ном]);
		EndDo;

		NewRow = BaseTableDimensions.Добавить();
		NewRow.TableName = НРег(ДанныеСтроки.table_name);
		NewRow.КоличествоСтрок = Макс(УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.records_count), 0);
		NewRow.РазмерДанных = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.table_usage_kb);
		NewRow.РазмерИндексов = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.index_usage_kb);
		NewRow.Зарезервировано = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.total_usage_kb);
		NewRow.Свободно = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.table_free_kb);
	EndDo;
EndProcedure

// Заполнить таблицу размеров таблиц базы данных из стоки результата PSQL.
// 
// Parameters:
//  ТекстовыйДокументРезультата -ТекстовыйДокумент-Текстовый документ результата
&НаКлиенте
Procedure ЗаполнитьТаблицуРазмеровТаблицБазыДанныхИзСтокиРезультатаSQLCMD(ТекстовыйДокументРезультата)
	BaseTableDimensions.Clear();
	
	Если ТекстовыйДокументРезультата.КоличествоСтрок() <=1 Then
		Return;
	EndIf;
	
	НомерСтрокиНачалаТаблицы = 0;
	Для НомерСтроки = 1 По ТекстовыйДокументРезультата.КоличествоСтрок() Do
		ТекущаяСтрока = ТекстовыйДокументРезультата.ПолучитьСтроку(НомерСтроки);
			
		ИменаКолонок = StrSplit(ТекущаяСтрока, "|");
		Если ИменаКолонок.Количество() > 1 Then
			НомерСтрокиНачалаТаблицы = НомерСтроки;
			Break;
		EndIf;
	EndDo;
	
	Если Не ValueIsFilled(НомерСтрокиНачалаТаблицы) Then
		Return;
	EndIf;
	
	Для НомерСтроки = НомерСтрокиНачалаТаблицы+2 По ТекстовыйДокументРезультата.КоличествоСтрок() Do
		ТекущаяСтрока = ТекстовыйДокументРезультата.ПолучитьСтроку(НомерСтроки);
		Если Не ValueIsFilled(ТекущаяСтрока) Then
			Break;
		EndIf;
		
		МассивСтроки = StrSplit(ТекущаяСтрока, "|");
		
		ДанныеСтроки = New Structure;
		Для ном = 0 По ИменаКолонок.Количество()-1 Do
			ЗначениеКолонки = СтрЗаменить(МассивСтроки[ном],"KB","");
			ЗначениеКолонки = СтрЗаменить(ЗначениеКолонки, " ", "");
			
			ДанныеСтроки.Вставить(ИменаКолонок[ном], ЗначениеКолонки);
		EndDo;

		NewRow = BaseTableDimensions.Добавить();
		NewRow.TableName = НРег(ДанныеСтроки.table_name);
		NewRow.КоличествоСтрок = Макс(УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.records_count), 0);
		NewRow.РазмерДанных = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.table_usage_kb);
		NewRow.РазмерИндексов = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.index_usage_kb);
		NewRow.Зарезервировано = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.total_usage_kb);
		NewRow.Свободно = УИ_СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ДанныеСтроки.table_free_kb);
	EndDo;
EndProcedure

&AtServer
Procedure ЗаполнитьСтруктуруХраненияБазы()

	BaseStructure = ПолучитьИзВременногоХранилища(АдресСтруктурыБазы);

	Если BaseStructure = Undefined Then

		BaseStructure = ПолучитьСтруктуруХраненияБазыДанных(,True);
		ПоместитьВоВременноеХранилище(BaseStructure, АдресСтруктурыБазы);

	EndIf;

	FillResultTable(BaseStructure);
EndProcedure

&AtServer
Procedure FillResultTable(BaseStructure, FounRows = Undefined)
	Result.Clear();
	FilterByPurposies.Clear();
	FilterByTypesOfMetadataObjects.Clear();

	If FounRows = Undefined Then
		RowsForResult = BaseStructure;
	Else
		RowsForResult = FounRows;
	EndIf;

	DisplaySizies = MethodForDeterminingTableSize <> MethodsForObtainingDatabaseTablesSize.None.Name;

	For Each Row In RowsForResult Do
		NewRow = Result.Add();
		NewRow.TableName = Row.TableName;
		If Not ValueIsFilled(NewRow.TableName) Then
			NewRow.TableName = Row.Metadata;
		EndIf;
		NewRow.Metadata = Row.Metadata;
		NewRow.Purpose = Row.Purpose;
		NewRow.StorageTableName = Row.StorageTableName;
		NewRow.Found = True;
		NewRow.MetadataObjectType = MetadataObjectTypeFromMetadataName(Row.Metadata);

		For Each Field In Row.Fields Do
			NewFieldsRow = NewRow.Fields.Add();
			NewFieldsRow.StorageFieldName = Field.StorageFieldName;
			NewFieldsRow.FieldName = Field.FieldName;
			NewFieldsRow.Metadata = Field.Metadata;
		EndDo;

		For Each Index In Row.Indexes Do
			NewIndexRow = NewRow.Indexes.Add();
			NewIndexRow.StorageIndexName = Index.StorageIndexName;

			// Index fields
			For Each Field In Index.Fields Do
				NewIndexFieldRow = NewIndexRow.IndexFields.Add();
				NewIndexFieldRow.StorageFieldName = Field.StorageFieldName;
				NewIndexFieldRow.FieldName = Field.FieldName;
				NewIndexFieldRow.Metadata = Field.Metadata;
			EndDo;

		EndDo;
	
		If FilterByPurposies.FindByValue(NewRow.Purpose) = Undefined Then
			FilterByPurposies.Добавить(NewRow.Purpose, , True);
		EndIf;

		If FilterByTypesOfMetadataObjects.FindByValue(NewRow.MetadataObjectType) = Undefined Then
			MetedataTypePresentation = NewRow.MetadataObjectType;
			If Not ValueIsFilled(MetedataTypePresentation) Then
				MetedataTypePresentation = "<Empty>";
			EndIf;
			FilterByTypesOfMetadataObjects.Add(NewRow.MetadataObjectType,
													 MetedataTypePresentation,
													 True);
		EndIf;

	EndDo;

	If DisplaySizies Then
		OutputTableSaziesIntoResultTable();
	EndIf;
	Result.Sort("Metadata Asc,TableName Asc");
	FilterByPurposies.SortByValue();
	FilterByTypesOfMetadataObjects.SortByValue();
EndProcedure

&AtServer
Function SelectedAsFilterAllPurposies()
	AllSelected = True;
	
	For Each ListItem In FilterByPurposies Do
		Если Не ListItem.Check Then
			AllSelected = False;
			Break;
		EndIf;
	EndDo;
	
	Return AllSelected;
EndFunction


&AtServer
Function SelectedAsFilterAllTypesOfObjectsMetadata()
	AllSelected = True;
	
	For Each ListItem In FilterByTypesOfMetadataObjects Do
		Если Не ListItem.Check Then
			AllSelected = False;
			Break;
		EndIf;
	EndDo;
	
	Return AllSelected;
EndFunction

&AtServer
Function MetadataObjectTypeFromMetadataName(NameMetadata)
	NameArray = StrSplit(NameMetadata, ".");
	If NameArray.Count() = 0 Then
		Return "";
	EndIf;
	
	Return NameArray[0];
	
EndFunction

&AtServer
Procedure SetFiltersOnResultTable()
	SearchName = Upper(TrimAll(Filter));
	
	SelectedAllPurposies = SelectedAsFilterAllPurposies();
	SelectedAllTypesOfMetadataObjects = SelectedAsFilterAllTypesOfObjectsMetadata();

	If Not ValueIsFilled(SearchName) And SelectedAllPurposies And SelectedAllTypesOfMetadataObjects Then
		Items.Result.RowFilter = Undefined;
		Return;
	EndIf;
	
	If Not ExactMap And Left(SearchName, 1) = "_" Then
		SearchName = Mid(SearchName, 2);
	EndIf;
	
	For Each ResultString In Result Do
		ResultString.Found = False;
		
		If IncludingFields Then
			For Each RowField In ResultString.Fields Do
				If ExactMap Then
					If Upper(RowField.StorageFieldName) = SearchName Or Upper(RowField.FieldName) = SearchName Then
						ResultString.Found = True;
					EndIf;
				Else

					If StrFind(Upper(RowField.StorageFieldName), SearchName) > 0
						 Or StrFind(Upper(RowField.FieldName), SearchName) Then
						ResultString.Found = True;
					EndIf;
				EndIf;
			EndDo;
		EndIf;

		If ExactMap Then
			If Upper(ResultString.StorageTableName) = SearchName
				 Or Upper(ResultString.TableName) = SearchName
				 Or Upper(ResultString.Metadata) = SearchName
				 Or Upper(ResultString.Purpose) = SearchName Then
				ResultString.Found = True;
			EndIf;
		Else
			If StrFind(Upper(ResultString.StorageTableName), SearchName) > 0
				 Or StrFind(Upper(ResultString.TableName), SearchName)
				 Or StrFind(Upper(ResultString.Metadata), SearchName)
				 Or StrFind(Upper(ResultString.Purpose), SearchName) Then
				ResultString.Found = True;
			EndIf;
		EndIf;
	
		If Not SelectedAllPurposies Then
			ListItem = FilterByPurposies.FindByValue(ResultString.Purpose);
			If ListItem = Undefined Then
				ResultString.Found = False;
			EndIf; 
			
			If Not ListItem.Check Then
				ResultString.Found = False;
			EndIf;
		EndIf;
		
		If Not SelectedAllTypesOfMetadataObjects Then
			ListItem = FilterByTypesOfMetadataObjects.FindByValue(ResultString.MetadataObjectType);
			If ListItem = Undefined Then
				ResultString.Found = False;
			EndIf; 
			
			If Not ListItem.Check Then
				ResultString.Found = False;
			EndIf;
			
		EndIf;
	EndDo;

	SearchStructure = New Structure;
	SearchStructure.Insert("Found", True);
	Элементы.Result.RowFilter = New FixedStructure(SearchStructure);

EndProcedure

// Ways to get the size of database tables.
// 
// Return values:
//  Structure - Ways to get the size of database tables:
// * None - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * Platform - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * psql - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * sqlcmd - Structure - :
// ** Name - String - 
// ** Presentation - String - 
// * tool1cd - Structure - :
// ** Name - String - 
// ** Presentation - String - 
&AtServerNoContext
Function MethodsForObtainingDatabaseTablesSize()
	Methods = New Structure;
	Methods.Insert("None", NewMethodOfObtainingBaseTablesSize("None", NStr("ru = 'Не получать размеры таблиц'; en = 'Do not get table sizes'")));
	Methods.Insert("Platform", NewMethodOfObtainingBaseTablesSize("Platform",
																		NStr("ru = 'Платформенный метод ""ПолучитьРазмерДанныхБазыДанных""'; en = 'Platform method ""GetDatabaseDataSize""'")));
	
	Methods.Insert("tool1cd", NewMethodOfObtainingBaseTablesSize("tool1cd", NStr("ru = 'Утилита ""tool1cd"". Для файловых баз'; en = 'Utility ""tool1cd"". For file databases'")));

	Methods.Insert("psql", NewMethodOfObtainingBaseTablesSize("psql", NStr("ru = 'Утилита ""psql"". PostgreSQL'; en = 'Utility ""psql"". PostgreSQL'")));
	Methods.Insert("sqlcmd", NewMethodOfObtainingBaseTablesSize("sqlcmd", NStr("ru = 'Утилита ""sqlcmd"". MSSQL'; en = 'Utility ""sqlcmd"". MSSQL'")));

	Return Methods;
EndFunction

// Available methods for obtaining database size.
// 
// Parameters:
//  MethodsForObtainingDatabaseTablesSize- см. MethodsForObtainingDatabaseTablesSize
// 
// Return values:
// Array of см. NewMethodOfObtainingBaseTablesSize 
&AtServerNoContext
Function AvailableMethodsOfObtainingDatabaseSize(MethodsForObtainingDatabaseTablesSize)
	Methods = New Array; //Array look at см. NewMethodOfObtainingBaseTablesSize
	Methods.Add(MethodsForObtainingDatabaseTablesSize.None);
	If UT_CommonClientServer.PlatformVersionNotLess("8.3.15") Then
		Methods.Добавить(MethodsForObtainingDatabaseTablesSize.Platform);
	EndIf;
	If UT_Common.FileInfobase()
		 And Not (UT_CommonClientServer.IsLinux() And Not UT_CommonClientServer.IsTheX64Bitness())
		 And Not UT_CommonClientServer.IsMacOs() Then
		Methods.Add(MethodsForObtainingDatabaseTablesSize.tool1cd);
	EndIf;

//	If Not UT_Common.FileInfobase() Then
	Methods.Add(MethodsForObtainingDatabaseTablesSize.psql);
	Methods.Add(MethodsForObtainingDatabaseTablesSize.sqlcmd);
//	EndIf;


	Return Methods;
EndFunction

&AtServerNoContext
Function NewMethodOfObtainingBaseTablesSize(Name, Presentation)
	Method = New Structure;
	Method.Вставить("Name", Name);
	Method.Вставить("Presentation", Presentation);

	Return Method;
EndFunction

&AtServerNoContext
Function UnitsOfMeasurementSizeTables()
	Units = New Structure;
	Units.Вставить("KB");
	Units.Вставить("MB");

	Return Units;
EndFunction

&AtServer
Procedure OnChangeMethodOfDefiningSizeOfTablesAtServer()
	BaseTableDimensions.Clear();

	IsPlatformMethod = MethodForDeterminingTableSize = MethodsForObtainingDatabaseTablesSize.Platform.Name;
	GetTableSizes = MethodForDeterminingTableSize <> MethodsForObtainingDatabaseTablesSize.None.Name;

	Items.ResultGroupSiziesTables.Visible = GetTableSizes;
	Items.ResultRowCount.Visible = GetTableSizes And Not IsPlatformMethod;
	Items.ResultIndexSize.Visible = GetTableSizes And Not IsPlatformMethod;
	Items.ResultReserved.Visible = GetTableSizes And Not IsPlatformMethod;
	Items.ResultFreeSize.Visible = GetTableSizes And Not IsPlatformMethod;

	Items.PageSettingsReceiptDimensions.CurrentPage = Items["PageSettingsReceiptDimensions"
																					   + MethodForDeterminingTableSize];

	Items.TableSizesGroup.CollapsedRepresentationTitle = NStr("ru = 'Размеры таблиц базы данных:'; en = 'Database table sizes:'")
																  + " " + MethodsForObtainingDatabaseTablesSize[MethodForDeterminingTableSize].Presentation;
EndProcedure
&AtServer
Procedure SetColumnHeadersSizeTables()
	Items.ResultDataSize.Title = NStr("ru = 'Данные ('; en = 'Data'") + TableSizeUnit + ")";
	Items.ResultIndexSize.Title = NStr("ru = 'Индексы ('; en = 'Indexes'") + TableSizeUnit + ")";
	Items.ResultReserved.Title = NStr("ru = 'Зарезервировано всего ('; en = 'Total reserved'") + TableSizeUnit + ")";
	Items.ResultFreeSize.Title = NStr("ru = 'Свободно ('; en = 'Free'") + TableSizeUnit + ")";
EndProcedure
#EndRegion







&AtServer
Procedure FillResultTable_old(InfobaseStructure, FoundRows = Undefined)
	Result.Clear();

	If FoundRows = Undefined Then
		ResultRows=InfobaseStructure;
	Else
		ResultRows=FoundRows;
	EndIf;

	For Each Row In ResultRows Do
		NewRow = Result.Add();
		NewRow.TableName = Row.TableName;
		NewRow.Metadata = Row.Metadata;
		NewRow.Purpose = Row.Purpose;
		NewRow.StorageTableName = Row.StorageTableName;

		For Each Field In Row.Fields Do
			NewFieldsRow = NewRow.Fields.Add();
			NewFieldsRow.StorageFieldName = Field.StorageFieldName;
			NewFieldsRow.FieldName = Field.FieldName;
			NewFieldsRow.Metadata = Field.Metadata;
		EndDo;

		For Each Index In Row.Indexes Do
			NewIndexesRow = NewRow.Indexes.Add();
			NewIndexesRow.StorageIndexName = Index.StorageIndexName;

			// Index fields
			For Each Field In Index.Fields Do
				NewIndexFieldsRow = NewIndexesRow.IndexFields.Add();
				NewIndexFieldsRow.StorageFieldName = Field.StorageFieldName;
				NewIndexFieldsRow.FieldName = Field.FieldName;
				NewIndexFieldsRow.Metadata = Field.Metadata;
			EndDo;

		EndDo;

	EndDo;

	Result.Sort("Metadata ASC,TableName ASC");
EndProcedure

&AtServer
Procedure FindByStorageTableName_old()

	InfobaseStructure = GetFromTempStorage(DataBaseStructureAddress);

	SearchName = Upper(TrimAll(Filter));
	If Not ExactMap And Left(SearchName, 1) = "_" Then
		SearchName = Mid(SearchName, 2);
	EndIf;
	FoundRows = New Array;

	If IsBlankString(SearchName) Then
		Return;
	EndIf;

	For Each Row In InfobaseStructure Do

		If IncludingFields Then
			For Each RowField In Row.Fields Do
				If ExactMap Then
					If Upper(RowField.StorageFieldName) = SearchName Or Upper(RowField.FieldName) = SearchName Then
						FoundRows.Add(Row);
					EndIf;
				Else

					If Find(Upper(RowField.StorageFieldName), SearchName) > 0 Or Find(Upper(RowField.FieldName),
						SearchName) Then
						FoundRows.Add(Row);
					EndIf;
				EndIf;
			EndDo;
		EndIf;

		If ExactMap Then
			If Upper(Row.StorageTableName) = SearchName Or Upper(Row.TableName) = SearchName Or Upper(
				Row.Metadata) = SearchName Or Upper(Row.Purpose) = SearchName Then
				FoundRows.Add(Row);
			EndIf;
		Else
			If Find(Upper(Row.StorageTableName), SearchName) > 0 Or Find(Upper(Row.TableName),
				SearchName) Or Find(Upper(Row.Metadata), SearchName) Or Find(Upper(Row.Purpose),
				SearchName) Then
				FoundRows.Add(Row);
			EndIf;
		EndIf;
	EndDo;

	FillResultTable(FoundRows);
EndProcedure








