@isTest
public class ScheduleSharePointBatchableTest {
    
    public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate the HTTP response here
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"key":"value"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void executeSchedulemethod(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
            Alias = 'standt', 
            Email = 'standarduser@sharepointtest.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'uniqueUserName@testsharepoint.com'
        );
        
        insert u;
        List<Staging__b> stagingRecords = new List<Staging__b>();
        for (Integer i = 0; i <5; i++) {
            Staging__b stagingRecord = new Staging__b(Status__c = 'Not Started', Chunk__c = 'Chunk ' + i);
            stagingRecords.add(stagingRecord);
        }
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        Test.startTest();
        System.runAs(u) {
            ScheduleSharePointBatchable scheduler = new ScheduleSharePointBatchable('Not Started');
            String jobId = System.schedule('Test SchedulableSharePointstaging', '0 0 * * * ?', scheduler);
        }
        Test.stopTest();
    }
}