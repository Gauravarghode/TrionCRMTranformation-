trigger AccountTrigger on Account (before insert, before update) {

    AccountTriggerHandler accountTriggerHandler = new AccountTriggerHandler();
    if(trigger.isInsert){
        accountTriggerHandler.fillTheSurveyDate(trigger.new, null);
    } else if (trigger.isUpdate){
        accountTriggerHandler.fillTheSurveyDate(trigger.new, trigger.oldMap);
    }
}