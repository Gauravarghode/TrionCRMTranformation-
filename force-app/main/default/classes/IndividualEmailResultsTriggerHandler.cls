/*
Author: Rahul Allada
Description: This class updates all the new individual email results with the campaign and campaign member tagged to it
*/
public class IndividualEmailResultsTriggerHandler {
    
    
    List < Id > listOfTriggeredIdsToQuery;
    List < Id > listOfCampaignIds;
    List < Id > listOfContactIds;
    Map < Id, Map < Id, Id >> mapOfCampaignMemberAndContact;
    List < String > emailTemplateIds;
    Map < string, Id > mapOfEmailTemplateIds;
    
    public class CustomException extends exception {}

    public IndividualEmailResultsTriggerHandler() {
        listOfTriggeredIdsToQuery = new List < Id > ();
        listOfCampaignIds = new List < Id > ();
        listOfContactIds = new List < Id > ();
        mapOfCampaignMemberAndContact = new Map < Id, Map < Id, Id >> ();
        emailTemplateIds = new List < String > ();
        mapOfEmailTemplateIds = new Map < String, Id > ();
    }
    
    Public void insertIndividualEmailResultsTriggerHandler(List <et4ae5__IndividualEmailResult__c > listOfIndividualEmailResInserted) {
        
        try {
            for (et4ae5__IndividualEmailResult__c eachIndividualResults: listOfIndividualEmailResInserted) {
                listOfTriggeredIdsToQuery.add(eachIndividualResults.et4ae5__TriggeredSendDefinition__c);
            }
            
            Map < Id, et4ae5__Automated_Send__c > listOfTriggeredSends = new Map < Id, et4ae5__Automated_Send__c > ([SELECT Id, Campaign__c FROM et4ae5__Automated_Send__c WHERE Id IN: listOfTriggeredIdsToQuery]);
            for (et4ae5__IndividualEmailResult__c eachIndividualResults: listOfIndividualEmailResInserted) {
                eachIndividualResults.Campaign__c = listOfTriggeredSends.get(eachIndividualResults.et4ae5__TriggeredSendDefinition__c).Campaign__c;
                listOfCampaignIds.add(eachIndividualResults.Campaign__c);
                listOfContactIds.add(eachIndividualResults.et4ae5__Contact__c);
                emailTemplateIds.add(eachIndividualResults.et4ae5__Email_Asset_ID__c);
            }
            system.debug(emailTemplateIds);
            
            for (Email_Template__c eachEmailTemplate: [SELECT Id, Email_Asset_Id__c, Email_Template_Id__c FROM Email_Template__c WHERE Email_Template_Id__c IN: emailTemplateIds]) {
                mapOfEmailTemplateIds.put(eachEmailTemplate.Email_Template_Id__c, eachEmailTemplate.Id);
            }
            
            for (CampaignMember eachCampaignMember: [SELECT Id, CampaignId, ContactId FROM CampaignMember WHERE CampaignId IN: listOfCampaignIds AND ContactId IN: listOfContactIds]) {
                if (mapOfCampaignMemberAndContact.containsKey(eachCampaignMember.CampaignId)) {
                    mapOfCampaignMemberAndContact.get(eachCampaignMember.CampaignId).put(eachCampaignMember.ContactId, eachCampaignMember.Id);
                } else {
                    mapOfCampaignMemberAndContact.put(eachCampaignMember.CampaignId, new map < Id, Id > {
                        eachCampaignMember.ContactId => eachCampaignMember.Id
                            });
                }
            }
            
            System.debug('mapOfCampaignMemberAndContact is ' + mapOfCampaignMemberAndContact);
            for (et4ae5__IndividualEmailResult__c eachIndividualEmailResult: listOfIndividualEmailResInserted) {
                if (mapOfCampaignMemberAndContact.containsKey(eachIndividualEmailResult.Campaign__c) && mapOfCampaignMemberAndContact.get(eachIndividualEmailResult.Campaign__c).containsKey(eachIndividualEmailResult.et4ae5__Contact__c)) {
                    eachIndividualEmailResult.et4ae5__CampaignMemberId__c = mapOfCampaignMemberAndContact.get(eachIndividualEmailResult.Campaign__c).get(eachIndividualEmailResult.et4ae5__Contact__c);
                }
                system.debug(eachIndividualEmailResult.et4ae5__Email_Asset_ID__c);
                system.debug(mapOfEmailTemplateIds);
                eachIndividualEmailResult.Email_Template__c = mapOfEmailTemplateIds.containsKey(eachIndividualEmailResult.et4ae5__Email_Asset_ID__c) ? mapOfEmailTemplateIds.get(eachIndividualEmailResult.et4ae5__Email_Asset_ID__c) : null;
                system.debug(eachIndividualEmailResult.Email_Template__c);
            }
            if(IndividualEmailResultsTriggerHandlerTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
            
        } catch (exception e) {
            system.debug('exception e is ' + e.getMessage());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause())
            );
        }
    }
    
}