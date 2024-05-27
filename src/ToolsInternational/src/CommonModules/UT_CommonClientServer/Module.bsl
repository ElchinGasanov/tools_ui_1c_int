
#Region Public

#Region ScheduledJobs

// Converts  JobSchedule to Structure.
//
// Parameters:
//  Schedule - JobSchedule - original schedule.
// 
// Returns:
//  Structure - schedule as structure.
//
Function ScheduleToStructure (Val Schedule) Export

	ScheduleValue = Schedule;
	If ScheduleValue = Undefined Then
		ScheduleValue = New JobSchedule;
	EndIf;
	KeysList = "CompletionTime,EndTime,BeginTime,EndDate,BeginDate,DayInMonth,WeekDayInMonth,"
		+ "WeekDays,CompletionInterval,Months,RepeatPause,WeeksPeriod,RepeatPeriodInDay,DaysRepeatPeriod";
	Result = New Structure(KeysList);
	FillPropertyValues(Result, ScheduleValue, KeysList);
	DetailedDailySchedules = New Array;
	For Each DailySchedule In Schedule.DetailedDailySchedules Do
		DetailedDailySchedules.Add(ScheduleToStructure(DailySchedule));
	EndDo;
	Result.Вставить("DetailedDailySchedules", DetailedDailySchedules);
	Return Result;

EndFunction

// Converts  Structure to JobSchedule  .
// 
// Parameters:
//  ScheduleStructure - Structure - Schedule in Structure form.
// 
// Returns:
//  JobSchedule - Schedule.
//
Function StructureToSchedule(Val ScheduleStructure) Export

	If ScheduleStructure = UNdefined Then
		Return New JobSchedule;
	EndIf;
	KeysList = "CompletionTime,EndTime,BeginTime,EndDate,BeginDate,DayInMonth,WeekDayInMonth,"
		+ "WeekDays,CompletionInterval,Months,RepeatPause,WeeksPeriod,RepeatPeriodInDay,DaysRepeatPeriod";
	Result = New JobSchedule;
	FillPropertyValues(Result, ScheduleStructure, KeysList);
	DetailedDailySchedules = New Array;
	For Each Schedule In ScheduleStructure.DetailedDailySchedules Do
		DetailedDailySchedules.Add(StructureToSchedule(Schedule));
	EndDo;
	Result.DetailedDailySchedules = DetailedDailySchedules;
	Return Result;

EndFunction


#EndRegion

#Region UniversalCollections

// Supplements the ArrayReceiver array with values from the ArraySource array.
//
// Parameters:
// 	ArrayReceiver - Array of Arbitrary - the array to add values to.
// 	ArraySource - Array of Arbitrary - array of values to fill.
// 	OnlyUniqueValues - Boolean - if true, only unique values will be included in the array.
//
Procedure SupplementArray(ArrayReceiver, ArraySource, OnlyUniqueValues = False) Export

	If OnlyUniqueValues Then

		UniqueValues = New Map;

		For Each Value In ArrayReceiver Do
			UniqueValues.Insert(Value, True);
		EndDo;

		For Each Value In ArraySource Do
			If UniqueValues[Value] = Undefined Then
				ArrayReceiver.Add(Value);
				UniqueValues.Insert(Value, True);
			EndIf;
		EndDo;

	Else

		For Each Value In ArraySource Do
			ArrayReceiver.Add(Value);
		EndDo;

	EndIf;

EndProcedure

// Returns the structure property value.
//
// Parameters:
//   Structure - Structure, FixedStructure - an object to read key value from.
//   Key - String - the structure property whose value to read.
//   DefaultValue - Arbitrary - Optional. Returned when the structure contains no value for the 
//                                        given key.
//       To keep the system performance, it is recommended to pass only easy-to-calculate values 
//       (for example, primitive types). Pass performance-demanding values only after ensuring that 
//       the value is required.
//
// Returns:
//   Arbitrary - the property value. If the structure missing the property, returns DefaultValue.
//
Function StructureProperty(Structure, Key, DefaultValue = Undefined) Export
	
	If Structure = Undefined Then
		Return DefaultValue;
	EndIf;
	
	Result = DefaultValue;
	If Structure.Property(Key, Result) Then
		Return Result;
	Else
		Return DefaultValue;
	EndIf;
	
EndFunction

// Create copy of value type of Structure, Recursively, according of types of properties. 
// If  structure properties contains values of object types  (catalogref, DocumentRef,etc),
//  their contents are not copied, but references to the source object are returned..
//
// Parameters:
//  SourceStructure - Structure - copied Structure.
// 
// Returns:
//  Structure - copy of the original structure.
//
Function CopyStructure(SourceStructure) Export

	ResultStructure = New Structure;

	For Each  KeyAndValue Из SourceStructure Do
		ResultStructure.Insert(KeyAndValue.Key, CopyRecursively(KeyAndValue.Vakue));
	EndDo;

	Return ResultStructure;

EndFunction

// Supplement structure values from secound srtucture.
//
// Parameters:
//   Receiver - Structure - Collection,to which new values will be added..
//   Source - Structure - Collection, which be used for reading Key and Value for fili
//   Replace - Boolean, Undefined - what action choose when parts of Source and Receiver are equal
//   							True  - replace values of receiver (the fastest method)
//   							False - NOT replace value of receiver (skip)
//   							Undefined - (default setting) - raise exception 
//   
Procedure SupplementStructure(Receiver, Source, Replace = Undefined) Export

	For each  Element in Source do
		if Replace <> True and Receiver.Property(Element.Key) then
			if Replace = False then
				Continue;
			else
				Raise StrTemplate(Nstr("ru = 'Пересечение ключей источника и приемника: ""%1"".'; en='Intersection of source and receiver keys: ""%1"".'"),
					Element.Key);
			Endif;
		EndIf;
		Receiver.Insert(Element.Key, Element.Value);
	EndDo;

EndProcedure

// Create full copy of structure, map, array, list or value table, Recursively, 
//  taking into account the types of child elements. Object types values 
//  (CatalogObject,DocumentObject, etc) not copied and returns links to the source object.
//
// Parameters:
//  Source - Structure, Map, Array, ValueList, ValueTable - object that you want  
//  to copy.
//
// Returns:
//  Structure, Map, Array, ValueList, ValueTable- copy of the object passed as a parameter to the Source..
//
//@skip-check doc-comment-collection-item-type
Function CopyRecursively(Source) Export

	Var Receiver;
	
	SourceType = TypeOf(Source);

#If AtServer Or ThickClientOrdinaryApplication Or ExternalConnection Then
	If SourceType = Type("ValueTable") Then
		Return Source.Copy();
	EndIf;
#EndIf
	If SourceType = Type("Structure") Then
		Receiver = CopyStructure(Source);
	Elsif SourceType = Type("Map") Then
		Receiver = CopyMap(Source);
	Elsif SourceType = Type("Array") Тогда
		Receiver = CopyArray(Source);
	Elsif SourceType = Type("ValueList") Then
		Receiver = CopyValueList(Source);
	Else
		Receiver = Source;
	EndIf;

	//@skip-check constructor-function-return-section
	Return Receiver;

EndFunction

// Creates a copy of value type of  Map, recursively, based on the types of values.
// If elements of Map contains object  types values (CatalogObject,DocumentObject, etc).
//  their contents are not copied, and returns a reference to the original object.
//
// Parameters:
//  SourceMap - Map - map, that need to be copied.
// 
// Returns:
//  Map - copy of Source Map.
//
//@skip-check doc-comment-collection-item-type
Function CopyMap(SourceMap) Export

	ResultMap = New Map;

	For Each KeyAndValue in SourceMap Do
		ResultMap.Insert(KeyAndValue.Key, CopyRecursively(KeyAndValue.Value));
	EndDo;

	Return ResultMap;

EndFunction

// Creates a copy of value type of  Array, recursively, based on the types of values.
// If elements of Array contains object  types values (CatalogObject,DocumentObject, etc).
//  their contents are not copied, and returns a reference to the original object.
//  
// Parameters:
//  SourceArray - Array - array, that need to be copied.
// 
// Returns:
//  Array - copy of source array.
//
//@skip-check doc-comment-collection-item-type
Function CopyArray(SourceArray) Export

	ResultArray = New Array;

	For Each  Item In SourceArray Do
		ResultArray.Add(CopyRecursively(Item));
	EndDo;

	Return ResultArray;

EndFunction

// Creates a copy of value type of  ValueList, recursively, based on the types of values.
// If elements of ValueList contains object  types values (CatalogObject,DocumentObject, etc).
//  their contents are not copied, and returns a reference to the original object.
//
// Parameters:
//  SourceValueList - ValueList - ValueList that need to be copied.
// 
// Returns:
//  ValueList - copy of source ValueList.
//
//@skip-check doc-comment-collection-item-type
Function CopyValueList(SourceValueList) Export

	ValueListResult = New ValueList;

	For each  ListItem In SourceValueList Do
		ValueListResult.Add(CopyRecursively(ListItem.Value), ListItem.Presentation,
			ListItem.Check, ListItem.Picture);
	EndDo;

	Return ValueListResult;

EndFunction



#EndRegion

#Region ContextExecution

// This is the server context.
// 
// Returns:
// 	Boolean - This is the server context
Function ThisIsServerContext() Export

	#If AtServer Then
		Return True;
	#Else
		Return False;
	#EndIf
EndFunction

// This is a web client.
// 
// Returns:
// 	Boolean - This is a web client
Function IsWebClient() Export
	#If WebClient Then
	Return True;
	#Else 
	Return False;
	#EndIf
EndFunction

// This is windows.
// 
// Returns:
// 	Boolean - This is windows
Function IsWindows() Export
	SystemInformation = New SystemInfo;
	Return SystemInformation.PlatformType = PlatformType.Windows_x86 OR SystemInformation.PlatformType
		= PlatformType.Windows_x86_64;
EndFunction

// This is linux.
// 
// Returns:
// 	Boolean - This is linux
Function IsLinux() Export
	SystemInformation = New SystemInfo;
	Return SystemInformation.PlatformType = PlatformType.Linux_x86 OR SystemInformation.PlatformType
		= PlatformType.Linux_x86_64;
EndFunction

// This is mac os.
// 
// Returns:
// 	Boolean - This is mac os
Function IsMacOs() Export
	SystemInformation = New SystemInfo;
	Return SystemInformation.PlatformType = PlatformType.MacOS_x86 OR SystemInformation.PlatformType
		= PlatformType.MacOS_x86_64;
EndFunction

// This is x86 bitness.
// 
// Returns:
// 	Boolean - This is the x86 bitness
Function IsTheX86Bitness() Export
	SystemInformation = New SystemInfo;
	Return SystemInformation.PlatformType = PlatformType.MacOS_x86
			Or SystemInformation.PlatformType = PlatformType.Linux_x86
			Or SystemInformation.PlatformType = PlatformType.Windows_x86;
EndFunction

// This is x64 bitness.
// 
// Returns:
// 	Boolean - This is the x64 bitness
Function IsTheX64Bitness() Export
	SystemInformation = New SystemInfo;
	Return SystemInformation.PlatformType = PlatformType.MacOS_x86_64
			Or SystemInformation.PlatformType = PlatformType.Linux_x86_64
			Or SystemInformation.PlatformType = PlatformType.Windows_x86_64;
EndFunction

// Field HTMLBuilt on webkit.
// 
// Returns:
// 	Boolean - field HTMLBuilt on webkit
Function HTMLFieldBasedOnWebkit() Export
	Return PlatformVersionNotLess_8_3_14() OR IsLinux()
EndFunction

#EndRegion

#Region Variables

// The variable name is correct.
// 
// Parameters:
// 	Name - String -Name
// 
// Returns:
// 	Boolean -VariableName is correct
Function IsCorrectVariableName(Name) Export
	If Not ValueIsFilled(Name) Then
		Return False;
	EndIf;
	IsCorrectName = False;
	//@skip-check empty-except-statement
	Try
		//@skip-check module-unused-local-variable
		StructureTest = New Structure(Name);
		IsCorrectName=True;
	Except
	EndTry;
	
	Return IsCorrectName;
EndFunction

// Warning text about incorrect variable name.
// 
// Returns:
// 	String - Warning text about the incorrect variable name
Function WrongVariableNameWarningText() Export
	Return NStr("ru = 'Неверное имя колонки! Имя должно состоять из одного слова, начинаться с буквы и не содержать специальных символов кроме """"_"""".""';en = 'en=''Invalid column name! The name must consist of a single word, start with a letter and contain no special characters other than """"_"""".""'");
EndFunction

#EndRegion

#Region DynamicList

////////////////////////////////////////////////////////////////////////////////
// Functions for works with dynamic list filters and parameters.
//

// Searches for the item and the group of the dynamic list filter by the passed field name or presentation.
//
// Parameters:
//  SearchArea - DataCompositionFilter, DataCompositionFilterItemCollection, DataCompositionFilterItemGroup - 
//  				a container of items and filter groups.
//  				For example, List.Filter or a group in a filer.
//  FieldName - String - a composition field name. Not applicable to groups.
//  Presentation - String - the composition field presentation.
//
// Returns:
//  Array of DataCompositionFilter, DataCompositionFilterItemGroup - a collection of filters.
//
Function FindFilterItemsAndGroups(Val SearchArea, Val FieldName = Undefined, Val Presentation = Undefined) Export
	
	If ValueIsFilled(FieldName) Then
		SearchValue = New DataCompositionField(FieldName);
		SearchMethod = 1;
	Else
		SearchMethod = 2;
		SearchValue = Presentation;
	EndIf;
	
	ItemArray = New Array;

	FindRecursively(SearchArea.Items, ItemArray, SearchMethod, SearchValue);

	Return ItemArray;

EndFunction

// Adds filter groups to ItemCollection.
//
// Parameters:
//  ItemCollection - DataCompositionFilter, DataCompositionFilterItemCollection, DataCompositionFilterItemGroup - 
//  				 a container of items and filter groups. 
//                   For example, List.Filter or a group in a filer.
//  Presentation - String - the group presentation.
//  GroupType - DataCompositionFilterItemsGroupType - the group type.
//
// Returns:
//  DataCompositionFilterItemGroup - a filter group.
//
Function CreateFilterItemGroup(Val ItemCollection, Presentation, GroupType) Export
	
	If TypeOf(ItemCollection) = Type("DataCompositionFilterItemGroup") Then
		ItemCollection = ItemCollection.Items;
	EndIf;
	
	FilterItemsGroup = FindFilterItemByPresentation(ItemCollection, Presentation);
	If FilterItemsGroup = Undefined Then
		FilterItemsGroup = ItemCollection.Add(Type("DataCompositionFilterItemGroup"));
	Else
		FilterItemsGroup.Items.Clear();
	EndIf;
	
	FilterItemsGroup.Presentation = Presentation;
	FilterItemsGroup.Application = DataCompositionFilterApplicationType.Items;
	FilterItemsGroup.ViewMode = DataCompositionSettingsItemViewMode.Inaccessible;
	FilterItemsGroup.GroupType = GroupType;
	FilterItemsGroup.Use = True;
	
	Return FilterItemsGroup;
	
EndFunction

// Adds a composition item into a composition item container.
//
// Parameters:
//  AreaToAddTo - DataCompositionFilterItemCollection - a container with items and filter groups. 
//                                                      For example, List.Filter or a group in a filter.
//  FieldName - String - a data composition field name. Required.
//  ComparisonType - DataCompositionComparisonType - a comparison type.
//  RightValue - Arbitrary - the value to compare to.
//  Presentation - String - presentation of the data composition item.
//  Usage - Boolean - the flag that indicates whether the item is used.
//  DisplayMode - DataCompositionSettingsItemViewMode - the item display mode.
//  UserSettingID - String - see DataCompositionFilter_UserSettingID in Syntax Assistant. 
//                                                    
// Returns:
//  DataCompositionFilterItem - a composition item.
//@skip-check method-too-many-params
Function AddCompositionItem(AreaToAddTo, Val FieldName,	Val ComparisonType, Val RightValue = Undefined,
	Val Presentation  = Undefined, Val Usage  = Undefined, Val DisplayMode = Undefined,
	Val UserSettingID = Undefined) Export
	
	Item = AreaToAddTo.Items.Add(Type("DataCompositionFilterItem"));
	Item.LeftValue = New DataCompositionField(FieldName);
	Item.ComparisonType = ComparisonType;
	
	If DisplayMode = Undefined Then
		Item.ViewMode = DataCompositionSettingsItemViewMode.Inaccessible;
	Else
		Item.ViewMode = DisplayMode;
	EndIf;
	
	If RightValue <> Undefined Then
		Item.RightValue = RightValue;
	EndIf;
	
	If Presentation <> Undefined Then
		Item.Presentation = Presentation;
	EndIf;
	
	If Usage <> Undefined Then
		Item.Use = Usage;
	EndIf;
	
	// Important: The ID must be set up in the final stage of the item customization or it will be 
	// copied to the user settings in a half-filled condition.
	// 
	If UserSettingID <> Undefined Then
		Item.UserSettingID = UserSettingID;
	ElsIf Item.ViewMode <> DataCompositionSettingsItemViewMode.Inaccessible Then
		Item.UserSettingID = FieldName;
	EndIf;
	
	Return Item;
	
EndFunction

// Changes the filter item with the specified field name or presentation.
//
// Parameters:
//  SearchArea - DataCompositionFilterItemCollection - a container with items and filter groups, for 
//                                                     example, List.Filter or a group in the filter.
//  FieldName - String - a data composition field name. Required.
//  Presentation - String - presentation of the data composition item.
//  RightValue - Arbitrary - the value to compare to.
//  ComparisonType - DataCompositionComparisonType - a comparison type.
//  Usage - Boolean - the flag that indicates whether the item is used.
//  DisplayMode - DataCompositionSettingsItemViewMode - the item display mode.
//  UserSettingID - String - see DataCompositionFilter_UserSettingID in Syntax Assistant. 
//                                                    
// Returns:
//  Number - the changed item count.
//
//@skip-check method-too-many-params
Function ChangeFilterItems(SearchArea, Val FieldName = Undefined, Val Presentation = Undefined, 
	Val RightValue = Undefined,	Val ComparisonType = Undefined,	Val Usage = Undefined,
	Val DisplayMode = Undefined, Val UserSettingID = Undefined) Export
	
	If ValueIsFilled(FieldName) Then
		SearchValue = New DataCompositionField(FieldName);
		SearchMethod = 1;
	Else
		SearchMethod = 2;
		SearchValue = Presentation;
	EndIf;
	
	ItemArray = New Array;
	
	FindRecursively(SearchArea.Items, ItemArray, SearchMethod, SearchValue);
	
	For Each Item In ItemArray Do
		If FieldName <> Undefined Then
			Item.LeftValue = New DataCompositionField(FieldName);
		EndIf;
		If Presentation <> Undefined Then
			Item.Presentation = Presentation;
		EndIf;
		If Usage <> Undefined Then
			Item.Use = Usage;
		EndIf;
		If ComparisonType <> Undefined Then
			Item.ComparisonType = ComparisonType;
		EndIf;
		If RightValue <> Undefined Then
			Item.RightValue = RightValue;
		EndIf;
		If DisplayMode <> Undefined Then
			Item.ViewMode = DisplayMode;
		EndIf;
		If UserSettingID <> Undefined Then
			Item.UserSettingID = UserSettingID;
		EndIf;
	EndDo;
	
	Return ItemArray.Count();
	
EndFunction

// Delete filter items that contain the given field name or presentation.
//
// Parameters:
//  AreaToDelete - DataCompositionFilterItemCollection - a container of items or filter groups. For 
//                                                       example, List.Filter or a group in the filter.
//  FieldName - String - the composition field name. Not applicable to groups.
//  Presentation - String - the composition field presentation.
//
Procedure DeleteFilterItems(Val AreaToDelete, Val FieldName = Undefined, 
	Val Presentation = Undefined) Export
	
	If ValueIsFilled(FieldName) Then
		SearchValue = New DataCompositionField(FieldName);
		SearchMethod = 1;
	Else
		SearchMethod = 2;
		SearchValue = Presentation;
	EndIf;
	
	ItemArray = New Array;
	
	FindRecursively(AreaToDelete.Items, ItemArray, SearchMethod, SearchValue);
	
	For Each Item In ItemArray Do
		If Item.Parent = Undefined Then
			AreaToDelete.Items.Delete(Item);
		Else
			Item.Parent.Items.Delete(Item);
		EndIf;
	EndDo;
	
EndProcedure

// Adds or replaces the existing filter item.
//
// Parameters:
//  WhereToAdd - DataCompositionFilterItemCollection - a container with items and filter groups, for 
//                                     				   example, List.Filter or a group in the filter.
//  FieldName - String - a data composition field name. Required.
//  RightValue - Arbitrary - the value to compare to.
//  ComparisonType - DataCompositionComparisonType - a comparison type.
//  Presentation - String - presentation of the data composition item.
//  Usage - Boolean - the flag that indicates whether the item is used.
//  DisplayMode - DataCompositionSettingsItemViewMode - the item display mode.
//  UserSettingID - String - see DataCompositionFilter_UserSettingID in Syntax Assistant. 
//                                                    
//@skip-check method-too-many-params
Procedure SetFilterItem(WhereToAdd,	Val FieldName, Val RightValue = Undefined,
	Val ComparisonType = Undefined,	Val Presentation = Undefined, Val Usage = Undefined,
	Val DisplayMode = Undefined, Val UserSettingID = Undefined) Export
	
	ModifiedCount = ChangeFilterItems(WhereToAdd, FieldName, Presentation,
							RightValue, ComparisonType, Usage, DisplayMode, UserSettingID);
	
	If ModifiedCount = 0 Then
		If ComparisonType = Undefined Then
			If TypeOf(RightValue) = Type("Array") Or TypeOf(RightValue) = Type("FixedArray")
				Or TypeOf(RightValue) = Type("ValueList") Then
				ComparisonType = DataCompositionComparisonType.InList;
			Else
				ComparisonType = DataCompositionComparisonType.Equal;
			EndIf;
		EndIf;
		If DisplayMode = Undefined Then
			DisplayMode = DataCompositionSettingsItemViewMode.Inaccessible;
		EndIf;
		AddCompositionItem(WhereToAdd, FieldName, ComparisonType,
								RightValue, Presentation, Usage, DisplayMode, UserSettingID);
	EndIf;
	
EndProcedure

// Adds or replaces a filter item of a dynamic list.
//
// Parameters:
//   DynamicList - DynamicList - the list to be filtered.
//   FieldName - String - the field the filter to apply to.
//   RightValue - Arbitrary - the filter value.
//       Optional. The default value is Undefined.
//       Warning! If Undefined is passed, the value will not be changed.
//   ComparisonType  - DataCompositionComparisonType - a filter condition.
//   Presentation - String - presentation of the data composition item.
//       Optional. The default value is Undefined.
//       If another value is specified, only the presentation flag is shown, not the value.
//       To show the value, pass an empty string.
//   Usage - Boolean - the flag that indicates whether to apply the filter.
//       Optional. The default value is Undefined.
//   DisplayMode - DataCompositionSettingsItemViewMode - the filter display mode.
//                                                                          
//       * DataCompositionSettingItemDisplayMode.QuickAccess - in the Quick Settings bar on top of the list.
//       * DataCompositionSettingItemDisplayMode.Normal - in the list settings (submenu More).
//       * DataCompositionSettingItemDisplayMode.Inaccessible - privent users from changing the filter.
//   UserSettingID - String - the filter UUID. Used to link user settings.
//
//@skip-check method-too-many-params
Procedure SetDynamicListFilterItem(DynamicList, FieldName,	RightValue = Undefined,
	ComparisonType = Undefined,	Presentation = Undefined, Usage = Undefined,
	DisplayMode = Undefined, UserSettingID = Undefined) Export
	
	If DisplayMode = Undefined Then
		DisplayMode = DataCompositionSettingsItemViewMode.Inaccessible;
	EndIf;
	
	If DisplayMode = DataCompositionSettingsItemViewMode.Inaccessible Then
		DynamicListFilter = DynamicList.SettingsComposer.FixedSettings.Filter;
	Else
		DynamicListFilter = DynamicList.SettingsComposer.Settings.Filter;
	EndIf;
	
	SetFilterItem(DynamicListFilter, FieldName, RightValue, ComparisonType, Presentation,
		Usage, DisplayMode, UserSettingID);
	
EndProcedure

// Delete a filter group item of a dynamic list.
//
// Parameters:
//  DynamicList - DynamicList - the form attribute whose filter is to be modified.
//  FieldName - String - the composition field name. Not applicable to groups.
//  Presentation - String - the composition field presentation.
//
Procedure DeleteDynamicListFilterGroupItems(DynamicList, FieldName = Undefined, 
	Presentation = Undefined) Export
	
	DeleteFilterItems(DynamicList.SettingsComposer.FixedSettings.Filter, FieldName,
		Presentation);
	
	DeleteFilterItems(DynamicList.SettingsComposer.Settings.Filter, FieldName, Presentation);
	
EndProcedure

// Sets or modifies the ParameterName parameter of the List dynamic list.
//
// Parameters:
//  List - DynamicList - the form attribute whose parameter is to be modified.
//  ParameterName - String - name of the dynamic list parameter.
//  Value - Arbitrary - new value of the parameter.
//  Usage - Boolean - flag indicating whether the parameter is used.
//
Procedure SetDynamicListParameter(List, ParameterName, Value, Usage = True) Export
	
	DataCompositionParameterValue = List.Parameters.FindParameterValue(
		New DataCompositionParameter(ParameterName));
	If DataCompositionParameterValue <> Undefined Then
		If Usage And DataCompositionParameterValue.Value <> Value Then
			DataCompositionParameterValue.Value = Value;
		EndIf;
		If DataCompositionParameterValue.Use <> Usage Then
			DataCompositionParameterValue.Use = Usage;
		EndIf;
	EndIf;
	
EndProcedure

Function SetDCSParemeterValue(SettingsComposer, ParameterName, ParameterValue,
	UseNotFilled = True) Export

	ParameterIsSet = False;

	DataCompositionParameter = New DataCompositionParameter(ParameterName);
	DataCompositionParameterValue = SettingsComposer.Settings.DataParameters.FindParameterValue(
		DataCompositionParameter);
	If DataCompositionParameterValue <> Undefined Then

		DataCompositionParameterValue.Value = ParameterValue;
		DataCompositionParameterValue.Use = ?(UseNotFilled, True, ValueIsFilled(
			DataCompositionParameterValue.Value));

		ParameterIsSet = True;

	EndIf;

	Return ParameterIsSet;

EndFunction

Procedure FindRecursively(ItemCollection, ItemArray, SearchMethod, SearchValue)
	
	For each FilterItem In ItemCollection Do
		
		If TypeOf(FilterItem) = Type("DataCompositionFilterItem") Then
			
			If SearchMethod = 1 Then
				If FilterItem.LeftValue = SearchValue Then
					ItemArray.Add(FilterItem);
				EndIf;
			ElsIf SearchMethod = 2 Then
				If FilterItem.Presentation = SearchValue Then
					ItemArray.Add(FilterItem);
				EndIf;
			EndIf;
		Else
			
			FindRecursively(FilterItem.Items, ItemArray, SearchMethod, SearchValue);
			
			If SearchMethod = 2 AND FilterItem.Presentation = SearchValue Then
				ItemArray.Add(FilterItem);
			EndIf;
			
		EndIf;
		
	EndDo;
	
EndProcedure

// Searches for a filter item in the collection by the specified presentation.
//
// Parameters:
//  ItemCollection - DataCompositionFilterItemCollection - container with filter groups and items, 
//                                                         such as List.Filter.Filter items or group.
//  Presentation - String - group presentation.
// 
// Returns:
//  DataCompositionFilterItem - filter item.
//
Function FindFilterItemByPresentation(ItemCollection, Presentation) Export
	
	ReturnValue = Undefined;
	
	For each FilterItem In ItemCollection Do
		If FilterItem.Presentation = Presentation Then
			ReturnValue = FilterItem;
			Break;
		EndIf;
	EndDo;
	
	Return ReturnValue
EndFunction

Procedure CopyItems(ValueReceiver, ValueSource, ClearReceiver = Истина) Export

	If  Typeof(ValueSource) = Type("DataCompositionConditionalAppearance") Or TypeOf(ValueSource) = Type(
		"DataCompositionUserFieldsCaseVariants") Or TypeOf(ValueSource) = Type(
		"DataCompositionAppearanceFields") Or TypeOf(ValueSource) = Type(
		"DataCompositionDataParameterValues") Then
		CreateByType = False;
	Else
		CreateByType = True;
	EndIf;
	ItemsReceiver = ValueReceiver.Items;
	ItemsSource = ValueSource.Items;
	If ClearReceiver then
		ItemsReceiver.Clear();
	EndIf;

	For Each SourceItem In ItemsSource Do

		Если TypeOf(SourceItem) = Type("DataCompositionOrderItem") Then
			// Order items add to begin 
			IndexOf = ItemsSource.IndexOf(SourceItem);
			ReceiverItem = ItemsReceiver.Insert(IndexOf, Typeof(SourceItem));
		Else
			If CreateByType Then
				ReceiverItem = ItemsReceiver.Add(Typeof(SourceItem));
			else
				//@skip-check not-enough-parameters
				ReceiverItem = ItemsReceiver.Add();
			EndIf;
		Endif;

		FillPropertyValues(ReceiverItem, SourceItem);
		// In some collections it's Necessary to fill another collections
		if typeof(ItemsSource) = Type("DataCompositionConditionalAppearanceItemCollection") Then
			CopyItems(ReceiverItem.Items, SourceItem.Items);
			CopyItems(ReceiverItem.Filter, SourceItem.Filter);
			FillItems(ReceiverItem.Appearance, SourceItem.Appearance);
		ElsIf TypeOf(ItemsSource) = Type("DataCompositionUserFieldCaseVariantCollection") Then
			CopyItems(ReceiverItem.Filter, SourceItem.Filter);
		EndIf;
		
		// In some collections it's Necessary to fill another collections
		If TypeOf(SourceItem) = Type("DataCompositionFilterItemGroup") Then
			CopyItems(ReceiverItem, SourceItem);
		ElsIf TypeOf(SourceItem) = Type("DataCompositionSelectedFieldGroup") Then
			CopyItems(ReceiverItem, SourceItem);
		ElsIf TypeOf(SourceItem) = Type("DataCompositionUserFieldCase") Then
			CopyItems(ReceiverItem.Variants, SourceItem.Variants);
		ElsIf TypeOf(SourceItem) = Type("DataCompositionUserFieldExpression") Then
			ReceiverItem.SetDetailRecordExpression (SourceItem.GetDetailRecordExpression());
			ReceiverItem.SetTotalRecordExpression(SourceItem.GetTotalRecordExpression());
			ReceiverItem.SetDetailRecordExpressionPresentation(
				SourceItem.GetDetailRecordExpressionPresentation ());
			ReceiverItem.SetTotalRecordExpressionPresentation(
				SourceItem.GetTotalRecordExpressionPresentation ());
		EndIf;
		
	EndDo;
	
EndProcedure
Procedure FillItems(ValueReceiver, ValueSource, FirstLevel = Неопределено) Export

	If TypeOf(ValueReceiver) = Type("DataCompositionParameterValueCollection") Then
		ValueCollection = ValueSource;
	Else
		ValueCollection = ValueSource.Items;
	EndIf;

	For Each SourceItem In ValueCollection Do
		If FirstLevel = Undefined Then
			ReceiverItem = ValueReceiver.FindParameterValue(SourceItem.Parameter);
		Else
			ReceiverItem = FirstLevel.FindParameterValue(SourceItem.Parameter);
		EndIf;
		If ReceiverItem = Undefined Then
			Continue;
		EndIf;
		FillPropertyValues(ReceiverItem, SourceItem);
		If TypeOf(SourceItem) = Type("DataCompositionParameterValue") Then
			If SourceItem.NestedParameterValues.Count() <> 0 Then
				FillItems(ReceiverItem.NestedParameterValues,
					SourceItem.NestedParameterValues, ValueReceiver);
			Endif;
		EndIf;
	EndDo;

EndProcedure


// Copy  Data Composition Settings
//
// Parameters:
//	ReceiverSettings - DataCompositionSettings, DataCompositionNestedObjectSettings,
//		DataCompositionGroup, DataCompositionTableGroup, DataCompositionChartGroup,
//		DataCompositionTable, DataCompositionChart - Data Composition settings collection to receive settings from Source
//	SourceSettings	- DataCompositionSettings, DataCompositionNestedObjectSettings,
//		DataCompositionGroup, DataCompositionTableGroup, DataCompositionChartGroup,
//		DataCompositionTable, DataCompositionChart 	- Data Composition settings collection, where are the settings copied from.
//
Procedure CopyDataCompositionSettings(ReceiverSettings, SourceSettings) Export
	
	If SourceSettings = Undefined Then
		Return;
	Endif;
	
	If TypeOf(ReceiverSettings) = Type("DataCompositionSettings") Then
		For each Parameter In SourceSettings.DataParameters.Items Do
			ParameterValue = ReceiverSettings.DataParameters.FindParameterValue(Parameter.Parameter);
			If ParameterValue <> Undefined Then
				FillPropertyValues(ParameterValue, Parameter);
			EndIf;
		EndDo;
	EndIf;
	
	If TypeOf(SourceSettings) = Type("DataCompositionNestedObjectSettings") Then
		FillPropertyValues(ReceiverSettings, SourceSettings);
		CopyDataCompositionSettings(ReceiverSettings.Settings, SourceSettings.Settings);
		Return;
	EndIf;
	
	// Copy of settings
	If TypeOf(SourceSettings) = Type("DataCompositionSettings") Then
		
		CopyItems(ReceiverSettings.DataParameters,	SourceSettings.DataParameters);
		CopyItems(ReceiverSettings.UserFields,		SourceSettings.UserFields);
		CopyItems(ReceiverSettings.Filter,			SourceSettings.Filter);
		CopyItems(ReceiverSettings.Order,			SourceSettings.Order);
		
	EndIf;
	
	If TypeOf(SourceSettings) = Type("DataCompositionGroup")
	 Or TypeOf(SourceSettings) = Type("DataCompositionTableGroup")
	 Or TypeOf(SourceSettings) = Type("DataCompositionChartGroup") Then
		
		CopyItems(ReceiverSettings.GroupFields,	SourceSettings.GroupFields);
		CopyItems(ReceiverSettings.Filter,		SourceSettings.Filter);
		CopyItems(ReceiverSettings.Order,		SourceSettings.Order);
		FillPropertyValues(ReceiverSettings,	SourceSettings);
		
	EndIf;
	
	CopyItems(ReceiverSettings.Selection,				SourceSettings.Selection);
	CopyItems(ReceiverSettings.ConditionalAppearance,	SourceSettings.ConditionalAppearance);
	FillItems(ReceiverSettings.OutputParameters,		SourceSettings.OutputParameters);
	
	// Copy of Structure
	If TypeOf(SourceSettings) = Type("DataCompositionSettings")
	 Or TypeOf(SourceSettings) = Type("DataCompositionGroup") Then
		
		For Each SourceStructureItem In SourceSettings.Structure Do
			ReceiverStructureItem = ReceiverSettings.Structure.Add(TypeOf(SourceStructureItem));
			CopyDataCompositionSettings(ReceiverStructureItem, SourceStructureItem);
		EndDo;
		
	EndIf;
	
	If TypeOf(SourceSettings) = Type("DataCompositionTableGroup")
	 Or TypeOf(SourceSettings) = Type("DataCompositionChartGroup") Then
		
		For Each SourceStructureItem In SourceSettings.Structure Do
			ReceiverStructureItem = ReceiverSettings.Structure.Add();
			CopyDataCompositionSettings(ReceiverStructureItem, SourceStructureItem);
		EndDo;
		
	Endif;
	
	If TypeOf(SourceSettings) = Type("DataCompositionTable") Then
		
		For Each SourceStructureItem In SourceSettings.Строки Do
			ReceiverStructureItem = ReceiverSettings.Строки.Add();
			CopyDataCompositionSettings(ReceiverStructureItem, SourceStructureItem);
		Enddo;
		
		For each  SourceStructureItem in SourceSettings.Columns Do
			ReceiverStructureItem = ReceiverSettings.Columns.Add();
			CopyDataCompositionSettings(ReceiverStructureItem, SourceStructureItem);
		EndDo;
		
	EndIf;
	
	If TypeOf(SourceSettings) = Type("DataCompositionChart") Then

		For each SourceStructureItem In SourceSettings.Series Do
			ReceiverStructureItem = ReceiverSettings.Series.Add();
			CopyDataCompositionSettings(ReceiverStructureItem, SourceStructureItem);
		EndDo;
		
		For each SourceStructureItem In SourceSettings.Points do
			ReceiverStructureItem = ReceiverSettings.Points.Add();
			CopyDataCompositionSettings(ReceiverStructureItem, SourceStructureItem);
		EndDo;
		
	EndIf;
	
EndProcedure



#EndRegion

#Region Debug

Function SerializeQueryForDebug(ObjectForDebugging)
	ObjectStructure  = New Structure;
	
  	ObjectStructure.Insert("Text", ObjectForDebugging.Text);
  	
	ObjectStructure.Insert("Parameters", CopyRecursively(ObjectForDebugging.Parameters));
	
	If ObjectForDebugging.TempTablesManager <> Undefined Then
		TempTablesStructure = UT_CommonServerCall.TempTablesManagerTempTablesStructure(
			ObjectForDebugging.TempTablesManager);
		ObjectStructure.Insert("TempTables", TempTablesStructure);
	EndIf;
	
	Return ObjectStructure;
EndFunction

Function SerializeTempTablesManagerForDebug(ObjectForDebugging)
	ObjectStructure  = New Structure;
	
  	ObjectStructure.Insert("Text", ObjectForDebugging.Text);
	ObjectStructure.Insert("Parameters", New Structure);
	TempTablesStructure = UT_CommonServerCall.TempTablesManagerTempTablesStructure(ObjectForDebugging);
	ObjectStructure.Insert("TempTables", TempTablesStructure);
		
	Return ObjectStructure;
EndFunction

Function SerializeDCSForDebug(DCS,DcsSettings,ExternalDataSets)
	Return UT_CommonServerCall.SerializeDCSForDebug(DCS, DcsSettings, ExternalDataSets);
EndFunction

Function SerializeDBObjectForDebug(ObjectForDebugging)
	ObjectStructure = New Structure;
	ObjectStructure.Insert("Object", ObjectForDebugging);
	
	Return ObjectStructure;
EndFunction

// Serialize HTTP request for debug.
// 
// Parameters:
// 	RequestHTTP - HTTPRequest - HTTP request
// 	ConnectionHTTP - HTTPConnection - HTTP connection
// 
// Returns:
// 	Structure - Serialize NTTRRequest for debugging:
// 	* Version - Number 
// 	* HostAddress - String 
// 	* Port - Number 
// 	* UseHTPPS - Boolean 
// 	* Protocol - String 
// 	* ConnectionUseOSAuthentication - Boolean, Undefined - 
// 	* ProxyServer - String 
// 	* ProxyPort - Number 
// 	* ProxyUser - String 
// 	* ProxyPassword - String 
// 	* UseOSAuthentication - Boolean 
// 	* Request - String 
// 	* RequestBody - String, Undefined -
// 	* Headers - String 
// 	* BodyBinaryData - BinaryData, Undefined -
// 	* BodyBinaryDataAsString - String 
// 	* RequestFileName - String, Undefined -
Function SerializeHTTPRequestForDebug(RequestHTTP, ConnectionHTTP)
	ObjectStructure = New Structure;
	ObjectStructure.Insert("Version", 1);
	ObjectStructure.Insert("HostAddress", ConnectionHTTP.Host);
	ObjectStructure.Insert("Port", ConnectionHTTP.Port);
	ObjectStructure.Insert("UseHTPPS", ConnectionHTTP.SecureConnection <> Undefined);
	If ConnectionHTTP.SecureConnection = Undefined Then
		ObjectStructure.Insert("Protocol", "http");
	Else
		ObjectStructure.Insert("Protocol", "https");
	EndIf;

	If PlatformVersionNotLess("8.3.7") Then
		ObjectStructure.Insert("ConnectionUseOSAuthentication", ConnectionHTTP.UseOSAuthentication);
	EndIf;

	ObjectStructure.Insert("ProxyServer", ConnectionHTTP.Proxy.Server(ObjectStructure.Protocol));
	ObjectStructure.Insert("ProxyPort", ConnectionHTTP.Proxy.Port(ObjectStructure.Protocol));
	ObjectStructure.Insert("ProxyUser", ConnectionHTTP.Proxy.User(ObjectStructure.Protocol));
	ObjectStructure.Insert("ProxyPassword", ConnectionHTTP.Proxy.Password(ObjectStructure.Protocol));
	ObjectStructure.Insert("UseOSAuthentication", ConnectionHTTP.Proxy.UseOSAuthentication(
		ObjectStructure.Protocol));

	ObjectStructure.Insert("Request", RequestHTTP.ResourceAddress);
	ObjectStructure.Insert("RequestBody", RequestHTTP.GetBodyAsString());
	ObjectStructure.Insert("Headers", GetHTTPHeadersString(
		RequestHTTP.Headers));

	BodyBinaryData = RequestHTTP.GetBodyAsBinaryData();
	ObjectStructure.Insert("BodyBinaryData", BodyBinaryData);
	ObjectStructure.Insert("BodyBinaryDataAsString", String(BodyBinaryData));

	ObjectStructure.Insert("RequestFileName", RequestHTTP.GetBodyFileName());

	Return ObjectStructure;

EndFunction

Function SerializeObjectForDebugToStructure(ObjectForDebugging, DcsSettingsOrHTTPConnection, ExternalDataSets)
	AllRefsType = UT_CommonCached.AllRefsTypeDescription();

	ObjectStructure = New Structure;
	If AllRefsType.ContainsType(TypeOf(ObjectForDebugging)) Then
		ObjectStructure = SerializeDBObjectForDebug(ObjectForDebugging);
	ElsIf TypeOf(ObjectForDebugging) = Type("HTTPRequest") Then
		ObjectStructure = SerializeHTTPRequestForDebug(ObjectForDebugging, DcsSettingsOrHTTPConnection);
	ElsIf TypeOf(ObjectForDebugging) = Type("Query") Then
		ObjectStructure = SerializeQueryForDebug(ObjectForDebugging);
	ElsIf TypeOf(ObjectForDebugging) = Type("DataCompositionSchema") Then
		ObjectStructure = SerializeDCSForDebug(ObjectForDebugging, DcsSettingsOrHTTPConnection, ExternalDataSets);
	ElsIf TypeOf(ObjectForDebugging) = Type("FormTable") Then
		If Not ThisIsServerContext() Then
			Return Undefined;
		EndIf;
		DCS = ObjectForDebugging.GetPerformingDataCompositionScheme();
		Settings = ObjectForDebugging.GetPerformingDataCompositionSettings();
		ObjectStructure = SerializeDCSForDebug(DCS, Settings, Undefined);
	ElsIf TypeOf(ObjectForDebugging) = Type("TempTablesManager") Then
		ObjectStructure = SerializeTempTablesManagerForDebug(ObjectForDebugging);
	EndIf;
	
	Return ObjectStructure;
EndFunction

// Object debugging.
// 
// Parameters:
// 	ObjectForDebugging - Query, DataCompositionSchema, HTTPRequest, AnyRef, FormTable - query type object
// 	DcsSettingsOrHTTPConnection - HTTPConnection, DataCompositionSettings - query type object
// 	ExternalDataSets - Structure:
// 		* Key - String
// 		* Key - String - ValueTable
// 	SaveFile - Boolean - Sign of saving debugging data to a file on the server, not to the database.	
// 	Name - String - Name of the saving debugging object
// 
// Returns:
// 	Undefined, String - Debug Object
Function DebugObject(ObjectForDebugging, DcsSettingsOrHTTPConnection = Undefined, 
	ExternalDataSets = Undefined, SaveFile = False, Name = "") Export
	ImmediatelyOpenConsole = False;
	
#If ThickClientOrdinaryApplication or ThickClientManagedApplication Then
	ImmediatelyOpenConsole = True;
#EndIf

	AllRefsType = UT_CommonCached.AllRefsTypeDescription();
	SerializeObject = SerializeObjectForDebugToStructure(ObjectForDebugging, DcsSettingsOrHTTPConnection, ExternalDataSets);
	If AllRefsType.ContainsType(TypeOf(ObjectForDebugging)) Then
		DebugObjectType = "DataBaseObject";
	ElsIf TypeOf(ObjectForDebugging) = Type("HTTPRequest") Then
		DebugObjectType = "HTTPRequest";
	ElsIf TypeOf(ObjectForDebugging) = Type("Query") Then
		DebugObjectType = "QUERY";
	ElsIf TypeOf(ObjectForDebugging) = Type("TempTablesManager") Then
		DebugObjectType = "TempTablesManager";
	ElsIf TypeOf(ObjectForDebugging) = Type("DataCompositionSchema") Then
		DebugObjectType = "DATACOMPOSITIONSCHEMA";
	ElsIf TypeOf(ObjectForDebugging) = Type("FormTable") Then
		DebugObjectType = "DATACOMPOSITIONSCHEMA";
	EndIf;

	If ImmediatelyOpenConsole Then
		DebuggingData = PutToTempStorage(SerializeObject);
#If Client Then
	
		UT_CommonClient.OpenDebuggingConsole(DebugObjectType, DebuggingData);

#EndIf
		Return Undefined;
	
	ElsIf SaveFile Then
		Return UT_CommonServerCall.SaveDebuggingDataToFile(DebugObjectType,
														   SerializeObject,
														   Name);
	Else
		Return UT_CommonServerCall.SaveDebuggingDataToCatalog(DebugObjectType,
															  SerializeObject,
															  Name);
	EndIf;
EndFunction

Function DebuggingDataObjectDataKeyInSettingsStorage() Export
	Return "UT_UniversalTools_DebuggingData";
EndFunction

Function ObjectKeyInSettingsStorage() Export
		Return "UT_UniversalTools";
EndFunction

#EndRegion

#Region HTTPRequests

Function HTTPRequestHeadersFromString(HeadersString) Export
	TextDocument = New TextDocument;
	TextDocument.SetText(HeadersString);

	Headers = New Map;

	For LineNumber = 1 to TextDocument.LineCount() Do
		HeaderString = TextDocument.GetLine(LineNumber);

		If Not ValueIsFilled(HeaderString) Then
			Continue;
		EndIf;

		HeaderArray = StrSplit(HeaderString, ":");
		If HeaderArray.Count() <> 2 Then
			Continue;
		EndIf;

		Headers.Insert(HeaderArray[0], HeaderArray[1]);

	EndDo;

	Return Headers;
EndFunction

Function GetHTTPHeadersString(Headers) Export
	HeadersString = "";

	For Each KeyValue In Headers Do
		HeadersString = HeadersString 
			+ ?(ValueIsFilled(HeadersString), Chars.LF, "") 
			+ KeyValue.Key
			+ ":" 
			+ KeyValue.Value;
	EndDo;

	Return HeadersString;
EndFunction

#EndRegion

#Region JSON

Function mReadJSON(Value, ReadToMap = False) Export
#If WebClient Then
	Return UT_CommonServerCall.mReadJSON(Value);
#Else
		JSONReader = New JSONReader;
		JSONReader.SetString(Value);

		JSONDocumentData =ReadJSON(JSONReader,ReadToMap);
		JSONReader.Close();

		Return JSONDocumentData;
#EndIf
EndFunction // ReadJSON()

Function mWriteJSON(DataStructure) Export
#If WebClient Then
	Return UT_CommonServerCall.mWriteJSON(DataStructure);
#Else
	
		JSONWriter = New JSONWriter;
		JSONWriter.SetString();
		WriteJSON(JSONWriter, DataStructure);
		SerializedString = JSONWriter.Close();
		Return SerializedString;
#EndIf

EndFunction // WriteJSON()

Function mReadJSONFromFile(FileName, FileEncoding = "UTF8") Export
#If Not WebClient Then
	JSONReader = New JSONReader;
	JSONReader.OpenFile(FileName, FileEncoding);

	JSONDocumentData = ReadJSON(JSONReader);
	JSONReader.Close();

	Return JSONDocumentData;
#EndIf

	Return Undefined;
EndFunction

Procedure mWriteJSONFile(FileName, DataStructure, FileEncoding = "UTF8") Export
#If Not WebClient Then
	JSONWriter = New JSONWriter;
	JSONWriter.OpenFile(FileName, FileEncoding);
	WriteJSON(JSONWriter, DataStructure);
	JSONWriter.Close();
#EndIf
EndProcedure

#EndRegion

#Region ProhibitedChars
// Returns a string of illegal file name characters.
// See the list of symbols on https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words.
// Returns:
//   String - of  Prohibited Chars
//
Function GetProhibitedCharsInFileName() Export

	InvalidChars = """/\[]:;|=?*<>";
	InvalidChars = InvalidChars + Chars.Tab + Chars.LF;
	Return InvalidChars;

EndFunction

// Checks whether the file name contains illegal characters.
//
// Parameters:
//  FileName - String - file name.
//
// Returns:
//   Array - array of prohibited chars detected in the file name. If no invalid characters are detected, an empty array is returned.
//
//@skip-check doc-comment-collection-item-type
Function FindProhibitedCharsInFileName(FileName) Export

	InvalidChars = GetProhibitedCharsInFileName();
	
	FoundProhibitedCharsArray = New Array;
	
	For CharPosition = 1 To StrLen(InvalidChars) Do
		CharToCheck = Mid(InvalidChars,CharPosition,1);
		If StrFind(FileName,CharToCheck) <> 0 Then
			FoundProhibitedCharsArray.Add(CharToCheck);
		EndIf;
	EndDo;
	
	Return FoundProhibitedCharsArray;

EndFunction

// Replaces illegal characters in a file name to legal characters.
//
// Parameters:
//  FileName     - String - an input file name.
//  ReplaceWith  - String - the string to substitute an illegal character.
//
// Returns:
//   String - converted filename.
//
Function ReplaceProhibitedCharsInFileName(Val FileName, ReplaceWith = " ") Export
	
	Return TrimAll(StrConcat(StrSplit(FileName, GetProhibitedCharsInFileName(), True), ReplaceWith));

EndFunction


#EndRegion

#Region ComparingVersions

// Platform version is at least 8 3 14.
// 
// Returns:
// 	Boolean - The platform version is not less than 8 3 14
Function PlatformVersionNotLess_8_3_14() Export
	Return PlatformVersionNotLess("8.3.14");
EndFunction

// Platform version comparing.
// 
// Parameters:
// 	ComparingVersion - String - Version for comparison
// 
// Returns:
// 	Boolean - Version of the platform is not less
Function PlatformVersionNotLess(ComparingVersion) Export
	VersionWithOutReleaseSubnumber=ConfigurationVersionWithoutBuildNumber(CurrentAppVersion());

	Return CompareVersionsWithoutBuildNumber(VersionWithOutReleaseSubnumber, ComparingVersion)>=0;
EndFunction

// Gets the configuration version without the build version.
//
// Parameters:
//  Version - String - the configuration version in the RR.PP.ZZ.CC format, where CC is the build 
//                    version and excluded from the result.
// 
// Returns:
//  String - configuration version in the RR.PP.ZZ format, excluding the build version.
//
Function ConfigurationVersionWithoutBuildNumber(Val Version) Export

	Array = StrSplit(Version, ".");

	If Array.Count() < 3 Then
		Return Version;
	EndIf;

	Result = "[Edition].[Subedition].[Release]";
	Result = StrReplace(Result, "[Edition]",    Array[0]);
	Result = StrReplace(Result, "[Subedition]", Array[1]);
	Result = StrReplace(Result, "[Release]",       Array[2]);
	
	Return Result;
EndFunction

// Compare two strings that contains version info
//
// Parameters:
//  Version1String  - String - number of version in  РР.{M|MM}.RR.RS format
//  Version2String  - String - secound compared version number.
//
// Returns:
//   Number - Integer more than 0, if Version1String > Version2String; 0, if version values is equal.
//
Function CompareVersions(Val Version1String, Val Version2String) Export

	String1 = ?(IsBlankString(Version1String), "0.0.0.0", Version1String);
	String2 = ?(IsBlankString(Version2String), "0.0.0.0", Version2String);
	Version1 = StrSplit(String1, ".");
	If Version1.Count() <> 4 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version1String: %1'; en='Wrong format of parameter Version1String: %1'"), Version1String);
	EndIf;
	Version2 = StrSplit(String2, ".");
	If Version2.Count() <> 4 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version2String: %1'; en='Wrong format of parameter Version2String: %1'"), Version2String);
	EndIf;

	Result = 0;
	For Digit = 0 to 3 do
		Result = Number(Version2[Digit]) - Number(Version2[Digit]);
		If Result <> 0 Then
			Return Result;
		EndIf;
	EndDo;
	Return Result;

EndFunction

// Compare two strings that contains version info
//
// Parameters:
//  Version1String  - String - number of version in  РР.{M|MM}.RR format
//  Version2String  - String - secound compared version number.
//
// Returns:
//   Number - Integer more than 0, if Version1String > Version2String; 0, if version values is equal.
//
Function CompareVersionsWithoutBuildNumber(Val Version1String, Val Version2String) Export

	String1 = ?(IsBlankString(Version1String), "0.0.0", Version1String);
	String2 = ?(IsBlankString(Version2String), "0.0.0", Version2String);
	Version1 = StrSplit(String1, ".");
	If Version1.Count() <> 3 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version1String: %1'; en='Wrong format of parameter Version1String: %1'"), Version1String);
	EndIf;
	Version2 = StrSplit(String2, ".");
	If Version2.Count() <> 3 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version2String: %1'; en='Wrong format of parameter Version2String: %1'"), Version2String);
	EndIf;

	Result = 0;
	For Digit = 0 to 2 do
		Result = Number(Version1[Digit]) - Number(Version2[Digit]);
		If Result <> 0 Then
			Return Result;
		EndIf;
	КонецЦикла;
	Return Result;

EndFunction



#EndRegion

#Region WriteParams

Function WriteParametersStructureByDefaults() Export
	WriteParameters=New Structure;
	WriteParameters.Insert("WithOutChangesAutoRecording", False);
	WriteParameters.Insert("WritingInLoadMode", False);
	WriteParameters.Insert("PrivilegedMode", False);
	WriteParameters.Insert("UseAdditionalProperties", False);
	WriteParameters.Insert("AdditionalProperties", New Structure);
	WriteParameters.Insert("UseBeforeWriteProcedure", False);
	WriteParameters.Insert("BeforeWriteProcedure", "");

	Return WriteParameters;
EndFunction

Function ToolsFormOutputWriteSettings() Export
	Array=New Array;
	Array.Add("WritingInLoadMode");    
	Array.Add("PrivilegedMode");     
	Array.Add("WithOutChangesAutoRecording");
	
	Return Array;
EndFunction

Function FormWriteSettings(Form, FormAttributePrefix = "WriteParameter_") Export
	WriteParameters=WriteParametersStructureByDefaults();

	For each KeyValue In WriteParameters Do
		If TypeOf(KeyValue.Value) = Type("Structure") Then
			For Each Row In Form[FormAttributePrefix + KeyValue.Key] Do
				WriteParameters[KeyValue.Key].Insert(Row.Key, Row.Value);
			EndDo;
		Else
			WriteParameters[KeyValue.Key]=Form[FormAttributePrefix + KeyValue.Key];
		EndIf;
	EndDo;
//	FillPropertyValues(WriteSettings, Form);
	
	Return WriteParameters;
EndFunction

Procedure SetOnFormWriteParameters(Form, WriteParameters, FormAttributePrefix = "WriteParameter_") Export
	For Each KeyValue In WriteParameters Do
		If TypeOf(KeyValue.Value) = Type("Structure") Then
			For Each KV In KeyValue.Value Do
				NS=Form[FormAttributePrefix + KeyValue.Key].Add();
				NS.Key=KV.Key;
				NS.Value=KV.Value;
			EndDo;
		Else
			Form[FormAttributePrefix + KeyValue.Key]=KeyValue.Value;
		EndIf;
	EndDo;
EndProcedure

#EndRegion

#Область DataCompositionSystem

#КонецОбласти

#Region FilesOperations

// Combines file path components
// 
// Parameters:
// Path1 - String - The first part of the path
// Path2 - String - Second part of the path
// Path3 - String, Undefined - Third part of the path
// Path4 - String, Undefined - Fourth part of the path
// 
// Returns:
// String - Merged path.
//
Function MergePaths(Path1, Path2, Path3 = Undefined, Path4 = Undefined) Export
	Separator = GetPathSeparator();
	
	PathsArray = StrSplit(Path1, Separator, False);
	
	If StrStartsWith(Path1, Separator) Then
		PathsArray.Insert(0, "");
	EndIf;
	
	AdditionalPaths = New Array;
	AdditionalPaths.Add(Path2);
	If ValueIsFilled(Path3) Then
		AdditionalPaths.Add(Path3);
	EndIf;
	If ValueIsFilled(Path4) Then
		AdditionalPaths.Add(Path4);
	EndIf;
	
	For Each Path In AdditionalPaths Do
		PathArray = StrSplit(Path, Separator, False);
		
		For Each SubPath In PathArray Do
			PathsArray.Add(SubPath);
		EndDo;
	EndDo;
	
	Return StrConcat(PathsArray, Separator);
	
EndFunction

// Catalog of satellite libraries.
// 
// Parameters:
// UserWorkingDirectory - String - data / temp files directory will be located
// 
// Returns:
// 	String - satellite libraries
Function SatelliteLibrariesCatalog(UserWorkingDirectory) Export
	Return MergePaths(UserWorkingDirectory, "tools_ui_1c", Format(Version(), "NG=0;"))
EndFunction

// Random file name.
// 
// Parameters:
// 	Extension - String - Extension
// 	Prefix - String - Prefix
// 
// Returns:
// 	String - RandomFileName
Function RandomFileName(Extension = "tmp", Prefix = "") Export
	Return Prefix
// 			+ Format(RandomNumber, "NG=0;")
			+ Format(CurrentUniversalDateInMilliseconds(), "NG=0;")
			+ "."
			+ Extension;
EndFunction

// Get the index of the file icon.
// 
// Parameters:
// 	FileExtension - String -File Extension
// 
// Returns:
// 	Number - Get file icon index
Function GetFileIconIndex(val FileExtension) Export

	If TypeOf(FileExtension) <> Type("String") Or IsBlankString(FileExtension) Then
		
		Return 0;
	EndIf;

	FileExtension = ExtensionWithoutDot(FileExtension);

	Extension = "." + Lower(FileExtension) + ";";
	
	If StrFind(".dt;.1cd;.cf;.cfu;", Extension) <> 0 Then
		Return 6; // 1C files.
		
	ElsIf Extension = ".mxl;" Then
		Return 8; // Spreadsheet File.
		
	ElsIf StrFind(".txt;.log;.ini;", Extension) <> 0 Then
		Return 10; // Text File.
		
	ElsIf Extension = ".epf;" Then
		Return 12; // External data processors.
		
	ElsIf StrFind(".ico;.wmf;.emf;",Extension) <> 0 Then
		Return 14; // Pictures.
		
	ElsIf StrFind(".htm;.html;.url;.mht;.mhtml;",Extension) <> 0 Then
		Return 16; // HTML.
		
	ElsIf StrFind(".doc;.dot;.rtf;",Extension) <> 0 Then
		Return 18; // Microsoft Word file.
		
	ElsIf StrFind(".xls;.xlw;",Extension) <> 0 Then
		Return 20; // Microsoft Excel file.
		
	ElsIf StrFind(".ppt;.pps;",Extension) <> 0 Then
		Return 22; // Microsoft PowerPoint file.
		
	ElsIf StrFind(".vsd;",Extension) <> 0 Then
		Return 24; // Microsoft Visio file.
		
	ElsIf StrFind(".mpp;",Extension) <> 0 Then
		Return 26; // Microsoft Visio file.
		
	ElsIf StrFind(".mdb;.adp;.mda;.mde;.ade;",Extension) <> 0 Then
		Return 28; // Microsoft Access database.
		
	ElsIf StrFind(".xml;",Extension) <> 0 Then
		Return 30; // xml.
		
	ElsIf StrFind(".msg;.eml;",Extension) <> 0 Then
		Return 32; // Email.
		
	ElsIf StrFind(".zip;.rar;.arj;.cab;.lzh;.ace;",Extension) <> 0 Then
		Return 34; // Archives.
		
	ElsIf StrFind(".exe;.com;.bat;.cmd;",Extension) <> 0 Then
		Return 36; // Files being executed.
		
	ElsIf StrFind(".grs;",Extension) <> 0 Then
		Return 38; // Graphical schema.
		
	ElsIf StrFind(".geo;",Extension) <> 0 Then
		Return 40; // Geographical schema.
		
	ElsIf StrFind(".jpg;.jpeg;.jp2;.jpe;",Extension) <> 0 Then
		Return 42; // jpg.
		
	ElsIf StrFind(".bmp;.dib;",Extension) <> 0 Then
		Return 44; // bmp.
		
	ElsIf StrFind(".tif;.tiff;",Extension) <> 0 Then
		Return 46; // tif.
		
	ElsIf StrFind(".gif;",Extension) <> 0 Then
		Return 48; // gif.
		
	ElsIf StrFind(".png;",Extension) <> 0 Then
		Return 50; // png.
		
	ElsIf StrFind(".pdf;",Extension) <> 0 Then
		Return 52; // pdf.
		
	ElsIf StrFind(".odt;",Extension) <> 0 Then
		Return 54; // Open Office writer.
		
	ElsIf StrFind(".odf;",Extension) <> 0 Then
		Return 56; // Open Office math.
		
	ElsIf StrFind(".odp;",Extension) <> 0 Then
		Return 58; // Open Office Impress.
		
	ElsIf StrFind(".odg;",Extension) <> 0 Then
		Return 60; // Open Office draw.
		
	ElsIf StrFind(".ods;",Extension) <> 0 Then
		Return 62; // Open Office calc.
		
	ElsIf StrFind(".mp3;",Extension) <> 0 Then
		Return 64;
		
	ElsIf StrFind(".erf;",Extension) <> 0 Then
		Return 66; // External reports.
		
	ElsIf StrFind(".docx;",Extension) <> 0 Then
		Return 68; // Microsoft Word docx file.
		
	ElsIf StrFind(".xlsx;",Extension) <> 0 Then
		Return 70; // Microsoft Excel xlsx file.
		
	ElsIf StrFind(".pptx;",Extension) <> 0 Then
		Return 72; // Microsoft PowerPoint pptx file.
		
	ElsIf StrFind(".p7s;",Extension) <> 0 Then
		Return 74; // Signature file
		
	ElsIf StrFind(".p7m;",Extension) <> 0 Then
		Return 76; // encrypted message.
	Else
		Return 4;
	EndIf;
	
EndFunction

// Convert File Extension to lower case without Dot char
//
// Parameters:
//  FileExtension - String - extension for converting.
//
// Returns:
//  String.
//
Function ExtensionWithoutDot(Val FileExtension) Export

	FileExtension = Lower(TrimAll(FileExtension));

	If Mid(FileExtension, 1, 1) = "." Then
		FileExtension = Mid(FileExtension, 2);
	EndIf;

	Return FileExtension;

EndFunction

#EndRegion

#Region ToolsSettings

Function SavedToolsDataCatalogNameAtServer() Export
	Return "UI_ToolsDataCatalogAtServer";
EndFunction
	
Function SettingsDataKeyInSettingsStorage() Export
	Return "UT_UniversalTools_Settings";
EndFunction

Function SessionParametersSettingsKey() Export
	Return "SessionParameters";
EndFunction
	
#EndRegion

#Region DistributionSettings

Function DownloadFileName() Export
	Return "UT_International.cfe";
EndFunction

Function DistributionType() Export
	Return "Extension";
EndFunction

Function PortableDistributionType() Export
	Return "Portable";
EndFunction

Function Version() Export
	Return "24.1.4";	
EndFunction

Function IsPortableDistribution() Export
	Return DistributionType() = PortableDistributionType();	
EndFunction

#EndRegion

#Region TypesWork

// Types presentation.
// 
// Parameters:
// 	ExpectedTypes - TypeDescription, Type, Array of Type - expected types
// 
// Returns:
// 	String - types presentation
Function TypesPresentation(ExpectedTypes) Export
	If TypeOf(ExpectedTypes) = Type("Array") Then
		Result = "";
		Index = 0;
		For Each Type In ExpectedTypes Do
			If Not IsBlankString(Result) Then
				Result = Result + ", ";
			EndIf;
			Result = Result + TypePresentation(Type);
			Index = Index + 1;
			If Index > 10 Then
				Result = Result + ",... " + StrTemplate(Nstr("ru = '(всего %1 типов)';en = '(total %1 of types)'"), ExpectedTypes.Count());
				Break;
			EndIf;
		EndDo;
		Return Result;
	Else
		Return TypePresentation(ExpectedTypes);
	EndIf;
EndFunction

// Type presentation.
// 
// Parameters:
// Type - Arbitrary, Type, TypeDescription - Type
// 
// Returns:
// 	String - Type presentation
Function TypePresentation(Type) Export
	If Type = Undefined Then
		Return "Undefined";
	ElsIf TypeOf(Type) = Type("TypeDescription") Then
		TypeString = String(Type);
		Return ?(StrLen(TypeString) > 150, Left(TypeString, 150) + "..." + StrTemplate(NStr("ru = '(всего %1 типов)';en = '(total %1 types'"),
			Type.Types().Count()), TypeString);
	    Else
		TypeString = String(Type);
		Return ?(StrLen(TypeString) > 150, Left(TypeString, 150) + "...", TypeString);
	EndIf;
EndFunction

// Expected type value.
// 
// Parameters:
// 	Value - Undefined, Arbitrary - Value
// 	ExpectedTypes - TypeDescription, Type, Array of Type, Arbitrary - Expected types
// 
// Returns:
// 	Boolean, Undefined - Value of Expected Type
Function ExpectedTypeValue(Value, ExpectedTypes) Export
	ValueType = TypeOf(Value);
	If TypeOf(ExpectedTypes) = Type("TypeDescription") Then
		Return ExpectedTypes.Types().Find(ValueType) <> Undefined;
	ElsIf TypeOf(ExpectedTypes) = Type("Type") Then
		Return ValueType = ExpectedTypes;
	ElsIf TypeOf(ExpectedTypes) = Type("Array") Or TypeOf(ExpectedTypes) = Type("FixedArray") Then
		Return ExpectedTypes.Find(ValueType) <> Undefined;
	ElsIf TypeOf(ExpectedTypes) = Type("Map") 	Or TypeOf(ExpectedTypes) = Type("FixedMap") Then
		Return ExpectedTypes.Get(ValueType) <> Undefined;
	EndIf;
	Return Undefined;
EndFunction

// Creates a TypeDescription object containing the String type.
//
// Parameters:
// 	StringLength - Number - the length of the string.
//
// Returns:
// TypeDescription - description of the String type.
//
Function DescriptionTypeString(StringLength) Export

	Array = New Array;
	Array.Add(Type("String"));

	StringQualifiers = New StringQualifiers(StringLength, AllowedLength.Variable);

	Return New TypeDescription(Array, , , StringQualifiers);

EndFunction

// Creates a TypeDescription object containing the Number type.
//
// Parameters:
// 	Digit - Number - digits (
// 					  integer part plus fractional part).
// 	DigitFractionalPart - Number - digits of the fractional part.
// 	SignNumber - AllowedSign - the allowed sign of the number.
//
// Returns:
// 	TypeDescription - description of the Number type.
Function DescriptionTypeNumber(Digit, DigitFractionalPart = 0, SignNumber = Undefined) Export

	If SignNumber = Undefined Then
		NumberQualifiers = New NumberQualifiers(Digit, DigitFractionalPart);
	Else
		NumberQualifiers = New NumberQualifiers(Digit, DigitFractionalPart, SignNumber);
	EndIf;

	Return New TypeDescription("Number", NumberQualifiers);

EndFunction

// Creates a TypeDescription object containing the Date type.
//
// Parameters:
// 	DateFractions - DateFractions - is a set of use cases for the values of the Date type.
//
// Returns:
// 	TypeDescription - description of the Date type.
Function DescriptionTypeDate(DateFractions) Export

	Array = New Array;
	Array.Add(Type("Date"));

	DateQualifiers = New DateQualifiers(DateFractions);

	Return New TypeDescription(Array, , , , DateQualifiers);

EndFunction

// Value table type.
// 
// Returns:
// 	Type - Value table type
Function ValueTableType() Export
	TypeDescriptionVT = New TypeDescription("ValueTable");
	Return TypeDescriptionVT.Types()[0];
	
EndFunction

// Value tree type.
// 
// Returns:
// 	Type - Value tree type
Function ValueTreeType() Export
	TypeDescriptionVT = New TypeDescription("ValueTree");
	Return TypeDescriptionVT.Types()[0];
	
EndFunction

#EndRegion

#Region TypesEditor

// Available type sets for editing.
// 
// Returns:
// 	Structure - Available type sets to edit:
// * References - String 
// * ComplexReferences - String 
// * Primitive - String 
// * Null - String 
// * ValueStorage - String 
// * ValueCollections - String 
// * PointInTime - String 
// * Type - String
// * TypeDescription - String 
// * Boundary - String 
// * UUID - String
// * StandardPeriod - String 
// * SystemEnums - String 
// * SpreadsheetDocument - String 
// * Picture - String 
// * BinaryData - String 
// * FixedValueCollections - String 
Function AvailableEditingTypesSets() Export
	AvailableSets = New Structure;
	AvailableSets.Insert("References", "REFERENCES");
	AvailableSets.Insert("ComplexReferences", "COMPLEXREFERENCES");
	AvailableSets.Insert("Primitive", "PRIMITIVE");
	AvailableSets.Insert("Null", "NULL");
	AvailableSets.Insert("ValueStorage", "VALUESTORAGE");
	AvailableSets.Insert("ValueCollections", "VALUECOLLECTIONS");
	AvailableSets.Insert("PointInTime", "POINTINTIME");
	AvailableSets.Insert("Type", "TYPE");
	AvailableSets.Insert("TypeDescription", "TYPEDESCRIPTION");
	AvailableSets.Insert("Boundary", "BOUNDARY");
	AvailableSets.Insert("UUID", "UUID");
	AvailableSets.Insert("StandardPeriod", "STANDARDPERIOD");
	AvailableSets.Insert("SystemEnums", "SYSTEMENUMS");
	AvailableSets.Insert("SpreadsheetDocument", "SPREADSHEETDOCUMENT");
	AvailableSets.Insert("Picture", "PICTURE");
	AvailableSets.Insert("BinaryData", "BINARYDATA");
	AvailableSets.Insert("FixedValueCollections", "FIXEDVALUECOLLECTIONS");
	
	Return AvailableSets;
EndFunction

// Default form field editing type sets.
// 
// Returns:
// 	Array of String - Default form field editing type sets
Function DefaultFormFieldEditingTypeSets() Export
	AvailableSets = AvailableEditingTypesSets();
	
	Sets = New Array;
	Sets.Add(AvailableSets.References);
	Sets.Add(AvailableSets.Primitive);
	Sets.Add(AvailableSets.UUID);
	Return Sets;
EndFunction

// All editing type sets.
// 
// Returns:
// 	Array of String - All editing type sets
Function AllEditingTypeSets() Export
	AvailableSets = AvailableEditingTypesSets();
	
	Sets = New Array;
	
	For Each KeyValue In AvailableSets Do
		Sets.Add(KeyValue.Value);
	EndDo;
	
	Return Sets;
	
EndFunction

// Stored editing type sets.
// 
// Returns:
// 	Array of String - Stored editing type sets
Function StoredSetsTypesForEditing() Export
	AvailableSets = AvailableEditingTypesSets();
	
	Sets = New Array;
	Sets.Add(AvailableSets.References);
	Sets.Add(AvailableSets.ComplexReferences);
	Sets.Add(AvailableSets.Primitive);
	Sets.Add(AvailableSets.ValueStorage);
	Sets.Add(AvailableSets.UUID);
	
	Return Sets;
	
EndFunction

// Data composition field type sets.
// 
// Returns:
// Array of String - Data composition field type sets
Function DataCompositionFieldTypeSets() Export
	AvailableSets = AvailableEditingTypesSets();
	
	Sets = New Array;
	Sets.Add(AvailableSets.References);
	Sets.Add(AvailableSets.ComplexReferences);
	Sets.Add(AvailableSets.Primitive);
	Sets.Add(AvailableSets.ValueStorage);
	Sets.Add(AvailableSets.UUID);
	Sets.Add(AvailableSets.Null);
	
	Return Sets;
		
EndFunction

// Session parameters type sets.
// 
// Returns:
// 	Array Of String
Function SessionParametersTypeSets() Export
	AvailableSets = AvailableEditingTypesSets();
	
	Sets = New Array;
	Sets.Add(AvailableSets.References);
	Sets.Add(AvailableSets.ComplexReferences);
	Sets.Add(AvailableSets.Primitive);
	Sets.Add(AvailableSets.ValueStorage);
	Sets.Add(AvailableSets.UUID);
	Sets.Add(AvailableSets.Null);
	Sets.Add(AvailableSets.BinaryData);
	Sets.Add(AvailableSets.TypeDescription);
	Sets.Add(AvailableSets.FixedValueCollections);
	Sets.Add(AvailableSets.SystemEnums);
	
	Return Sets;
EndFunction

// Empty UUID.
// 
// Returns:
// 	UUID - Empty UUID
Function EmptyUUID() Export
	Return New UUID("00000000-0000-0000-0000-000000000000");
EndFunction

// Empty type value.
// 
// Parameters:
// 	Type - Type, TypeDescription -
// 	PutToContainer - Boolean
// 
// Returns:
// 	Arbitrary
Function EmptyTypeValue(Type, PutToContainer = False) Export
	If PutToContainer Then
		Return "";
	EndIf;		

	If TypeOf(Type) = Type("TypeDescription") Then
		TypeDescription = Type;
	Else
		ArrayTypes = New Array;
		ArrayTypes.Add(Type);
		TypeDescription = New TypeDescription(ArrayTypes);
	EndIf;
		
	Return TypeDescription.AdjustValue(Undefined);
EndFunction
	
#EndRegion

#Region ContainerStorageValuesOnForm

#Region FormDataContainer

// Value type storage field suffix.
// 
// Returns:
// 	String - The suffix of the value type storage field name 
Function SuffixValueTypeStorageFieldName() Export
	Return "ValueType";
EndFunction

// New structure storing attribute on a form with a container.
// 
// Parameters:
// 	FieldName - String - FieldName
// 
// Returns:
// 	Structure - New structure storing attribute on a form with a container:
// * StructureFieldName - String 
// * ContainerFieldName - String 
// * ValueTypeFieldName - String 
// * ValueTypePresentationFieldName - String 
Function NewStructureStoringAttributeOnFormContainer(FieldName) Export
	StorageAttributeStructure = New Structure;
	StorageAttributeStructure.Insert("StructureFieldName", FieldName);
	StorageAttributeStructure.Insert("ContainerFieldName", FieldName
		+ SuffixContainerStorageFieldName());
	StorageAttributeStructure.Insert("ValueTypeFieldName", FieldName
		+ SuffixValueTypeStorageFieldName());
	StorageAttributeStructure.Insert("ValueTypePresentationFieldName", FieldName
		+ SuffixPresentationStorageFieldName());

	Return StorageAttributeStructure;
EndFunction

// Presentation storage field name suffix for the container field.
// 
// Returns:
// 	String - Presentation storage field name suffix for the container field
Function SuffixPresentationStorageFieldName() Export
	Return "PresentationValueType";
EndFunction

// Container storage field name suffix for container fiel.
// 
// Returns:
// 	String - Container storage field name suffix for container fiel
Function SuffixContainerStorageFieldName() Export
	Return "Container";
EndFunction



#EndRegion

#Region StorageContainers

// New value storage boundary type.
// 
// Returns:
// 	Structure - New value storage boundary type:
// * BoundaryType - String - Include or Exclude
// * Date - Date 
Function NewValueStorageBoundaryType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("BoundaryType", "Include");
	ValueStorage.Insert("Date",'00010101');
	
	Return ValueStorage;	
EndFunction

// New value storage point in time type.
// 
// Returns:
// 	Structure - New value storage point in time type:
// * Date - Date 
// * Reference - Undefined, AnyRef, CollaborationSystemConversation -  
Function NewValueStoragePointInTimeType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Date", '00010101');
	ValueStorage.Insert("Reference", Undefined);

	Return ValueStorage;
EndFunction

// New value storage value table type.
// 
// Returns:
// 	Structure - New value storage value table type:
// * Value - String 
// * RowCount - Number 
// * ColumnCount - Number 
Function NewValueStorageValueTableType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("RowCount", 0);
	ValueStorage.Insert("ColumnCount", 0);
	Return ValueStorage;
	
EndFunction

// New value storage value tree type.
// 
// Returns:
// 	Structure - New value storage value tree type:
// * Value - String 
// * RowCount - Number 
// * ColumnCount - Number 
Function NewValueStorageValueTreeType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("RowCount", 0);
	ValueStorage.Insert("ColumnCount", 0);
	Return ValueStorage;
	
EndFunction

// New value storage type.
// 
// Returns:
// 	Structure - New value storage type:
// * Value - String 
// * Name - String 
Function NewValueStorageType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("Name", "");
	
	Return ValueStorage;
EndFunction

// New value storage structure type.
// 
// Returns:
// 	Structure - New value storage structure type:
// * Value - String 
// * KeysCount - Number 
// * Keys - String - Comma-separated structure keys
Function NewValueStorageStructureType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("KeysCount", 0);
	ValueStorage.Insert("Keys", "");
	
	Return ValueStorage;
EndFunction

// New value storage map type.
// 
// Returns:
// 	Structure - New value storage map type:
// * Value - String 
// * KeysCount - Number 
Function NewValueStorageMapType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("KeysCount", 0);
	
	Return ValueStorage;
EndFunction

// New value storage spreadsheet document type.
// 
// Returns:
// 	Structure - New value storage spreadsheet document type:
// * Value - SpreadsheetDocument 
// * RowCount - Number 
// * ColumnCount - Number 
Function NewValueStorageSpreadsheetDocumentType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", New SpreadsheetDocument);
	ValueStorage.Insert("RowCount", 0);
	ValueStorage.Insert("ColumnCount", 0);
	
	Return ValueStorage;
EndFunction	

// New value storage value storage type.
// 
// Returns:
// 	Structure - New value storage value storage type:
// * Value - String 
// * Type - String 
Function NewValueStorageValueStorageType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("Type", "");
	
	Return ValueStorage;
	
EndFunction

// New value storage value list type.
// 
// Returns:
// Structure - New value storage value list type:
// * Value - String 
// * Presentation - String 
Function NewValueStoreValueListTypeValueList() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("Presentation", "");
	
	Return ValueStorage;
	
EndFunction

// New value storage array type.
// 
// Returns:
// 	Structure - New value storage array type:
// * Value - String 
// * Presentation - String 
Function NewValueStorageArrayType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", "");
	ValueStorage.Insert("Presentation", "");
	
	Return ValueStorage;
	
EndFunction

// New value storage picture type.
// 
// Returns:
// 	Structure - New value storage picture type:
// * Value - Picture 
// * PictureType - String 
Function NewValueStoragePictureType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", New Picture);
	ValueStorage.Insert("PictureType", "Empty");
	
	Return ValueStorage;
EndFunction

// New value storage binary data type.
// 
// Returns:
// 	Structure - New value storage binary data type:
// * Value - Undefined, ValueStorage - 
// * Size - Number 
// * Presentation - String 
Function NewValueStorageBinaryDataType() Export
	ValueStorage = New Structure;
	ValueStorage.Insert("Value", Undefined);
	ValueStorage.Insert("Size", 0);
	ValueStorage.Insert("Presentation", "");
	
	Return ValueStorage;
EndFunction

#EndRegion

#Region StorageContainerFromValues

// Time moment container storage value by date and reference.
// 
// Parameters:
// 	Date - Date
// 	Reference - AnyRef, CollaborationSystemConversation - Reference
// 
// Returns:
// 	ValueStorage - Structure - see UT_CommonClientServer.NewValueStoragePointInTimeType()
Function ValueOfTheTimeMomentStorageContainerByDateAndReference(Date, Reference) Export
	ValueStorage = NewValueStoragePointInTimeType();
	ValueStorage.Date = Date;
	ValueStorage.Reference = Reference;
	Return ValueStorage;
EndFunction

// Boundary container storage value by date and boundary type by string.
// 
// Parameters:
// 	Date - Date
// 	BoundaryType - String - Include or Exclude
// 
// Returns:
// 	ValueStorage - Structure - see UT_CommonClientServer.NewValueStorageBoundaryType()
Function ValueOfTheBoundaryStorageContainer(Date, BoundaryType) Export
	ValueStorage = NewValueStorageBoundaryType();
	ValueStorage.Date = Date;
	ValueStorage.BoundaryType = BoundaryType;
	Return ValueStorage;
EndFunction

// Spreadsheet document container storage value
// 
// Parameters:
// 	SpreadsheetDoc - SpreadsheetDocument - spreadsheet document
// 
// Returns:
// 	ValueStorage - Structure -  UT_CommonClientServer.NewValueStorageSpreadsheetDocumentType()
Function ValueOfTheSpreadsheetDocumentStorageContainer(SpreadsheetDoc) Export
	ValueStorage = NewValueStorageSpreadsheetDocumentType();
	ValueStorage.Value = SpreadsheetDoc;
	ValueStorage.RowCount=SpreadsheetDoc.HeightTable;
	ValueStorage.ColumnCount = SpreadsheetDoc.WidthTable;
	
	Return ValueStorage;	
	
EndFunction

// The value of the image container storage.
// 
// Parameters:
// 	Picture - Picture
// 
// Returns:
// 	ValueStorage - Structure - see UT_CommonClientServer.NewValueStoragePictureType().
Function ValueOfThePictureStorageContainer(Picture) Export
	ValueStorage = NewValueStoragePictureType();
	ValueStorage.Value = Picture;
	ValueStorage.PictureType = String(Picture.PictureType);
	
	Return ValueStorage;	
	
EndFunction

#EndRegion

#Region ValueFromStorageContainer

// Value from the spreadsheet document container storage.
// 
// Parameters:
// 	Container - Structure - see UT_CommonClientServer.NewValueStorageSpreadsheetDocumentType()
// 
// Returns:
// 	SpreadsheetDocument 
Function ValueFromSpreadsheetDocumentStorageContainer(Container) Export
	Return Container.Value;
EndFunction

// Value from the image container storage.
// 
// Parameters:
// 	Container - Structure - see UT_CommonClientServer.NewValueStoragePictureType().
// 
// Returns:
// 	Picture 
Function ValueFromPictureStorageContainer(Container) Export
	Return Container.Value;
EndFunction


#EndRegion

// Store type in the container.
// 
// Parameters:
// 	ValueType - Type 
// 
// Returns:
// 	Boolean - Store type in the container
Function TypeStoringInContainer(ValueType) Export
	Types = TypesStoredInContainers();
	Return Types.Find(ValueType) <> Undefined;
EndFunction

// Types stored in containers.
// 
// Returns:
// 	Array of Type - types stored in containers
Function TypesStoredInContainers() Export
	Return TypeDescriptionStoredInContainer().Types();	
EndFunction

// Types description of the  stored in the container.
// 
// Returns:
// 	TypeDescription - Description of types stored to the container
Function TypeDescriptionStoredInContainer() Export
	TypesArray = New Array;
	TypesArray.Add("PointInTime");
	TypesArray.Add("ValueTable");
	TypesArray.Add("ValueTree");
	TypesArray.Add("Type");
	TypesArray.Add("TypeDescription");
	TypesArray.Add("Boundary");
	TypesArray.Add("ValueStorage");
	TypesArray.Add("Array");
	TypesArray.Add("ValueList");
	TypesArray.Add("SpreadsheetDocument");
	TypesArray.Add("Map");
	TypesArray.Add("Structure");
	TypesArray.Add("Picture");
	TypesArray.Add("BinaryData");
	TypesArray.Add("FixedStructure");
	TypesArray.Add("FixedMap");
	TypesArray.Add("FixedArray");

	Return New TypeDescription(StrConcat(TypesArray,","));
EndFunction

// Value container types.
// 
// Returns:
// 	Structure - Value container types:
// * ValueTable - String 
// * ValueTree - String  
// * PointInTime - String 
// * Type - String 
// * TypeDescription - String 
// * ValueStorage - String 
// * Array - String 
// * ValueList - String 
// * Boundary - String 
// * SpreadsheetDocument - String
// * Map - String
// * Structure - String 
// * Picture - String 
// * BinaryData - String  
// * FixedStructure - String
// * FixedMap - String
// * FixedArray - String 
Function ContainerValuesTypes() Export
	ContainerTypes = New Structure;
	ContainerTypes.Insert("ValueTable", "VALUETABLE");
	ContainerTypes.Insert("ValueTree", "VALUETREE");
	ContainerTypes.Insert("PointInTime", "POINTINTIME");
	ContainerTypes.Insert("Type", "TYPE");
	ContainerTypes.Insert("TypeDescription", "TYPEDESCRIPTION");
	ContainerTypes.Insert("ValueStorage", "VALUESTORAGE");
	ContainerTypes.Insert("Array", "ARRAY");
	ContainerTypes.Insert("ValueList", "VALUELIST");
	ContainerTypes.Insert("Boundary", "BOUNDARY");
	ContainerTypes.Insert("SpreadsheetDocument", "SPREADSHEETDOCUMENT");
	ContainerTypes.Insert("Map", "MAP");
	ContainerTypes.Insert("Structure", "STRUCTURE");
	ContainerTypes.Insert("Picture", "PICTURE");
	ContainerTypes.Insert("BinaryData", "BINARYDATA");
	ContainerTypes.Insert("FixedStructure", "FIXEDSTRUCTURE");
	ContainerTypes.Insert("FixedMap", "FIXEDMAP");
	ContainerTypes.Insert("FixedArray", "FIXEDARRAY");
	
	Return ContainerTypes;
EndFunction

// New value container.
// 
// Returns:
// 	Structure - New value container:
// * Type - String - available types see UT_CommonClientServer.ContainerValuesTypes()
// * ValueStorage - Arbitrary, Undefined - The value itself or the storage that can be placed in the form data. 
// * Presentation - String - How to show the value to the user
Function NewValueContainer() Export
	Container = New Structure;
	Container.Insert("Type", "");
	Container.Insert("ValueStorage", Undefined);
	Container.Insert("Presentation", "");
	
	Return Container;
EndFunction

// New value container by type.
// 
// Parameters:
// 	Type - Type.
// 
// Returns:
// 	Structure - see UT_CommonClientServer.NewValueContainer()
Function NewValueContainerByType(Type) Export
	ContainerTypes = ContainerValuesTypes();
	
	Container = NewValueContainer();
	
	If Type = Type("Boundary") Then
		Container.Type = ContainerTypes.Boundary;
	ElsIf Type = Type("PointInTime") then 
		Container.Type = ContainerTypes.PointInTime;
	ElsIf Type = Type("Type") then 
		Container.Type = ContainerTypes.Type;
	ElsIf Type = Type("TypeDescription") then 
		Container.Type = ContainerTypes.TypeDescription;
	ElsIf Type = Type("Structure") then 
		Container.Type = ContainerTypes.Structure;
	ElsIf Type = Type("FixedStructure") then 
		Container.Type = ContainerTypes.FixedStructure;
	ElsIf Type = Type("Map") then 
		Container.Type = ContainerTypes.Map;
	ElsIf Type = Type("FixedMap") then 
		Container.Type = ContainerTypes.FixedMap;
	ElsIf Type = Type("SpreadsheetDocument") Then 
		Container.Type = ContainerTypes.SpreadsheetDocument;
	ElsIf Type = Type("ValueStorage") then 
		Container.Type = ContainerTypes.ValueStorage;
	ElsIf Type = Type("ValueList") then 
		Container.Type = ContainerTypes.ValueList;
	ElsIf Type = Type("Array") then 
		Container.Type = ContainerTypes.Array;
	ElsIf Type = Type("FixedArray") then 
		Container.Type = ContainerTypes.FixedArray;
	ElsIf Type = Type("Picture") then 
		Container.Type = ContainerTypes.Picture;
	ElsIf Type = Type("BinaryData") then 
		Container.Type = ContainerTypes.BinaryData;
	ElsIf Type = ValueTableType() then 
		Container.Type = ContainerTypes.ValueTable;
	ElsIf Type = ValueTreeType() then 
		Container.Type = ContainerTypes.ValueTree;
	EndIf;
	
	Return Container; //@skip-check constructor-function-return-section
EndFunction

// Set the container view.
// 
// Parameters:
// 	ValueContainer - Structure - see UT_CommonClientServer.NewValueContainer()
Procedure SetContainerPresentation(ValueContainer) Export
	ContainerTypes = ContainerValuesTypes();
	If ValueContainer.ValueStorage = Undefined Then
		ValueContainer.Presentation = "";
		Return;
	EndIf;
	If ValueContainer.Type = ContainerTypes.PointInTime Then
		ValueContainer.Presentation = String(ValueContainer.ValueStorage.Date)
										  + "; "
										  + ValueContainer.ValueStorage.Reference;
	ElsIf ValueContainer.Type = ContainerTypes.Boundary Then
		ValueContainer.Presentation = String(ValueContainer.ValueStorage.Date)
										  + " "
										  + ValueContainer.ValueStorage.BoundaryType;
	ElsIf ValueContainer.Type = ContainerTypes.ValueTable Then 
		ValueContainer.Presentation = StrTemplate("Rows: %1 Columns: %2",
																ValueContainer.ValueStorage.RowCount,
																ValueContainer.ValueStorage.ColumnCount);
	ElsIf ValueContainer.Type = ContainerTypes.ValueTree Then 
		ValueContainer.Presentation = StrTemplate("VT - rows: %1 Columns: %2",
																ValueContainer.ValueStorage.RowCount,
																ValueContainer.ValueStorage.ColumnCount);
	ElsIf ValueContainer.Type = ContainerTypes.Type Then
		ValueContainer.Presentation = "Type: " + ValueContainer.ValueStorage.Name;
	ElsIf ValueContainer.Type = ContainerTypes.TypeDescription Then
		ValueContainer.Presentation = "Types: " + ValueContainer.ValueStorage.Name;
	ElsIf ValueContainer.Type = ContainerTypes.Structure Then
		ValueContainer.Presentation = "Structure: " + ValueContainer.ValueStorage.Keys;
	ElsIf ValueContainer.Type = ContainerTypes.FixedStructure Then
		ValueContainer.Presentation = "Fixed structure: " + ValueContainer.ValueStorage.Keys;
	ElsIf ValueContainer.Type = ContainerTypes.Map Then
		ValueContainer.Presentation = "Map: " + ValueContainer.ValueStorage.KeysCount;
	ElsIf ValueContainer.Type = ContainerTypes.FixedMap Then
		ValueContainer.Presentation = "Fixed map: " + ValueContainer.ValueStorage.KeysCount;
	ElsIf ValueContainer.Type = ContainerTypes.SpreadsheetDocument Then 
		ValueContainer.Presentation = StrTemplate("Spreadsheet doc - rows: %1 Columns: %2",
																ValueContainer.ValueStorage.RowCount,
																ValueContainer.ValueStorage.ColumnCount);
	ElsIf ValueContainer.Type = ContainerTypes.ValueStorage Then
		ValueContainer.Presentation = "Value storage: " + ValueContainer.ValueStorage.Type;
	ElsIf ValueContainer.Type = ContainerTypes.ValueList Then
		ValueContainer.Presentation = "Value list: " + ValueContainer.ValueStorage.Presentation;
	ElsIf ValueContainer.Type = ContainerTypes.Array Then
		ValueContainer.Presentation = "Array: " + ValueContainer.ValueStorage.Presentation;
	ElsIf ValueContainer.Type = ContainerTypes.FixedArray Then
		ValueContainer.Presentation = "Fixed array: " + ValueContainer.ValueStorage.Presentation;
	ElsIf ValueContainer.Type = ContainerTypes.Picture Then
		ValueContainer.Presentation = "Picture: " + ValueContainer.ValueStorage.PictureType;
	ElsIf ValueContainer.Type = ContainerTypes.BinaryData Then
		ValueContainer.Presentation = "Binary data: " + ValueContainer.ValueStorage.Size;
	EndIf;
EndProcedure
		
// Value container field value.
// 
// Parameters:
// 	FormDataStructure - ClientApplicationForm, FormDataStructure, FormDataTreeItem, FormDataCollectionItem - form data structure
// 	ContainerFieldStorageParameters - see UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer
//
// Returns:
// 	Arbitrary
Function ValueContainerFieldValue(FormDataStructure, ContainerFieldStorageParameters) Export
	ContainerValue = FormDataStructure[ContainerFieldStorageParameters.ContainerFieldName];
	FieldValue = FormDataStructure[ContainerFieldStorageParameters.StructureFieldName];
	
	If ContainerValue = Undefined Then
		Return FieldValue;
	EndIf;
	
	Return UT_Common.ValueFromFormContainer(ContainerValue);
EndFunction

// Set container field value.
// 
// Parameters:
// 	FormDataStructure - ClientApplicationForm, FormDataStructure, FormDataTreeItem, FormDataCollectionItem - form data structure
// 	ContainerFieldStorageParameters - see UT_CommonClientServer.NewStructureStoringAttributeOnFormContainer
// 	NewValue - arbitrary - NewValue
Procedure SetContainerFieldValue(FormDataStructure, ContainerFieldStorageParameters, NewValue) Export
	ValueType = TypeOf(NewValue);	

	TypesDescription = New Array;
	TypesDescription.Add(ValueType);
	TypeDescription = New TypeDescription(TypesDescription);
		
	FormDataStructure[ContainerFieldStorageParameters.ValueTypePresentationFieldName] = String(TypeDescription);
	If Not TypeStoringInContainer(ValueType) Then
		TypesDescription = New Array;
		TypesDescription.Add(ValueType);
		FormDataStructure[ContainerFieldStorageParameters.ValueTypeFieldName] = TypeDescription;

		FormDataStructure[ContainerFieldStorageParameters.StructureFieldName] = NewValue;
		FormDataStructure[ContainerFieldStorageParameters.ContainerFieldName] = Undefined;

	Else
		FormDataStructure[ContainerFieldStorageParameters.ValueTypeFieldName] = DescriptionTypeString(100);
		
		Container = UT_Common.ValueIntoFormContainer(NewValue);

		SetContainerPresentation(Container);
		FormDataStructure[ContainerFieldStorageParameters.ValueTypeFieldName] = Container;
		FormDataStructure[ContainerFieldStorageParameters.ValueTypeFieldName] = Container.Presentation;
	EndIf;
EndProcedure
				
#EndRegion

// Description OS for Technical support().
// 
// Returns:
//  Structure -  Description OS for Technical support:
// * OSVersion - String - 
// * PlatformType - String - 
// * Processor - String - 
// * RAM - String - 
Function DescriptionOSForTechnicalSupport() Export
	SystemInfo = New SystemInfo;
	
	Description = New Structure;
	Description.Вставить("OSVersion",		SystemInfo.OSVersion);
	Description.Вставить("PlatformType", 	String(SystemInfo.PlatformType));
	Description.Вставить("Processor", 		SystemInfo.Processor);
	Description.Вставить("RAM", 			String(SystemInfo.RAM));
	
	Return Description;	
EndFunction

// Current 1C Enterprise platform version.
// 
// Returns:
//  String -  Current 1C Enterprise platform version
Function CurrentAppVersion() Export

	SystemInfo = New SystemInfo;
	Return SystemInfo.AppVersion;

EndFunction

// Managed form type.
// 
// Returns:
// 	Type - Managed form type
Function ManagedFormType() Export
	If PlatformVersionNotLess_8_3_14() Then
		
		Return Type("ClientApplicationForm")
	Else
		Return Type("ManagedForm");
	EndIf;
EndFunction

// Form item table
//
// Parameters:
//  Item - FormField, FormGroup, FormTable -
// 
// Returns:
//  FormTable -
// Returns:
//  Undefined - Item doesn't belong to form table
Function FormItemTable(Item) Export
	CurrentItem = Item;
	FormType = ManagedFormType();
	
	While TypeOf(CurrentItem) <> Type("FormTable") Do
		If CurrentItem.Parent = Undefined Or TypeOf(CurrentItem.Parent) = FormType Then
			
			Return Undefined;
		EndIf;
		
		CurrentItem = CurrentItem.Parent;
	EndDo;
	
	Return CurrentItem;
EndFunction

// Return configuration default language code, for example "ru".
//
// Returns:
// 	String - language code.
//
Function DefaultLanguageCode() Export
#If Not ThinClient And Not WebClient And Not MobileClient Then
	Return Metadata.DefaultLanguage.LanguageCode;
#Else
	Return UT_CommonCached.DefaultLanguageCode();
#EndIf
EndFunction

// Generates and show the message that can relate to a form item..
//
//
// Parameters:
//  UserMessageText - String - a mesage text.
//  DataKey - AnyRef - the infobase record key or object that message refers to.
//  Field                       - String - a form attribute description.
//  DataPath - String - a data path (a path to a form attribute).
//  Cancel - Boolean - an output parameter. Always True.
//
// Example:
//
//  1. Showing the message associated with the object attribute near the managed form field
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), ,
//   "FieldInFormAttributeObject",
//   "Object");
//
//  An alternative variant of using in the object form module
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), ,
//   "Object.FieldInFormAttributeObject");
//
//  2. Showing a message for the form attribute, next to the managed form field:
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), ,
//   "FormAttributeName");
//
//  3. To display a message associated with an infobase object:
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), InfobaseObject, "Responsible person",,Cancel);
//
//  4. To display a message from a link to an infobase object:
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), Reference, , , Cancel);
//
//  Scenarios of incorrect using:
//   1. Passing DataKey and DataPath parameters at the same time.
//   2. Passing a value of an illegal type to the DataKey parameter.
//   3. Specifying a reference without specifying a field (and/or a data path).
//
//@skip-check method-too-many-params
Procedure MessageToUser(Val UserMessageText,Val DataKey = Undefined,Val Field = "",Val DataPath = "",
		Cancel = False) Export
		
	Message = New UserMessage;
	Message.Text = UserMessageText;
	Message.Field = Field;
	
	IsObject = False;

#If Not ThinClient And Not WebClient And Not MobileClient Then
	If DataKey <> Undefined And XMLTypeOf(DataKey) <> Undefined Then
		ValueTypeAsString = XMLTypeOf(DataKey).TypeName;
		IsObject = StrFind(ValueTypeAsString, "Object.") > 0;
	EndIf;
#EndIf

	If IsObject Then
		Message.SetData(DataKey);
	Else
		Message.DataKey = DataKey;
	EndIf;
	
	If Not IsBlankString(DataPath) Then
		Message.DataPath = DataPath;
	EndIf;
		
	Message.Message();
	
	Cancel = True;

EndProcedure

// Add objects array to compare.
// 
// Parameters:
// 	Objects - Array of AnyRef, ValueList, AnyRef - Objects
Procedure AddObjectsArrayToCompare(Objects) Export
	UT_CommonServerCall.AddObjectsArrayToCompare(Objects);
EndProcedure

// Canceled long operations parameter name.
// 
// Parameters:
// 	Parameters - String.
// 
// Returns:
// 	String - Parameter name of canceled long term operations
Function СancelledTimeConsumingOperationsParametrName(Parameters) Export
	
	Return "UT_СancelledTimeConsumingOperations";
EndFunction

// Raises an exception if the ParameterName parameter value type of the ProcedureOrFunctionName 
// procedure or function does not match the excepted one.
// For validating types of parameters passed to the interface procedures and functions.
//
// Parameters:
//   ProcedureOrFunctionName - String          - name of the procedure or function that contains the parameter to check.
//   ParameterName           - String          - name of the parameter of procedure or function to check.
//   ParameterValue          - Arbitrary       - actual value of the parameter.
//   ExpectedTypes - TypeDescription, Type, Array of Type - type(s) of the parameter of procedure or function.
//   PropertiesTypesToExpect - Structure       - if the expected type is a structure, 
//   											 this parameter can be used to specify its properties.
//
Procedure CheckParameter(Val ProcedureOrFunctionName, Val ParameterName, Val ParameterValue, Val ExpectedTypes,
	Val PropertiesTypesToExpect = Undefined) Export

	Context = "CommonClientServer.CheckParameter";
	Validate(TypeOf(ProcedureOrFunctionName) = Type("String"), NStr(
		"ru = 'Недопустимое значение параметра ИмяПроцедурыИлиФункции'; en = 'Invalid value of ProcedureOrFunctionName parameter.'"), Context);
	Validate(TypeOf(ParameterName) = Type("String"), NStr(
		"ru = 'Недопустимое значение параметра ИмяПараметра'; en = 'Invalid value of ParameterName parameter.'"), Context);

	IsCorrectType = ExpectedTypeValue(ParameterValue, ExpectedTypes);
	Validate(IsCorrectType <> Undefined, NStr("ru = 'Недопустимое значение параметра ОжидаемыеТипы'; en = 'Invalid value of ExpectedTypes parameter.'"), Context);

	InvalidParameter = NStr("en = 'Invalid value of the %1 parameter in %2.
			           |Expected value: %3, passed value: %4 (type: %5).'");
	Validate(IsCorrectType, StrTemplate(InvalidParameter, ParameterName, ProcedureOrFunctionName,
		TypesPresentation(ExpectedTypes), ?(ParameterValue <> Undefined, ParameterValue, NStr(
		"ru = 'Неопределено'; en = 'Undefined'")), TypeOf(ParameterValue)));

	If TypeOf(ParameterValue) = Type("Structure") AND PropertiesTypesToExpect <> Undefined Then

		Validate(TypeOf(PropertiesTypesToExpect) = Type("Structure"), NStr("ru = 'Недопустимое значение параметра ИмяПроцедурыИлиФункции';
				 | en = 'Invalid value of ProcedureOrFunctionName parameter.'"), Context);

		NoProperty = NStr("en = 'Invalid value of parameter %1 (Structure) in %2.
					       |Expected value: %3 (type: %4).'");						   
		InvalidProperty = NStr("en = 'Invalid value of property %1 in parameter %2 (Structure) in %3.
					           |Expected value: %4; passed value: %5 (type: %6).'");				           
		For Each Property In PropertiesTypesToExpect Do

			ExpectedPropertyName = Property.Key;
			ExpectedPropertyType = Property.Value;
			PropertyValue = Undefined;

			Validate(ParameterValue.Свойство(ExpectedPropertyName, PropertyValue), StrTemplate(
				NoProperty,ParameterName, ProcedureOrFunctionName, ExpectedPropertyName, ExpectedPropertyType));

			IsCorrectType = ExpectedTypeValue(PropertyValue, ExpectedPropertyType);
			Validate(IsCorrectType, StrTemplate(InvalidProperty, ExpectedPropertyName, ParameterName,
				ProcedureOrFunctionName, TypesPresentation(ExpectedTypes), ?(PropertyValue <> Undefined,
				PropertyValue, NStr("ru = 'Неопределено'; en = 'Undefined'")), TypeOf(PropertyValue)));
		EndDo;
	EndIf;

EndProcedure

// Raise exeption with text Message when Condition not equal True.
// It is used for self-diagnosis of the code.
//
// Parameters:
//   Condition            - Boolean - if not True - raise Exeption
//   CheckContext     	  - String - for example, name of procedure or function where the check is performed.
//   Message              - String - message text message.If not set up, would exeption with default text. 
//   								 
//@skip-check doc-comment-parameter-section
Procedure Validate(Val Condition, Val Message = "", Val CheckContext = "") Export

	If Condition <> True Then
		If IsBlankString(Message) Then
			RaiseText = Nstr("ru = 'Недопустимая операция';en='Invalid operation'"); // Assertion failed
		Else
			RaiseText = Message;
		Endif;
		If Not IsBlankString(CheckContext) Then
			RaiseText = RaiseText + " " + StrTemplate(Nstr("ru = 'в %1';en='at %1'"), CheckContext);
		EndIf;
		Raise RaiseText;
	EndIf;

КонецПроцедуры

// Return a reference to the predefined item by its full name.
// Only the following objects can contain predefined objects:
//   - Catalogs,
//   - Charts of characteristic types,
//   - Charts of accounts,
//   - Charts of calculation types.
//
//  Parameters:
//   FullPredefinedItemName - String - full path to the predefined item including the name.
//     The format is identical to the PredefinedValue() global context function.
//     Example:
//       "Catalog.ContactInformationKinds.UserEmail"
//
//
//
// Returns:
//   AnyRef - reference to the predefined item;
//   Undefined - if the predefined item exists in metadata but not in the infobase.
//
Function PredefinedItem(FullPredefinedItemName) Export

// Using a standard function to get:
	//  - blank references
	//  - enumeration values
	//  - business process route points
	If ".EMPTYREF" = Upper(Right(FullPredefinedItemName, 13)) Or "ENUM." = Upper(Left(FullPredefinedItemName, 13)) 
		Or "BUSINESSPROCESS." = Upper(Left(FullPredefinedItemName, 14)) Then
		
		Return PredefinedValue(FullPredefinedItemName);
	EndIf;
	
	// Parsing the full name of the predefined item.
	FullNameParts = StrSplit(FullPredefinedItemName, ".");
	If FullNameParts.Count() <> 3 Then 
		Raise PredefinedValueNotFoundErrorText(FullPredefinedItemName);
	EndIf;

	FullMetadataObjectName = Upper(FullNameParts[0] + "." + FullNameParts[1]);
	PredefinedItemName = FullNameParts[2];
	
	// Cache to be called is determined by context.
	
#If Server Or ThickClientOrdinaryApplication Or ExternalConnection Then
	PredefinedValues = UT_CommonCached.RefsByPredefinedItemsNames(FullMetadataObjectName);
#Else
	PredefinedValues = UT_CommonClientCached.RefsByPredefinedItemsNames(
		FullMetadataObjectName);
#EndIf

	// In case of error in metadata name.
	If PredefinedValues = Undefined Then
		Raise PredefinedValueNotFoundErrorText(FullPredefinedItemName);
	EndIf;

	// Getting result from cache.
	Result = PredefinedValues.Get(PredefinedItemName);

    // If the predefined item does not exist in metadata.
	If Result = Undefined Then 
		Raise PredefinedValueNotFoundErrorText(FullPredefinedItemName);
	EndIf;

// If the predefined item exists in metadata but not in the infobase.
	If Result = Null Then 
		Return Undefined;
	EndIf;
	
	Return Result;

EndFunction

Function PredefinedValueNotFoundErrorText(PredefinedItemFullName) Export
	
	Return StrTemplate(NStr("ru = 'Предопределенное значение ""%1"" не найдено.'; en = 'Predefined value ""%1"" is not found.'"), PredefinedItemFullName);

EndFunction



#EndRegion

#Region Internal
// is intended for modules that are part of some functional subsystem. It should contain export procedures and functions that can only be called from other functional subsystems of the same library.
#EndRegion

#Region Private
// contains procedures and functions that make up the internal implementation of a common module. In cases where a common module is part of some functional subsystem that includes several metadata objects, this section can also contain service export procedures and functions intended only for calling from other objects of this subsystem.
#EndRegion


