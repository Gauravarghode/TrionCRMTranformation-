@isTest
public class Arch_RetrySharePointStagingBatchFATest {
	@isTest
    static void testBatchClass() {        
        List<Stagging__c> testStaggingRecords = new List<Stagging__c>();
        for (Integer i = 0; i < 10; i++) {
            testStaggingRecords.add(new Stagging__c(
                Status__c = 'Not Started',
                Chunk__c = '06AVE000003jTfN2AU',
                From_sObject__c = 'ContentDocument'
            ));
        }
        insert testStaggingRecords;
        
        Test.startTest();
        Arch_RetrySharePointStagingBatchFA batch = new Arch_RetrySharePointStagingBatchFA('Not Started');
        Database.executeBatch(batch, 200); 
        Test.stopTest();

        List<Integration_Log_Error__c> errors = [SELECT Id, getMessage__c, getCause__c, getLineNumber__c, getStackTraceString__c, getTypeName__c FROM Integration_Log_Error__c];
        System.assertEquals(0, errors.size(), 'No errors should be logged for this test case.');
    }
    
    @isTest
    static void testBatchClassWithException() {
        List<Stagging__c> testStaggingRecords = new List<Stagging__c>();
        for (Integer i = 0; i < 10; i++) {
            testStaggingRecords.add(new Stagging__c(
                Status__c = 'Not Started',
                Chunk__c = '06AVE000003jTfN2AU',
                From_sObject__c = 'ContentDocument'
            ));
        }
        insert testStaggingRecords;
       
        Test.startTest();
        
        Integration_Log_Error__c testIntegrationRecords = new Integration_Log_Error__c();
        testIntegrationRecords.getMessage__c = 'Record not inserted';
        testIntegrationRecords.getStackTraceString__c = 'Data is not inserted';
        testIntegrationRecords.getCause__c = 'Stagging is not valid';
        testIntegrationRecords.getLineNumber__c = 'Line number 5';
        testIntegrationRecords.getTypeName__c = 'String type';
        insert testIntegrationRecords;
        
        Arch_RetrySharePointStagingBatchFA batch = new Arch_RetrySharePointStagingBatchFA('Not Started');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        List<Integration_Log_Error__c> errors = [SELECT Id, getMessage__c, getCause__c, getLineNumber__c, getStackTraceString__c, getTypeName__c FROM Integration_Log_Error__c];
        System.assertEquals(1, errors.size(), 'One error should be logged for this test case.');
        
        Integration_Log_Error__c error = errors[0];
        System.assert(error.getMessage__c != null, 'Error message should be populated.');
        System.assert(error.getStackTraceString__c != null, 'Stack trace should be populated.');
        System.assert(error.getCause__c!=null,'Cause needs to be populated');
        System.assert(error.getLineNumber__c!=null,'Line number needs to be populated');
        System.assert(error.getTypeName__c!=null,'Type needs to be populated');
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return new HTTPResponse();
        }
    }
}