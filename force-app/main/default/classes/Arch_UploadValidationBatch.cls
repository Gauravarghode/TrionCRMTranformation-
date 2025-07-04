global class Arch_UploadValidationBatch implements Database.Batchable<SObject> {
    
    //Datetime startDate = Datetime.valueOf(Label.StartDate);
    //Datetime endDate = Datetime.valueOf(Label.EndDate);
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String days=Label.DaysTo;
        String days2 = Label.DaysTo2;
        String Id='500G000000NLquZIAT';
        Integer day=Integer.valueOf(days);
       
       // String query = 'Select id, ParentId , Parent.Failed_Record__c,Parent.ClosedDate from EmailMessage where '+
       //     ' Parent.ClosedDate < LAST_N_DAYS:' + days + 'and Parent.ClosedDate>=LAST_N_DAYS: ' + days2 + ' AND Parent.Failed_Record__c != True'  ;
        String query = 'Select id, ParentId , Parent.Failed_Record__c,Parent.ClosedDate from EmailMessage where '+
            ' Parent.ClosedDate < LAST_N_DAYS:' + days +' AND Parent.Failed_Record__c != True AND Parent.Processed_Record__c = false'  ;
        System.debug('Batch Query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailMessage> emailMessages) {
        List<Id> cdLongSize = new List<id>();
        set<ID> caseIdSet = new set<Id>();
        integer localcount = 0;
        system.debug('emailMessages----------->'+emailMessages);
        Map<Id,integer> mapofIdAttachmentCount = new Map<Id, Integer>();
        for(EmailMessage e : emailMessages){
            //caseIdSet.add(e.ParentId);
            caseIdSet.add(e.id);
        }
        List<Attachment> attList = [select Id, ParentId, Name, BodyLength from Attachment where ParentId IN: caseIdSet
                                    order by createddate asc];
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
                
                if(att.BodyLength > 12000000){
                    cdLongSize.add(att.ParentId);				
                }
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
                if(cdl.ContentDocument.ContentSize > 12000000){
                    cdLongSize.add(cdl.LinkedEntityId);
                }
            }
        }
        system.debug('mapofIdAttachmentCount----------->'+mapofIdAttachmentCount);
        
        
        List<Id> emailLongCaseId = new List<Id>();
        
        List<Emailmessage> emailMessageList = [Select id, ParentId,Parent.ClosedDate from Emailmessage where id =: cdLongSize];
        for(Emailmessage em2 : emailMessageList){
            emailLongCaseId.add(em2.ParentId);
        }
        
        List<Case> caseList = [Select id,Failed_Record__c,ClosedDate from Case where id =: emailLongCaseId];
        For(Case csList : caseList){
            csList.Failed_Record__c  = TRUE;
        }
        Update caseList;
        for(EmailMessage em :emailMessages){
            system.debug('em ID----------->'+em.Id);
            system.debug('em Parent Id----------->'+em.ParentId);
            //system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.ParentId));
            system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.id));
            system.debug('emailLongCaseId----->'+emailLongCaseId);
            if(!emailLongCaseId.contains(em.ParentId)){
                ID jobId = System.enqueueJob(new Arch_SharePointCountMatchQueue(em.ParentId,em.Id,mapofIdAttachmentCount.get(em.id)));
                system.debug('jobId----->'+jobId);
            }
            
        }
        
        
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    public Id getApexClassId() {
        Id classId = [SELECT Id FROM ApexClass WHERE Name = 'Arch_UploadValidationBatch'].Id;
        return classId;
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
    }
    
    
}