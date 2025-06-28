global class Arch_UpdateProcessedCaseRecord implements Database.Batchable<SObject> {
    
    
    global List<EmailMessage> start(Database.BatchableContext bc) { 
        String days=Label.DaysTo;
        
        String queryString = 'SELECT Id, Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber ' +
            'FROM EmailMessage ' +
            'WHERE ' + 
            'Parent.ClosedDate < LAST_N_DAYS: ' +
            + days + ' AND Parent.Have_More_Character__c = FALSE '+
            'And Parent.Failed_Record__c =False AND Parent.Processed_Record__c = false';  
        
        List<EmailMessage> emailList = Database.query(queryString);
        return emailList;
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailList){
        
        Set<Id> caseIds = new Set<Id>();
              
        for (EmailMessage email : emailList) {
            caseIds.add(email.ParentId);
        }
            
        List<Case> caseList = [Select id from case where id IN: caseIds];
        for(Case cs : caseList){
            cs.Processed_Record__c = TRUE;            
        }
        Update caseList;
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
}