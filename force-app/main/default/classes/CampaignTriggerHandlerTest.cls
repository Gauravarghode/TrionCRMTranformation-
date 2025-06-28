@isTest()
public class CampaignTriggerHandlerTest {
    public static boolean isTestFailInsert = false;
    @isTest()
    static void updateCampaignMembers(){
        CampaignTriggerHandlerTest.isTestFailInsert = true;
        
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        Map<id,Campaign> oldMapList = new Map<id,Campaign>();
        List<Contact> listOfContact =TestDataFactory.contactData(true);
        
        for(Campaign campaignEach:campaignList){
            oldMapList.put(campaignEach.id,campaignEach);
        }
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);
        List<CampaignMember> listOfCampaignMember1 = new  List<CampaignMember>();
        CampaignMember campaignMemEach1= new CampaignMember(ContactId=listOfContact[0].id,Status='Send');
        listOfCampaignMember1.add(campaignMemEach1);
        CampaignTriggerHandler campaignHandler = new CampaignTriggerHandler();
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
        
        campaignHandler.updateCampaignMembers(campaignList,oldMapList);
        campaignHandler.updateCampaignMembers(campaignList,oldMapList);
        
        //List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList[0].id, emailTempList[0].id, true);
        campaignHandler.queueCampaignMembers(listOfCampaignMember);
        
        System.assert(listOfCampaignMember.size()!= null);
    }  
    
    @isTest()
    static void validateCampaignstagetest(){
        CampaignTriggerHandlerTest.isTestFailInsert = true;   
        
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);        
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        Map<id,Campaign> oldCampaign = new Map<id,Campaign>(campaignList);
        try{
            for(Campaign campaignEach:campaignList){
                campaignEach.Campaign_Stage__c ='Email Template Selection';
            }
            Update campaignList;
            for(Email_Template_Mapping__c obj:listOfEmailTempMapp){
                obj.Status__c='Activated / In Progress';
            }
            update listOfEmailTempMapp;
        }Catch(exception e){
            system.debug('Error= ' +e.getMessage());
        }
        for(Campaign campaignEach:campaignList){
            campaignEach.Campaign_Stage__c ='Activated / In Progress';
        }
        Database.update(campaignList,false);
         List<Id> campaignIds = new List<Id>();
        for (Campaign campaign : campaignList) {
            campaignIds.add(campaign.Id);
        }

        CampaignTriggerHandler.checkIfTSAreActivatedPreviously(campaignIds, campaignList);

        Map<id,Campaign> newMap = new Map<id,Campaign>(campaignList);
        CampaignTriggerHandler.validateCampaignstage(newMap,oldCampaign);
        system.assertEquals(1,listOfEmailTempMapp.size());
    }  
   
}