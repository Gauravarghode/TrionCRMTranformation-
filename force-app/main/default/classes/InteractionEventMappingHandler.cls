public class InteractionEventMappingHandler 
{    /*
      * Validation for checking the Campaign Stage before updating Interaction Event Mapping
      */
    public static void beforeUpdate(List<Interaction_event_mapping__c> newInteractioneventmapList){
        set<id> campaignIds = new set<id>();
        for(Interaction_event_mapping__c interactioneEvtmapEach : newInteractioneventmapList){
            campaignIds.add(interactioneEvtmapEach.Campaign__c);
        }
        Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Campaign_Stage__c FROM Campaign WHERE Id IN: campaignIds]);
        for(Interaction_event_mapping__c EachInteractioneEvtmap : newInteractioneventmapList){
            if(mapOfCampaigns.get(EachInteractioneEvtmap.Campaign__c).Campaign_Stage__c != 'Interaction Score'){
                EachInteractioneEvtmap.addError('Attention: Field Restricted. The template mapping cannot be filled/edited at the ' + mapOfCampaigns.get(EachInteractioneEvtmap.Campaign__c).Campaign_Stage__c + ' stage. Kindly advance to the "Interaction Score" stage for population');
                
            }
        }
        
    }
}