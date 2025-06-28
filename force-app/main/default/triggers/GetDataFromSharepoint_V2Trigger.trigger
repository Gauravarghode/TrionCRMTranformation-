trigger GetDataFromSharepoint_V2Trigger on GetDataFromSharepoint_V2__e (after Insert) {
     //List<GetDataFromSharepoint_V2__e> sharePointList = new List<GetDataFromSharepoint_V2__e>();
    List<String> emailIdList = new List<String>();  
    System.debug('Code is inside Trigger class');
    for (GetDataFromSharepoint_V2__e sharepointdata : Trigger.new) {
        
        String emailMessageIdFromSP = sharepointdata.EmailIdFromSP__c;
        emailIdList.add(emailMessageIdFromSP);
        String emailParentCaseId =  sharepointdata.ParentCaseId__c;                                                         
        System.debug('Received platform event: ' + sharepointdata);
        System.debug('Received platform event: ' + sharepointdata.EmailIdFromSP__c);
        System.debug('Received platform event: ' + sharepointdata.ParentCaseId__c);
        
        //GetCsvUsingCaseSPId_checkV12Handler.subscribeEvents(Trigger.new, emailParentCaseId);
        GetCsvUsingCaseSPId_checkV12Handler_V2.subscribeEvents(Trigger.new, emailParentCaseId);
    }   

}