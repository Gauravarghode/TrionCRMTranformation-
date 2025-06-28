@isTest
public class LeadTriggerHandlerTest {
    
    public static boolean isTestFailInsert = false;
    
    @testSetup
    static void insertTestData() {
        
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Contact> contactList = TestDataFactory.contactData(true);
        List<CampaignMember> campaignMemberList;
        if (contactList != null || !contactList.isEmpty())
            campaignMemberList = TestDataFactory.campaignMemberTestData(true, campaignList, contactList[0].Id);
        // TestDataFactory.leadTestData(true);
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template__c> emailTempList1 = TestDataFactory.emailTemplateData(true);
        List<et4ae5__Business_Unit__c> businessUnitList = TestDataFactory.businessUnitTestData1(true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].Id, true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true, emailTempList[0].Id);
        List<Interaction_event_mapping__c> interactionEvtMapList = TestDataFactory.interactionEventMappingData(true, campaignList[0].Id, listOfCallToAction);
        
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true, campaignList[0].Id, businessUnitList, emailTempList);
        List<et4ae5__IndividualEmailResult__c> individualEmailResList = TestDataFactory.individualemailResultsTestData1(true, campaignList[0].Id, contactList[0].Id, emailTempList, listOfTriggerSend[0].Id, campaignMemberList[0].Id);
        
         //insert listOfLeads;
                	List<Lead> listOfLeads = TestDataFactory.leadTestData(false , campaignMemberList[0].id);

        System.assertEquals(1, listOfLeads.size(), 'Lead records were not inserted successfully');
        
        List<Error_Login__c> errLogList=TestDataFactory.errorLoginTestData(true);
        
    }
    @isTest
    static void LeadTriggerHandler_InsertHappyPath(){
         LeadTriggerHandlerTest.isTestFailInsert = true;    
        List<Lead> listOfLeads = new List<Lead>();
        try{
            List<CampaignMember> listOfCampMembers = [SELECT id FROM CampaignMember];
           listOfLeads = TestDataFactory.leadTestData(false , listOfCampMembers[0].id);
        	insert listOfLeads;
        }  catch (Exception e){
            system.debug('Exception is '+e.getMessage());
        }
       System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Campaign_Member_Id__c =: listOfLeads[0].Campaign_Member_Id__c]);

        
    }
    @isTest
    static void LeadTriggerHandler_updateHappyPath(){
         LeadTriggerHandlerTest.isTestFailInsert = true;
       List<Lead> listOfLeads = new List<Lead>();
        try{
             List<CampaignMember> listOfCampMembers = [SELECT id FROM CampaignMember];
             listOfLeads = TestDataFactory.leadTestData(false , listOfCampMembers[0].id);
        	insert listOfLeads;
             for(Lead eachLead : listOfLeads){
                    eachLead.Status = 'Unqualified';
                }
            update listOfLeads;
            System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Campaign_Member_Id__c =: listOfLeads[0].Campaign_Member_Id__c]);

        }  catch (Exception e){
            system.debug('Exception is '+e.getMessage());
        }
    }
}