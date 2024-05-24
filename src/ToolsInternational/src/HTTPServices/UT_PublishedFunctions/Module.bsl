#Region EventHandlers

#Region AlgorithmsExecution

Function AlgorithmsExecutionResult(Request)
	WebID = Request.URLParameters["AlgWebID"];

	IncomingParametersStructure = New Structure;
	For Each Parameter In Request.QueryOptions Do
		IncomingParametersStructure.Insert(Parameter.Key, Parameter.Value);
	EndDo;
	ResponseStructure = New Structure("StatusCode,ResponseBody", 200, " GET  method processing");

	ProcessRequest(WebID, IncomingParametersStructure, ResponseStructure);

	Return ServiceResponse(ResponseStructure.StatusCode, ResponseStructure.ResponseBody);
EndFunction



#EndRegion

#Region Ping


Функция PingGET(Запрос)
	Возврат ServiceResponse(200, "OK");
КонецФункции

#EndRegion

#Region DataTransfer

Function DataTransferSendFileAndUpload(Request)

	UploadError=False;
	ServiceError="";
	UploadLog="";

	Try

		FileName = GetTempFileName("zip");
		TransferBinaryData=Request.GetBodyAsBinaryData();
		TransferBinaryData.Write(FileName);

		UploadLogFileName=GetTempFileName("txt");

		Processing = DataProcessors.UT_UniversalDataExchangeXML.Create();
		Processing.ExchangeMode = "Load";
		Processing.ExchangeFileName = FileName;
		Processing.ExchangeLogFileName=UploadLogFileName;
		Processing.ExchangeLogFileEncoding="UTF-8";
		Processing.ExecuteImport();

		UploadError=Processing.ErrorFlag;
		DeleteFiles(FileName);

		LogFile=New File(UploadLogFileName);
		If LogFile.Exists() Then
			LogText=New TextDocument;
			LogText.Read(UploadLogFileName);

			UploadLog=LogText.GetText();
			LogText=Undefined;

			DeleteFiles(UploadLogFileName);

		EndIf;
	Except
		ServiceError = ErrorDescription();
	EndTry;

	ResponseStructure=New Structure;
	ResponseStructure.Insert("ServiceError", ServiceError);
	ResponseStructure.Insert("UploadError", UploadError);
	ResponseStructure.Insert("UploadLog", UploadLog);

	JSONWriter=New JSONWriter;
	JSONWriter.SetString();

	WriteJSON(JSONWriter, ResponseStructure);

	Return ServiceResponse(200, JSONWriter.Close(), "application/json; charset=utf-8");

EndFunction

#EndRegion

#EndRegion

#Region Private


Procedure ProcessRequest(WebID, IncomingParameters, Response)
	Query = New Query;
	Query.Text =
	"Select first 1
	|   _37583_ALG.Ref AS Algorithm
	|ИЗ
	|   Catalog.UT_Algorithms AS _37583_ALG
	|ГДЕ
	|   _37583_ALG.HttpID= &WebID";

	Query.SetParameter("WebID", WebID);

	QueryResult = Query.Execute();
	If QueryResult.IsEmpty() Then
		Response.StatusCode = 404;
		Response.ResponseBody = NStr("ru = 'Ошибка: не найден алгоритм!'; en = 'Error:  algorithm not found'");
		Return;
	EndIf;
		
	SelectionDetailRecords = QueryResult.Select();
	SelectionDetailRecords.Next();
	ExecutionResult = UT_AlgorithmsServer.ExecuteAlgorithm(SelectionDetailRecords.Algorithm);
	If ExecutionResult = Undefined Then
		Response.StatusCode = 404;
		Response.ResponseBody = NStr("ru = 'Ошибка: Путой алгоритм!'; en = 'Error:  algorithm is empty'");
		Return;
	EndIf;
	
	Response.ResponseBody = UT_CommonClientServer.mWriteJSON(ExecutionResult);	
		
EndProcedure


Function ServiceResponse(StatusCode, ResponseBody, ContentType = "text/html; charset=utf-8")
	Response = New HTTPServiceResponse(StatusCode);
	Response.SetBodyFromString(ResponseBody, TextEncoding.UTF8);
	Response.Headers.Insert("Content-Type", ContentType);
	Return Response;
		
EndFunction 

#EndRegion

