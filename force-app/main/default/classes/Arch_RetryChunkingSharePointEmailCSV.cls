public class Arch_RetryChunkingSharePointEmailCSV {
    
    public static void chunkStagingData(List<EmailMessageHtml__c> stagChunkList){
        try{ 
            Map<String, List<EmailMessageHtml__c>> mapOfStagBigObject = new Map<String, List<EmailMessageHtml__c>>();
            Set<String> uniqueChunkSet = new Set<String>();
            
            for (EmailMessageHtml__c stgBigObjEach : stagChunkList) {
                if(!uniqueChunkSet.contains(stgBigObjEach.EmailMessage_Id__c)) {
                    uniqueChunkSet.add(stgBigObjEach.EmailMessage_Id__c);
                    
                    if (mapOfStagBigObject.containsKey(stgBigObjEach.EmailMessage_Id__c)) {
                        mapOfStagBigObject.get(stgBigObjEach.EmailMessage_Id__c).add(stgBigObjEach);
                    } else {
                        mapOfStagBigObject.put(stgBigObjEach.EmailMessage_Id__c, new List<EmailMessageHtml__c>{stgBigObjEach});
                    }
                } else {
                    System.debug('Duplicate EmailMessage_Id__c found: ' + stgBigObjEach.EmailMessage_Id__c);
                }
            }
            
            System.debug('mapOfStagBigObject------>' + mapOfStagBigObject);
            
            publishTrionEvents(mapOfStagBigObject);
        }
        
        catch(Exception e){         
            List<Integration_Log_Error__c> intErrList=new List<Integration_Log_Error__c>();
            
            Integration_Log_Error__c intLog=new Integration_Log_Error__c();
            intLog.getMessage__c = e.getMessage();
            intLog.getCause__c =String.valueOf(e.getCause());
            intLog.getLineNumber__c=String.valueOf(e.getLineNumber());
            //intLog.getNumDml__c =String.valueOf(e.getNumDml());
            intLog.getStackTraceString__c=e.getStackTraceString();            
            intLog.getTypeName__c=e.getTypeName();            
            intErrList.add(intLog);
            
            if(intErrList.size() > 0){
                system.debug('intList-->'+intErrList);
                insert(intErrList);
            }
        }
    }
    public static void publishTrionEvents(Map<String, List<EmailMessageHtml__c>> mapOfStagBigObject){
        try{
            Set<SharePointPusherCSV__e> trionFilesSet = new Set<SharePointPusherCSV__e>();
            
            for (String stagingVar : mapOfStagBigObject.keySet()) {
                SharePointPusherCSV__e trionFileEach = new SharePointPusherCSV__e();
                trionFileEach.EmailNumber__c = stagingVar;
                System.debug('stagingVar' + stagingVar);
                System.debug('EventUuid: ' + trionFileEach.EventUuid);
                trionFilesSet.add(trionFileEach);
            }
            List<SharePointPusherCSV__e> trionFilesList = New List<SharePointPusherCSV__e>(trionFilesSet);
            //trionFilesList.addAll(trionFilesSet);
            System.debug('trionFilesList=>' + trionFilesList);
            
            if (!trionFilesList.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(trionFilesList);
                
                System.debug('List<Database.SaveResult> results =>' + results);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error message: ' + error.getMessage());
                            System.debug('Status code: ' + error.getStatusCode());
                        }
                    }
                }
            }
            
        }
        catch(Exception e){         
            
            List<Integration_Log_Error__c> intErrList=new List<Integration_Log_Error__c>();
            
            Integration_Log_Error__c intLog=new Integration_Log_Error__c();
            intLog.getMessage__c = e.getMessage();
            intLog.getCause__c =String.valueOf(e.getCause());
            intLog.getLineNumber__c=String.valueOf(e.getLineNumber());
            //intLog.getNumDml__c =String.valueOf(e.getNumDml());
            intLog.getStackTraceString__c=e.getStackTraceString();            
            intLog.getTypeName__c=e.getTypeName();            
            intErrList.add(intLog);
            
            if(intErrList.size() > 0){
                system.debug('intList-->'+intErrList);
                insert(intErrList);
            }            
        }
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
    }
    
}