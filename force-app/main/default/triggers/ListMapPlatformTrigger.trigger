trigger ListMapPlatformTrigger on ListMapPlatform__e (after insert) {
    
    List<String> emailIdList = new List<String>();  
    System.debug('Code is inside Trigger class');
    for (ListMapPlatform__e sharepointdata : Trigger.new) {
        
        String emailMessageIdFromSP = sharepointdata.csvInfoList__c;
        emailIdList.add(emailMessageIdFromSP);
        //String emailParentCaseId =  sharepointdata.ParentCaseId__c;                                                         
        System.debug('Received platform event: ' + sharepointdata);
        System.debug('Received platform event: ' + sharepointdata.csvInfoList__c);
        //System.debug('Received platform event: ' + sharepointdata.ParentCaseId__c);
        
        GetCsvUsingCaseSPId_checkV12Handler2.subscribeEvents(Trigger.new);
    }   
   
}