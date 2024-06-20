
#Region FormEventHandlers

// Code of procedures and functions


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	//@skip-check unknown-form-parameter-access
	RequestRow = Parameters.RequestRow;
	//@skip-check unknown-form-parameter-access
	HistoryRow = Parameters.HistoryRow;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	CurrentRequestRow = FormOwner.RequestsTree.FindByID(RequestRow);
	If CurrentRequestRow = Undefined Then
		Cancel = True;
		Return;
	EndIf;
	
	CurrentHistoryRow = CurrentRequestRow.RequestsHistory.FindByID(HistoryRow);
	If CurrentHistoryRow = Undefined Then
		Cancel = True;
		Return;
	EndIf;
	
	FillPropertyValues(ThisObject, CurrentHistoryRow);
	Если IsTempStorageURL(ResponseBodyAddressString) Then
		ResponseBodyString = GetFromTempStorage(ResponseBodyAddressString);
	EndIf;
	
	HeaderProxySettingsAnalysisRequest = HeaderProxySettingsByParameters();

	Title = "" + Date + "," + FunctionHTTP + "," + RequestURL;

	If RequestBodyType = "Bodyless" Then
		CurrentPage = Items.BodylessPagesRequestsHistoryRequestBodyGroup;
	ElsIf RequestBodyType = "String" Then
		CurrentPage = Items.StringPagesRequestsHistoryRequestBodyGroup;
	ElsIf RequestBodyType = "BinaryData" Or RequestBodyType = "MultypartForm" Then
		CurrentPage = Items.BinaryDataPagesRequestsHistoryRequestBodyGroup;
	Else
		CurrentPage = Items.FilePagesRequestsHistoryRequestBodyGroup;
	EndIf;
	Items.PagesRequestsHistoryRequestBodyGroup.CurrentPage = CurrentPage;
EndProcedure

#EndRegion


#Region FormCommandsEventHandlers


&AtClient
Procedure EditResponseBodyInJSONEditorAnalyzedRequest(Command)
	UT_CommonClient.EditJSON(ResponseBodyString, True);
EndProcedure

&AtClient
Procedure SaveBinaryDataBodyResponseInFile(Command)
	If Not IsTempStorageURL(ResponseBodyBinaryDataAddress) Then
		Return;
	EndIf;

	SavingParameters = UT_CommonClient.NewFileSavingParameters();
	SavingParameters.TempStorageFileDirectory = ResponseBodyBinaryDataAddress;

	UT_CommonClient.BeginFileSaving(SavingParameters);
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditorAnalyzedRequest(Command)
	UT_CommonClient.EditJSON(RequestBodyString, True);
EndProcedure

&AtClient
Procedure SaveBodyRequestBinaryDataFromHistory(Command)
	If Not IsTempStorageURL(RequestBodyBinaryDataAddress) Then
		Return;
	EndIf;

	SavingParameters = UT_CommonClient.NewFileSavingParameters();
	SavingParameters.TempStorageFileDirectory = RequestBodyBinaryDataAddress;

	UT_CommonClient.BeginFileSaving(SavingParameters);
EndProcedure



#EndRegion

#Region Private

&AtClient
Function HeaderProxySettingsByParameters()
	HeaderPrefix = "";

	If UseProxy Then
		ProxyHeaderGroup = HeaderPrefix + ProxyServer;
		If ValueIsFilled(ProxyPort) Then
			ProxyHeaderGroup = ProxyHeaderGroup + ":" + Format(ProxyPort, "NG=0;");
		EndIf;

		If ProxyOSAuthentication Then
			ProxyHeaderGroup = ProxyHeaderGroup + NStr("ru = '; Аутентификация ОС'; en = 'OS authentication'");
		ElsIf ValueIsFilled(ProxyUser) Then
			ProxyHeaderGroup = ProxyHeaderGroup + ";" + ProxyUser;
		EndIf;

	Else
		ProxyHeaderGroup = HeaderPrefix + NStr("ru = 'Не используется'; en = 'Not used'");
	EndIf;

	Return ProxyHeaderGroup;
EndFunction

#EndRegion
