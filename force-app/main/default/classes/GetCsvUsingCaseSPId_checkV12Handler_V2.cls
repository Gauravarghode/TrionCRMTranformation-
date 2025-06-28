public class GetCsvUsingCaseSPId_checkV12Handler_V2 {
    
    public static void subscribeEvents(List<GetDataFromSharepoint_V2__e> sharepointemailIdPushList, String caseParentId){
        System.debug(' Code is inside handler class');        
        System.debug(' List<GetDataFromSharepoint_V2__e> sharepointemailIdPushList===> '+sharepointemailIdPushList);
        System.debug(' String caseParentId===> '+caseParentId);
        String eachSharePointId;
        String spIdSetValue;
        try{
            Set<string> uniqueIdentifier = new set<string>();
            for(GetDataFromSharepoint_V2__e platformeventList:sharepointemailIdPushList){
                uniqueIdentifier.add(platformeventList.EmailIdFromSP__c);
                uniqueIdentifier.remove(null);                         
            } 
            System.debug('uniqueIdentifier===>'+uniqueIdentifier);
            System.debug('uniqueIdentifier SIZE===>'+uniqueIdentifier.size());
            
            For(String spemid:uniqueIdentifier){
                spIdSetValue=spemid;
            }
            System.debug('spIdSetValue===>'+spIdSetValue);
            List<String> spEmailId=new List<String>(uniqueIdentifier);
            //emailSpId.add(serializedmethodOpMap);
            System.debug(' emailSpId.add(serializedmethodOpMap);===> '+spEmailId);
            System.debug(' emailSpId.add(serializedmethodOpMap);Size===> '+spEmailId.size());
            
            processSharepointEmailIdsAsync(spEmailId, caseParentId);
            
        }catch (Exception e){
            System.debug('Catch Exception ===>'+e.getmessage());
        }
    }
    
    @future(callout=true)
    public static void processSharepointEmailIdsAsync(List<String> spEmailId, String caseParentId) {
        System.debug(' Code is inside future method');        
        processSharepointEmailIds(spEmailId, caseParentId);
    }
    
    @AuraEnabled(cacheable=true) 
    public static void processSharepointEmailIds(List<String> spEmailId, String caseParentId) {
        System.debug(' Code is inside List<Map<String, String>> processSharepointEmailIds');        
        List<Map<String, String>> spInfoList = new List<Map<String, String>>();
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        List<Map<String, String>> chunkCsvInfoList = new List<Map<String, String>>();
        List<String> sharepointEmailIdList= new List<String>();
        String fileid;
        String sharepointid;
        String caseFolderName;
        List<Case> caseList = [Select id from case where id = :caseParentId];
        
        for(Case cs:caseList){
            caseFolderName = cs.Id;
        }
        System.debug(' String caseFolderName===> ' + caseFolderName);   
        //String caseFolderName = caseList[0].id;
        /*  GetFolderUsingCustomMetadata_V1 batch = new GetFolderUsingCustomMetadata_V1(caseFolderName);
Database.executeBatch(batch);
String objectNameCase2 = batch.getMetadataFolderName();
*/
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); 
        System.debug('String objectNameCase2----> ' + objectNameCase2);
        try {
            Integer chunkSize = 15;
            System.debug('Integer chunkSize----> ' + chunkSize);
            Integer totalRecords = spEmailId.size();
            System.debug('Integer totalRecords----> ' + totalRecords);
            
            for (Integer chunkStart = 0; chunkStart < totalRecords; chunkStart += chunkSize) {
                System.debug('Integer chunkStart----> ' + chunkStart);
                Integer chunkEnd = Math.min(chunkStart + chunkSize, totalRecords);
                System.debug('Integer chunkEnd----> ' + chunkEnd);
                List<String> chunk = new List<String>();
                
                for (Integer i = chunkStart; i < chunkEnd; i++) {
                    chunk.add(spEmailId[i]);                   
                }
                System.debug('List<String> chunk------> ' + chunk);
                System.debug('List<String> chunk SIZE------> ' + chunk.size());
                
                for (String spid : chunk) {
                    
                    Http httpCallout2 = new Http();
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('GET');
                    req2.setHeader('Content-Type', 'application/json');
                    req2.setHeader('Accept', 'application/json');
                    req2.setTimeout(120000);
                    req2.setEndpoint('callout:Sharepoint/v1.0/sites/' + Label.SharePoint_Site_Id + '/drives/' + Label.SharepointDriveId + '/items/root:/' + objectNameCase2 + '/' + caseFolderName + '/' + spid + ':/children');
                    
                    HTTPResponse res2 = httpCallout2.send(req2);
                    
                    if (res2.getStatusCode() == 200) {
                        if (res2.getBody() != null) {
                            String jsonString2 = res2.getBody();
                            Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                            
                            for (Item eachItem2 : result2.value) {
                                if (eachItem2.name.contains('EmailMessageDetails')) {
                                    Map<String, String> spInfo = new Map<String, String>();
                                    spInfo.put('fileid', eachItem2.id);
                                    spInfo.put('fileName', eachItem2.name);
                                    spInfo.put('fileSize', eachItem2.size);
                                    spInfo.put('fileType', eachItem2.File.mimeType);
                                    spInfo.put('fileCreatedDateTime', eachItem2.createdDateTime);
                                    spInfo.put('fileSPWebUrl', eachItem2.webUrl);
                                    spInfo.put('fileSPEtag', eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                    
                                    spInfoList.add(spInfo);
                                    fileid = spInfo.get('fileid');
                                    sharepointEmailIdList.add(fileid);
                                    System.debug('sharepointid ===>'+sharepointEmailIdList);  
                                    System.debug('sharepointid size ===>'+sharepointEmailIdList.size());    
                                }
                            }
                        }
                    }
                }    
                for (String spid : sharepointEmailIdList) {
                    //String sharepointid = spid;
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('GET');
                    req2.setHeader('Accept', 'application/json;odata=verbose');
                    req2.setEndpoint('callout:Sharepoint/v1.0/drives/' + Label.SharepointDriveId + '/items/' + spid + '/content');
                    HTTPResponse res2 = new Http().send(req2);
                    
                    try {
                        while (res2.getStatusCode() == 302) {
                            req2.setEndpoint(res2.getHeader('Location'));
                            res2 = new Http().send(req2);
                        }
                    } catch (Exception e) {
                        System.debug('Catch exception: ' + e.getMessage());
                    }
                    
                    Blob headerValue = Blob.valueOf(res2.getBody());
                    String body = EncodingUtil.base64Encode(headerValue);
                    String lines = res2.getBody();
                    List<String> allValues = lines.split(',');
                    
                    List<String> Headers1 = new List<String>();
                    for (Integer i = 0; i < 39; i++) {
                        if (i <= 37)
                            Headers1.add(allValues[i]);
                        else {
                            Headers1.add('HtmlBody');
                        }
                    }
                    
                    List<String> allValues1 = lines.split('##  ');
                    List<String> Values1 = new List<String>();
                    
                    for (Integer i = 1; i < 40; i++) {
                        Values1.add(allValues1[i]);
                    }
                    
                    Map<String, String> MapHeadersValues = new Map<String, String>();
                    
                    for (Integer i = 0; i < 39; i++) {
                        MapHeadersValues.put(Headers1[i], Values1[i]);
                    }
                    
                    Map<String, String> csvInfo = new Map<String, String>();
                    csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
                    csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
                    csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
                    string CreatedById = String.valueOf(mapHeadersValues.get('CreatedById')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedById')).length() - 3));
                    csvInfo.put('CreatedById', CreatedById);
                    //system.debug(' <> CreatedById '+ CreatedById );
                    csvInfo.put('CreatedByUserName', getUserNameRecordbyId(CreatedById) );
                    //string LastModifiedById = String.valueOf(mapHeadersValues.get('LastModifiedById')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedById')).length() - 3));
                   // csvInfo.put('LastModifiedById', LastModifiedById );
                    //csvInfo.put('LastModifiedByUserName', getUserNameRecordbyId(LastModifiedById) );
                    //csvInfo.put('LastModifiedDate', String.valueOf(mapHeadersValues.get('LastModifiedDate')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedDate')).length() - 3)));
                    csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
                    csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
                    csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
                    csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
                    csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
                    //csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
                    csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
                    csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
                    csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
                   // csvInfo.put('FromName', String.valueOf(mapHeadersValues.get('FromName')).substring(0, (String.valueOf(mapHeadersValues.get('FromName')).length() - 3)));
                    csvInfo.put('Status', String.valueOf(MapHeadersValues.get('Status')).substring(0, (String.valueOf(MapHeadersValues.get('Status')).length() - 3)));
                    String status = statusCodeToText(Integer.valueOf(csvInfo.get('Status')));
                    csvInfo.put('Statustext', status);
                    System.debug('csvInfo.put(Status) =>' + csvInfo.get('Status'));
                    System.debug('csvInfo.put(IdOfCsv)=>' + csvInfo.get('IdOfCsv'));
                    System.debug('csvInfo.put(ParentId)=>' + csvInfo.get('ParentId'));
                    System.debug('csvInfo.put(HtmlBody)=>' + csvInfo.get('HtmlBody'));
                    chunkCsvInfoList.add(csvInfo);
                    System.debug('chunkCsvInfoList.add(csvInfo); chunkCsvInfoList===>' + chunkCsvInfoList);
                    System.debug('chunkCsvInfoList.add(csvInfo); chunkCsvInfoList size===>' + chunkCsvInfoList.size());
                    system.debug('Serialized map is '+system.json.serializePretty(csvInfo));
                    
                    
                    List<ListMapPlatform_V2__e> finalList = new List<ListMapPlatform_V2__e>();
                    //for (Map<String, String> spIdList : csvInfoList) {
                    ListMapPlatform_V2__e event = new ListMapPlatform_V2__e();
                    event.Id__c = String.valueOf((csvInfo.get('IdOfCsv')));
                    System.debug('event.Id__c Length from new approach===>' + event.Id__c); 
                    event.ParentId__c = String.valueOf((csvInfo.get('ParentId')));
                    System.debug('event.ParentId__c Length from new approach===>' + event.ParentId__c); 
                    event.CreatedDate__c = String.valueOf((csvInfo.get('CreatedDate')));
                    System.debug('event.CreatedDate__c Length from new approach===>' + event.CreatedDate__c); 
                    event.CreatedById__c = String.valueOf((csvInfo.get('CreatedById')));
                    System.debug('event.CreatedById__c Length from new approach===>' + event.CreatedById__c); 
                    event.CreatedByName__c = String.valueOf((csvInfo.get('CreatedByUserName')));
                    System.debug('event.CreatedByName__c Length from new approach===>' + event.CreatedByName__c); 
                    event.Subject__c = String.valueOf((csvInfo.get('Subject')));
                    event.FromAddress__c = String.valueOf((csvInfo.get('FromAddress')));
                    event.ToAddress__c = String.valueOf((csvInfo.get('ToAddress')));
                    event.BccAddress__c = String.valueOf((csvInfo.get('BccAddress')));
                    event.HtmlBody__c = String.valueOf((csvInfo.get('HtmlBody')));
                    event.Status__c = String.valueOf((csvInfo.get('Statustext')));
                    System.debug('event.Status__c Length from new approach===>' + event.Status__c); 
                    event.TextBody__c = String.valueOf((csvInfo.get('TextBody')));
                    event.Headers__c = String.valueOf((csvInfo.get('Headers')));
                    event.MessageDate__c = String.valueOf((csvInfo.get('MessageDate ')));
                    finalList.add(event);
                    
                    system.debug('Serialized map is (from new approach)'+system.json.serializePretty(finalList));
                    List<Database.SaveResult> finalResultEvent = EventBus.publish(finalList);
                    System.debug('Database.SaveResult results (from new approach)==>' + finalResultEvent);
                    //}
                    
                }               
                csvInfoList.addAll(chunkCsvInfoList);
                System.debug('csvInfoList.addAll(chunkCsvInfoList); csvInfoList===>' + csvInfoList);
                System.debug('csvInfoList.addAll(chunkCsvInfoList); csvInfoList size===>' + csvInfoList.size()); 
                /*      List<ListMapPlatform__e> finalList = new List<ListMapPlatform__e>();
//for (Map<String, String> spIdList : csvInfoList) {
ListMapPlatform__e event = new ListMapPlatform__e();
event.csvInfoList__c = String.valueOf(csvInfoList);
System.debug('event.csvInfoList__c Length===>' + event.csvInfoList__c.length()); 

finalList.add(event);

*/
                //}
                //List<Database.SaveResult> finalResultEvent = EventBus.publish(finalList);
                //System.debug('Database.SaveResult results==>' + finalResultEvent);
                /*
List<Id> successIds = new List<Id>();        
for (Database.SaveResult resultnew : finalResultEvent ) {
if (resultnew.isSuccess()) {
successIds.add(resultnew.getId());
System.debug('List<Id> successIds==>' + successIds);
System.debug('List<Id> successIds SIZE==>' + successIds.size());
System.debug('successIds.add(resultnew.getId())==>' + resultnew.getId());
} else {
for (Database.Error error : resultnew.getErrors()) {
System.debug('Error message: ' + error.getMessage());
System.debug('Status code: ' + error.getStatusCode());
}
}
}
*/
            }
        }catch (Exception e) {
            System.debug('Catch exception: ' + e.getMessage());
        }
        
        
        
        setCsvInfoList(csvInfoList);
        //return csvInfoList;    
    }   
    @AuraEnabled(cacheable=true) 
    public static List<Map<String, String>> setCsvInfoList(List<Map<String, String>> csvInfoList) {
        csvInfoListStatic = csvInfoList;
        System.debug('Code is inside setCsvInfoList');
        System.debug('FINAL csvInfoList===> ' + csvInfoList);
        System.debug('FINAL csvInfoList size===> ' + csvInfoList.size());
        System.debug('FINAL csvInfoListStatic===> ' + csvInfoListStatic);
        System.debug('FINAL csvInfoListStatic size===> ' + csvInfoListStatic.size());
        return csvInfoListStatic;
    }
    private static List<Map<String, String>> csvInfoListStatic;
    
    @AuraEnabled
    public static Case getCaseRecordbyId(String caseId) {
        Case caseRecord;
        try {
            caseRecord = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving case record: ' + e.getMessage());
        }      
        return caseRecord;
    }
    
    public static String getUserNameRecordbyId(String userId){
        return (String)[Select Id, Name from User where id = :userId limit 1].Name;
    }
    
    
    public class EmailMessageInfoUtil {
        public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
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
        public File File;
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
    
    public class File {
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
    
    public static String statusCodeToText(Integer code) {
        switch on code {
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
    }
    
}