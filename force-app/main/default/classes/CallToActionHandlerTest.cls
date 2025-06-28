@isTest
public class CallToActionHandlerTest {
    
    public static boolean isTestFailInsert = false;
    
    @isTest
    static void insertInteractionEventMapTestMethod() {
        // Create test data
        
        
        CallToActionHandlerTest.isTestFailInsert = true;
        
        
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].Id, true);
        List<Error_Login__c> errLogList = TestDataFactory.errorLoginTestData(true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true, emailTempList[0].Id);
        //insert listOfCallToAction;
        
        String actionName;
        List<Interaction_event_mapping__c> interactionEventMapList = [
            SELECT Action_Name__c, URL__c, Campaign__c, Email_Template__c
            FROM Interaction_event_mapping__c
        ];
        for(Interaction_event_mapping__c inEventMappingList: interactionEventMapList){
            actionName = inEventMappingList.Action_Name__c;
        }
        
        Interaction_event_mapping__c interactionEventMap = interactionEventMapList[0];
        System.assertEquals(actionName, interactionEventMap.Action_Name__c);
        System.assertEquals(listOfCallToAction[0].CTA_URL__c, interactionEventMap.URL__c);
        System.assertEquals(listOfEmailTempMapp[0].Campaign__c, interactionEventMap.Campaign__c);
        System.assertEquals(listOfEmailTempMapp[0].Email_Template__c, interactionEventMap.Email_Template__c);
    }
}