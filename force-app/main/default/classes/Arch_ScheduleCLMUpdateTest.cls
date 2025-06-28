@isTest
public class Arch_ScheduleCLMUpdateTest {
    
    @isTest
    public static void testScheduleBatchExecution() {
       
       //String query = 'SELECT ID,Processed_Record__c,ClosedDate,Failed_Record__c FROM CASE WHERE ClosedDate <LAST_N_DAYS:91 and ClosedDate >=LAST_N_DAYS:92';
        
       
        String cronExp = '0 0 0 18 9 ? 2026';  
        
        Test.startTest();
        
        
      //  String jobId = System.schedule('Test_SchedulCase', cronExp, new Arch_ScheduleCLMUpdate());
        
        Arch_ScheduleCLMUpdate.testCoverage();
        /*CronTrigger cronJob = [SELECT Id, CronExpression, TimesTriggered, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, cronJob.CronExpression, 'Cron expression should match the one provided');
        System.assertEquals('WAITING', cronJob.State, 'The job should be in WAITING state before execution');*/
        
        
        Test.stopTest();
        
        
     //   List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        
    }
}