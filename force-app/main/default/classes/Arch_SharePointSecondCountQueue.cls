public class Arch_SharePointSecondCountQueue implements Queueable, Database.AllowsCallouts{
    private String emailRecordId;
    private string caseId;
    private integer emailRecordCount;
    
    public Arch_SharePointSecondCountQueue(string caseId,string emailRecordId, integer emailRecordCount) {
        this.emailRecordId = emailRecordId;
        this.caseId = caseId;
        this.emailRecordCount = emailRecordCount;
        System.debug('emailRecordId->'+emailRecordId);
        System.debug('caseId->'+caseId);
        System.debug('emailRecordCount->'+emailRecordCount);
    }
    
    public void execute(QueueableContext context) {
        System.debug('emailRecordId->'+emailRecordId);
        System.debug('caseId->'+caseId);
        System.debug('emailRecordCount->'+emailRecordCount);
        String driveId = Label.SharepointDriveId;
        List<Stagging__c> stagingUpdateList = new List<Stagging__c> ();
        List<EmailMessageHtml__c> emailHtmlUpdateList = new List<EmailMessageHtml__c> ();
        Http httpCallOut=new Http();
        HttpRequest httpReq=new HttpRequest();
        Map<Id,integer> mapofEntityandFilesCount = new Map<Id, Integer>();
        String sharepointFolderName = Label.SharepointfolderName;
        httpReq.setMethod('GET');
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('Accept','application/json');
        httpReq.setEndPoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+sharepointFolderName +'/'+caseId+'/'+emailRecordId+':/children');
        
        List<String>count=new List<String>();
        
        Integer emailMessageDetailsCount = 0;
        
        HttpResponse res=httpCallOut.send(httpReq);
        if(res.getStatusCode()==200){
            if(res.getBody()!=Null){
                String rBody=res.getBody();
                system.debug('Resonse'+rBody);
                Response result=(Response) JSON.deserialize(rBody, Response.class);
                //List<String>count=new List<String>();
                
                for(Item eachItem:result.value){
                    if(!(eachItem.Name.startsWith('EmailMessageDetails'))){
                        count.add(eachItem.Name);
                    } else if(eachItem.Name.startsWith('EmailMessageDetails') && eachItem.Name.contains(emailRecordId)){
                        emailMessageDetailsCount += 1;
                    }
                    
                }
                System.debug('Number of Child counts are:'+count.size());
                System.debug('Number of EmailMessageDetails items: ' + emailMessageDetailsCount);
                
            }
            
            String staggingLinkedEntityId;
            if(count.size() != emailRecordCount ){
                List<Stagging__c> stagingList = [Select id,status__c,Retry_Executed_Count__c,Linked_Entity_Id__c from Stagging__c where Linked_Entity_Id__c =: emailRecordId AND Retry_Executed_Count__c =1 ];
                if(!stagingList.isEmpty()){
                    System.debug('stagingList------>'+stagingList);
                    for(Stagging__c stg: stagingList ){
                        System.debug('stg.Retry_Executed_Count__c------>'+stg.Retry_Executed_Count__c);
                        if(stg.Retry_Executed_Count__c ==1 || stg.Retry_Executed_Count__c != null){
                            //stg.status__c = 'Retry Required';
                            // stg.Retry_Executed_Count__c = stg.Retry_Executed_Count__c +1;
                            // System.debug('stg.Retry_Executed_Count__c------>'+stg.Retry_Executed_Count__c);
                            staggingLinkedEntityId = stg.Linked_Entity_Id__c;
              
                            stg.Upload_Failed__c = True;
                            stagingUpdateList.add(stg);
                        }
                        else{
                            stg.status__c = 'Failed';
                            stagingUpdateList.add(stg);
                        }
                        
                    }
                    List<EmailMessage> emailMessages = [SELECT Id, ParentId FROM EmailMessage WHERE Id = :staggingLinkedEntityId];
                    Set<Id> caseIds = new Set<Id>();
                    
                    for (EmailMessage em : emailMessages) {
                        if (em.ParentId != null) {
                            caseIds.add(em.ParentId);
                        }
                    }
                    
                    List<Case> casesToUpdate = [SELECT Id, Failed_Record__c FROM Case WHERE Id IN :caseIds And Failed_Record__c = false];
                    system.debug('Caseeeeeeeeeeeeeee-:'+casesToUpdate);
                    for (Case c : casesToUpdate) {
                        c.Failed_Record__c = TRUE;
                    }
                    
                    if (!casesToUpdate.isEmpty()) { 
                        update casesToUpdate;
                    }
                    
                }
                
                
                if(!stagingUpdateList.isEmpty()){
                    System.debug('stagingUpdateList------>'+stagingUpdateList);
                    Update(stagingUpdateList);
                }              
                
            }
            if(emailMessageDetailsCount != 1){
                set<Id> caseIdSet = new set<Id>();
                List<EmailMessageHtml__c> listEmHtml = [Select id , Status__c,Retry_Executed_Count__c,EmailMessage_Id__c, Parent_case_ID__c from EmailMessageHtml__c where EmailMessage_Id__c =: emailRecordId AND Retry_Executed_Count__c =1];
                if(!listEmHtml.isEmpty()){
                    system.debug('listEmHtml---->'+listEmHtml);
                    for(EmailMessageHtml__c em : listEmHtml ){
                        //em.Status__c = 'Case failed retry';
                        caseIdSet.add(em.Parent_case_ID__c);
                        
                        em.Upload_Failed__c = TRUE;
                        emailHtmlUpdateList.add(em);
                    }
                    
                    if(!emailHtmlUpdateList.isEmpty()){
                        system.debug('emailHtmlUpdateList--->'+emailHtmlUpdateList);
                        Update(emailHtmlUpdateList);
                    }
                    List<case> caseList = [Select id, Failed_Record__c from case where id IN : caseIdSet];
                    for(Case cs : caseList){
                        cs.Failed_Record__c = true;
                    }
                    if(!caseList.isEmpty()){
                        system.debug('caseList------>'+caseList);
                        update caseList;
                    }
                }
            }
            
        }
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
    
}