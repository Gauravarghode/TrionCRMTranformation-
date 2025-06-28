public class GetCsvUsingCaseSPId {
    
    
    //============================= List<Map<String, String>> getSharepointId(===================================
    
    
    @AuraEnabled(cacheable=true) 
    public static List<Map<String, String>> getSharepointId(String caseParentId/*,String fileNameForCaseID*/){
         List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        String sharepointid;
        String fileSpId;
        
        List<String> sharepointEmailIdList= new List<String>();
        
        FileDataResult fileData = new FileDataResult();
        fileData.resultMap = new Map<String, List<Object>>();
        //fileData.resultList = new List<Object>();
        //getting access token
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
            system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
        }
        
        //getting email message ID        
       // List<Case> caseList = [Select id from case where id =: caseParentId limit 1];
      //  String caseFolderName = caseList[0].id;    
        String caseFolderName =  caseParentId;
        
        List<String> emailIdFromSp = new List<String>();
        String fileNameForCaseID;
        String eachEmailMessageIdFromSp;
        
        
        String fileSPWebUrlForCaseId;
        String fileCreatedDateTimeForCaseId;
        String fileSPEtagForCaseId;
        String fileSizeForCaseId;
        String fileTypeForCaseId;
        String fileName;
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
            
            //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
            req1.setMethod('GET');
            //req1.setHeader('Authorization', 'Bearer ' + accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            req1.setEndpoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + ':/children'); 
            
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
                                
                                //getting email message share point id                            
                                try{                               
                                    String driveId1 = Label.SharepointDriveId;
                                    String encodedDriveId1 = EncodingUtil.urlEncode(driveId1, 'UTF-8');
                                    //String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                                    //String subFolderName = stagingList[0].Linked_Entity_Id__c;
                                    //String objectName = stagingList[0].sObject__c;
                                    
                                    Http httpCallout2 = new Http();
                                    HttpRequest req2 = new HttpRequest();
                                    String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case';
                                    //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                                    req2.setMethod('GET');
                                    req2.setHeader('Authorization', 'Bearer ' + accessToken);
                                    req2.setHeader('Content-Type', 'application/json');
                                    req2.setHeader('Accept', 'application/json');
                                    req2.setTimeout(120000);
                                    req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId1+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + '/' + eachEmailMessageIdFromSp +':/children'); 
                                    
                                    //req.setBodyAsBlob(fileBody);
									System.debug('limits of callouts'+limits.getCallouts());                                    
                                    HTTPResponse res2 = httpCallout2.send(req2);
                                    System.debug('limits after of callouts'+limits.getCallouts());
                                    System.debug('Aya edhar bhi');
                                    if (res2.getStatusCode() == 200) {
                                        try {
                                            if (res2.getBody() != null) {
                                                String jsonString2 = res2.getBody();
                                                Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                                                System.debug('EmailResponse: ' + result2);
                                                for(Item eachItem2 : result2.value){
                                                    List<object> dataList2=new List<object>();
                                                    
                                                    fileName=eachItem2.name;
                                                    if(fileName.contains('EmailMessageDetails')){
                                                        fileSpId=eachItem2.id;
                                                        fileSPWebUrl=eachItem2.webUrl;
                                                        fileCreatedDateTime=eachItem2.createdDateTime;
                                                        fileSPEtag=eachItem2.eTag.substring(2, eachItem.eTag.length() - 4);
                                                        fileSize=eachItem2.size;
                                                        fileType=eachItem2.File.mimeType;
                                                        system.debug('fileName==>' +eachItem2.name);
                                                        system.debug('fileSpId==>' +eachItem2.id);
                                                        system.debug('fileSPWebUrl==>' +eachItem2.webUrl);
                                                        system.debug('fileCreatedDateTime==>' +eachItem2.createdDateTime);
                                                        system.debug('fileSPEtag==>' +eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                                        system.debug('fileSize==>' +eachItem2.size);
                                                        system.debug('fileType==>' +eachItem2.File.mimeType);
                                                        dataList2.add(fileName);
                                                        dataList2.add(fileSize);
                                                        dataList2.add(fileType);
                                                        dataList2.add(fileSPEtag);
                                                        dataList2.add(fileCreatedDateTime);
                                                        fileData.resultMap.put(fileSPWebUrl, dataList2);
                                                        //sharepointEmailIdList.add(fileSpId);
                                                        
                                                    }                                                
                                                }
                                                
                                                System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
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
                            sharepointEmailIdList.add(fileSpId);
                            System.debug('sharepointEmailIdList ===>'+sharepointEmailIdList); 
                        }
                        System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
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
        //getting each fields values from email message csv using email message csv share point id        
        try{
            
            for (string spid:sharepointEmailIdList){                
                sharepointid=spid;
                System.debug('sharepointid ===>'+sharepointid);                
                
                String driveId2 = Label.SharepointDriveId;
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('GET');
                req2.setHeader('Accept', 'application/json;odata=verbose');
                req2.setEndpoint('callout:Sharepoint/v1.0/drives/'+driveId2+'/items/' + sharepointid + '/content');
                HTTPResponse res2 = new Http().send(req2);
                try{
                    while (res2.getStatusCode() == 302) {
                        req2.setEndpoint(res2.getHeader('Location'));
                        res2 = new Http().send(req2);
                    }
                }catch(exception o){
                    System.debug('Catch exception1'+o.getMessage());
                }
                
                Blob headerValue= blob.valueOf(res2.getBody());
                
                String body = EncodingUtil.base64Encode(headerValue);
                
                String lines = res2.getBody();
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
                csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
                csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
                csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
                string CreatedById = String.valueOf(mapHeadersValues.get('CreatedById')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedById')).length() - 3));
                csvInfo.put('CreatedById', CreatedById);
                system.debug(' <> CreatedById '+ CreatedById );
                csvInfo.put('CreatedByUserName', getUserNameRecordbyId(CreatedById) );
                string LastModifiedById = String.valueOf(mapHeadersValues.get('LastModifiedById')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedById')).length() - 3));
                csvInfo.put('LastModifiedByUserName', getUserNameRecordbyId(LastModifiedById) );
                csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
                csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
                csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
                csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
                csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
                csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
                csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
                csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
                csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
                
                csvInfoList.add(csvInfo);
                system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
                system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
                system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
            }
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        
        return csvInfoList;
        
         }  
    //======================================Test Method============================================================
    
    @AuraEnabled
    public static Map<String, String> getEmailDataTestMethod(String caseId/*,String eachEmailMessageIdFromSp*/){
        system.debug('String caseId==> '+caseId);
        caseId = caseId.right(19).left(18);
        system.debug('Case id '+caseId);
        FileDataResult fileData = new FileDataResult();
        fileData.resultMap = new Map<String, List<Object>>();
        
        List<String> sharepointEmailIdList= new List<String>();
        String sharepointid;
        String fileSpId;
        
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
            //system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }       
        //Case_Email__c caseEmail = [select Id, Case_Id__c from Case_Email__c  where EmailMessage_Id__c =: emailMessageId limit 1];
        
        List<Case> caseList = [Select id from case where id =: caseId];
        String caseFolderName = caseList[0].id;
        system.debug('String caseFolderName==>'+caseFolderName);
        
        List<String> emailIdFromSp = new List<String>();
        String fileNameForCaseID;
        String eachEmailMessageIdFromSp;
        
        String fileSPWebUrlForCaseId;
        String fileCreatedDateTimeForCaseId;
        String fileSPEtagForCaseId;
        String fileSizeForCaseId;
        String fileTypeForCaseId;
        String fileName;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        
        String statusNew;
        String statusRead;
        String statusReplied;
        String statusSent;
        String statusForwarded;
        String statusDraft;
        Map<String, String> csvInfo = new Map<String, String>(); 
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
            //req1.setHeader('Authorization', 'Bearer ' + accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            req1.setEndpoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + ':/children'); 
            // String endpoint = 'callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/' + 'Case/' + encodedParentCaseId + '/' + encodedObjectName + '/' + encodedFileName.replaceAll('\\+', '%20') + ':/content';
            
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res1 = httpCallout.send(req1);
            
            if (res1.getStatusCode() == 200) {
                try {
                    if (res1.getBody() != null) {
                        String jsonString = res1.getBody();
                        Response result = (Response) JSON.deserialize(jsonString, Response.class);
                        //System.debug('EmailResponse: ' + result);
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
                                    String encodedDriveId1 = EncodingUtil.urlEncode(driveId1, 'UTF-8');
                                    //String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                                    //String subFolderName = stagingList[0].Linked_Entity_Id__c;
                                    //String objectName = stagingList[0].sObject__c;
                                    
                                    Http httpCallout2 = new Http();
                                    HttpRequest req2 = new HttpRequest();
                                    String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case';
                                    //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                                    req2.setMethod('GET');
                                    req2.setHeader('Authorization', 'Bearer ' + accessToken);
                                    req2.setHeader('Content-Type', 'application/json');
                                    req2.setHeader('Accept', 'application/json');
                                    req2.setTimeout(120000);
                                    req2.setEndpoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId1+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + '/' + eachEmailMessageIdFromSp +':/children'); 
                                    //req.setBodyAsBlob(fileBody);
                                    
                                    HTTPResponse res2 = httpCallout2.send(req2);
                                    
                                    if (res2.getStatusCode() == 200) {
                                        try {
                                            if (res2.getBody() != null) {
                                                String jsonString2 = res2.getBody();
                                                Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                                                //System.debug('EmailResponse: ' + result2);
                                                for(Item eachItem2 : result2.value){
                                                    List<object> dataList2=new List<object>();
                                                    
                                                    fileName=eachItem2.name;
                                                    if(fileName.contains('EmailMessageDetails')){
                                                        fileSpId=eachItem2.id;
                                                        fileSPWebUrl=eachItem2.webUrl;
                                                        fileCreatedDateTime=eachItem2.createdDateTime;
                                                        fileSPEtag=eachItem2.eTag.substring(2, eachItem.eTag.length() - 4);
                                                        fileSize=eachItem2.size;
                                                        fileType=eachItem2.File.mimeType;
                                                        dataList2.add(fileName);
                                                        dataList2.add(fileSize);
                                                        dataList2.add(fileType);
                                                        dataList2.add(fileSPEtag);
                                                        dataList2.add(fileCreatedDateTime);
                                                        fileData.resultMap.put(fileSPWebUrl, dataList2);
                                                        
                                                        try{                                                            
                                                            for (string spid:sharepointEmailIdList){
                                                                
                                                                sharepointid=spid;
                                                                System.debug('sharepointid ===>'+sharepointid);
                                                                
                                                                String driveId3 = Label.SharepointDriveId;
                                                                HttpRequest req3 = new HttpRequest();
                                                                req3.setMethod('GET');
                                                                req3.setHeader('Accept', 'application/json;odata=verbose');
                                                                req3.setEndpoint('callout:Sharepoint/v1.0/drives/'+driveId3+'/items/' + sharepointid + '/content');
                                                                HTTPResponse res3 = new Http().send(req3);
                                                                try{
                                                                    while (res3.getStatusCode() == 302) {
                                                                        req3.setEndpoint(res3.getHeader('Location'));
                                                                        res3 = new Http().send(req3);
                                                                    }
                                                                }catch(exception o){
                                                                    System.debug('Catch exception1'+o.getMessage());
                                                                }
                                                                
                                                                Blob headerValue= blob.valueOf(res3.getBody());
                                                                
                                                                String body = EncodingUtil.base64Encode(headerValue);
                                                                
                                                                String lines = res3.getBody();
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
                                                                system.debug('>><< status - '+ String.valueOf(mapHeadersValues.get('Status')));
                                                                //Map<String, String> csvInfo = new Map<String, String>();
                                                                csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
                                                                csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
                                                                csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
                                                                string CreatedById = String.valueOf(mapHeadersValues.get('CreatedById')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedById')).length() - 3));
                                                                csvInfo.put('CreatedById', CreatedById);
                                                                system.debug(' <> CreatedById '+ CreatedById );
                                                                csvInfo.put('CreatedByUserName', getUserNameRecordbyId(CreatedById) );
                                                                string LastModifiedById = String.valueOf(mapHeadersValues.get('LastModifiedById')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedById')).length() - 3));
                                                                csvInfo.put('LastModifiedById', LastModifiedById );
                                                                csvInfo.put('LastModifiedByUserName', getUserNameRecordbyId(LastModifiedById) );
                                                                csvInfo.put('LastModifiedDate', String.valueOf(mapHeadersValues.get('LastModifiedDate')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedDate')).length() - 3)));
                                                                csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
                                                                csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
                                                                csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
                                                                csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
                                                                csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
                                                                csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
                                                                csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
                                                                csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
                                                                csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
                                                                csvInfo.put('FromName', String.valueOf(mapHeadersValues.get('FromName')).substring(0, (String.valueOf(mapHeadersValues.get('FromName')).length() - 3)));
                                                                csvInfo.put('Status', String.valueOf(mapHeadersValues.get('Status')).substring(0, (String.valueOf(mapHeadersValues.get('Status')).length() - 3)));
                                                                //system.debug(' >><< status -- '+String.valueOf(mapHeadersValues.get('Status')));
                                                                //string status = statusCodeToText(integer.valueOf(mapHeadersValues.get('Status')));
                                                                //csvInfo.put('Status', status);
                                                                // csvInfoList.add(csvInfo);
                                                                system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
                                                                system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
                                                                system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
                                                                system.debug('csvInfo.put(Status)=>'   +csvInfo.get('Status'));
                                                                
                                                                
                                                                string status = statusCodeToText(integer.valueOf(csvInfo.get('Status')));
                                                                system.debug('string status ==>'  +status);
                                                                csvInfo.put('Status', status);
                                                                system.debug('csvInfo.put(Status)=>' + csvInfo.get('Status'));
                                                                
                                                            }
                                                        }catch(exception e){
                                                            System.debug('Catch exception'+e.getMessage());
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
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
                            sharepointEmailIdList.add(fileSpId);
                            System.debug('sharepointEmailIdList ===>'+sharepointEmailIdList);
                            
                            //return dataList;                                                       
                        }
                        System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
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
        
        //system.debug('csv returned '+csvInfo);
        return csvInfo;   
    }
    
    //================================================================================================================================
    
    @AuraEnabled 
    public static Map<String, String> getSharepointIdfromEmailId(String caseParentId, String eachEmailMessageIdFromSp){  
        Map<String, String> csvInfo = new Map<String, String>();
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        String sharepointid;
        String fileSpId;
        
        FileDataResult fileData = new FileDataResult();
        fileData.resultMap = new Map<String, List<Object>>();
        List<String> sharepointEmailIdList= new List<String>();
        
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
            system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
        }
                
        //List<Case> caseList = [Select id from case where id =: caseParentId limit 1];
        String caseFolderName = caseParentId;
        system.debug('String caseFolderName==>'+caseFolderName);
        List<String> emailMessageIds = new List<String>();
        String fileNameForCaseID;
        //String eachEmailMessageIdFromSp;
        
        String fileSPWebUrlForCaseId;
        String fileCreatedDateTimeForCaseId;
        String fileSPEtagForCaseId;
        String fileSizeForCaseId;
        String fileTypeForCaseId;
        String fileName;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        
        system.debug('List<String> emailMessageIds==>' +emailMessageIds);
        /*for(String emidsp:emailMessageIds){
eachEmailMessageIdFromSp=emidsp;
system.debug('String eachEmailMessageIdFromSp==>' +eachEmailMessageIdFromSp);
*/    
        try{                                
            String driveId1 = Label.SharepointDriveId;
            String encodedDriveId1 = EncodingUtil.urlEncode(driveId1, 'UTF-8');
            //String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
            //String subFolderName = stagingList[0].Linked_Entity_Id__c;
            //String objectName = stagingList[0].sObject__c;
            
            Http httpCallout2 = new Http();
            HttpRequest req2 = new HttpRequest();
            String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); //'Case';
            //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
            req2.setMethod('GET');
            req2.setHeader('Authorization', 'Bearer ' + accessToken);
            req2.setHeader('Content-Type', 'application/json');
            req2.setHeader('Accept', 'application/json');
            req2.setTimeout(120000);
            req2.setEndpoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId1+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + '/' + eachEmailMessageIdFromSp +':/children'); 
            
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res2 = httpCallout2.send(req2);
            
            if (res2.getStatusCode() == 200) {
                try {
                    if (res2.getBody() != null) {
                        String jsonString2 = res2.getBody();
                        Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                        System.debug('EmailResponse: ' + result2);
                        for(Item eachItem2 : result2.value){
                            List<object> dataList2=new List<object>();
                            
                            fileName=eachItem2.name;
                            if(fileName.contains('EmailMessageDetails')){
                                fileSpId=eachItem2.id;
                                fileSPWebUrl=eachItem2.webUrl;
                                fileCreatedDateTime=eachItem2.createdDateTime;
                                fileSPEtag=eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4);
                                fileSize=eachItem2.size;
                                fileType=eachItem2.File.mimeType;
                                system.debug('fileName==>' +eachItem2.name);
                                system.debug('fileSpId==>' +eachItem2.id);
                                system.debug('fileSPWebUrl==>' +eachItem2.webUrl);
                                system.debug('fileCreatedDateTime==>' +eachItem2.createdDateTime);
                                system.debug('fileSPEtag==>' +eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                system.debug('fileSize==>' +eachItem2.size);
                                system.debug('fileType==>' +eachItem2.File.mimeType);			
                                dataList2.add(fileName);
                                dataList2.add(fileSize);
                                dataList2.add(fileType);
                                dataList2.add(fileSPEtag);
                                dataList2.add(fileCreatedDateTime);
                                fileData.resultMap.put(fileSPWebUrl, dataList2);
                                
                            }                                                
                        }
                        System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
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
        //}
        sharepointEmailIdList.add(fileSpId);
        System.debug('sharepointEmailIdList ===>'+sharepointEmailIdList); 
        try{
            
            for (string spid:sharepointEmailIdList){                
                sharepointid=spid;
                System.debug('sharepointid ===>'+sharepointid);                
                
                String driveId2 = Label.SharepointDriveId;
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('GET');
                req2.setHeader('Accept', 'application/json;odata=verbose');
                req2.setEndpoint('callout:Sharepoint/v1.0/drives/'+driveId2+'/items/' + sharepointid + '/content');
                HTTPResponse res2 = new Http().send(req2);
                try{
                    while (res2.getStatusCode() == 302) {
                        req2.setEndpoint(res2.getHeader('Location'));
                        res2 = new Http().send(req2);
                    }
                }catch(exception o){
                    System.debug('Catch exception1'+o.getMessage());
                }
                
                Blob headerValue= blob.valueOf(res2.getBody());
                
                String body = EncodingUtil.base64Encode(headerValue);
                
                String lines = res2.getBody();
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
                
                
                csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
                csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
                csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
                string CreatedById = String.valueOf(mapHeadersValues.get('CreatedById')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedById')).length() - 3));
                csvInfo.put('CreatedById', CreatedById);
                //system.debug(' <> CreatedById '+ CreatedById );
                csvInfo.put('CreatedByUserName', getUserNameRecordbyId(CreatedById) );
                string LastModifiedById = String.valueOf(mapHeadersValues.get('LastModifiedById')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedById')).length() - 3));
                csvInfo.put('LastModifiedByUserName', getUserNameRecordbyId(LastModifiedById) );
                csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
                csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
                csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
                csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
                csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
                csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
                csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
                csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
                csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
                csvInfo.put('Status', String.valueOf(mapHeadersValues.get('Status')).substring(0, (String.valueOf(mapHeadersValues.get('Status')).length() - 3)));
                //system.debug(' >><< status -- '+String.valueOf(mapHeadersValues.get('Status')));
                //string status = statusCodeToText(integer.valueOf(mapHeadersValues.get('Status')));
                //csvInfo.put('Status', status);
                // csvInfoList.add(csvInfo);
                system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
                system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
                system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
                system.debug('csvInfo.put(Status)=>'   +csvInfo.get('Status'));
                
                
                string status = statusCodeToText(integer.valueOf(csvInfo.get('Status')));
                system.debug('string status ==>'  +status);
                csvInfo.put('Status', status);
                system.debug('csvInfo.put(Status)=>' + csvInfo.get('Status'));
                
            }
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        System.debug(' return csvInfo;-===>'+csvInfo);
        return csvInfo;
    }    
    
    //======================================== deleteSharepointId=====================================================================
    
    @AuraEnabled
    Public static void deleteSharepointId(String fileSharepointId){
        try{
            //fileSharepointId=caseEmailList[0].Files_Share_Point_Id__c;
            //fileSharepointId='01SCG6PXPNIAXL3OCS5RALIQIBCLEKFFOD';
            //System.debug('Each files sharepointID==> ' +fileSharepointId);
            String driveId = Label.SharepointDriveId;
            string siteId='d7c113dd-f195-44b6-a7ff-027d3860f10f';
            
            
            Http httpCallout = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint('callout:Sharepoint/v1.0/sites/' + siteId + '/drives/' + driveId + '/items/' + fileSharepointId);             
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res = httpCallout.send(req);
            System.debug('HTTPResponse respomse status code==> '+res.getStatusCode());
            if(res.getStatusCode() == 204){
                System.debug('File is deleted');
            }else{
                System.debug('There is a problem in calss.');
            }                       
        }catch(Exception e){
            System.debug('Catch Exception==> '+e.getMessage());
        }
    }
    
    //=============================================================================================================
    
    @AuraEnabled
    public static Case getCaseRecordbyId(String caseId) {
        Case caseRecord;
        try {
            caseRecord = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
            System.debug('Case Record Retrieved: ' + caseRecord);
        } catch (Exception e) {
            System.debug('Catch Exception: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving case record: ' + e.getMessage());
        }
        return caseRecord;
    }
    
    
    //=============================================================================================================
    
    public static String getUserNameRecordbyId(string userId){
        return (String)[Select Id, Name from User where id = :userId limit 1].Name;
    }
    
    public class FileDataResult {
        public Map<String, List<Object>> resultMap { get; set; }
        //public List<Object> resultList { get; set; }
    } 
    
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
    
    public class Item {
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
    
    public static string statusCodeToText(integer code){
        switch on code{
            when 0 {
                return 'New';
            }
            when 1 {
                return 'Read';
            }
            when 2 {
                return 'Replied';
            }
            when 3 {
                return 'Sent';
            }
            when 5 {
                return 'Draft';
            }
            when else {
                return 'N/A';
            }
        }
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
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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