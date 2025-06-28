public class TriggeredSendTriggerHandler {
    
    Public static void markTheActivationTiming(List<et4ae5__Automated_Send__c> listOfUpdatedTS, Map<Id, et4ae5__Automated_Send__c> oldTS){
        for(et4ae5__Automated_Send__c eachAutomatedSend: listOfUpdatedTS){
            if(eachAutomatedSend.et4ae5__Active__c == true && oldTS.get(eachAutomatedSend.Id).et4ae5__Active__c == false){
                eachAutomatedSend.Activated_previously_on__c = system.now();
            }
        }
    }

}