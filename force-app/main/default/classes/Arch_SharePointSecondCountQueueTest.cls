@isTest
public class Arch_SharePointSecondCountQueueTest {
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
            Retry_Executed_Count__c = 1
        );
        insert staggingRecord;
        
        EmailMessageHtml__c emailMessageHtml = new EmailMessageHtml__c(
            EmailMessage_Id__c = emailRecordId,
            File_Body__c = emailMessage.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Not Started',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 1,
            Parent_Case_Id__c = caseId,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        insert emailMessageHtml; 
        
        Test.startTest();
        System.enqueueJob(new Arch_SharePointSecondCountQueue(caseId, emailRecordId, emailRecordCount));
        Test.stopTest();
        
        List<Case> caseList = [SELECT Id, Failed_Record__c FROM Case WHERE Id = :caseId];
        System.assert(!caseList.isEmpty(), 'No Case record found');
        Case updatedCase = caseList[0];
        System.assertEquals(true, updatedCase.Failed_Record__c, 'The Failed_Record__c field should be true after job execution');
        
        EmailMessageHtml__c updatedEmh = [SELECT Id, Upload_Failed__c FROM EmailMessageHtml__c WHERE Id = :emailMessageHtml.Id];
        System.assertEquals(true, updatedEmh.Upload_Failed__c, 'The Upload_Failed__c field should be true');
    }
}