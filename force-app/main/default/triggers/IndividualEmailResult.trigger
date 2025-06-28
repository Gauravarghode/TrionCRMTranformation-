trigger IndividualEmailResult on et4ae5__IndividualEmailResult__c (before insert, before update) {
    
    IndividualEmailResultsTriggerHandler individualEmailResultsTriggerHandler = new IndividualEmailResultsTriggerHandler();
    //Is there a scenario where the contacts in individual email results changes are updated
    
    if((trigger.isInsert && trigger.isBefore) || (trigger.isUpdate && trigger.isBefore)){
        individualEmailResultsTriggerHandler.insertIndividualEmailResultsTriggerHandler(trigger.new);
        system.debug('trigger.new is '+trigger.new);
    }else if (trigger.isInsert && trigger.isAfter){
        individualEmailResultsTriggerHandler.insertIndividualEmailResultsTriggerHandler(trigger.new);
    }
}