trigger WCRateTrigger on WC_Rate__c (before insert, Before Update, After Insert, After Update) {
    
    if(trigger.isBefore){
        if(trigger.isInsert && WCRateTriggerHandler.runOnce){
            WCRateTriggerHandler.onBeforeInsert(trigger.new, null);
            WCRateTriggerHandler.runOnce = false;
        }else if(trigger.isUpdate && WCRateTriggerHandler.runOnce){
            WCRateTriggerHandler.onBeforeUpdate(trigger.new, null);
            WCRateTriggerHandler.runOnce = false;
        }
    }else if(trigger.isAfter){
        if(trigger.isInsert && WCRateTriggerHandler.runOnce){
            WCRateTriggerHandler.onAfterInsert(trigger.new, null);
            WCRateTriggerHandler.runOnce = false;
        }else if(trigger.isUpdate && WCRateTriggerHandler.runOnce){
            WCRateTriggerHandler.onAfterUpdate(trigger.new, trigger.OldMap);
            WCRateTriggerHandler.runOnce = false;
        }
    }
}