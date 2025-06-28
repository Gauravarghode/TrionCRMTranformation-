@isTest
public class SharePointStagingBatchableTest {
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
        
        List<Staging__b> stagingRecords = new List<Staging__b>();
        for (Integer i = 0; i <5; i++) {
            Staging__b stagingRecord = new Staging__b(Status__c = 'Not Started', Chunk__c = 'Chunk ' + i);
            stagingRecords.add(stagingRecord);
        }
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        Test.startTest();
        SharePointStagingBatchable batchableInstance = new SharePointStagingBatchable('Not Started');
        Id batchId = Database.executeBatch(batchableInstance);
        Test.stopTest();
    }
}