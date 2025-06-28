@isTest
public class TriggeredSendSchedulerTest {
    @isTest
    public static void testScheduler() {
        // Create Test Data
        List<Campaign> listOfCampaign = new List<Campaign>();
        String uniqueSuffix = Datetime.now().getTime().toString(); // Add a unique timestamp
        
        // Initially set the campaign stage to 'Creation' to pass the validation rule
        Campaign campaignEach = new Campaign(Name = 'Test Campaign EA221 ' + uniqueSuffix, IsActive = true, Campaign_Stage__c = 'Creation');
        insert campaignEach; // Insert campaign into the database
        
        // Update the campaign stage to 'Completed' to match the logic in your service class
        campaignEach.Campaign_Stage__c = 'Completed';
        update campaignEach;

        // Create associated Business Unit and Email Template records (mock data)
        List<et4ae5__Business_Unit__c> businessUnitList = new List<et4ae5__Business_Unit__c>();
        et4ae5__Business_Unit__c businessUnit = new et4ae5__Business_Unit__c(Name = 'Test Business Unit');
        insert businessUnit;
        businessUnitList.add(businessUnit);

        List<Email_Template__c> emailTempList = new List<Email_Template__c>();
        Email_Template__c emailTemplate = new Email_Template__c(Name = 'Test Email Template', Email_Asset_Id__c = '12345', Email_Template_Id__c = '54321');
        insert emailTemplate;
        emailTempList.add(emailTemplate);

        // Create an active Automated Send related to the campaign
        List<et4ae5__Automated_Send__c> triggerSendList = triggerSendTestData(true, campaignEach.Id, businessUnitList, emailTempList);

        // Test scheduling the job
        Test.startTest();
        
        // Schedule the job to run in 1 minute
        String jobId = System.schedule('Test TriggeredSendScheduler Job', '0 0 0 * * ?', new TriggeredSendScheduler());
        
        // Simulate execution of the scheduled job
        Test.stopTest();

        // Fetch the automated send and check that it was deactivated
        et4ae5__Automated_Send__c deactivatedSend = [SELECT Id, et4ae5__Active__c FROM et4ae5__Automated_Send__c WHERE Id = :triggerSendList[0].Id];
        
        // Assert that the send is now deactivated (et4ae5__Active__c = false)
        System.assertEquals(false, deactivatedSend.et4ae5__Active__c, 'The triggered send should be deactivated.');
    }
    
    // Helper method to create test data
    public static List<et4ae5__Automated_Send__c> triggerSendTestData(Boolean doInsert, Id campaignId, List<et4ae5__Business_Unit__c> businessUnitList, List<Email_Template__c> emailTempList) {
        List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();

        // Create Automated Send related to the campaign
        et4ae5__Automated_Send__c eachAutomatedSend = new et4ae5__Automated_Send__c();
        eachAutomatedSend.Name = 'Test Automated Send';
        eachAutomatedSend.et4ae5__Object__c = 'CAMPAIGNMEMBER';
        eachAutomatedSend.et4ae5__Active__c = true; // Set as active
        eachAutomatedSend.Campaign__c = campaignId;
        eachAutomatedSend.et4ae5__Business_Unit__c = businessUnitList[0].Id;
        eachAutomatedSend.et4ae5__EmailId__c = emailTempList[0].Email_Asset_Id__c;
        eachAutomatedSend.et4ae5__EmailAssetId__c = emailTempList[0].Email_Template_Id__c;
        eachAutomatedSend.et4ae5__FromEmail__c = 'test@example.com';

        listOfTriggerSend.add(eachAutomatedSend);

        if (doInsert) {
            insert listOfTriggerSend;
        }

        return listOfTriggerSend;
    }
}