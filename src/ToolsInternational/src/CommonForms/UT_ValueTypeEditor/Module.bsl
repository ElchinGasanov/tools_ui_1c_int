#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("StartMode") Then
		//@skip-check unknown-form-parameter-access
		ActionMode = Parameters.StartMode;
	Else
		ActionMode = -1;
	EndIf;
	
	AvailableTypesSets = UT_CommonClientServer.AvailableEditingTypesSets();

	//Types set can contain:
	// Ref
	// CompositeRef
	// PrimitiveType
	// Null
	// ValueStorage
	// ValueCollection 
	// PointInTime
	// Type
	// Boundary
	// UUID
	// StandardPeriod
	// SystemEnumeration
	
	TypesSet.Clear();
	
	If ActionMode = 0 Then
		TypesSet.Add(AvailableTypesSets.References);
		TypesSet.Add(AvailableTypesSets.ComplexReferences);
		TypesSet.Add(AvailableTypesSets.Primitive);
		TypesSet.Add(AvailableTypesSets.ValueStorage);
		TypesSet.Add(AvailableTypesSets.UUID);
	ElsIf ActionMode = 1 Then 
		TypesSet.Add(AvailableTypesSets.References);
		TypesSet.Add(AvailableTypesSets.ComplexReferences);
		TypesSet.Add(AvailableTypesSets.Primitive);
		TypesSet.Add(AvailableTypesSets.ValueStorage);
		TypesSet.Add(AvailableTypesSets.UUID);
		TypesSet.Add(AvailableTypesSets.ValueCollections);
		TypesSet.Add(AvailableTypesSets.PointInTime);
		TypesSet.Add(AvailableTypesSets.Type);
		TypesSet.Add(AvailableTypesSets.Boundary);
		TypesSet.Add(AvailableTypesSets.UUID);
		TypesSet.Add(AvailableTypesSets.Null);
	ElsIf ActionMode = 2 Then 
		TypesSet.Add(AvailableTypesSets.References);
		TypesSet.Add(AvailableTypesSets.ComplexReferences);
		TypesSet.Add(AvailableTypesSets.Primitive);
		TypesSet.Add(AvailableTypesSets.ValueStorage);
		TypesSet.Add(AvailableTypesSets.UUID);
		TypesSet.Add(AvailableTypesSets.Null);
	ElsIf ActionMode = 3 Then 
		TypesSet.Add(AvailableTypesSets.References);
		TypesSet.Add(AvailableTypesSets.ComplexReferences);
		TypesSet.Add(AvailableTypesSets.Primitive);
		TypesSet.Add(AvailableTypesSets.ValueStorage);
		TypesSet.Add(AvailableTypesSets.UUID);
		TypesSet.Add(AvailableTypesSets.Null);
		TypesSet.Add(AvailableTypesSets.StandardPeriod);
		TypesSet.Add(AvailableTypesSets.SystemEnums);
	ElsIf Parameters.Property("TypesSet") Then
		//@skip-check unknown-form-parameter-access
		TempTypesSet = Parameters.TypesSet;
		If TypeOf(TempTypesSet) = Type("String") Then
			TempTypesArray = StrSplit(TempTypesSet, ",");
			For Each CurrSet In TempTypesArray Do
				TypesSet.Add(Upper(CurrSet));
			EndDo;
		ElsIf TypeOf(TempTypesSet) = Type("ValueList") Then
			For Each CurrSet In TempTypesSet Do
				TypesSet.Add(Upper(CurrSet.Value));
			EndDo;

		ElsIf TypeOf(TempTypesSet) = Type("Array") Then
			For Each CurrSet In TempTypesSet Do
				TypesSet.Add(Upper(CurrSet));
			EndDo;
		EndIf;
	EndIf;
	
	InitialDataType = New TypeDescription;	
	If Parameters.Property("DataType") Then
		//@skip-check unknown-form-parameter-access
		DataType = Parameters.DataType;
		If TypeOf(DataType) = Type("TypeDescription") Then
			InitialDataType = DataType;
		ElsIf TypeOf(DataType) = Type("String") Then 
			//@skip-check empty-except-statement
			Try
				InitialDataType = UT_Common.ValueFromXMLString(DataType, Type("TypeDescription"));
			Except
			EndTry;
		EndIf;
	ElsIf Parameters.Property("ValueTypeStorageContainer") Then 
		ReturnStorageForValueContainer = True;
		ValueContainerType = UT_CommonClientServer.ContainerValuesTypes().Type;
		//@skip-check unknown-form-parameter-access
		StorageContainer = Parameters.ValueTypeStorageContainer;//look at UT_CommonClientServer.NewValueStorageBoundaryType
		If StorageContainer <> Undefined Then
			Try
				ContainerDataType = ValueFromStringInternal(StorageContainer.Value);
				ArrayOfTypesForDescription = New Array();
				ArrayOfTypesForDescription.Add(ContainerDataType);
				InitialDataType = New TypeDescription(ArrayOfTypesForDescription);
			Except
				UT_CommonClientServer.MessageToUser(NStr("ru = 'Не удалось прочитать тип из контейнера.'; en = 'Failed to read type from container.'"));
			EndTry;
		EndIf;
	ElsIf Parameters.Property("ValueDescriptionsTypeStorageContainer") Then 
		ReturnStorageForValueContainer = True;
		ValueContainerType = UT_CommonClientServer.ContainerValuesTypes().TypeDescription;
		
		//@skip-check unknown-form-parameter-access
		StorageContainer = Parameters.ValueDescriptionsTypeStorageContainer;//look at UT_CommonClientServer.NewValueStorageBoundaryType
		If StorageContainer <> Undefined Then
			Try
				InitialDataType = UT_Common.ValueFromXMLString(StorageContainer.Value,
																			 Type("TypeDescription"));
			Except
				UT_CommonClientServer.MessageToUser(NStr("ru = 'Не удалось прочитать описание типов из контейнера.'; en = 'Failed to read type description from container.'"));
			EndTry;
		EndIf;
		
	EndIf;

	If Parameters.Property("TypeRestrictions") Then
		//@skip-check unknown-form-parameter-access
		TypeRestrictionsParameter = Parameters.TypeRestrictions;
		If TypeOf(TypeRestrictionsParameter) = Type("TypeDescription") Then
			TypeRestrictions = UT_Common.ValueToXMLString(TypeRestrictionsParameter);
		ElsIf TypeOf(TypeRestrictionsParameter) = Type("String") Then
			TypeRestrictions = TypeRestrictionsParameter;
		EndIf;
	EndIf;
		
	CompositeDataType = InitialDataType.Types().Count() > 1;

	If Parameters.Property("CompositeDataTypeAvailable") Then
		//@skip-check unknown-form-parameter-access
		CompositeDataTypeAvailable = Parameters.CompositeDataTypeAvailable;
	Else
		CompositeDataTypeAvailable = True;
	EndIf;
	
	If Parameters.Property("ChoiceMode") Then
		//@skip-check unknown-form-parameter-access
		ChoiceMode = Parameters.ChoiceMode;
		If ChoiceMode Then
			CompositeDataTypeAvailable = False;
		EndIf;
	Else
		ChoiceMode = False;
	EndIf;
	
	If ChoiceMode Then
		Title = NStr("ru = 'Выбор типа'; en = 'Type selection'");
	EndIf;
	
	If Not CompositeDataTypeAvailable Then
		CompositeDataType = False;
		Items.CompositeDataType.Visible = False;
	EndIf;
	
//	Items.TypesTreeSelected.Visible = Not ChoiceMode;
	Items.ReferredValueChoiceFormSelectionGroup.Visible = ChoiceMode
														And Not ReturnStorageForValueContainer;
	
	FillQualifiersDataByOriginalDataType(InitialDataType);
	
	FillTypesTree(InitialDataType);
	
	SetConditionalAppearance();
EndProcedure


#EndRegion

#Region FormItemsEvents

&AtClient
Procedure UnlimitedStringLengthOnChange(Item)
	If UnlimitedStringLength Then
		StringLength=0;
		AcceptableFixedStringLength=False;
	EndIf;
	Items.AcceptableFixedStringLength.Enabled = Not UnlimitedStringLength;
EndProcedure

&AtClient
Procedure StringLengthOnChange(Item)
	If Not ValueIsFilled(StringLength) Then
		UnlimitedStringLength=True;
		AcceptableFixedStringLength=False;
	Else
		UnlimitedStringLength=False;
	EndIf;
	Items.AcceptableFixedStringLength.Enabled = Not UnlimitedStringLength;
EndProcedure

&AtClient
Procedure SearchStringOnChange(Item)
	FillTypesTree();
	ExpandTreeItems();
EndProcedure

&AtClient
Procedure CompositeDataTypeOnChange(Item)
	If Not CompositeDataType Then
		If SelectedTypes.Count()=0 Then
			AddSelectedType("String");
		EndIf;
		Type=SelectedTypes[SelectedTypes.Count()-1];
		SelectedTypes.Clear();
		AddSelectedType(Type);
		
		SetSelectedTypesInTree(TypesTree,SelectedTypes);
	EndIf;
EndProcedure

#EndRegion

#Область ОбработчикиСобытийЭлементовТаблицыФормыДеревоТипов

&AtClient
Procedure TypesTreeSelection(Item, RowSelected, Field, StandardProcessing)
	СurrentRow = TypesTree.FindByID(RowSelected);
	If СurrentRow = Undefined Then
		Return;
	EndIf;
	
	СurrentRow.Selected = True;
	ChangeCheckTypeСhoiceHandler(СurrentRow);
	
	If ChoiceMode И Не CompositeDataType Then
		FinishTypeEditingAndCloseForm();
	EndIf;
EndProcedure

&AtClient
Procedure TypesTreeSelectedOnChange(Item)
	CurrentRow=Items.TypesTree.CurrentData;
	If CurrentRow=Undefined Then
		Return;
	EndIf;
	
	ChangeCheckTypeСhoiceHandler(CurrentRow);
EndProcedure

&AtClient
Procedure TypesTreeOnActivateRow(Item)
	CurrentData=Items.TypesTree.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	Items.GroupNumberQualifier.Visible=CurrentData.Name = NStr("ru = 'Число'; en = 'Number'");
	Items.GroupStringQualifier.Visible=CurrentData.Name = NStr("ru = 'Строка'; en = 'String'");
	Items.GroupDateQualifier.Visible=CurrentData.Name = NStr("ru = 'Дата'; en = 'Date'");
	
EndProcedure



#EndRegion

#Region FormCommandsHandlers

&AtClient
Procedure Apply(Command)
	FinishTypeEditingAndCloseForm();
EndProcedure

#EndRegion

#Region Internal


&НаСервере
Процедура AddTypesToArrayByCollectionMetadata(TypesArray, Collection, TypePrefix)
	For Each MDObject In Collection Do
		TypesArray.Add(Type(TypePrefix + MDObject.Name));
	EndDo;
КонецПроцедуры

&НаСервере
Функция ArrayOfSelectedTypes()
	TypesArray = New Array;
	
	For Each TypeItem In SelectedTypes Do 
		TypeRow = TypeItem.Value;
		
		If Lower(TypeRow) = Lower("AnyRef") Then
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Catalogs,"CatalogRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Documents,"DocumentRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ChartsOfCharacteristicTypes,"ChartOfCharacteristicTypesRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ChartsOfAccounts,"ChartOfAccountsRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ChartsOfCalculationTypes,"ChartOfCalculationTypesRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ExchangePlans,"ExchangePlanRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Enums,"EnumRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.BusinessProcesses,"BusinessProcessRef.");
			AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Tasks,"TaskRef.");
		ElsIf StrFind(Lower(TypeRow),Lower("Ref")) > 0 And StrFind(TypeRow,".") = 0 Then
			If Lower(TypeRow) = Lower("CatalogRef") Then
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Catalogs,"CatalogRef.");
			ElsIf Lower(TypeRow) = Lower("DocumentRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Documents,"DocumentRef.");
			ElsIf Lower(TypeRow) = Lower("ChartOfCharacteristicTypesRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ChartsOfCharacteristicTypes,"ChartOfCharacteristicTypesRef.");
			ElsIf Lower(TypeRow) = Lower("ChartOfAccountsRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ChartsOfAccounts,"ChartOfAccountsRef.");
			ElsIf Lower(TypeRow) = Lower("ChartOfCalculationTypesRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ChartsOfCalculationTypes,"ChartOfCalculationTypesRef.");
			ElsIf Lower(TypeRow) = Lower("ExchangePlanRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.ExchangePlans,"ExchangePlanRef.");
			ElsIf Lower(TypeRow) = Lower("EnumRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Enums,"EnumRef.");
			ElsIf Lower(TypeRow) = Lower("BusinessProcessRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.BusinessProcesses,"BusinessProcessRef.");
			ElsIf Lower(TypeRow) = Lower("TaskRef") Then	
				AddTypesToArrayByCollectionMetadata(TypesArray, Metadata.Tasks,"TaskRef.");
			EndIf;
		ElsIf TypeItem.Check Then
			NameArray = StrSplit(TypeRow,".");
			If NameArray.Count() <> 2 Then
				Continue;
			EndIf;
			ObjectName = NameArray[1];
			If StrFind(Lower(TypeRow), Lower("Characteristic")) > 0 Then
				MDObject = Metadata.ChartsOfCharacteristicTypes[ObjectName];
			ElsIf StrFind(Lower(TypeRow), Lower("DefinedType")) > 0 Then
				MDObject = Metadata.DefinedTypes[ObjectName];
			Else
				Continue;
			EndIf;
			TypeDescription = MDObject.Type;
			
			For Each  CurrentType ИЗ TypeDescription.Types() Do
				TypesArray.Add(CurrentType);
			EndDo;
			
		Else
			TypesArray.Add(TypeItem.Value);
		EndIf;
	EndDo;
	
	Return TypesArray;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция SelectedTypesDescription(Form, TypesArray)
	TypesLikeString = New Array;
	TypesLikeType = New Array;

	For Each CurrentType In TypesArray Do
		If TypeOf(CurrentType) = Type("Type") Then
			TypesLikeType.Add(CurrentType);
		Else
			TypesLikeString.Add(CurrentType);
		EndIf;
	EndDo;

	If Form.NonnegativeNumber Then
		Sign = AllowedSign.Nonnegative;
	Else
		Sign = AllowedSign.Any;
	EndIf;

	NumberQualifier = New NumberQualifiers(Form.NumberLength, Form.NumberPrecision, Sign);
	StringQualifier = New StringQualifiers(Form.StringLength, ?(Form.AcceptableFixedStringLength,
																	  AllowedLength.Fixed,
																	  AllowedLength.Variable));
	
	If Form.DateFormat = 1 Then
		DateFraction = DateFractions.Time;
	ElsIf Form.DateFormat = 2 Then
		DateFraction = DateFractions.DateTime;
	Else
		DateFraction = DateFractions.Date;
	EndIf;
	
	DateQualifier = New DateQualifiers(DateFraction);

	Description = New TypeDescription;
	If TypesLikeType.Count() > 0 Then
		Description = New TypeDescription(Description, TypesLikeType, , NumberQualifier, StringQualifier, DateQualifier);
	EndIf;
	If TypesLikeString.Count() > 0 Then
		Description = New TypeDescription(Description, СтрСоединить(TypesLikeString, ","), , NumberQualifier, StringQualifier,
			DateQualifier);
	EndIf;
	
	Return Description;
КонецФункции

&НаСервере
Функция ReturnStorageForContainer()
	TypesArray = ArrayOfSelectedTypes();
	
	Description = SelectedTypesDescription(ThisObject, TypesArray);
	
	TypeStorage = UT_CommonClientServer.NewValueStorageType();
	TypeStorage.Name = String(Description);
	
	ContainerTypes = UT_CommonClientServer.ContainerValuesTypes();
	If ValueContainerType = ContainerTypes.Type Then
		Types = Description.Types();
		If Types.Count() = 0 Then
			TypeInContainer = Type("Undefined");
		Else
			TypeInContainer = Types[0];
		EndIf;
		
		TypeStorage.Value = ValueToStringInternal(TypeInContainer);
	Else
		TypeStorage.Value = UT_Common.ValueToXMLString(Description);
	EndIf;
	
	Return TypeStorage;
КонецФункции

&НаКлиенте
Процедура ChangeCheckTypeСhoiceHandler(СurrentRow)
	
	If СurrentRow.Selected Then
		If Not CompositeDataType Then
			SelectedTypes.Очистить();
		ElsIf СurrentRow.UnavailableForCompositeType Then
			If SelectedTypes.Count() > 0 Then
				ShowQueryBox(New CallbackDescription("TypesTreeSelectedOnChangeEnd", ThisObject,
					New Structure("СurrentRow", СurrentRow)), NStr("ru = 'Выбран тип, который не может быть включен в составной тип данных.'; en = 'A type was selected that cannot be included in a composite data type.'") + Chars.LF 
					+ NStr("ru = 'Будут исключены остальные типы данных.'; en = 'Other data types will be excluded.'") + Chars.LF
					+ NStr("ru = 'Продолжить?'; en = 'Continue?'"), QuestionDialogMode.YesNo);
				Return;
			EndIf;
		Else
			IsUnAvailableForCompositeType = Ложь;
			For Each  Item Из SelectedTypes Do
				If Item.Check Then
					IsUnAvailableForCompositeType = True;
					Прервать;
				EndIf;
			EndDo;
			
			If IsUnAvailableForCompositeType Then
				ShowQueryBox(New CallbackDescription("TypesTreeSelectedOnChangeEndWasNotAllowedForCompositeType", ThisObject,
					New Structure("СurrentRow", СurrentRow)), NStr("ru = 'Ранее был выбран тип, который не может быть'; en = 'A type was previously selected that cannot be'") + Chars.LF  																	  
					+ NStr("ru = 'включен в составной тип данных и будет исключен.'; en = 'included in a composite data type and will be excluded.'") + Chars.LF 
					+ NStr("ru = 'Продолжить?'; en = 'Continue?'"), QuestionDialogMode.YesNo);
				Return;
			EndIf;
		EndIf;
	Else
		Item = SelectedTypes.FindByValue(СurrentRow.Name);
		If Item <> Undefined Then
			SelectedTypes.Delete(Item);
		EndIf;

	EndIf;
	TypesTreeSelectedOnChangeFragment(СurrentRow);

	
КонецПроцедуры

&НаКлиенте
Процедура FinishTypeEditingAndCloseForm()
	If ReturnStorageForValueContainer Then
		ReturnValue = ReturnStorageForContainer();
	Else
		TypesArray = ArrayOfSelectedTypes();
		
		Description = SelectedTypesDescription(ThisObject, TypesArray);
		ReturnValue = Description;
		If ChoiceMode Then
			ReturnValue = New Structure;
			ReturnValue.Insert("Description", Description);
			ReturnValue.Insert("UseDynamicListForRefValueSelection",
										  UseDynamicListForRefValueSelection);
		EndIf;
	EndIf;
	
	Close(ReturnValue);
	
КонецПроцедуры

&НаСервере
Функция TypesSetAvailable(Set)
	Return TypesSet.FindByValue(Set) <> Undefined;
КонецФункции

&AtServer
Function PrimitiveTypeIsAvailable()
	Return TypesSetAvailable(AvailableTypesSets.Primitive);
EndFunction

&AtServer
Function ValueStorageIsAvailable()
	Return TypesSet.FindByValue("VALUESTORAGE") <> Undefined;	
EndFunction

&AtServer
Function NullIsAvailable()
	Return TypesSet.FindByValue("NULL") <> Undefined;	
EndFunction

&AtServer
Function RefIsAvailable()
	Return TypesSet.FindByValue("REF") <> Undefined;	
EndFunction

&AtServer
Function CompositeRefIsAvailable()
	Return TypesSet.FindByValue("COMPOSITEREF") <> Undefined;	
EndFunction

&AtServer
Function UUIDIsAvailable()
	Return TypesSet.FindByValue("UUID") <> Undefined;
EndFunction

&AtServer
Function ValueCollectionIsAvailable()
	Return TypesSet.FindByValue("VALUECOLLECTION") <> Undefined;	
EndFunction

&AtServer
Function PointInTimeIsAvailable()
	Return TypesSet.FindByValue("POINTINTIME") <> Undefined;
EndFunction

&AtServer
Function TypeTypeIsAvailable()
	Return TypesSet.FindByValue("TYPE") <> Undefined;
EndFunction

&AtServer
Function BoundaryIsAvailable()
	Return TypesSet.FindByValue("BOUNDARY") <> Undefined;
EndFunction

&AtServer
Function StandardPeriodIsAvailable()
	Return TypesSet.FindByValue("STANDARDPERIOD") <> Undefined;
EndFunction

&AtServer
Function SystemEnumerationIsAvailable()
	Return TypesSet.FindByValue("SYSTEMENUMERATION") <> Undefined;	
EndFunction

&AtServer
Function AddTypeToTypesTree(InitialDataType, TypeName, Picture, TypeRestrictionsDescription, Presentation = "", 
	TreeRow = Undefined, IsGroup = False, Group = False, UnavailableForCompositeType = False)
	
	If ValueIsFilled(Presentation) Then
		TypePresentation = Presentation;
	Else
		TypePresentation = TypeName;
	EndIf;

	If ValueIsFilled(SearchString) And Not Group Then
		If StrFind(Lower(TypePresentation), Lower(SearchString)) = 0 Then
			Return Undefined;
		EndIf;
	EndIf;
	
	If TreeRow = Undefined Then
		AdditionElement = TypesTree;
	Else
		AdditionElement = TreeRow;
	EndIf;
	
	Try
		CurrentType = Type(TypeName);
	Except
		CurrentType = Undefined;
	EndTry;
	
	If TypeOf(TypeRestrictionsDescription) = Type("TypeDescription") And CurrentType <> Undefined Then
		If Not TypeRestrictionsDescription.СодержитТип(CurrentType) Then
			Return Undefined;
		EndIf;
	EndIf; 

	NewRow = AdditionElement.GetItems().Add();
	NewRow.Name = TypeName;
	NewRow.Presentation = TypePresentation;
	NewRow.Picture = Picture;
	NewRow.IsGroup = IsGroup;
	NewRow.UnavailableForCompositeType = UnavailableForCompositeType;
	NewRow.Group = Group;
	
	If InitialDataType <> Undefined And CurrentType <> Undefined Then
		If InitialDataType.ContainsType(CurrentType) Then
			SelectedTypes.Add(NewRow.Name, , NewRow.UnavailableForCompositeType);
		EndIf;
	EndIf;


	Return NewRow;
EndFunction

&AtServer
Procedure FillTypesByObjectType(MetadataObjectsType, TypePrefix, Picture, InitialDataType,
	TypeRestrictionsDescription)
	ObjectsCollection = Metadata[MetadataObjectsType];

	CollectionRow = AddTypeToTypesTree(InitialDataType,
											TypePrefix,
											Picture,
											TypeRestrictionsDescription,
											TypePrefix,
											,
											,
											True);

	For Each  MetadataObject Из ObjectsCollection Do
		AddTypeToTypesTree(InitialDataType,
								TypePrefix + "." + MetadataObject.Name,
								Picture,
								TypeRestrictionsDescription,
								MetadataObject.Name,
								CollectionRow);
	EndDo;
	
	DeleteTreeRowIfNotSubordinatesOnSearch(CollectionRow, TypeRestrictionsDescription);
EndProcedure

&AtServer
Procedure FillPrimitiveTypes(InitialDataType, TypeRestrictionsDescription)
	//AddTypeToTypesTree("Arbitrary", PictureLib.UT_ArbitraryType);
	If PrimitiveTypeIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,"Number", PictureLib.UT_Number, TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType,"String", PictureLib.UT_String, TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType,"Date", PictureLib.UT_Date, TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType,"Boolean", PictureLib.UT_Boolean, TypeRestrictionsDescription);
	EndIf;
	If ValueStorageIsAvailable() Then      
		AddTypeToTypesTree(InitialDataType,"ValueStorage", New Picture, TypeRestrictionsDescription);
	EndIf;
	
	If ValueCollectionIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,
			"ValueTable",
			PictureLib.UT_ValueTable,
			TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType,
			"ValueList", 
			PictureLib.UT_ValueList,
			TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType,
		"Array",
		 PictureLib.UT_Array,
		 TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType, "Array", PictureLib.UT_Array, TypeRestrictionsDescription,);
		AddTypeToTypesTree(InitialDataType, "Structure", New Picture, TypeRestrictionsDescription);
		AddTypeToTypesTree(InitialDataType, "Map", New Picture, TypeRestrictionsDescription);		
	EndIf;
	If TypeTypeIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,"Type", PictureLib.ChooseType, TypeRestrictionsDescription);
	EndIf;
	If TypesSetAvailable(AvailableTypesSets.TypeDescription) Then
		AddTypeToTypesTree(InitialDataType,
								"TypeDescription",
								PictureLib.UT_DescriptionOfTypes,
								TypeRestrictionsDescription);
	EndIf;
	
	If PointInTimeIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,
			"PointInTime", 
			PictureLib.UT_PointInTime,
			TypeRestrictionsDescription);
	EndIf;
	If BoundaryIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,
			"Boundary", 
			PictureLib.UT_Boundary,
			TypeRestrictionsDescription);
	EndIf;
	If UUIDIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,
			"UUID", 
			PictureLib.UT_UUID,
			TypeRestrictionsDescription);
	EndIf;
	If NullIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,"Null", PictureLib.UT_Null,TypeRestrictionsDescription);
	EndIf;
	
	FillAdditionalTypes(InitialDataType, TypeRestrictionsDescription);
EndProcedure

&AtServer
Procedure FillCharacteristicsTypes(InitialDataType, TypeRestrictionsDescription)
	If Not CompositeRefIsAvailable() Then
		Return;
	EndIf;
	//Characteristics
	Charts=Metadata.ChartsOfCharacteristicTypes;
	If Charts.Count()=0 Then
		Return;
	EndIf;
	
	CharacteristicsRow=AddTypeToTypesTree(InitialDataType,
		"Characteristics", 
		PictureLib.Folder,
		TypeRestrictionsDescription,
		,
		,
		True,
		True);
	
	For Each Chart In Charts Do
		AddTypeToTypesTree(InitialDataType,
			"Characteristic." + Chart.Name,
			New Picture,
			TypeRestrictionsDescription,
			Chart.Name,
			CharacteristicsRow,
			,
			,
			True);
	EndDo;
	
	DeleteTreeRowIfNotSubordinatesOnSearch(CharacteristicsRow, TypeRestrictionsDescription);

EndProcedure

&AtServer
Procedure FillDefinedTypes(InitialDataType, TypeRestrictionsDescription)
	If Not CompositeRefIsAvailable() Then
		Return;
	EndIf;
	
	//Characteristics
	Types = Metadata.DefinedTypes;
	If Types.Count() = 0 Then
		Return;
	EndIf;
	
	TypeAsString = AddTypeToTypesTree(InitialDataType,
		"DefinedType", 
		PictureLib.Folder,
		TypeRestrictionsDescription,
		,
		,
		True,
		True);
	
	For Each DefinedType In Types Do
		AddTypeToTypesTree(InitialDataType,
			"DefinedType." + DefinedType.Name,
			New Picture,
			TypeRestrictionsDescription,
			DefinedType.Name,
			TypeAsString,
			,
			,
			True);
	EndDo;
	DeleteTreeRowIfNotSubordinatesOnSearch(TypeAsString, TypeRestrictionsDescription);
EndProcedure

&AtServer
Procedure FillTypesOfSystemEnumerations(InitialDataType, TypeRestrictionsDescription)
	If Not SystemEnumerationIsAvailable() Then
		Return;
	EndIf;
	TypeAsString=AddTypeToTypesTree(InitialDataType,
		"SystemEnumerations", 
		PictureLib.Folder,
		TypeRestrictionsDescription,
		"System Enumerations",
		,
		True,
		True);

	AddTypeToTypesTree(InitialDataType,
		"AccumulationRecordType",
		PictureLib.UT_AccumulationRecordType,
		TypeRestrictionsDescription,
		,
		TypeAsString);
	AddTypeToTypesTree(InitialDataType,
		"AccountType",
		PictureLib.ChartOfAccountsObject,
		TypeRestrictionsDescription,
		,
		TypeAsString);
	AddTypeToTypesTree(InitialDataType,
		"AccountingRecordType",
		PictureLib.ChartOfAccounts,
		TypeRestrictionsDescription,
		,
		TypeAsString);
	AddTypeToTypesTree(InitialDataType,
		"AccumulationRegisterAggregateUse",
		New Picture,
		TypeRestrictionsDescription,
		,
		TypeAsString);
	AddTypeToTypesTree(InitialDataType,
		"AccumulationRegisterAggregatePeriodicity",
		New Picture,
		TypeRestrictionsDescription,
		,
		TypeAsString);
	
	DeleteTreeRowIfNotSubordinatesOnSearch(TypeAsString, TypeRestrictionsDescription);
EndProcedure

&НаСервере
Процедура FillAdditionalTypes(InitialDataType, TypeRestrictionsDescription)
	If TypesSetAvailable(AvailableTypesSets.SpreadsheetDocument) Then
		AddTypeToTypesTree(InitialDataType,
								"SpreadsheetDocument",
								PictureLib.SpreadsheetShowHeaders,
								TypeRestrictionsDescription);
	EndIf;
	If TypesSetAvailable(AvailableTypesSets.Picture) Then
		AddTypeToTypesTree(InitialDataType,
								"Picture",
								PictureLib.Picture,
								TypeRestrictionsDescription);
	EndIf;
	If TypesSetAvailable(AvailableTypesSets.BinaryData) Then
		AddTypeToTypesTree(InitialDataType,
								"BinaryData",
								New Picture,
								TypeRestrictionsDescription);
	EndIf;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьФиксированныеКоллекции(InitialDataType, TypeRestrictionsDescription)
	If Not TypesSetAvailable(AvailableTypesSets.FixedValueCollections) Then
		Return;
	EndIf;
	
	AddTypeToTypesTree(InitialDataType,
							"FixedArray",
							PictureLib.UT_FixedArray,
							TypeRestrictionsDescription);
	AddTypeToTypesTree(InitialDataType, "FixedStructure",
							PictureLib.UT_FixedArray,
							TypeRestrictionsDescription);
	AddTypeToTypesTree(InitialDataType,
							"FixedMap",
							PictureLib.UT_FixedArray,
							TypeRestrictionsDescription);

КонецПроцедуры

&AtServer
Procedure FillTypesTree(InitialDataType = Undefined)
	TypeRestrictionsDescription = Undefined;
	If ValueIsFilled(TypeRestrictions) Then
		//@skip-check empty-except-statement
		Try
			TypeRestrictionsDescription = UT_Common.ValueFromXMLString(TypeRestrictions, Type("TypeDescription"));
		Except
		EndTry;
		If TypeRestrictionsDescription = New TypeDescription Then
			TypeRestrictionsDescription = Undefined;
		EndIf;
	EndIf;
	
	TypesTree.GetItems().Clear();
	FillPrimitiveTypes(InitialDataType, TypeRestrictionsDescription);
	FillTypesByObjectType("Catalogs",
		"CatalogRef",
		PictureLib.Catalog,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("Documents",
		"DocumentRef",
		PictureLib.Document,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("ChartsOfCharacteristicTypes",
		"ChartOfCharacteristicTypesRef",
		PictureLib.ChartOfCharacteristicTypes,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("ChartsOfAccounts", "ChartOfAccountsRef",
		PictureLib.ChartOfAccounts,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("ChartsOfCalculationTypes",
		"ChartOfCalculationTypesRef",
		PictureLib.ChartOfCalculationTypes,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("ExchangePlans",
		"ExchangePlanRef", 
		PictureLib.ExchangePlan,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("Enums", 
		"EnumRef", 
		PictureLib.Enum,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("BusinessProcesses",
		"BusinessProcessRef",
		PictureLib.BusinessProcess,
		InitialDataType,
		TypeRestrictionsDescription);
	FillTypesByObjectType("Tasks",
		"TaskRef",
		PictureLib.Task,
		InitialDataType,
		TypeRestrictionsDescription);
	//FillTypesByObjectType("BusinessProcessRoutePointsRef", "BusinessProcessRoutePointRef");
	
	FillCharacteristicsTypes(InitialDataType, TypeRestrictionsDescription);
	//@skip-check empty-except-statement
	Try
		FillDefinedTypes(InitialDataType, TypeRestrictionsDescription);
	Except
	EndTry;
	If CompositeRefIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,
		"AnyRef",
		New Picture,
		TypeRestrictionsDescription,
		"Any reference");
	EndIf;
	ЗаполнитьФиксированныеКоллекции(InitialDataType, TypeRestrictionsDescription);
	If StandardPeriodIsAvailable() Then
		AddTypeToTypesTree(InitialDataType,
			"StandardBeginningDate", 
			New Picture,
			TypeRestrictionsDescription,
			"Standard beginning date");
		AddTypeToTypesTree(InitialDataType,
			"StandardPeriod", 
			New Picture,
			TypeRestrictionsDescription, 
			"Standard period");
	EndIf;
	FillTypesOfSystemEnumerations(InitialDataType, TypeRestrictionsDescription);
	
	SetSelectedTypesInTree(TypesTree,SelectedTypes);
EndProcedure

&AtServer
Procedure SetConditionalAppearance()
	// Groups cannot be selected
	NewCa=ConditionalAppearance.Items.Add();
	NewCa.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCa.Filter,
		"Items.TypesTree.CurrentData.IsGroup", True);
	Field=NewCa.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("TypesTreeSelected");

	Appearance=NewCa.Appearance.FindParameterValue(New DataCompositionParameter("Show"));
	Appearance.Use=True;
	Appearance.Value=False;
	
	// If the string is unlimited, then you cannot change the allowed length of the string
	NewCa=ConditionalAppearance.Items.Add();
	NewCa.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCa.Filter,
		"StringLength", 0);
	Field=NewCa.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("AcceptableFixedStringLength");

	Appearance=NewCa.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	If ChoiceMode Then
		NewCA=ConditionalAppearance.Items.Add();
		NewCA.Use=True;
		UT_CommonClientServer.SetFilterItem(NewCA.Filter,
			"Items.TypesTree.CurrentData.Group", True);
		Field=NewCA.Fields.Items.Add();
		Field.Use=True;
		Field.Field=New DataCompositionField("TypesTreeSelected");

		Appearance=NewCA.Appearance.FindParameterValue(New DataCompositionParameter("Show"));
		Appearance.Use=True;
		Appearance.Value=False;

	EndIf;
EndProcedure

&AtServer
Procedure DeleteTreeRowIfNotSubordinatesOnSearch(TreeRow, TypeRestrictionsDescription)
	If Not ValueIsFilled(SearchString) And TypeRestrictionsDescription = Undefined Then
		Return;
	EndIf;
	If TreeRow.GetItems().Count()=0 Then
		TypesTree.GetItems().Delete(TreeRow);
	EndIf;
EndProcedure

&AtClient
Procedure ExpandTreeItems()
	For each TreeRow In TypesTree.GetItems() Do 
		Items.TypesTree.Expand(TreeRow.GetID());
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Procedure SetSelectedTypesInTree(TreeRow,SelectedTypes)
	For Each Item In TreeRow.GetItems() Do
		Item.Selected=SelectedTypes.FindByValue(Item.Name)<>Undefined;
		
		SetSelectedTypesInTree(Item, SelectedTypes);
	EndDo;
EndProcedure

&AtClient
Procedure AddSelectedType(TreeRowOrType)
	If TypeOf(TreeRowOrType)=Type("String") Then
		TypeName=TreeRowOrType;
		UnavailableForCompositeType=False;
	 ElsIf TypeOf(TreeRowOrType)=Type("ValueListItem") Then
		TypeName=TreeRowOrType.Value;
		UnavailableForCompositeType=TreeRowOrType.Check;
	Else
		TypeName=TreeRowOrType.Name;
		UnavailableForCompositeType=TreeRowOrType.UnavailableForCompositeType;
	EndIf;
	
	If SelectedTypes.FindByValue(TypeName)=Undefined Then
		SelectedTypes.Add(TypeName,,UnavailableForCompositeType);
	EndIf;
EndProcedure
&AtClient
Procedure TypesTreeSelectedOnChangeEnd(QuestionResult, AdditionalParameters) Export
	
	Answer=QuestionResult;
	
	If Answer=DialogReturnCode.No Then
		AdditionalParameters.CurrentRow.Selected=False;
		Return;
	EndIf;

	SelectedTypes.Clear();
	TypesTreeSelectedOnChangeFragment(AdditionalParameters.CurrentRow);
EndProcedure
&AtClient
Procedure TypesTreeSelectedOnChangeEndWasNotAllowedForCompositeType(QuestionResult, AdditionalParameters) Экспорт
	
	Answer=QuestionResult;
	
	If Answer=DialogReturnCode.No Then
		AdditionalParameters.CurrentRow.Selected=False;
		Return;
	EndIf;

	DeletedItemsArray=New Array;
	For Each Item In SelectedTypes Do 
		If Item.Check Then
			DeletedItemsArray.Add(Item);
		EndIf;
	EndDo;
	
	For Each Item In  DeletedItemsArray Do
		SelectedTypes.Delete(Item);
	EndDo;
	
	TypesTreeSelectedOnChangeFragment(AdditionalParameters.CurrentRow);
EndProcedure

&AtClient
Procedure TypesTreeSelectedOnChangeFragment(CurrentRow) Export
		
	If CurrentRow.Selected Then
		AddSelectedType(CurrentRow);
	EndIf;

	If SelectedTypes.Count()=0 Then
		AddSelectedType("String");
	EndIf;
	
	SetSelectedTypesInTree(TypesTree,SelectedTypes);
EndProcedure


&AtServer
Procedure FillQualifiersDataByOriginalDataType(InitialDataType)
	NumberLength=InitialDataType.NumberQualifiers.Digits;
	NumberPrecision=InitialDataType.NumberQualifiers.FractionDigits;
	NonnegativeNumber= InitialDataType.NumberQualifiers.AllowedSign=AllowedSign.Nonnegative;
	
	StringLength=InitialDataType.StringQualifiers.Length;
	UnlimitedStringLength=Not ValueIsFilled(StringLength);
	AcceptableFixedStringLength=InitialDataType.StringQualifiers.AllowedLength=AllowedLength.Fixed;

	If InitialDataType.DateQualifiers.DateFractions=DateFractions.Time Then
		DateFormat= 1;
	 ElsIf InitialDataType.DateQualifiers.DateFractions=DateFractions.DateTime Then
		DateFormat=2;
	EndIf;
EndProcedure

#EndRegion