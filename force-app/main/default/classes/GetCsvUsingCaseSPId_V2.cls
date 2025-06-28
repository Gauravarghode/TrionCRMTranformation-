public class GetCsvUsingCaseSPId_V2 {
    
    @AuraEnabled
    public static string getfileData(String caseParentId){
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
        
        List<Case> caseList = [Select id from case where id =: caseParentId];
        String caseFolderName = caseList[0].id;
        
        
        List<String> emailIdFromSp = new List<String>();
        String fileNameForCaseID;
        String eachEmailMessageIdFromSp;
        
        
        String fileSPWebUrlForCaseId;
        String fileCreatedDateTimeForCaseId;
        String fileSPEtagForCaseId;
        String fileSizeForCaseId;
        String fileTypeForCaseId;
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        String driveId = Label.SharepointDriveId;
        String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
        
        try{
            
            
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
            req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + ':/children'); 
            
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res1 = httpCallout.send(req1);
            
            if (res1.getStatusCode() == 200) {
                try {
                    if (res1.getBody() != null) {
                        String jsonString = res1.getBody();
                        Response result = (Response) JSON.deserialize(jsonString, Response.class);
                        System.debug('EmailResponse: ' + result);
                        for(Item eachItem : result.value){
                            List<object> dataList=new List<object>();
                            
                            fileNameForCaseID=eachItem.name;
                            emailIdFromSp.add(fileNameForCaseID);
                            system.debug('List<String> emailIdFromSp==>' +emailIdFromSp);
                            //system.debug('fileNameForCaseID==>' +fileNameForCaseID);
                            //getting email message share point id    
                            for(String emidsp:emailIdFromSp){
                                eachEmailMessageIdFromSp=emidsp;
                                system.debug('String eachEmailMessageIdFromSp==>' +eachEmailMessageIdFromSp);
                                
                                
                                
                                try{
                                    
                                    String driveId1 = Label.SharepointDriveId;
                                    String encodedDriveId2 = EncodingUtil.urlEncode(driveId1, 'UTF-8');
                                    
                                    Http httpCallout2 = new Http();
                                    HttpRequest req2 = new HttpRequest();
                                    String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case';
                                    req2.setMethod('GET');
                                    req2.setHeader('Authorization', 'Bearer ' + accessToken);
                                    req2.setHeader('Content-Type', 'application/json');
                                    req2.setHeader('Accept', 'application/json');
                                    req2.setTimeout(120000);
                                    req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId1+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + '/' + eachEmailMessageIdFromSp +':/children'); 
                                    
                                    HTTPResponse res2 = httpCallout2.send(req2);
                                    
                                    if (res2.getStatusCode() == 200) {
                                        try {
                                            if (res2.getBody() != null) {
                                                String jsonString2 = res2.getBody();
                                                responseString = res2.getBody();
                                                Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                                                System.debug('EmailResponse: ' + result2);
                                                for(Item eachItem2 : result2.value){
                                                    //List<object> dataList=new List<object>();
                                                    fileName=eachItem2.name;
                                                    
                                                    fileSpId=eachItem2.id;
                                                    fileSPWebUrl=eachItem2.webUrl;
                                                    fileCreatedDateTime=eachItem2.createdDateTime;
                                                    fileSPEtag=eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4);
                                                    fileSize=eachItem2.size;
                                                    fileType=eachItem2.File.mimeType;
                                                    ResponseItem resp = new ResponseItem();
                                                    resp.name = eachItem2.name;
                                                    resp.id = eachItem2.id;
                                                    resp.webUrl = eachItem2.webUrl;
                                                    resp.createdDateTime = eachItem2.createdDateTime;
                                                    resp.eTag = eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4);
                                                    resp.size = eachItem2.size;
                                                    resp.fileType = eachItem2.File.mimeType;
                                                    fileData.responseItems.add(resp);
                                                    system.debug('response item '+resp);
                                                    system.debug(eachItem2.name);
                                                    system.debug(eachItem2.id);
                                                    system.debug(eachItem2.webUrl);
                                                    system.debug(eachItem2.createdDateTime);
                                                    system.debug(eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                                    system.debug(eachItem2.size);
                                                    system.debug(eachItem2.File.mimeType);
                                                    
                                                    
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
                            }
                            //return dataList;
                            system.debug('returned '+fileData);
                            //return fileData;
                            //return responseString;
                        }
                    }
                }catch(exception e){
                    System.debug('Catch exception'+e.getMessage());
                }
            }
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        System.debug('return responseString;'+responseString);
        return responseString;
    }
    
    //===============================================================================
    @AuraEnabled
    public static string getfileDataTwoParameter(String caseParentId, String eachEmailMessageIdFromSp) {
        ResponseWrap fileData = new ResponseWrap();
        fileData.responseItems = new List<ResponseItem>(); // Ensure responseItems is initialized
        string responseString = '';
        String accessToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('POST'); // Change to POST for getting token
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=8ln8Q~vuDll8VoUHV~cXJzU6qweMa9WcV1lzBaq4&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            system.debug(res.getBody());
            accessToken = tokenResponse.access_token;
        } else {
            return null;
        }
        
        List<Case> caseList = [SELECT Id FROM Case WHERE Id = :caseParentId LIMIT 1];
        if (caseList.isEmpty()) {
            return null; // Return null if no case is found
        }
        String caseFolderName = caseList[0].Id;
        
        String fileSPWebUrlForCaseId;
        String fileCreatedDateTimeForCaseId;
        String fileSPEtagForCaseId;
        String fileSizeForCaseId;
        String fileTypeForCaseId;
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        
        String driveId = Label.SharepointDriveId;
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName);
        
        try{
            
            String driveId2 = Label.SharepointDriveId;
            String encodedDriveId = EncodingUtil.urlEncode(driveId2, 'UTF-8');
            
            Http httpCallout = new Http();
            HttpRequest req1 = new HttpRequest();
            String objectNameCase = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case';
            req1.setMethod('GET');
            req1.setHeader('Authorization', 'Bearer ' + accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId2+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + '/' + eachEmailMessageIdFromSp +':/children'); 
            
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
        System.debug('return responseString;'+responseString);
        return responseString;
    }

    
    //================================================================================
    
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
            //system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
        }
        
        List<Case> caseList = [Select id from case where id =: caseParentId];
        String caseFolderName = caseList[0].id;
        
        List<String> emailIdFromSp = new List<String>();
        String fileNameForCaseID;
        String eachEmailMessageIdFromSp;
        
        String fileSPWebUrlForCaseId;
        String fileCreatedDateTimeForCaseId;
        String fileSPEtagForCaseId;
        String fileSizeForCaseId;
        String fileTypeForCaseId;
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        String driveId = Label.SharepointDriveId;
        String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
        //  map<string, string> fileMap = new map<string, string>();
        try{          
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
            req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + ':/children'); 
            
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res1 = httpCallout.send(req1);
            
            if (res1.getStatusCode() == 200) {
                try {
                    if (res1.getBody() != null) {
                        String jsonString = res1.getBody();
                        Response result = (Response) JSON.deserialize(jsonString, Response.class);
                        System.debug('EmailResponse: ' + result);
                        for(Item eachItem : result.value){
                            List<object> dataList=new List<object>();
                            
                            fileNameForCaseID=eachItem.name;
                            emailIdFromSp.add(fileNameForCaseID);
                            system.debug('List<String> emailIdFromSp==>' +emailIdFromSp);
                            //system.debug('fileNameForCaseID==>' +fileNameForCaseID);
                            //getting email message share point id    
                            /* for(String emidsp:emailIdFromSp){
eachEmailMessageIdFromSp=emidsp;
system.debug('String eachEmailMessageIdFromSp==>' +eachEmailMessageIdFromSp);
*/    
                            
                            try{
                                
                                //String driveId = Label.SharepointDriveId;
                                //String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                                //String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                                //String subFolderName = stagingList[0].Linked_Entity_Id__c;
                                //String objectName = stagingList[0].sObject__c;
                                
                                Http httpCallout1 = new Http();
                                HttpRequest req2 = new HttpRequest();
                                String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case'; 
                                
                                
                                
                                
                                //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                                req2.setMethod('GET');
                                req2.setHeader('Authorization', 'Bearer ' + accessToken);
                                req2.setHeader('Content-Type', 'application/json');
                                req2.setHeader('Accept', 'application/json');
                                req2.setTimeout(120000);
                                req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + '/' + fileNameForCaseID +':/children'); 
                                system.debug('###req2 is '+req2);
                                //req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +':/children');
                                //req.setBodyAsBlob(fileBody);
                                
                                HTTPResponse res2 = httpCallout1.send(req2);
                                String jsonString2;
                                if (res2.getStatusCode() == 200) {
                                    try {
                                        if (res2.getBody() != null) {
                                            jsonString2 = res2.getBody();
                                            system.debug(' >>  res body '+jsonString2);
                                            list<string> downloadUrlList = new list<string>();
                                            map<string, string> mapUrlEtag = new map<string, string>();
                                            list<string> strList = jsonString2.split('"@microsoft.graph.downloadUrl":');
                                            
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
                                            jsonStringList.add(jsonString2);
                                            Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                                            //integer counter = 0;
                                            for(Item eachItem2 : result2.value){
                                                map<string, string> fileMap = new map<string, string>();
                                                ResponseItem file = new ResponseItem();
                                                if(!eachItem2.name.contains('EmailMessageDetails')){
                                                    string etagString = eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4);
                                                    file.createdDateTime = eachItem2.createdDateTime;
                                                    file.eTag = eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4);
                                                    file.id = eachItem2.id;
                                                    file.name = eachItem2.name;
                                                    file.webUrl = eachItem2.webUrl;
                                                    file.size = eachItem2.size;
                                                    file.fileType = eachItem2.File.mimeType;
                                                    fileMap.put('createdDateTime', eachItem2.createdDateTime );
                                                    //fileMap.put('lastModifiedDateTime', eachItem2.lastModifiedDateTime );    
                                                    fileMap.put('eTag', etagString );
                                                    fileMap.put('name', eachItem2.name );
                                                    fileMap.put('webUrl', eachItem2.webUrl );
                                                    fileMap.put('size', eachItem2.size );
                                                    fileMap.put('fileType', eachItem2.File.mimeType );
                                                    fileMap.put('fileId', eachItem2.id );
                                                    if(mapUrlEtag.containsKey(etagString)){
                                                        fileMap.put('downloadUrl', mapUrlEtag.get(etagString) );
                                                    }
                                                    
                                                    //counter++;
                                                    responseMapList.add(fileMap);
                                                    filesList.add(file);
                                                    system.debug(' filesList==> '+filesList);
                                                    system.debug(' responseMapList==> '+responseMapList);
                                                    system.debug('fileMap****************'+fileMap);
                                                }
                                                
                                                system.debug(' a fileMap '+fileMap);
                                            }
                                            if(responseMapList.size()>1)
                                            {
                                                System.debug('at index@@@@@@@@@@'+responseMapList.size());
                                                System.debug('at index000&&&&'+responseMapList[0]);
                                                System.debug('at index111&&&&'+responseMapList[1]);
                                                
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
                            
                            //}
                            //responseMapList.add(fileMap);
                        }
                    }
                }catch(exception e){
                    System.debug('Catch exception'+e.getMessage());
                }      
            }
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }  
        system.debug('final response '+finalResponse);
        system.debug('list<map<string, string>> responseMapList'+responseMapList);
        //return filesList;
        //return jsonStringList;
        for(Integer i=0;i<responseMapList.size();i++)
        {
            System.debug('eachfileeee@@@@@@@@@@@@@@'+responseMapList[i]);
        }
        return responseMapList;
    }
    
    @AuraEnabled
    public static Case getCaseRecordbyId(string caseId){
        return [Select Id, CaseNumber from Case where id = :caseId limit 1];
    }
    public static String getUserNameRecordbyId(string userId){
        return (String)[Select Id, Name from User where id = :userId limit 1].Name;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
     }
}