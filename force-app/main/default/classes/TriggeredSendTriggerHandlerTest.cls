@isTest()
public class TriggeredSendTriggerHandlerTest {
    @isTest()
    static void markTheActivationTimingTest(){
        Datetime sendEach;
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
        try{
            Map<id,et4ae5__Automated_Send__c> oldMapTriggerSend = new Map<id,et4ae5__Automated_Send__c>();
            for(et4ae5__Automated_Send__c triggerSendEach:listOfTriggerSend){
                oldMapTriggerSend.put(triggerSendEach.id,triggerSendEach);
                triggerSendEach.et4ae5__Active__c=true;
                triggerSendEach.Activated_previously_on__c=system.now();
                sendEach=triggerSendEach.Activated_previously_on__c;
            }
            //Test.startTest();
            //TriggeredSendTriggerHandler.markTheActivationTiming(listOfTriggerSend,oldMapTriggerSend);
            //Test.stopTest();
            update listOfTriggerSend;
            
           // System.assertEquals(System.now(), sendEach);
        }catch(Exception e){
            system.debug('Exception is '+e.getMessage());
            
        }
        
        
    }
    
}