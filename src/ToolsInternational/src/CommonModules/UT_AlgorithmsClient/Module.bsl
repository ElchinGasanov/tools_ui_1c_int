
#Region Public

#Region EditingAlgorithms

Procedure CreateAlgorithm(DescriptionCompleteAlerts = Undefined,
	CopyAlgorithmIdentifier = Undefined) Export
	FormOptions = New Structure;
	FormOptions.Insert("CopyingValue", CopyAlgorithmIdentifier);

	If DescriptionCompleteAlerts = Undefined Then
		OpenForm("DataProcessor.UT_UT_Algorithm2.Form.ФормаЭлемента", FormOptions);
	Else
		OpenForm("DataProcessor.UT_UT_Algorithm2.Form.ФормаЭлемента",
					 FormOptions,
					 ,
					 ,
					 ,
					 ,
					 DescriptionCompleteAlerts);

	EndIf;
EndProcedure

Procedure EditAlgorithm(Identifier, DescriptionCompleteAlerts = Undefined) Export
	FormOptions = New Structure;
	FormOptions.Insert("Key", Identifier);
	
	If DescriptionCompleteAlerts = Undefined Then
		OpenForm("DataProcessor.UT_UT_Algorithm2.Form.ФормаЭлемента", FormOptions);
	Else
		OpenForm("DataProcessor.UT_UT_Algorithm2.Form.ФормаЭлемента",
					 FormOptions,
					 ,
					 ,
					 ,
					 ,
					 DescriptionCompleteAlerts);

	EndIf;
	
EndProcedure

#EndRegion

#EndRegion

#Region Internal

// Code of procedures and functions

#EndRegion

#Region Private

// Code of procedures and functions

#EndRegion
