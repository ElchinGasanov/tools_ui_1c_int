
#Region Variables

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SetTextFieldChanges();
	FillCurrentVersion();
	FillActualVersionAndChangesDescription();
	SetNeedForUpdate();
EndProcedure


#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure ChangesDescriptionDocumentComplete(Item)
	If Not NeedForUpdate Then
		Return;
	EndIf;
	
	View = Item.Document.defaultView;
	View.addText("preview", DescriptionOfChanges);
	View.markdownConvert();
EndProcedure


&AtClient
Procedure ChangesDescriptionOnClick(Item, EventData, StandardProcessing)
	StandardProcessing = False;
	
	If ValueIsFilled(EventData.href) Then
		UT_CommonClient.OpenURL(EventData.href);
	EndIf;
EndProcedure
#EndRegion

#Region FormTableItemsEventHandlers

// Code of procedures and functions

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure Update(Command)
	If UpdateViaDownloadOfDistributionPackage Then
		UpdateViaFileDownload();
	Else
		UpdateViaExtensionUpdate();
	EndIf;
EndProcedure


#EndRegion

#Region Private

&AtServer
Procedure SetTextFieldChanges()
	LibraryShowdown= GetCommonTemplate("UT_showdown");
	LibraryAddress = PutToTempStorage(LibraryShowdown, UUID);
	
	StyleCSS= 
	"
	|h2, .wiki h1 {font-size: 20px;}
	|h3, .wiki h2 {font-size: 16px;}
	|h4, .wiki h3 {font-size: 13px;}
	|
	|
	|/***** Wiki *****/
	|div.wiki table {
	|  border-collapse: collapse;
	|  margin-bottom: 1em;
	|}
	|
	|div.wiki table, div.wiki td, div.wiki th {
	|  border: 1px solid #bbb;
	|  padding: 4px;
	|}
	|
	|div.wiki th{
	|	background-color: #EEEEEE;
	|}
	|
	|div.wiki .wiki-class-noborder, div.wiki .wiki-class-noborder td, div.wiki .wiki-class-noborder th {border:0;}
	|
	|div.wiki .external {
	|  background-position: 0% 60%;
	|  background-repeat: no-repeat;
	|  padding-left: 12px;
	|}
	|
	|div.wiki a {word-wrap: break-word;}
	|div.wiki a.new {color: #b73535;}
	|
	|div.wiki ul, div.wiki ol {margin-bottom:1em;}
	|div.wiki li>ul, div.wiki li>ol {margin-bottom: 0;}
	|
	|div.wiki pre {
	|  margin: 1em 1em 1em 1.6em;
	|  padding: 8px;
//	|  background-color: #fafafa;
	|  border: 1px solid #e2e2e2;
	|  border-radius: 3px;
	|  width:auto;
	|  overflow-x: auto;
	|  overflow-y: hidden;
	|}
	|
	|div.wiki ul.toc {
	|  background-color: #ffffdd;
	|  border: 1px solid #e4e4e4;
	|  padding: 4px;
	|  line-height: 1.2em;
	|  margin-bottom: 12px;
	|  margin-right: 12px;
	|  margin-left: 0;
	|  display: table
	|}
	|* html div.wiki ul.toc { width: 50%; } /* IE6 doesn't autosize div */
	|
	|div.wiki ul.toc.right { float: right; margin-left: 12px; margin-right: 0; width: auto; }
	|div.wiki ul.toc.left  { float: left; margin-right: 12px; margin-left: 0; width: auto; }
	|div.wiki ul.toc ul { margin: 0; padding: 0; }
	|div.wiki ul.toc li {list-style-type:none; margin: 0; font-size:12px;}
	|div.wiki ul.toc>li:first-child {margin-bottom: .5em; color: #777;}
	|div.wiki ul.toc li li {margin-left: 1.5em; font-size:10px;}
	|div.wiki ul.toc a {
	|  font-size: 0.9em;
	|  font-weight: normal;
	|  text-decoration: none;
	|  color: #606060;
	|}
	|div.wiki ul.toc a:hover { color: #c61a1a; text-decoration: underline;}
	|
	|a.wiki-anchor { display: none; margin-left: 6px; text-decoration: none; }
	|a.wiki-anchor:hover { color: #aaa !important; text-decoration: none; }
	|h1:hover a.wiki-anchor, h2:hover a.wiki-anchor, h3:hover a.wiki-anchor { display: inline; color: #ddd; }
	|
	|div.wiki img {vertical-align:middle; max-width:100%;}
	|blockquote { font-style: italic; border-left: 3px solid #e0e0e0; padding-left: 0.6em; margin-left: 0;}
	|blockquote blockquote { margin-left: 0;}
	|
	|";

	ChangesDescription= 
	"<html>
	|<head>
	|	<meta charset=""UTF-8"">
	|    <style>
	|    	html { 
	|			word-break: break-all;
	|    	}
	|		" + StyleCSS + "
	|    </style>	
	|	 
	|</head>
	|    
	|<body>
	|    <div id=""wiki-container""></div>
	|    <button id=""interactionButton"" style=""display: none"">Кнопка взаимодействия</button>
	|	 	<script src=""" + LibraryAddress + """ type=""text/javascript"" charset=""utf-8""></script>
	|    <script>
	|		 
	|        var markdownTexts={};
	|		 var converter = new showdown.Converter();
	|	     converter.setFlavor('github');
	|
	|	     function clearTexts(){
	|            markdownTexts={};
	|        }
	|
	|        function addText(key, text){
	|            markdownTexts[key]=text;
	|        }
	|        function deleteText(key){
	|            delete markdownTexts[key];
	|        }
	|	     function convertOneText(key,text){
	|           
	|			 var newdiv = document.createElement('div');
	|            newdiv.className = 'wiki';
	|            newdiv.id = key;
	|
	|           newdiv.innerHTML = converter.makeHtml(text);
	|
	|           return newdiv;
	|      	 }
	|        
	|		 function mdToHtml(text){
	|           return converter.makeHtml(text);
	|      	 }
	|		 function htmlToMd(text){
	|           return converter.makeMarkdown(text);
	|      	 }
	|        function markdownConvert(){
	|            var container=document.getElementById('wiki-container');
	|            container.innerHTML='';
	|
	|            for (var key in markdownTexts) {
	|                if (markdownTexts.hasOwnProperty(key)) {
	|                    var markText = markdownTexts[key];
	|                    
	|                	 var newdiv=convertOneText(key,markText);
	|						
	|                    container.appendChild(newdiv);
	|                }
	|            }
	|  			var elems= document.getElementsByTagName('code');
	|			
	|			 for(var i = 0; i < elems.length; i++) {
	|				hljs.highlightBlock(elems[i]);
	|			}			
	|
	|        }
	|
	|    </script>

	|</body>
	|
	|    
	|</html>
	|";
	
EndProcedure



&AtClient 
Procedure UpdateViaFileDownload()
	FileName=UT_CommonClientServer.DownloadFileName();
	FileNameArray=UT_StringFunctionsClientServer.SplitStringIntoSubstringsArray(FileName, ".");
	FileExtention=FileNameArray[FileNameArray.Count()-1];
	
	
	FileDialog=New FileDialog(FileDialogMode.Save);
	FileDialog.Extension=FileExtention;
	FileDialog.Filter=StrTemplate(NStr("ru = 'Файл новой версии универсальных инструментов|*.%1';en = 'The file of the new version of universal tools|*.%1'"),FileExtention);
	FileDialog.Multiselect=False;
	FileDialog.FullFileName=FileName;
	FileDialog.Show(New NotifyDescription("UpdateViaFileDownloadEndFileNameChoose", ThisObject));
EndProcedure

&AtClient 
Procedure UpdateViaFileDownloadEndFileNameChoose(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles=Undefined Then
		Return;
	EndIf;
	
	BinaryData=DownloadedBinaryUpdateData();
	If BinaryData=Undefined Then
		Message(NStr("ru = 'Не удалось скачать обновление с сайта обновления';en = 'Failed to download the update from the update site'"));
		Return;
	EndIf;
	
	If TypeOf(BinaryData)<>Type("BinaryData") Then
		Return;
	EndIf;
		
	BinaryData.BeginWriting(New NotifyDescription("UpdateViaFileDownloadEndFileWrite", ThisObject), SelectedFiles[0]);
	
EndProcedure	

&AtClient 
Procedure UpdateViaFileDownloadEndFileWrite(AdditionalParameters) Export
	ShowMessageBox(, Nstr("ru = 'Файл успешно скачан';en = 'File downloaded successfully'"));
EndProcedure

&AtClient
Procedure UpdateViaExtensionUpdate()
	UpdateResult=ResultUpdateViaExtensionAtServer();

	If UpdateResult = Undefined Then
		ShowQueryBox(New NotifyDescription("UpdateViaExtensionUpdateOnEnd", ThisObject),Nstr("ru = 'Обновление успешно применено. Для использования изменений нужно перезапустить сеанс. Перезапустить?';
		|en = 'The update was successfully applied. To use the changes, you need to restart the session. Restart?'"),
			QuestionDialogMode.YesNo);
	Else
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Ошибка применения обновления %1';en = 'Update application error %1'"),UpdateResult));
	EndIf;
EndProcedure

&AtClient
Procedure UpdateViaExtensionUpdateOnEnd(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.None Then
		Return;
	EndIf;

	Exit(False, True);
EndProcedure

&AtServer
Function DownloadedBinaryUpdateData()
	Response=UT_HTTPConnector.Get(ActualVersionURL);

	If Response.StatusCode > 300 Then
		Return Undefined;
	EndIf;

	Return Response.Body;
	
EndFunction

&AtServer
Function ResultUpdateViaExtensionAtServer()
	BinaryData=DownloadedBinaryUpdateData();
	
	If BinaryData=Undefined Then
		Return NStr("ru = 'He удалось скачать файл обновления с сервера';en = 'Failed to download the update file from the server'");
	EndIf;

	If TypeOf(BinaryData) <> Type("BinaryData") Then
		Return NStr("ru = 'Неправильный формат файла обновления';en = 'Incorrect update file format'");
	EndIf;

	Filter = New Structure;
	Filter.Insert("Name", "UniversalTools");

	FoundExtensions = ConfigurationExtensions.Get(Filter);

	If FoundExtensions.Count() = 0 Then
		Return Nstr("ru = 'Не обнаружено расширение Универсальные инструменты';en = 'Universal Tools extension not found'")
	EndIf;

	OurExtension = FoundExtensions[0];
	
	// Let's check the possibility of using the extension

	CheckResult=OurExtension.CheckCanApply(BinaryData, False);

	If CheckResult.Count() > 0 Then
		MessageAboutErrors="";
		For Each ConfigurationExtensionApplicationIssueInformation In CheckResult Do
			MessageAboutErrors=MessageAboutErrors + ?(ValueIsFilled(MessageAboutErrors), Chars.LF, "") + NSTR("ru = 'Ошибка применения расширения';
			|en = 'Extension apply error'") + ConfigurationExtensionApplicationIssueInformation.Description;
		EndDo;

		Return MessageAboutErrors;
	EndIf;

	UpdateResult=Undefined;
	Try
		OurExtension.Write(BinaryData);
	Except
		UpdateResult=ErrorDescription();
	EndTry;

	Return UpdateResult;

EndFunction

&AtServer
Procedure FillCurrentVersion()
	CurrentVersion = UT_CommonClientServer.Version();
	DistributionType=UT_CommonClientServer.DistributionType();
	DownloadFileName=UT_CommonClientServer.DownloadFileName();
	UpdateViaDownloadOfDistributionPackage=Not StrEndsWith(Lower(DownloadFileName), "cfe");
EndProcedure

&AtServer
Procedure FillActualVersionAndChangesDescription()
//Getting a list of all releases
	RequestUrl = "https://api.github.com/repos/i-neti/tools_ui_1c_international/releases";
	DownloadFileName=UT_CommonClientServer.DownloadFileName();
	
	ReleasesArray = UT_HTTPConnector.GetJson(RequestUrl);

	MaxRelease = "0.0.0";
//	ReleasesDescriptionMap = New Map;

	DescriptionOfChanges = "";
	
	For Each CurrentRelease In ReleasesArray Do
		CurrentReleaseVersion = StrReplace(CurrentRelease["tag_name"], "v", "");

		If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(CurrentReleaseVersion, CurrentVersion) > 0 Then
//			ReleasesDescriptionMap.Insert(CurrentReleaseVersion, CurrentRelease);
					
			DescriptionOfChanges = DescriptionOfChanges + "# [" + CurrentReleaseVersion + "](" + CurrentRelease["html_url"] + ")" + Chars.LF;
			DescriptionOfChanges = DescriptionOfChanges + CurrentRelease["body"] + Chars.LF;
		EndIf;

		If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(CurrentReleaseVersion, MaxRelease) <= 0 Then
			Continue;
		EndIf;

		MaxRelease = CurrentReleaseVersion;
		ReleaseAssets = CurrentRelease["assets"];
		If ReleaseAssets = Undefined Then
			ActualVersionURL = "";
		Else
			For Each CurrentAsset In ReleaseAssets Do
				ReleaseFileName = CurrentAsset["name"];

				If StrFind(Lower(ReleaseFileName), Lower(DownloadFileName)) = 0 Then
					Continue;
				EndIf;

				ActualVersionURL=CurrentAsset["browser_download_url"];
				Break;
			EndDo;
		EndIf;
		
		
	EndDo;

	ActualVersion = MaxRelease;
EndProcedure

&AtServer
Procedure SetNeedForUpdate()
	If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(ActualVersion, CurrentVersion) > 0 Then
		NeedForUpdate = True;
	EndIf;

	Items.FormUpdate.Visible = NeedForUpdate;
	Items.ChangesDescription.Visible = NeedForUpdate;
	
	If UpdateViaDownloadOfDistributionPackage Then
		Items.FormUpdate.Title = NStr("ru = 'Скачать';en = 'Download'");
	EndIf;
EndProcedure


#EndRegion

