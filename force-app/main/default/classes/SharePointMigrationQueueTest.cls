@isTest
public class SharePointMigrationQueueTest{
    
    @isTest
    public static void testQueueableExecution(){
      
        List<Stagging__c> stagingRecords = new List<Stagging__c>();
		stagingRecords.add(new Stagging__c(Status__c = 'Not Started', Chunk__c = 'Test##SP'));
        
        Test.startTest();
        System.enqueueJob(new Arch_SharePointMigrationQueueFA(stagingRecords));
        Arch_SharePointMigrationQueueFA.testQualifier();
        Test.stopTest();
    }
}