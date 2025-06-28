@isTest
private class CreateCMSTest {
    
    @isTest
    static void testInsertCMS() {
        List<Campaign> listOfCampaigns = new List<Campaign>();
        
        Campaign testCampaign = new Campaign();
        testCampaign.Name = 'Test0000 Campaign'; 
        testCampaign.IsActive=true;
        testCampaign.Stage_of_Campaign__c = 'Creation';
        listOfCampaigns.add(testCampaign);
        /*
        Campaign testCampaign1 = new Campaign();
        testCampaign1.Name = 'Test11111 Campaign'; 
        testCampaign1.IsActive=true;
        testCampaign1.Stage_of_Campaign__c = 'Creation';
        listOfCampaigns.add(testCampaign1);
        
        Campaign testCampaign2 = new Campaign();
        testCampaign2.Name = 'Test22222 Campaign'; 
        testCampaign2.IsActive=true;
        testCampaign2.Stage_of_Campaign__c = 'Creation';
        listOfCampaigns.add(testCampaign2);
        */
        insert listOfCampaigns;
        
        
    }
}