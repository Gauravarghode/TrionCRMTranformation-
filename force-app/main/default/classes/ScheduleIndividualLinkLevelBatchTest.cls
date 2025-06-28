@isTest()
public class ScheduleIndividualLinkLevelBatchTest {
    @isTest()
    static void fetchIndividualLinkLevelData(){
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Campaign> campaignList1 = TestDataFactory.campaignTestData1(true);

        List<Contact> listOfContact =TestDataFactory.contactData(true);
        
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);
        
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template__c> emailTempList1 = TestDataFactory.emailTemplateData(true);

       List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        List<Interaction_event_mapping__c> interactionEvtMapList =TestDataFactory.interactionEventMappingData(true,campaignList[0].id,listOfCallToAction);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
       
        List<et4ae5__IndividualEmailResult__c> individualEmailResList = TestDataFactory.individualemailResultsTestData1(true,campaignList[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id);
        List<et4ae5__IndividualEmailResult__c> individualEmailResList1 = TestDataFactory.individualemailResultsTestData1(true,campaignList1[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id);

        //List<Opportunity> opportunityList =TestDataFactory.opportunityTestData1(true,campaignList[0].id,listOfCampaignMember[0].id);
       // List<Opportunity> opportunityList1 =TestDataFactory.opportunityTestData1(true,campaignList1[0].id,listOfCampaignMember[0].id);

        List<et4ae5__IndividualLink__c>  listOfIndividualLink = TestDataFactory.individualLinkTestData(true,individualEmailResList[0].id,listOfCallToAction);
        List<et4ae5__IndividualLink__c>  listOfIndividualLink1 = TestDataFactory.individualLinkTestData1(true,individualEmailResList1[0].id,listOfCallToAction);
       
        ScheduleIndividualLinkLevelBatch schIndividualLink = new ScheduleIndividualLinkLevelBatch();
        String sch = '0 0 23 * * ?';

        System.schedule('TestJob1', sch, schIndividualLink);
        IndividualLinkLevelDetailsBatchHandler individualLinkBatch = new IndividualLinkLevelDetailsBatchHandler();
        Database.executeBatch(individualLinkBatch);
    }

}