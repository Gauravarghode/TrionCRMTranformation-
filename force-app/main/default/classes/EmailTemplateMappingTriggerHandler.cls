public class EmailTemplateMappingTriggerHandler {
    
    List<Id> listOfTemplateIdsInserted;
    Map<String, Map<String, String>> mapOfEmailTemplatesAndCtas;
    Map<Id, Set<Id>> mapOfCampaignsAndEmailTemplates;
    Public EmailTemplateMappingTriggerHandler(){
        listOfTemplateIdsInserted = new List<Id>();
        mapOfEmailTemplatesAndCtas = new Map<String, Map<String, String>>();
        mapOfCampaignsAndEmailTemplates = new Map<Id, Set<Id>>();
    }
    
    Public void createEmailTemplateMappingInCampaigns( List<Email_Template_Mapping__c> listOfNewEmailTemplateMapping ){
        for(Email_Template_Mapping__c eachEmailTemplateMapping : listOfNewEmailTemplateMapping){
            listOfTemplateIdsInserted.add(eachEmailTemplateMapping.Email_Template__c);
            if(mapOfCampaignsAndEmailTemplates.containsKey(eachEmailTemplateMapping.Campaign__c)){
                //mapOfCampaignsAndEmailTemplates.get(eachEmailTemplateMapping.Campaign__c).add()
            }
        }
        for(Email_Template__c eachEmailTemplate : [SELECT Id, Name, (SELECT Name, CTA_URL__c FROM Call_To_Actions__r) FROM Email_Template__c WHERE Id IN: listOfTemplateIdsInserted]){
            for(Call_To_Action__c eachCallToAction : eachEmailTemplate.Call_To_Actions__r){
                if(!mapOfEmailTemplatesAndCtas.containsKey(eachEmailTemplate.Id)){
                    mapOfEmailTemplatesAndCtas.put(eachEmailTemplate.Id, new Map<String, String>{eachCallToAction.Name => eachCallToAction.CTA_URL__c});
                } else {
                    mapOfEmailTemplatesAndCtas.get(eachEmailTemplate.Id).put(eachCallToAction.Name, eachCallToAction.CTA_URL__c);
                }
            }
        }        
        List<Interaction_event_mapping__c> listOfInteractionMapping = new List<Interaction_event_mapping__c>();        
    }   
}