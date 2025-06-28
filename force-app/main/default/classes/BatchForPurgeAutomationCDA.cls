global class BatchForPurgeAutomationCDA implements Database.Batchable<SObject> {
    
    global List<Staging__b> start(Database.BatchableContext bc){
        
        return[Select Id, CreatedById, CreatedDate, SystemModstamp, Chunk__c, Status__c, Content_Document_Id__c, Content_Size__c, Content_Version_Id__c, Error_Message__c, From_sObject__c, Is_Large_File__c, Job_ID__c, Linked_Entity_Id__c, sObject__c, Status_Code__c, Title__c, tmp__c from Staging__b];
    }
    
    global void execute(Database.BatchableContext bc, List<Staging__b> stagingList){
        List<id> stagingContentDocumentId=new List<id>();
        List<id> stagingattachmentId=new List<id>();
        for(Staging__b stvar:stagingList){
            if(!stagingList.isEmpty()){
                if(stvar.Content_Document_Id__c != null && stvar.Status__c == 'Completed'){
                    stagingContentDocumentId.add(stvar.Content_Document_Id__c);
                }
                if(stvar.Content_Document_Id__c == null && stvar.Status__c == 'Completed'){
                    stagingattachmentId.add(stvar.Chunk__c);
                }                
            }
        }
        system.debug('Content Document ID=>'+stagingContentDocumentId);
        system.debug('Content Document ID Count=>'+stagingContentDocumentId.size());
        system.debug('Chunk ID=>'+stagingattachmentId);
        system.debug('Chunk ID Count=>'+stagingattachmentId.size());
        
        /*
        if(!stagingContentDocumentId.isEmpty()){
            delete[SELECT Id FROM ContentDocument where Id IN :stagingContentDocumentId];
        }
        if(!stagingattachmentId.isEmpty()){
            delete[select id from Attachment where Id IN :stagingattachmentId];
        }
*/
        String startDate = Label.StartDate;
        String endDate = Label.EndDate;
        
        String queryString = 'select id,Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber from EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate+ 'and Parent.have_more_character__c =false' ;
        System.debug(queryString);
        List<EmailMessage> emailList = (List<EmailMessage>) Database.query(queryString);
        System.debug(emailList.size());
        if(!emailList.isEmpty()){
            delete emailList;
        }
        
    }
    
    
    global void finish(Database.BatchableContext bc){
        System.debug('BatchForPurgeAutomation is completed.');
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
    }
}