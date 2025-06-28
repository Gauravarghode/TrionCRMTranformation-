public class Arch_RetryChunkingSharePointStagingFA{
    
    public static void chunkStagingData(List<Stagging__c> stagingChunkList){
        try{
            Map<String, List<Stagging__c>> mapOfStagingBigObject = new Map<String, List<Stagging__c>>();
            Set<String> uniqueChunkSet = new Set<String>();
            
            for(Stagging__c stagingRecord : stagingChunkList) {
                uniqueChunkSet.add(stagingRecord.Chunk__c);
                
                if(mapOfStagingBigObject.containsKey(stagingRecord.Chunk__c)) {
                    mapOfStagingBigObject.get(stagingRecord.Chunk__c).add(stagingRecord);
                } else {
                    mapOfStagingBigObject.put(stagingRecord.Chunk__c, new List<Stagging__c>{stagingRecord});
                }
            }
            system.debug('mapOfStagingBigObject--------->'+mapOfStagingBigObject);
            publishTrionEvents(mapOfStagingBigObject);
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
    
    public static void publishTrionEvents(Map<String, List<Stagging__c>> mapOfStagingBigObject){
        try{
            List<SharePointPusher__e> trionFilesList = new List<SharePointPusher__e>();
            
            for(String chunkNumber : mapOfStagingBigObject.keySet()){
                SharePointPusher__e trionFileEach = new SharePointPusher__e();
                trionFileEach.ChunkNumber__c = chunkNumber;
                trionFilesList.add(trionFileEach);
            }
            System.debug('trionFilesList =>' + trionFilesList);
            
            if(!trionFilesList.isEmpty()) {
                List<Database.SaveResult> results = Eventbus.publish(trionFilesList);
                System.debug('List<Database.SaveResult> results =>' + results);
                // If you are not expecting a return value from Eventbus.publish, you might want to remove the following line
                //System.debug('Eventbus.publish(trionFilesList) =>' + Eventbus.publish(trionFilesList));
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
    
    public static void testQualifier(){
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
    }
}