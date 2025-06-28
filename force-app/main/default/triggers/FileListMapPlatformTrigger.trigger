trigger FileListMapPlatformTrigger on FileListMapPlatform__e (after insert) {
     //List<GetDataFromSharepoint_V2__e> sharePointList = new List<GetDataFromSharepoint_V2__e>();
    List<String> emailIdList = new List<String>();  
    System.debug('Code is inside Trigger class');
    for (FileListMapPlatform__e sharepointdata : Trigger.new) {
        
        String emailMessageIdFromSP = sharepointdata.fileDataPlatform__c;
        emailIdList.add(emailMessageIdFromSP);
        System.debug('Received platform event: ' + sharepointdata);
        System.debug('Received platform event: ' + sharepointdata.fileDataPlatform__c);
        
        GetFileUsingCaseSPId_V1Handler2.subscribeEvents(Trigger.new);
    }   

}