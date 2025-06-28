public class TriggeredSendService {

    public static void deactivateSendOfOldestCampaign() {
        
       List<Campaign> oldestCampaign = [SELECT Id 
                                 FROM Campaign 
                                 WHERE Campaign_Stage__c = 'Completed'
                                 AND Id IN (SELECT Campaign__c 
                                            FROM et4ae5__Automated_Send__c 
                                            WHERE et4ae5__Active__c = TRUE)
                                 ORDER BY CreatedDate ASC 
                                 LIMIT 1];
System.debug('Oldest Campaign List: ' + oldestCampaign);
        
        if (!oldestCampaign.isEmpty()) {
            System.debug('Oldest campaign found: ' + oldestCampaign[0].Id );
            deactivateTriggeredSend(oldestCampaign[0].Id);
        } else {
            System.debug(' No oldest campaign found');
        }
    }

    public static void deactivateTriggeredSend(Id campaignId) {
        System.debug(' deactivateTriggeredSend for campaignId: ' + campaignId );
        
        List<et4ae5__Automated_Send__c> triggeredSendList = [SELECT Id, et4ae5__Active__c 
                                                             FROM et4ae5__Automated_Send__c 
                                                             WHERE et4ae5__Object__c = 'CampaignMember' 
                                                             AND et4ae5__Active__c = TRUE 
                                                             AND Campaign__c = :campaignId
                                                             LIMIT 1];
                    System.debug('triggeredSendList ' + triggeredSendList );
        


        if (!triggeredSendList.isEmpty()) {
            et4ae5__Automated_Send__c triggeredSend = triggeredSendList[0];
            System.debug('Triggered send found: ' + triggeredSend.Id );
            
            triggeredSend.et4ae5__Active__c = false;
            update triggeredSend;
            System.debug('Triggered send deactivated: ' + triggeredSend.Id );
        } else {
            System.debug('No triggered send found for campaignId: ' + campaignId );
        }
    }
}