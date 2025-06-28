trigger campaignTrigger on Campaign (after insert, after update,before update, before insert) {
    CampaignTriggerHandler campaignTrigger = new CampaignTriggerHandler();
    /*if(trigger.isInsert){
campaignTrigger.createInteractionEventmappingRecords(trigger.newMap);
}*/
    
    if(trigger.isInsert && trigger.isBefore){
        CampaignTriggerHandler.checkDuplicateCampaignNames(trigger.new, new Map<Id, Campaign>());
    }
    if(trigger.isUpdate && trigger.isAfter){
        campaignTrigger.updateCampaignMembers(trigger.new, trigger.oldMap);
        //updateStartDate.startDateUpdate(trigger.new);
    }
    if(trigger.isInsert && trigger.isAfter){
        CampaignTriggerHandler.createTriggersendInsert(trigger.new);
        CreateCMS.insertCMS(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isBefore){
        //CampaignTriggerHandler.checkDuplicateCampaignNames(trigger.new, trigger.oldMap);
        CampaignTriggerHandler.validateCampaignstage(trigger.newMap, trigger.oldMap);
    }
}