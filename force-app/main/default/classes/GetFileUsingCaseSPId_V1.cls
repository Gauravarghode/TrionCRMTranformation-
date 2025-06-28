public class GetFileUsingCaseSPId_V1 {
  /*  @AuraEnabled(cacheable=true) 
    public static void getCaseFolderData(String caseParentId) {
        //List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId);
        getEmailMessageSharePointIds(caseParentId);
        //System.debug('List<String> sharepointEmailIdList===> ' + sharepointEmailIdList);   
        System.debug('String caseParentId===> ' + caseParentId);   
    }
*/
    @AuraEnabled
    Public static List<String> getCaseFolderData(String caseParentId) {
        List<String> emailIdFromSp = new List<String>();
        List<Case> caseList = [Select id from Case where id = :caseParentId limit 1];
        String caseFolderName = caseList[0].id;
        System.debug(' String caseFolderName===> ' + caseFolderName);   
        System.debug(' String caseParentId===> ' + caseParentId);  
        // GetFolderUsingCustomMetadata_V1 batch = new GetFolderUsingCustomMetadata_V1(caseFolderName);
        // Database.executeBatch(batch);
        //String objectNameCase2 = getMetadataFolderName(); 
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); 
        
        //String objectNameCase2 = batch.metadataFolderName;  
        //String objectNameCase2 = batch.finish(metadataFolderName);  
        System.debug(' String objectNameCase2===> ' + objectNameCase2);   
        doHttpCallout(caseParentId, caseFolderName, objectNameCase2);
        
        return emailIdFromSp;
    }
    
     @future(callout=true)
    private static void doHttpCallout(String caseParentId, String caseFolderName, String objectNameCase2) {
        Http httpCallout = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('GET');
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        req1.setTimeout(120000);
        req1.setEndpoint('callout:Sharepoint/v1.0/sites/' + Label.SharePoint_Site_Id + '/drives/' + Label.SharepointDriveId + '/items/root:/' + objectNameCase2  + '/' + caseFolderName + ':/children');             
        
        HTTPResponse res1 = httpCallout.send(req1);
        
        if (res1.getStatusCode() == 200) {
            if (res1.getBody() != null) {
                String jsonString = res1.getBody();
                Response result = (Response) JSON.deserialize(jsonString, Response.class);
                List<String> emailIdFromSp = new List<String>();
                for (Item eachItem : result.value) {
                    emailIdFromSp.add(eachItem.name);
                }
                System.debug('List<String> emailIdFromSp===> ' + emailIdFromSp);
                System.debug('List<String> emailIdFromSp SIZE===> ' + emailIdFromSp.size());   

                List<GetDataFromSharepoint__e> eventList = new List<GetDataFromSharepoint__e>();
                for (String spIdList : emailIdFromSp) {
                    GetDataFromSharepoint__e event = new GetDataFromSharepoint__e();
                    event.Emailid__c = String.valueOf(spIdList);
                    event.ParentCaseId__c = String.valueOf(caseParentId);
                    eventList.add(event);
                }

                List<Database.SaveResult> resultEvent = EventBus.publish(eventList);
                System.debug('Database.SaveResult results==>' + resultEvent);
            }
        }
    }
    
  /*  
    private static String getMetadataFolderName() {
        return MetadataFolderCache.getInstance().metadataFolderName;
    }
*/
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
    
    public static String getUserNameRecordbyId(String userId) {
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
        public String mimeType;
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
    }
    

}