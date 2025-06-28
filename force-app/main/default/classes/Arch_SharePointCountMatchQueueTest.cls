@isTest
public class Arch_SharePointCountMatchQueueTest {
    public static String caseId;
    public static String emailRecordId;
    public static Integer emailRecordCount = 3; 
    
    public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"value": [{"name": "File1"}, {"name": "File2"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    static void testSharePointCountSecondValidation() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        Case testCase = new Case(Subject = 'Test Case', Status = 'New', Failed_Record__c = False);
        insert testCase;
        caseId = testCase.Id;
        
        EmailMessage emailMessage = new EmailMessage(
            FromAddress = '123@testSalesforce.com',
            ToAddress = '321@testSalesforce.com',
            Headers = 'Test Header',
            HtmlBody = 'Test HTML Body',
            ParentId = testCase.Id
        );
        insert emailMessage;
        emailRecordId = emailMessage.Id;
        
        Stagging__c staggingRecord = new Stagging__c(
            Linked_Entity_Id__c = emailRecordId,
            status__c = 'Retry Required',
            Upload_Failed__c = False,
            Retry_Executed_Count__c = 0
        );
        insert staggingRecord;
        
        EmailMessageHtml__c emailMessageHtml = new EmailMessageHtml__c(
            EmailMessage_Id__c = emailRecordId,
            File_Body__c = emailMessage.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Not Started',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 0,
            Parent_Case_Id__c = caseId,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        insert emailMessageHtml; 
        
        Test.startTest();
        System.enqueueJob(new Arch_SharePointCountMatchQueue(caseId, emailRecordId, emailRecordCount));
        // List<EmailMessageHtml__c> emailList =New List<EmailMessageHtml__c>();
        //emailList.add(emailMessageHtml);
        //Arch_ChunkingSharePointEmailCSV.chunkStagingData(emailList);
        Test.stopTest();
        
        List<Case> caseList = [SELECT Id, Failed_Record__c FROM Case WHERE Id = :caseId];
        System.assert(!caseList.isEmpty(), 'No Case record found');
        Case updatedCase = caseList[0];
        System.assertEquals(False, updatedCase.Failed_Record__c, 'The Failed_Record__c field should be False after job execution');
        
        EmailMessageHtml__c updatedEmh = [SELECT Id, Status__c, Retry_Executed_Count__c, Upload_Failed__c FROM EmailMessageHtml__c WHERE Id = :emailMessageHtml.Id];
        System.assertEquals(False, updatedEmh.Upload_Failed__c, 'The Upload_Failed__c field should be False');
        System.assertEquals('Retry Required', updatedEmh.Status__c, 'The Status__c field should be Retry Required');
        System.assertEquals(1, updatedEmh.Retry_Executed_Count__c, 'The Retry_Executed_Count__c field should be incremented');
        
        Stagging__c updatedStagging = [SELECT Id, status__c, Retry_Executed_Count__c FROM Stagging__c WHERE Linked_Entity_Id__c = :emailRecordId];
        System.assertEquals('Retry Required', updatedStagging.status__c, 'The status__c field should be Retry Required');
        System.assertEquals(1, updatedStagging.Retry_Executed_Count__c, 'The Retry_Executed_Count__c field should be incremented');
        
        System.assert(updatedStagging.Retry_Executed_Count__c > 0, 'The Retry_Executed_Count__c should be incremented on retry');
    }
}