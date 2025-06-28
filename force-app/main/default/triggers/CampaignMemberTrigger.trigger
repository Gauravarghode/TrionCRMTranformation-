trigger CampaignMemberTrigger on CampaignMember (before insert, before update, after update, after insert) {
    
    CampaignMemberTriggerHandler campaignMemberHandler = new CampaignMemberTriggerHandler();
    if(trigger.isInsert &&trigger.isBefore){
        campaignMemberHandler.insertCampaignMembers(trigger.new);
    }
    
    if(trigger.isUpdate &&trigger.isBefore){
        //campaignMemberHandler.insertCampaignMembers(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter){
        system.debug(trigger.new);
        et4ae5.triggerUtility.automate('CampaignMember'); 
    }
     Set<Id> campaignIds = new Set<Id>();
    for (CampaignMember member : Trigger.new) {
        campaignIds.add(member.CampaignId);
    }
    
    
}