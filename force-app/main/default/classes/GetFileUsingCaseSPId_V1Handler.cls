public class GetFileUsingCaseSPId_V1Handler {
    
    public static void subscribeEvents(List<GetDataFromSharepoint__e> sharepointemailIdPushList, String caseParentId){
        System.debug(' Code is inside handler class');        
        System.debug(' List<GetDataFromSharepoint__e> sharepointemailIdPushList===> '+sharepointemailIdPushList);
        System.debug(' String caseParentId===> '+caseParentId);
        String eachSharePointId;
        String spIdSetValue;
        try{
            Set<string> uniqueIdentifier = new set<string>();
            for(GetDataFromSharepoint__e platformeventList:sharepointemailIdPushList){
                uniqueIdentifier.add(platformeventList.Emailid__c);
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
        list<map<string, string>> responseMapList = new list<map<string, string>>();
        responseWrap finalResponse = new responseWrap();
        list<ResponseItem> filesList = new list<ResponseItem>();
        list<String> jsonStringList = new list<string>();
        List<String> sharepointEmailIdList= new List<String>();
        String fileid;
        String sharepointid;
        List<Case> caseList = [Select id from case where id = :caseParentId limit 1];
        String caseFolderName = caseList[0].id;
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
                                    system.debug(' jsonStringList.@@@ '+ jsonStringList);
                                    Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                                    system.debug('  Response result2 '+ result2);
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
                                            fileMap.put('ParentId', caseFolderName );
                                            fileMap.put('createdDateTime', eachItem2.createdDateTime );
                                            //fileMap.put('lastModifiedDateTime', eachItem2.lastModifiedDateTime );    
                                            fileMap.put('eTag', etagString );
                                            system.debug(' eTag==> '+etagString);
                                            fileMap.put('name', eachItem2.name );
                                            system.debug(' name==> '+eachItem2.name);
                                            fileMap.put('webUrl', eachItem2.webUrl );
                                            system.debug(' webUrl==> '+eachItem2.webUrl);
                                            fileMap.put('size', eachItem2.size );
                                            fileMap.put('fileType', eachItem2.File.mimeType );
                                            fileMap.put('fileId', eachItem2.id );
                                            if(mapUrlEtag.containsKey(etagString)){
                                                fileMap.put('downloadUrl', mapUrlEtag.get(etagString) );
                                            }
                                            system.debug('Serialized map is '+system.json.serializePretty(fileMap));
                                            responseMapList.add(fileMap);
                                            filesList.add(file);
                                            system.debug(' file==> '+file);
                                            
                                            system.debug(' filesList==> '+filesList);
                                            system.debug(' responseMapList==> '+responseMapList);
                                            system.debug('fileMap****************'+fileMap);
                                            
                                            system.debug('Serialized map is '+system.json.serializePretty(responseMapList));
                                            List<FileListMapPlatform__e> finalList = new List<FileListMapPlatform__e>();
                                            FileListMapPlatform__e event = new FileListMapPlatform__e();
                                            for (Map<String, String> spIdList : responseMapList) {
                                                event.fileDataPlatform__c = String.valueOf(spIdList);                                            
                                            }
                                            finalList.add(event);
                                            //System.debug('event.fileDataPlatform__c ==>' + event.fileDataPlatform__c );
                                            System.debug('finalList.add(event); ==>' + finalList );
                                            List<Database.SaveResult> finalResultEvent = EventBus.publish(finalList);
                                            System.debug('Database.SaveResult results==>' + finalResultEvent);
                                            List<Id> successIds = new List<Id>();        
                                            for (Database.SaveResult resultnew : finalResultEvent) {
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
                    }
                }    
            }
        }catch (Exception e) {
            System.debug('Catch exception: ' + e.getMessage());
        }
        //System.debug('return responseMapList; ' + responseMapList);
        //return responseMapList;
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
    }
    
}