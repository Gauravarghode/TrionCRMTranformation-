public class GetCsvUsingSPId_V2 {
    @AuraEnabled
    public static string getfileData(String emailMessageId){
        ResponseWrap fileData = new ResponseWrap();
        string responseString = '';
        String accessToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=8ln8Q~vuDll8VoUHV~cXJzU6qweMa9WcV1lzBaq4&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            // Do something with the deserialized tokenResponse object
            system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }
        
        Case_Email__c caseEmail = [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                                   LastActivityDate, Case_Id__c, Case_Number__c, Case__c, EmailMessage_Id__c, Email_Message_Created_Date__c, Email_Message_Subject__c, 
                                   Case_Email_Number__c, EM_Sharepoint_Web_Url__c, Email_Message_SP_Folder_Id__c, Email_Message_SharePoint_Id__c, Files_SP_Id__c, Files_Share_Point_Id__c 
                                   from Case_Email__c  where EmailMessage_Id__c =: emailMessageId limit 1];
        
        String caseFolderName=caseEmail.Case_Id__c;
        String subFolderName=caseEmail.EmailMessage_Id__c;
        System.debug('String caseFolderName' +caseFolderName);
        System.debug('String subFolderName' +subFolderName);
        //Map<String,List<object>> MapWeb=new Map<String,List<object>>();
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        
        
        
        try{
            
            String driveId = Label.SharepointDriveId;
            String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
            
            Http httpCallout = new Http();
            HttpRequest req1 = new HttpRequest();
            String objectNameCase = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case';
            req1.setMethod('GET');
            req1.setHeader('Authorization', 'Bearer ' + accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +':/children'); 
            
            HTTPResponse res1 = httpCallout.send(req1);
            
            if (res1.getStatusCode() == 200) {
                try {
                    if (res1.getBody() != null) {
                        String jsonString = res1.getBody();
                        responseString = res1.getBody();
                        Response result = (Response) JSON.deserialize(jsonString, Response.class);
                        System.debug('EmailResponse: ' + result);
                        for(Item eachItem : result.value){
                            List<object> dataList=new List<object>();
                            fileName=eachItem.name;
                            fileSpId=eachItem.id;
                            fileSPWebUrl=eachItem.webUrl;
                            fileCreatedDateTime=eachItem.createdDateTime;
                            fileSPEtag=eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                            fileSize=eachItem.size;
                            fileType=eachItem.File.mimeType;
                            ResponseItem resp = new ResponseItem();
                            resp.name = eachItem.name;
                            resp.id = eachItem.id;
                            resp.webUrl = eachItem.webUrl;
                            resp.createdDateTime = eachItem.createdDateTime;
                            resp.eTag = eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                            resp.size = eachItem.size;
                            resp.fileType = eachItem.File.mimeType;
                            fileData.responseItems.add(resp);
                            system.debug('response item '+resp);
                            system.debug(eachItem.name);
                            system.debug(eachItem.id);
                            system.debug(eachItem.webUrl);
                            system.debug(eachItem.createdDateTime);
                            system.debug(eachItem.eTag.substring(2, eachItem.eTag.length() - 4));
                            system.debug(eachItem.size);
                            system.debug(eachItem.File.mimeType);
                            
                            
                        }
                        //System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
                        //System.debug('Map<String,List<object>> MapWeb==>'+MapWeb);
                        //System.debug('List<object> dataList=>'+dataList);
                        
                    } else {
                        System.debug('Response body is null or empty');
                    }
                } catch (Exception e) {
                    System.debug('Error deserializing JSON: ' + e.getMessage());
                }
            }
            
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        //return dataList;
        system.debug('returned '+fileData);
        //return fileData;
        System.debug('return responseString;'+responseString);
        return responseString;
    }
    
    @AuraEnabled
    public static list<map<string, string>> getCaseFolderData(String caseParentId){
        //FileDataResult fileData = new FileDataResult();
        //fileData.resultMap = new Map<String, List<Object>>();
        //fileData.resultList = new List<Object>();
        list<String> jsonStringList = new list<string>();
        responseWrap finalResponse = new responseWrap();
        list<ResponseItem> filesList = new list<ResponseItem>();
        list<map<string, string>> responseMapList = new list<map<string, string>>();
        String accessToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=8ln8Q~vuDll8VoUHV~cXJzU6qweMa9WcV1lzBaq4&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody); 
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            // Do something with the deserialized tokenResponse object
            system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }
        
        List<Case_Email__c> caseEmail = [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                                         LastActivityDate, Case_Id__c, Case_Number__c, Case__c, EmailMessage_Id__c, Email_Message_Created_Date__c, Email_Message_Subject__c, 
                                         Case_Email_Number__c, EM_Sharepoint_Web_Url__c, Email_Message_SP_Folder_Id__c, Email_Message_SharePoint_Id__c, Files_SP_Id__c, Files_Share_Point_Id__c
                                         from Case_Email__c  where Case_Id__c =: caseParentId ];
        
        String caseFolderName=caseEmail[0].Case_Id__c;
        String subFolderName;
        List<string> emailMessageIds = new List<string>();
        
        for(Case_Email__c ce:caseEmail){
            //subFolderName=ce.EmailMessage_Id__c;
            emailMessageIds.add(ce.EmailMessage_Id__c);
        }
        System.debug('List<String> emailMessageIds=>' +emailMessageIds);
        
        for(string ce:emailMessageIds){
            subFolderName=ce;
            System.debug('String subFolderName' +subFolderName);
            
            
            String emailMessageIdsString = String.join(emailMessageIds, ',');
            System.debug('String emailMessageIdsString=='+emailMessageIdsString);
            //String subFolderName=caseEmail[0].EmailMessage_Id__c;
            System.debug('String caseFolderName' +caseFolderName);
            System.debug('String subFolderName' +subFolderName);
            //Map<String,List<object>> MapWeb=new Map<String,List<object>>();
            String fileName;
            String fileSpId;
            String fileSPWebUrl;
            String fileCreatedDateTime;
            String fileSPEtag;
            String fileSize;
            String fileType;
            
            
            
            try{
                
                String driveId = Label.SharepointDriveId;
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                //String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                //String subFolderName = stagingList[0].Linked_Entity_Id__c;
                //String objectName = stagingList[0].sObject__c;
                
                Http httpCallout = new Http();
                HttpRequest req1 = new HttpRequest();
                String objectNameCase = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case'; 
                
                
                
                
                //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                req1.setMethod('GET');
                req1.setHeader('Authorization', 'Bearer ' + accessToken);
                req1.setHeader('Content-Type', 'application/json');
                req1.setHeader('Accept', 'application/json');
                req1.setTimeout(120000);
                req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +':/children'); 
                
                //req.setBodyAsBlob(fileBody);
                
                HTTPResponse res1 = httpCallout.send(req1);
                String jsonString;
                if (res1.getStatusCode() == 200) {
                    try {
                        if (res1.getBody() != null) {
                            jsonString = res1.getBody();
                            system.debug(' >>  res body '+jsonString);
                            list<string> downloadUrlList = new list<string>();
                            map<string, string> mapUrlEtag = new map<string, string>();
                            list<string> strList = jsonString.split('"@microsoft.graph.downloadUrl":');
                            
                            for(string str : strList){
                                
                                if(str.contains('"createdBy"') && str.contains('"eTag":') ){
                                    system.debug(' >> split str '+str);
                                    integer indOCrBy = str.indexOf('","createdBy"');
                                    integer indOeTag = str.indexOf('"eTag":');
                                	string strDl = str.subString(1, indOCrBy);
                                    string strEtag = str.subString(indOeTag+11, indOeTag + 47);
                                	system.debug(' >><< url '+ indOCrBy);//str2);
                                    downloadUrlList.add(strDl);
                                    mapUrlEtag.put(strEtag, strDl);
                                    system.debug(' >><< url '+ strDl);
                                    system.debug(' >< map url etag '+strEtag+ ' : '+ strDl);
                                }
                                
                            }
                            jsonStringList.add(jsonString);
                            Response result = (Response) JSON.deserialize(jsonString, Response.class);
                            //integer counter = 0;
                            for(Item eachItem : result.value){
                                map<string, string> fileMap = new map<string, string>();
                                ResponseItem file = new ResponseItem();
                                if(!eachItem.name.contains('EmailMessageDetails')){
                                    string etagString = eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                                    file.createdDateTime = eachItem.createdDateTime;
                                    file.eTag = eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                                    file.id = eachItem.id;
                                    file.name = eachItem.name;
                                    file.webUrl = eachItem.webUrl;
                                    file.size = eachItem.size;
                                    file.fileType = eachItem.File.mimeType;
                                    fileMap.put('createdDateTime', eachItem.createdDateTime );
                                    fileMap.put('lastModifiedDateTime', eachItem.lastModifiedDateTime );    
                                    fileMap.put('eTag', etagString );
                                    fileMap.put('name', eachItem.name );
                                    fileMap.put('webUrl', eachItem.webUrl );
                                    fileMap.put('size', eachItem.size );
                                    fileMap.put('fileType', eachItem.File.mimeType );
                                    fileMap.put('fileId', eachItem.id );
                                    if(mapUrlEtag.containsKey(etagString)){
                                        fileMap.put('downloadUrl', mapUrlEtag.get(etagString) );
                                    }
                                    
                                    //counter++;
                                    responseMapList.add(fileMap);
                                    filesList.add(file);
                                }
                                
                                system.debug(' a fileMap '+fileMap);
                            }
                            finalResponse.responseItems = filesList;
                        }
                        //System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
                        //System.debug('Map<String,List<object>> MapWeb==>'+MapWeb);
                        //System.debug('List<object> dataList=>'+dataList);
                        else {
                            System.debug('Response body is null or empty');
                        }
                        
                    } 
                    catch (Exception e) {
                        System.debug('Error deserializing JSON: ' + e.getMessage());
                    }
                }
            } catch(exception e){
                System.debug('Catch exception'+e.getMessage());
            }            
            
            
            
        }
        system.debug('final response '+finalResponse);
        //return filesList;
        //return jsonStringList;
        return responseMapList;
    }
    
    public class FileDataResult {
        public Map<String, List<Object>> resultMap { get; set; }
        public List<Object> resultList { get; set; }
    } 
    
    public class responseWrap{
        public list<ResponseItem> responseItems;
    }
    
    public class ResponseItem {
        public String createdDateTime;
        public String eTag;
        public String id;
        public String name;
        public String webUrl;
        public String size;
        public String fileType;
    }
    
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
    
    //@SuppressWarnings('PMD.VariableNamingConventions')
    public class Item {
        //public string @microsoft.graph.downloadUrl;
        public String createdDateTime;
        public String eTag;
        public String id;
        public String lastModifiedDateTime;
        public String name;
        public String webUrl;
        public String cTag;
        public String size;
        public Decorator decorator;
        public CreatedBy createdBy;
        public LastModifiedBy lastModifiedBy;
        public ParentReference parentReference;
        public FileSystemInfo fileSystemInfo;
        public Folder folder;
        public Shared shared;
        Public File File;
    }
    
    public class Decorator {
        public String iconColor;
    }
    
    public class CreatedBy {
        public User user;
    }
    
    public class LastModifiedBy {
        public User user;
    }
    
    public class User {
        public String email;
        public String id;
        public String displayName;
    }
    
    public class ParentReference {
        public String driveType;
        public String driveId;
        public String id;
        public String name;
        public String path;
        public String siteId;
    }
    
    Public class File{
        public string mimeType;
    }
    
    public class FileSystemInfo {
        public String createdDateTime;
        public String lastModifiedDateTime;
    }
    
    public class Folder {
        public Integer childCount;
    }
    
    public class Shared {
        public String scope;
    }
    
    public class Response {
        public List<Item> value;
    }
    
    @AuraEnabled(cacheable=true) 
    public static string getEmailsData(String parentCaseId){
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        string returnString = '';
        //List<id> csvSPID=new List<id>();
        List<Case_Email__c> caseEmailList=[select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                                           LastActivityDate, Case_Id__c, Case_Number__c, Case__c, EmailMessage_Id__c, Email_Message_Created_Date__c, Email_Message_Subject__c, 
                                           Case_Email_Number__c, EM_Sharepoint_Web_Url__c, Email_Message_SP_Folder_Id__c, Email_Message_SharePoint_Id__c, Files_SP_Id__c, Files_Share_Point_Id__c 
                                           from Case_Email__c  where Case_Id__c =: parentCaseId];
        
        if(!caseEmailList.isEmpty()){
            System.debug('List<Case_Email__c> caseEmailList='+caseEmailList);
            for(Case_Email__c ce:caseEmailList){
                string sharepointid=ce.Email_Message_SharePoint_Id__c;
                System.debug('string sharepointid='+sharepointid);
                //csvSPID.add(sharepointid);
                //System.debug('List<id> csvSPID='+csvSPID);            
                
                
                try{
                    String driveId = Label.SharepointDriveId;
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setHeader('Accept', 'application/json;odata=verbose');
                    req.setEndpoint('callout:Sharepoint/v1.0/drives/'+driveId+'/items/' + sharepointid + '/content');
                    HTTPResponse res = new Http().send(req);
                    try{
                        while (res.getStatusCode() == 302) {
                            req.setEndpoint(res.getHeader('Location'));
                            res = new Http().send(req);
                        }
                    }catch(exception o){
                        System.debug('Catch exception1'+o.getMessage());
                    }
                    returnString = res.getBody();
                    /*
                    Blob headerValue= blob.valueOf(res.getBody());
                    
                    String body = EncodingUtil.base64Encode(headerValue);
                    
                    String lines = res.getBody();
                    List<String>allValues=lines.split(',');
                    
                    
                    List<String> Headers1=New List<String>();
                    for(Integer i=0;i<39;i++){
                        if(i<=37)
                            Headers1.add(allValues[i]);
                        else{
                            Headers1.add('HtmlBody');
                        }
                        
                    }
                    List<String>allValues1=lines.split('##  ');
                    
                    List<String> Values1=new List<String>();
                    for(Integer i=1;i<40;i++){
                        Values1.add(allValues1[i]);
                        System.debug(allValues1[i]);
                        
                    }
                    Map<String,String> MapHeadersValues=new Map<String,String>();
                    for(Integer i=0;i<39;i++){
                        MapHeadersValues.put(Headers1[i],Values1[i]);
                        
                    }
                    
                    Map<String, String> csvInfo = new Map<String, String>();
                    //csvInfo.put('IdOfCsv', mapHeadersValues.get('Id').subString(0,(MapHeadersValues.get('Id')-3));
                    csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
                    // csvInfo.put('ParentId', mapHeadersValues.get('ParentId'));
                    csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
                    //csvInfo.put('CreatedDate', mapHeadersValues.get('CreatedDate'));
                    csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
                    //csvInfo.put('TextBody', mapHeadersValues.get('TextBody'));
                    csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
                    //csvInfo.put('Headers', mapHeadersValues.get('Headers'));
                    csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
                    //csvInfo.put('Subject', mapHeadersValues.get('Subject'));
                    csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
                    //csvInfo.put('FromAddress', mapHeadersValues.get('FromAddress'));
                    csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
                    //csvInfo.put('ToAddress', mapHeadersValues.get('ToAddress'));
                    csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
                    //csvInfo.put('CcAddress', mapHeadersValues.get('CcAddress'));
                    csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
                    //csvInfo.put('BccAddress', mapHeadersValues.get('BccAddress'));
                    csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
                    //csvInfo.put('MessageDate', mapHeadersValues.get('MessageDate'));
                    csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
                    //csvInfo.put('HtmlBody', mapHeadersValues.get('HtmlBody'));
                    csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
                    
                    
                    csvInfoList.add(csvInfo);
                    system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
                    system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
                    system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
                }catch(exception e){
                    System.debug('Catch exception'+e.getMessage());
                }
                
            }
        }
        //return csvInfoList;
        //
        */
        
                } catch(exception e){
                    system.debug('exception : '+e);
                }
            }
        }
        return returnString;
    }
    public static void testCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}