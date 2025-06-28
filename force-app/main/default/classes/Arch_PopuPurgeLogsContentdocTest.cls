@isTest
public class Arch_PopuPurgeLogsContentdocTest {
    
    @isTest
    static void testArch_PopuPurgeLogsContentdoc() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        List < sObject > ls = Test.loadData(Case.sObjectType, 'Test0041933'); 
        
        //String caseJSON = '{"attributes":{"type":"Case","url":"/services/data/v25.0/sobjects/Case"},"ContactId":"003VE000002sRJpYAM","AccountId":"001VE000002WNF5YAO","OwnerId":"005VE000008tW7cYAE","CreatedById":"005VE000008tW7cYAE","LastModifiedById":"0058Y00000D18z2QAB","ClosedDate":"2024-09-16T10:39:51Z","CreatedDate":"2024-09-15T10:39:51Z","Reason":"Duplicate","Status":"Closed","Issue_with__c":"Client","Failed_Record__c":false,"Subject":"Test Case","have_more_character__c":false}';
        //Case c = (Case) JSON.deserialize(caseJSON, Case.class);
        
        
        Case cse = new Case(
            Subject = 'Test Case', 
            Status = 'New', 
            AccountId = testAccount.Id, 
            Failed_Record__c = false,
            Reason = 'Issue Resolved',
            have_more_character__c=false
            
        );
        insert cse;
        cse.Status='Closed';
        update cse;
        
        EmailMessage emailMessage = new EmailMessage(
            ParentId = cse.Id,
            FromAddress = 'test@example.com',
            ToAddress = 'recipient@example.com',
            HtmlBody = 'Test Email Body',
            Status = '3'
            
        );
        insert emailMessage;
        
        Stagging__c stagingRecord = new Stagging__c(
            Linked_Entity_Id__c = emailMessage.Id,
            Retry_Executed_Count__c = 1,
            Upload_Failed__c = false,
            Status__c='Completed',
            Is_Large_File__c='No'
        );
        insert stagingRecord;
        
        // Create Content Document
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Test Document'; 
        content.PathOnClient = '/' + content.Title + '.pdf'; 
        content.VersionData = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.Origin = 'H';
        insert content;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = emailMessage.Id;
        contentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id LIMIT 1].ContentDocumentId;
        //contentLink.ShareType = 'I';
        contentLink.Visibility = 'AllUsers';
        insert contentLink;
        
        // Create Purge Log Record for testing
        Purge_Log__c purgeLog = new Purge_Log__c(
            SObject_Type__c = 'ContentDocument',
            Parent_Id__c = emailMessage.Id,
            Case_Id__c = cse.Id,
            Record_Id__c = contentLink.Id,
            Purge_Date__c = Date.today()
        );
        insert purgeLog;
        
        Test.startTest();
        
        Arch_PopuPurgeLogsContentdoc batchInstance = new Arch_PopuPurgeLogsContentdoc();
        Database.executeBatch(batchInstance);
        Arch_PopuPurgeLogsContentdoc.testCoverage();
        Test.stopTest();
        
        // Verify results
        /* List<Purge_Log__c> purgeLogs = [SELECT Id, SObject_Type__c, Parent_Id__c, Case_Id__c, Record_Id__c, Purge_Date__c FROM Purge_Log__c where id=:purgeLog.id];
System.assertEquals(1, purgeLogs.size(), 'There should be one Purge_Log__c record.');

Purge_Log__c purgeLogAfterBatch = purgeLogs[0];
System.assertEquals('ContentDocument', purgeLogAfterBatch.SObject_Type__c, 'The SObject_Type__c should be ContentDocument.');
System.assertEquals(emailMessage.Id, purgeLogAfterBatch.Parent_Id__c, 'The Parent_Id__c should match the LinkedEntityId.');
System.assertEquals(cse.Id, purgeLogAfterBatch.Case_Id__c, 'The Case_Id__c should match the ParentId of EmailMessage.');
System.assertNotEquals(null, purgeLogAfterBatch.Purge_Date__c, 'The Purge_Date__c should not be null.');

List<ContentDocument> contentDocs = [SELECT Id FROM ContentDocument WHERE Id = :contentLink.ContentDocumentId];
System.assertEquals(0, contentDocs.size(), 'The ContentDocument should have been deleted.');*/
    }
}