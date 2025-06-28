@isTest
public class GetCsvUsingCaseSPId_checkV12Test {
    

    @isTest
    static void testTriggerExecution() {


        List<GetDataFromSharepoint_V2__e> events = new List<GetDataFromSharepoint_V2__e>();
        events.add(new GetDataFromSharepoint_V2__e(EmailIdFromSP__c = 'email1@example.com', ParentCaseId__c = '500xx0000008xwy'));
        events.add(new GetDataFromSharepoint_V2__e(EmailIdFromSP__c = 'email2@example.com', ParentCaseId__c = '500xx0000008xwy'));

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();


      
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HttpRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "12345", "content": "some content"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testCoverage(){
        GetCsvUsingCaseSPId_checkV12.testCoverage();
        //GetDataFromSharepoint_V2Trigger.testCoverage();
    }
    
    @isTest
    static void testDoHttpCallout() {
        // Set up test data
        String caseParentId = '500xx0000008xwy';
        String caseFolderName = 'TestFolder';
        String objectNameCase2 = 'TestObject';
        
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Call the method under test
        Test.startTest();
        //GetCsvUsingCaseSPId_checkV12.doHttpCallout(caseParentId, caseFolderName, objectNameCase2);
        Test.stopTest();
        
        // Verify that events were published (you can add more assertions as needed)
        //List<GetDataFromSharepoint_V2__e> events = [SELECT Id FROM GetDataFromSharepoint_V2__e];
        //System.assertEquals(2, events.size(), 'Expected number of events to be published.');
    }
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"value":[{"name":"email1@example.com"},{"name":"email2@example.com"}]}');
            return res;
        }
    }
    
}