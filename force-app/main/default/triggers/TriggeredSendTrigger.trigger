trigger TriggeredSendTrigger on et4ae5__Automated_Send__c (before update) {

    if(trigger.isBefore && trigger.isUpdate){
        TriggeredSendTriggerHandler.markTheActivationTiming(trigger.new, trigger.oldMap);
    }
}