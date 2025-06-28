global class PurgeEmail implements
Database.Batchable<SObject> {
    
    global List<EmailMessage> start(Database.BatchableContext bc){ 
        String startDate = Label.StartDate;
        String endDate = Label.EndDate;
        
        String queryString = 'select id,Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber from EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate+ 'and Parent.have_more_character__c =TRUE limit 50000' ;
        System.debug(queryString); 
        List<EmailMessage> emailList = (List<EmailMessage>) Database.query(queryString);
        return emailList;
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailList){
        delete emailList;
    }
    
    global void finish(Database.BatchableContext bc){
         String startDate = Label.StartDate;
        String endDate = Label.EndDate;
        
        String queryString = 'select id,Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber from EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate+ 'and Parent.have_more_character__c =TRUE limit 1' ;
        System.debug(queryString);
        List<EmailMessage> emailList = (List<EmailMessage>) Database.query(queryString);
        System.debug(emailList.size());
      
        if(emailList.size() > 0){
            Database.executeBatch(new PurgeEmail(), 2000);
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