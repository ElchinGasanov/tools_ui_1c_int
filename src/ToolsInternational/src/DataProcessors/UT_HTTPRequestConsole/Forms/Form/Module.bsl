#Region ОписаниеПеременных

&AtClient
Перем УИ_ИдентификаторТекущейСтрокиЗапросов; //Number

#EndRegion

#Region ОбработчикиСобытийФормы

&AtServer
Procedure ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	InitialHeader = Title;

	InitializeForm();


	Если Параметры.Property("ДанныеОтладки") Then
		//@skip-check unknown-form-parameter-access
		FillByDebaggingData(Параметры.ДанныеОтладки);
	EndIf;

	УИ_ОбщегоНазначения.ФормаИнструментаПриСозданииНаСервере(ThisObject,
															 Отказ,
															 СтандартнаяОбработка,
															 КоманднаяПанель);

EndProcedure

&AtClient
Procedure ПриОткрытии(Отказ)
	UpdateTitle();
	УстановитьСтраницуРедактированияЗаголовковЗапроса();

	Если ValueIsFilled(RequestsFileName) Then
		ЗагрузитьФайлКонсоли(True);
	EndIf;
EndProcedure

&AtServer
Procedure ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	Если Параметры.Property("ДанныеОтладки") Then
		RequestsFileName = "";
	EndIf;
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы

#Region RequestHeaders

&AtClient
Procedure EditHeadersWithTableOnChange(Элемент)
	УстановитьСтраницуРедактированияЗаголовковЗапроса();
EndProcedure

#EndRegion


&AtClient
Procedure RequestBodyEncodingOnChange(Item)
	УстановитьЗаголовкиПоСодержимомуТелаЗапроса();
EndProcedure

&AtClient
Procedure RequestsTreeTypeOfStringContentOnChange(Item)
	УстановитьЗаголовкиПоСодержимомуТелаЗапроса();
EndProcedure

&AtClient
Procedure RequestBodyTypeOnChange(Item)
	ПриИзмененииВидаТелаЗапроса();

EndProcedure

&AtClient
Procedure BodyFileNameЗапросаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	RequestString = ТекущаяСтрокаЗапросов();	
	Если RequestString = Undefined Then
		Return;
	EndIf;
	
	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДВФ.МножественныйВыбор = False;
	ДВФ.ПолноеИмяФайла = RequestString.NameФайлаТела;

	ПараметрыОповещения = New Structure;
	ПараметрыОповещения.Insert("RowID", RequestString.GetID());

	ДВФ.Показать(Новый ОписаниеОповещения("RequestBodyFileNameStartChooseFinish", ThisObject, ПараметрыОповещения));
EndProcedure


&AtClient
Procedure RequestURLOnChange(Item)
	SetPreliminaryURL(УИ_ИдентификаторТекущейСтрокиЗапросов);
EndProcedure

&AtClient
Procedure ЗаголовкиСтрокаПриИзменении(Элемент)
	//FillJSONStructureInRequestsTree();
EndProcedure


&AtClient
Procedure RequestsTreeAuthenticationTypeOnChange(Элемент)
	ПриИзмененииВидаАутентификацииЗапроса();
EndProcedure


#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыФормыДеревоЗапросов

&AtClient
Procedure ДеревоЗапросовПриАктивизацииСтроки(Элемент)
	ПодключитьОбработчикОжидания("ОбработчикОжиданияАктивизацииСтрокиДереваЗапросов", 0.1, True);
EndProcedure


&AtClient
Procedure ДеревоЗапросовПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	If Not НоваяСтрока Then
		Return;
	EndIf;
	Если Копирование Then
		Return;
	EndIf;
	
	CurrentData = Items.RequestsTree.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	
	InitializeRequestsTreeString(CurrentData, ThisObject);
EndProcedure

&AtClient
Procedure ДеревоЗапросовПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	Если ОтменаРедактирования Then
		Return;
	EndIf;	
	
	CurrentData = Items.RequestsTree.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	
	If Not ValueIsFilled(CurrentData.Name) Then
		Отказ = True;
	EndIf;

EndProcedure


#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыФормыТаблицаЗаголовковЗапроса


&AtClient
Procedure RequestHeadersTableOnStartEdit(Item, NewRow, Clone)
	If Not НоваяСтрока Then
		Return;
	EndIf;
	Если Копирование Then
		Return;
	EndIf;
	
	CurrentData = Items.RequestHeadersTable.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	
	CurrentData.Using = True;
EndProcedure

&AtClient
Procedure RequestHeadersTableOnChange(Элемент)
	//FillJSONStructureInRequestsTree();
EndProcedure

&AtClient
Procedure TableRequestHeadersTableKeyAutoComplete(Item, Text, ChoiceData, DataGetParameters, Waiting, 
	StandardProcessing)

	СтандартнаяОбработка = False;

	If Not ValueIsFilled(Текст) Then
		Return;
	EndIf;

	ДанныеВыбора = Новый СписокЗначений;

	For Each ЭлементСписка Из СписокИспользованныхЗаголовков Цикл
		Если СтрНайти(Lower(ЭлементСписка.Value), Lower(Текст)) > 0 Then
			ДанныеВыбора.Add(ЭлементСписка.Value);
		EndIf;
	EndDo;

EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыФормыДеревоЗапросовТелоМультипарт
&AtClient
Procedure MultipartBodyRequestsTreeOnStartEdit(Элемент, НоваяСтрока, Копирование)
	If Not НоваяСтрока Then
		Return;
	EndIf;
	Если Копирование Then
		Return;
	EndIf;
	
	CurrentData = Items.MultipartBodyRequestsTree.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	CurrentData.Using = True;
	CurrentData.Вид = MultypartItemsType().File;
EndProcedure

&AtClient
Procedure MultipartBodyRequestsTreeValueStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData = Items.MultipartBodyRequestsTree.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	
	Types = MultypartItemsType();
	
	ПараметрыОповещения = New Structure;
	ПараметрыОповещения.Insert("ИдентификаторСтрокиЗапросов", УИ_ИдентификаторТекущейСтрокиЗапросов);
	ПараметрыОповещения.Insert("ИдентификаторСтрокиТела", CurrentData.GetID());

	ОписаниеОповещенияОЗавершении = Новый ОписаниеОповещения("ДеревоЗапросовТелоМультипартЗначениеНачалоВыбораЗавершениеВыбора",
		ThisObject, ПараметрыОповещения);

	Если CurrentData.Вид = Types.File Then
		ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		ДиалогВыбора.ПроверятьСуществованиеФайла = True;
		ДиалогВыбора.МножественныйВыбор = False;
		ДиалогВыбора.Показать(Новый ОписаниеОповещения("ДеревоЗапросовТелоМультипартЗначениеНачалоВыбораЗавершениеВыбораФайла",
			ThisObject, New Structure("ОписаниеОЗавершении", ОписаниеОповещенияОЗавершении)));
	Else
		УИ_ОбщегоНазначенияКлиент.ОткрытьФормуРедактированияТекста(CurrentData.Value, ОписаниеОповещенияОЗавершении);
	EndIf;
EndProcedure



#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыФормыПараметрыURL

&AtClient
Procedure ПараметрыURLПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)

	If Not НоваяСтрока Then
		Return;
	EndIf;

	Если Копирование Then
		Return;
	EndIf;
	CurrentData = Items.URLParameters.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	
	CurrentData.Using = True;
EndProcedure

&AtClient
Procedure RequestParametersПриИзменении(Элемент)
	SetPreliminaryURL(УИ_ИдентификаторТекущейСтрокиЗапросов);
EndProcedure


#EndRegion

#Region ОбработчикиКомандФормы

&AtClient
Procedure RequestTreeMoveToLevelUp(Команда)
	
	Строка = RequestsTree.FindByID(Items.RequestsTree.CurrentRow);
	Родитель = Строка.ПолучитьРодителя();

	Если Родитель <> Undefined Then
		РодительРодителя = Родитель.ПолучитьРодителя();
		Если РодительРодителя = Undefined Then
			ИндексВставки = RequestsTree.GetItems().Индекс(Родитель) + 1;
		Else
			ИндексВставки = РодительРодителя.GetItems().Индекс(Родитель) + 1;
		EndIf;
		
		НоваяСтрока = ПереместитьСтрокуДерева(RequestsTree, Строка, ИндексВставки, РодительРодителя);
		
		Items.RequestsTree.CurrentRow = НоваяСтрока.GetID();
	EndIf;

	Модифицированность = True;
	
EndProcedure

&AtClient
Procedure RequestExecute(Command)
	СохранитьДанныеЗапросаВДеревоЗапросов();
	
	RequestString  = ТекущаяСтрокаЗапросов();
	Если RequestString = Undefined Then
		Return;
	EndIf;
	
	If Not PossibleRequestExecution(RequestString) Then
		Return;	
	EndIf;
	
	ДопПараметры = New Structure;
	ДопПараметры.Insert("RequestString", RequestString);
	Если СохранятьПередВыполнением И ValueIsFilled(RequestsFileName) Then
		ВыполнитьСохранениеЗапросовВФайл( , Новый ОписаниеОповещения("ВыполнитьЗапросЗавершениеСохраненияФайла",
			ThisObject, ДопПараметры));
	Else
		ВыполнитьЗапросЗавершениеСохраненияФайла(True, ДопПараметры);
	EndIf;
EndProcedure

&AtClient
Procedure FillBodyBinaryDataFromFile(Команда)
	Если УИ_ИдентификаторТекущейСтрокиЗапросов = Undefined Then
		Return;
	EndIf;
	
	ПараметрыОповещения = New Structure();
	ПараметрыОповещения.Insert("CurrentRowID", УИ_ИдентификаторТекущейСтрокиЗапросов);
	
	НачатьПомещениеФайла(Новый ОписаниеОповещения("FillBodyBinaryDataFromFileFinish", ThisObject,
		ПараметрыОповещения), , "", True, УникальныйИдентификатор);
EndProcedure

&AtClient
Procedure SaveBodyRequestBinaryDataFromHistory(Команда)
	ТекДанныеИсторииЗапроса = Items.RequestsHistory.ТекущиеДанные;
	Если ТекДанныеИсторииЗапроса = Undefined Then
		Return;
	EndIf;

	If Not IsTempStorageURL(ТекДанныеИсторииЗапроса.ТелоЗапросаАдресДвоичныхДанных) Then
		Return;
	EndIf;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = False;

	ПараметрыСохранения = УИ_ОбщегоНазначенияКлиент.НовыйПараметрыСохраненияФайла();
	ПараметрыСохранения.ДиалогВыбораФайла = ДВФ;
	ПараметрыСохранения.АдресФайлаВоВременномХранилище = ТекДанныеИсторииЗапроса.ТелоЗапросаАдресДвоичныхДанных;
	УИ_ОбщегоНазначенияКлиент.НачатьСохранениеФайла(ПараметрыСохранения);

EndProcedure

&AtClient
Procedure SaveBinaryDataBodyAnswerInFile(Команда)
	ТекДанныеИсторииЗапроса = Items.RequestsHistory.ТекущиеДанные;
	Если ТекДанныеИсторииЗапроса = Undefined Then
		Return;
	EndIf;

	If Not IsTempStorageURL(ТекДанныеИсторииЗапроса.ТелоОтветаАдресДвоичныхДанных) Then
		Return;
	EndIf;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = False;

	ПараметрыСохранения = УИ_ОбщегоНазначенияКлиент.НовыйПараметрыСохраненияФайла();
	ПараметрыСохранения.ДиалогВыбораФайла = ДВФ;
	ПараметрыСохранения.АдресФайлаВоВременномХранилище = ТекДанныеИсторииЗапроса.ТелоОтветаАдресДвоичныхДанных;
	УИ_ОбщегоНазначенияКлиент.НачатьСохранениеФайла(ПараметрыСохранения);

EndProcedure

&AtClient
Procedure RecordHistoryRequestDetailedInformation(Команда)
	RequestString = ТекущаяСтрокаЗапросов();
	Если RequestString = Undefined Then
		Return;
	EndIf;
	
	CurrentData = Items.RequestsTreeRequestsHistory.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	
	ПараметрыФормы = New Structure;
	ПараметрыФормы.Insert("RequestString", RequestString.GetID());
	ПараметрыФормы.Insert("СтрокаИстории", CurrentData.GetID());

	ОткрытьФорму("Обработка.УИ_КонсольHTTPЗапросов.Form.ФормаПодробнойИнформацииОЗапросе",
				 ПараметрыФормы,
				 ThisObject,
				 ""
				 + УникальныйИдентификатор
				 + RequestString.GetID()
				 + CurrentData.GetID());
EndProcedure


&AtClient
Procedure SaveBodyResponseBinaryData(Команда)
	If Not IsTempStorageURL(ТелоОтветаАдресДвоичныхДанных) Then
		Return;
	EndIf;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = False;

	ПараметрыСохранения = УИ_ОбщегоНазначенияКлиент.НовыйПараметрыСохраненияФайла();
	ПараметрыСохранения.ДиалогВыбораФайла = ДВФ;
	ПараметрыСохранения.АдресФайлаВоВременномХранилище = ТелоОтветаАдресДвоичныхДанных;
	УИ_ОбщегоНазначенияКлиент.НачатьСохранениеФайла(ПараметрыСохранения);
EndProcedure

&AtClient
Procedure NewRequestFile(Команда)
	Если RequestsTree.GetItems().Count() = 0 Then
		ИнициализироватьКонсоль();
	Else
		ПоказатьВопрос(Новый ОписаниеОповещения("НовыйФайлЗапросовЗавершение", ThisObject),
			"Дерево запросов непустое. Continue?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	EndIf;
EndProcedure

&AtClient
Procedure OpenRequestFile(Команда)
	Если RequestsTree.GetItems().Count() = 0 Then
		ЗагрузитьФайлКонсоли();
	Else
		ПоказатьВопрос(Новый ОписаниеОповещения("ОткрытьФайлОтчетовЗавершение", ThisObject),
			"Дерево запросов непустое. Continue?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	EndIf;
EndProcedure

&AtClient
Procedure SaveRequestsToFile(Команда)
	ВыполнитьСохранениеЗапросовВФайл();
EndProcedure

&AtClient
Procedure SaveRequestsToFileAs(Команда)
	ВыполнитьСохранениеЗапросовВФайл(True);
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditor(Команда)
	TreeRow = ТекущаяСтрокаЗапросов();
	Если TreeRow = Undefined Then
		Return;
	EndIf;
	
	ПараметрыОповещения = New Structure;
	ПараметрыОповещения.Insert("ТекущаяСтрока", TreeRow.GetID());

	УИ_ОбщегоНазначенияКлиент.РедактироватьJSON(TreeRow.BodyString,
												False,
												Новый ОписаниеОповещения("EditRequestBodyInJSONEditorFinish",
		ThisObject, ПараметрыОповещения));
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditorAnalyzedRequest(Команда)
	УИ_ОбщегоНазначенияКлиент.РедактироватьJSON(Items.RequestsHistory.ТекущиеДанные.ТелоЗапросаСтрока, True);
EndProcedure

&AtClient
Procedure EditResponseBodyInJSONEditorAnalyzedRequest(Команда)
	УИ_ОбщегоНазначенияКлиент.РедактироватьJSON(ResponseBodyString, True);
EndProcedure

&AtClient
Procedure CopyRowDataHistoryToRequest(Команда)
	RequestString = ТекущаяСтрокаЗапросов();
	Если RequestString = Undefined Then
		Return;
	EndIf;
	
	СтрокаИстории = Items.RequestsTreeRequestsHistory.ТекущиеДанные;
	Если RequestString = Undefined Then
		Return;
	EndIf;
	СкопироватьДанныеСтрокиИсторииВЗапросНаСервере(RequestString.GetID(),
												   СтрокаИстории.GetID());
	ИзвлечьДанныеЗапросаИзСтрокиДерева();
EndProcedure

&AtClient
Procedure GenerateExecutionCode(Command)
	CurrentData = Items.RequestsTree.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;
	СохранитьДанныеЗапросаВДеревоЗапросов();

	СгенерированныйКод = GeneratedExecutionCodeAtServer(CurrentData.GetID());

	УИ_ОбщегоНазначенияКлиент.ОткрытьСтрокуКодаВСпециальнойФорме(СгенерированныйКод, "HTTP запрос: " + CurrentData.Name, ""
																													  + УникальныйИдентификатор
																													  + CurrentData.GetID());
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Команда) 
	УИ_ОбщегоНазначенияКлиент.Подключаемый_ВыполнитьОбщуюКомандуИнструментов(ThisObject, Команда);
EndProcedure

#EndRegion

#Region СлужебныеПроцедурыИФункции

&AtClient
Procedure ВыполнитьЗапросЗавершениеСохраненияФайла(Result, AdditionalParameters) Export
	Если Result <> True Then
		Return;
	EndIf;
	RequestString = AdditionalParameters.RequestString;
	
	ПараметрыСледующегоШага = New Structure;
	ПараметрыСледующегоШага.Insert("RowID", RequestString.GetID());
	ПараметрыСледующегоШага.Insert("Файл", Undefined);
	ПараметрыСледующегоШага.Insert("AtClient", RequestString.AtClient);
	
	Если RequestString.BodyType = TypesOfRequestBody.File Then
		Если RequestString.AtClient Then
			ПараметрыСледующегоШага.File = New Structure;
			ПараметрыСледующегоШага.File.Insert("ПолноеИмя", RequestString.BodyFileName);
			ВыполнитьЗапросЗавершениеПодготовительныхДействий(ПараметрыСледующегоШага);
		Else
			ПараметрыЧтенияФайла = УИ_ОбщегоНазначенияКлиент.НовыйПараметрыЧтенияФайла(УникальныйИдентификатор);
			ПараметрыЧтенияФайла.ПолноеИмяФайла = RequestString.BodyFileName;
			ПараметрыЧтенияФайла.ОповещениеОЗавершении = Новый ОписаниеОповещения("ВыполнитьЗапросЗавершениеЧтенияФайлаВоВременноеХранилище",
				ThisObject, ПараметрыСледующегоШага);

			УИ_ОбщегоНазначенияКлиент.НачатьЧтениеФайла(ПараметрыЧтенияФайла);
		EndIf;
	ElsIf RequestString.BodyType = TypesOfRequestBody.MultypartForm Then
		НачатьПомещениеФайловВоВременноеХранилищеДляСтрокТелаМультипарт(RequestString,
																		Новый ОписаниеОповещения("ВыполнитьЗапросЗавершениеЧтенияФайловМультипартВоВременноеХранилище",
			ThisObject, ПараметрыСледующегоШага));
	Else
		ВыполнитьЗапросЗавершениеПодготовительныхДействий(ПараметрыСледующегоШага);
	EndIf;
	
EndProcedure

&AtClient
Procedure НачатьПомещениеФайловВоВременноеХранилищеДляСтрокТелаМультипарт(RequestString, ОписаниеОповещенияОЗавершении)
	ПараметрыОповещений = New Structure;
	ПараметрыОповещений.Insert("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	ПараметрыОповещений.Insert("RequestsTreeRow", RequestString);
	ПараметрыОповещений.Insert("ИндексСтрокиМультипарт", 0);
	ПараметрыОповещений.Insert("СоответствиеПомещенныхФайлов", New Map);

	УИ_ОбщегоНазначенияКлиент.ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(Новый ОписаниеОповещения("НачатьПомещениеФайловВоВременноеХранилищеДляСтрокТелаМультипартЗавершениеПодключенияРасширенияРаботыСФайлам",
		ThisObject, ПараметрыОповещений));
EndProcedure


// Начать помещение файлов во временное хранилище для строк тела мультипарт завершение подключения расширения работы с файлам.
// 
// Parameters:
//  Подключено - Булево- Подключено
//  AdditionalParameters - Structure:
//  * ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  * RequestsTreeRow - ДанныеФормыЭлементДерева
&AtClient
Procedure НачатьПомещениеФайловВоВременноеХранилищеДляСтрокТелаМультипартЗавершениеПодключенияРасширенияРаботыСФайлам(Подключено,
	AdditionalParameters) Export
	If Not Подключено Then
		Return;
	EndIf;
	
	ПоместитьОчереднойФайлМультипарт(AdditionalParameters);
EndProcedure

// Поместить очередной файл мультипарт.
// 
// Parameters:
//  AdditionalParameters - Structure:
//  * ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  * RequestsTreeRow - ДанныеФормыЭлементДерева
//  * СоответствиеПомещенныхФайлов - Map из КлючИЗначение
//  * ИндексСтрокиМультипарт - Number
&AtClient
Procedure ПоместитьОчереднойФайлМультипарт(AdditionalParameters)
	TypesМультипарт = MultypartItemsType();
	
	Для ТекИндекс = AdditionalParameters.ИндексСтрокиМультипарт По AdditionalParameters.RequestsTreeRow.MultipartBody.Count()
																	  - 1 Цикл
		MultypartItemRow = AdditionalParameters.RequestsTreeRow.MultipartBody[ТекИндекс];
		Если MultypartItemRow.Type <> TypesМультипарт.File Then
			Continue;
		EndIf;
		If Not ValueIsFilled(MultypartItemRow.Value) Then
			Continue;
		EndIf;

		AdditionalParameters.ИндексСтрокиМультипарт = ТекИндекс;

		ПараметрыЧтения = УИ_ОбщегоНазначенияКлиент.НовыйПараметрыЧтенияФайла(УникальныйИдентификатор);
		ПараметрыЧтения.РасширениеРаботыСФайламиПодключено = True;
		ПараметрыЧтения.ПолноеИмяФайла = MultypartItemRow.Value;
		ПараметрыЧтения.ОповещениеОЗавершении = Новый ОписаниеОповещения("ПоместитьОчереднойФайлМультипартЗавершениеЧтенияОчередногоФайла",
			ThisObject, AdditionalParameters);

		УИ_ОбщегоНазначенияКлиент.НачатьЧтениеФайла(ПараметрыЧтения);
		Return;
	EndDo;

	ВыполнитьОбработкуОповещения(AdditionalParameters.ОписаниеОповещенияОЗавершении,
								 AdditionalParameters.СоответствиеПомещенныхФайлов);
EndProcedure

// Поместить очередной файл мультипарт завершение чтения очередного файла.
// 
// Parameters:
//  Result - Массив Из Structure:
//  	* ПолноеИмя - Строка
//  	* Storage - Строка
//  AdditionalParameters - Structure:
//  	* ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//  	* RequestsTreeRow - ДанныеФормыЭлементДерева
//  	* СоответствиеПомещенныхФайлов - Map из КлючИЗначение
//  	* ИндексСтрокиМультипарт - Number
&AtClient
Procedure ПоместитьОчереднойФайлМультипартЗавершениеЧтенияОчередногоФайла(Result, AdditionalParameters) Export
	Если Result <> Undefined Then
		Если Result.Count() > 0 Then
			AdditionalParameters.СоответствиеПомещенныхФайлов.Insert(AdditionalParameters.ИндексСтрокиМультипарт,
																		  Result[0].Storage);
		EndIf;
	EndIf;
	AdditionalParameters.ИндексСтрокиМультипарт = AdditionalParameters.ИндексСтрокиМультипарт + 1;
	ПоместитьОчереднойФайлМультипарт(AdditionalParameters);
EndProcedure


&AtClient
Procedure ДеревоЗапросовТелоМультипартЗначениеНачалоВыбораЗавершениеВыбораФайла(ChosenFiles, AdditionalParameters) Export
	Если ChosenFiles = Undefined Then
		Return;
	EndIf;
	Если ChosenFiles.Count() = 0  Then
		Return;
	EndIf;
	
	ВыполнитьОбработкуОповещения(AdditionalParameters.ОписаниеОЗавершении, ChosenFiles[0]);
EndProcedure

// Дерево запросов тело мультипарт значение начало выбора завершение выбора.
// 
// Parameters:
//  Result - Строка, Undefined - Result
//  AdditionalParameters - Structure:
//  * ИдентификаторСтрокиЗапросов - Number
//  * ИдентификаторСтрокиТела - Number
&AtClient
Procedure ДеревоЗапросовТелоМультипартЗначениеНачалоВыбораЗавершениеВыбора(Result, AdditionalParameters) Export
	Если Result = Undefined Then
		Return;
	EndIf;
	
	TreeRow = RequestsTree.FindByID(AdditionalParameters.ИдентификаторСтрокиЗапросов);
	Если TreeRow = Undefined Then
		Return;
	EndIf;
	
	СтрокаТела = TreeRow.MultipartBody.FindByID(AdditionalParameters.ИдентификаторСтрокиТела);
	Если СтрокаТела = Undefined Then
		Return;
	EndIf;
	
	СтрокаТела.Value = Result;
	Модифицированность = True;
EndProcedure

&AtClient
Procedure ОбработчикОжиданияАктивизацииСтрокиДереваЗапросов()
	СохранитьДанныеЗапросаВДеревоЗапросов();
	
	CurrentData = Items.RequestsTree.ТекущиеДанные;
	Если CurrentData = Undefined Then
		Return;
	EndIf;

	УИ_ИдентификаторТекущейСтрокиЗапросов = CurrentData.GetID();
	ИзвлечьДанныеЗапросаИзСтрокиДерева();
	
EndProcedure

&AtClient
Procedure УстановитьЗаголовкиПоСодержимомуТелаЗапроса()
	TreeRow = ТекущаяСтрокаЗапросов();
	Если TreeRow = Undefined Then
		Return;
	EndIf;
	
	ЗначениеЗаголовкаСодержимого = "";

	Если TreeRow.BodyType = TypesOfRequestBody.String Then
		Если TreeRow.TypeOfStringContent <> "None" И ValueIsFilled(TreeRow.TypeOfStringContent) Then
			ТипыТекстов = TextContentTypes();
			Если ТипыТекстов.Property(TreeRow.TypeOfStringContent) Then
				ЗначениеЗаголовкаСодержимого = ТипыТекстов[TreeRow.TypeOfStringContent];

				Кодировка = "";
				
				Кодировки = RequestBodyEncodingsTypes();
								
				Если TreeRow.BodyEncoding = Кодировки.Auto
					Или TreeRow.BodyEncoding = Кодировки.System Then
						
				ElsIf TreeRow.BodyEncoding = Кодировки.UTF8 Then 
					Кодировка="utf-8";
				ElsIf TreeRow.BodyEncoding = Кодировки.ANSI Then 
					Кодировка = "windows-1251";
				ElsIf TreeRow.BodyEncoding = Кодировки.UTF16 Then 
					Кодировка = "utf-16";
				ElsIf TreeRow.BodyEncoding = Кодировки.OEM Then 
					Кодировка = "cp866";
				ElsIf ValueIsFilled(TreeRow.BodyEncoding) Then
					Кодировка = TreeRow.BodyEncoding;
				EndIf;
				Если ValueIsFilled(Кодировка) Then
					ЗначениеЗаголовкаСодержимого = ЗначениеЗаголовкаСодержимого
												   + "; charset="
												   + Кодировка;
				EndIf;
			EndIf;
		EndIf;
	ElsIf TreeRow.BodyType = TypesOfRequestBody.BinaryData Then 
		//ЗначениеЗаголовкаСодержимого = "application/octet-stream";	
	ElsIf TreeRow.BodyType = TypesOfRequestBody.MultypartForm Then
		ЗначениеЗаголовкаСодержимого = "multipart/form-data; boundary=" + MultipartBodySplitter;
	Else
		Return;
	EndIf;
		
	ИмяЗаголовкаПоиска = "Content-Type";
	
	Если ValueIsFilled(ЗначениеЗаголовкаСодержимого) Then
		ДобавитьЗаголовокЗапроса(ИмяЗаголовкаПоиска, ЗначениеЗаголовкаСодержимого);
//	Else
//		УдалитьЗаголовокЗапроса(ИмяЗаголовкаПоиска);
	EndIf;

EndProcedure

&AtClient
Procedure ДобавитьЗаголовокЗапроса(HeaderName, ЗначениеЗаголовка)
	Если EditHeadersWithTable Then
		НайденаСтрокаЗаголовка = False;
		For Each Стр Из RequestHeadersTable Цикл
			Если Lower(HeaderName) = Lower(Стр.Key) Then
				Стр.Using = True;
				Стр.Value = ЗначениеЗаголовка;
				
				НайденаСтрокаЗаголовка = True;
				Break;
			EndIf;
		EndDo;
		
		If Not НайденаСтрокаЗаголовка Then
			Стр = RequestHeadersTable.Add();
			Стр.Using = True;
			Стр.Key = HeaderName;
			Стр.Value = ЗначениеЗаголовка;	
		EndIf;
	Else
		СтрокиЗаголовков = StrSplit(ЗаголовкиСтрока, Chars.LF);
		
		ИскомыйИндексЗаголовка = Undefined;
		
		Для Индекс = 0 по СтрокиЗаголовков.Count() -1 Цикл
			Стр = СтрокиЗаголовков[Индекс];
			
			If Not ValueIsFilled(Стр) Then
				Continue;
			EndIf;
			
			МассивЗаголовка = StrSplit(Стр, ":");
			Если Lower(МассивЗаголовка[0]) = Lower(HeaderName) Then
				ИскомыйИндексЗаголовка = Индекс;
				Break;
			EndIf;
		EndDo;
		
		СторокаДляВставки = StrTemplate("%1:%2",HeaderName, ЗначениеЗаголовка);
		
		Если ИскомыйИндексЗаголовка = Undefined Then
			СтрокиЗаголовков.Add(СторокаДляВставки);
		Else
			СтрокиЗаголовков[ИскомыйИндексЗаголовка] = СторокаДляВставки;
		EndIf;
			
		ЗаголовкиСтрока = StrConcat(СтрокиЗаголовков, Chars.LF);
		
	EndIf;
EndProcedure

&AtClient 
Procedure УдалитьЗаголовокЗапроса(HeaderName)
	Если EditHeadersWithTable Then
		УдаляемаяСтрока = Undefined;
		For Each Стр Из RequestHeadersTable Цикл
			Если Lower(HeaderName) = Lower(Стр.Key) Then
				УдаляемаяСтрока = Стр;
				Break;
			EndIf;
		EndDo;
		
		Если УдаляемаяСтрока <> Undefined Then
			RequestHeadersTable.Удалить(УдаляемаяСтрока);
		EndIf;
	Else
		СтрокиЗаголовков = StrSplit(ЗаголовкиСтрока, Chars.LF);
		
		ИскомыйИндексЗаголовка = Undefined;
		
		Для Индекс = 0 по СтрокиЗаголовков.Count() -1 Цикл
			Стр = СтрокиЗаголовков[Индекс];
			
			If Not ValueIsFilled(Стр) Then
				Continue;
			EndIf;
			
			МассивЗаголовка = StrSplit(Стр, ":");
			Если Lower(МассивЗаголовка[0]) = Lower(HeaderName) Then
				ИскомыйИндексЗаголовка = Индекс;
				Break;
			EndIf;
		EndDo;

		Если ИскомыйИндексЗаголовка <> Undefined Then
			СтрокиЗаголовков.Удалить(ИскомыйИндексЗаголовка);
			ЗаголовкиСтрока = StrConcat(СтрокиЗаголовков, Chars.LF);
		EndIf;
		
	EndIf;	
EndProcedure

&AtClient
Function ПереместитьСтрокуДерева(Дерево, ПеремещаемаяСтрока, ИндексВставки, НовыйРодитель, Уровень = 0)

	Если Уровень = 0 Then

		Если НовыйРодитель = Undefined Then
			НоваяСтрока = Дерево.GetItems().Insert(ИндексВставки);
		Else
			НоваяСтрока = НовыйРодитель.GetItems().Insert(ИндексВставки);
		EndIf;

		ЗаполнитьЗначенияСвойств(НоваяСтрока, ПеремещаемаяСтрока);
		ПереместитьСтрокуДерева(Дерево, ПеремещаемаяСтрока, ИндексВставки, НоваяСтрока, Уровень + 1);

		ПеремещаемаяСтрокаРодитель = ПеремещаемаяСтрока.ПолучитьРодителя();
		Если ПеремещаемаяСтрокаРодитель = Undefined Then
			Дерево.GetItems().Удалить(ПеремещаемаяСтрока);
		Else
			ПеремещаемаяСтрокаРодитель.GetItems().Удалить(ПеремещаемаяСтрока);
		EndIf;

	Else

		For Each Строка Из ПеремещаемаяСтрока.GetItems() Цикл
			НоваяСтрока = НовыйРодитель.GetItems().Add();
			
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ПеремещаемаяСтрока);
			
			ПереместитьСтрокуДерева(Дерево, Строка, НоваяСтрока, ИндексВставки, Уровень + 1);
		EndDo;

	EndIf;

	Return НоваяСтрока;

EndFunction




&AtServer
Procedure СкопироватьДанныеСтрокиИсторииВЗапросНаСервере(ИдентификаторСтрокиЗапросов, ИдентификаторСтрокиИстории)
	RequestString = RequestsTree.FindByID(ИдентификаторСтрокиЗапросов);
	СтрокаИстории = RequestString.RequestsHistory.FindByID(ИдентификаторСтрокиИстории);
	
	RequestString.RequestURL = СтрокаИстории.RequestURL;
	RequestString.BodyType = СтрокаИстории.RequestBodyType;
	RequestString.HTTPRequest = СтрокаИстории.HTTPFunction;
	RequestString.BodyFileName = СтрокаИстории.ТелоЗапросаИмяФайла;
	RequestString.UseBOM = СтрокаИстории.BOM;
	RequestString.UseProxy = СтрокаИстории.UseProxy;
	RequestString.BodyEncoding = СтрокаИстории.RequestBodyEncoding;
	RequestString.ProxyOSAuthentication = СтрокаИстории.ProxyOSAuthentication;
	RequestString.ProxyPassword = СтрокаИстории.ProxyPassword;
	RequestString.ProxyPort = СтрокаИстории.ProxyPort;
	RequestString.ProxyUser = СтрокаИстории.ProxyUser;
	RequestString.ProxyServer = СтрокаИстории.ProxyServer;
	RequestString.Timeout = СтрокаИстории.Timeout;
	RequestString.BodyString = СтрокаИстории.ТелоЗапросаСтрока;

	RequestString.BodyBinaryData = Undefined;
	Если IsTempStorageURL(СтрокаИстории.ТелоЗапросаАдресДвоичныхДанных) Then
		BinaryData = GetFromTempStorage(СтрокаИстории.ТелоЗапросаАдресДвоичныхДанных);
		Если TypeOf(BinaryData) = Тип("BinaryData") Then
			RequestString.BodyBinaryData = UT_Common.ValueStorageContainerBinaryData(BinaryData);
		EndIf;
	EndIf;
	
	FillHeadersTableByString(СтрокаИстории.RequestHeaders, RequestString.Headers);
//	RequestString.URLParameters = СтрокаИстории.RequestBodyEncoding;

EndProcedure

&AtClient
Function StructureОписанияСохраняемогоФайла()
	Structure=УИ_ОбщегоНазначенияКлиент.ПустаяСтруктураОписанияВыбираемогоФайла();
	Structure.ИмяФайла=RequestsFileName;

	// Пока закоментим сохранение в JSON, т.к. библиотека ошибки выдает на двоичных данных
	УИ_ОбщегоНазначенияКлиент.ДобавитьFormatВОписаниеФайлаСохранения(Structure,
		"Файл запросов консоли HTTP (*.uihttp)", "uihttp");

	Return Structure;
EndFunction

&AtClient
Procedure ВыполнитьСохранениеЗапросовВФайл(СохранитьКак = False, ОписаниеОповещенияОЗаверешении = Undefined)
	СохранитьДанныеЗапросаВДеревоЗапросов();
	
	ДопПараметрыОповещения = Undefined;
	Если ОписаниеОповещенияОЗаверешении <> Undefined Then
		ДопПараметрыОповещения = New Structure;
		ДопПараметрыОповещения.Insert("ОписаниеОповещенияОЗаверешении", ОписаниеОповещенияОЗаверешении);
	EndIf;

	УИ_ОбщегоНазначенияКлиент.СохранитьДанныеКонсолиВФайл("КонсольHTTPЗапросов",
														  СохранитьКак,
														  СтруктураОписанияСохраняемогоФайла(),
														  ПолучитьСтрокуДанныхФайлаДляСохраненияВФайл(),
														  Новый ОписаниеОповещения("СохранениеВФайлЗавершение",
		ThisObject, ДопПараметрыОповещения));

EndProcedure

&AtClient
Procedure ПриИзмененииВидаТелаЗапроса()
	RequestString = ТекущаяСтрокаЗапросов();	
	Если RequestString = Undefined Then
		Return;
	EndIf;
		
	Если RequestString.BodyType = TypesOfRequestBody.Bodyless Then
		НоваяСтраница = Items.RequestBodyBodylessPageGroup;
	ElsIf RequestString.BodyType = TypesOfRequestBody.String Then
		НоваяСтраница = Items.RequestBodyStringPageGroup;
	ElsIf RequestString.BodyType = TypesOfRequestBody.BinaryData Then
		НоваяСтраница = Items.BinaryDataRequestBodyPageGroup;
	ElsIf RequestString.BodyType = TypesOfRequestBody.MultypartForm Then 
		НоваяСтраница = Items.BodyMultypartPageGroup;
	Else
		НоваяСтраница = Items.BadyFileNameRequestBodySPageGroup;
	EndIf;

	Items.RequestBodyPageGroup.CurrentPage = НоваяСтраница;
	
	УстановитьЗаголовкиПоСодержимомуТелаЗапроса();
EndProcedure


&AtClient
Procedure ПриИзмененииВидаАутентификацииЗапроса()
	RequestString = ТекущаяСтрокаЗапросов();	
	Если RequestString = Undefined Then
		Return;
	EndIf;
		
	Types = AuthenticationTypes();
		
	ВидимостьГруппыНастроекАутентификации = True;	
	Если RequestString.AuthenticationType = Types.Basic Then
		НоваяСтраница = Items.ГруппаСтраницаАутентифкацияБазовая;
	ElsIf RequestString.AuthenticationType = Types.BearerToken Then
		НоваяСтраница = Items.TokenAuthenticationPageGroup;
	ElsIf RequestString.AuthenticationType = Types.NTML Then 
		НоваяСтраница = Items.StubAuthenticationPageGroup;
	Else
		ВидимостьГруппыНастроекАутентификации = False;
		НоваяСтраница = Items.StubAuthenticationPageGroup;
	EndIf;

	Items.AuthenticationTypePageGroup.CurrentPage = НоваяСтраница;
	Items.RequestsAuthenticationSettingsGroup.Видимость = ВидимостьГруппыНастроекАутентификации;
EndProcedure

&AtClient
Function ТекущаяСтрокаЗапросов()
	Если УИ_ИдентификаторТекущейСтрокиЗапросов = Undefined Then
		Return Undefined;
	EndIf;
	Return RequestsTree.FindByID(УИ_ИдентификаторТекущейСтрокиЗапросов);	
	
EndFunction

// Request body types.
// 
// Возвращаемое значение:
//  Structure -  Request body types:
// * String - String - 
// * BinaryData - String - 
// * File - String - 
&AtClientAtServerNoContext
Function RequestBodyTypes()

	BodyTypes = New Structure;
	BodyTypes.Insert("Bodyless", "Bodyless");	
	BodyTypes.Insert("String", "String");	
	BodyTypes.Insert("BinaryData", "BinaryData");	
	BodyTypes.Insert("File", "File");	
	BodyTypes.Insert("MultypartForm", "MultypartForm");	

	Return BodyTypes;
EndFunction

// Multypart items type.
// 
// Возвращаемое значение:
//  Structure -  Multypart items type:
// * String - String - 
// * File - String - 
&AtClientAtServerNoContext
Function MultypartItemsType()
	Types = New Structure;
	Types.Insert("String", "String");
	Types.Insert("File", "File");
	
	Return Types;
EndFunction

// Types of HTTP methods.
// 
// Возвращаемое значение:
//  Structure -  Types of HTTP methods:
// * GET - String - 
// * POST - String - 
// * PUT - String - 
// * PATCH - String - 
// * DELETE - String - 
// * OPTIONS - String - 
// * HEAD - String - 
&AtClientAtServerNoContext
Function TypesOfHTTPMethods()
	Types = New Structure;
	Types.Insert("GET", "GET");
	Types.Insert("POST", "POST");
	Types.Insert("PUT", "PUT");
	Types.Insert("PATCH", "PATCH");
	Types.Insert("DELETE", "DELETE");
	Types.Insert("OPTIONS", "OPTIONS");
	Types.Insert("HEAD", "HEAD");
	
	Return Types;
EndFunction

&AtClientAtServerNoContext
Function TextContentTypes()
	Types = New Structure;
	Types.Insert("json", "application/json");
	Types.Insert("xml", "application/xml");
	Types.Insert("yaml", "text/yaml");
	Types.Insert("text", "text/plain");

	Return Types;	
EndFunction

&AtClientAtServerNoContext
Function AuthenticationTypes()
	Types = New Structure;
	Types.Insert("None", "None");
	Types.Insert("Basic", "Basic");
	Types.Insert("BearerToken", "BearerToken");
	Types.Insert("NTML", "NTML");
	
	Return Types;
EndFunction

#Region ПараметрыДереваЗапроса



&AtClient
Function ПодготовитьСтрокуПараметров()
//		стрПараметры = "";
//		
//	For Each стрПараметра Из URLParameters Цикл
//		Если стрПараметра.Using Then
//			Если ПустаяСтрока(стрПараметры) Then
//				стрПараметры = StrTemplate("%1=%2", стрПараметра.Name, стрПараметра.Value);
//			Else
//				стрПараметры = стрПараметры+"&"+StrTemplate("%1=%2", стрПараметра.Name, стрПараметра.Value);
//			EndIf;
//		EndIf;
//	EndDo;
//	
//	Return стрПараметры;
Return "";
EndFunction

#EndRegion

#Region ФайлыЗапросов

// Отработка загрузки файла с отчетами из адреса.
&AtClient
Procedure ОтработкаЗагрузкиИзАдреса(Адрес)

	ЗагрузитьФайлКонсолиНаСервере(Адрес);
	UpdateTitle();
	
EndProcedure

&AtServer
Procedure ЗаполнитьЗапросыИзФайла(ЗапросФайла, КоллекцияЭлементовЗапросов, ВерсияФормата)
	НоваяСтрокаЗапросов = КоллекцияЭлементовЗапросов.Add();
	НоваяСтрокаЗапросов.Name = ЗапросФайла.Name;
	НоваяСтрокаЗапросов.RequestURL = ЗапросФайла.RequestURL;
	НоваяСтрокаЗапросов.BodyType = ЗапросФайла.BodyType;
	НоваяСтрокаЗапросов.HTTPRequest = ЗапросФайла.HTTPRequest;
	НоваяСтрокаЗапросов.BodyFileName = ЗапросФайла.BodyFileName;
	НоваяСтрокаЗапросов.UseBOM = ЗапросФайла.UseBOM;
	НоваяСтрокаЗапросов.BodyEncoding = ЗапросФайла.BodyEncoding;
	НоваяСтрокаЗапросов.UseProxy = ЗапросФайла.UseProxy;
	НоваяСтрокаЗапросов.ProxyOSAuthentication = ЗапросФайла.ProxyOSAuthentication;
	НоваяСтрокаЗапросов.ProxyPassword = ЗапросФайла.ProxyPassword;
	НоваяСтрокаЗапросов.ProxyUser = ЗапросФайла.ProxyUser;
	НоваяСтрокаЗапросов.ProxyPort = ЗапросФайла.ProxyPort;
	НоваяСтрокаЗапросов.ProxyServer = ЗапросФайла.ProxyServer;
	НоваяСтрокаЗапросов.Timeout = ЗапросФайла.Timeout;
	НоваяСтрокаЗапросов.BodyString = ЗапросФайла.BodyString;
	НоваяСтрокаЗапросов.BodyBinaryData = Undefined;
	НоваяСтрокаЗапросов.TypeOfStringContent = ЗапросФайла.TypeOfStringContent;
	НоваяСтрокаЗапросов.Комментарий = ЗапросФайла.Комментарий;

	Если ВерсияФормата >=3 Then
		НоваяСтрокаЗапросов.AtClient = ЗапросФайла.AtClient;
	EndIf;

	//Аутентификация
	НоваяСтрокаЗапросов.AuthenticationType = ЗапросФайла.AuthenticationType;
	НоваяСтрокаЗапросов.UseAuthentication = ЗапросФайла.UseAuthentication;
	НоваяСтрокаЗапросов.AuthenticationPassword = ЗапросФайла.AuthenticationPassword;
	НоваяСтрокаЗапросов.AuthenticationUser = ЗапросФайла.AuthenticationUser;
	НоваяСтрокаЗапросов.АутентификацияИмяЗаголовка = ЗапросФайла.АутентификацияИмяЗаголовка;
	НоваяСтрокаЗапросов.AuthenticationTokenPrefix = ЗапросФайла.AuthenticationTokenPrefix;
	

	Если ЗапросФайла.BodyBinaryData <> Undefined Then
		Try
			Хранилище = ЗначениеИзСтрокиВнутр(ЗапросФайла.BodyBinaryData);//ХранилищеЗначения
			BinaryData = Хранилище.Получить();
			НоваяСтрокаЗапросов.BodyBinaryData = UT_Common.ValueStorageContainerBinaryData(BinaryData);
		Except
			UT_CommonClientServer.MessageToUser("Для запроса "
																 + НоваяСтрокаЗапросов.Name
																 + " не удалось прочитать двоичные данные тела запроса");
		EndTry;
	EndIf;

	For Each ТекЗаголовок Из ЗапросФайла.Headers Цикл
		НоваяСтрока = НоваяСтрокаЗапросов.Headers.Add();
		НоваяСтрока.Using = ТекЗаголовок.Using;
		НоваяСтрока.Key = ТекЗаголовок.Key;
		НоваяСтрока.Value = ТекЗаголовок.Value;
	EndDo;	
	
	For Each ТекЗаголовок Из ЗапросФайла.URLParameters Цикл
		НоваяСтрока = НоваяСтрокаЗапросов.URLParameters.Add();
		НоваяСтрока.Using = ТекЗаголовок.Using;
		НоваяСтрока.Name = ТекЗаголовок.Name;
		НоваяСтрока.Value = ТекЗаголовок.Value;
	EndDo;	

	For Each ТекОписание Из ЗапросФайла.MultipartBody Цикл
		НоваяСтрока = НоваяСтрокаЗапросов.MultipartBody.Add();
		НоваяСтрока.Using = ТекОписание.Using;
		НоваяСтрока.Name = ТекОписание.Name;
		НоваяСтрока.Вид = ТекОписание.Вид;
		НоваяСтрока.Value = ТекОписание.Value;
	EndDo;

	КоллекцияСтрок = НоваяСтрокаЗапросов.GetItems();
	For Each ПодчиненныйЗапрос Из ЗапросФайла.Строки Цикл
		ЗаполнитьЗапросыИзФайла(ПодчиненныйЗапрос, КоллекцияСтрок, ВерсияФормата)
	EndDo;

EndProcedure



// Загрузить файл консоли на сервере.
//
// Parameters:
//  Адрес - String -адрес хранилища, из которого нужно загрузить файл.
&AtServer
Procedure ЗагрузитьФайлКонсолиНаСервере(Адрес)
	
	ДанныеФайла=GetFromTempStorage(Адрес);

	ЧтениеJSON=Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьПоток(ДанныеФайла.ОткрытьПотокДляЧтения());

	СтруктураФайла=ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();

	ЭлементыЗапросов =  RequestsTree.GetItems();
	ЭлементыЗапросов.Clear();
	
	For Each ТекЗапрос Из СтруктураФайла.Requestы Цикл
		ЗаполнитьЗапросыИзФайла(ТекЗапрос, ЭлементыЗапросов, СтруктураФайла.ВерсияФормата);	
	EndDo;

EndProcedure

&AtClient
Procedure ЗагрузитьФайлКонсолиПослеПомещенияФайла(Result, AdditionalParameters) Export
	Если Result = Undefined Then
		Return;
	EndIf;
	
	УИ_ИдентификаторТекущейСтрокиЗапросов = Undefined;
	RequestsFileName = Result.ИмяФайла;
	ОтработкаЗагрузкиИзАдреса(Result.Адрес);
	
	Модифицированность = False;
EndProcedure

// Загрузить файл.
//
// Parameters:
//  БезВыбораФайла - Булево
&AtClient
Procedure ЗагрузитьФайлКонсоли(БезВыбораФайла = False)

	УИ_ОбщегоНазначенияКлиент.ПрочитатьДанныеКонсолиИзФайла("КонсольHTTPЗапросов",
															СтруктураОписанияСохраняемогоФайла(),
															Новый ОписаниеОповещения("ЗагрузитьФайлКонсолиПослеПомещенияФайла",
		ThisObject),
															БезВыбораФайла);

EndProcedure

// Завершение обработчика открытия файла.
// 
// Parameters:
//  ResultВопроса - КодВозвратаДиалога 
//  AdditionalParameters - Произвольный
&AtClient
Procedure ОткрытьФайлОтчетовЗавершение(ResultВопроса, AdditionalParameters) Export

	Если ResultВопроса = КодВозвратаДиалога.None Then
		Return;
	EndIf;
	ЗагрузитьФайлКонсоли();
	
EndProcedure

&AtClient
Procedure ИнициализироватьКонсоль()
	Модифицированность = False;
	RequestsFileName = "";

	RequestsTree.GetItems().Clear();
	InitializeRequestsTree();

	UpdateTitle();
EndProcedure

// Завершение обработчика создания нового файла запросов.
// 
// Parameters:
//  ResultВопроса - КодВозвратаДиалога
//  AdditionalParameters - Произвольный
&AtClient
Procedure НовыйФайлЗапросовЗавершение(ResultВопроса, AdditionalParameters) Export

	Если ResultВопроса = КодВозвратаДиалога.None Then
		Return;
	EndIf;

	ИнициализироватьКонсоль();

EndProcedure

// Завершение обработчика открытия файла.
// 
// Parameters:
//  Result - Строка
//  AdditionalParameters - Произвольный
&AtClient
Procedure СохранениеВФайлЗавершение(Result, AdditionalParameters) Export
	Если Result = Undefined Then
		Return;
	EndIf;

	RequestsFileName=Result;
	Модифицированность = False;
	UpdateTitle();

	Если AdditionalParameters <> Undefined Then
		ВыполнитьОбработкуОповещения(AdditionalParameters.ОписаниеОповещенияОЗаверешении, True);
	EndIf;
EndProcedure

&AtServer
Function ОписаниеЗапросаДляСохраненияВФайл(RequestsTreeRow)
	ОписаниеЗапроса = New Structure;
	ОписаниеЗапроса.Insert("Имя", RequestsTreeRow.Name);
	ОписаниеЗапроса.Insert("RequestURL", RequestsTreeRow.RequestURL);
	ОписаниеЗапроса.Insert("ВидТела", RequestsTreeRow.BodyType);
	ОписаниеЗапроса.Insert("HTTPRequest", RequestsTreeRow.HTTPRequest);
	ОписаниеЗапроса.Insert("BodyFileName", RequestsTreeRow.BodyFileName);
	ОписаниеЗапроса.Insert("UseBOM", RequestsTreeRow.ИспользоватьBOM);
	ОписаниеЗапроса.Insert("BodyEncoding", RequestsTreeRow.BodyEncoding);
	ОписаниеЗапроса.Insert("UseProxy", RequestsTreeRow.UseProxy);
	ОписаниеЗапроса.Insert("ProxyOSAuthentication", RequestsTreeRow.ProxyOSAuthentication);
	ОписаниеЗапроса.Insert("ProxyPassword", RequestsTreeRow.ProxyPassword);
	ОписаниеЗапроса.Insert("ProxyUser", RequestsTreeRow.ProxyUser);
	ОписаниеЗапроса.Insert("ProxyPort", RequestsTreeRow.ProxyPort);
	ОписаниеЗапроса.Insert("ProxyServer", RequestsTreeRow.ProxyServer);
	ОписаниеЗапроса.Insert("Timeout", RequestsTreeRow.Timeout);
	ОписаниеЗапроса.Insert("BodyString", RequestsTreeRow.BodyString);
	ОписаниеЗапроса.Insert("TypeOfStringContent", RequestsTreeRow.TypeOfStringContent);
	ОписаниеЗапроса.Insert("Комментарий", RequestsTreeRow.Комментарий);
	ОписаниеЗапроса.Insert("AtClient", RequestsTreeRow.AtClient);

	//Аутентификация
	ОписаниеЗапроса.Insert("АутентификацияВид", RequestsTreeRow.AuthenticationType);
	ОписаниеЗапроса.Insert("UseAuthentication", RequestsTreeRow.UseAuthentication);
	ОписаниеЗапроса.Insert("AuthenticationPassword", RequestsTreeRow.AuthenticationPassword);
	ОписаниеЗапроса.Insert("AuthenticationUser", RequestsTreeRow.AuthenticationUser);
	ОписаниеЗапроса.Insert("АутентификацияПрефиксТокена", RequestsTreeRow.AuthenticationTokenPrefix);
	ОписаниеЗапроса.Insert("АутентификацияИмяЗаголовка", RequestsTreeRow.АутентификацияИмяЗаголовка);
	
	
	Если RequestsTreeRow.BodyBinaryData = Undefined Then
		ОписаниеЗапроса.Insert("BodyBinaryData", Undefined);
	Else
		BinaryData = UT_Common.ValueFromBinaryDataContainerStorage(RequestsTreeRow.BodyBinaryData);
		ОписаниеЗапроса.Insert("BodyBinaryData", ЗначениеВСтрокуВнутр(Новый ХранилищеЗначения(BinaryData,
			Новый СжатиеДанных(9))));
	EndIf;
	
	ОписаниеЗапроса.Insert("Заголовки", New Array);
	
	For Each Стр Из RequestsTreeRow.Headers Цикл
		ОписаниеЗаголовка = New Structure;
		ОписаниеЗаголовка.Insert("Использование", Стр.Using);
		ОписаниеЗаголовка.Insert("Ключ", Стр.Key);
		ОписаниеЗаголовка.Insert("Значение", Стр.Value);

		ОписаниеЗапроса.Headers.Add(ОписаниеЗаголовка);
	EndDo;
	
	ОписаниеЗапроса.Insert("URLParameters", New Array);
	For Each Стр Из RequestsTreeRow.URLParameters Цикл
		ОписаниеПараметра = New Structure;
		ОписаниеПараметра.Insert("Использование", Стр.Using);
		ОписаниеПараметра.Insert("Имя", Стр.Name);
		ОписаниеПараметра.Insert("Значение", Стр.Value);
		
		ОписаниеЗапроса.URLParameters.Add(ОписаниеПараметра);
	EndDo;
	
	ОписаниеЗапроса.Insert("ТелоМультипарт", New Array);
	For Each Стр Из RequestsTreeRow.MultipartBody Цикл
		Описание= New Structure;
		Описание.Insert("Использование", Стр.Using);
		Описание.Insert("Имя", Стр.Name);
		Описание.Insert("Вид", Стр.Вид);
		Описание.Insert("Значение", Стр.Value);
		
		ОписаниеЗапроса.MultipartBody.Add(Описание);
	EndDo;
	
	ОписаниеЗапроса.Insert("Строки", New Array);
	
	For Each Стр Из RequestsTreeRow.GetItems() Цикл
		ОписаниеЗапроса.Строки.Add(ОписаниеЗапросаДляСохраненияВФайл(Стр));
	EndDo;

	Return ОписаниеЗапроса;
EndFunction



&AtServer
Function ПолучитьСтрокуДанныхФайлаДляСохраненияВФайл()
	
	СохраняемыеДанные = New Structure;
	СохраняемыеДанные.Insert("ВерсияФормата", 3);
	СохраняемыеДанные.Insert("Запросы", New Array);
	
	For Each СтрокаАлгоритма Из RequestsTree.GetItems() Цикл
		СохраняемыеДанные.Запросы.Add(ОписаниеЗапросаДляСохраненияВФайл(СтрокаАлгоритма));
	EndDo;
	
	Return УИ_ОбщегоНазначенияКлиентСервер.мЗаписатьJSON(СохраняемыеДанные);

EndFunction

#EndRegion

#Region ВыполнениеЗапроса

// Выполнить запрос завершение подготовительных действий.
// 
// Parameters:
//  ПараметрыЗаврешения - Structure -  Параметры заврешения:
// * RowID - Number - 
// * AtClient - Булево -
// * Файл - Structure: 
// 		** Storage - String - Адрес файла во временном хранилище
// 		** ПолноеИмя - Строка 
&AtClient
Procedure ВыполнитьЗапросЗавершениеПодготовительныхДействий(ПараметрыЗаврешения)
	Если ПараметрыЗаврешения.AtClient Then
		ВыполнитьЗапросНаКлиенте(ПараметрыЗаврешения.RowID, ПараметрыЗаврешения.File);
	Else
		ВыполнитьЗапросНаСервере(ПараметрыЗаврешения.RowID, ПараметрыЗаврешения.File);
	EndIf;
EndProcedure

&AtClient
Procedure ВыполнитьЗапросЗавершениеЧтенияФайлаВоВременноеХранилище(Result, AdditionalParameters) Export
	Если Result = Undefined Then
		UT_CommonClientServer.MessageToUser("Не удалось поместить файл тела во временное хранилище");
		Return;
	EndIf;
	
	Если Result.Count() = 0 Then
		UT_CommonClientServer.MessageToUser("Не удалось поместить файл тела во временное хранилище");
		Return;
	EndIf;
	
	
	AdditionalParameters.Insert("Файл", Result[0]);
	
	ВыполнитьЗапросЗавершениеПодготовительныхДействий(AdditionalParameters);
EndProcedure

&AtClient
Procedure ВыполнитьЗапросЗавершениеЧтенияФайловМультипартВоВременноеХранилище(Result, AdditionalParameters) Export
	Если Result = Undefined Then
		UT_CommonClientServer.MessageToUser("Не удалось поместить файлы тела во временное хранилище");
		Return;
	EndIf;
	
	AdditionalParameters.Insert("Файл", Result);
	
	ВыполнитьЗапросЗавершениеПодготовительныхДействий(AdditionalParameters);
EndProcedure

&AtClientAtServerNoContext
Procedure AddListPreviouslyUsedHeadings(Form, Заголовки)
	For Each KeyValue Из Заголовки Цикл
		Если Form.СписокИспользованныхЗаголовков.НайтиПоЗначению(KeyValue.Key) = Undefined Then
			Form.СписокИспользованныхЗаголовков.Add(KeyValue.Key);
		EndIf;
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Procedure RecordRequestLog(Form, RequestsTreeRow, URLForExecution, HostAddress, Protocol, HTTPЗапрос,
	HTTPОтвет, ДатаНачала, Duration)

		//	Если HTTPОтвет = Undefined Then 
	//		Ошибка = True;
	//	Else 
	//		Ошибка=Не ПроверитьУспешностьВыполненияЗапроса(HTTPОтвет);//.КодСостояния<>КодУспешногоЗапроса;
	//	EndIf;
	ЗаписьЛога = RequestsTreeRow.RequestsHistory.Add();
	ЗаписьЛога.RequestURL = URLForExecution;

	ЗаписьЛога.HTTPFunction = RequestsTreeRow.HTTPRequest;
	ЗаписьЛога.HostAddress = HostAddress;
	ЗаписьЛога.Дата = ДатаНачала;
	ЗаписьЛога.ДлительностьВыполнения = Duration;
	ЗаписьЛога.Request = HTTPЗапрос.ResourceAddress;
	ЗаписьЛога.RequestHeaders = УИ_ОбщегоНазначенияКлиентСервер.ПолучитьСтрокуЗаголовковHTTP(HTTPЗапрос.Headers);
	ЗаписьЛога.BOM = RequestsTreeRow.UseBOM;
	ЗаписьЛога.RequestBodyEncoding = RequestsTreeRow.BodyEncoding;
	ЗаписьЛога.RequestBodyType = RequestsTreeRow.BodyType;
	ЗаписьЛога.Timeout = RequestsTreeRow.Timeout;

	Если RequestsTreeRow.BodyType = Form.TypesOfRequestBody.String Then
		ЗаписьЛога.ТелоЗапросаСтрока = HTTPЗапрос.GetBodyAsString();
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.File Then
		ЗаписьЛога.ТелоЗапросаИмяФайла = RequestsTreeRow.BodyFileName;
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.Bodyless Then
	Else
		BodyBinaryData = HTTPЗапрос.GetBodyAsBinaryData();
		ЗаписьЛога.ТелоЗапросаАдресДвоичныхДанных = PutToTempStorage(BodyBinaryData,
																				  Form.УникальныйИдентификатор);
		ЗаписьЛога.BinaryDataRequestBodyString = Строка(BodyBinaryData);
	EndIf;

	ЗаписьЛога.Protocol = Protocol;

	// Proxy
	ЗаписьЛога.UseProxy = RequestsTreeRow.UseProxy;
	ЗаписьЛога.ProxyServer = RequestsTreeRow.ProxyServer;
	ЗаписьЛога.ProxyPort = RequestsTreeRow.ProxyPort;
	ЗаписьЛога.ProxyUser = RequestsTreeRow.ProxyUser;
	ЗаписьЛога.ProxyPassword = RequestsTreeRow.ProxyPassword;
	ЗаписьЛога.ProxyOSAuthentication = RequestsTreeRow.ProxyOSAuthentication;

	ЗаписьЛога.StatusCode = ?(HTTPОтвет = Undefined, 500, HTTPОтвет.КодСостояния);

	Если HTTPОтвет = Undefined Then
		Return;
	EndIf;

	ЗаписьЛога.ResponseHeaders = УИ_ОбщегоНазначенияКлиентСервер.ПолучитьСтрокуЗаголовковHTTP(HTTPОтвет.Headers);

	СтрокаТелоОтвета = HTTPОтвет.GetBodyAsString();
	Если ValueIsFilled(СтрокаТелоОтвета) Then
#Если Сервер Then
		Если FindDisallowedXMLCharacters(СтрокаТелоОтвета) = 0 Then
			АдресТелаОтветаСтрокой = PutToTempStorage(СтрокаТелоОтвета, Form.УникальныйИдентификатор);
		Else
			АдресТелаОтветаСтрокой = PutToTempStorage("Содержит недопустимые символы XML",
																   Form.УникальныйИдентификатор);
		EndIf;
#Else

			Try
				АдресТелаОтветаСтрокой = PutToTempStorage(СтрокаТелоОтвета, Form.УникальныйИдентификатор);
			Except
				АдресТелаОтветаСтрокой = PutToTempStorage("Содержит недопустимые символы XML",
																	   Form.УникальныйИдентификатор);
			EndTry;
#EndIf
		ЗаписьЛога.АдресТелаОтветаСтрокой = АдресТелаОтветаСтрокой;
	EndIf;
	ДвоичныеДанныеОтвета = HTTPОтвет.GetBodyAsBinaryData();
	Если ДвоичныеДанныеОтвета <> Undefined Then
		ЗаписьЛога.ТелоОтветаАдресДвоичныхДанных = PutToTempStorage(ДвоичныеДанныеОтвета,
			Form.УникальныйИдентификатор);
		ЗаписьЛога.ТелоОтветаДвоичныеДанныеСтрокой = Строка(ДвоичныеДанныеОтвета);
	EndIf;

	ИмяФайлаОтвета = HTTPОтвет.GetBodyFileName();
	Если ИмяФайлаОтвета <> Undefined Then
		Файл = New File(ИмяФайлаОтвета);
		Если Файл.Существует() Then
			ДвоичныеДанныеОтвета = New BinaryData(ИмяФайлаОтвета);
			ЗаписьЛога.ТелоОтветаАдресДвоичныхДанных = PutToTempStorage(ДвоичныеДанныеОтвета,
				Form.УникальныйИдентификатор);
			ЗаписьЛога.ТелоОтветаДвоичныеДанныеСтрокой = Строка(ДвоичныеДанныеОтвета);
		EndIf;
	EndIf;
	
	RequestsTreeRow.RequestsHistory.Сортировать("Дата Убыв");
	
EndProcedure

&AtClientAtServerNoContext
Procedure FillRequestResultByHistoryRecord(Form, RequestsTreeRow, СтрокаИсторииЗапросов = Undefined)
	Если СтрокаИсторииЗапросов = Undefined Then
		Form.StatusCode = 0;
		Form.ResponseHeaders = "";
		Form.ResponseBodyString = "";
		Form.DurationInMilliseconds = 0;
		Form.ТелоОтветаДвоичныеДанныеСтрокой = "";
		Form.ТелоОтветаАдресДвоичныхДанных = "";

		Return;
	EndIf;

	Form.StatusCode = СтрокаИсторииЗапросов.StatusCode;
	Form.ResponseHeaders = СтрокаИсторииЗапросов.ResponseHeaders;
	Если IsTempStorageURL(СтрокаИсторииЗапросов.АдресТелаОтветаСтрокой) Then
		Form.ResponseBodyString = GetFromTempStorage(СтрокаИсторииЗапросов.АдресТелаОтветаСтрокой);
	Else
		Form.ResponseBodyString = "";
	EndIf;
	Form.DurationInMilliseconds = СтрокаИсторииЗапросов.ДлительностьВыполнения;
	Form.StatusCode = СтрокаИсторииЗапросов.StatusCode;
	Form.ТелоОтветаДвоичныеДанныеСтрокой = СтрокаИсторииЗапросов.ТелоОтветаДвоичныеДанныеСтрокой;
	Form.ТелоОтветаАдресДвоичныхДанных = СтрокаИсторииЗапросов.ТелоОтветаАдресДвоичныхДанных;
EndProcedure

#EndRegion

#Region СписокЗапросов

&AtClient 
Procedure СохранитьДанныеЗапросаВДеревоЗапросов()
	Если УИ_ИдентификаторТекущейСтрокиЗапросов = Undefined Then
		Return;
	EndIf;
	CurrentData = RequestsTree.FindByID(УИ_ИдентификаторТекущейСтрокиЗапросов);
	Если CurrentData = Undefined Then
		Return;
	EndIf;

	//Заголовки 
	CurrentData.Headers.Clear();
	Если EditHeadersWithTable Then
		For Each HeaderRow Из RequestHeadersTable Цикл
			НоваяСтрока = CurrentData.Headers.Add();
			НоваяСтрока.Key = HeaderRow.Key;
			НоваяСтрока.Value = HeaderRow.Value;
			НоваяСтрока.Using = HeaderRow.Using;
		EndDo;
	Else
		Заголовки = УИ_ОбщегоНазначенияКлиентСервер.ЗаголовкиHTTPЗапросаИзСтроки(ЗаголовкиСтрока);
		For Each KeyValue ИЗ Заголовки Цикл
			НоваяСтрока = CurrentData.Headers.Add();
			НоваяСтрока.Key = KeyValue.Key;
			НоваяСтрока.Value = KeyValue.Value;
			НоваяСтрока.Using = True;
		EndDo;
	EndIf;
		

//	CurrentData.Текст = УИ_РедакторКодаКлиент.ТекстКодаРедактора(ThisObject, "Код");
//	CurrentData.ИспользоватьОбработкуДляВыполненияКода = УИ_РедакторКодаКлиент.РежимИспользованияОбработкиДляВыполненияКодаРедактора(ThisObject,
//																																   "Код");
	
EndProcedure

&AtClient
Procedure ИзвлечьДанныеЗапросаИзСтрокиДерева()
	TreeRow = ТекущаяСтрокаЗапросов();
	Если TreeRow = Undefined Then
		Return;
	EndIf;
	
	//Заголовки 
	RequestHeadersTable.Clear();
	ЗаголовкиСтрока = "";
	Если EditHeadersWithTable Then
		For Each Стр Из TreeRow.Headers Цикл
			НоваяСтрока = RequestHeadersTable.Add();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, Стр);
		EndDo;
	Else
		ЗаголовкиСтрока = СтрокаЗаголовковПоТаблице(TreeRow.Headers);
	EndIf;
	
	RequestBodyBinaryDataString = "";
	Если TreeRow.BodyBinaryData <> Undefined Then
		ХранилищеДвоичныхДанных = TreeRow.BodyBinaryData; //см. УИ_ОбщегоНазначенияКлиентСервер.НовыйХранилищеЗначенияТипаДвоичныеДанные
		RequestBodyBinaryDataString = ХранилищеДвоичныхДанных.Представление;
	EndIf;

	ПриИзмененииВидаТелаЗапроса();
	ПриИзмененииВидаАутентификацииЗапроса();

	Если TreeRow.RequestsHistory.Count() > 0 Then
		FillRequestResultByHistoryRecord(ThisObject,
												 TreeRow,
												 TreeRow.RequestsHistory[0]);
	Else
		FillRequestResultByHistoryRecord(ThisObject,
												 TreeRow,
												 Undefined);
		
	EndIf;
	SetPreliminaryURL(TreeRow.GetID());
EndProcedure



#EndRegion

#Region ПодготовкаЗапроса

&AtClientAtServerNoContext
Procedure FillHeadersTableByString(СтрокаЗаголовков, RequestHeadersTable)
	RequestHeadersTable.Clear();
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(СтрокаЗаголовков);
	Для НомерСтроки = 1 По ТекстовыйДокумент.КоличествоСтрок() Цикл
		ЗаголовокСтр = ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки);

		If Not ValueIsFilled(ЗаголовокСтр) Then
			Continue;
		EndIf;

		МассивЗаголовка = StrSplit(ЗаголовокСтр, ":");
		Если МассивЗаголовка.Count() <> 2 Then
			Continue;
		EndIf;

		НС = RequestHeadersTable.Add();
		НС.Key = МассивЗаголовка[0];
		НС.Value = МассивЗаголовка[1];
		НС.Using = True;

	EndDo;
	
EndProcedure

&AtClient
Procedure УстановитьСтраницуРедактированияЗаголовковЗапроса()
	Если EditHeadersWithTable Then
		НоваяСтраница = Items.EditRequestHeadersPageGroupAsTable;
	Else
		НоваяСтраница = Items.EditRequestHeadersPageGroupAsText;
	EndIf;

	Items.EditRequestHeadersPagesGroup.CurrentPage = НоваяСтраница;

	//Теперь нужно заполнить заголовки на новой странице по старой странице
	Если EditHeadersWithTable Then
		FillHeadersTableByString(ЗаголовкиСтрока, RequestHeadersTable);
	Else
		ЗаголовкиСтрока = СтрокаЗаголовковПоТаблице(RequestHeadersTable);
	EndIf;
EndProcedure

#EndRegion

#Region ИсполнениеЗапроса

&AtClientAtServerNoContext
Procedure ВыполнитьЗапросНаКлиентеНаСервере(Form, TreeRow, BodyFileData = Undefined)
	URLForExecution = URLForExecution(TreeRow);
	StructureURL = UT_HTTPConnector.ParseURL(URLForExecution);

	HTTPConnection = ПодготовленноеСоединение(Form, TreeRow, StructureURL);

	StartExecution = CurrentUniversalDateInMilliseconds();
	Запрос = PreparedHTTPRequest(Form, TreeRow, StructureURL, BodyFileData);
	#Если AtClient Then
	ДатаНачала = ТекущаяДата();
	#Else
	ДатаНачала = ТекущаяДатаСеанса();
	#EndIf
	
	ПараметрыОбработкиResultаВыполненияЗапроса = New Structure;
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("Form", Form);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("TreeRow", TreeRow);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("HTTPConnection", HTTPConnection);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("Запрос", Запрос);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("StartExecution", StartExecution);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("ДатаНачала", ДатаНачала);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("URLForExecution", URLForExecution);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("StructureURL", StructureURL);
	ПараметрыОбработкиResultаВыполненияЗапроса.Insert("BodyFileData", BodyFileData);
	
#Если Клиент Then
	//@skip-check wrong-string-literal-content
	ОповещениеОЗавершенииВыполненияЗапроса = Новый ОписаниеОповещения("AfterRequestExecutionAtClient", Form,
		ПараметрыОбработкиResultаВыполненияЗапроса);
#EndIf	
	
	Try
		Если UT_CommonClientServer.PlatformVersionNotLess("8.3.21")
			 И TreeRow.AtClient Then
			Если TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.GET Then
				Ответ = HTTPConnection.ПолучитьАсинх(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.POST Then
				Ответ = HTTPConnection.ОтправитьДляОбработкиАсинх(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.DELETE Then
				Ответ = HTTPConnection.УдалитьАсинх(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.PUT Then
				Ответ = HTTPConnection.ЗаписатьАсинх(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.PATCH Then
				Ответ = HTTPConnection.ИзменитьАсинх(Запрос);
			Else
				Ответ = HTTPConnection.CallHTTPMethodAsync(TreeRow.HTTPRequest, Запрос);
			EndIf;
#Если Клиент Then
			УИ_МетодыСовмеcтимостиПлатформы_8_3_18Клиент.ЗадатьОповещениеДляОбещания(Ответ,
																					 ОповещениеОЗавершенииВыполненияЗапроса);
			Return;
#EndIf
		Else
			Если TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.GET Then
				Ответ = HTTPConnection.Получить(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.POST Then
				Ответ = HTTPConnection.ОтправитьДляОбработки(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.DELETE Then
				Ответ = HTTPConnection.Удалить(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.PUT Then
				Ответ = HTTPConnection.Записать(Запрос);
			ElsIf TreeRow.HTTPRequest = Form.TypesOfHTTPMethods.PATCH Then
				Ответ = HTTPConnection.Изменить(Запрос);
			Else
				Ответ = HTTPConnection.CallHTTPMethod(TreeRow.HTTPRequest, Запрос);
			EndIf;
			ПараметрыОбработкиResultаВыполненияЗапроса.Insert("Ответ", Ответ);
		EndIf;
	Except
		UT_CommonClientServer.MessageToUser(ОписаниеОшибки());
		
		ПараметрыОбработкиResultаВыполненияЗапроса.Insert("Ответ", Undefined);
	EndTry;
	AfterRequestExecutionAtClientAtServer(ПараметрыОбработкиResultаВыполненияЗапроса);

EndProcedure

&AtClient
Procedure ВыполнитьЗапросНаКлиенте(TreeRowId, BodyFileData = Undefined)
	TreeRow = RequestsTree.FindByID(TreeRowId);
	Если TreeRow = Undefined Then
		Return;
	EndIf;
	
	ВыполнитьЗапросНаКлиентеНаСервере(ThisObject, TreeRow, BodyFileData);
	
EndProcedure

&AtServer
Procedure ВыполнитьЗапросНаСервере(TreeRowId, BodyFileData = Undefined)
	TreeRow = RequestsTree.FindByID(TreeRowId);
	Если TreeRow = Undefined Then
		Return;
	EndIf;
	
	ВыполнитьЗапросНаКлиентеНаСервере(ThisObject, TreeRow, BodyFileData);
EndProcedure

&AtClientAtServerNoContext
Function ПодготовленноеСоединение(Form, RequestsTreeRow, StructureURL)
	Port = Undefined;
	Если ValueIsFilled(StructureURL.Port) Then
		Port = StructureURL.Port;
	EndIf;
		
	ProxySettings = Undefined;
	Если RequestsTreeRow.UseProxy Then
#If Not ВебКлиент Then
		ProxySettings = New InternetProxy(True);
		ProxySettings.Установить(StructureURL.Scheme,
								   RequestsTreeRow.ProxyServer,
								   RequestsTreeRow.ProxyPort,
								   RequestsTreeRow.ProxyUser,
								   RequestsTreeRow.ProxyPassword,
								   RequestsTreeRow.ProxyOSAuthentication);
#EndIf
	EndIf;

	UseNTMAuthentication = Undefined;
	Если UT_CommonClientServer.PlatformVersionNotLess("8.3.7") Then
		Если RequestsTreeRow.UseAuthentication
			 И RequestsTreeRow.AuthenticationType = AuthenticationTypes().NTML Then
			UseNTMAuthentication = True;
		EndIf;
	EndIf;

	SecuredConnection = Undefined;
	Если Lower(StructureURL.Scheme) = "https" Then
		SecuredConnection = UT_PlatformCompatibilityMethods_8_3_21_ClientServer.NewOpenSSLSecureConnection();
	EndIf;

	Return UT_PlatformCompatibilityMethods_8_3_21_ClientServer.NewHTTPConnection(StructureURL.Server,
																				   Port
																				   ,
																				   ,
																				   ProxySettings,
																				   RequestsTreeRow.Timeout,
																				   SecuredConnection,
																				   UseNTMAuthentication);

EndFunction

&AtClientAtServerNoContext
Function PreparedHTTPRequest(Form, RequestsTreeRow, StructureURL, BodyFileData)
	Headers = New Map;

	RequestString = StructureURL.Path;

	ParametersString = "";
	For Each KeyValue In StructureURL.RequestParameters Do
		ParametersString = ParametersString
						   + ?(Not ValueIsFilled(ParametersString), "?", "&")
						   + KeyValue.Key
						   + "="
						   + KeyValue.Value;
	EndDo;

	ResourceAddress = RequestString + ParametersString;
	
	BodyParameters = New Structure;
	BodyParameters.Insert("Body", Undefined);
	BodyParameters.Insert("BodyEncoding", Undefined);
	BodyParameters.Insert("BodyBOM", Undefined);
	
	If RequestsTreeRow.BodyType = Form.TypesOfRequestBody.Bodyless Then
		// We don't do anything. no body
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.String Then
		If ValueIsFilled(RequestsTreeRow.BodyString) Then
#If WebClient Then
			BOM = Undefined;
			If RequestsTreeRow.UseBOM <> 0 Then
				UT_CommonClientServer.MessageToUser(NStr("ru = 'Настройка использования BOM игнорируется на веб клиенте'; en = 'Setting to use BOM is ignored on the web client'"));
			EndIf;
#Else
				If RequestsTreeRow.UseBOM = 0 Then
					BOM = ByteOrderMarkUse.Auto;
				ElsIf (RequestsTreeRow.UseBOM = 1) Then
					BOM = ByteOrderMarkUse.Use;
				Else
					BOM = ByteOrderMarkUse.DontUse;
				EndIf;
#EndIf                
			BodyParameters.BodyBOM = BOM;
			WithoutTextEncoding = RequestsTreeRow.BodyEncoding = "Auto";
#If WebClient Then
			If Not WithoutTextEncoding Then
				WithoutTextEncoding = True;
				UT_CommonClientServer.MessageToUser(NStr("ru = 'При запросе в вебклиенте тело устанавливается в кодровке UTF-8 и настройка кодировки игнорируется'; en = 'When requesting in the web client, the body is set to UTF-8 encoding and the encoding setting is ignored'"));
			EndIf;

#EndIf
			BodyParameters.Body = RequestsTreeRow.BodyString;

			If Not WithoutTextEncoding Then
				Try
					BodyEncoding = UT_PlatformCompatibilityMethods_8_3_21_ClientServer.TextEncodingByName(RequestsTreeRow.BodyEncoding);
				Except
					BodyEncoding = RequestsTreeRow.BodyEncoding;
				EndTry;
				BodyParameters.BodyEncoding = BodyEncoding;
			EndIf;
		EndIf;
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.BinaryData Then
		If RequestsTreeRow.BodyBinaryData <> Undefined Then
			BodyBinaryData = UT_Common.ValueFromBinaryDataContainerStorage(RequestsTreeRow.BodyBinaryData);
			
			If TypeOf(BodyBinaryData) = Type("BinaryData") Then 
				BodyParameters.Body = BodyBinaryData;	
			EndIf;
		EndIf;
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.MultypartForm Then
		MultypartItemsType = MultypartItemsType();
		RowDelimiterForMultipartRequest = RowDelimiterForMultipartRequest();
		
		FilesToCombine = New Array;
		For RowIndex = 0 To RequestsTreeRow.MultipartBody.Count() - 1 Do
			MultypartItemRow = RequestsTreeRow.MultipartBody[RowIndex];
			If Not MultypartItemRow.Using Then
				Continue;
			EndIf;
			
			If MultypartItemRow.Type = MultypartItemsType.String Then

				InputFile = ""
							+ RowDelimiterForMultipartRequest
							+ "--"
							+ Form.MultipartBodySplitter
							+ RowDelimiterForMultipartRequest
							+ "Content-Disposition: form-data;name="""
							+ MultypartItemRow.Name
							+ """"
							+ RowDelimiterForMultipartRequest 
							+ RowDelimiterForMultipartRequest;

				FilesToCombine.Add(GetBinaryDataFromString(InputFile));

				FilesToCombine.Add(GetBinaryDataFromString(MultypartItemRow.Value));

			ElsIf MultypartItemRow.Type = MultypartItemsType.File Then
				If Not ValueIsFilled(MultypartItemRow.Value) Then
					Continue;
				EndIf;

				BinaryDataAddress = BodyFileData[RowIndex];
				If BinaryDataAddress = Undefined Then
					Continue;
				EndIf;
				If Not IsTempStorageURL(BinaryDataAddress) Then
					Continue;
				EndIf;


				File = New File(MultypartItemRow.Value);

				InputFile = ""
							  + RowDelimiterForMultipartRequest
							  + "--"
							  + Form.MultipartBodySplitter
							  + RowDelimiterForMultipartRequest
							  + "Content-Disposition: form-data;name="""
							  + MultypartItemRow.Name
							  + """;filename="""
							  + File.Name
							  + """"
							  + RowDelimiterForMultipartRequest
							  + "Content-Type: application/octet-stream"
							  + RowDelimiterForMultipartRequest
							  + RowDelimiterForMultipartRequest;

				FilesToCombine.Add(GetBinaryDataFromString(InputFile));
				FilesToCombine.Add(GetFromTempStorage(BinaryDataAddress));
			EndIf;
				
		EndDo;

		InputFile = ""
					  + RowDelimiterForMultipartRequest
					  + "--"
					  + Form.MultipartBodySplitter
					  + "--"
					  + RowDelimiterForMultipartRequest;

		FilesToCombine.Add(GetBinaryDataFromString(InputFile));

		FinalBD = ConcatBinaryData(FilesToCombine);

		SendFileSize = Format(FinalBD.Size(), "NG=0;");
		BodyParameters.Body = FinalBD;
		
		Headers.Insert("Content-Length", SendFileSize);		
	Else
		If RequestsTreeRow.AtClient Then      
			BodyParameters.Body = BodyFileData.ПолноеИмя;
		Else
#If Not WebClient Then
			BodyBinaryData = GetFromTempStorage(BodyFileData.Storage);
			If TypeOf(BodyBinaryData) = Тип("BinaryData") Then
				File = New File(RequestsTreeRow.BodyFileName);
			//@skip-check missing-temporary-file-deletion
				TemporaryFile = GetTempFileName(File.Extension);
				BodyBinaryData.Write(TemporaryFile);

				BodyParameters.Body = TemporaryFile;

				Headers.Insert("Content-Length", Format(BodyBinaryData.Размер(), "NG=0;"));

			EndIf;
#EndIf
		EndIf;
	EndIf;

	// Now you need to set the request headers

	For Each HeaderRow In RequestsTreeRow.Headers Do
		If Not HeaderRow.Using Then
			Continue;
		EndIf;
		Headers.Insert(HeaderRow.Key, HeaderRow.Value);
	EndDo;

	SetAuthenticationHeaderInHTTPRequest(RequestsTreeRow, Headers);
	NewRequest = UT_PlatformCompatibilityMethods_8_3_21_ClientServer.NewHTTPRequest(ResourceAddress, Headers);
	
	If RequestsTreeRow.BodyType = Form.TypesOfRequestBody.String Then
		If BodyParameters.BodyEncoding = Undefined Then
			//@skip-check unknown-method-property
			NewRequest.SetBodyFromString(BodyParameters.Body, , BodyParameters.BodyBOM);
		Else
			//@skip-check unknown-method-property
			NewRequest.SetBodyFromString(BodyParameters.Body, BodyParameters.BodyEncoding, BodyParameters.BodyBOM);
		EndIf;
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.BinaryData Then
		If TypeOf(BodyParameters.Body) = Type("BinaryData") Then
			//@skip-check unknown-method-property
			NewRequest.SetBodyFromBinaryData(BodyParameters.Body);
		EndIf;
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.MultypartForm Then
		//@skip-check unknown-method-property
		NewRequest.SetBodyFromBinaryData(BodyParameters.Body);
	ElsIf RequestsTreeRow.BodyType = Form.TypesOfRequestBody.File Then
		If BodyParameters.Body <> Undefined Then
			//@skip-check unknown-method-property
			NewRequest.SetBodyFileName(BodyParameters.Body);
		EndIf;
	EndIf;
	Return NewRequest;
EndFunction

&AtClientAtServerNoContext
Procedure SetAuthenticationHeaderInHTTPRequest(RequestsTreeRow, RequestHeaders)
	Types = AuthenticationTypes();
	If Not ValueIsFilled(RequestsTreeRow.AuthenticationType)
		 Or RequestsTreeRow.AuthenticationType = Types.None Then
		Return;
	EndIf;
	
	If Not RequestsTreeRow.UseAuthentication Then
		Return;
	EndIf;
	
	HeaderName = "Authorization";
	If RequestHeaders.Get(HeaderName) <> Undefined Then
		Return;
	EndIf;
	
	HeaderValue = "";
	
	Если RequestsTreeRow.AuthenticationType = Types.Basic Then
		Prefix = "Basic";

		HeaderValue = Prefix
							+ " "
							+ Base64Строка(GetBinaryDataFromString(RequestsTreeRow.AuthenticationUser
							+ ":"
							+ RequestsTreeRow.AuthenticationPassword));

	ElsIf RequestsTreeRow.AuthenticationType = Types.BearerToken Then 
		Prefix = TrimAll(RequestsTreeRow.AuthenticationTokenPrefix);
		If Not ValueIsFilled(Prefix) Then
			Prefix = "Bearer";
		EndIf;
		HeaderValue = Prefix + " " + RequestsTreeRow.AuthenticationPassword;
	Else
		Return;
	EndIf;
	
	RequestHeaders.Insert(HeaderName, HeaderValue);
EndProcedure

// После выполнения запроса на клиенте на сервере.
// 
// Parameters:
//  AdditionalParameters - Structure -  Дополнительные параметры:
// * Form - УправляемаяФорма - 
// * TreeRow - ДанныеФормыЭлементДерева - 
// * HTTPConnection - HTTPСоединение - 
// * Запрос - HTTPЗапрос - 
// * StartExecution - Number - 
// * ДатаНачала - Дата - 
// * URLForExecution - String -
// * StructureURL - Structure - :
// ** Scheme - String - 
// ** Аутентификация - Structure - :
// *** Пользователь - String - 
// *** Пароль - String - 
// ** Сервер - String - 
// ** Port - Number - 
// ** Path - Строка, Number - 
// ** RequestParameters - Map - 
// ** Фрагмент - String - 
// * BodyFileData - Structure, Undefined - :
// ** Storage - String - 
// ** ПолноеИмя - String - 
// * Response - HTTPОтвет - 
&AtClientAtServerNoContext
Procedure AfterRequestExecutionAtClientAtServer(AdditionalParameters)
	FinishExecution = CurrentUniversalDateInMilliseconds();

	DurationInMilliseconds = FinishExecution - AdditionalParameters.StartExecution;

	RecordRequestLog(AdditionalParameters.Form,
							AdditionalParameters.TreeRow,
							AdditionalParameters.URLForExecution,
							AdditionalParameters.StructureURL.Server,
							AdditionalParameters.StructureURL.Scheme,
							AdditionalParameters.Request,
							AdditionalParameters.Response,
							AdditionalParameters.ДатаНачала,
							DurationInMilliseconds);

	FillRequestResultByHistoryRecord(AdditionalParameters.Form,
							AdditionalParameters.TreeRow,
							AdditionalParameters.TreeRow.RequestsHistory[0]);

	AddListPreviouslyUsedHeadings(AdditionalParameters.Form,
							AdditionalParameters.Request.Headers);

	BodyFileName = AdditionalParameters.Request.GetBodyFileName();
	Если BodyFileName <> Undefined Then
		//@skip-check empty-except-statement
		Try
			DeleteFiles(BodyFileName);
		Except
		EndTry;
	EndIf;
	Если AdditionalParameters.BodyFileData <> Undefined Then
		Если TypeOf(AdditionalParameters.BodyFileData) = Type("Structure") Then
		//@skip-check empty-except-statement
			Try
				DeleteFromTempStorage(AdditionalParameters.BodyFileData.Storage);
			Except
			EndTry;
		ElsIf TypeOf(AdditionalParameters.BodyFileData) = Type("Map") Then
			For Each KeyValue In AdditionalParameters.BodyFileData Do
			//@skip-check empty-except-statement
				Try
					DeleteFromTempStorage(KeyValue.Value);
				Except
				EndTry;
			EndDo;
		EndIf;
	EndIf;
	
	
EndProcedure

&AtClient 
Procedure AfterRequestExecutionAtClient(ServerResponse, AdditionalParameters) Export
	If TypeOf(ServerResponse) = Type("ErrorInfo") Then
		UT_CommonClientServer.MessageToUser(ServerResponse.Описание);
		Response = Undefined;
	Else
		Response = ServerResponse;
	EndIf;
		
	AdditionalParameters.Insert("Response", Response);
	
	AfterRequestExecutionAtClientAtServer(AdditionalParameters);	
EndProcedure

#EndRegion

#Region RequestResult

#EndRegion

#Region General

&AtServerNoContext
Function URLForExecutionWithEncodedParameters(URL, Parameters)
	Return UT_HTTPConnector.UI_PreparedURL(URL, Parameters);
EndFunction

&AtClientAtServerNoContext
Function URLForExecution(RequestsTreeRow)
	URLParameters = New Map;
	
	For Each Str In RequestsTreeRow.URLParameters Do
		If Not Str.Using Then
			Continue;
		EndIf;
		If Not ValueIsFilled(Str.Name) Then
			Continue;
		EndIf;
		
		NameArray = URLParameters[Str.Name];
		If NameArray = Undefined Then
			URLParameters.Insert(Str.Name, New Array);
			NameArray = URLParameters[Str.Name];
		EndIf;
		NameArray.Add(Str.Value);
	EndDo;
	
	Return URLForExecutionWithEncodedParameters(RequestsTreeRow.RequestURL, URLParameters);
EndFunction

&AtServer
Procedure SetPreliminaryURL(TreeRowId)
	PreliminaryURL = "";
	If TreeRowId = Undefined Then
		Return;
	EndIf;
	
	CurrentTreeRow = RequestsTree.FindByID(TreeRowId);
	If CurrentTreeRow = Undefined Then
		Return;
	EndIf;
		
	PreliminaryURL = URLForExecution(CurrentTreeRow)
EndProcedure

&AtClientAtServerNoContext
Function RowDelimiterForMultipartRequest()
	Return Chars.CR + Chars.LF;
EndFunction

&AtClient
Function PossibleRequestExecution(RequestRow)
	If Not RequestRow.AtClient Then
		Return True;
	EndIf;	
	
	If Not UT_CommonClient.IsWebClient() Then
		Return True;
	EndIf;		
	
	Result = True;

	If Not UT_CommonClientServer.PlatformVersionNotLess("8.3.21") Then
		UT_CommonClientServer.MessageToUser(NStr("ru = 'Запросы в контексте веб-клиента доступны, начиная с версии платформы 8.3.21'; en = 'Requests in the context of the web client are available starting from platform version 8.3.21'"));
		Result = False;
	EndIf;

	If RequestRow.UseProxy Then
		UT_CommonClientServer.MessageToUser(NStr("ru = 'В веб клиенте не поддерживается использование прокси в HTTP запросах'; en = 'The web client does not support the use of proxies in HTTP requests'"));
		Result = False;
	EndIf;
	
	Return Result;
EndFunction

&AtClientAtServerNoContext
Function СтрокаЗаголовковПоТаблице(HeaderTable)
	HeadersStringsArray = New Array;
	For Each Str In HeaderTable Do
		If Not Str.Using Then
			Continue;
		EndIf;
		HeadersStringsArray.Add(Str.Key + ":" + Str.Value);
	EndDo;

	Return StrConcat(HeadersStringsArray, Chars.LF);

EndFunction

&AtClientAtServerNoContext
Function RequestBodyEncodingsTypes()
	Types = New Structure;
	Types.Insert("Auto", "Auto");
	Types.Insert("System", "System");
	Types.Insert("ANSI", "ANSI");
	Types.Insert("OEM", "OEM");
	Types.Insert("UTF8", "UTF8");
	Types.Insert("UTF16", "UTF16");
	
	
	Return Types;
EndFunction

&AtServer
Procedure FillChoiceListListOfTextEncodings()
	Items.RequestBodyEncoding.ChoiceList.Clear();

	Types = RequestBodyEncodingsTypes();
	For Each KeyValue In Types Do
		Items.RequestBodyEncoding.ChoiceList.Add(KeyValue.Value);	
	EndDo;
	
EndProcedure

&AtServer
Procedure InitializeForm()
	MultipartBodySplitter = "X-TOOLS-UI-1C-BOUNDARY";
	
	FillChoiceListListOfTextEncodings();
	
	Items.RequestBodyType.ChoiceList.Clear();
	TypesOfRequestBody = RequestBodyTypes();
	Items.RequestBodyType.ChoiceList.Add(TypesOfRequestBody.Bodyless, "Bodyless");
	Items.RequestBodyType.ChoiceList.Add(TypesOfRequestBody.String);
	Items.RequestBodyType.ChoiceList.Add(TypesOfRequestBody.BinaryData, "Binary data");
	Items.RequestBodyType.ChoiceList.Add(TypesOfRequestBody.File);
	Items.RequestBodyType.ChoiceList.Add(TypesOfRequestBody.MultypartForm, "Multipart form");

	TypesOfHTTPMethods = TypesOfHTTPMethods();
	Items.HTTPRequest.ChoiceList.Clear();
	For Each KeyValue In TypesOfHTTPMethods Do
		Items.HTTPRequest.ChoiceList.Add(KeyValue.Value);
	EndDo;
	
	TypesStringContentBody = TextContentTypes();
	Items.RequestsTreeTypeOfStringContent.ChoiceList.Clear();
	Items.RequestsTreeTypeOfStringContent.ChoiceList.Add("None");
	For Each KeyValue In TypesStringContentBody Do
		Items.RequestsTreeTypeOfStringContent.ChoiceList.Add(KeyValue.Key);
	EndDo;
	
	Items.RequestsTreeAuthenticationType.ChoiceList.Clear();
	
	AuthenticationTypes = AuthenticationTypes();
	Items.RequestsTreeAuthenticationType.ChoiceList.Add(AuthenticationTypes.None);
	Items.RequestsTreeAuthenticationType.ChoiceList.Add(AuthenticationTypes.Basic, NStr("ru = 'Базовая(Логин,Пароль)'; en = 'Basic(Login,Password)'"));
	Items.RequestsTreeAuthenticationType.ChoiceList.Add(AuthenticationTypes.BearerToken, NStr("ru = 'Bearer Токен'; en = 'Bearer Token'"));
	Если UT_CommonClientServer.PlatformVersionNotLess("8.3.7") Then
		Items.RequestsTreeAuthenticationType.ChoiceList.Add(AuthenticationTypes.NTML, NStr("ru = 'NTML (аутентифкация ОС)'; en = 'NTML (OS authentication)'"));
	EndIf;
	
	Items.MultipartBodyRequestsTreeType.ChoiceList.Clear();
	
	MultypartItemsType = MultypartItemsType();
	Items.MultipartBodyRequestsTreeType.ChoiceList.Add(MultypartItemsType.String);
	Items.MultipartBodyRequestsTreeType.ChoiceList.Add(MultypartItemsType.File);
		
	InitializeRequestsTree();	

EndProcedure


&AtServer
Procedure InitializeRequestsTree()
	TreeItems = RequestsTree.GetItems();
	If TreeItems.Count() > 0 Then
		Return;
	EndIf;
	
	NewRow = TreeItems.Add();
	InitializeRequestsTreeString(NewRow, ThisObject);
EndProcedure


&AtClientAtServerNoContext
Procedure InitializeRequestsTreeString(RequestsTreeRow, Form)
	RequestsTreeRow.HTTPRequest = Form.TypesOfHTTPMethods.GET;
	RequestsTreeRow.BodyType = Form.TypesOfRequestBody.Bodyless;
	
	RequestBodyEncodingsTypes = RequestBodyEncodingsTypes();
	RequestsTreeRow.BodyEncoding = RequestBodyEncodingsTypes.Auto;
	
	RequestsTreeRow.Timeout = 30;
	RequestsTreeRow.TypeOfStringContent = "None";
	
	If Not ValueIsFilled(RequestsTreeRow.Name) Then
		RequestsTreeRow.Name = "Request" + Format(RequestsTreeRow.GetID(), "NG=0;");
	EndIf;
	
	AuthenticationTypes = AuthenticationTypes();
	RequestsTreeRow.AuthenticationType = AuthenticationTypes.None;
	
EndProcedure



// Update form title.
&AtClient
Procedure UpdateTitle()

	Title = InitialHeader + ?(RequestsFileName <> "", ": " + RequestsFileName, "");

EndProcedure


#EndRegion


&AtServer
Procedure FillBodyBinaryDataFromFileFinishAtServer(Address, RowID)
	CurrentData = RequestsTree.FindByID(RowID);
	If CurrentData = Undefined Then
		Return;
	EndIf;

	BinaryData = GetFromTempStorage(Address);

	CurrentData.BodyBinaryData = UT_Common.ValueStorageContainerBinaryData(BinaryData);

	RequestBodyBinaryDataString = CurrentData.BodyBinaryData.Представление;	
EndProcedure

&AtClient
Procedure FillBodyBinaryDataFromFileFinish(Result, Address, ChosenFileName, AdditionalParameters) Export
	If Not Result Then
		Return;
	EndIf;

	FillBodyBinaryDataFromFileFinishAtServer(Address, AdditionalParameters.CurrentRowID);

EndProcedure

// Request body file name start choose finish.
// 
// Parameters:
//  ChosenFiles - Array of String - Chosen fales
//  AdditionalParameters - Structure:
//  * RowID - Number
&AtClient
Procedure RequestBodyFileNameStartChooseFinish(ChosenFiles, AdditionalParameters) Export

	If ChosenFiles = Undefined Then
		Return;
	EndIf;

	If ChosenFiles.Count() = 0 Then
		Return;
	EndIf;

	RequestString = RequestsTree.FindByID(AdditionalParameters.RowID);
	If RequestString = Undefined Then
		Return;
	EndIf;

	RequestString.BodyFileName = ChosenFiles[0];
EndProcedure

&AtServer
Procedure FillByDebaggingData(DebuggingDataAddress)
	TreeItems = RequestsTree.GetItems();
	TreeItems.Clear();
	
	RequestNewRow = TreeItems.Add();
	InitializeRequestsTreeString(RequestNewRow, ThisObject);
	RequestNewRow.Name = "Debugging";
	
	DebuggingData = GetFromTempStorage(DebuggingDataAddress);

	RequestNewRow.RequestURL = "";
	If Not ValueIsFilled(DebuggingData.Protocol) Then
		RequestNewRow.RequestURL = "http";
	Else
		RequestNewRow.RequestURL = DebuggingData.Protocol;
	EndIf;

	RequestNewRow.RequestURL = RequestNewRow.RequestURL + "://" + DebuggingData.HostAddress;

	If ValueIsFilled(DebuggingData.Port) Then
		SpecialPort = True;
		If (Not ValueIsFilled(DebuggingData.Protocol) Or DebuggingData.Protocol = "http")
			 И DebuggingData.Port = 80 Then
			SpecialPort = False;
		ElsIf DebuggingData.Protocol = "https" And DebuggingData.Port = 443 Then
			SpecialPort = False;
		EndIf;

		If SpecialPort Then
			RequestNewRow.RequestURL = RequestNewRow.RequestURL + ":" + Format(DebuggingData.Port, "NG=0;");
		EndIf;
	EndIf;

	If Not StrStartsWith(DebuggingData.Request, "/") Then
		RequestNewRow.RequestURL = RequestNewRow.RequestURL + "/";
	EndIf;

	RequestNewRow.RequestURL = RequestNewRow.RequestURL + DebuggingData.Request;

	EditHeadersWithTable = True;
	Items.EditRequestHeadersPagesGroup.CurrentPage = Items.EditRequestHeadersPageGroupAsTable;

	Headers = DebuggingData.Headers;

	//Removing unused characters from headers string
	SymbolPosition = FindDisallowedXMLCharacters(Headers);
	While  SymbolPosition > 0 Do
		If SymbolPosition = 1 Then
			Headers = Mid(Headers, 2);
		ElsIf SymbolPosition = StrLen(Headers) Then
			Headers = Left(Headers, StrLen(Headers) - 1);
		Else
			NewHeaders = Left(Headers, SymbolPosition - 1) + Mid(Headers, SymbolPosition + 1);
			Headers = NewHeaders;
		EndIf;

		SymbolPosition = FindDisallowedXMLCharacters(Headers);
	EndDo;

	FillHeadersTableByString(Headers, RequestNewRow.Headers);
	FillBodyRequestByDebugData(RequestNewRow, DebuggingData);
	FillAuthenticationByDebugData(RequestNewRow, DebuggingData);

	If ValueIsFilled(DebuggingData.ProxyServer) Then
		RequestNewRow.UseProxy = True;

		RequestNewRow.ProxyServer = DebuggingData.ProxyServer;
		RequestNewRow.ProxyPort = DebuggingData.ProxyPort;
		RequestNewRow.ProxyUser = DebuggingData.ProxyUser;
		RequestNewRow.ProxyPassword = DebuggingData.ProxyPassword;
		RequestNewRow.ProxyOSAuthentication = DebuggingData.UseOSAuthentication;
	EndIf;

EndProcedure

&AtServer
Procedure FillBodyRequestByDebugData(RequestNewRow, DebuggingData)

	If DebuggingData.RequestBody <> Undefined Then
		If FindDisallowedXMLCharacters(DebuggingData.RequestBody) = 0 Then
			RequestNewRow.BodyType = TypesOfRequestBody.String;
			RequestNewRow.BodyString = DebuggingData.RequestBody;
			Return;
		EndIf;
	EndIf;

	If DebuggingData.Property("BodyBinaryData") Then
		If TypeOf(DebuggingData.BodyBinaryData) = Type("BinaryData") Then
			RequestNewRow.BodyType = TypesOfRequestBody.BinaryData;
			RequestNewRow.BodyBinaryData = UT_Common.ValueStorageContainerBinaryData(DebuggingData.BodyBinaryData);
			Return;
		EndIf;
	EndIf;
	If DebuggingData.Property("RequestFileName") Then
		RequestNewRow.BodyType = TypesOfRequestBody.File;
		RequestNewRow.BodyFileName = DebuggingData.RequestFileName;
		Return;
	EndIf;

	RequestNewRow.BodyType = TypesOfRequestBody.Bodyless;
EndProcedure

&AtServer
Procedure FillAuthenticationByDebugData(RequestNewRow, DebuggingData)
	AuthenticationTypes = AuthenticationTypes();
	If DebuggingData.Property("ConnectionUseOSAuthentication") Then
		If DebuggingData.ConnectionUseOSAuthentication Then
			RequestNewRow.AuthenticationType = AuthenticationTypes.NTML;
			RequestNewRow.UseAuthentication = True;
			Return;
		EndIf;
	EndIf;
	
	SearchedTitle = "authorization";
	AuthenticationHeaderValue = "";
	
	For Each Str In RequestNewRow.Headers Do
		If Lower(Str.Key)	= SearchedTitle Then
			AuthenticationHeaderValue = Str.Value;
			Break;
		EndIf;	
	EndDo;
	
	If Not ValueIsFilled(AuthenticationHeaderValue) Then
		Return;
	EndIf;
	
	RowsValuesHeader = StrSplit(AuthenticationHeaderValue, " ");
	If RowsValuesHeader.Count() < 2 Then
		Return;
	EndIf;
	
	Scheme = RowsValuesHeader[0];
	If Lower(Scheme) = "basic" Then
		RequestNewRow.AuthenticationType = AuthenticationTypes.Basic;
		RequestNewRow.UseAuthentication = True;
		
		//@skip-check empty-except-statement
		Try
			UserString = GetStringFromBinaryData(Base64Value(RowsValuesHeader[1]));
		Except
		EndTry;
	
		UserNameRowArray = StrSplit(UserString, ":");
		RequestNewRow.AuthenticationUser = UserNameRowArray[0];
		
		If UserNameRowArray.Count() > 1 Then
			UserNameRowArray.Delete(0);
			RequestNewRow.AuthenticationPassword = StrConcat(UserNameRowArray,":");
		EndIf;
	ElsIf Lower(Scheme) = "bearer" Then 
		RequestNewRow.AuthenticationType = AuthenticationTypes.BearerToken;
		RequestNewRow.UseAuthentication = True;
		RequestNewRow.AuthenticationPassword = RowsValuesHeader[1];
	EndIf;
EndProcedure

// Edit request body in JSON editor.
// 
// Parameters:
//  Result - Строка, Undefined- Result
//  AdditionalParameters - Structure:
//  * ТекущаяСтрока - Number, Undefined -
&AtClient
Procedure EditRequestBodyInJSONEditorFinish(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	If AdditionalParameters.CurrentRow = Undefined Then
		Return;
	EndIf;
	
	TreeRow = RequestsTree.FindByID(AdditionalParameters.CurrentRow);
	If TreeRow = Undefined Then
		Return;
	EndIf;

	TreeRow.BodyString = Result;
	
	//FillJSONStructureInRequestsTree();
EndProcedure


&AtServer
Function GeneratedHTTPRequestInitializationConnection(RequestsTreeRow, StructureURL)
	If RequestsTreeRow.UseProxy Then
		ProxySettingsText = StrTemplate("ProxyProtocol = %1;
										 |ProxyServer = %2;
										 |ProxyPort = %3;
										 |ProxyUser = %4;
										 |ProxyPassword = %5;
										 |ProxyOSAuthentication = %6;
										 |
										 |ProxySettings = New InternetProxy(True);
										 |ProxySettings.Set(ProxyProtocol,
										 |					ProxyServer,
										 |					ProxyPort,
										 |					ProxyUser,
										 |					ProxyPassword,
										 |					ProxyOSAuthentication);",
										 UT_CodeGenerator.StringInCodeString(StructureURL.Scheme),
										 UT_CodeGenerator.StringInCodeString(RequestsTreeRow.ProxyServer),
										 UT_CodeGenerator.NumberInCodeString(RequestsTreeRow.ProxyPort),
										 UT_CodeGenerator.StringInCodeString(RequestsTreeRow.ProxyUser),
										 UT_CodeGenerator.StringInCodeString(RequestsTreeRow.ProxyPassword),
										 UT_CodeGenerator.BooleanInCodeString(RequestsTreeRow.ProxyOSAuthentication));
	Else
		ProxySettingsText = "ProxySettings = " + UT_CodeGenerator.UndefinedInCodeString() + ";";
	EndIf;	
	
	Port = UT_CodeGenerator.UndefinedInCodeString();
	If ValueIsFilled(StructureURL.Port) Then
		Port = UT_CodeGenerator.NumberInCodeString(StructureURL.Port);
	EndIf;	
		
	UseNTMAuthentication = Undefined;
	If UT_CommonClientServer.PlatformVersionNotLess("8.3.7") Then
		If RequestsTreeRow.UseAuthentication
			 И RequestsTreeRow.AuthenticationType = AuthenticationTypes().NTML Then
			UseNTMAuthentication = True;
		EndIf;
	EndIf;

	SecuredConnection = UT_CodeGenerator.UndefinedInCodeString();
	If Lower(StructureURL.Scheme) = "https" Then
		SecuredConnection = "New OpenSSLSecureConnection";
	EndIf;
	
	If UseNTMAuthentication = Undefined Then
		UseNTMAuthenticationForCode = UT_CodeGenerator.UndefinedInCodeString();
		HTTPConnection = "New HTTPConnection(Server, Port , ,ProxySettings, Timeout, SecuredConnection)";
	Else
		UseNTMAuthenticationForCode = UT_CodeGenerator.BooleanInCodeString(UseNTMAuthentication);
		HTTPConnection = "New HTTPConnection(Server, Port , ,ProxySettings, Timeout, SecuredConnection, UseNTMAuthentication)";
	EndIf;

	HTTPConnectionsInitializationText = StrTemplate("
												|Server = %1;
												|Port = %2;
												|UseNTMAuthentication = %3;
												|SecuredConnection = %4;
												|Timeout = %5;
												|
												|HTTPConnection = %6;",
												UT_CodeGenerator.StringInCodeString(StructureURL.Server),
												Port,
												UseNTMAuthenticationForCode,
												SecuredConnection,
												UT_CodeGenerator.NumberInCodeString(RequestsTreeRow.Timeout),
												HTTPConnection);
	
	Return ProxySettingsText + HTTPConnectionsInitializationText;
EndFunction

&AtServer
Function GeneratedHTTPRequestInitializationCode(RequestsTreeRow, StructureURL)
	RowsToConcatenate = New Array;
	
	RowsToConcatenate.Add(StrTemplate("NewRequest = New HTTPRequest;
											|NewRequest.ResourceAddress = %1;
											|", UT_CodeGenerator.StringInCodeString(StructureURL.Path)));
	
	
	
	For Each HeaderRow In RequestsTreeRow.Headers Do
		If Not HeaderRow.Using Then
			Continue;
		EndIf;

		RowsToConcatenate.Add(StrTemplate("NewRequest.Headers.Insert(%1,%2);",
												UT_CodeGenerator.StringInCodeString(HeaderRow.Key),
												UT_CodeGenerator.StringInCodeString(HeaderRow.Value)));
	EndDo;

	AuthenticationTypes = AuthenticationTypes();
	If RequestsTreeRow.UseAuthentication
		 And ValueIsFilled(RequestsTreeRow.AuthenticationType)
		 And RequestsTreeRow.AuthenticationType <> AuthenticationTypes.None Then

		If RequestsTreeRow.AuthenticationType = AuthenticationTypes.Basic Then
			RowsToConcatenate.Add(StrTemplate("
													|// Authentication Basic
													|AuthenticationUser = %1;
													|AuthenticationPassword = %2;
													|NewRequest.Headers.Insert(""Authorization"", ""Basic ""+Base64Строка(GetBinaryDataFromString(AuthenticationUser + "":""+ AuthenticationPassword)));",
													UT_CodeGenerator.StringInCodeString(RequestsTreeRow.AuthenticationUser),
													UT_CodeGenerator.StringInCodeString(RequestsTreeRow.AuthenticationPassword)));

		ElsIf RequestsTreeRow.AuthenticationType = AuthenticationTypes.BearerToken Then

			Prefix = TrimAll(RequestsTreeRow.AuthenticationTokenPrefix);
			If Not ValueIsFilled(Prefix) Then
				Prefix = "Bearer";
			EndIf;
			RowsToConcatenate.Add(StrTemplate("
										|// Authentication BearerToken
										|Token = %1;
										|TokenPrefix = %2;
										|NewRequest.Headers.Insert(""Authorization"", TokenPrefix +"" ""+Token);",
										UT_CodeGenerator.StringInCodeString(RequestsTreeRow.AuthenticationPassword),
										UT_CodeGenerator.StringInCodeString(Prefix)));
		EndIf;

	EndIf;

	RowsToConcatenate.Add("
	|// Body request");
	If RequestsTreeRow.BodyType = TypesOfRequestBody.Bodyless Then
		RowsToConcatenate.Add("// Bodyless");
	ElsIf RequestsTreeRow.BodyType = TypesOfRequestBody.String Then
		If RequestsTreeRow.UseBOM = 0 Then
			BOM = "ByteOrderMarkUse.Auto";
		ElsIf (RequestsTreeRow.UseBOM = 1) Then
			BOM = "ByteOrderMarkUse.Use";
		Else
			BOM = "ByteOrderMarkUse.DontUse";
		EndIf;

		RowsToConcatenate.Add(StrTemplate("// Body String
										|RequestBody = %1;
										|UsingBOM = %2;",
										UT_CodeGenerator.StringInCodeString(RequestsTreeRow.BodyString),
												BOM));

		If RequestsTreeRow.BodyEncoding = "Auto" Then
			RowsToConcatenate.Add("NewRequest.SetBodyFromString(RequestBody, , UsingBOM);");
		Else
			Try
				//@skip-check module-unused-local-variable
				BodyEncoding = TextEncoding[RequestsTreeRow.BodyEncoding];
				RowsToConcatenate.Add(StrTemplate("BodyEncoding = TextEncoding.%1;",
														RequestsTreeRow.BodyEncoding));
			Except
				RowsToConcatenate.Add(StrTemplate("BodyEncoding = %1;",
														UT_CodeGenerator.StringInCodeString(RequestsTreeRow.BodyEncoding)));

			EndTry;
			RowsToConcatenate.Add("NewRequest.SetBodyFromString(RequestBody, BodyEncoding, UsingBOM);");

		EndIf;
	ElsIf RequestsTreeRow.BodyType = TypesOfRequestBody.BinaryData Then
		If RequestsTreeRow.ТелоBinaryData <> Undefined Then
			BodyBinaryData = UT_Common.ValueFromBinaryDataContainerStorage(RequestsTreeRow.BodyBinaryData);
			If TypeOf(BodyBinaryData) = Type("BinaryData") Then
				BinaryDataString = Base64Строка(BodyBinaryData);
				RowsToConcatenate.Add(StrTemplate("// Body BinaryData
												|RequestBody = Base64Value(%1);
												|NewRequest.SetBodyFromBinaryData(RequestBody);",
												UT_CodeGenerator.StringInCodeString(BinaryDataString)));

			EndIf;
		EndIf;
	ElsIf RequestsTreeRow.BodyType = TypesOfRequestBody.File Then
		RowsToConcatenate.Add(StrTemplate("// File body
										|RequestBody = %1;
										|NewRequest.SetBodyFileName(RequestBody);",
										UT_CodeGenerator.StringInCodeString(RequestsTreeRow.BodyFileName)));
	ElsIf RequestsTreeRow.BodyType = TypesOfRequestBody.MultypartForm Then 
		MultypartItemsType = MultypartItemsType();
		
		RowsToConcatenate.Add("// Body Multypartdata
		|MultipartBodySplitter = ""---""+StrReplace(String(New UUID), ""-"", """")+""---"";
		|
		|FilesToCombine = New Array;");	

		FilesExist = False;
		For RowIndex = 0 To RequestsTreeRow.MultipartBody.Count() - 1 Do
			MultypartItemRow = RequestsTreeRow.MultipartBody[RowIndex];
			If Not MultypartItemRow.Using Then
				Continue;
			EndIf;
			
			If MultypartItemRow.Type = MultypartItemsType.String Then
				FilesExist = True;

				RowsToConcatenate.Add(StrTemplate("
												|CurrentParameterName = %1;
												|CurrentParameterValue = %2;
												|
												|StreamRecord = New MemoryStream;
												|
												|InputFile = New TextWriter(StreamRecord, TextEncoding.ANSI, Chars.LF);
												|InputFile.WriteLine("""");
												|InputFile.WriteLine(""--"" + MultipartBodySplitter);
												|InputFile.WriteLine(""Content-Disposition: form-data;name=""""""+CurrentParameterName+"""""""");
												|InputFile.WriteLine("""");
												|InputFile.Close();
												|FilesToCombine.Add(StreamRecord.CloseAndGetBinaryData());
												|
												|FilesToCombine.Add(GetBinaryDataFromString(CurrentParameterValue));",
												UT_CodeGenerator.StringInCodeString(MultypartItemRow.Name),
												UT_CodeGenerator.StringInCodeString(MultypartItemRow.Value)));

			ElsIf MultypartItemRow.Type = MultypartItemsType.File Then
				If Not ValueIsFilled(MultypartItemRow.Value) Then
					Continue;
				EndIf;

				FilesExist = True;

				RowsToConcatenate.Add(StrTemplate("
												|CurrentParameterName = %1;
												|CurrentFileName = %2;
												|
												|File = New File(CurrentFileName);
												|FileBinaryData = New BinaryData(CurrentFileName);
												|
												|StreamRecord = New MemoryStream;
												|
												|InputFile = New TextWriter(StreamRecord, TextEncoding.ANSI, Chars.LF);
												|InputFile.WriteLine("""");
												|InputFile.WriteLine(""--"" + MultipartBodySplitter);
												|InputFile.WriteLine(""Content-Disposition: form-data;name=""""""
												|													+ CurrentParameterName 
												|													+ """""";filename="""""" 
												|													+ File.Name+ """""""");
												|InputFile.WriteLine(""Content-Type: application/octet-stream"");  
												|InputFile.WriteLine("""");
												|InputFile.Close();
												|FilesToCombine.Add(StreamRecord.CloseAndGetBinaryData());
												|
												|FilesToCombine.Add(FileBinaryData);",
												UT_CodeGenerator.StringInCodeString(MultypartItemRow.Name),
												UT_CodeGenerator.StringInCodeString(MultypartItemRow.Value)));
			EndIf;

		EndDo;
		
		If FilesExist Then
			RowsToConcatenate.Add("
			|StreamRecord = New MemoryStream;
			|InputFile = New TextWriter(StreamRecord, TextEncoding.ANSI, Chars.LF);
			|InputFile.WriteLine("""");
			|InputFile.WriteLine(""--"" + MultipartBodySplitter + ""--"");
			|InputFile.Close();
			|
			|FilesToCombine.Add(StreamRecord.CloseAndGetBinaryData());
			|
			|FinalBD = ConcatBinaryData(FilesToCombine);
			|
			|NewRequest.SetBodyFromBinaryData(FinalBD);
			|
			|NewRequest.Headers.Insert(""Content-Type"", ""multipart/form-data; boundary=""+MultipartBodySplitter);
			|NewRequest.Headers.Insert(""Content-Length"", XMLString(FinalBD.Size()));
			|");
		EndIf;

	EndIf;

	Return StrConcat(RowsToConcatenate, Chars.LF);
	

	
EndFunction

&AtServer
Function GeneratedRequestExecutionCode(RequestsTreeRow)
	
	
	Return StrTemplate("RequestType = %1;
					  |
					  |StartExecution = CurrentUniversalDateInMilliseconds();
					  |
					  |HTTPResponse = HTTPConnection.CallHTTPMethod(RequestType, NewRequest);
					  |FinishExecution = CurrentUniversalDateInMilliseconds();
					  |
					  |Duration = FinishExecution - StartExecution;
					  |
					  |StatusCode = HTTPResponse.StatusCode;
					  |ResponseBodyString = HTTPResponse.GetBodyAsString();
					  |ResponseBodyBinaryData = HTTPResponse.GetBodyAsBinaryData();
					  |", UT_CodeGenerator.StringInCodeString(RequestsTreeRow.HTTPRequest));
EndFunction

Function GeneratedExecutionCodeAtServer(RowID)
	RequestsTreeRow = RequestsTree.FindByID(RowID);
	StructureURL = UT_HTTPConnector.ParseURL(RequestsTreeRow.RequestURL);
	
	
	ExecuteText = UT_CodeGenerator.StandardGeneratedCodeHeader("HTTP Request Console",
															RequestsFileName,
															RequestsTreeRow.Name);

	ExecuteText = ExecuteText
					  + GeneratedHTTPRequestInitializationConnection(RequestsTreeRow, StructureURL)
					  + Chars.LF
					  + GeneratedHTTPRequestInitializationCode(RequestsTreeRow, StructureURL)
					  + Chars.LF
					  + GeneratedRequestExecutionCode(RequestsTreeRow);
								
	Return ExecuteText;
EndFunction



#EndRegion

