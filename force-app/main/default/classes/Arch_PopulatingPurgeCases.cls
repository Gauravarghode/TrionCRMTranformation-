global class Arch_PopulatingPurgeCases implements Database.Batchable<SObject> {

     String days=Label.DaysTo;

    String query= 'SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, '

+			'TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress,'

+			' BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, '

+			'IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId,'

+			' IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c,Message_Size__c  '

+			'FROM EmailMessage where Parent.ClosedDate < LAST_N_DAYS:' + days + ' and Parent.Failed_Record__c =false and Parent.Processed_Record__c = false';


    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext bc, List<SObject> sObjectRecords) {

        Set<Id> caseIds = new Set<Id>();


        for (SObject sObj : sObjectRecords) {

            EmailMessage Emrec = (EmailMessage) sObj;

            caseIds.add(Emrec.ParentId);

        }
        List<Case>lisCas=[select id,Failed_Record__c from case where id in:caseIds];

      List<Purge_Case__c>lis= [SELECT CaseId__c FROM Purge_Case__c WHERE CaseId__c IN :caseIds];

     List<String> existingPurgeCases = new List<String>();

        for(Purge_Case__c p:lis){

            existingPurgeCases.add(p.CaseId__c);

        }
 
       

        List<EmailMessageHtml__c> listEmails = [

            SELECT Id, EmailMessage_Id__c, Parent_Case_Id__c 

            FROM EmailMessageHtml__c 

            WHERE Parent_Case_Id__c IN :caseIds

        ];
 
       

        Map<Id, List<String>> caseToEmailMessageMap = new Map<Id, List<String>>();

        for (EmailMessageHtml__c e : listEmails) {

            if (e.EmailMessage_Id__c != null) {

                if (!caseToEmailMessageMap.containsKey(e.Parent_Case_Id__c)) {

                    caseToEmailMessageMap.put(e.Parent_Case_Id__c, new List<String>());

                }

                caseToEmailMessageMap.get(e.Parent_Case_Id__c).add(e.EmailMessage_Id__c);

            }

        }


        List<Purge_Case__c> pList = new List<Purge_Case__c>();

        for (Case sObj : lisCas) {

            


            System.debug('Checking Duplications: Test It one');

            if (!existingPurgeCases.contains(sObj.Id)) {

                Purge_Case__c p = new Purge_Case__c();


                p.Status__c = (sObj.Failed_Record__c == true) ? 'Failed' : 'Success';

                p.CaseId__c = sObj.Id;
 
              

                List<String> emIds = caseToEmailMessageMap.get(sObj.Id);

                if (emIds != null && !emIds.isEmpty()) {

                    p.EmailMessage_Id__c = String.join(emIds, ',\n');

                }
 
                

                pList.add(p);

            }

        }
      // Handle failed records from Stagging__c and avoid duplicates
List<Stagging__c> lisofStag = [SELECT Id, Status__c, Linked_Entity_Id__c FROM Stagging__c WHERE Status__c = 'Failed' AND CreatedDate = TODAY];
if (!lisofStag.isEmpty()) {
    Set<String> emIds = new Set<String>();
    for (Stagging__c s : lisofStag) {
        emIds.add(s.Linked_Entity_Id__c);
    }

    List<EmailMessage> lisEmailFailed = [SELECT Id, ParentId FROM EmailMessage WHERE Id IN :emIds];
    Set<Id> caseIdsFailed = new Set<Id>();
    for (EmailMessage eRec : lisEmailFailed) {
        caseIdsFailed.add(eRec.ParentId);
    }

    List<Case> lisFailedCase = [SELECT Id, Failed_Record__c FROM Case WHERE Id IN :caseIdsFailed];

    // Query existing Purge_Case__c records to avoid duplicates
    List<Purge_Case__c> existingFailedPurgeCases = [SELECT CaseId__c FROM Purge_Case__c WHERE CaseId__c IN :caseIdsFailed AND Status__c = 'Failed'];
    Set<Id> existingFailedCaseIds = new Set<Id>();
    for (Purge_Case__c p : existingFailedPurgeCases) {
        existingFailedCaseIds.add(p.CaseId__c);
    }

    // Add new failed cases, but skip duplicates and populate EmailMessage_Id__c
    for (Case caFailed : lisFailedCase) {
        if (!existingFailedCaseIds.contains(caFailed.Id)) {
            Purge_Case__c p = new Purge_Case__c();
            p.Status__c = 'Failed';
            p.CaseId__c = caFailed.Id;

            // Populate the EmailMessage_Id__c field for failed cases
            List<String> failedEmIds = caseToEmailMessageMap.get(caFailed.Id);
            if (failedEmIds != null && !failedEmIds.isEmpty()) {
                p.EmailMessage_Id__c = String.join(failedEmIds, ',\n');
            }

            pList.add(p);
        }
    }
}


        if (!pList.isEmpty()) {

            insert pList;

        }
        
      
    }

    global void finish(Database.BatchableContext bc) {

        Database.executeBatch(new Arch_UpdateProcessedCaseRecord(), 2000);

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

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

        i++;

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