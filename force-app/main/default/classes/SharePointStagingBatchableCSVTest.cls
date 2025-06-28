@isTest
public class SharePointStagingBatchableCSVTest {
    public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"key":"value"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    public static void executeBatch(){
        
       /* List<EmailMessage_Html__b> stagingRecords = new List<EmailMessage_Html__b>();
        for (Integer i = 0; i <5; i++) {
            EmailMessage_Html__b stagingRecord = new EmailMessage_Html__b(Status__c = 'Not Started' + i);
            stagingRecords.add(stagingRecord);
        }*/
        
        List<EmailMessageHtml__c> stagingRecords = new List<EmailMessageHtml__c>();
        for (Integer i = 0; i <5; i++) {
            EmailMessageHtml__c stagingRecord = new EmailMessageHtml__c(Status__c = 'Not Started',
                                                                       sObject__c = 'Email Message',
                                                                       File_Size__c = 100,
                                                                       Parent_Case_Id__c = 'a1PVE0000053HB72AM',
                                                                       EmailMessage_Id__c = 'id'+i);
            stagingRecords.add(stagingRecord);
        }
        insert stagingRecords;
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        Test.startTest();
       // SharePointStagingBatchableCSV batchableInstance = new SharePointStagingBatchableCSV('Not Started');
       	  Arch_SharePointEmailBatchCSV batchableInstance = new Arch_SharePointEmailBatchCSV('Not Started');
        //Id batchId = Database.executeBatch(batchableInstance);
           Database.executeBatch(batchableInstance);
        Test.stopTest();
    }
    @isTest
    public static void executeRetrySharePointEmailBatchCSVBatch(){
        
       /* List<EmailMessage_Html__b> stagingRecords = new List<EmailMessage_Html__b>();
        for (Integer i = 0; i <5; i++) {
            EmailMessage_Html__b stagingRecord = new EmailMessage_Html__b(Status__c = 'Not Started' + i);
            stagingRecords.add(stagingRecord);
        }*/
        
        List<EmailMessageHtml__c> stagingRecords = new List<EmailMessageHtml__c>();
        for (Integer i = 0; i <5; i++) {
            EmailMessageHtml__c stagingRecord = new EmailMessageHtml__c(Status__c = 'Not Started',
                                                                       sObject__c = 'Email Message',
                                                                       File_Size__c = 100,
                                                                       Parent_Case_Id__c = 'a1PVE0000053HB72AM',
                                                                       EmailMessage_Id__c = 'id'+i);
            stagingRecords.add(stagingRecord);
        }
        insert stagingRecords;
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        Test.startTest();
       // SharePointStagingBatchableCSV batchableInstance = new SharePointStagingBatchableCSV('Not Started');
       	  Arch_RetrySharePointEmailBatchCSV batchableInstance = new Arch_RetrySharePointEmailBatchCSV('Not Started');
        //Id batchId = Database.executeBatch(batchableInstance);
           Database.executeBatch(batchableInstance);
        Test.stopTest();
    }
}