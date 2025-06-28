@isTest
public class ScheduleBatchtoCSVNewTest{
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
        
         
        Test.startTest();
        System.runAs(u){
            ScheduleBatchtoCSVNew scheduler = new ScheduleBatchtoCSVNew('Not Started');
            String jobId = System.schedule('Test ScheduleBatchtoCSVNew', '0 0 * * * ?', scheduler);
        }
        Test.stopTest();
    }
    
    

}