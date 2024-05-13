#Region Public

#Region FormItemsCreate

// Form on create at server.
// 
// Parameters:
//  Form - ClientApplicationForm
//  EditorType - String - Editor type, to add to form details at UT_CodeEditorClientServer.CodeEditorVariants()
Procedure FormOnCreateAtServer(Form, EditorType = Undefined) Export
	EditorVariants = UT_CodeEditorClientServer.CodeEditorVariants();
	
	If EditorType = Undefined Then
		EditorSettings = CodeEditorCurrentSettings();
		EditorType = EditorSettings.Variant;
	EndIf;
	
	IsWindowsClient = False;
	IsWebClient = True;
	
	SessionParametersInStorage = UT_CommonServerCall.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
	If Type(SessionParametersInStorage) = Type("Structure") Then
		If SessionParametersInStorage.Property("HTMLFieldBasedOnWebkit") Then
			If Not SessionParametersInStorage.HTMLFieldBasedOnWebkit Then
				EditorType = EditorVariants.Text;
			EndIf;
		EndIf;
		If SessionParametersInStorage.Property("IsWindowsClient") Then
			IsWindowsClient = SessionParametersInStorage.IsWindowsClient;
		EndIf;
		If SessionParametersInStorage.Property("IsWebClient") Then
			IsWebClient = SessionParametersInStorage.IsWebClient;
		EndIf;
		
	EndIf;
	
	AttributeNameEditorType=UT_CodeEditorClientServer.AttributeNameCodeEditorTypeOfEditor();
	AttributeNameLibraryURL=UT_CodeEditorClientServer.AttributeNameCodeEditorLibraryURL();
	AttributeNameCodeEditorFormCodeEditors = UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors();
	AttributeNameCodeEditorInitialInitializationPassed = UT_CodeEditorClientServer.AttributeNameCodeEditorInitialInitializationPassed();
	
	AttributesArray=New Array;
	AttributesArray.Add(New FormAttribute(AttributeNameEditorType, New TypeDescription("String", , 
		New StringQualifiers(20,AllowedLength.Variable)), "", "", True));
	AttributesArray.Add(New FormAttribute(AttributeNameLibraryURL, New TypeDescription("String", , 
		New StringQualifiers(0,	AllowedLength.Variable)), "", "", True));
	AttributesArray.Add(New FormAttribute(AttributeNameCodeEditorFormCodeEditors, New TypeDescription, 
		"", "", True));	
	AttributesArray.Add(New FormAttribute(AttributeNameCodeEditorInitialInitializationPassed, New TypeDescription("Boolean"),
		"", "", Истина));

	Form.ChangeAttributes(AttributesArray);
	
	Form[AttributeNameEditorType]=EditorType;
	Форма[ИмяРеквизитаРедактораКодаСписокРедакторовФормы] = New Structure;
	Форма[ИмяРеквизитаДанныеБиблиотекРедакторов] = New Structure;

	Форма[ИмяРеквизитаДанныеБиблиотекРедакторов].Вставить(EditorType,
														  DataLibraryEditor(Форма.УникальныйИдентификатор,
																					IsWindowsClient,
																					IsWebClient,
																					EditorType));
	
	КлючДанныхБиблиотекиВзаимодействия = УИ_РедакторКодаКлиентСервер.ИмяБиблиотекиВзаимодействияДляДанныхФормы(EditorType);
	If EditorType = EditorOptions.Ace Then
		Форма[ИмяРеквизитаДанныеБиблиотекРедакторов].Вставить(КлючДанныхБиблиотекиВзаимодействия,
															  DataLibraryCommonTemplate("УИ_AceColaborator",
																						   Форма.УникальныйИдентификатор));
	EndIf;
	
EndProcedure

// Create code editor items.
// 
// Parameters:
//  Form - ClientApplicationForm-
//  EditorID - String - The unique identifier of the editor within the form. Must comply with the rules for naming variables
//  EditorField - FormField - Editor Field
//  EditorEvents - Undefined, Structure - Names of form procedures for processing editor events. List of supported events in method UT_CodeEditorServer.NewEditorEventsParameters
//  EditorLanguage - String -Code editor language . By default "bsl". 
//  CommandBarGroup - FormGroup - Command bar group to add  buttons . Still in development
Procedure CreateCodeEditorItems(Form, EditorID, EditorField, EditorEvents = Undefined, 
	EditorLanguage = "bsl", CommandBarGroup = Undefined) Export
	EditorType = UT_CodeEditorClientServer.FormCodeEditorType(Form);
	
	ДанныеРедактора = УИ_РедакторКодаКлиентСервер.НовыйДанныеРедактораФормы();
	ДанныеРедактора.Идентификатор = ИдентификаторРедактора;
	ДанныеРедактора.СобытияРедактора= СобытияРедактора;
	If EditorData.EditorEvents = Undefined Then 
		EditorData.EditorEvents = NewEditorEventsParameters();
	EndIf;

	If UT_CodeEditorClientServer.CodeEditorUsesHTMLField(EditorType) Then
		If EditorField.Type <> FormFieldType.HTMLDocumentField Then
			EditorField.Type = FormFieldType.HTMLDocumentField;
		EndIf;
		EditorField.SetAction("DocumentComplete", "Attachable_EditorFieldDocumentGenerated");
		EditorField.SetAction("OnClick", "Attachable_EditorFieldOnClick");

	Else
		EditorField.Type = FormFieldType.TextDocumentField;
		EditorData.Insert("Initialized", True);
		
		If ValueIsFilled(EditorData.EditorEvents.OnChange) Then 
			EditorField.SetAction("OnChange",EditorData.EditorEvents.OnChange);
		Endif;	
	EndIf;
	
	ДанныеРедактора.Язык = ЯзыкРедактора;
	ДанныеРедактора.ПолеРедактора= ПолеРедактора.Имя;
	ДанныеРедактора.ИмяРеквизита = ПолеРедактора.ПутьКДанным;
	
	EditorVariants = UT_CodeEditorClientServer.CodeEditorVariants();

	EditorSettings = CodeEditorCurrentSettings();
	ДанныеРедактора.ПараметрыРедактора = EditorSettings;

	If EditorType = EditorVariants.Monaco Then
		For Each KeyValue In EditorSettings.Monaco Do
			EditorData.EditorSettings.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;
	
	Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()].Insert(
	   EditorID,  EditorData);
	
	
	If EditorType = EditorOptions.Ace Then
		ДанныеБиблиотекРедакторов = Форма[УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКодаДанныеБиблиотекРедакторов()];
		Форма[ДанныеРедактора.ИмяРеквизита] = TextFieldsHTMLEditorAce(ДанныеБиблиотекРедакторов[EditorOptions.Ace]);
	EndIf;
	
	If CommandBarGroup = Undefined Then 
		Return;
	EndIf;
	ДанныеРедактора.ИмяКоманднойПанелиРедактора = ГруппаКомманднойПанели.Имя;
	
	If ЯзыкРедактора = "bsl" Then
		ОписаниеКнопки = УИ_РаботаСФормами.НовыйОписаниеКомандыКнопки();
		ОписаниеКнопки.Имя = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыРежимВыполненияЧерезОбработку(),
																				  ИдентификаторРедактора);
		ОписаниеКнопки.ИмяКоманды = ОписаниеКнопки.Имя;
		ОписаниеКнопки.Заголовок = "Через обработку";
		ОписаниеКнопки.РодительЭлемента = ГруппаКомманднойПанели;
		ОписаниеКнопки.Действие = "Подключаемый_ВыполнитьКомандуРедактораКода";
		ОписаниеКнопки.Картинка = БиблиотекаКартинок.Обработка;
		ОписаниеКнопки.Подсказка = "Режим выполнения кода через обработку. Позволяет использовать свои процедуры и функции";
		ОписаниеКнопки.Отображение = ОтображениеКнопки.Картинка;
		УИ_РаботаСФормами.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
		УИ_РаботаСФормами.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);
	EndIf;
	
	ОписаниеПодменюИнтеграцииСPaste1C = УИ_РаботаСФормами.НовыйОписаниеГруппыФормы();
	ОписаниеПодменюИнтеграцииСPaste1C.Родитель = ГруппаКомманднойПанели;
	ОписаниеПодменюИнтеграцииСPaste1C.Вид = ВидГруппыФормы.Подменю;
	ОписаниеПодменюИнтеграцииСPaste1C.Имя = ГруппаКомманднойПанели.Имя +"_ПодменюИнтеграцииССервисомХраненияКода_"+ИдентификаторРедактора;
	ОписаниеПодменюИнтеграцииСPaste1C.ОтображатьЗаголовок = Ложь;
	ОписаниеПодменюИнтеграцииСPaste1C.Заголовок = "Paste 1C";

//	ОписаниеПодменюИнтеграцииСPaste1C.Отображение = ОтображениеОбычнойГруппы.Нет;
	Подменю = УИ_РаботаСФормами.СоздатьГруппуПоОписанию(Форма, ОписаниеПодменюИнтеграцииСPaste1C);
	If Не УИ_ОбщегоНазначенияКлиентСервер.ЭтоПортативнаяПоставка() Then
		Подменю.Картинка = БиблиотекаКартинок.УИ_Поделиться;
	EndIf;
	
	ОписаниеКнопки = УИ_РаботаСФормами.НовыйОписаниеКомандыКнопки();
	ОписаниеКнопки.Имя = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыПоделитьсяАлгоритмом(),
																			  ИдентификаторРедактора);
	ОписаниеКнопки.ИмяКоманды = ОписаниеКнопки.Имя;
	ОписаниеКнопки.Заголовок = "Поделиться алгоритмом";
	ОписаниеКнопки.РодительЭлемента = Подменю;
	ОписаниеКнопки.Действие = "Подключаемый_ВыполнитьКомандуРедактораКода";
	//ОписаниеКнопки.Картинка = БиблиотекаКартинок.Обработка;
	ОписаниеКнопки.Подсказка = "Поделиться кодом алгоритма";
	//ОписаниеКнопки.Отображение = ОтображениеКнопки.Картинка;
	УИ_РаботаСФормами.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
	УИ_РаботаСФормами.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);		
	
	ОписаниеКнопки = УИ_РаботаСФормами.НовыйОписаниеКомандыКнопки();
	ОписаниеКнопки.Имя = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыЗагрузитьАлгоритм(),
																			  ИдентификаторРедактора);
	ОписаниеКнопки.ИмяКоманды = ОписаниеКнопки.Имя;
	ОписаниеКнопки.Заголовок = "Загрузить алгоритм";
	ОписаниеКнопки.РодительЭлемента = Подменю;
	ОписаниеКнопки.Действие = "Подключаемый_ВыполнитьКомандуРедактораКода";
	//ОписаниеКнопки.Картинка = БиблиотекаКартинок.Обработка;
	ОписаниеКнопки.Подсказка = "Загрузить расшаренный код";
	//ОписаниеКнопки.Отображение = ОтображениеКнопки.Картинка;
	УИ_РаботаСФормами.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
	УИ_РаботаСФормами.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);		
	
	If EditorType = EditorOptions.Ace Then
	// Взаимодействие
		ОписаниеПодменюСессииВзаимодействия = УИ_РаботаСФормами.НовыйОписаниеГруппыФормы();
		ОписаниеПодменюСессииВзаимодействия.Родитель = ГруппаКомманднойПанели;
		ОписаниеПодменюСессииВзаимодействия.Вид = ВидГруппыФормы.Подменю;
		ОписаниеПодменюСессииВзаимодействия.Имя = ГруппаКомманднойПанели.Имя
												  + "_ПодменюИнтеграцииССерверомКолаборации_"
												  + ИдентификаторРедактора;
		ОписаниеПодменюСессииВзаимодействия.ОтображатьЗаголовок = Ложь;
		ОписаниеПодменюСессииВзаимодействия.Заголовок = "";

//	ОписаниеПодменюИнтеграцииСPaste1C.Отображение = ОтображениеОбычнойГруппы.Нет;
		Подменю = УИ_РаботаСФормами.СоздатьГруппуПоОписанию(Форма, ОписаниеПодменюСессииВзаимодействия);
		If Не УИ_ОбщегоНазначенияКлиентСервер.ЭтоПортативнаяПоставка() Then
			Подменю.Картинка = БиблиотекаКартинок.АктивныеПользователи;
		EndIf;
		
		ОписаниеКнопки = УИ_РаботаСФормами.НовыйОписаниеКомандыКнопки();
		ОписаниеКнопки.Имя = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыНачатьСессиюВзаимодействия(),
																				  ИдентификаторРедактора);
		ОписаниеКнопки.ИмяКоманды = ОписаниеКнопки.Имя;
		ОписаниеКнопки.Заголовок = "Начать сессию взаимодейтсвия";
		ОписаниеКнопки.РодительЭлемента = Подменю;
		ОписаниеКнопки.Действие = "Подключаемый_ВыполнитьКомандуРедактораКода";
	//ОписаниеКнопки.Картинка = БиблиотекаКартинок.Обработка;
		ОписаниеКнопки.Подсказка = "Начать сессию совместного кодинга";
	//ОписаниеКнопки.Отображение = ОтображениеКнопки.Картинка;
		УИ_РаботаСФормами.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
		УИ_РаботаСФормами.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);

		ОписаниеКнопки = УИ_РаботаСФормами.НовыйОписаниеКомандыКнопки();
		ОписаниеКнопки.Имя = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыЗакончитьСессиюВзаимодействия(),
																				  ИдентификаторРедактора);
		ОписаниеКнопки.ИмяКоманды = ОписаниеКнопки.Имя;
		ОписаниеКнопки.Заголовок = "Завершить сессию взаимодейтсвия";
		ОписаниеКнопки.РодительЭлемента = Подменю;
		ОписаниеКнопки.Действие = "Подключаемый_ВыполнитьКомандуРедактораКода";
	//ОписаниеКнопки.Картинка = БиблиотекаКартинок.Обработка;
		ОписаниеКнопки.Подсказка = "Завершить сессию совместного кодинга";
	//ОписаниеКнопки.Отображение = ОтображениеКнопки.Картинка;
		УИ_РаботаСФормами.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
		УИ_РаботаСФормами.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);

	EndIf;

	
//
//
//		
//	ОписаниеКнопки = УИ_РаботаСФормами.НовыйОписаниеКомандыКнопки();
//	ОписаниеКнопки.Имя = УИ_РедакторКодаКлиентСервер.ИмяКнопкиКоманднойПанели(УИ_РедакторКодаКлиентСервер.ИмяКомандыКонструкторЗапроса(),
//																			  ИдентификаторРедактора);
//	ОписаниеКнопки.ИмяКоманды = ОписаниеКнопки.Имя;
//	ОписаниеКнопки.Заголовок = "Конструктор запроса";
//	ОписаниеКнопки.РодительЭлемента = ГруппаКомманднойПанели;
//	ОписаниеКнопки.Действие = "Подключаемый_ВыполнитьКомандуРедактораКода";
//	ОписаниеКнопки.Картинка = БиблиотекаКартинок.КонструкторЗапроса;
//	ОписаниеКнопки.Отображение = ОтображениеКнопки.Картинка;
//	УИ_РаботаСФормами.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
//	УИ_РаботаСФормами.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);	
			
//Buttons
//1 - Query wizard
//2 - Format string wizard
//3 - Query editor
//4 - format text
//6- Check Syntax
//7 - Execute
//8 - Add Comment
//9 - Delete Comment
//10 - Add Bookmark
//11 - Delete Bookmark
//12 - Next Bookmark
//13 - Add Line Break 
//14 - Delete Line Break 
////15 - Go to to Line
//16 - Insert predefined value
////17 - Add Macrocolumn
 //18 - Save as dataprocessors

EndProcedure

// new parameters of editor events .
// 
// return:
//  Structure - new parameters of editor events .:
// * OnChange - String -
Function NewEditorEventsParameters() Export
	Return UT_CodeEditorClientServer.NewEditorEventOptions();
EndFunction

#EndRegion

#Region ToolsSettings
Function CodeEditor1CCurrentVariant() Export
	CodeEditorSettings = CodeEditorCurrentSettings();
	
	CodeEditor = CodeEditorSettings.Variant;
	
	UT_SessionParameters = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
		
	If Type(UT_SessionParameters) = Type("Structure") Then
		If UT_SessionParameters.HTMLFieldBasedOnWebkit<>True Then
			CodeEditor = UT_CodeEditorClientServer.CodeEditorVariants().Text;
		EndIf;
	EndIf;
	
	Return CodeEditor;
EndFunction

Procedure SetCodeEditorNewSettings(NewSettings) Export
	UT_Common.CommonSettingsStorageSave(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "CodeEditorSettings",
		NewSettings);
EndProcedure

Function CodeEditorCurrentSettings() Export
	EditorSavedSettings = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "CodeEditorSettings");

	DefaultSettings = UT_CodeEditorClientServer.CodeEditorCurrentSettingsByDefault();
	If EditorSavedSettings = Undefined Then
		DefaultSettings.Variant = UT_CodeEditorClientServer.EditorVariantByDefault();
		MonacoEditorParameters = CurrentMonacoEditorParameters();

		FillPropertyValues(DefaultSettings.Monaco, MonacoEditorParameters);
	Else
		FillPropertyValues(DefaultSettings, EditorSavedSettings, , "Monaco");
		FillPropertyValues(DefaultSettings.Monaco, EditorSavedSettings.Monaco);
	EndIf;

	Return DefaultSettings;

EndFunction

#EndRegion

#Region WorkWithMetaData

Function ConfigurationScriptVariant() Export
	If Metadata.ScriptVariant = Metadata.ObjectProperties.ScriptVariant.English Then
		Return "English";
	Else
		Return "Russian";
	EndIf;
EndFunction

Function MetadataObjectHasPredefined(MetadataTypeName)
	
	Objects = New Array;
	Objects.Add("сatalog");
	Objects.Add("catalogs");
	Objects.Add("chartofaccounts");	
	Objects.Add("сhartsofaccounts");	
	Objects.Add("chartofcharacteristictypes");
	Objects.Add("chartsofcharacteristictypes");
	Objects.Add("chartofcalculationtypes");
	Objects.Add("chartsofcalculationtypes");
	
	Return Objects.Find(Lower(MetadataTypeName)) <> Undefined;
	
EndFunction

Function MetadataObjectHasVirtualTables(MetadataTypeName)
	
	Objects = New Array;
	Objects.Add("InformationRegisters");
	Objects.Add("AccumulationRegisters");	
	Objects.Add("CalculationRegisters");
	Objects.Add("AccountingRegisters");
	
	Return Objects.Find(MetadataTypeName) <> Undefined;
	
EndFunction

Function MetadataObjectAttributeDescription(Attribute,AllRefsType)
	Description = New Structure;
	Description.Insert("Name", Attribute.Name);
	Description.Insert("Synonym", Attribute.Synonym);
	Description.Insert("Comment", Attribute.Comment);
	
	RefTypes = New Array;
	For Each CurrentType In Attribute.Type.Types() Do
		If AllRefsType.ContainsType(CurrentType) Then
			RefTypes.Add(CurrentType);
		EndIf;
	EndDo;
	Description.Insert("Type", New TypeDescription(RefTypes));
	
	Return Description;
EndFunction

Function ConfigurationMetadataObjectDescriptionByName(ObjectType, ObjectName) Export
	AllRefsType = UT_Common.AllRefsTypeDescription();

	Return ConfigurationMetadataObjectDescription(Metadata[ObjectType][ObjectName], ObjectType, AllRefsType);	
EndFunction

Function ConfigurationMetadataObjectDescription(ObjectOfMetadata, ObjectType, AllRefsType, 
IncludeAttributesDescription = True) Export
	ItemDescription = New Structure;
	ItemDescription.Insert("ObjectType", ObjectType);
	ItemDescription.Insert("Name", ObjectOfMetadata.Name);
	ItemDescription.Insert("Synonym", ObjectOfMetadata.Synonym);
	ItemDescription.Insert("Comment", ObjectOfMetadata.Comment);
	
	Extension = ObjectOfMetadata.ConfigurationExtension();
	If Extension <> Undefined Then
		ItemDescription.Insert("Extension", Extension.Name);
	Else
		ItemDescription.Insert("Extension", Undefined);
	EndIf;
	If Lower(ObjectType) = "constant"  Or Lower(ObjectType) = "constants" Then
		ItemDescription.Insert("Type", ObjectOfMetadata.Type);
	ElsIf Lower(ObjectType) = "enum"  Or Lower(ObjectType) = "enums"Then
		EnumValues = New Structure;

		For Each CurrentValue In ObjectOfMetadata.EnumValues Do
			EnumValues.Insert(CurrentValue.Name, CurrentValue.Synonym);
		EndDo;

		ItemDescription.Insert("EnumValues", EnumValues);
	EndIf;

	If Not IncludeAttributesDescription Then
		Return ItemDescription;
	EndIf;
	
	AttributesCollections = New Structure("Attributes, StandardAttributes, Dimensions, Resources, AddressingAttributes, AccountingFlags");
	TabularSectionsCollections = New Structure("TabularSections, StandardTabularSections");
	FillPropertyValues(AttributesCollections, ObjectOfMetadata);
	FillPropertyValues(TabularSectionsCollections, ObjectOfMetadata);

	For Each KeyValue In AttributesCollections Do
		If KeyValue.Value = Undefined Then
			Continue;
		EndIf;

		AttributesCollectionDescription= New Structure;

		For Each CurrentAttribute In KeyValue.Value Do
			AttributesCollectionDescription.Insert(CurrentAttribute.Name, MetadataObjectAttributeDescription(CurrentAttribute,
				AllRefsType));
		EndDo;

		ItemDescription.Insert(KeyValue.Key, AttributesCollectionDescription);
	EndDo;

	For Each KeyValue In TabularSectionsCollections Do
		If KeyValue.Value = Undefined Then
			Continue;
		EndIf;

		TabularSectionCollectionDescription = New Structure;

		For Each TabularSection In KeyValue.Value Do
			TabularSectionDescription = New Structure;
			TabularSectionDescription.Insert("Name", TabularSection.Name);
			TabularSectionDescription.Insert("Synonym", TabularSection.Synonym);
			TabularSectionDescription.Insert("Comment", TabularSection.Comment);

			TabularSectionAttributesCollection = New Structure("Attributes, StandardAttributes");
			FillPropertyValues(TabularSectionAttributesCollection, TabularSection);
			For Each CurrentTabularSectionAttributesCollection In TabularSectionAttributesCollection Do
				If CurrentTabularSectionAttributesCollection.Value = Undefined Then
					Continue;
				EndIf;

				TabularSectionAttributesCollectionDescription = New Structure;

				For Each CurrentAttribute In CurrentTabularSectionAttributesCollection.Value Do
					TabularSectionAttributesCollectionDescription.Insert(CurrentAttribute.Name, MetadataObjectAttributeDescription(
						CurrentAttribute, AllRefsType));
				EndDo;

				TabularSectionDescription.Insert(CurrentTabularSectionAttributesCollection.Key, TabularSectionAttributesCollectionDescription);
			EndDo;
			TabularSectionCollectionDescription.Insert(TabularSection.Name, TabularSectionDescription);
		EndDo;

		ItemDescription.Insert(KeyValue.Key, TabularSectionCollectionDescription);
	EndDo;
	If MetadataObjectHasPredefined(ObjectType) Then

		Predefined = ObjectOfMetadata.GetPredefinedNames();

		PredefinedDescription = New Structure;
		For Each Name In Predefined Do
			PredefinedDescription.Insert(Name, "");
		EndDo;

		ItemDescription.Insert("Predefined", PredefinedDescription);
	EndIf;
	
	Return ItemDescription;
EndFunction

Function ConfigurationMetadataCollectionDescription(Collection, ObjectType, TypesMap, AllRefsType, 
IncludeAttributesDescription) 
	CollectionDescription = New Structure;

	For Each ObjectOfMetadata In Collection Do
		ItemDescription = ConfigurationMetadataObjectDescription(ObjectOfMetadata, ObjectType, AllRefsType,
		      IncludeAttributesDescription);
			
		CollectionDescription.Insert(ObjectOfMetadata.Name, ItemDescription);
		
		If UT_Common.IsRefTypeObject(ObjectOfMetadata) Then
			TypesMap.Insert(Type(ObjectType+"Ref."+ItemDescription.Name), ItemDescription);
		EndIf;
		
	EndDo;
	
	Return CollectionDescription;
EndFunction

Function ConfigurationCommonModulesDescription() Export
	CollectionDescription = New Structure();

	For Each ObjectOfMetadata In Metadata.CommonModules Do
			
		CollectionDescription.Insert(ObjectOfMetadata.Name, New Structure);
		
	EndDo;
	
	Return CollectionDescription;
EndFunction

Function MetaDataDescriptionForMonacoEditorInitialize() Export
	TypesMap = New Map;
	AllRefsType = UT_Common.AllRefsTypeDescription();

	MetadataDescription = New Structure;
	MetadataDescription.Insert("CommonModules", ConfigurationCommonModulesDescription());
	//	MetadataDescription.Insert("Roles", ConfigurationMetadataCollectionDescription(Metadata.Roles, "Role", TypesMap, AllRefsType));
	//	MetadataDescription.Insert("CommonForms", ConfigurationMetadataCollectionDescription(Metadata.CommonForms, "CommonForm", TypesMap, AllRefsType));

	Return MetadataDescription;	
EndFunction

Function ConfigurationMetadataDescription(IncludeAttributesDescription = True) Export
	AllRefsType = UT_Common.AllRefsTypeDescription();
	
	MetadataDescription = New Structure;
	
	TypesMap = New Map;
	
	MetadataDescription.Insert("Name", Metadata.Name);
	MetadataDescription.Insert("Version", Metadata.Version);
	MetadataDescription.Insert("AllRefsType", AllRefsType);
	
	MetadataDescription.Insert("Catalogs", ConfigurationMetadataCollectionDescription(Metadata.Catalogs, 
	    "Catalog", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Documents", ConfigurationMetadataCollectionDescription(Metadata.Documents, "Document",
		 TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("InformationRegisters", ConfigurationMetadataCollectionDescription(
		Metadata.InformationRegisters, "InformationRegister", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("AccumulationRegisters", ConfigurationMetadataCollectionDescription(
		Metadata.AccumulationRegisters, "AccumulationRegister", TypesMap, AllRefsType, 
		IncludeAttributesDescription));
	MetadataDescription.Insert("AccountingRegisters", ConfigurationMetadataCollectionDescription(
		Metadata.AccountingRegisters, "AccountingRegister", TypesMap, AllRefsType, 
		IncludeAttributesDescription));
	MetadataDescription.Insert("CalculationRegisters", ConfigurationMetadataCollectionDescription(Metadata.CalculationRegisters,
		 "CalculationRegister", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("DataProcessors", ConfigurationMetadataCollectionDescription(Metadata.DataProcessors, "DataProcessonr",
		 TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Reports", ConfigurationMetadataCollectionDescription(Metadata.Reports, "Report", 
		 TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Enums", ConfigurationMetadataCollectionDescription(Metadata.Enums, 
		"Enum", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("CommonModules", ConfigurationMetadataCollectionDescription(Metadata.CommonModules,
		 "CommonModule", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfAccounts", ConfigurationMetadataCollectionDescription(Metadata.ChartsOfAccounts, 
		"ChartOfAccounts", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("BusinessProcesses", ConfigurationMetadataCollectionDescription(Metadata.BusinessProcesses, 
		"BusinessProcess", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Tasks", ConfigurationMetadataCollectionDescription(Metadata.Tasks, "Task", 
		TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfAccounts", ConfigurationMetadataCollectionDescription(Metadata.ChartsOfAccounts, 
		"ChartOfAccounts", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ExchangePlans", ConfigurationMetadataCollectionDescription(Metadata.ExchangePlans,
		 "ExchangePlan", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfCharacteristicTypes", ConfigurationMetadataCollectionDescription(
		Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypes", TypesMap, AllRefsType, 
		IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfCalculationTypes", ConfigurationMetadataCollectionDescription(
		Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypes", TypesMap, AllRefsType,IncludeAttributesDescription));
	MetadataDescription.Insert("Constants", ConfigurationMetadataCollectionDescription(Metadata.Constants, "Constant", 
		TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("SessionParameters", ConfigurationMetadataCollectionDescription(Metadata.SessionParameters, 
		"SessionParameter", TypesMap, AllRefsType, IncludeAttributesDescription));
	
	MetadataDescription.Insert("ReferenceTypesMap", TypesMap);
	
	Return MetadataDescription;
EndFunction

Function ConfigurationMetadataDescriptionAdress() Export
	Description = ConfigurationMetadataDescription();
	
	Return PutToTempStorage(Description, New UUID);
EndFunction

Function MetadataListByType(MetadataType) Export
	MetadataCollection = Metadata[MetadataType];
	
	NamesArray = New Array;
	For Each ObjectOfMetadata In MetadataCollection Do
		NamesArray.Add(ObjectOfMetadata.Name);
	EndDo;
	
	Return NamesArray;
EndFunction

Procedure AddMetadataCollectionToReferenceTypesMap(TypesMap, Collection, ObjectType)
	For Each ObjectOfMetadata In Collection Do
		ItemDescription = New Structure;
		ItemDescription.Insert("Name", ObjectOfMetadata.Name);
		ItemDescription.Insert("ObjectType", ObjectType);
			
		TypesMap.Insert(Type(ObjectType+"Ref."+ObjectOfMetadata.Name), ItemDescription);
	EndDo;
	
EndProcedure

Function ReferenceTypesMap() Export
	Map = New Map;
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Catalogs, "Catalog");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Documents, "Document");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Enums, "Enum");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.BusinessProcesses, "BusinessProcess");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Tasks, "Task");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ExchangePlans, "ExchangePlan");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfCharacteristicTypes, 
		"ChartOfCharacteristicTypes");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfCalculationTypes, 
		"ChartOfCalculationTypes");

	Return Map;
EndFunction

#EndRegion

// Editors for assembly with converted text module.
// 
// Parameters:
//  EditorsForAssembly - Array from look UT_CodeEditorClientServer.NewEditorDataForAssemblyProcessing - Editors for assembly
// 
// Return values:
// Array from look UT_CodeEditorClientServer.NewEditorDataForAssemblyProcessing 
Function EditorsForAssemblyWithConvertedTextModule(EditorsForAssembly) Export
	For Each CurrentEditor In EditorsForAssembly Do
		CurrentEditor.ТекстРедактораДляОбработки = UT_Code.TextOfAlgorithmExecutionProcessingModule(CurrentEditor.TextEditor,
																									CurrentEditor.NamesOfPredefinedVariables,
																									CurrentEditor.ExecutionOnClient);
	EndDo;
	Return EditorsForAssembly;
EndFunction

#EndRegion

#Region Internal

Function CurrentMonacoEditorParameters() Export
	ParametersFromStorage =  UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "MonacoEditorParameters",
		UT_CodeEditorClientServer.MonacoEditorParametersByDefault());

	ParametersByDefault = UT_CodeEditorClientServer.MonacoEditorParametersByDefault();
	FillPropertyValues(ParametersByDefault, ParametersFromStorage);

	Return ParametersByDefault;
EndFunction

Function AvailableSourceCodeSources() Export
	Array = New ValueList();
	
	Array.Add("MainConfiguration", "Main configuration");
	
	ExtensionsArray = ConfigurationExtensions.Get();
	For Each CurrentExtension In ExtensionsArray Do
		Array.Add(CurrentExtension.Name, CurrentExtension.Synonym);
	EndDo;
	
	Return Array;
EndFunction


// Data library common template(.
// 
// Parameters:
//  LayoutName - Строка -Имя макета
//  FormId - УникальныйИдентификатор
// 
// Return values:
//  look UT_CodeEditorClientServer.NewDataLibraryEditor
Function DataLibraryCommonTemplate(LayoutName, FormId) Export
	LibraryData = UT_CodeEditorClientServer.NewDataLibraryEditor();

	BinaryDataLibraries = GetCommonTemplate(LayoutName);

	CatalogOnServer = GetTempFileName();
	CreateDirectory(CatalogOnServer);

	Stream = BinaryDataLibraries.ОткрытьПотокДляЧтения();

	ZipFileReader = New ZipFileReader(Stream);
	ZipFileReader.ExtractAll(CatalogOnServer, ZIPRestoreFilePathsMode.Restore);

	ArchiveFiles = FindFiles(CatalogOnServer, GetAllFilesMask(), True);
	For Each  LibraryFile In ArchiveFiles Do
		If LibraryFile.IsDirectory() Then
			Continue;
		EndIf;
		
		If Lower(LibraryFile.Extension) = ".js" Then
			BinaryData = New BinaryData(LibraryFile.FullName);
			LibraryData.Scripts.Add(PutToTempStorage(BinaryData, FormId));
		ElsIf Lower(LibraryFile.Extension) = ".css" Then
			Text = New TextDocument();
			Text.Read(LibraryFile.FullName);
			LibraryData.Styles.Add(Text.GetText());
		EndIf;
	EndDo;

	//@skip-check empty-except-statement
	Try
		DeleteFiles(CatalogOnServer);
	Except
	EndTry;

	Return LibraryData;	
EndFunction

#EndRegion

#Region Private

// Data library editor.
// 
// Parameters:
//  FormId - UUID - Идентификатор формы
//  IsWindowsClient - Boolean - Это windows клиент
//  IsWebClient - Boolean - Это веб клиент
//  EditorType - String , Undefined -  Editor type
// 
// Return values:
//  Undefined -  Editor library data
// Return values:
//  String -  Library address in temporary storage
// Return values:
//  look UT_CodeEditorClientServer.NewDataLibraryEditor
Function DataLibraryEditor(FormId, IsWindowsClient, IsWebClient, EditorType = Undefined)
	If EditorType = Undefined Then
		EditorType = CodeEditor1CCurrentVariant();
	EndIf;
	EditorOptions = UT_CodeEditorClientServer.CodeEditorVariants();
	
	If EditorType <> EditorOptions.Ace Then
		Return PutLibraryInTemporaryStorage(FormId,
			IsWindowsClient,
			IsWebClient,
			EditorType);
	EndIf; 
	
	Return DataLibraryCommonTemplate("UT_Ace", FormId);

EndFunction

Function PutLibraryInTemporaryStorage(FormId, IsWindowsClient, IsWebClient,
	EditorType = Undefined) 
	If EditorType = Undefined Then
		EditorType = CodeEditor1CCurrentVariant();
	EndIf;
	EditorOptions = UT_CodeEditorClientServer.CodeEditorVariants();

	If EditorType = EditorOptions.Monaco Then
		If IsWindowsClient Then
			BinaryDataLibraries = GetCommonTemplate("UT_MonacoEditorWindows");
		Else
			BinaryDataLibraries = GetCommonTemplate("UT_MonacoEditor");
		EndIf;
	ElsIf EditorType = EditorOptions.Ace Then
		BinaryDataLibraries = GetCommonTemplate("UT_Ace");
	Else
		Return Undefined;
	EndIf;

	LibraryStructure = New Map;

	If Not IsWebClient Then
		LibraryStructure.Insert("editor.zip", BinaryDataLibraries);

		Return PutToTempStorage(LibraryStructure, FormId);
	EndIf;

	CatalogOnServer = GetTempFileName();
	CreateDirectory(CatalogOnServer);

	Stream = BinaryDataLibraries.ОткрытьПотокДляЧтения();

	ZipFileReader = Новый ZipFileReader(Stream);
	ZipFileReader.ExtractAll(CatalogOnServer, ZIPRestoreFilePathsMode.Restore);
	ArchiveFiles = FindFiles(CatalogOnServer, "*", True);
	For Each LibraryFile In ArchiveFiles Do
		FileKey = StrReplace(LibraryFile.FullName, CatalogOnServer + GetPathSeparator(), "");
		If LibraryFile.IsDirectory() Then
			Continue;
		EndIf;

		LibraryStructure.Insert(FileKey, New BinaryData(LibraryFile.FullName));
	EndDo;

	LibraryAddress = PutToTempStorage(LibraryStructure, FormId);

	Try
		DeleteFiles(CatalogOnServer);
	Except
		// TODO:
	EndTry;

	Return LibraryAddress;
EndFunction

// Text fields HTML editor Ace.
// 
// Parameters:
//  LibraryData - look UT_CodeEditorClientServer.NewLibraryDataРедактора
// 
// Return values:
//  String
Function TextFieldsHTMLEditorAce(LibraryData)
	TextHTML =
	"<!doctype html>
	|<html lang=""ru"">
	|
	|<head>
	|  <meta charset=""UTF-8"" />
	|  <meta name=""viewport"" content=""width=device-width,initial-scale=1"" />
	|  <meta http-equiv=""X-UA-Compatible"" content=""ie=edge"" />
	|  <title>Ace editor for 1C</title>
	|";
	
	For Each  CurrentStyle In LibraryData.Styles Do
		TextHTML = TextHTML + "
		|<style>
		|" + CurrentStyle + "
		|</style>";
	EndDo;	
	
	TextHTML = TextHTML+"
	|</head>
	|
	|<body>
	|  <div id=""editor""></div>
	|  <div id=""statusBar""></div>
	|";


	For Each  CurrentScript In LibraryData.Scripts Do
		TextHTML = TextHTML + "
							  |  <script src=""" + CurrentScript + """ defer></script>";
	EndDo;

	TextHTML = TextHTML + "
						   |</body>
						   |
						   |</html>";

	Return TextHTML;
EndFunction


#EndRegion