//Module for quick access to debugging procedures

// Description
// 
// Runs the appropriate tool for a thick client or writes data to the database for further debugging// 
//
// If the debugging startup context is a thick client, the console form oppening immediately after the code call
// is completed
// If debugging is called in the context of a server or a thin or web client,
//  the necessary information is stored in UT_DebugData
// 
// Parameters:
// 	DebugObject - Object of Query type
// Return value:
// DebugDataRef- type String.
// The result of saving debugging data
// 	
Function _Debug(ObjectForDebugging, DcsSettingsOrHTTPConnection = Undefined, ExternalDataSets = Undefined) Export
	Return UT_CommonClientServer.DebugObject(ObjectForDebugging, DcsSettingsOrHTTPConnection,ExternalDataSets);
EndFunction

#If Not WebClient Then


// Description
// 
// Parameters:
// 	ReadingPath - String, XMLReading, Stream - from where to read the XML 
// 	SimplifyElements - Boolean - is it worth removing unnecessary elements of the structure when reading
// Return value:
// 	Map, Structure, Undefined - Result of xml data reading
Function _XMLObject(ReadingPath, SimplifyElements=True) Export
	Return UT_XMLParcer.mRead(ReadingPath, SimplifyElements);
EndFunction

#EndIf

#If Server Or ThickClientOrdinaryApplication Or ThickClientManagedApplication Then
	
// Description
// 
// Returns a structure query table or Manager of temporary tables
//  If you pass a query, he previously performed.
// f the request has a Manager temporary tables, the structure of the table was added Manager temporary tables query
//
// Parameters:
// 	QueryORTempTablesManager- Type Query or TempTablesManager
// Return value:
// Structure- Type Structure
// Where
// Key- Name of Temporary Table
// Value- Content of temporary table
Function _TempTable(QueryORTempTablesManager) Export
	If TypeOf(QueryORTempTablesManager) = Type("TempTablesManager") Then
		Return UT_CommonServerCall.TempTablesManagerTempTablesStructure(
			QueryORTempTablesManager);
	ElsIf TypeOf(QueryORTempTablesManager) = Type("Query") Then
		Query=New Query;
		Query.Text=QueryORTempTablesManager.Text;
		For Each Parameter In QueryORTempTablesManager.Parameters Do
			Query.SetParameter(Parameter.Key, Parameter.Value);
		EndDo;

		If QueryORTempTablesManager.TempTablesManager = Undefined Then
			Query.TempTablesManager=New TempTablesManager;
		Else
			Query.TempTablesManager=QueryORTempTablesManager.TempTablesManager;
		EndIf;

		Try
			Query.ExecuteBatch();
		Except
			Return NStr("ru = 'Ошибка выполнения запроса';en = 'Query execution error'") + ErrorDescription();
		EndTry;

		Return UT_CommonServerCall.TempTablesManagerTempTablesStructure(
			Query.TempTablesManager);
	EndIf;
EndFunction


// Description
// Compares two tables of values for a given list of columns
// 
// Parameters:
// 	BaseTable		- ValueTable - the first table for comparison
// 	ComparisonTable	- ValueTable - the second table for comparison
// 	ColumnsList		- String 		  - List of columns for which you need to perform a comparison. 
// 											Columns must be present in both tables
// 											If the parameter is not specified, the comparison takes place according to the columns of the base table
// 	
// 	
// Return value:
// 
// 	Structure - Description:
// 	
// * IdenticalTables 		- Boolean 	- A sign of the identity of the tables
// * DifferencesTable 	- ValueTable 	- A table showing the discrepancies of the compared tables
Function _ValueTablesCompare(BaseTable, ComparisonTable, ColumnsList = Undefined) Export
	If ColumnsList = Undefined Then
		ColumnsForComparison="";
	Else
		ColumnsForComparison=ColumnsList;
	EndIf;

	Try
		Return UT_CommonServerCall.ExecuteTwoValueTablesComparison(BaseTable, ComparisonTable,
			ColumnsForComparison);
	Except
		Return ErrorDescription();
	EndTry;
EndFunction

#EndIf