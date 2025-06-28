trigger GetDataFromSHarePointTrigger on GetDataFromSharepoint__e (after insert) {
    List<GetDataFromSharepoint__e> sharePointList = new List<GetDataFromSharepoint__e>();
    List<String> emailIdList = new List<String>();  
    for (GetDataFromSharepoint__e sharepointdata : Trigger.new) {
        String emailMessageIdFromSP = sharepointdata.Emailid__c;
        emailIdList.add(emailMessageIdFromSP);
        String emailParentCaseId =  sharepointdata.ParentCaseId__c;                                                         
        System.debug('Received platform event: ' + sharepointdata);
        System.debug('Received platform event: ' + sharepointdata.Emailid__c);
        System.debug('Received platform event: ' + sharepointdata.ParentCaseId__c);
        
        GetFileUsingCaseSPId_V1Handler.subscribeEvents(trigger.new, emailParentCaseId);
    }   
    
}