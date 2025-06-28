trigger LeadTrigger on Lead (after insert, after update) {

    if(trigger.isInsert && trigger.isAfter){
        LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
        leadTriggerHandler.insertLeadOnIER(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
        leadTriggerHandler.updateLeadOnIER(trigger.new);
    }

}