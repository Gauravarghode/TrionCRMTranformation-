@isTest
public class GetCsvUsingSPId_V2Test {
    
    @isTest
    public static void testGetCsvUsingSPId() {
        // Prepare the test data
        Case casRec = new Case(
            Status = 'New',
            Description = 'hi this is for testing',
            Subject = 'Test Subject',
            To_be_Archived__c = true
        );
        insert casRec;
        
        EmailMessage emgRec = new EmailMessage(
            ParentId = casRec.Id,
            ToAddress = 'Sujatha@gmail.com',
            FromAddress = 'Sujatha12@gmail.com',
            Subject = 'This is for testing',
            CreatedDate = System.now()
        );
        insert emgRec;
        
        Case_Email__c casEmailRec = new Case_Email__c(
            EmailMessage_Id__c = emgRec.Id,
            Email_Message_Created_Date__c = emgRec.CreatedDate.format(),
            Case_Id__c = emgRec.ParentId,
            Email_Message_Subject__c = emgRec.Subject
        );
        insert casEmailRec;
        
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
        
        // Mock HTTP Callouts to avoid actual callouts during testing
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();        
        GetCsvUsingSPId_V2.getfileData(emgRec.Id);
        GetCsvUsingSPId_V2.getCaseFolderData(casRec.Id);
        Test.stopTest();    
    }
    
    // Mock HTTP response generator class
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
        GetCsvUsingSPId_V2.testCoverage();
    }
}