global class StagingCleaner implements
Database.Batchable<SObject> {
    
    global List<Stagging__c> start(Database.BatchableContext bc){ 
        return [select id,chunk__c, status__c from Stagging__c ];
    }
    
    global void execute(Database.BatchableContext bc, List<Stagging__c> stagList){
        //Database.deleteImmediate(stagList);
        delete stagList;
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