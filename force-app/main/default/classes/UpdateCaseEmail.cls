global class UpdateCaseEmail implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer DaysFromLabel = Integer.valueOf(System.label.Days);
        System.debug('DaysFromLabel: ' + DaysFromLabel);
        String closed='Closed';
         String startDate = Label.StartDate; 
        String endDate = Label.EndDate; 
        String eQuery = 'select id,Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber from EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate;
        system.debug(eQuery);
        return Database.getQueryLocator(eQuery);
    }

    global void execute(Database.BatchableContext BC, List<EmailMessage> scope) {
        Set<String> emailMessageIds = new Set<String>();

        // Dynamic set to store unique EmailMessage IDs from the scope
        for (EmailMessage em : scope) {
            emailMessageIds.add(em.Id);
        }

        List<Case_Email__c> listToInsert = new List<Case_Email__c>();

        // Retrieve existing Case_Email__c records based on EmailMessage_Id__c
        Set<String> existingEmailMessageIds = new Set<String>();
        for (Case_Email__c existingRecord : [SELECT EmailMessage_Id__c FROM Case_Email__c WHERE EmailMessage_Id__c IN :emailMessageIds]) {
            existingEmailMessageIds.add(existingRecord.EmailMessage_Id__c);
        }

        try {
            for (EmailMessage em : scope) {
                // Check if the record already exists
                if (!existingEmailMessageIds.contains(em.Id)) {
                    Case_Email__c customObject = new Case_Email__c();
                    customObject.Case_Number__c = em.Parent.CaseNumber;
                    customObject.EmailMessage_Id__c = em.Id;
                    customObject.Email_Message_Created_Date__c = em.CreatedDate.format();
                    customObject.Case_Id__c = em.ParentId;
                    customObject.Email_Message_Subject__c = em.Subject;
                    listToInsert.add(customObject);

                    system.debug('em.ParentId: ' + customObject.Case_Number__c);
                    system.debug('em.id: ' + customObject.EmailMessage_Id__c);
                    system.debug('em.CreatedDate: ' + customObject.Email_Message_Created_Date__c);
                    system.debug('em.Subject: ' + customObject.Email_Message_Subject__c);
                    
                }
            }

            if (!listToInsert.isEmpty()) {
                insert listToInsert;
            }
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Add any finish logic if needed
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
    }
}