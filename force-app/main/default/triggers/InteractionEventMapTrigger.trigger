trigger InteractionEventMapTrigger on Interaction_event_mapping__c (before Update) {
    
    if(trigger.isbefore&&trigger.isUpdate){
        InteractionEventMappingHandler.beforeUpdate(trigger.new);
    }
}