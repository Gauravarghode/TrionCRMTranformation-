trigger Arch_SharePointPusherTriggerFA on SharePointPusher__e (after insert) {
    if(trigger.isInsert&& trigger.isAfter){
        
        String status;
        
        String emailMessageId;
        Decimal retryRequiredCount;
        for (SharePointPusher__e trionFile : Trigger.new) {
            System.debug('Received platform event: ' + trionFile);
            emailMessageId = trionFile.ChunkNumber__c;        
        }
        status  =[select Id,  Chunk__c, Content_Document_Id__c, Content_Version_Id__c, Error_Message__c, Job_ID__c, Linked_Entity_Id__c, Status__c, Title__c, tmp__c from Stagging__c  WHERE Chunk__c =:emailMessageId].Status__c;
        retryRequiredCount = [select Id,  Chunk__c, Content_Document_Id__c, Content_Version_Id__c, Error_Message__c, Job_ID__c, Linked_Entity_Id__c, Status__c, Title__c, tmp__c,Retry_Executed_Count__c from Stagging__c  WHERE Chunk__c =:emailMessageId].Retry_Executed_Count__c;
        
        if(status ==  'Not Started'  || status == 'Pending'){
            Arch_SharePointPusherHandlerFA.subscribeEvents(trigger.new);
        }
        
        if(retryRequiredCount == 1 && (status ==  'Retry Required' || status == 'Pending')){            
            Arch_RetrySharePointPusherHandlerFA.subscribeEvents(trigger.new);
        }
        
    }
}