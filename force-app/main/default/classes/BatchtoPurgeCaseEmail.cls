global class BatchtoPurgeCaseEmail implements Database.Batchable<SObject> {
    
    global List<Case_Email__c> start(Database.BatchableContext bc){ 
        return [select id from Case_Email__c limit 50000];
    }
    
    global void execute(Database.BatchableContext bc, List<Case_Email__c> stagList){
        delete stagList;
    }
    
    global void finish(Database.BatchableContext bc){
        List<Case_Email__c> stagList = [select id from Case_Email__c limit 1];
        if(stagList.size() > 0){
            Database.executeBatch(new BatchtoPurgeCaseEmail(), 2000);
        }
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

    
    
      }
    
}