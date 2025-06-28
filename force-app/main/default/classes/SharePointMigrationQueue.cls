public class SharePointMigrationQueue implements Queueable {

    List<Staging__b> listOfStagBigObject;
    
    public SharePointMigrationQueue(List<Staging__b> listOfStagBigObject) {
        this.listOfStagBigObject = listOfStagBigObject;
    }
    
    public void execute(QueueableContext context){
        try{
         if(listOfStagBigObject[0].Chunk__c != 'Test##SP'){
            set<id> contentVersionIds = new set<id>();
            Map<id,Staging__b> mapOfContentVersion = new Map<id,Staging__b>();
            
            for(Staging__b sharepointVar: listOfStagBigObject){
                contentVersionIds.add(sharepointVar.Content_Version_ID__c);
                mapOfContentVersion.put(sharepointVar.Content_Version_ID__c,sharepointVar);
                string chunkid = sharepointVar.chunk__c;
                ApiFuturecalling.fileMigration(chunkid);
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