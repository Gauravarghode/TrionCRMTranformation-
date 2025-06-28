trigger UpdateCaseOwner on Case (before insert, before update, after insert, after update) { 
    
    CaseTriggerHandler caseTriggerHandler = new CaseTriggerHandler();
    if(trigger.isInsert && trigger.isBefore){
        caseTriggerHandler.triggerTheSurveyForTheFirstTime(trigger.new, Null);
    } else if(trigger.isUpdate && trigger.isBefore){
        caseTriggerHandler.triggerTheSurveyForTheFirstTime(trigger.new, trigger.oldMap);
    }
    
    if(trigger.isInsert && trigger.isAfter){
        caseTriggerHandler.markTheSurveyLastSentOnDateOnContact(trigger.new, Null);
    } else if(trigger.isUpdate && trigger.isAfter){
        caseTriggerHandler.markTheSurveyLastSentOnDateOnContact(trigger.new, trigger.oldMap);
    }
   /* for(Case cs : Trigger.New){ 
        String ownId = cs.OwnerId; 
        //check status & owner of case is queue or not 
        if(trigger.isUpdate && cs.Status != Trigger.oldMap.get(cs.Id).Status && ownId.startsWith('00G')){ 
            cs.OwnerId = Userinfo.getUserId(); 
        } 
        else if(ownId.startsWith('00G')&& cs.Status == 'Closed'){ 
            cs.OwnerId = Userinfo.getUserId(); 
        } 
    } */
}