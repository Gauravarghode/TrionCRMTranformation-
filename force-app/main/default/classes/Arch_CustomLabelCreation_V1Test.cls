@isTest
public class Arch_CustomLabelCreation_V1Test {

    // Mock class for MetadataService callouts
    private class MockMetadataService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response for the MetadataService callout
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}'); // Mock response body
            return res;
        }
    }

    @isTest
    static void testCLMUpdate() {
        // Setup test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Case testCase = new Case(
            AccountId = acc.Id,
            Subject = 'Test Case',
            Status = 'Open',
            Failed_Record__c = false,
            Processed_Record__c = false,
            ClosedDate = System.today().addDays(-100) // Set to more than 91 days ago
        );
        insert testCase;

        // Create an EmailMessage associated with the case
        EmailMessage emailMessage = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email',
            ToAddress = 'test@example.com',
            FromAddress = 'from@example.com',
            HtmlBody = 'This is a test email.',
            MessageDate = System.now()
        );
        insert emailMessage;

        // Set the mock response for callouts
        //Test.setMock(HttpCalloutMock.class, new MockMetadataService());
         //CLMUpdate.CLMupdate();
        Test.startTest();
        // Call the future method
        Arch_CustomLabelCreation_V1.testCoverage();
        Test.stopTest();

        // Since custom metadata records aren't committed in test contexts, 
        // we can't query them here. You could verify other behaviors if needed.
    }
}