
#Region FormEventHandlers


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CloseOnChoice = True;

	If Parameters.Property("Value") Then
		//@skip-check unknown-form-parameter-access
		UUIDString = Parameters.Value;
	EndIf;
	
	If Not ValueIsFilled(UUIDString) Then
		UUIDString = UT_CommonClientServer.EmptyUUID();
	EndIf;
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure UUIDFinishTextInput(Item, Text, ChosenData, DataReceivingParameters, StandardProcessing)
	//StandardProcessing = False;
	If ValueIsFilled(Text) Then
		Try
			//@skip-warning
			_ = New UUID(Text);
		Except
			Raise NStr("ru = 'Некорректный уникальный идентификатор!'; en = 'Invalid UUID'");
		EndTry;
	EndIf;
EndProcedure

&AtClient
Procedure RefOnChange(Item)
	If Ref <> Undefined Then
		//@skip-warning
		UUIDString = Ref.UUID();
	EndIf;
EndProcedure

&AtClient
Procedure UUIDCleaning(Item, StandardProcessing)
	StandardProcessing = False;
	UUIDString = UT_CommonClientServer.EmptyUUID();
EndProcedure
#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure CommandOK(Command)
	
	ChosenValue = UT_CommonClientServer.EmptyUUID();
	If ValueIsFilled(UUIDString) Then
		//@skip-check empty-except-statement
		Try
			ChosenValue = New UUID(UUIDString);
		Except
			UT_CommonClientServer.MessageToUser(NStr("ru = 'Указан некорректный уникальный идентификатор'; en = 'Invalid UUID specified'"));
			Return;
		EndTry;
	EndIf;
	
	If FormOwner <> Undefined Then
		NotifyChoice(ChosenValue);
	Else
		Close(ChosenValue);
	EndIf;
		
EndProcedure

&AtClient
Procedure CommandFind(Command)
	Ref = CommandFindOnServer(UUIDString);
EndProcedure

&AtClient
Procedure Generate(Command)
	UUIDString = Строка(New UUID);
EndProcedure

#EndRegion

#Region Private

&AtServerNoContext
Procedure AddRequest(SearchQueryArray, SearchRequest, RefClass, Manager, UUIDString)
	
	Ref = Manager.GetRef(New UUID(UUIDString));
	MetadataName = Ref.Metadata().Name;
	BaseTable = RefClass + "." + MetadataName;
	ParameterName = RefClass + MetadataName;;
	
	SearchQueryArray.Add(
		"SELECT TOP 1
		|	Table.Ref КАК Ref
		|FROM
		|	" + BaseTable + " AS Table
		|WHERE
		|	Table.Ref = &" + ParameterName);
	SearchRequest.SetParameter(ParameterName, Ref);
		
EndProcedure

&AtServerNoContext
Function CommandFindOnServer(UUIDString)
	
	SearchRequest = New Query;
	SearchQueryArray = New Array;
	
	For Each  Manager In Catalogs Do
		AddRequest(SearchQueryArray, SearchRequest, "Catalog", Manager, UUIDString);
	EndDo;
	
	For Each  Manager In Documents Do
		AddRequest(SearchQueryArray, SearchRequest, "Document", Manager, UUIDString);
	EndDo;
	
	For Each  Manager In ChartsOfAccounts Do
		AddRequest(SearchQueryArray, SearchRequest, "ChartOfAccounts", Manager, UUIDString);
	EndDo;
	                                                         
	For Each  Manager In ChartsOfCharacteristicTypes Do
		AddRequest(SearchQueryArray, SearchRequest, "ChartOfCharacteristicTypes", Manager, UUIDString);
	EndDo;
	
	For Each  Manager In ChartsOfCalculationTypes Do
		AddRequest(SearchQueryArray, SearchRequest, "ChartOfCalculationTypes", Manager, UUIDString);
	EndDo;
	
	For Each  Manager In BusinessProcesses Do
		AddRequest(SearchQueryArray, SearchRequest, "BusinessProcess", Manager, UUIDString);
	EndDo;
	
	For Each  Manager In Tasks Do
		AddRequest(SearchQueryArray, SearchRequest, "Task", Manager, UUIDString);
	EndDo;
	
	For Each  Manager In ExchangePlans Do
		AddRequest(SearchQueryArray, SearchRequest, "ExchangePlan", Manager, UUIDString);
	EndDo;
	
	RequestText = StrConcat(SearchQueryArray, "
		|UNION ALL
		|");
	
	SearchRequest.Text = RequestText;
	QueryResultSelection = SearchRequest.Execute().Select();
	If QueryResultSelection.Next() Then
		Return QueryResultSelection.Ref;
	EndIf;
	
	Return Undefined;
	
EndFunction


#EndRegion



