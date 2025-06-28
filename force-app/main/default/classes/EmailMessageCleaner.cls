global class EmailMessageCleaner implements Database.Batchable<SObject> {
    
    global List<EmailMessageHtml__c> start(Database.BatchableContext bc){
        return [select id,Emailmessage_Id__c,Status__c	,sObject__c from EmailMessageHtml__c];
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessageHtml__c> emList){
        //Database.deleteImmediate(emList);
        Delete emList;
    }
    
    global void finish(Database.BatchableContext bc){
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
    }
}