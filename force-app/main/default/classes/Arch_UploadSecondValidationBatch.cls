global class Arch_UploadSecondValidationBatch implements Database.Batchable<SObject> {
    //Datetime startDate = Datetime.valueOf(Label.StartDate);
    //Datetime endDate = Datetime.valueOf(Label.EndDate);
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'SELECT Id, Status FROM Case WHERE Status = \'Closed\' AND ClosedDate < LAST_N_DAYS:90 AND Id =: idi';
        /*String query = 'SELECT Id, Status FROM Case WHERE Status = \'Closed\' ' + 
'AND ClosedDate < LAST_N_DAYS:90 ' +
'AND CreatedDate > ' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + 
' AND CreatedDate < ' + endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); */
        //String query = 'Select id, ParentId from EmailMessage where ParentId=:idi AND Parent.Status = \'Closed\' ' + 
        //               'AND Parent.ClosedDate < LAST_N_DAYS:90 ' ;
        // String query = 'Select id, ParentId from EmailMessage where ParentId=:idi AND Parent.Status = \'Closed\' ' ;
        //String query = 'Select id,  EmailMessage_Id__c, Parent_Case_Id__c from EmailMessageHtml__c where Retry_Executed_Count__c =1 ' ;
    /*    String query = 'select Id,Chunk__c, Content_Document_Id__c, Content_Size__c, Content_Version_Id__c, Error_Message__c,'
            +	'From_sObject__c, Is_Large_File__c, Job_ID__c, Linked_Entity_Id__c, sObject__c, Status__c, Status_Code__c,'
            +	'Title__c, tmp__c, Upload_Failed__c, Retry_Executed_Count__c from Stagging__c where Retry_Executed_Count__c =1 ' ;
    */    
        String query = 'select Id,Chunk__c, Content_Document_Id__c, Content_Size__c, Content_Version_Id__c, Error_Message__c,'
            +	'From_sObject__c, Is_Large_File__c, Job_ID__c, Linked_Entity_Id__c, sObject__c, Status__c, Status_Code__c,'
            +	'Title__c, tmp__c, Upload_Failed__c, Retry_Executed_Count__c from Stagging__c where Retry_Executed_Count__c = 1 AND CreatedDate = TODAY' ;
        
        //  String query = 'Select id, ParentId from EmailMessage where  Parent.CreatedDate =TODAY  and Parent.Status = \'Closed\' ';
        //String query = 'Select id, ParentId from EmailMessage where Parent.ClosedDate  >= 2024-09-12T00:00:00Z  AND Parent.ClosedDate  < 2024-09-13T00:00:00Z';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Stagging__c> stagging) {

        
        set<ID> caseIdSet = new set<Id>();
        integer localcount = 0;
        system.debug('emailMessages----------->'+stagging);
        Map<Id,integer> mapofIdAttachmentCount = new Map<Id, Integer>();
        for(Stagging__c s : stagging){
            //caseIdSet.add(e.ParentId);
            caseIdSet.add(s.Linked_Entity_Id__c);
        }
        
        List<Attachment> attList = [select Id, ParentId, Name, BodyLength from Attachment where ParentId IN: caseIdSet order by createddate asc];
        //List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: caseIdSet and ContentDocument.CreatedDate = LAST_N_DAYS:10 ];
        //List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId, ContentDocument.ContentSize from ContentDocumentLink where LinkedEntityId IN: caseIdSet AND ContentDocument.ContentSize <12000000 ];
        List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId, ContentDocument.ContentSize from ContentDocumentLink where LinkedEntityId IN: caseIdSet];
        
        system.debug('attList----------->'+attList);
        system.debug('cdlList----------->'+cdlList);
        if(!attList.isEmpty()){
            for(Attachment att : attList){
                if(!mapofIdAttachmentCount.keySet().contains(att.ParentId)){
                    localcount = 1;
                }
                else{
                    ++localcount;
                }
                mapofIdAttachmentCount.put(att.ParentId,localcount); //map of case Id and attachment and Content document records
            }
        }
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cdl : cdlList ){
                if(!mapofIdAttachmentCount.keySet().contains(cdl.LinkedEntityId)){
                    localcount = 1;
                }
                else{
                    ++localcount;
                }
                mapofIdAttachmentCount.put(cdl.LinkedEntityId,localcount); //map of case Id and attachment and Content document records
            }
        }
        system.debug('mapofIdAttachmentCount----------->'+mapofIdAttachmentCount);
        
        
        string emailid;
        string parentcaseid;
        list<Emailmessage> emailList = [Select id,parentid from emailmessage where id =: caseIdSet ];
        for(Emailmessage e : emailList){
            emailid=e.Id;
            parentcaseid=e.ParentId;
            system.debug('em ID----------->'+emailid);
            system.debug('em Parent Id----------->'+parentcaseid);
            //system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.ParentId));
            system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(emailid));
            //ID jobId = System.enqueueJob(new SharePointCountMatchQueueable(em.ParentId,em.Id,mapofIdAttachmentCount.get(em.ParentId)));
            ID jobId = System.enqueueJob(new Arch_SharePointSecondCountQueue(parentcaseid,emailid,mapofIdAttachmentCount.get(emailid)));
            system.debug('jobId----->'+jobId);
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        Arch_UploadSecondValidationEmail usve = new Arch_UploadSecondValidationEmail();
        Database.executeBatch(usve, 1);         
    }
}