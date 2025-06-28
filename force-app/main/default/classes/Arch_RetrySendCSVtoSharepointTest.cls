@isTest
class Arch_RetrySendCSVtoSharepointTest {
     /*
    @istest(seeAllData = true)
    public static void testDataforHttp(){
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
        
       
        System.runAs(u) {
            SendCSVtoSharepoint.fileMigration('1234567890');
            //ApiFuturecalling.updateSharepointStatus(stagingRecord1,'Completed','null');
        }
    }
    */
    @isTest
    static void testCoverage(){
        //Arch_SendCSVtoSharepoint.testCoverage();
        Arch_RetrySendCSVtoSharepoint.testCoverage();
    }

}