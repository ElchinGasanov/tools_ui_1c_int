&Around("AttachExternalDataProcessor")				//ДополнительныеОтчетыИОбработки  // Checked, OK
Function UT_AttachExternalDataProcessor(Ref) Export
	UT_DebugSettings=UT_Common.AdditionalDataProcessorDebugSettings(Ref);

	UT_HasDebug=False;
	If UT_DebugSettings.DebugEnabled And ValueIsFilled(UT_DebugSettings.FileNameOnServer) Then
		If UT_DebugSettings.User=Undefined Or Not ValueIsFilled(UT_DebugSettings.User) Then
				
			UT_HasDebug=True;
		ElsIf UT_DebugSettings.User=Users.CurrentUser() Then
			UT_HasDebug=True;
			
		EndIf;
	EndIf;

	If Not UT_HasDebug Then
		Return ProceedWithCall(Ref);
	Else
		
		UT_DataProcessorFile = New File(UT_DebugSettings.FileNameOnServer);
		If Not UT_DataProcessorFile.Exist() Then
		
			UT_DataProcessorStorage = Common.ObjectAttributeValue(Ref, "DataProcessorStorage");
			UT_BinaryData = UT_DataProcessorStorage.Get();
			UT_BinaryData.Write(UT_DebugSettings.FileNameOnServer);
		
		EndIf; 
		
		UT_Kind = Common.ObjectAttributeValue(Ref, "Kind");
		If UT_Kind = Enums.AdditionalReportsAndDataProcessorsKinds.Report
			Or UT_Kind = Enums.AdditionalReportsAndDataProcessorsKinds.AdditionalReport Then
			UT_Manager = ExternalReports;
		Else
			UT_Manager = ExternalDataProcessors;
		EndIf;
		
        UT_UnsafeOperationProtectionDescription = New UnsafeOperationProtectionDescription;
		UT_UnsafeOperationProtectionDescription.UnsafeOperationWarnings = False; 
		
		UT_DataProcessorObject = UT_Manager.Create(UT_DebugSettings.FileNameOnServer,
											 False,
											 UT_UnsafeOperationProtectionDescription);
		
		Return TrimAll(UT_DataProcessorObject.Metadata().Name);
	EndIf;
	
EndFunction