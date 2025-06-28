trigger CallToActionTrigger on Call_To_Action__c (after insert) {
    if(trigger.isInsert&&trigger.isAfter){
        CallToActionHandler.insertInteractionEventMap(trigger.new);
    }
}