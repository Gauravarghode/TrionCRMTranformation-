trigger ProposalTrigger on Proposal__c (Before Insert, Before update, after update) {
    if(trigger.isAfter && trigger.isUpdate){
        ProposalTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }
    
    // Pricing Matrix Logic
    if(trigger.isBefore && trigger.isInsert){
        ProposalTriggerHandler.onBeforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        ProposalTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }

}