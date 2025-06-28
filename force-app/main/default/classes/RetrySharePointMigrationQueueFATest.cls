@isTest
public class RetrySharePointMigrationQueueFATest{
    
    @isTest
    public static void testQueueableExecution(){
      
        List<Stagging__c> stagingRecords = new List<Stagging__c>();
		stagingRecords.add(new Stagging__c(Status__c = 'Not Started', Chunk__c = 'Test##SP'));
        
        Test.startTest();
        System.enqueueJob(new Arch_RetrySharePointMigrationQueueFA(stagingRecords));
        Arch_RetrySharePointMigrationQueueFA.testQualifier();
        Test.stopTest();
    }
}