public class CampaignTriggerHandler {

    public class CustomException extends Exception {}

    public CampaignTriggerHandler() {}

    public void updateCampaignMembers(List<Campaign> listOfCampaignsUpdated, Map<Id, Campaign> mapOfCampaignsBeforeUpdate) {
        try {
            List<Id> listOfCampaignsToConsider = new List<Id>();
            List<Id> listOfOtherCampaigns = new List<Id>();

            for(Campaign eachCampaign : listOfCampaignsUpdated) {
                if(mapOfCampaignsBeforeUpdate.get(eachCampaign.Id).Campaign_Stage__c != 'Activated / In Progress' && eachCampaign.Campaign_Stage__c == 'Activated / In Progress') {
                    listOfCampaignsToConsider.add(eachCampaign.Id);
                } else if (mapOfCampaignsBeforeUpdate.get(eachCampaign.Id).Campaign_Stage__c != eachCampaign.Campaign_Stage__c) {
                    listOfOtherCampaigns.add(eachCampaign.Id);
                }
            }

            // Get the list of Campaigns and its members
            Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Campaign_Stage__c, (SELECT Campaign_completed__c, CampaignId FROM CampaignMembers) FROM Campaign WHERE Id IN : listOfCampaignsToConsider]);

            List<CampaignMember> listOfCampaignMembersToUpdate = new List<CampaignMember>();
            for(Id eachCampaign : mapOfCampaigns.keySet()) {
                if(mapOfCampaigns.get(eachCampaign).CampaignMembers.size() > 50) {
                    queueCampaignMembers(mapOfCampaigns.get(eachCampaign).CampaignMembers);
                } else {
                    for(CampaignMember eachCampaignMember : mapOfCampaigns.get(eachCampaign).CampaignMembers) {
                        eachCampaignMember.Status__c = 'Activated / In Progress';
                        listOfCampaignMembersToUpdate.add(eachCampaignMember);
                    }
                }
            }

            if(!listOfCampaignMembersToUpdate.isEmpty()) {
                update listOfCampaignMembersToUpdate;
            }
        } catch(Exception e) {
            System.debug('Exception is ' + e.getMessage());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause())
            );
        }
    }

    public void queueCampaignMembers(List<CampaignMember> campaignMembersToBeUpdated) {
        List<CampaignMember> listOfCampaignMembers = new List<CampaignMember>();

        for(CampaignMember eachCampaignMember : campaignMembersToBeUpdated) {
            listOfCampaignMembers.add(eachCampaignMember);

            if(listOfCampaignMembers.size() == 50) {
                System.enqueueJob(new UpdateCampaignMembersQueuable(new List<CampaignMember>(listOfCampaignMembers)));
                listOfCampaignMembers.clear();
            }
        }

        if(!listOfCampaignMembers.isEmpty()) {
            System.enqueueJob(new UpdateCampaignMembersQueuable(new List<CampaignMember>(listOfCampaignMembers)));
        }
    }

    public static void checkIfTSAreActivatedPreviously(List<Id> listOfCampaignIds, List<Campaign> listOfCampaignsUpdated) {
        Map<Id, Campaign> mapOfCampaignsUpdated = new Map<Id, Campaign>(listOfCampaignsUpdated);
        Map<Id, DateTime> mapOfCampaignIdAndTime = new Map<Id, DateTime>();
        Map<Id, Boolean> mapOfCampaignIdAndActive = new Map<Id, Boolean>();
        Map<Id, Campaign> mapOfCampaignAndETMs = new Map<Id, Campaign>([SELECT Id, (SELECT Id, Name, Template_Last_Activated_On__c FROM Email_Template_Mappings__r WHERE Template_Last_Activated_On__c != NULL AND Status__c = 'Activate' ORDER BY Template_Last_Activated_On__c DESC LIMIT 1) FROM Campaign]);

        for(et4ae5__Automated_Send__c eachAutomatedSend : [SELECT Id, Activated_previously_on__c, Campaign__c, et4ae5__Active__c FROM et4ae5__Automated_Send__c WHERE Campaign__c IN : listOfCampaignIds ORDER BY Activated_previously_on__c DESC LIMIT 1]) {
            mapOfCampaignIdAndTime.put(eachAutomatedSend.Campaign__c, eachAutomatedSend.Activated_previously_on__c);
            mapOfCampaignIdAndActive.put(eachAutomatedSend.Campaign__c, eachAutomatedSend.et4ae5__Active__c);
        }

        for(Id eachCampaignId : listOfCampaignIds) {
            if(mapOfCampaignIdAndActive?.get(eachCampaignId) == false) {
                mapOfCampaignsUpdated.get(eachCampaignId).addError('The triggered send should be activated');
            } else if(mapOfCampaignAndETMs.get(eachCampaignId).Email_Template_Mappings__r[0].Template_Last_Activated_On__c > mapOfCampaignIdAndTime.get(eachCampaignId)) {
                mapOfCampaignsUpdated.get(eachCampaignId).addError('The triggered send should be deactivated and activated');
            }
        }
    }

    public static void createTriggersendInsert(List<Campaign> newCampaignList) {
        List<et4ae5__Automated_Send__c> listOfAutomatedSend = new List<et4ae5__Automated_Send__c>();
        List<et4ae5__Business_Unit__c> listOfBusinessUnit = [SELECT Id, Name FROM et4ae5__Business_Unit__c WHERE Name='Trion Solutions II, Inc' LIMIT 1];
        List<Email_Template__c> listOfemailTemplate = [SELECT Id, Name, Email_Asset_Id__c, Email_Template_Id__c FROM Email_Template__c WHERE Name='Manual timekeeping systems are widely Inaccurate' LIMIT 1];

        for(Campaign campaignObjEach : newCampaignList) {  
            et4ae5__Automated_Send__c eachAutomatedSend = new et4ae5__Automated_Send__c();
            Id inactiveRecordTypeId = Schema.SObjectType.et4ae5__Automated_Send__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
            String filter = '('+ 'campaign_name__c'+' = \''+ campaignObjEach.Name + '\'' +' AND '+ 'interacted__c'+ ' = '+'False'+ ' AND '+'send_campaign_emails__c ' + '=' + ' True ' + 'AND status__c ' + '=' + ' \'Activated / In Progress\''+')';

            eachAutomatedSend.Name = 'Triggered send - ' + ' ' + campaignObjEach.Id;
            eachAutomatedSend.et4ae5__Object__c = 'CAMPAIGNMEMBER';
            eachAutomatedSend.et4ae5__Filter__c = filter;
            eachAutomatedSend.et4ae5__Contact_Lead_Field__c = 'Contact';
            eachAutomatedSend.Campaign__c = campaignObjEach.Id;
            eachAutomatedSend.et4ae5__Hours_Delayed__c = 0;
            eachAutomatedSend.et4ae5__SendClassificationName__c = 'Survey-Classification';
            eachAutomatedSend.et4ae5__SendClassificationId__c = '9c385041-81df-ee11-a5cc-5cba2c1a53e0';
            eachAutomatedSend.et4ae5__Subscriber_Field__c = 'contactid';

            if(listOfBusinessUnit.size() > 0) {
                eachAutomatedSend.et4ae5__Business_Unit__c = listOfBusinessUnit[0].Id;
            }
            eachAutomatedSend.et4ae5__Use_All_Subscribers_List__c = true;
            eachAutomatedSend.et4ae5__Subscribed_For_Tracking__c = true;

            if(listOfemailTemplate.size() > 0) {
                eachAutomatedSend.et4ae5__EmailId__c = listOfemailTemplate[0].Email_Asset_Id__c;
                eachAutomatedSend.et4ae5__EmailAssetId__c = listOfemailTemplate[0].Email_Template_Id__c;
                eachAutomatedSend.et4ae5__EmailName__c = listOfemailTemplate[0].Name;
            }

            eachAutomatedSend.et4ae5__FromEmail__c = 'Gangabhavani@enabledanalytics.com';
            eachAutomatedSend.et4ae5__Active__c = false;
            eachAutomatedSend.RecordTypeId = inactiveRecordTypeId;
            eachAutomatedSend.et4ae5__Action__c = 'EitherSubsequently';

            listOfAutomatedSend.add(eachAutomatedSend);
        }

        try {
            insert listOfAutomatedSend;
            if(CampaignTriggerHandlerTest.isTestFailInsert) {
                throw new CustomException('Fail the test class!');
            }
        } catch(Exception e) {
            System.debug('Exception is ' + e.getMessage());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause())
            );
        }
    }

    public static void validateCampaignstage(Map<Id, Campaign> campaignMapBeforeUpdate, Map<Id, Campaign> campaignMapAfterUpdate) {
        for(Campaign campaignBefore : campaignMapBeforeUpdate.values()) {
            Campaign campaignAfter = campaignMapAfterUpdate.get(campaignBefore.Id);
            if(campaignBefore.Campaign_Stage__c != campaignAfter.Campaign_Stage__c) {
                if(campaignBefore.Campaign_Stage__c == 'Draft' && campaignAfter.Campaign_Stage__c == 'Active') {
                    CampaignTriggerHandler.createTriggersendInsert(new List<Campaign> { campaignAfter });
                }
            }
        }
    }
     public static void checkDuplicateCampaignNames(List<Campaign> listOfInsertedCampaigns, Map<Id, Campaign> oldCampaignMap) {
        List<String> listOfCampaignNames = new List<String>();

        for (Campaign eachCampaign : [SELECT Name FROM Campaign]) {
            listOfCampaignNames.add(eachCampaign.Name);
        }

        for (Campaign eachCampaign : listOfInsertedCampaigns) {
            if (listOfCampaignNames.contains(eachCampaign.Name)) {
                eachCampaign.addError('A campaign with the name ' + eachCampaign.Name + ' already exists! Please give a different name and try again.');
            }
        }
    }

    
}