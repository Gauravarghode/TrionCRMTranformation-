@isTest
public class SchedulableSharePointstagingCSVTest {
 @isTest
    public static void testInsertAndSchedule(){
        // Create a user for testing
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
        
        //List<Staging__c> listOfStaging = TestDataFactory_SP.sharePointTestData(true);
        
        Test.startTest();
        System.runAs(u){
            //SchedulableSharePointstagingCSV scheduler = new SchedulableSharePointstagingCSV('Not Started');
            Arch_SchedulableSharePointCSV scheduler = new Arch_SchedulableSharePointCSV('Not Started');
            String jobId = System.schedule('Test SchedulableSharePointstaging', '0 0 * * * ?', scheduler);
        }
        Test.stopTest();
    } 
    
    @isTest
    public static void testInsertAndScheduleRetrySchedulableSharePointCSVClass(){
        // Create a user for testing
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
        
        //List<Staging__b> listOfStaging = TestDataFactory_SP.sharePointTestData(true);
        
        Test.startTest();
        System.runAs(u){
            //SchedulableSharePointstagingCSV scheduler = new SchedulableSharePointstagingCSV('Not Started');
            Arch_RetrySchedulableSharePointCSV scheduler = new Arch_RetrySchedulableSharePointCSV('Not Started');
            String jobId = System.schedule('Test SchedulableSharePointstaging', '0 0 * * * ?', scheduler);
        }
        Test.stopTest();
    }
    
    @isTest
    static void ScheduleTest(){
        Test.startTest();
        System.schedule('Test Arch_ScheduleSharePointCSV' , ' 0 44 1 * * ? ', new Arch_SchedulableSharePointCSV('Not started'));
        System.schedule('Test Arch_RetryScheduleSharePointCSV' , ' 0 44 1 * * ? ', new Arch_RetrySchedulableSharePointCSV('Not started'));
        Test.stopTest();
    }
    
}