trigger ListMapPlatformTrigger_V2 on ListMapPlatform_V2__e (after insert) {
    
    List<String> emailIdList = new List<String>();  
    System.debug('Code is inside Trigger class');
    for (ListMapPlatform_V2__e sharepointdata : Trigger.new) {
        
        String emailMessageIdFromSP = sharepointdata.Id__c;
        String emailMessageParentIdFromSP = sharepointdata.ParentId__c;
        String emailMessageCreateddateFromSP = sharepointdata.CreatedDate__c;
        String emailMessageCreatedByFromSP = sharepointdata.CreatedById__c;
        String emailMessageSubjectFromSP = sharepointdata.Subject__c;
        String emailMessageFromAddressFromSP = sharepointdata.FromAddress__c;
        String emailMessageToAddressFromSP = sharepointdata.ToAddress__c;
        String emailMessageBccAddressFromSP = sharepointdata.BccAddress__c;
        String emailMessageHtmlBodyFromSP = sharepointdata.HtmlBody__c;
        String emailMessageStatusFromSP = sharepointdata.Status__c;
        String emailMessageTextBodyFromSP = sharepointdata.TextBody__c;
        String emailMessageHeaderFromSP = sharepointdata.Headers__c;
        String emailMessageMessageDateFromSP = sharepointdata.MessageDate__c;
        
        emailIdList.add(emailMessageIdFromSP);
        emailIdList.add(emailMessageParentIdFromSP);
        emailIdList.add(emailMessageCreateddateFromSP);
        emailIdList.add(emailMessageCreatedByFromSP);
        emailIdList.add(emailMessageSubjectFromSP);
        emailIdList.add(emailMessageFromAddressFromSP);
        emailIdList.add(emailMessageToAddressFromSP);
        emailIdList.add(emailMessageBccAddressFromSP);
        emailIdList.add(emailMessageHtmlBodyFromSP);
        emailIdList.add(emailMessageStatusFromSP);
        emailIdList.add(emailMessageTextBodyFromSP);
        emailIdList.add(emailMessageHeaderFromSP);
        emailIdList.add(emailMessageMessageDateFromSP);
        
        
        System.debug('List<String> emailIdList===> '+emailIdList);
        //String emailParentCaseId =  sharepointdata.ParentCaseId__c;                                                         
        System.debug('Received platform event: ' + sharepointdata);
        System.debug('Received platform event: ' + sharepointdata.Id__c);
        //System.debug('Received platform event: ' + sharepointdata.ParentCaseId__c);
        
        GetCsvUsingCaseSPId_checkV12Handler2_V2.subscribeEvents(Trigger.new);
    }   
    
    
}