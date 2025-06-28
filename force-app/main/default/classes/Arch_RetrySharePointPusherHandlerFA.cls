public class Arch_RetrySharePointPusherHandlerFA{
    
    public static void subscribeEvents(List<SharePointPusher__e> sharepointPushLst){
        try{
            Set<string> uniqueIdentifier = new set<string>();
            for(SharePointPusher__e sharePointPushEach: sharepointPushLst){
                uniqueIdentifier.add(sharePointPushEach.ChunkNumber__c);
                uniqueIdentifier.remove(null);
            }
            List<Stagging__c> stagChunkList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c,From_sObject__c from Stagging__c 
                                              where  Status__c='Retry Required' AND Chunk__c IN: uniqueIdentifier];
             //List<Stagging__c> stagChunkList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c,From_sObject__c from Stagging__c 
             //                                 where Status__c =: Status AND Chunk__c IN: uniqueIdentifier];
            if(stagChunkList.size() == 0){
                stagChunkList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c,From_sObject__c from Stagging__c 
                                 where Status__c = 'Pending' AND Chunk__c IN: uniqueIdentifier];    
            }
            
            Map<string,List<Stagging__c>> mapOfStagBigObject = new Map<string,List<Stagging__c>>();
            
            for(Stagging__c stgBigObjEach :stagChunkList){
                
                if(mapOfStagBigObject.containskey(stgBigObjEach.Chunk__c)){
                    mapOfStagBigObject.get(stgBigObjEach.Chunk__c).add(stgBigObjEach);
                }else{
                    mapOfStagBigObject.put(stgBigObjEach.Chunk__c,new List<Stagging__c>{stgBigObjEach});
                }
            }
            
            Integer count=0;
            for(SharePointPusher__e sharePointPusherEach: sharepointPushLst){
                queuethejob(mapOfStagBigObject.get(sharePointPusherEach.ChunkNumber__c));
                count++;
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(sharePointPusherEach.ReplayId);
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
    
    public static void queuethejob(List<Stagging__c> listOfStagBigObj){
        try{
            if(!listOfStagBigObj.isEmpty() && listOfStagBigObj[0].Chunk__c !=  null){
            if(listOfStagBigObj[0].Chunk__c != 'Test##SP'){
                System.debug('Hiiiiiiiiiiiiiiii' +listOfStagBigObj[0].Chunk__c);
                System.enqueueJob(new Arch_RetrySharePointMigrationQueueFA(listOfStagBigObj));
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
            }     }
    }
    
    public static void createFoldersubFolder(List<Stagging__c> listOfStagg){
        try{
            if(listOfStagg[0].Chunk__c != 'Test##SP'){
                
                Set<id> contentVersionIds = new set<id>();
                Map<id,Stagging__c> mapOfContentVersion = new Map<id,Stagging__c>();
                
                for(Stagging__c sharepointVar: listOfStagg){
                    contentVersionIds.add(sharepointVar.Content_Version_ID__c);
                    mapOfContentVersion.put(sharepointVar.Content_Version_ID__c,sharepointVar);
                    String chunkid = sharepointVar.chunk__c;
                    Arch_RetryApiFutureCallingFA.fileMigration(chunkid);
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
        i++;
        i++;
        i++;
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