#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ColumnsContainerEndPrefix = "____Container__";

	If Parameters.Property("SerializeToXML") Then
		//@skip-check unknown-form-parameter-access
		SerializeToXML = Parameters.SerializeToXML;
	EndIf;
	
	Table = Undefined;
	If Parameters.Property("ValueTableAsString") Then
		//@skip-check unknown-form-parameter-access
		Table = TableOfValuesFromStringRepresentation(Parameters.ValueTableAsString, SerializeToXML);
	ElsIf Parameters.Property("ValueContainerStorage") Then 
		ReturningStorageForValueContainer = True;
		
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueContainerStorage; //см. UT_CommonClientServer.NewValueStorageValueTableType
		
		SerializeToXML = False;
		If ContainerStorage <> Undefined Then
			Table = UT_Common.ValueFromValueTableContainerStorage(ContainerStorage);
		EndIf;
	ElsIf Parameters.Property("ValueTreeContainerStorage") Then 
		ReturningStorageForValueContainer = True;
		IsTree = True;
		
		//@skip-check unknown-form-parameter-access
		ContainerStorage = Parameters.ValueTreeContainerStorage; //см. UT_CommonClientServer.NewValueStorageValueTableType
		
		SerializeToXML = False;
		If ContainerStorage <> Undefined Then
			Table = UT_Common.ValueFromValueTreeContainerStorage(ContainerStorage);
		EndIf;
	EndIf;

	If Table = Undefined Then
		If IsTree Then
			Table = New ValueTree;
		Else
			Table = New ValueTable;
		EndIf;
	EndIf;
	If IsTree Then
		Title = NStr("ru = 'Редактор дерева значения'; en = 'Value tree editor'");
	Else
		Title = NStr("ru = 'Редактор таблицы значения'; en = 'Value table editor'")
	EndIf;
	AddRootItemAndAttributeTables();	

	FillValueTableColumns(Table);
	CreateFormValueTableColumns();
	If IsTree Then
		FillFormTreeValuesByTree(Table);
	Else
		FillFormValueTableByTable(Table);
	EndIf;
	
	If TableColumns.Количество() = 0 Then
		Items.GroupTableColumns.Show();
	EndIf;
	
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersTableColumns

&AtClient
Procedure TableColumnsBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	If CancelEdit Then
		Return;
	EndIf;
	CurrentData = Items.TableColumns.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	ColumnName = CurrentData.Name;

	If Not UT_CommonClientServer.IsCorrectVariableName(ColumnName) Then
		ShowMessageBox( ,
			UT_CommonClientServer.WrongVariableNameWarningText(),
			, Title);
		Cancel = True;
		Return;
	EndIf;

	NameRows = TableColumns.НайтиСтроки(New Structure("Name", ColumnName));
	If NameRows.Count() > 1 Then
		ShowMessageBox( , NStr("ru = 'Колонка с таким именем уже есть! Введите другое имя.'; en = 'There is already a column with that name! Enter a different name.'"), , Title);
		Cancel = True;
		Return;
	EndIf;
EndProcedure

&AtClient
Procedure TableColumnsValueTypeStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData = Items.TableColumns.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	StandardProcessing = False;
	CurrentRow = Items.TableColumns.CurrentRow;

	UT_CommonClient.EditType(CurrentData.ValueType, 1, StandardProcessing, ThisObject,
		New NotifyDescription("TableColumnsValueTypeStartChoiceEND", ThisObject,
		New Structure("CurrentRow", CurrentRow)));
EndProcedure

&AtClient
Procedure TableColumnsAfterDeleteRow(Item)
	CreateFormValueTableColumns();
EndProcedure

&AtClient
Procedure TableColumnsOnEditEnd(Item, NewRow, CancelEdit)
	If CancelEdit Then
		Return;
	EndIf;
	
	CurrentData = Items.TableColumns.CurrentData;
	CurrentData.NameForSearch = Lower(CurrentData.Name);

	Items.ValueTable.Enabled = False;
	AttachIdleHandler("CreateColumnsTablesValuesFormsHandlerExpectations", 0.1, True);
EndProcedure

#EndRegion

#Область FormTableItemsEventHandlersValueTable

&AtClient 
Procedure Подключаемый_ПолеТаблицыЗначенийПриИзменении(Item)
	CurrentData = Items.ValueTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	TableRowColumns = TableRowColumns(TableColumns, Mid(Lower(Item.Name), StrLen("valuetable")+1));
	If TableRowColumns = Undefined Then
		Return;
	EndIf;
	
	HandlerParameters = UT_CommonClient.NewProcessorInChangingEventsParameters(ThisObject,
		Item,
		"Value");
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;
	
	TableColumnStorageStructureOnForm = TableColumnStorageStructureOnForm(TableRowColumns.Name);
	FillPropertyValues(HandlerParameters, TableColumnStorageStructureOnForm);

	UT_CommonClient.FormFieldInChangeProcessor(HandlerParameters);
	
EndProcedure

&AtClient
Procedure Подключаемый_ПолеТаблицыЗначенийНачалоВыбора(Item, ChosenData, StandardProcessing)
	CurrentData = Items.ValueTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	TableRowColumns = TableRowColumns(TableColumns, Mid(Lower(Item.Name), StrLen("valuetable")+1));
	If TableRowColumns = Undefined Then
		StandardProcessing = False;
		Return;
	EndIf;

	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
		Item,
		TableRowColumns.Name);
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.Value = CurrentData[TableRowColumns.Name];
	HandlerParameters.StructureValueStorage 		= CurrentData;
	HandlerParameters.TypesSet 						= UT_CommonClientServer.AllEditingTypeSets();
	HandlerParameters.CurrentDescriptionValueTypes 	= TableRowColumns.ValueType;

	TableColumnStorageStructureOnForm = TableColumnStorageStructureOnForm(TableRowColumns.Name);
	FillPropertyValues(HandlerParameters, TableColumnStorageStructureOnForm);
	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure Подключаемый_ПолеТаблицыЗначенийОчистка(Item, StandardProcessing)
	CurrentData = Items.ValueTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	TableRowColumns = TableRowColumns(TableColumns, Mid(Lower(Item.Name), StrLen("valuetable")+1));
	If TableRowColumns = Undefined Then
		StandardProcessing = False;
		Return;
	EndIf;

	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
		Item,
		TableRowColumns.Name);
	HandlerParameters.AvailableContainer = True;
	HandlerParameters.StructureValueStorage = CurrentData;
	HandlerParameters.CurrentDescriptionValueTypes = TableRowColumns.ValueType;
	
	TableColumnStorageStructureOnForm = TableColumnStorageStructureOnForm(TableRowColumns.Name);
	FillPropertyValues(HandlerParameters, TableColumnStorageStructureOnForm);
	
	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);
EndProcedure


#КонецОбласти

#Region FormCommandsEventHandlers
&AtClient
Procedure Apply(Command)
	If IsTree Then
		ResultStructure=ResultValueTreeInStorage();
	Else
		ResultStructure = ResultValueTableToString();
	EndIf;
	
	Close(ResultStructure);	
EndProcedure
#EndRegion

#Region Private

&AtClientAtServerNoContext
Function TableRowColumns(Columns, Name)
	Search = New Structure;
	Search.Insert("NameForSearch", Lower(Name));
	
	FoundStrings = Columns.FindRows(Search);
	If FoundStrings.Count() = 0 Then
		Return Undefined;
	Else
		Return FoundStrings[0];
	EndIf;
EndFunction

&AtClient
Procedure CreateColumnsTablesValuesFormsHandlerExpectations()
	CreateFormValueTableColumns();
	Items.TableColumns.Enabled = True;
EndProcedure

&AtServerNoContext
Function TableOfValuesFromStringRepresentation(TableStringRepresentation, SerializeToXML)

	If SerializeToXML Then
		Try
			ValueTable = UT_Common.ValueFromXMLString(TableStringRepresentation);
		Except
			ValueTable = New ValueTable;
		EndTry;
	Else
		Try
			ValueTable = ValueFromStringInternal(TableStringRepresentation);
		Except
			ValueTable = New ValueTable;
		EndTry;
	EndIf;
	Return ValueTable;

EndFunction

&AtServer
Procedure FillValueTableColumns(ValueTable)
	TableColumns.Clear();

	For Each Column In ValueTable.Columns Do
		NewRow = TableColumns.Add();
		NewRow.Name = Column.Name;
		NewRow.NameForSearch = Lower(Column.Name);
		NewRow.ValueType = Column.ValueType;
	EndDo;
EndProcedure

&AtServerNoContext
Procedure RemoveValueFromArray(Array, Value)
	Index = Array.Find(Value);
	If Index = Undefined Then
		Return;
	EndIf;
	
	Array.Delete(Index);
EndProcedure

&AtServer
Function AdditionalTableColumnName(FieldName, Suffix)
	Return ColumnsContainerEndPrefix + FieldName + Suffix + ColumnsContainerEndPrefix;
EndFunction

&AtServer
Procedure CreateFormValueTableColumns()
	TypeStoredInContainer = UT_CommonClientServer.TypesStoredInContainers();
	
	ArrayOfRemovableAttributes = New Array;
	ArrayOfAddedAttributes = New Array;
	
	ArrayOfCurrentColumnsOfTable = GetAttributes(StorageAttributeName);
	
	AlreadyCreatedColumns = New Structure;

	For Each СurrentAttribute In ArrayOfCurrentColumnsOfTable Do
		ArrayOfRemovableAttributes.Add(StorageAttributeName + "." + Lower(СurrentAttribute.Name));
		If StrStartsWith(СurrentAttribute.Name, ColumnsContainerEndPrefix) 
			And StrEndsWith(СurrentAttribute.Name, ColumnsContainerEndPrefix) Then
			Continue;
		EndIf;
		AlreadyCreatedColumns.Insert(СurrentAttribute.Name, СurrentAttribute);

	EndDo;
	ColumnsForCastingTypes = New Array;

	FieldColumnStructuresStoringValues = New Structure;

	For Each  CurrentColumn In TableColumns Do
		FieldColumnStructuresStoringValues.Insert(CurrentColumn.Name,
													  TableColumnStorageStructureOnForm(CurrentColumn.Name));
		If AlreadyCreatedColumns.Property(CurrentColumn.Name) Then
			If CurrentColumn.ValueType <> AlreadyCreatedColumns[CurrentColumn.Name].ValueType Then
				ColumnsForCastingTypes.Add(CurrentColumn);
			EndIf;

			RemoveValueFromArray(ArrayOfRemovableAttributes, StorageAttributeName + "." + Lower(CurrentColumn.Name));
			RemoveValueFromArray(ArrayOfRemovableAttributes, StorageAttributeName
				+ "."
				+ Lower(AdditionalTableColumnName(CurrentColumn.Name,
						UT_CommonClientServer.SuffixContainerStorageFieldName())));
			RemoveValueFromArray(ArrayOfRemovableAttributes, StorageAttributeName
				+ "."
				+ Lower(AdditionalTableColumnName(CurrentColumn.Name,
						UT_CommonClientServer.SuffixValueTypeStorageFieldName())));
			RemoveValueFromArray(ArrayOfRemovableAttributes, StorageAttributeName
				+ "."
				+ Lower(AdditionalTableColumnName(CurrentColumn.Name,
						UT_CommonClientServer.SuffixPresentationStorageFieldName())));

		Else
			ArrayOfAddedAttributes.Add(New FormAttribute(CurrentColumn.Name, New TypeDescription,
				StorageAttributeName, , True));
			ArrayOfAddedAttributes.Add(New FormAttribute(AdditionalTableColumnName(CurrentColumn.Name,
					UT_CommonClientServer.SuffixContainerStorageFieldName()),
				New TypeDescription, StorageAttributeName, , True));
			ArrayOfAddedAttributes.Add(New FormAttribute(AdditionalTableColumnName(CurrentColumn.Name,
					UT_CommonClientServer.SuffixValueTypeStorageFieldName()),
				New TypeDescription("TypeDescription"), StorageAttributeName, , True));
			ArrayOfAddedAttributes.Add(New FormAttribute(AdditionalTableColumnName(CurrentColumn.Name,
				UT_CommonClientServer.SuffixPresentationStorageFieldName()),
				UT_CommonClientServer.DescriptionTypeString(0), StorageAttributeName, , True));

		EndIf;
	EndDo;

	ChangeAttributes(ArrayOfAddedAttributes, ArrayOfRemovableAttributes);

	For Each CurrentColumn In TableColumns Do
		ItemDescription = UT_Forms.ItemAttributeNewDescription();
		ItemDescription.Insert("Name", CurrentColumn.Name);
		ItemDescription.Insert("DataPath", StorageAttributeName + "." + CurrentColumn.Name);
		ItemDescription.Insert("ItemParent", Items.ValueTable);

		ItemDescription.Actions.Insert("OnChange", "Подключаемый_ПолеТаблицыЗначенийПриИзменении");
		ItemDescription.Actions.Insert("StartChoice", "Подключаемый_ПолеТаблицыЗначенийНачалоВыбора");
		ItemDescription.Actions.Insert("Clearing", "Подключаемый_ПолеТаблицыЗначенийОчистка");

		NewItem = UT_Forms.CreateItemByDescription(ThisObject, ItemDescription);
		NewItem.ChooseType = False;
		NewItem.ChoiceFoldersAndItems = FoldersAndItems.FoldersAndItems;
		NewItem.TypeRestriction = CurrentColumn.ValueType;
		NewItem.ChoiceButton = True;
		NewItem.ClearButton = True;

	EndDo;

	For Each CurrentColumn In ColumnsForCastingTypes Do
		ColumnsStorageStructure = FieldColumnStructuresStoringValues[CurrentColumn.Name];
		For Each  ValueTableRow In ThisObject[StorageAttributeName] Do
			FieldValue = UT_CommonClientServer.ValueContainerFieldValue(ValueTableRow,
				ColumnsStorageStructure);
			NewFieldValue = CurrentColumn.ValueType.AdjustValue(FieldValue);

			If FieldValue <> NewFieldValue Or TypeOf(FieldValue) <> TypeOf(NewFieldValue) Then
				UT_CommonClientServer.SetContainerFieldValue(ValueTableRow,
					ColumnsStorageStructure,
					NewFieldValue);
			EndIf;
		EndDo;
	EndDo;
EndProcedure


&AtServer
Procedure FillFormValueTableByTable(ValueTable)
	ValueTable = ThisObject[StorageAttributeName];
	ValueTable.Clear();

	ColumnsTableStorageStructuresOnForm = New Structure;

	For Each ColumnRow In TableColumns Do
		ColumnsTableStorageStructuresOnForm.Insert(ColumnRow.Name,
			TableColumnStorageStructureOnForm(ColumnRow.Name));
	EndDo;

	For Each Row In ValueTable Do
		NewRow = ValueTable.Add();

		For Each ColumnRow In TableColumns Do
			UT_CommonClientServer.SetContainerFieldValue(NewRow,
				ColumnsTableStorageStructuresOnForm[ColumnRow.Name],
				Row[ColumnRow.Name]);
		EndDo;
		
		//FillPropertyValues(NewRow, Row);
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Function GetTypeModifiers(ValueType)

	QualifiersArray = New Array;

	If ValueType.ContainsType(Type("String")) Then
		StrStringQualifiers = "Length " + ValueType.StringQualifiers.Length;
		QualifiersArray.Add(New Structure("Type, Qualifiers", "String", StrStringQualifiers));
	EndIf;

	If ValueType.ContainsType(Type("Date")) Then
		StrDateQualifiers = ValueType.DateQualifiers.DateFractions;
		QualifiersArray.Add(New Structure("Type, Qualifiers", "Date", StrDateQualifiers));
	EndIf;

	If ValueType.ContainsType(Type("Number")) Then
		StrDateQualifiers = "Sign " + ValueType.NumberQualifiers.AllowedSign + " "
			+ ValueType.NumberQualifiers.Digits + "." + ValueType.NumberQualifiers.FractionDigits;
		QualifiersArray.Add(New Structure("Type, Qualifiers", "Number", StrDateQualifiers));
	EndIf;

	NeedTitle = QualifiersArray.Count() > 1;

	StrQualifiers = "";
	For Each stQualifiers In QualifiersArray Do
		StrQualifiers = ?(NeedTitle, stQualifiers.Type + ": ", "") + stQualifiers.Qualifiers + "; ";
	EndDo;

	Return StrQualifiers;

EndFunction

&AtClient
Procedure TableColumnsValueTypeStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	CurrentData = TableColumns.FindByID(AdditionalParameters.CurrentRow);
	CurrentData.ValueType = Result;
	CurrentData.Qualifiers = GetTypeModifiers(CurrentData.ValueType);

EndProcedure

&AtServer
Function ResultValueTreeInStorage()
	ResultTree = New ValueTree();

	StructureStorageStructuresFieldsByNames = New Structure;

	For Each  CurrentRowColumns In TableColumns Do
		ResultTree.Columns.Add(CurrentRowColumns.Name, CurrentRowColumns.ValueType);

		StructureStorageStructuresFieldsByNames.Insert(CurrentRowColumns.Name,
			TableColumnStorageStructureOnForm(CurrentRowColumns.Name));
	EndDo;

	ReadRowTreeFormInTreeResult(ThisObject[StorageAttributeName],
												ResultTree,
												StructureStorageStructuresFieldsByNames);
												
	If ReturningStorageForValueContainer Then
		Return UT_Common.ValueStorageContainerValueTree(ResultTree);	
	Else

		ResultStructure = New Structure;
		If SerializeToXML Then
			ResultStructure.Insert("Value", UT_Common.ValueToXMLString(ResultTree));
		Else
			ResultStructure.Insert("Value", ValueToStringInternal(ResultTree));
		EndIf;
		ResultStructure.Insert("Presentation", StrTemplate(NStr("ru = 'Строк: %1 Колонок: %2'; en = 'Rows: %1 Columns: %2'"),
			ResultTree.Rows.Count(),
			ResultTree.Columns.Count()));
		ResultStructure.Insert("RowsCount", ResultTree.Rows.Count());
		ResultStructure.Insert("ColumnsCount", ResultTree.Columns.Count());
		Return ResultStructure;
	EndIf;
	
EndFunction

// Read form tree row into result tree.
// 
// Parameters:
//  RowTreeForm - FormDataTree, FormDataTreeItem - Form tree row
//  ResultTreeRow - ValueTree, ValueTreeRow -  Result tree row
//  StructureStorageStructuresFieldsByNames - Structure -  Structure of field storage structures by name
&AtServer
Procedure ReadRowTreeFormInTreeResult(RowTreeForm, ResultTreeRow,
	StructureStorageStructuresFieldsByNames)

	For Each RowTableForm In RowTreeForm.GetItems() Do
		NewRow = ResultTreeRow.Rows.Add();

		For Each CurrentRowColumns In TableColumns Do
			NewRow[CurrentRowColumns.Name] = UT_CommonClientServer.ValueContainerFieldValue(RowTableForm,
				StructureStorageStructuresFieldsByNames[CurrentRowColumns.Name]);
		EndDo;

		ReadRowTreeFormInTreeResult(RowTableForm,
									NewRow,
									StructureStorageStructuresFieldsByNames);
	EndDo;

EndProcedure

&AtServer
Function ResultValueTableToString()
	ValueTable = New ValueTable;

	StructureStorageStructuresFieldsByNames = New Structure;

	For Each ColumnCurrentRow In TableColumns Do
		ValueTable.Columns.Add(ColumnCurrentRow.Name, ColumnCurrentRow.ValueType);

		StructureStorageStructuresFieldsByNames.Insert(ColumnCurrentRow.Name,
			TableColumnStorageStructureOnForm(ColumnCurrentRow.Name));
	EndDo;

	For Each RowTableForm In ThisObject[StorageAttributeName] Do
		NewRow = ValueTable.Add();

		For Each  ColumnCurrentRow In TableColumns Do
			NewRow[ColumnCurrentRow.Name] = UT_CommonClientServer.ValueContainerFieldValue(RowTableForm,
				StructureStorageStructuresFieldsByNames[ColumnCurrentRow.Name]);
		EndDo;
	EndDo;
		
	If ReturningStorageForValueContainer Then
		Return UT_Common.ValueStorageContainerValueTable(ValueTable);	
	Else
		
		ResultStructure=New Structure;
		If SerializeToXML Then
			ResultStructure.Insert("Value", UT_Common.ValueToXMLString(ValueTable));
		Else
			ResultStructure.Insert("Value", ValueToStringInternal(ValueTable));
		EndIf;
		ResultStructure.Insert("Presentation", StrTemplate(NSTR("ru = 'Строк: %1 Колонок: %2';en = 'Rows: %1 Columns: %2'"), 
			ValueTable.Count(), 
			ValueTable.Columns.Count()));
		ResultStructure.Insert("RowCount", ValueTable.Count());
		ResultStructure.Insert("ColumnsCount", ValueTable.Columns.Count());
		Return ResultStructure;
	EndIf;
EndFunction

&AtServer
Function TableColumnStorageStructureOnForm(ColumnName)
	StorageStructure = UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer(ColumnName);
	StorageStructure.ContainerFieldName = AdditionalTableColumnName(ColumnName,
		UT_CommonClientServer.SuffixContainerStorageFieldName());
	StorageStructure.ValueTypeFieldName = AdditionalTableColumnName(ColumnName,
		UT_CommonClientServer.SuffixValueTypeStorageFieldName());
	StorageStructure.ValueTypePresentationFieldName = AdditionalTableColumnName(ColumnName,
		UT_CommonClientServer.SuffixPresentationStorageFieldName());
	
	Return StorageStructure;
EndFunction

// Fill the form tree level according to the source tree.
// 
// Parameters:
//  FormTreeRow - FormDataTree, FormDataTreeItem - Row rom tree
//  SourceTreeRow - ValueTree, СтрокаДереваЗначений - Row source tree
//  ColumnsTableStorageStructuresOnForm - Structure
&AtServer
Procedure FillLevelFormTreeBySourceTree(FormTreeRow, SourceTreeRow,
	ColumnsTableStorageStructuresOnForm)

	FormTreeItems = FormTreeRow.GetItems();

	For Each Row In SourceTreeRow.Rows Do
		НС = FormTreeItems.Add();

		For Each  ColumnRow In TableColumns Do
			UT_CommonClientServer.SetContainerFieldValue(НС,
				ColumnsTableStorageStructuresOnForm[ColumnRow.Name],
				Row[ColumnRow.Name]);
		EndDo;

		FillLevelFormTreeBySourceTree(НС, Row, ColumnsTableStorageStructuresOnForm);
	EndDo;
EndProcedure

&AtServer
Procedure FillFormTreeValuesByTree(SourceTree)
	ValueTree = ThisObject[StorageAttributeName]; // DataShapesTree
	ValueTree.GetItems().Clear();

	ColumnsTableStorageStructuresOnForm = New Structure;

	For Each ColumnRow In TableColumns Do
		ColumnsTableStorageStructuresOnForm.Insert(ColumnRow.Name,
			TableColumnStorageStructureOnForm(ColumnRow.Name));
	EndDo;

	FillLevelFormTreeBySourceTree(ValueTree, SourceTree, ColumnsTableStorageStructuresOnForm);

EndProcedure

&AtServer
Procedure AddRootItemAndAttributeTables()
	StorageAttributeName = "ValueTable";
	AttributesAddedArray = New Array;
	
	If IsTree Then
		AttributeType = New TypeDescription("ValueTree");
	Else
		AttributeType = New TypeDescription("ValueTable");
	EndIf;
	
	AttributesAddedArray.Add(New FormAttribute(StorageAttributeName, AttributeType, "", "", True));
	ChangeAttributes(AttributesAddedArray);

	ItemDescription = UT_Forms.ItemAttributeNewDescription();
	ItemDescription.Insert("Name", StorageAttributeName);
	ItemDescription.Insert("DataPath", StorageAttributeName);
	ItemDescription.Properties.FieldType = Type("FormTable");
	ItemDescription.Properties.Insert("TitleLocation", FormItemTitleLocation.None);
	If IsTree Then
		ItemDescription.Properties.Insert("Representation", TableRepresentation.Tree);
	EndIf;

	NewItem = UT_Forms.CreateItemByDescription(ThisObject, ItemDescription);
EndProcedure

#EndRegion