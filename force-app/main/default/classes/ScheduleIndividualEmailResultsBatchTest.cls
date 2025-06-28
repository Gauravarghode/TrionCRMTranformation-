@isTest()
public class ScheduleIndividualEmailResultsBatchTest {
    @isTest()
    static void getScheduleData(){
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);

        List<Contact> listOfContact =TestDataFactory.contactData(true);
        
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);
		//List<Lead> listOfLead= TestDataFactory.leadTestData(true,listOfCampaignMember[0].id);
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        List<Interaction_event_mapping__c> interactionEvtMapList =TestDataFactory.interactionEventMappingData(true,campaignList[0].id,listOfCallToAction);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
       // List<Opportunity> opportunityList =TestDataFactory.opportunityTestData(true,campaignList[0].id,listOfCampaignMember[0].id);
        //List<Opportunity> opportunityList1 =TestDataFactory.opportunityTestData1(true,campaignList[0].id,listOfCampaignMember[0].id);

        //List<et4ae5__IndividualEmailResult__c> individualEmailResList1 = TestDataFactory.individualemailResultsTestData(true,campaignList[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id,opportunityList1[0].id);
        List<et4ae5__IndividualEmailResult__c> individualEmailResList = TestDataFactory.individualemailResultsTestData2(true,campaignList[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id);

        List<et4ae5__IndividualLink__c> individualLinkDetailsList = TestDataFactory.individualLinkTestData(true,individualEmailResList[0].id,listOfCallToAction);
        Test.startTest();
        ScheduleIndividualEmailResultsBatch inividualbatch = new ScheduleIndividualEmailResultsBatch();
         String sch = '0 0 23 * * ?';

     System.schedule('TestJob', sch, inividualbatch);
       // Database.executeBatch(inividualbatch,200);
        Test.stopTest();

    }

}