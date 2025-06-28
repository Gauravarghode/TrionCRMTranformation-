@isTest
public class Arch_RetrySchedulableSharePointFATest {
	@isTest
    public static void ScheduleTest(){      
        List<Stagging__c> stagingRecords = new List<Stagging__c>();
        for (Integer i = 0; i <5; i++) {
            Stagging__c stagingRecord = new Stagging__c(Status__c = 'Not Started', Chunk__c = 'Chunk ' + i);
            stagingRecords.add(stagingRecord);
        }  
        Test.startTest();
        Arch_RetrySchedulableSharePointFA scheduler = new Arch_RetrySchedulableSharePointFA('Not Started');
        System.schedule('Test Arch_ScheduleSharePointFA', '0 0 * * * ?', scheduler);
        Test.stopTest();
    }    
    
    @isTest
    public static void NthScheduleTest(){
        Test.startTest();
        System.schedule('Arch_RetrySchedulableSharePointFA' , ' 0 48 1 * * ? ', new Arch_RetrySchedulableSharePointFA('Not started'));
        Test.stopTest();
    }

}