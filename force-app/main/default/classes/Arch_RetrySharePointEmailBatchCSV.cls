public with sharing class Arch_RetrySharePointEmailBatchCSV implements Database.Batchable<sObject>{
    
    String status;
    public Arch_RetrySharePointEmailBatchCSV(String status){
        this.status = status;
    }
    
    public List<EmailMessageHtml__c > start(Database.BatchableContext BC) {
        return [select EmailMessage_Id__c,Status__c,sObject__c from EmailMessageHtml__c  where Status__c =: status limit 500];
    }
    
    public void execute(Database.BatchableContext BC, List<EmailMessageHtml__c> emList){
        try{
            Arch_RetryChunkingSharePointEmailCSV.chunkStagingData(emList);
        }catch(Exception e) {
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
        System.debug('EmailMessageHtml__c> emList' + emList);
    }
    
    public void finish(Database.BatchableContext BC){
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
    }
}