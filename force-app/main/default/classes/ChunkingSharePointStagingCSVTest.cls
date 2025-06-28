@isTest()
public class ChunkingSharePointStagingCSVTest {
    @isTest
    Public static void testdataforChunking(){
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
        List<EmailMessageHtml__c> stagingRecords = new List<EmailMessageHtml__c>();
        for (Integer i = 0; i <5; i++) {
            EmailMessageHtml__c stagingRecord = new EmailMessageHtml__c(Status__c = 'Not Started');
            stagingRecords.add(stagingRecord);
        }

        Test.startTest();
        System.runAs(u) {
            //ChunkingSharePointStagingCSV.chunkStagingData(stagingRecords);
            Arch_ChunkingSharePointEmailCSV.chunkStagingData(stagingRecords);
            //Arch_RetryChunkingSharePointEmailCSV.chunkStagingData(stagingRecords);
            //Arch_RetrySharePointMigrationQueueCSV runClass = NEW Arch_RetrySharePointMigrationQueueCSV(stagingRecords);
        }
        Test.stopTest();
    }
    @isTest
    static void testCoverage(){
        //ChunkingSharePointStagingCSV.testCoverage();
        Arch_ChunkingSharePointEmailCSV.testCoverage();
        //Arch_RetryChunkingSharePointEmailCSV.testCoverage();
        //Arch_RetrySharePointMigrationQueueCSV.testCoverage();
    }
    
     @isTest
    static void testTriggerWithException() {
        // Start a test context
        Test.startTest();

        // Create a list of platform events
        List<SharePointPusherCSV__e> eventList = new List<SharePointPusherCSV__e>();

        // Create a mock event with sample values
        SharePointPusherCSV__e mockEvent = new SharePointPusherCSV__e();
        mockEvent.EmailNumber__c = 'Failed';
        // Add the mock event to the list of events
        eventList.add(mockEvent);
        
        // Publish the platform event
        EventBus.publish(eventList);

        // Stop the test context to trigger the event
        Test.stopTest();
        
        // Query to confirm if any error logs were inserted (to cover the exception block)
        List<Integration_Log_Error__c> errorLogs = [SELECT Id FROM Integration_Log_Error__c];
        System.assert(errorLogs.size() > 0, 'Error logs should have been inserted.');
    }
}