public with sharing class LeadTriggerHandler {
    
    public class CustomException extends exception {}
    List<Id> listOfCampaignMemberIds;
    Map<Id, Id> mapOfCampaignMemberAndLead;
    Public LeadTriggerHandler(){
        listOfCampaignMemberIds = new List<Id>();
        mapOfCampaignMemberAndLead = new Map<Id, Id>();
    }    
    Public void insertLeadOnIER(List<Lead> listOfLeadsInserted){
        system.debug(listOfLeadsInserted);
        //Create a map of campaign member and the Lead
        Map<Id, Lead> mapOfCampaignMemberAndLead = new Map<Id, Lead>();
        for(Lead eachLead : listOfLeadsInserted){
            mapOfCampaignMemberAndLead.put(eachLead.Campaign_Member_Id__c, eachLead);
        }
        system.debug('mapOfCampaignMemberAndLead is '+mapOfCampaignMemberAndLead);        
        //Get all the IER's where they are consumed by the scheduler but the Lead is null
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailResults = [SELECT Id, Marked_by_Scheduling__c, et4ae5__Lead__c, Opportunity__c, et4ae5__CampaignMemberId__c FROM et4ae5__IndividualEmailResult__c WHERE Marked_by_Scheduling__c = True AND et4ae5__Lead__c = Null AND et4ae5__TriggeredSendDefinition__c != Null];
        system.debug('listOfIndividualEmailResults is '+system.JSON.serializePretty(listOfIndividualEmailResults));
        for(et4ae5__IndividualEmailResult__c eachIndividualResults : listOfIndividualEmailResults){
            system.debug('eachIndividualResults is '+eachIndividualResults);
            system.debug('eachIndividualResults.et4ae5__CampaignMemberId__c is '+eachIndividualResults.et4ae5__CampaignMemberId__c);
            system.debug('mapOfCampaignMemberAndLead.containsKey(eachIndividualResults.et4ae5__CampaignMemberId__c) is '+mapOfCampaignMemberAndLead.containsKey(eachIndividualResults.et4ae5__CampaignMemberId__c));
            eachIndividualResults.et4ae5__Lead__c = mapOfCampaignMemberAndLead.containsKey(eachIndividualResults.et4ae5__CampaignMemberId__c) ? mapOfCampaignMemberAndLead.get(eachIndividualResults.et4ae5__CampaignMemberId__c).Id : Null;
        }        
        Map<Id, CampaignMember> mapOfCampaignMembers = new Map<Id, CampaignMember>([SELECT Id, Interacted__c, opened__c FROM CampaignMember WHERE Id IN: mapOfCampaignMemberAndLead.keySet()]);
        for(Lead eachLead : listOfLeadsInserted){
            if(!mapOfCampaignMembers.containsKey(eachLead.Campaign_Member_Id__c))
                continue;
            mapOfCampaignMembers.get(eachLead.Campaign_Member_Id__c).opened__c = eachLead.Opened__c == null ? False : eachLead.Opened__c;
            mapOfCampaignMembers.get(eachLead.Campaign_Member_Id__c).Interacted__c = eachLead.Interacted__c == null ? False : eachLead.Interacted__c;
        }
        try{
            Update mapOfCampaignMembers.values();
            Update listOfIndividualEmailResults;
            if(LeadTriggerHandlerTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
            
        } catch(exception e ){
            System.debug('exception e is '+e.getMessage() +' '+e.getStackTraceString());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(), 
                Error_Cause__c = String.valueOf(e.getCause())
            );
        }
    }    
    Public void updateLeadOnIER(List<Lead> listOfLeadsUpdated){        
        Map<Id, Lead> mapOfCampaignMemberAndLead = new Map<Id, Lead>();
        for(Lead eachLead : listOfLeadsUpdated){
            mapOfCampaignMemberAndLead.put(eachLead.Campaign_Member_Id__c, eachLead);
        }
        List<CampaignMember> listOfCampaignMembersToUpdate = new List<CampaignMember>();
        Map<Id, CampaignMember> mapOfCampaignMembers = new Map<Id, CampaignMember>([SELECT Id, Interacted__c, opened__c FROM CampaignMember WHERE Id IN: mapOfCampaignMemberAndLead.keySet()]);
        for(Lead eachLead : listOfLeadsUpdated){
            if(!mapOfCampaignMembers.containsKey(eachLead.Campaign_Member_Id__c))
                continue;
            mapOfCampaignMembers.get(eachLead.Campaign_Member_Id__c).opened__c = eachLead.Opened__c;
            mapOfCampaignMembers.get(eachLead.Campaign_Member_Id__c).Interacted__c = eachLead.Interacted__c;
        }
        try{
            system.debug(mapOfCampaignMembers.values());
            Update mapOfCampaignMembers.values();
            if(LeadTriggerHandlerTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
        } catch(exception e ){
            System.debug('exception e is '+e.getMessage());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause()));
        }
    }
}