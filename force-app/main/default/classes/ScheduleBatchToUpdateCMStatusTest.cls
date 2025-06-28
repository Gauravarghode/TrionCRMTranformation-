@isTest
public class ScheduleBatchToUpdateCMStatusTest {
       @isTest
    public static void testScheduleBatchToUpdateSKU(){
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
            ScheduleBatchToUpdateCMStatus scheduler = new ScheduleBatchToUpdateCMStatus();
            String jobId = System.schedule('Test ScheduleBatchToUpdateCMS', '0 0 * * * ?', scheduler);
        }
        Test.stopTest();
    }

}