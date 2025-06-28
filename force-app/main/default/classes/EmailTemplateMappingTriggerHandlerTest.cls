@isTest
public class EmailTemplateMappingTriggerHandlerTest {
    @isTest
    static void Test() {
        List<Campaign> CampaignList = TestDataFactory.campaignTestData(True);
        List<Email_Template__c> EmailTempList = TestDataFactory.emailTemplateData(True);
                
        List<Email_Template_Mapping__c> emailtempmapping = TestDataFactory.emailTemplateMapData(CampaignList,EmailTempList[0].Id,false);
        
        List<Call_To_Action__c> calltoaction = TestDataFactory.callToActionTestData(True,EmailTempList[0].Id);
        
        List<Interaction_event_mapping__c> InteractioneventList = TestDataFactory.interactionEventMappingData(true, CampaignList[0].Id,calltoaction);
        
       
        
        System.assertEquals(1, emailtempmapping.size(), 'Email Templet Mapping');
    }
    
}