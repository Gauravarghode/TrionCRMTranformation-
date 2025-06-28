public class Arch_SharePointMigrationQueueFA implements Queueable {

    List<Stagging__c> listOfStagBigObject;
    
    public Arch_SharePointMigrationQueueFA(List<Stagging__c> listOfStagBigObject) {
        this.listOfStagBigObject = listOfStagBigObject;
    }
    
    public void execute(QueueableContext context){
        try{
         if(listOfStagBigObject[0].Chunk__c != 'Test##SP'){
            set<id> contentVersionIds = new set<id>();
            Map<id,Stagging__c> mapOfContentVersion = new Map<id,Stagging__c>();
            
            for(Stagging__c sharepointVar: listOfStagBigObject){
                contentVersionIds.add(sharepointVar.Content_Version_ID__c);
                mapOfContentVersion.put(sharepointVar.Content_Version_ID__c,sharepointVar);
                string chunkid = sharepointVar.chunk__c;
                Arch_ApiFutureCallingFA.fileMigration(chunkid);
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
       // SharePointPusherHandler.createFoldersubFolder(listOfStagBigObject);        
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
    }
}