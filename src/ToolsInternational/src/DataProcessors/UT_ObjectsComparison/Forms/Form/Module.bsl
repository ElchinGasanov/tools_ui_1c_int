
#Region FormEventHandlers
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Objects.Clear();
	If Parameters.Property("ObjectsComparison") Then
		Objects.LoadValues(Parameters.ObjectsComparison);
	EndIF;
	GenerateAtServer();
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure

#EndRegion

#Region ObjectFormTableEventHandlers

&AtClient
Procedure ObjectsValueStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData = Items.Objects.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	AvailableTypesSets = UT_CommonClientServer.AvailableEditingTypesSets();

	HandlerParameters = UT_CommonClient.NewProcessorValueChoiceStartingEvents(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.Value = CurrentData.Value;
	HandlerParameters.StructureValueStorage = CurrentData;
	HandlerParameters.TypesSet = AvailableTypesSets.References;

	UT_CommonClient.FormFieldValueStartChoiceProcessor(HandlerParameters, StandardProcessing);
EndProcedure

&AtClient
Procedure ObjectsValueClearing(Item, StandardProcessing)
	CurrentData = Items.Objects.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	HandlerParameters = UT_CommonClient.NewProcessorClearingEventsParameters(ThisObject,
																			Item,
																			"Value");
	HandlerParameters.AvailableContainer = False;
	HandlerParameters.StructureValueStorage = CurrentData;

	UT_CommonClient.FormFieldClear(HandlerParameters, StandardProcessing);

EndProcedure


#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure Generate(Command)
	If Objects.Count() = 0 Then
		Items.FormParameters.Check = True;
		Items.GroupParameters.Visible = True;
		CurrentItem = Items.Objects;
		Return;
	EndIf;
	GenerateAtServer();	
EndProcedure

&AtClient
Procedure Parameters(Command)
	Check = NOT Items.FormParameters.Check;
	Items.FormParameters.Check = Check;
	Items.GroupParameters.Visible = Check;
EndProcedure

&AtClient
Procedure AddObjectsAddedToComparisonEarly(Command)
	AddObjectsAddedToComparisonEarlyAtServer();
EndProcedure

&AtClient
Procedure ClearObjectsAddedToTheComparison(Command)
	ClearObjectsAddedToTheComparisonAtServer();
EndProcedure

//@skip-check module-unused-method
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure



#EndRegion

#Region Private

&AtServerNoContext
Procedure AddToTree(VT, ObjectRef)
	MD = ObjectRef.Metadata();
	UUID = ObjectRef.UUID();
	GUUID = "id_" + StrReplace(UUID, "-", "_");
	
	VT.Columns.Add(GUUID, New TypeDescription());

	//Attributes
	Rows = VT.Rows;
	Row = Rows.Find(" Attributes", "Attribute");
	If Row = Undefined Then
		Row = Rows.Add();
		Row.Attribute = " Attributes";
	EndIf;
	Row[GUUID] = ObjectRef;

	Rows = Row.Rows;
	Attributes = MD.Attributes;
	For Each Attribute in Attributes Do
		AttributeName = Attribute.Name; 
		
		Row = Rows.Find(AttributeName, "Attribute");
		If Row = Undefined Then
			Row = Rows.Add();
			Row.Attribute = AttributeName;
		EndIf;
		Row[GUUID] = ObjectRef[AttributeName]; 
	EndDo;
		
	//Tabular section
	For Each TS In MD.TabularSections Do
		IF ObjectRef[TS.Name].Count() = 0 Then Continue; Endif;
		AttributeName = TS.Name; 
		
		Rows = VT.Rows;
		Row = Rows.Find(AttributeName, "Attribute");
		If Row = Undefined Then
			Row = Rows.Add();
			Row.Attribute = AttributeName;
		EndIf;

		//Rows tabular section
		RowsSet = Row.Rows;
		For Each RowTS In ObjectRef[TS.Name] Do
			NumberRow = "Row # " + Format(RowTS.LineNumber, "ND=4; NLZ=; NG=");
			RowSet = RowsSet.Find(NumberRow, "Attribute");
			If RowSet = Undefined Then 
				RowSet = RowsSet.Add();
				RowSet.Attribute = NumberRow;
			EndIf;
			
			//Values of the rows tabular section
			RowsRS = RowSet.Rows;
			For Each Attribute In MD.TabularSections[TS.Name].Attributes Do
				AttributeName = Attribute.Name; 

				RowRS = RowsRS.Find(AttributeName, "Attribute");
				If RowRS = Undefined Then
					RowRS = RowsRS.Add();
					RowRS.Attribute = AttributeName;
				EndIf;
				Value = RowTS[AttributeName];
				RowRS[GUUID] = ?(ValueIsFilled(Value), Value, Undefined);
			EndDo;

		EndDo;
	EndDo;
	
	Rows = VT.Rows;
	Rows.Sort("Attribute", True);
EndProcedure

&AtServerNoContext
Procedure ClearTree(VT, Rows = Undefined) 
	
	Columns = New Array;
	For Each Column In VT.Columns Цикл
		Если Column.Name = "Attribute" Then Continue; EndIF;
		Columns.Add(Column.Name);
	EndDo;
	CountCol = Columns.Count() - 1;
	If CountCol = 0 Then Return EndIf;

	If Rows = Undefined Then
		Rows = VT.Rows;
	EndIF;

	DeletedRows = New Array;
	For Each Row In Rows Do
		HaveSubordinates = Row.Rows.Count() > 0; 
		
		IF HaveSubordinates Then
			ClearTree(VT, Row.Rows);
		Else counter = 0;
			For Col = 1 to CountCol Do
				counter = counter + ?(Row[Columns[0]] = Row[Columns[Col]], 1, 0);
			EndDo;
			If counter = CountCol Then DeletedRows.Add(Row); EndIf;
		EndIf;
	EndDo;
	
	For Each Row In DeletedRows Do
		Rows.Delete(Row);
	EndDo;

EndProcedure

&AtServer
Procedure GeneratePrintFormObjectsComparison() Export 

	VT = New ValueTree;
	VT.Columns.Add("Attribute", New TypeDescription());

	For Each ObjectItem In Objects Do
		RefOnObject = ObjectItem.value;
		AddToTree(VT, RefOnObject);
	EndDo;

	ClearTree(VT);

	SpreadsheetDocument = New SpreadsheetDocument;
	SpreadsheetDocument.PrintParametersName = "Print_Parameters_Processing_ObjectsComparison";
	Template = DataProcessors.UT_ObjectsComparison.GetTemplate("PF_MXL_ComparisonObjects");
	
	SpreadsheetDocument.StartRowAutoGrouping();
	Level = 1;
	For Each Row In VT.Rows Do
		PrintRow(Row, VT.Columns, SpreadsheetDocument, Template, Level);// print row
	EndDo;
	SpreadsheetDocument.EndRowAutoGrouping();
	
	HeadArea = SpreadsheetDocument.Area(1,,1);
	SpreadsheetDocument.RepeatOnRowPrint = HeadArea;
	SpreadsheetDocument.ReadOnly = True;
	SpreadsheetDocument.FitToPage = True;
	SpreadsheetDocument.FixedTop = 1;
	SpreadsheetDocument.FixedLeft = 1;
	
EndProcedure

&AtServerNoContext
Procedure PrintRow(Row, Columns, SpreadsheetDocument, Template, Level)
	HaveNestedRows = Row.Rows.Count() > 0;//HaveNestedRows
	
	AttributeArea = Template.GetArea("Attribute");
	AttributeArea.Parameters.Attribute = TrimAll(Row.Attribute);
	If HaveNestedRows Then CheckoutArea(AttributeArea); EndIf;
	SpreadsheetDocument.Put(AttributeArea, Level);
	
	ColumnArea = Template.GetArea("Value");
	For Each Column In Columns Do
		If Column.Name = "Attribute" Then Continue; EndIf;
		Value = Row[Column.Name];
		ColumnArea.Parameters.Value = Value;
		If HaveNestedRows Then CheckoutArea(ColumnArea); EndIf;
		SpreadsheetDocument.Join(ColumnArea, Level);
	EndDo;
	

	If HaveNestedRows Then
		For Each SubString In Row.Rows Do
			PrintRow(SubString, Columns, SpreadsheetDocument, Template, Level + 1);
		EndDo;
	EndIf;
EndProcedure

&AtServerNoContext
Procedure CheckoutArea(Area)
	Font = Area.CurrentArea.Font;
	Area.CurrentArea.Font = New Font(Font,,,True);
	Area.CurrentArea.BackColor = StyleColors.ReportHeaderBackColor;
EndProcedure


&AtServer
Procedure GenerateAtServer()
	GeneratePrintFormObjectsComparison();
EndProcedure

&AtServer
Procedure AddObjectsAddedToComparisonEarlyAtServer()
	ObjectsComparisonArray=UT_Common.ObjectsAddedToTheComparison();
	
	For Each CurrObject In ObjectsComparisonArray Do
		If Objects.FindByValue(CurrObject)<>Undefined Then
			Continue;
		EndIf;
		
		Objects.Add(CurrObject);
	EndDo;
EndProcedure

&AtServer
Procedure ClearObjectsAddedToTheComparisonAtServer()
	UT_Common.ClearObjectsAddedToTheComparison();
EndProcedure

#EndRegion



