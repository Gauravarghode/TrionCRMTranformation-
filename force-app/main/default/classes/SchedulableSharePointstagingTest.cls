@isTest
public class SchedulableSharePointstagingTest{
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
        
        List<Staging__b> listOfStaging = TestDataFactory_SP.sharePointTestData(true);
        
        Test.startTest();
        System.runAs(u){
            SchedulableSharePointstaging scheduler = new SchedulableSharePointstaging('Not Started');
            String jobId = System.schedule('Test SchedulableSharePointstaging', '0 0 * * * ?', scheduler);
        }
        Test.stopTest();
    }
}