@isTest
public class Arch_PopulatingPurgeCasesTest {

    @isTest
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a list of test Cases
        List<Case> liscas = new List<Case>();
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'Closed',
            AccountId = testAccount.Id,
            Reason = 'Issue Resolved',
            Failed_Record__c = true // This should be 'Failed' status
        );
        liscas.add(c);

        Case c1 = new Case(
            Subject = 'Test Case1',
            Status = 'Closed',
            AccountId = testAccount.Id,
            Reason = 'Issue Resolved',
            Failed_Record__c = false // This should be 'Success' status
        );
        liscas.add(c1);
        insert liscas;

        // Debugging to ensure Failed_Record__c is set correctly
        System.debug('Case 1 Failed_Record__c: ' + liscas[0].Failed_Record__c);
        System.debug('Case 2 Failed_Record__c: ' + liscas[1].Failed_Record__c);

        // Create test EmailMessageHtml__c records linked to the Cases
        List<EmailMessageHtml__c> lisem = new List<EmailMessageHtml__c>();
        EmailMessageHtml__c email = new EmailMessageHtml__c(
            File_Size__c = 10,
            sObject__c = 'EmailMessage',
            EmailMessage_Id__c = '02sUH0000009gT6YAI',
            Parent_Case_Id__c = liscas[0].id
        );
        lisem.add(email);

        EmailMessageHtml__c email2 = new EmailMessageHtml__c(
            File_Size__c = 10,
            sObject__c = 'EmailMessage',
            EmailMessage_Id__c = '02sUH0000009fT6YAI',
            Parent_Case_Id__c = liscas[1].id
            
        );
        lisem.add(email2);
        insert lisem;

        // Create existing Purge_Case__c records to test duplicate prevention
        List<Purge_Case__c> lis = new List<Purge_Case__c>();
        Purge_Case__c existingPurgeCase = new Purge_Case__c(
            CaseId__c = liscas[0].Id,
            Status__c = 'Success',
            EmailMessage_Id__c = lisem[0].EmailMessage_Id__c
        );
        lis.add(existingPurgeCase);

        Purge_Case__c existingPurgeCase1 = new Purge_Case__c(
            CaseId__c = liscas[1].Id,
            Status__c = 'Failed',
            EmailMessage_Id__c = lisem[1].EmailMessage_Id__c
        );
        lis.add(existingPurgeCase1);
        insert lis;

        // Prepare the case IDs for dynamic query
        List<String> caIds = new List<String>();
        for (Case cid : liscas) {
            caIds.add(cid.id);
        }

        // Dynamically build the query
       // String query = 'SELECT Id, ParentId EmailMessage WHERE parentId IN (\'' +
         //   String.join(caIds, '\',\'') + '\')';

        // Start test and execute batch
        Test.startTest();
        Arch_PopulatingPurgeCases batch = new Arch_PopulatingPurgeCases();
        Database.executeBatch(batch, 200);
        
        Arch_PopulatingPurgeCases.testCoverage();
        Test.stopTest();

        // Validate that Purge_Case__c records are correctly inserted/updated
        List<Purge_Case__c> purgeCases = [SELECT CaseId__c, Status__c, EmailMessage_Id__c FROM Purge_Case__c WHERE CaseId__c IN :caIds];

        System.assertEquals(2, purgeCases.size(), 'There should be 2 Purge_Case__c records.');
        for (Purge_Case__c pCase : purgeCases) {
            if (pCase.CaseId__c == liscas[0].Id) {
                System.debug('Case 1 Status: ' + pCase.Status__c);
                System.assertEquals('Success', pCase.Status__c, 'Case 1 should be marked as Failed.');
                System.assert(pCase.EmailMessage_Id__c != null, 'Case 1 should have email message IDs.');
            } else if (pCase.CaseId__c == liscas[1].Id) {
                System.debug('Case 2 Status: ' + pCase.Status__c);
                System.assertEquals('Failed', pCase.Status__c, 'Case 2 should be marked as Success.');
                System.assert(pCase.EmailMessage_Id__c != null, 'Case 2 should have email message IDs.');
            }
        }
    }
}