trigger SUTAQuoteTrigger on SUTA_Quote__c (Before insert, After insert, After Update) {

    //if(SUTAQuoteTriggerHandler.runOnce()){
    
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                SUTAQuoteTriggerHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
            }else if(Trigger.isUpdate){
                SUTAQuoteTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
            }
        }else if(Trigger.isBefore){
            if(Trigger.isInsert){
                SUTAQuoteTriggerHandler.onBeforeInsert(Trigger.new);
            }
        }
    //}
}