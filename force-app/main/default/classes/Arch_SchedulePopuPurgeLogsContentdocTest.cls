@isTest
public class Arch_SchedulePopuPurgeLogsContentdocTest {
    
    @isTest
    public static void testScheduleBatchExecution() {
       
        String query = 'SELECT Id, Failed_Record__c FROM Case';
        
       
        String cronExp = '0 0 0 18 9 ? 2026';  
        
        Test.startTest();
        
        
        String jobId = System.schedule('Test_SchedulCase', cronExp, new Arch_SchedulePopuPurgeLogsContentdoc());
        
        
        CronTrigger cronJob = [SELECT Id, CronExpression, TimesTriggered, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, cronJob.CronExpression, 'Cron expression should match the one provided');
        System.assertEquals('WAITING', cronJob.State, 'The job should be in WAITING state before execution');
        
        
        Test.stopTest();
        
        
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, batchJobs.size(), 'The batch job should have been queued.');
        
        
        AsyncApexJob batchJob = batchJobs[0];
        System.assert(batchJob.Status == 'Queued' || batchJob.Status == 'Processing', 
            'The batch job should be queued or processing, but was: ' + batchJob.Status);
    }
}