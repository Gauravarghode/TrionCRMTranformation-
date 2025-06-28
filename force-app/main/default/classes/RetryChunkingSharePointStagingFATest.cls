@isTest()
public class RetryChunkingSharePointStagingFATest {
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
        List<Stagging__c> stagingRecords = new List<Stagging__c>();
        for (Integer i = 0; i <5; i++) {
            Stagging__c stagingRecord = new Stagging__c(Status__c = 'Not Started', Chunk__c = 'Test##SP');
            stagingRecords.add(stagingRecord);
        }

        Test.startTest();
        System.runAs(u) {
            Arch_RetryChunkingSharePointStagingFA.chunkStagingData(stagingRecords);
        }
        Test.stopTest();
    }
     @isTest
    static void testCoverage(){
        Arch_RetryChunkingSharePointStagingFA.testQualifier();
    }
}