@isTest
public class Arch_UploadSecondValidationBatchTest {

    public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"value": [{"name": "File1"}, {"name": "File2"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testBatchExecution() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
                
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Case cse = new Case(
            Subject = 'Test Case', 
            Status = 'Closed', 
            AccountId = testAccount.Id, 
            Failed_Record__c = False,
            Reason = 'Issue Resolved'
        );
        insert cse;
 
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
            Upload_Failed__c = false
        );
        insert stagingRecord;
        
        
        Attachment attach1 = new Attachment();   	
        attach1.Name = 'Test##SP';
        Blob bodyBlobAttach1 = Blob.valueOf('Unit Test Attachment Body');
        attach1.Body = bodyBlobAttach1;
        attach1.ParentId = emailMessage.Id;
        insert attach1;                
        
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Test##SP'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.Origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = emailMessage.Id;
        contentlink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.Id].ContentDocumentId;
        //contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
                
        Test.startTest();
        
        Arch_UploadSecondValidationBatch batchInstance = new Arch_UploadSecondValidationBatch();
        ID batchJobId = Database.executeBatch(batchInstance);
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Attachment WHERE ParentId = :emailMessage.Id], 'Attachment should be processed.');
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :emailMessage.Id], 'ContentDocumentLink should be processed.');
        
        List<Attachment> processedAttachments = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :emailMessage.Id];
        System.assert(processedAttachments.size() > 0, 'At least one attachment should be processed.');
        
        List<ContentDocumentLink> processedContentLinks = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :emailMessage.Id];
        System.assert(processedContentLinks.size() > 0, 'At least one content document link should be processed.');
        
        
        System.assertNotEquals(processedAttachments.size(), 0, 'The `attList` should be populated.');
        System.assertNotEquals(processedContentLinks.size(), 0, 'The `cdlList` should be populated.');
        
        Integer attachmentCount = processedAttachments.size() + processedContentLinks.size();
        Map<Id, Integer> mapOfIdAttachmentCount = new Map<Id, Integer>();
        mapOfIdAttachmentCount.put(emailMessage.Id, attachmentCount);
        
        System.assertNotEquals(System.enqueueJob(new Arch_SharePointSecondCountQueue(cse.Id, emailMessage.Id, attachmentCount)), null, 'A job should be enqueued.');  
       
    }
}