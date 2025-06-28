/*
* Author: Rahul Allada (EA)
* Date: 22nd May 2023
* Description: This batch class handles all the new individual Link level details or updated ones
*/


global class IndividualLinkLevelDetailsBatchHandler implements Database.Batchable<sObject>{
    
    global IndividualLinkLevelDetailsBatchHandler(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, No_Of_Clicks_Tracked__c, et4ae5__NumberOfTotalClicks__c, et4ae5__LinkURL__c, ' +
            'et4ae5__Individual_Email_Result__r.Name, et4ae5__Individual_Email_Result__r.Campaign__c, ' +
            'et4ae5__Individual_Email_Result__r.Campaign__r.Count_Weightage_For_Duplicate_Clicks__c, ' +
            'et4ae5__Individual_Email_Result__r.et4ae5__Lead__c	, ' +
            'et4ae5__Individual_Email_Result__r.et4ae5__TriggeredSendDefinition__c '+
            'FROM et4ae5__IndividualLink__c ' +
            'WHERE Errored__c = False AND et4ae5__Individual_Email_Result__r.et4ae5__Lead__c != Null AND et4ae5__Individual_Email_Result__r.et4ae5__TriggeredSendDefinition__c != Null AND ' +
            '((et4ae5__Individual_Email_Result__r.Campaign__r.Count_Weightage_For_Duplicate_Clicks__c = true) OR ' +
            '(et4ae5__Individual_Email_Result__r.Campaign__r.Count_Weightage_For_Duplicate_Clicks__c = false AND No_Of_Clicks_Tracked__c = 0)) ' +
            'ORDER BY et4ae5__Individual_Email_Result__r.Campaign__c';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualLink__c> listOfIndividualEmailLink) {
        //Map<String, Map<String, Decimal>> mapOfTemplate_Link_Weightage = new Map<String, Map<String, Decimal>>();
        
        // Create a map which has CampaignId -> Template Name -> URL -> Weightage
        Map<Id, Map<String, Map<String, Decimal>>> mapOfCampaignIdAndTemplates = new Map<Id, Map<String, Map<String, Decimal>>>();
        //Create a List to hold all the campaign Ids
        List<Id> listOfCampaignIds = new List<Id>();
        //Create a set to hold all the opportunity Ids
        Set<Id> leadIds = new Set<Id>();
        //Get the list of campaign Ids and opportunity Ids
        for(et4ae5__IndividualLink__c eachIndividualLink: listOfIndividualEmailLink){
            listOfCampaignIds.add(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c);
            leadIds.add(eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c);
        }
        
        //Get the list of all the opprtunities
        Map<Id, Lead> mapOfLeads = new Map<Id, Lead>([SELECT Id, Weightage_Score__c, Interacted__c, Opened__c, Name FROM Lead WHERE Id IN: leadIds]);
        system.debug(mapOfLeads);

        //Get the list of all the email template mappings
        for(Interaction_event_mapping__c eachInteractionEventMapping: [SELECT Campaign__c, Email_Template__r.Name, URL__c, Weightage__c FROM Interaction_event_mapping__c WHERE Campaign__c IN: listOfCampaignIds]){
            Map<String, Map<String, Decimal>> mapOfTemplate_Link_Weightage = new Map<String, Map<String, Decimal>>();
            if(mapOfCampaignIdAndTemplates.containsKey(eachInteractionEventMapping.Campaign__c)){
                mapOfTemplate_Link_Weightage = mapOfCampaignIdAndTemplates.get(eachInteractionEventMapping.Campaign__c);
                if(mapOfTemplate_Link_Weightage.containsKey(eachInteractionEventMapping.Email_Template__r.Name)){
                    mapOfTemplate_Link_Weightage.get(eachInteractionEventMapping.Email_Template__r.Name).put(eachInteractionEventMapping.URL__c, eachInteractionEventMapping.Weightage__c);
                } else {
                    mapOfTemplate_Link_Weightage.put(eachInteractionEventMapping.Email_Template__r.Name, new Map<String, Decimal>{eachInteractionEventMapping.URL__c => eachInteractionEventMapping.Weightage__c});
                }
                mapOfCampaignIdAndTemplates.put(eachInteractionEventMapping.Campaign__c, mapOfTemplate_Link_Weightage);
            } else {
                mapOfCampaignIdAndTemplates.put(eachInteractionEventMapping.Campaign__c, new Map<String, Map<String, Decimal>>{eachInteractionEventMapping.Email_Template__r.Name => new Map<String, Decimal>{eachInteractionEventMapping.URL__c => eachInteractionEventMapping.Weightage__c }});
            }
        }
        
        for(et4ae5__IndividualLink__c eachIndividualLink: listOfIndividualEmailLink){
            system.debug(eachIndividualLink.et4ae5__LinkURL__c);
            if(!eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__r.Count_Weightage_For_Duplicate_Clicks__c){
                //system.debug(mapOfCampaignIdAndTemplates.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c).get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name).get(eachIndividualLink.et4ae5__LinkURL__c));
                system.debug(mapOfLeads.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c).Weightage_Score__c);
                if(mapOfCampaignIdAndTemplates.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c)?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name)?.get(eachIndividualLink.et4ae5__LinkURL__c) != Null){
                	mapOfLeads.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c).Weightage_Score__c += mapOfCampaignIdAndTemplates.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c).get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name).get(eachIndividualLink.et4ae5__LinkURL__c);
                }
                mapOfLeads.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c).Interacted__c = true;
                eachIndividualLink.No_Of_Clicks_Tracked__c = 1;
                eachIndividualLink.Lead__c = eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c;
            } else {
                eachIndividualLink.No_Of_Clicks_Tracked__c = (eachIndividualLink.No_Of_Clicks_Tracked__c == null) ? 0 : eachIndividualLink.No_Of_Clicks_Tracked__c;
                Decimal numberOfClicksToTrack = eachIndividualLink.et4ae5__NumberOfTotalClicks__c - eachIndividualLink.No_Of_Clicks_Tracked__c;
                if(numberOfClicksToTrack >= 0){
                    system.debug('mapOfCampaignIdAndTemplates are '+mapOfCampaignIdAndTemplates);
                    system.debug('eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c is '+eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c);
                    system.debug('eachIndividualLink.et4ae5__Individual_Email_Result__r.Name is '+eachIndividualLink.et4ae5__Individual_Email_Result__r.Name);
                    system.debug('eachIndividualLink.et4ae5__LinkURL__c is '+ eachIndividualLink.et4ae5__LinkURL__c);
                    system.debug(mapOfCampaignIdAndTemplates?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c));
                    system.debug(mapOfCampaignIdAndTemplates?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c)?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name));
                    system.debug(mapOfCampaignIdAndTemplates?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c)?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name)?.get(eachIndividualLink.et4ae5__LinkURL__c));
                    if(mapOfCampaignIdAndTemplates?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c)?.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name)?.get(eachIndividualLink.et4ae5__LinkURL__c) != Null){
                        system.debug('eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c '+eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c);
                        Decimal Weightage = mapOfCampaignIdAndTemplates.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Campaign__c).get(eachIndividualLink.et4ae5__Individual_Email_Result__r.Name).get(eachIndividualLink.et4ae5__LinkURL__c);
                        mapOfLeads.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c).Weightage_Score__c += (Weightage * numberOfClicksToTrack);
                        eachIndividualLink.No_Of_Clicks_Tracked__c = eachIndividualLink.et4ae5__NumberOfTotalClicks__c;
                        mapOfLeads.get(eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c).Interacted__c = true; 
                        eachIndividualLink.Lead__c = eachIndividualLink.et4ae5__Individual_Email_Result__r.et4ae5__Lead__c;
                    } else {
                        eachIndividualLink.Errored__c = true;
                        eachIndividualLink.Error_Description__c = 'Either the URL/Weightage for the Email Template is not available';
                    }
                }
            }
        }
        Database.SaveResult[] leadUpdateResult = Database.update(mapOfLeads.values(), false);
        Database.SaveResult[] IELUpdateResult = Database.update(listOfIndividualEmailLink, false);
        /*try { 
            update mapOfLeads.values();
            update listOfIndividualEmailLink;
        } Catch(exception e){
            system.debug('Exception is '+e.getMessage());
        }*/
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
}