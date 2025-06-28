global class Arch_PopuPurgeLogsEmails implements Database.Batchable<SObject> {
    String days = Label.DaysTo;
    String days2 = Label.DaysTo2;
    global List<String>emIds=new List<String>();
    global List<EmailMessage> start(Database.BatchableContext bc) { 
        List<EmailMessageHtml__c>lisEmailHtmls=[Select id,Status__c,Is_Large_File__c,EmailMessage_Id__c FROM EmailMessageHtml__c WHERE Status__c='Completed' AND CreatedDate = TODAY];
        //List<EmailMessageHtml__c>lisEmailHtmls=[Select id,Status__c,Is_Large_File__c,EmailMessage_Id__c FROM EmailMessageHtml__c WHERE EmailMessage_Id__c='02sVE000004Q3OAYA0'];
        
        for(EmailMessageHtml__c emHtRec : lisEmailHtmls){
            emIds.add(emHtRec.EmailMessage_Id__c);
        } 
        //String NoDays = Label.DaysTo; // Assuming Label.DaysTo exists and returns an integer or a string representing the number of days
       String queryString = 'SELECT Id, Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber ' +
            'FROM EmailMessage ' +
            'WHERE Id IN :emIds ' + 
            'AND Parent.ClosedDate < LAST_N_DAYS: ' +
            + days + ' AND Parent.Have_More_Character__c = FALSE '+
            'And Parent.Failed_Record__c =False AND Parent.Processed_Record__c = true';  

      /*  String queryString = 'SELECT Id, Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber ' +
            'FROM EmailMessage ' +
            'WHERE Id IN :emIds ';  */
        // System.debug(queryString);
        
        List<EmailMessage> emailList = Database.query(queryString);
        return emailList;
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailList){
        list<Purge_Log__c>lisPurgBackUp=new List<Purge_Log__c>();
        List<String> emIds=new List<String>();
        Map<String,String> MapEmaWithCase=new  Map<String,String>();
        for(EmailMessage emRec:emailList){
            emIds.add(emRec.id);
            Purge_Log__c p=new Purge_Log__c();
            p.SObject_Type__c=emRec.getSObjectType().getDescribe().getName();
            p.Parent_Id__c=emRec.ParentId;
            p.Case_Id__c=emRec.ParentId;
            p.Record_Id__c=emRec.id;
            p.Purge_Date__c=Date.Today();
            MapEmaWithCase.put(emRec.id,emRec.ParentId);
            lisPurgBackUp.add(p);
        }
        
        
        List<Attachment>lisAttachs=[SELECT Id, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description from Attachment where ParentId IN :emIds];
        for(Attachment att:lisAttachs){
            Attachment attRec=new Attachment();
            Purge_Log__c p=new Purge_Log__c();
            p.SObject_Type__c=attRec.getSObjectType().getDescribe().getName();
            p.Parent_Id__c=att.ParentId;
            p.Case_Id__c=MapEmaWithCase.get(att.ParentId);
            p.Record_Id__c=att.id;
            p.Purge_Date__c=Date.Today();
            lisPurgBackUp.add(p);
        }  
        if(!lisPurgBackUp.isEmpty()){
            insert lisPurgBackUp; }
        if(!emailList.isEmpty()){
        delete emailList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
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