public with sharing class CampaignMemberTriggerHandler {
    public CampaignMemberTriggerHandler() {

    }

    public void insertCampaignMembers(List<CampaignMember> listOfCampaignMembersInserted){
        try{
        List<Id> listOfCampaignIds = new List<Id>();
        for(CampaignMember eachCampaignMember: listOfCampaignMembersInserted){
            listOfCampaignIds.add(eachCampaignMember.campaignId);
        }
        Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Campaign_Stage__c FROM Campaign WHERE Id IN: listOfCampaignIds]);

        for(CampaignMember eachCampaignMember: listOfCampaignMembersInserted){
            if(mapOfCampaigns.get(eachCampaignMember.campaignId).Campaign_Stage__c =='Member Identification'){
            	eachCampaignMember.Status__c = mapOfCampaigns.get(eachCampaignMember.campaignId).Campaign_Stage__c;
            } else {
                eachCampaignMember.adderror('Attention: Field Restricted. The Campaign Members cannot be filled at the ' +  mapOfCampaigns.get(eachCampaignMember.campaignId).Campaign_Stage__c + 'Stage. Kindly advance to the "Member Identification" stage for population.');
            }
        }
        } 
        catch( exception e)
        {
            System.debug('Exception is '+e.getMessage());
            //Declare the List to hold the Error_Login__c
            List<Error_Login__c> listOfErrorLogin = new List<Error_Login__c>();
            Error_Login__c eachErrorlogin = new Error_Login__c();
            eachErrorlogin.Error_LineNumber__c = e.getLineNumber();
            eachErrorlogin.Error_Message__c = e.getMessage();
            eachErrorlogin.Error_StackTraceString__c = e.getStackTraceString();
            eachErrorlogin.Error_TypeName__c = e.getTypeName();
            eachErrorlogin.Error_Cause__c	= string.valueof(e.getCause());
            listOfErrorLogin.add(eachErrorlogin);
            
            insert listOfErrorLogin;

        }
    }
    
}