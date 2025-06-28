@isTest()
public class InteractionEventMappingHandlerTest {
    
@isTest()
    static void beforeUpdateTestData(){   
        string camStage;
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);  
        for(Campaign cam:campaignList){
            camStage=cam.Campaign_Stage__c;
        }
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);         
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        List<Interaction_event_mapping__c> interactionEvtMapList =TestDataFactory.interactionEventMappingData(true,campaignList[0].id,listOfCallToAction);
        Test.startTest();
        InteractionEventMappingHandler.beforeUpdate(interactionEvtMapList);
        Test.stopTest();
        for(Interaction_event_mapping__c obj:interactionEvtMapList){
            obj.URL__c='www.googletestlink.com';
        }
        Database.update(interactionEvtMapList,false);
        
       // System.assertEquals('Interaction Score', camStage);                
    }
}