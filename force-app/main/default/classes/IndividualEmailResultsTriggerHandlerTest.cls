@isTest()
public class IndividualEmailResultsTriggerHandlerTest {
	
    public static boolean isTestFailInsert = false;

    @testSetup
    static void testData(){

        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Contact> listOfContact =TestDataFactory.contactData(true);
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);   
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        List<Interaction_event_mapping__c> interactionEvtMapList =TestDataFactory.interactionEventMappingData(true,campaignList[0].id,listOfCallToAction);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
        List<et4ae5__IndividualEmailResult__c> individualEmailResList = TestDataFactory.individualemailResultsTestData1(false,campaignList[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id);
    }
    @isTest
    static void LeadTriggerHandler_InsertHappyPath() { 
        IndividualEmailResultsTriggerHandlerTest.isTestFailInsert = true;
        List<et4ae5__IndividualEmailResult__c> individualEmailResList = new List<et4ae5__IndividualEmailResult__c> ();
        try {
            
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Contact> listOfContact =TestDataFactory.contactData(true);
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);   
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        List<Interaction_event_mapping__c> interactionEvtMapList =TestDataFactory.interactionEventMappingData(true,campaignList[0].id,listOfCallToAction);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
        individualEmailResList = TestDataFactory.individualemailResultsTestData1(false,campaignList[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id);
         insert individualEmailResList;
        }
        catch (Exception e) {
            system.debug('Exception is '+e.getMessage());
        }
		System.assertEquals(1, [SELECT COUNT() FROM et4ae5__IndividualEmailResult__c WHERE Id =: individualEmailResList[0].Id]);
               
    }
    
}