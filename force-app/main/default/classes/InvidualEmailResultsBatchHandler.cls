global class InvidualEmailResultsBatchHandler implements Database.Batchable<sObject> {
    
    List<Id> listOfTriggeredIdsToQuery;
    List<Id> listOfCampaignIds;
    List<Id> listOfContactIds;
    List<Id> listOfCampaignMemberIds;
    Map<Id, Map<Id, Id>> mapOfCampaignMemberAndContact;
    Map<Id, Campaign> mapOfCampaigns;
    
    public InvidualEmailResultsBatchHandler(){
        listOfTriggeredIdsToQuery = new List<Id>();
        listOfCampaignIds = new List<Id>();
        listOfContactIds = new List<Id>();
        mapOfCampaignMemberAndContact = new Map<Id, Map<Id, Id>>();
        listOfCampaignMemberIds = new List<Id>();
        mapOfCampaigns = new Map<Id, Campaign>();
    }
    
    // Get all the IER where scheduling is not marked yet. Scheduled marked is a field that is used to track if the record is marked by the scheduler
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Campaign__c, Campaign__r.Name, et4ae5__Lead__c, '
            + 'et4ae5__CampaignMemberId__c, et4ae5__Contact__c, ' 
            + 'et4ae5__Contact__r.Account.name, '
            + 'et4ae5__Contact__r.Name, et4ae5__TriggeredSendDefinition__c, '
            + 'Create_Opportunity_On_Open__c, et4ae5__NumberOfTotalClicks__c, '
            + 'et4ae5__Opened__c, Marked_by_Scheduling__c '
            + 'FROM et4ae5__IndividualEmailResult__c '
            + 'WHERE Marked_by_Scheduling__c = False AND '
            + 'Campaign__c != Null AND et4ae5__CampaignMemberId__c != Null AND et4ae5__Lead__c = Null ';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailResInserted) {
        // Get the list of all the triggered sends from the IERs
        for(et4ae5__IndividualEmailResult__c eachIndividualResults: listOfIndividualEmailResInserted) {
            listOfCampaignMemberIds.add(eachIndividualResults.et4ae5__CampaignMemberId__c);
            listOfCampaignIds.add(eachIndividualResults.Campaign__c);
        }
        
        // Query the campaigns and store them in a map
        mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Do_Not_Create_Lead__c FROM Campaign WHERE Id IN :listOfCampaignIds]);
        
        List<Lead> listOfLeads = [SELECT Id, Campaign_Member_Id__c FROM Lead WHERE Campaign_Member_Id__c IN :listOfCampaignMemberIds];
        Map<Id, Id> mapOfCampaignMemberAndLead = new Map<Id, Id>();
        for(Lead eachLead: listOfLeads){
            mapOfCampaignMemberAndLead.put(eachLead.Campaign_Member_Id__c, eachLead.Id);
        }
        System.debug('mapOfCampaignMemberAndLead is ' + mapOfCampaignMemberAndLead);
        
        List<Lead> listOfLeadToCreate = new List<Lead>();
        for(et4ae5__IndividualEmailResult__c eachIndividualEmailResult: listOfIndividualEmailResInserted){
            if(mapOfCampaignMemberAndLead.containsKey(eachIndividualEmailResult.et4ae5__CampaignMemberId__c) && mapOfCampaignMemberAndLead.get(eachIndividualEmailResult.et4ae5__CampaignMemberId__c) != null){
                eachIndividualEmailResult.et4ae5__Lead__c = mapOfCampaignMemberAndLead.get(eachIndividualEmailResult.et4ae5__CampaignMemberId__c);
                eachIndividualEmailResult.Marked_by_Scheduling__c = true;
            } else if (!mapOfCampaignMemberAndLead.containsKey(eachIndividualEmailResult.et4ae5__CampaignMemberId__c) && 
                       ((eachIndividualEmailResult.Create_Opportunity_On_Open__c && eachIndividualEmailResult.et4ae5__Lead__c == null && eachIndividualEmailResult.et4ae5__Opened__c) || eachIndividualEmailResult.et4ae5__NumberOfTotalClicks__c > 0) &&
                       !mapOfCampaigns.get(eachIndividualEmailResult.Campaign__c).Do_Not_Create_Lead__c) {
                System.debug('inside');
                listOfLeadToCreate.add(new Lead(Contact__c = eachIndividualEmailResult.et4ae5__Contact__c, 
                                                Campaign__c = eachIndividualEmailResult.Campaign__c,
                                                Campaign_Member_Id__c = eachIndividualEmailResult.et4ae5__CampaignMemberId__c,
                                                Status = 'Open',
                                                Opened__c = eachIndividualEmailResult.et4ae5__Opened__c,
                                                LastName = eachIndividualEmailResult.et4ae5__Contact__r.Name, 
                                                Company = eachIndividualEmailResult.et4ae5__Contact__r.Account.name,
                                                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('MC_Generated_Lead').getRecordTypeId(),
                                                Interacted__c = eachIndividualEmailResult.et4ae5__NumberOfTotalClicks__c > 0 ? true : false));
                
                mapOfCampaignMemberAndLead.put(eachIndividualEmailResult.et4ae5__CampaignMemberId__c, null); // This is to ensure that no new lead is created for the same campaign member.
                eachIndividualEmailResult.Marked_by_Scheduling__c = true;
            }
        }
        System.debug('listOfIndividualEmailResInserted is ' + listOfIndividualEmailResInserted);
        System.debug('listOfLeadToCreate is ' + listOfLeadToCreate);
        Database.SaveResult[] results = Database.update(listOfIndividualEmailResInserted, false);
        Database.SaveResult[] leadResults = Database.insert(listOfLeadToCreate, false);
        Map<Id, et4ae5__IndividualEmailResult__c> mapOfIndividualEmailResults = new Map<Id, et4ae5__IndividualEmailResult__c>(listOfIndividualEmailResInserted);
        for(Integer i = 0; i < leadResults.size(); i++){
            if(!leadResults.get(i).isSuccess()){
                System.debug(leadResults[i]);
                mapOfIndividualEmailResults.get(listOfLeadToCreate.get(i).Individual_Email_Result__c).Marked_by_Scheduling__c = false;
            }
        }
        System.debug('mapOfIndividualEmailResults.values() ' + System.Json.serializePretty(mapOfIndividualEmailResults.values()));
    }
    
    global void finish(Database.BatchableContext BC) {
        // Execute any post-processing operations
    }
}