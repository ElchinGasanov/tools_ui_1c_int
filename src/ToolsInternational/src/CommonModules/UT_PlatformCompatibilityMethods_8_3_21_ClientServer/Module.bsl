//The module contains constructors and methods, 
//the use of which has been added or changed in the platform 8.3.21
//


#Region Public

// New secure connection open SSL
// 
// Return values:
//  OpenSSLSecureConnection -  New secure connection open SSL
Function NewOpenSSLSecureConnection() Export
	//@skip-check type-not-defined
	Return New OpenSSLSecureConnection;	
EndFunction

// New HTTPConnection.
// 
// Parameters:
//  Host - String - Host
//  Port - Undefined, Number -  Port
//  User - Undefined, String -  User
//  Password - Undefined, String -  Password
//  Proxy - Undefined, InternetProxy -  Setting up a proxy
//  Timeout - Number -  Timeout
//  SecureConnection - Undefined, OpenSSLSecureConnection -  Secure connection
//  UseOSAuthentication - Undefined, Boolean -  Use OS authentication
// 
// Return values:
//  HTTPConnection -  New HTTPConnection
//@skip-check method-too-many-params
Function NewHTTPConnection(Host, Port = Undefined, User = Undefined, Password = Undefined,
	Proxy = Undefined, Timeout = 0, SecureConnection = Undefined,
	UseOSAuthentication = Undefined) Export  
	
	If SecureConnection = Undefined Then
		SecureConnectionForConstructor = SecureConnection;
	Else            
		If UT_CommonClientServer.IsWebClient() Then
			SecureConnectionForConstructor = True;	         
		Else
			SecureConnectionForConstructor = SecureConnection;
		EndIf;
	EndIf;
	
	If UseOSAuthentication = Undefined Then
		//@skip-check type-not-defined
		HTTPConnection = New HTTPConnection(Host, Port, , , Proxy, Timeout, SecureConnectionForConstructor);
	Else
		//@skip-check type-not-defined
		HTTPConnection = New HTTPConnection(Host, Port, , , Proxy, Timeout, SecureConnectionForConstructor,
			UseOSAuthentication);
	EndIf;
	
	Return HTTPConnection;
EndFunction

// New HTTPRequest.
// 
// Parameters:
//  ResourceAddress - String - Адрес ресурса
//  Headings - Map of KeyAndValue,Undefined -  Headings
// 
// Return values:
//  HTTPRequest - New HTTPRequest
Function NewHTTPRequest(ResourceAddress, Headings = Undefined) Export
	//@skip-check type-not-defined
	Return New HTTPRequest(ResourceAddress, Headings);
EndFunction

// Кодировка текста по имени.
// 
// Parameters:
//  Name - String - Name
// 
// Return values:
//  TextEncoding
Function TextEncodingByName(Name) Export
	//@skip-check Undefined variable
	Return TextEncoding[Name];
EndFunction

#EndRegion

#Region Internal

// Code of procedures and functions

#EndRegion

#Region Private

// Code of procedures and functions

#EndRegion
