global class BatchToUpdateCMStatus implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,et4ae5__HardBounce__c,et4ae5__DateSent__c,et4ae5__Opened__c,Campaign__r.IsActive, et4ae5__NumberOfTotalClicks__c,et4ae5__CampaignMemberId__c,et4ae5__DateUnsubscribed__c,et4ae5__SoftBounce__c, Campaign__c,et4ae5__Contact__c FROM et4ae5__IndividualEmailResult__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> getIerList) {
        
        Map<Id, List<et4ae5__IndividualEmailResult__c>> campaignIER = new Map<Id, List<et4ae5__IndividualEmailResult__c>>();
        Set<Id> uniqueCampaignMemberIds = new Set<Id>();
        List<CampaignMember> cmListupdate = new List<CampaignMember>();

        for (et4ae5__IndividualEmailResult__c iECRec : getIerList) {
            if (iECRec.Campaign__c != null && iECRec.Campaign__r.IsActive ==true) {
                if (!campaignIER.containsKey(iECRec.Campaign__c)) {
                    campaignIER.put(iECRec.Campaign__c, new List<et4ae5__IndividualEmailResult__c>());
                }
                campaignIER.get(iECRec.Campaign__c).add(iECRec);
            }
        }

        System.debug('campaignIER' + campaignIER);

        for (et4ae5__IndividualEmailResult__c iECRec : getIerList) {
            if (iECRec.Campaign__c != null) {
                for (CampaignMember cm : [SELECT Id, CampaignId, ContactId,Campaign.IsActive, Status  FROM CampaignMember WHERE CampaignId = :iECRec.Campaign__c  AND ContactId = :iECRec.et4ae5__Contact__c]) {
                    if (!uniqueCampaignMemberIds.contains(cm.Id)) {
                        system.debug('cm.Campaign.IsActive-->'+cm.Campaign.IsActive);
                        if(cm.Campaign.IsActive ==true){
                        if (iECRec.et4ae5__Opened__c == true && iECRec.et4ae5__DateUnsubscribed__c != null) {
                            cm.Status = 'Unsubscribed';
                        } else if (iECRec.et4ae5__HardBounce__c == true) {
                            cm.Status = 'Hardbounced';
                        } else if (iECRec.et4ae5__SoftBounce__c == true) {
                            cm.Status = 'Softbounced';
                        } else if (iECRec.et4ae5__NumberOfTotalClicks__c >= 1 ) {
                            cm.Status = 'Interacted';
                        } else if (iECRec.et4ae5__Opened__c == true && iECRec.et4ae5__DateSent__c != null) {
                            cm.Status = 'Opened';
                        } else if (iECRec.et4ae5__DateSent__c != null) {
                            cm.Status = 'Sent';
                        }
                        //system.debug(iECRec.et4ae5__SoftBounce__c);
                        //system.debug('campaign of iECRec' + iECRec.Campaign__c);
                        //system.debug('Contact of iECRec' + iECRec.et4ae5__Contact__c);
                        //system.debug('cm Contact Id' + cm.ContactId);
                        //system.debug('cm Campaign Id' + cm.CampaignId);
                        system.debug('cm====>' + cm);
                        cmListupdate.add(cm);
                        uniqueCampaignMemberIds.add(cm.Id);
                    }
                    }
                }
            }
        }

        system.debug('cmListupdate==>' + cmListupdate);
        if (!cmListupdate.isEmpty()) {
            update cmListupdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}