@isTest
public class IndividualLinkLelDetaBatchHandlerTest {
    
    @isTest
    static void fetchLinkLevelDetails(){
        /*
        // Contact Insert
        List<Contact> contactList = TestDataFactory.contactTestData2(true);
        
        // Campaigns Insert
        List<Campaign> campaign1 = TestDataFactory.campaignDataSet1(true);
        List<Campaign> campaign2 = TestDataFactory.campaignDataSet2(true);
        
        // Email Template Insert
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template__c> emailTempList1 = TestDataFactory.emailTemplateData1(true);
        List<Email_Template__c> emailTempList2 = TestDataFactory.emailTemplateData2(true);
        
        // Triggred Send Insert
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggeredSendDataSet(true);
        
        // Lead Insert
        List<Lead> leadList = TestDataFactory.leadDataSet(true);
        
        //Individual Email Result Insert
        List<et4ae5__IndividualEmailResult__c> individualEmailResultList1 = TestDataFactory.induvidualEmailResultDataSet1(true);
        List<et4ae5__IndividualEmailResult__c> individualEmailResultList2 = TestDataFactory.induvidualEmailResultDataSet2(true);
        
        // Interaction Event Mapping Insert
        List<Interaction_event_mapping__c> interactionEventMappingList1 = TestDataFactory.interactionEventMappingDataSet1(true);
        List<Interaction_event_mapping__c> interactionEventMappingList2 = TestDataFactory.interactionEventMappingDataSet2(true);
        List<Interaction_event_mapping__c> interactionEventMappingList3 = TestDataFactory.interactionEventMappingDataSet3(true);
        
        // Individual Link Insert
        List<et4ae5__IndividualLink__c> individualLinkList1 = TestDataFactory.individualLinkDataSet1(false);
        List<et4ae5__IndividualLink__c> individualLinkList2 = TestDataFactory.individualLinkDataSet2(false);
        
        //Lead Update
        Lead varLead2 = new Lead();
        varLead2.Id = leadList[0].Id;
        varLead2.Weightage_Score__c = 20;
        varLead2.Interacted__c = true;
        
        update varLead2;
        
        //Individual Email Result Update
        et4ae5__IndividualEmailResult__c  varIER = new et4ae5__IndividualEmailResult__c();
        varIER.Id = individualEmailResultList1[0].Id;
        varIER.Errored__c = true;
        
        update varIER;
        */
        
        // Individual Link Method with all the Data in a single method
        // Working test class 76%
        // Only works if First_Payroll_Survey_Sent_Requirements Validation Rule is Inactive on Account object
        List<et4ae5__IndividualLink__c> indList = TestDataFactory.getDataOfIndividualLink(true);
        
        Test.startTest();
        
        // Execute the batch
        IndividualLinkLevelDetailsBatchHandler obj = new IndividualLinkLevelDetailsBatchHandler();
        database.executeBatch(obj);
        
        Test.stopTest();
    }
    
}