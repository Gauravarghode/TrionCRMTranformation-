trigger Arch_SharePointPusherTriggerCSV on SharePointPusherCSV__e (after insert) {
    if(trigger.isInsert&& trigger.isAfter){
        
        String status;
        
        String emailMessageId;
        Decimal retryRequiredCount;
        for (SharePointPusherCSV__e trionFile : Trigger.new) {
            System.debug('Received platform event: ' + trionFile);
            emailMessageId = trionFile.EmailNumber__c;        
        }
        status = [select Id,  EmailMessage_Id__c, Parent_Case_Id__c, Status__c, Title__c, Upload_Failed__c, Retry_Executed_Count__c from EmailMessageHtml__c  WHERE EmailMessage_Id__c =:emailMessageId].Status__c;
        retryRequiredCount = [select Id,  EmailMessage_Id__c, Parent_Case_Id__c, Status__c, Title__c, Upload_Failed__c, Retry_Executed_Count__c from EmailMessageHtml__c  WHERE EmailMessage_Id__c =:emailMessageId].Retry_Executed_Count__c;
        
        if(status ==  'Not Started'  || status == 'Pending'){
            Arch_SharePointPusherHandlerCSV.subscribeEvents(trigger.new);
        }
        if(retryRequiredCount == 1 && (status ==  'Retry Required' || status == 'Pending')){            
            Arch_RetrySharePointPusherHandlerCSV.subscribeEvents(trigger.new);
        }
    }
}