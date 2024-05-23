
#Region Public

// Service algorithm data.
// 
// Parameters:
//  AlgorithmID - String - Algorithm identifier
// 
// Return values:
//  look at NewAlgorithmData 
// Return values:
// Undefined - Failed to receive data
Function ServiceAlgorithmData(AlgorithmID) Export
	Try
		Data = UT_HTTPConnector.GetJson("https://paste1c.ru/json/" + AlgorithmID);
	Except
		Return Undefined;
	EndTry;

	ReturnData = NewAlgorithmData();
	ReturnData.Text = ?(Data["code"] = Undefined, "", Data["code"]);
	ReturnData.QueryMode = ValueIsFilled(Data["query_mode"]);

	Return ReturnData;
EndFunction

// Result of loading the algorithm into the service.
// 
// Parameters:
//  AlgorithmText - String - Algorithm text
//  QueryMode - Boolean - Query mode
// 
// Return values:
// look at NewResultLoadingAlgorithm
// Return values:
// Undefined - the request came out with an error
Function LoadingResultAlgorithmIntoService(AlgorithmText, QueryMode) Export
	SentData = New Structure("Shared", New Structure);
	SentData.Shared.Вставить("code", AlgorithmText);
	SentData.Shared.Вставить("query_mode", ?(QueryMode, 1, 0));
	
	Try
		Result = UT_HTTPConnector.PostJson("https://paste1c.ru/paste", SentData);
	Except
		Return Undefined;
	EndTry;

	Successfully =  Result["success"];
	If Successfully = Undefined Then
		Return Undefined;
	EndIf;

	ReturnData = NewResultLoadingAlgorithm();
	ReturnData.Successfully = Successfully;
	If ReturnData.Successfully Then
		ReturnData.ID = Result["id"];
		ReturnData.Link = Result["full_url"];
		ReturnData.LinkJSON = Result["json_url"];
	Else
		ReturnData.Errors = StrConcat(Result["error"], ";");
	EndIf;

	Return ReturnData;
EndFunction

#EndRegion

#Region Internal

//Code of procedures and functions

#EndRegion

#Region Private

// New algorithm data.
// 
// Return values:
//  Structure -  New algorithm data:
// * Text - String - 
// * QueryMode - Boolean - 
Function NewAlgorithmData() Export
	Data = New Structure;
	Data.Insert("Text", "");
	Data.Insert("QueryMode", False);
	
	Return Data;
EndFunction

// New result of loading the algorithm.
// 
// Return values:
//  Structure -  New result of loading the algorithm:
// * Successfully - Boolean - 
// * ID - String - 
// * Link - String - 
// * LinkJSON - String - 
Function NewResultLoadingAlgorithm() 
	Structure = New Structure;
	Structure.Insert("Successfully", False);
	Structure.Insert("ID", "");
	Structure.Insert("Link", "");
	Structure.Insert("LinkJSON", "");
	Structure.Insert("Errors", "");
	
	Return Structure;
EndFunction

#EndRegion
