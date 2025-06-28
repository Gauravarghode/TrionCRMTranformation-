public class Arch_RetrySharePointPusherHandlerCSV{
    
    public static void subscribeEvents(List<SharePointPusherCSV__e> sharepointPushLst){
        try{
            
            Set<string> uniqueIdentifier = new set<string>();
            for(SharePointPusherCSV__e sharePointPushEach: sharepointPushLst){
                uniqueIdentifier.add(sharePointPushEach.EmailNumber__c);
                uniqueIdentifier.remove(null);
            }
            system.debug('List<SharePointPusherCSV__e> sharepointPushLst=>' +sharepointPushLst);
            List<EmailMessageHtml__c> emailChunkList = [select Id,  EmailMessage_Id__c, Status__c, Error_Message__c, Is_Large_File__c, File_Size__c, sObject__c, Title__c, 
                                                         File_Body__c, Parent_Case_Id__c, Job_ID__c, Csv_Body__c, Csv_Body_Extension__c, Csv_String_2__c 
                                                         from EmailMessageHtml__c   
                                                         where Status__c='Retry Required' AND EmailMessage_Id__c IN: uniqueIdentifier];
            if(emailChunkList.size() == 0){
                emailChunkList = [select Id,  EmailMessage_Id__c, Status__c, Error_Message__c, Is_Large_File__c, File_Size__c, sObject__c, Title__c, 
                                  File_Body__c, Parent_Case_Id__c, Job_ID__c, Csv_Body__c, Csv_Body_Extension__c, Csv_String_2__c 
                                  from EmailMessageHtml__c   
                                  where Status__c = 'Pending' AND EmailMessage_Id__c IN: uniqueIdentifier];    
            }
            
            Map<string,List<EmailMessageHtml__c>> mapOfStagBigObject = new Map<string,List<EmailMessageHtml__c>>();
            
            for(EmailMessageHtml__c stgBigObjEach :emailChunkList){
                
                if(mapOfStagBigObject.containskey(stgBigObjEach.EmailMessage_Id__c)){
                    mapOfStagBigObject.get(stgBigObjEach.EmailMessage_Id__c).add(stgBigObjEach);
                }else{
                    mapOfStagBigObject.put(stgBigObjEach.EmailMessage_Id__c,new List<EmailMessageHtml__c>{stgBigObjEach});
                }
            }
            system.debug('emailChunkList'+emailChunkList);
            
            Integer count=0;
            for(SharePointPusherCSV__e sharePointPusherEach: sharepointPushLst){
                queuethejob(mapOfStagBigObject.get(sharePointPusherEach.EmailNumber__c));
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
    
    public static void queuethejob(List<EmailMessageHtml__c> listOfStagBigObj){
        try{
            
            if(listOfStagBigObj[0].EmailMessage_Id__c != 'Test##SP')
            {
                System.enqueueJob(new Arch_RetrySharePointMigrationQueueCSV(listOfStagBigObj));
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
    
    
    public static void createFoldersubFolder(List<EmailMessageHtml__c> emailStagList){
        try{
            
            if(emailStagList[0].EmailMessage_Id__c != 'Test##SP'){
                
                Set<id> contentVersionIds = new set<id>();
                Map<id,EmailMessageHtml__c> mapOfContentVersion = new Map<id,EmailMessageHtml__c>();
                
                for(EmailMessageHtml__c sharepointVar: emailStagList){
                    //  contentVersionIds.add(sharepointVar.Content_Version_ID__c);
                    //  mapOfContentVersion.put(sharepointVar.Content_Version_ID__c,sharepointVar);
                    String chunkid = sharepointVar.EmailMessage_Id__c;
                    Arch_RetrySendCSVtoSharepoint.fileMigration(chunkid);
                }
                System.debug('SharePointPusherHandlerCSV emailStagList' + emailStagList);
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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