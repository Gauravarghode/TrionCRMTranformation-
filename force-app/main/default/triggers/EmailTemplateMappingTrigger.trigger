trigger EmailTemplateMappingTrigger on Email_Template_Mapping__c (before insert,before update,after insert, after update) {
    
    if(trigger.isInsert&& trigger.isBefore){
       EmailTemplateMappingHander.beforeInsertcheckCampaignStatus(trigger.new);
        EmailTemplateMappingHander.checkDuplicatesforEmailTEmplate(trigger.new);
    }
     if(trigger.isUpdate&& trigger.isBefore){
       EmailTemplateMappingHander.beforeUpdatecheckCampaignStatus(trigger.new, trigger.oldMap);
       //  EmailTemplateMappingHander.checkDuplicatesforEmailTEmplate(trigger.new);
    }
    if(trigger.isInsert&&trigger.isAfter){
        EmailTemplateMappingHander.updateTriggeredSend(trigger.new);
        EmailTemplateMappingHander.insertInteractionEvtMap(trigger.new);

    }
    
    if(trigger.isUpdate && trigger.isAfter){
        EmailTemplateMappingHander.updateTriggeredSend(trigger.new);
      //  EmailTemplateMappingHander.updateInteractionEvtMap(trigger.new,trigger.oldmap);
    }

}