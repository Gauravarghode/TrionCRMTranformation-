@isTest
private class BatchToUpdateCMStatusTest {

    @isTest
    static void testBatchUpdate() {
        List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', IsActive = true, 	Campaign_Stage__c = 'Creation');
        insert testCampaign;
        
        Account testAccount = new Account(name = 'Test');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;
      
                Contact testContact1 = new Contact(FirstName = 'Test1', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact1;
        
                Contact testContact2 = new Contact(FirstName = 'Test2', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact2;
         
        Contact testContact3 = new Contact(FirstName = 'Test3', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact3;
        
          Contact testContact4 = new Contact(FirstName = 'Test4', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact4;
        

          Contact testContact5 = new Contact(FirstName = 'Test5', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact5;
        
           
        List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
        List<campaign> campaignLst =[SELECT id,Name FROM campaign WHERE id =:testCampaign.Id];
                      List<CampaignMember> listOfCampaignMembersInserted = new List<CampaignMember>();

      for(Campaign campaignEach:campaignLst){
            campaignEach.Campaign_Stage__c = 'Member Identification';
            CampaignMember campaignMemEach= new CampaignMember(CampaignId=campaignEach.id,ContactId=testContact.Id,Status='Send');
            listOfCampaignMembersInserted.add(campaignMemEach);
        }
        Update campaignLst;  
    
        List<CampaignMember> cmList = new List<CampaignMember>();

        CampaignMember testCampaignMember = new CampaignMember(
            CampaignId = campaignLst[0].Id,
            ContactId = testContact.Id,
            Status = 'Sent'
        );
        
        CampaignMember testCampaignMember1 = new CampaignMember(
            CampaignId = campaignLst[0].Id,
            ContactId = testContact1.Id,
            Status = 'Hardbounced'
        );
        
        CampaignMember testCampaignMember2 = new CampaignMember(
            CampaignId = campaignLst[0].Id,
            ContactId = testContact2.Id,
            Status = 'Softbounced'
        );
        
        CampaignMember testCampaignMember3 = new CampaignMember(
            CampaignId = campaignLst[0].Id,
            ContactId = testContact3.Id,
            Status = 'Opened'
        );
         CampaignMember testCampaignMember4 = new CampaignMember(
            CampaignId = campaignLst[0].Id,
            ContactId = testContact4.Id,
            Status = 'Interacted'
        );
           CampaignMember testCampaignMember5 = new CampaignMember(
            CampaignId = campaignLst[0].Id,
            ContactId = testContact5.Id,
            Status = 'Unsubscribed'
        );
        
        
     
        cmList.add(testCampaignMember);
        cmList.add(testCampaignMember1);
        cmList.add(testCampaignMember2);
        cmList.add(testCampaignMember3);
        cmList.add(testCampaignMember4);
         cmList.add(testCampaignMember5);

        insert cmList;
        
        et4ae5__Automated_Send__c eachAutomatedSend = new et4ae5__Automated_Send__c();
        
        Id inactiveRecordTypeId = Schema.SObjectType.et4ae5__Automated_Send__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
        
        string filter =	'('+ 'campaign_name__c'+' = \''+ campaignLst[0].Name + '\'' +' AND '+ 'interacted__c'+ ' = '+'False'+ ' AND '+'send_campaign_emails__c ' + '=' + ' True ' + 'AND status__c ' + '=' + ' \'Activated / In Progress\''+')';
        // system.debug(filter);
        eachAutomatedSend.Name = campaignLst[0].Name + ' ' + campaignLst[0].Id;
        eachAutomatedSend.et4ae5__Object__c = 'CAMPAIGNMEMBER';
        eachAutomatedSend.et4ae5__Filter__c = filter;
        eachAutomatedSend.et4ae5__Contact_Lead_FIeld__c = 'Contact';
        eachAutomatedSend.Campaign__c = campaignLst[0].id;
        eachAutomatedSend.et4ae5__Data_Extension_Name__c ='TriggeredSDE';
        eachAutomatedSend.et4ae5__Hours_Delayed__c = 0;
        eachAutomatedSend.et4ae5__SendClassificationName__c = 'Default Transactional';
        eachAutomatedSend.et4ae5__SendClassificationId__c = '22b1bff8-8ea9-ed11-a5b6-5cba2c193328';
        eachAutomatedSend.et4ae5__Subscriber_Field__c='contactid';
       // if(listOfBusinessUnit.size()>0){
         //   eachAutomatedSend.et4ae5__Business_Unit__c = listOfBusinessUnit[0].id;}
        eachAutomatedSend.et4ae5__FromEmail__c = 'rahulallada@enabledanalytics.com';
        eachAutomatedSend.et4ae5__Active__c = false;
        eachAutomatedSend.RecordTypeId = inactiveRecordTypeId;
        eachAutomatedSend.et4ae5__Action__c = 'EitherSubsequently';
        //eachAutomatedSend.et4ae5__EmailId__c = emailTempList[0].Email_Asset_Id__c;
        //eachAutomatedSend.et4ae5__EmailAssetId__c = emailTempList[0].Email_Template_Id__c;
        //eachAutomatedSend.et4ae5__EmailName__c = emailTempList[0].Name;
        
        /* RecordType rtypes = [Select Name, Id From RecordType where sObjectType='et4ae5__Automated_Send__c' and isActive=true limit 1];
List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
et4ae5__Automated_Send__c automatedSendVar = new et4ae5__Automated_Send__c(et4ae5__Action__c='Insert',et4ae5__Active__c=false,et4ae5__Business_Unit__c='a0q8G000000pSCiQAM',et4ae5__Contact_Lead_FIeld__c='Contact',et4ae5__ConversationId__c='00D8G0000004ZP2a0o8G000001Wft4',et4ae5__EmailAssetId__c='11874',et4ae5__EmailId__c='2925',et4ae5__EmailName__c='Email1Test',et4ae5__etTriggeredSendDefId__c='1bcd2df4-aef3-ed11-a5c0-5cba2c1a53e8',et4ae5__FromEmail__c='rahulallada@enabledanalytics.com',et4ae5__FromName__c='MC Connect-CRM',et4ae5__hasDelayedSends__c=false,et4ae5__Notify_Owner_On_Error__c=false,et4ae5__Notify_Running_User_On_Error__c=true,et4ae5__NumberofExistingUndeliverables__c=0,et4ae5__NumberofExistingUnsubscribes__c=0,et4ae5__NumberofHardBounces__c=0,et4ae5__NumberofSoftBounces__c=0,et4ae5__NumberofSubscribersForwardingEmail__c=0,et4ae5__NumberofTotalClicks__c=3,et4ae5__NumberofTotalOpens__c=1,et4ae5__NumberofUniqueClicks__c=1,et4ae5__NumberofUniqueOpens__c=1,et4ae5__NumberSent__c=1,et4ae5__NumberUnsubscribed__c=0,et4ae5__Object__c='CAMPAIGNMEMBER',et4ae5__RecipientsOptedIn__c=true,et4ae5__SendClassificationId__c='22b1bff8-8ea9-ed11-a5b6-5cba2c193328',et4ae5__SendClassificationName__c='DefaultTransactional',et4ae5__SenderProfileId__c='BB301DB7-B5F3-ED11-A5C0-5CBA2C1A53E8',et4ae5__Subject__c='Emailtest1',et4ae5__SubjectBlob__c='RW1haWx0ZXN0MQ==',et4ae5__Subscribed_For_Tracking__c=true,et4ae5__Subscriber_Field__c='contactid',et4ae5__TrackingOnly__c=false,et4ae5__Use_All_Subscribers_List__c=true,Name='Test Triggered send',OwnerId='0058G000003nBCaQAM',RecordTypeId=rtypes.Id, Campaign__c=campaignId,Activated_previously_on__c=system.now();*/
        listOfTriggerSend.add(eachAutomatedSend);
        insert listOfTriggerSend;
    
        et4ae5__IndividualEmailResult__c testIER = new et4ae5__IndividualEmailResult__c(
            Campaign__c = testCampaign.Id,
            et4ae5__Contact__c = testContact3.Id,
            et4ae5__Opened__c = true,
            et4ae5__DateUnsubscribed__c = System.today(),
            et4ae5__TriggeredSendDefinition__c = listOfTriggerSend[0].id
            
        );
        
         et4ae5__IndividualEmailResult__c testIER1 = new et4ae5__IndividualEmailResult__c(
            Campaign__c = testCampaign.Id,
            et4ae5__Contact__c = testContact1.Id,
            et4ae5__HardBounce__c = true,
            et4ae5__DateUnsubscribed__c = System.today(),
            et4ae5__TriggeredSendDefinition__c = listOfTriggerSend[0].id
            
        );
            et4ae5__IndividualEmailResult__c testIER2 = new et4ae5__IndividualEmailResult__c(
            Campaign__c = testCampaign.Id,
            et4ae5__Contact__c = testContact2.Id,
            et4ae5__SoftBounce__c = true,
            et4ae5__DateUnsubscribed__c = System.today(),
            et4ae5__TriggeredSendDefinition__c = listOfTriggerSend[0].id
            
        );
            et4ae5__IndividualEmailResult__c testIER3 = new et4ae5__IndividualEmailResult__c(
            Campaign__c = testCampaign.Id,
            et4ae5__Contact__c = testContact4.Id,
            et4ae5__NumberOfTotalClicks__c = 1,
            //et4ae5__DateUnsubscribed__c = System.today(),
            et4ae5__TriggeredSendDefinition__c = listOfTriggerSend[0].id
            
        );
         et4ae5__IndividualEmailResult__c testIER4 = new et4ae5__IndividualEmailResult__c(
            Campaign__c = testCampaign.Id,
            et4ae5__Contact__c = testContact.Id,
            et4ae5__DateSent__c = system.today(),
            //et4ae5__DateUnsubscribed__c = System.today(),
            et4ae5__TriggeredSendDefinition__c = listOfTriggerSend[0].id
            
        );
        
            et4ae5__IndividualEmailResult__c testIER5 = new et4ae5__IndividualEmailResult__c(
            Campaign__c = testCampaign.Id,
            et4ae5__Contact__c = testContact5.Id,
            et4ae5__Opened__c = true,
            et4ae5__DateSent__c = system.today(),
            //et4ae5__DateUnsubscribed__c = System.today(),
            et4ae5__TriggeredSendDefinition__c = listOfTriggerSend[0].id
            
        );
        
      
        ierList.add(testIER);
		ierList.add(testIER1);
        ierList.add(testIER2);
        ierList.add(testIER3);
        ierList.add(testIER4);
        insert ierList;

        for (et4ae5__IndividualEmailResult__c ier : ierList) {
            for (CampaignMember cm : cmList) {
                if (ier.Campaign__c == cm.CampaignId && ier.et4ae5__Contact__c == cm.ContactId) {
                    ier.et4ae5__CampaignMemberId__c = cm.Id;
                    break;
                }
            }
        }

        update ierList;

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {

        BatchToUpdateCMStatus ba = new BatchToUpdateCMStatus();
        Database.executeBatch(ba);
        }
        Test.stopTest();

       
    }
}