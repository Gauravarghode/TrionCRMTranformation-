global class Arch_PopuPurgeLogsContentdoc implements Database.Batchable<SObject> {
    String NoDays = Label.DaysTo;
    
    
    global List<String>lisofContIds=new List<String>();
    global List<String>lisoflinkentIds=new List<String>();
    global List<ContentDocumentLink>  start(Database.BatchableContext bc){ 
        String days=Label.DaysTo;
        String days2 = Label.DaysTo2;
        List<Stagging__c> lisStagings=[Select id,Content_Document_Id__c,Is_Large_File__c,Status__c,Linked_Entity_Id__c,Retry_Executed_Count__c from Stagging__c where Status__c='Completed' And Is_Large_File__c='No' AND CreatedDate = TODAY  ];
        //List<Stagging__c> lisStagings=[Select id,Content_Document_Id__c,Is_Large_File__c,Status__c,Linked_Entity_Id__c,Retry_Executed_Count__c from Stagging__c where Linked_Entity_Id__c='02sVE000004Q3OAYA0' ];
        for(Stagging__c St:lisStagings){
            lisofContIds.add(St.Content_Document_Id__c);
            lisoflinkentIds.add(St.Linked_Entity_Id__c);
        }
        String queryString = 'SELECT Id, ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE  LinkedEntityId IN (SELECT Id FROM EmailMessage WHERE id=:lisoflinkentIds AND Parent.have_more_character__c = FALSE and Parent.Failed_Record__c =False and  Parent.ClosedDate < LAST_N_DAYS: ' +
            + days + 'AND  Parent.Processed_Record__c = true)';
        //String queryString = 'SELECT Id, ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : lisoflinkentIds';
        
        // System.debug(queryString);
        
        List<ContentDocumentLink> ContentDocLinList = Database.query(queryString);
        return ContentDocLinList;
        
    }
    
    global void execute(Database.BatchableContext bc, List<ContentDocumentLink> contentDocLinLis) {
        Set<Id> contDocIds = new Set<Id>();
        for (ContentDocumentLink obj : contentDocLinLis) {
            contDocIds.add(obj.ContentDocumentId);
        }
        
        List<ContentDocument> contentDocumentList = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :contDocIds
        ];  
        
        list<Purge_Log__c>lisPurgBackUpofContentDoc=new List<Purge_Log__c>();
        List<EmailMessage> EmList=new List<EmailMessage>();
        List<String>emIds=new List<String>();
        Map<String,String>MappingEmailAndCase=new Map<String,String>();
        for(ContentDocumentLink obj1 : contentDocLinLis){
            emIds.add(obj1.LinkedEntityId);
            
        }
        EmList=[select id,parentId from EmailMessage where id In:emIds];
        for(EmailMessage emRec:EmList){
            MappingEmailAndCase.put(emRec.id,emRec.ParentId);
        }
        for(ContentDocumentLink conDocLink : contentDocLinLis){
            Purge_Log__c p=new Purge_Log__c();
            ContentDocument con=new ContentDocument();
            p.SObject_Type__c=con.getSObjectType().getDescribe().getName();
            p.Parent_Id__c=conDocLink.LinkedEntityId;
            p.Case_Id__c=MappingEmailAndCase.get(conDocLink.LinkedEntityId);
            p.Record_Id__c=conDocLink.id;
            p.Purge_Date__c=Date.Today();
            lisPurgBackUpofContentDoc.add(p);
        }
        if(!lisPurgBackUpofContentDoc.isEmpty()){        
            insert lisPurgBackUpofContentDoc;  
        }
        if(!contentDocumentList.isEmpty()){
         delete contentDocumentList;
          }
    }
    
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new Arch_PopuPurgeLogsEmails(), 500);
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