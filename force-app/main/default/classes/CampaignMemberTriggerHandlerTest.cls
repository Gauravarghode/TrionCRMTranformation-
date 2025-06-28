@isTest()
public class CampaignMemberTriggerHandlerTest {
    @isTest()
    static void testData(){
        string camStage;
        string camMemStatus;
        List<Contact> listOfContact =TestDataFactory.contactData(true);
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        for(Campaign cam:campaignList){
            camStage=cam.Campaign_Stage__c;
        }
        List<Campaign> campaignList1 = TestDataFactory.campaignTestData(true);
        
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);
        for(CampaignMember camMem:listOfCampaignMember){
            camMem.Status__c=camStage;
            camMemStatus=camMem.Status__c;
        }
        List<CampaignMember> listOfCampaignMember1 = new List<CampaignMember>();
        CampaignMember campaignMemEach= new CampaignMember(CampaignId=campaignList1[0].id,ContactId=listOfContact[0].id,Status='Send');
        listOfCampaignMember1.add(campaignMemEach);
        List<CampaignMember> listOfCampaignMember2= new List<CampaignMember>();
        
        CampaignMember campaignMemEach1= new CampaignMember(ContactId=listOfContact[0].id,Status='Send');
        listOfCampaignMember2.add(campaignMemEach1);
        CampaignMemberTriggerHandler obj = new CampaignMemberTriggerHandler();
        obj.insertCampaignMembers(listOfCampaignMember);
        obj.insertCampaignMembers(listOfCampaignMember1);
        obj.insertCampaignMembers(listOfCampaignMember2);
        
		//System.assertEquals('Interaction Score', camMemStatus);
  
    }
}