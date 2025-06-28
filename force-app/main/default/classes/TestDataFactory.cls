@isTest()
public class TestDataFactory {
    
   public static List<Campaign> campaignTestData(Boolean doInsert){
    List<Campaign> listOfCampaign = new List<Campaign>();
    String uniqueSuffix = Datetime.now().getTime().toString(); // Add a unique timestamp
    Campaign campaignEach = new Campaign(Name='Test Campaign EA22 ' + uniqueSuffix, IsActive=true, Campaign_Stage__c='Creation', Create_Opportunity_On_Open__c=true);
    listOfCampaign.add(campaignEach);
    if(doInsert==True){
        insert listOfCampaign;
    }
    return listOfCampaign;
}
    
    Public static List<Contact_Type__c> insertContactType(Boolean doInsert){
        
        Contact_Type__c eachContactType = new Contact_Type__c(Name = 'Director', Default_Days__c = 10);
        if(doInsert==True){
            insert eachContactType;
        }
        
        return new List<Contact_Type__c>{eachContactType};
    }
    
    Public static List<Campaign> campaignTestData1(Boolean doInsert){
        List<Campaign> listOfCampaign = new List<Campaign>();
        Campaign campaignEach = new Campaign(Name='Test Campaign',IsActive=true,Campaign_Stage__c='Creation',Create_Opportunity_On_Open__c=true,Count_Weightage_For_Duplicate_Clicks__c=true);
        listOfCampaign.add(campaignEach);
        if(doInsert==True){
            insert listOfCampaign;
        }
        return listOfCampaign;
        
    }
    Public static List<Lead> leadTestData(Boolean doInsert, id campaignMemId){
        List<Lead> listOfLead = new List<Lead>();
        Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('MC Generated Lead').getRecordTypeId();

        Lead leadEach = new Lead(LastName = 'Test Contact',Company='company', Opened__c = true, Interacted__c = true, Campaign_Member_Id__c = campaignMemId );
        listOfLead.add(leadEach);
        if(doInsert==True){
            insert listOfLead;
        }
        return listOfLead;
        
    }
    
     Public static List<Error_Login__c> errorLoginTestData(Boolean doInsert){
        List<Error_Login__c> listOfErrorLogin = new List<Error_Login__c>();
        Error_Login__c errorLoginEach = new Error_Login__c(Error_LineNumber__c = 12,Error_Message__c = 'Test Error', Error_StackTraceString__c = 'Test Stack', Error_TypeName__c = 'Test type name', Error_Cause__c	= 'Test cause');
        listOfErrorLogin.add(errorLoginEach);
        if(doInsert==True){
            insert listOfErrorLogin;
        }
        return listOfErrorLogin;
        
    }
    
    
    

    public static List<Account> accountTestData(Boolean doInsert) {
        List<Account> listOfAccount = new List<Account>();
      
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
        
        Account accountEach = new Account(
            Name = 'Test Account',
            Status__c = 'Onboarding',
            Website = 'www.test.com',
            Send_Survey_Again__c = false,
            Payroll_survey_last_sent_on__c = Date.today(),
            RecordTypeId = RecordTypeIdAccount
           
        );
        listOfAccount.add(accountEach);
        
        if (doInsert == true) {
            insert listOfAccount;
        }
        
        return listOfAccount;
    }
    
     public static List<Account> accountTestData1(Boolean doInsert, Id payrollContact) {
        List<Account> listOfAccount = new List<Account>();
      
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
        
        Account accountEach = new Account(
            Name = 'Test Account',
            Status__c = 'Onboarding',
            Website = 'www.test.com',
            Send_Survey_Again__c = false,
            Payroll_survey_last_sent_on__c = Date.today(),
            RecordTypeId = RecordTypeIdAccount, 
            Payroll_Contact__c = payrollContact
           
        );
        listOfAccount.add(accountEach);
        
        if (doInsert == true) {
            insert listOfAccount;
        }
        
        return listOfAccount;
    }
    
    


    
    public static List<Contact> contactTestData2(Boolean doInsert){
        List<Account> list2OfAccount = new List<Account>();  
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
        
        Account accountEach = new Account(Name='Test Account', Status__c ='Onboarding', Website = 'www.test.com', Send_Survey_Again__c = false, Payroll_survey_last_sent_on__c = date.today(), RecordTypeId=RecordTypeIdAccount);
        insert accountEach;

        Contact_Type__c eachContactType = new Contact_Type__c(Name = 'Director', Default_Days__c = 10);
        insert eachContactType;
        List<Contact> contactList = new List<Contact>();
        
        
        Contact contactEach = new Contact();
        contactEach.AccountId=accountEach.id; 
        contactEach.Email='test@gmail.com';
        contactEach.LastName ='TestContact';
        contactEach.Survey_Last_sent_on__c=system.today();
        contactEach.Contact_Type__c = eachContactType.Id;
        contactEach.Default_Days_Survey__c = 1;
          
            
        contactList.add(contactEach);
        if(doInsert==True){
            insert contactList;
        }
        
        accountEach.Payroll_Contact__c = contactList[0].Id;
        update accountEach;
        
        return contactList;
    }
    
public static List<Case> caseTestData(Boolean doInsert) {


    Account acc = new Account(Name='TestAccount');
        insert acc;

    Contact_Type__c eachContactType = new Contact_Type__c(Name = 'Director', Default_Days__c = 10);
        insert eachContactType;

     Contact contactEach = new Contact(
        AccountId=acc.id,
        Email='test@gmail.com',
       LastName ='TestContact',
     Default_Days_Survey__c=1,
    Contact_Type__c = eachContactType.Id,
       Survey_Last_sent_on__c=date.today());
    
    insert contactEach;
        
    
    List<Case> caseList = new List<Case>();
   
    Case caseEach = new Case(
        Send_Survey_Email__c = true,
        ContactId = contactEach.Id,
        Send_Survey_Email_Again__c = true,
        Survey_Last_sent_on__c = Date.today()
        
        
    );
    
    caseList.add(caseEach);
    
    if (doInsert) {
        insert caseList;
    }
    
    return caseList;
}
    
       public static List<Contact> contactData1(Boolean doInsert)
    {
        List<Contact> contactList = new List<Contact>();
        
        Account acc = new Account(Name='TestAccount');
        insert acc;

        Contact_Type__c eachContactType = new Contact_Type__c(Name = 'Director', Default_Days__c = 10);
        insert eachContactType;
        Contact contactEach = new Contact();
        contactEach.AccountId=acc.id;
        contactEach.Email='test@gmail.com';
        contactEach.LastName ='TestContact';
        contactEach.Default_Days_Survey__c=1;
        contactEach.Survey_Last_sent_on__c=date.today();
        contactEach.Contact_Type__c=eachContactType.Id;
        
        contactList.add(contactEach);
        if(doInsert==True){
            insert contactList;
        }
        return contactList;
        
    }
    
    

    
    
    
    
    
    Public static List<Email_Template__c> emailTemplateData(Boolean doInsert){
        List<Email_Template__c> listOfEmailTemp = new List<Email_Template__c>();
        
        Email_Template__c emailTempEach = new Email_Template__c(Name ='TestTemplate',Email_Asset_Id__c ='4567',Email_Template_Id__c='23456');
        listOfEmailTemp.add(emailTempEach);
        
        if(doInsert==True){
            insert listOfEmailTemp;
        }
        return listOfEmailTemp;
    } 
    
    Public static List<Email_Template__c> emailTemplateData1(Boolean doInsert){
        List<Email_Template__c> listOfEmailTemp1 = new List<Email_Template__c>();
        
        Email_Template__c emailTempEach = new Email_Template__c(Name ='TestTemplate1',Email_Asset_Id__c ='45671',Email_Template_Id__c='234561');
        listOfEmailTemp1.add(emailTempEach);
        
        if(doInsert==True){
            insert listOfEmailTemp1;
        }
        return listOfEmailTemp1;
    }
    
    Public static List<Email_Template__c> emailTemplateData2(Boolean doInsert){
        List<Email_Template__c> listOfEmailTemp2 = new List<Email_Template__c>();
        
        Email_Template__c emailTempEach = new Email_Template__c(Name ='TestTemplate2',Email_Asset_Id__c ='45672',Email_Template_Id__c='234562');
        listOfEmailTemp2.add(emailTempEach);
        
        if(doInsert==True){
            insert listOfEmailTemp2;
        }
        return listOfEmailTemp2;
    }
    
      Public static List<Email_Template__c> emailTemplateUpdateData(Boolean doInsert){
        List<Email_Template__c> listOfEmailTemp = new List<Email_Template__c>();
        
        Email_Template__c emailTempEach = new Email_Template__c(Name ='TemplateTest',Email_Asset_Id__c ='45676',Email_Template_Id__c='93456');
        listOfEmailTemp.add(emailTempEach);
        
        if(doInsert==True){
            insert listOfEmailTemp;
        }
        return listOfEmailTemp;
    }  
    
    
    
    
    Public static List<Email_Template_Mapping__c> emailTemplateMapData(List<Campaign> campaignList,id emailTemplateId,Boolean doInsert){
        
        List<Email_Template_Mapping__c> listOfEmailTempMapp = new List<Email_Template_Mapping__c>();
        for(Campaign campaignEach:campaignList){
            campaignEach.Campaign_Stage__c ='Template Tagging';
            Email_Template_Mapping__c emailTempMappEach = new Email_Template_Mapping__c(Email_Template__c = emailTemplateId,Campaign__c = campaignEach.id,Status__c = 'Not Activated');
            listOfEmailTempMapp.add(emailTempMappEach);
        }
        Update campaignList;
        
        
        // Email_Template_Mapping__c emailTempMappEachtest = new Email_Template_Mapping__c(Email_Template__c = emailTemplateId,Campaign__c = campaignId,Status__c = 'Not Active');
        //  listOfEmailTempMapp.add(emailTempMappEachtest);
        if(doInsert==True){
            insert listOfEmailTempMapp;
        }
        return listOfEmailTempMapp;
    }
    
    Public static List<Email_Template_Mapping__c> emailTemplateMapData1(List<Campaign> campaignList, id emailTemplateId,Boolean doInsert){
        List<Email_Template_Mapping__c> listOfEmailTempMapp = new List<Email_Template_Mapping__c>();
        
        Email_Template_Mapping__c emailTempMappEach = new Email_Template_Mapping__c(Email_Template__c = emailTemplateId,Status__c = 'Not Activated');
        listOfEmailTempMapp.add(emailTempMappEach);
        // Email_Template_Mapping__c emailTempMappEachtest = new Email_Template_Mapping__c(Email_Template__c = emailTemplateId,Campaign__c = campaignId,Status__c = 'Not Active');
        //  listOfEmailTempMapp.add(emailTempMappEachtest);
        if(doInsert==True){
            insert listOfEmailTempMapp;
        }
        return listOfEmailTempMapp;
    }
    
    Public static List<Email_Template_Mapping__c> emailTemplateMapDataActive(id campaignId,id emailTemplateId,Boolean doInsert){
        List<Email_Template_Mapping__c> listOfEmailTempMapp = new List<Email_Template_Mapping__c>();
        
        Email_Template_Mapping__c emailTempMappEach = new Email_Template_Mapping__c(Email_Template__c = emailTemplateId,Campaign__c = campaignId,Status__c = 'Activate');
        listOfEmailTempMapp.add(emailTempMappEach);
        // Email_Template_Mapping__c emailTempMappEachtest = new Email_Template_Mapping__c(Email_Template__c = emailTemplateId,Campaign__c = campaignId,Status__c = 'Not Active');
        //  listOfEmailTempMapp.add(emailTempMappEachtest);
        if(doInsert==True){
            insert listOfEmailTempMapp;
        }
        return listOfEmailTempMapp;
    }
    
    Public static List<Call_To_Action__c> callToActionTestData(Boolean doInsert,id emailTemplateId){
        
        List<Call_To_Action__c> listOfCallToAction = new List<Call_To_Action__c>();
        Call_To_Action__c callToActionEach = new Call_To_Action__c(CTA_URL__c ='www.eainfo.com',Email_Template__c = emailTemplateId);
        listOfCallToAction.add(callToActionEach);
        if(doInsert==True){
            insert listOfCallToAction;
        }
        return listOfCallToAction;
    }
    
     Public static List<Call_To_Action__c> callToActionTestUpdateData(Boolean doInsert,id emailTemplateId){
        
        List<Call_To_Action__c> listOfCallToAction = new List<Call_To_Action__c>();
        Call_To_Action__c callToActionEach = new Call_To_Action__c(CTA_URL__c ='www.einfo.com',Email_Template__c = emailTemplateId);
        listOfCallToAction.add(callToActionEach);
        if(doInsert==True){
            insert listOfCallToAction;
        }
        return listOfCallToAction;
    }
    
    
    
    
    
    
    public static List<et4ae5__Business_Unit__c> businessUnitTestData1(Boolean doInsert){
        
        List<et4ae5__Business_Unit__c> listOfBusinessUnit = new List<et4ae5__Business_Unit__c>();
       et4ae5__Business_Unit__c businessVar = new et4ae5__Business_Unit__c(
            Name = 'Test Business Unit',
            et4ae5__Enabled__c = true,
            et4ae5__IsParentAccountMID__c = true,
            et4ae5__Business_Unit_ID__c = '546000953');
        
     listOfBusinessUnit.add(businessVar);      
        if(doInsert==True){
            insert listOfBusinessUnit;
        }
        return listOfBusinessUnit;
    }
    
    public static List<et4ae5__Automated_Send__c>  triggerSendTestData(Boolean doInsert,id campaignId,List<et4ae5__Business_Unit__c> businessUnitList,List<Email_Template__c> emailTempList){
        List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
        List<et4ae5__Business_Unit__c> listOfBusinessUnit = [Select id,Name from et4ae5__Business_Unit__c Where id IN: businessUnitList Limit 1];
        List<campaign> campaignLst =[SELECT id,Name FROM campaign WHERE id =:campaignId];
       // List<Email_Template__c> listOfemailTemplate = [Select id,Name,Email_Asset_Id__c,Email_Template_Id__c from Email_Template__c where Name='Manual timekeeping systems are widely Inaccurate' Limit 1  ];
        
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
        if(listOfBusinessUnit.size()>0){
            eachAutomatedSend.et4ae5__Business_Unit__c = listOfBusinessUnit[0].id;}
        eachAutomatedSend.et4ae5__FromEmail__c = 'rahulallada@enabledanalytics.com';
        eachAutomatedSend.et4ae5__Active__c = false;
        eachAutomatedSend.RecordTypeId = inactiveRecordTypeId;
        eachAutomatedSend.et4ae5__Action__c = 'EitherSubsequently';
        eachAutomatedSend.et4ae5__EmailId__c = emailTempList[0].Email_Asset_Id__c;
        eachAutomatedSend.et4ae5__EmailAssetId__c = emailTempList[0].Email_Template_Id__c;
        eachAutomatedSend.et4ae5__EmailName__c = emailTempList[0].Name;
        
        /* RecordType rtypes = [Select Name, Id From RecordType where sObjectType='et4ae5__Automated_Send__c' and isActive=true limit 1];
List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
et4ae5__Automated_Send__c automatedSendVar = new et4ae5__Automated_Send__c(et4ae5__Action__c='Insert',et4ae5__Active__c=false,et4ae5__Business_Unit__c='a0q8G000000pSCiQAM',et4ae5__Contact_Lead_FIeld__c='Contact',et4ae5__ConversationId__c='00D8G0000004ZP2a0o8G000001Wft4',et4ae5__EmailAssetId__c='11874',et4ae5__EmailId__c='2925',et4ae5__EmailName__c='Email1Test',et4ae5__etTriggeredSendDefId__c='1bcd2df4-aef3-ed11-a5c0-5cba2c1a53e8',et4ae5__FromEmail__c='rahulallada@enabledanalytics.com',et4ae5__FromName__c='MC Connect-CRM',et4ae5__hasDelayedSends__c=false,et4ae5__Notify_Owner_On_Error__c=false,et4ae5__Notify_Running_User_On_Error__c=true,et4ae5__NumberofExistingUndeliverables__c=0,et4ae5__NumberofExistingUnsubscribes__c=0,et4ae5__NumberofHardBounces__c=0,et4ae5__NumberofSoftBounces__c=0,et4ae5__NumberofSubscribersForwardingEmail__c=0,et4ae5__NumberofTotalClicks__c=3,et4ae5__NumberofTotalOpens__c=1,et4ae5__NumberofUniqueClicks__c=1,et4ae5__NumberofUniqueOpens__c=1,et4ae5__NumberSent__c=1,et4ae5__NumberUnsubscribed__c=0,et4ae5__Object__c='CAMPAIGNMEMBER',et4ae5__RecipientsOptedIn__c=true,et4ae5__SendClassificationId__c='22b1bff8-8ea9-ed11-a5b6-5cba2c193328',et4ae5__SendClassificationName__c='DefaultTransactional',et4ae5__SenderProfileId__c='BB301DB7-B5F3-ED11-A5C0-5CBA2C1A53E8',et4ae5__Subject__c='Emailtest1',et4ae5__SubjectBlob__c='RW1haWx0ZXN0MQ==',et4ae5__Subscribed_For_Tracking__c=true,et4ae5__Subscriber_Field__c='contactid',et4ae5__TrackingOnly__c=false,et4ae5__Use_All_Subscribers_List__c=true,Name='Test Triggered send',OwnerId='0058G000003nBCaQAM',RecordTypeId=rtypes.Id, Campaign__c=campaignId,Activated_previously_on__c=system.now();*/
        listOfTriggerSend.add(eachAutomatedSend);
        if(doInsert==True){
            insert listOfTriggerSend;
        }
        return listOfTriggerSend;
        
    }
    public static List<et4ae5__Automated_Send__c>  triggerSendTestData(Boolean doInsert,id campaignId){
        List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
        //List<et4ae5__Business_Unit__c> listOfBusinessUnit = [Select id,Name from et4ae5__Business_Unit__c Where id IN: businessUnitList Limit 1];
        List<campaign> campaignLst =[SELECT id,Name FROM campaign WHERE id =:campaignId];
       // List<Email_Template__c> listOfemailTemplate = [Select id,Name,Email_Asset_Id__c,Email_Template_Id__c from Email_Template__c where Name='Manual timekeeping systems are widely Inaccurate' Limit 1  ];
        
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
        if(doInsert==True){
            insert listOfTriggerSend;
        }
        return listOfTriggerSend;
        
    }
    public static List<Contact> contactData(Boolean doInsert)
    {
        List<Contact> contactList = new List<Contact>();
        
        Account acc = new Account(Name='TestAccount');
        insert acc;

        Contact_Type__c eachContactType = new Contact_Type__c(Name = 'Director', Default_Days__c = 10);
        insert eachContactType;
        Contact contactEach = new Contact();
        contactEach.AccountId=acc.id;
        contactEach.Email='test@gmail.com';
        contactEach.LastName ='TestContact';
        contactEach.Contact_Type__c = eachContactType.Id;
        contactList.add(contactEach);
        if(doInsert==True){
            insert contactList;
        }
        return contactList;
        
    }
    Public static List<CampaignMember> campaignMemberTestData(Boolean doInsert,List<Campaign> campaignList,id contactId){
        List<CampaignMember> listOfCampaignMembersInserted = new List<CampaignMember>();
        
        for(Campaign campaignEach:campaignList){
            campaignEach.Campaign_Stage__c = 'Member Identification';
            CampaignMember campaignMemEach= new CampaignMember(CampaignId=campaignEach.id,ContactId=contactId,Status='Send');
            listOfCampaignMembersInserted.add(campaignMemEach);
        }
        Update campaignList;        
        
        if(doInsert==True){
            insert listOfCampaignMembersInserted;
        }
        return listOfCampaignMembersInserted;
    }
    Public static List<CampaignMember> campaignMemberTestData1(Boolean doInsert,List<Campaign> campaignList,id contactId){
        List<CampaignMember> listOfCampaignMembersInserted1 = new List<CampaignMember>();
        
        for(Campaign campaignEach:campaignList){
            campaignEach.Campaign_Stage__c = 'Member Identification';
            CampaignMember campaignMemEach= new CampaignMember(CampaignId=campaignEach.id,ContactId=contactId,Status='Activate');
            listOfCampaignMembersInserted1.add(campaignMemEach);
        }
        Update campaignList;        
        
        if(doInsert==True){
            insert listOfCampaignMembersInserted1;
        }
        return listOfCampaignMembersInserted1;
    }
    Public static List<Interaction_event_mapping__c> interactionEventMappingData(Boolean doInsert, id campaignId,List<Call_To_Action__c> callToActionList){
        List<Interaction_event_mapping__c> listOfInteractionEventMap = new List<Interaction_event_mapping__c>();
        Interaction_event_mapping__c interactionEventMappEach = new Interaction_event_mapping__c(Action_Name__c=callToActionList[0].Name,URL__c=callToActionList[0].CTA_URL__c,Campaign__c=campaignId,Email_Template__c=callToActionList[0].Email_Template__c,Weightage__c=100);
        Interaction_event_mapping__c interactionEventMappEach1 = new Interaction_event_mapping__c(Action_Name__c=callToActionList[0].Name,URL__c='www.yahoo.com',Campaign__c=campaignId,Email_Template__c=callToActionList[0].Email_Template__c,Weightage__c=100);
        
        listOfInteractionEventMap.add(interactionEventMappEach);
        listOfInteractionEventMap.add(interactionEventMappEach1);
        
        if(doInsert==True){
            insert listOfInteractionEventMap;
        }
        return listOfInteractionEventMap;
    }
    
   /* Public static List<Opportunity> opportunityTestData(Boolean doInsert,id campaignId,id campaignMemberId){
        List<Opportunity> listOfOpportunity = new List<Opportunity>();
        Opportunity oppEach = new Opportunity(CampaignId=campaignId,Name='TestOpp',StageName='Prospecting',CloseDate=System.today()+30,Campaign_Member_Id__c=campaignId,Opened__c=true,Interacted__c=true);
        listOfOpportunity.add(oppEach);
        if(doInsert==True){
            insert listOfOpportunity;
        }
        return listOfOpportunity;
        
    }
    Public static List<Opportunity> opportunityTestData1(Boolean doInsert,id campaignId,id campaignMemberId){
        List<Opportunity> listOfOpportunity = new List<Opportunity>();
        Opportunity oppEach = new Opportunity(CampaignId=campaignId,Name='TestOpp',StageName='Prospecting',CloseDate=System.today()+30,Campaign_Member_Id__c=campaignMemberId,Opened__c=true,Interacted__c=true);
        listOfOpportunity.add(oppEach);
        if(doInsert==True){
            insert listOfOpportunity;
        }
        return listOfOpportunity;
        
    } */
    
    public static List<et4ae5__IndividualEmailResult__c> individualemailResultsTestData(Boolean doInsert,id campaignId,id contactId,List<Email_Template__c> emailTemplateLst,id triggerSendId,string campaignMemId,id opportunityId){
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c  individualEmailResEach = new et4ae5__IndividualEmailResult__c(Campaign__c=campaignId,et4ae5__Contact__c=contactId,Email_Template__c=emailTemplateLst[0].id,et4ae5__TriggeredSendDefinition__c=triggerSendId,et4ae5__Email_Asset_ID__c=emailTemplateLst[0].Email_Asset_Id__c,et4ae5__CampaignMemberId__c=campaignMemId,Marked_by_Scheduling__c=true,Marked_For_Opportunity_Creation__c=false,et4ae5__Opened__c = True,Opportunity__c=opportunityId,et4ae5__NumberOfTotalClicks__c=1);
        listOfIndividualEmailRes.add(individualEmailResEach);
        if(doInsert==True){
            insert listOfIndividualEmailRes;
        }
        return listOfIndividualEmailRes;
        
    }
    
    public static List<et4ae5__IndividualEmailResult__c> individualemailResultsTestData1(Boolean doInsert,id campaignId,id contactId,List<Email_Template__c> emailTemplateLst,id triggerSendId,string campaignMemId){
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c  individualEmailResEach = new et4ae5__IndividualEmailResult__c(Campaign__c=campaignId,et4ae5__Contact__c=contactId,Email_Template__c=emailTemplateLst[0].id,Name='Test', et4ae5__TriggeredSendDefinition__c=triggerSendId,et4ae5__Email_Asset_ID__c=emailTemplateLst[0].Email_Asset_Id__c,et4ae5__CampaignMemberId__c=campaignMemId,Marked_by_Scheduling__c=true,et4ae5__Lead__c = Null,Marked_For_Opportunity_Creation__c=True,et4ae5__Opened__c = True,et4ae5__NumberOfTotalClicks__c=1);
        listOfIndividualEmailRes.add(individualEmailResEach);
        if(doInsert==True){
            insert listOfIndividualEmailRes;
        }
        return listOfIndividualEmailRes;
        
    }
    public static List<et4ae5__IndividualEmailResult__c> individualemailResultsTestData2(Boolean doInsert,id campaignId,id contactId,List<Email_Template__c> emailTemplateLst,id triggerSendId,id campaignMemId){
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c  individualEmailResEach = new et4ae5__IndividualEmailResult__c(Campaign__c=campaignId,et4ae5__Contact__c=contactId,Email_Template__c=emailTemplateLst[0].id, et4ae5__TriggeredSendDefinition__c=triggerSendId,et4ae5__Email_Asset_ID__c=emailTemplateLst[0].Email_Asset_Id__c,et4ae5__CampaignMemberId__c=campaignMemId,Marked_by_Scheduling__c=false,Marked_For_Opportunity_Creation__c=True,et4ae5__Opened__c = True,et4ae5__NumberOfTotalClicks__c=1);
        listOfIndividualEmailRes.add(individualEmailResEach);
        if(doInsert==True){
            insert listOfIndividualEmailRes;
        }
        return listOfIndividualEmailRes;
        
    }
    
    public static List<et4ae5__IndividualLink__c> individualLinkTestData(Boolean doInsert,id individualEmailResId,List<Call_To_Action__c> callToActionList){
        
        List<et4ae5__IndividualLink__c>  listOfIndividualLink = new  List<et4ae5__IndividualLink__c>();
        et4ae5__IndividualLink__c individualLinkEach = new et4ae5__IndividualLink__c(et4ae5__Individual_Email_Result__c=individualEmailResId,et4ae5__LinkURL__c=callToActionList[0].CTA_URL__c,et4ae5__Unique_Link_ID__c='abc123455iikll',et4ae5__NumberOfTotalClicks__c=1);
        listOfIndividualLink.add(individualLinkEach);
        if(doInsert==True){
            insert listOfIndividualLink;
        }
        return listOfIndividualLink;
        
    } 
    
    public static List<et4ae5__IndividualLink__c> individualLinkTestData1(Boolean doInsert,id individualEmailResId,List<Call_To_Action__c> callToActionList){
        
        List<et4ae5__IndividualLink__c>  listOfIndividualLink = new  List<et4ae5__IndividualLink__c>();
        et4ae5__IndividualLink__c individualLinkEach = new et4ae5__IndividualLink__c(et4ae5__Individual_Email_Result__c=individualEmailResId,
                                                                                     et4ae5__LinkURL__c=callToActionList[0].CTA_URL__c,
                                                                                     et4ae5__Unique_Link_ID__c='abc123455iikllm',
                                                                                     et4ae5__NumberOfTotalClicks__c=1,
                                                                                     No_Of_Clicks_Tracked__c=1);
                                                                                     
                                                                                     
                                                                                     
                                                                                  
        listOfIndividualLink.add(individualLinkEach);
        if(doInsert==True){
            insert listOfIndividualLink;
        }
        return listOfIndividualLink;
        
    }
    
	 
     public static List<et4ae5__IndividualLink__c> individualLinkTestData2(Boolean doInsert,id individualEmailResId,List<Call_To_Action__c> callToActionList,id opportunityId){
        
        List<et4ae5__IndividualLink__c>  listOfIndividualLink = new  List<et4ae5__IndividualLink__c>();
        et4ae5__IndividualLink__c individualLinkEach = new et4ae5__IndividualLink__c(et4ae5__Individual_Email_Result__c=individualEmailResId,et4ae5__LinkURL__c=callToActionList[0].CTA_URL__c,Opportunity__c=opportunityId,et4ae5__Unique_Link_ID__c='abc123455iikllm',et4ae5__NumberOfTotalClicks__c=1,No_Of_Clicks_Tracked__c=1);
        listOfIndividualLink.add(individualLinkEach);
        if(doInsert==True){
            insert listOfIndividualLink;
        }
        return listOfIndividualLink;
        
    }
    
    public static List<et4ae5__IndividualLink__c> individualLinkTestData3(Boolean doInsert,id individualEmailResId,List<Call_To_Action__c> callToActionList){
     List<et4ae5__IndividualLink__c>  listOfIndividualLink3 = new  List<et4ae5__IndividualLink__c>();
          et4ae5__IndividualLink__c individualLinkEach3 = new et4ae5__IndividualLink__c(et4ae5__Individual_Email_Result__c=individualEmailResId,
                                                                                     et4ae5__LinkURL__c=callToActionList[0].CTA_URL__c,
                                                                                     
                                                                                     et4ae5__Unique_Link_ID__c='abc123455iikllm',
                                                                                     et4ae5__NumberOfTotalClicks__c=1,
                                                                                     No_Of_Clicks_Tracked__c=1
                                                                                    
                                                                                       );
                                                                                    
                                                                                      
         listOfIndividualLink3.add(individualLinkEach3);
         if(doInsert==True){
            insert listOfIndividualLink3;
        }
        return listOfIndividualLink3;      
     }
    
    
    public static List<Survey_Responses__c> surveyResponseData(Boolean doInsert){
        
        Case caseEach = new Case( Status='New',Issue_with__c = 'Client', Type='	Staffing',Send_Survey_Email_Again__c = false, Survey_Last_sent_on__c = date.today());
        
        insert caseEach;
        
        List<Survey_Responses__c> surveyResponseList = new List<Survey_Responses__c>();
        Survey_Responses__c objSurveyResponse = new Survey_Responses__c();
        objSurveyResponse.Survey_Start_Time__c = system.now();
        objSurveyResponse.Survey_Completion_Time__c = system.now();
        objSurveyResponse.Case__c = caseEach.Id;
        surveyResponseList.add(objSurveyResponse);
        
        if(doInsert==True){
            insert surveyResponseList;
        }
        return surveyResponseList;
        
    }
    
    public static List<Survey_Feedback__c> surveyFeedbackData(Boolean doInsert){
        
        List<Survey_Feedback__c> surveyFeedbackList = new List<Survey_Feedback__c>();
        
        Survey_Feedback__c objSurveyFeedback = new Survey_Feedback__c();
        objSurveyFeedback.Name = 'Test Survey Feedback';
        objSurveyFeedback.How_long_have_you_been_a_client__c = '9';
        objSurveyFeedback.Survey_Completed_Date__c = system.today();
        objSurveyFeedback.FirstName__c = 'First Name';
        objSurveyFeedback.LastName__c = 'Last Name';
        objSurveyFeedback.Company_name__c = 'EA';
        surveyFeedbackList.add(objSurveyFeedback);
        
        if(doInsert==True){
            insert surveyFeedbackList;
        }
        return surveyFeedbackList;
    }
    
    //===============================================================For IndividualLinkLelDetaBatchHandlerTest class Data=================================================================================
    
    public static List<Campaign> campaignDataSet1(boolean doInsert){
        
        List<Campaign> listOfCampaign = new List<Campaign>();
        Campaign campaignEach = new Campaign(Name='Test Campaign',IsActive=true,Campaign_Stage__c='Creation',Create_Opportunity_On_Open__c=true ,Count_Weightage_For_Duplicate_Clicks__c=true);
        
        listOfCampaign.add(campaignEach);
        
        if(doInsert==True){
            insert listOfCampaign;
        }
        return listOfCampaign;
    }
    
    public static List<Campaign> campaignDataSet2(boolean doInsert){
        
        List<Campaign> listOfCampaign2 = new List<Campaign>();
        Campaign campaignEach2 = new Campaign(Name='Test Campaign1',IsActive=true,Campaign_Stage__c='Creation',Create_Opportunity_On_Open__c=true ,Count_Weightage_For_Duplicate_Clicks__c=false);
        
        listOfCampaign2.add(campaignEach2);
        
        if(doInsert==True){
            insert listOfCampaign2;
        }
        return listOfCampaign2;
    }
    
    public static List<et4ae5__Automated_Send__c> triggeredSendDataSet(boolean doInsert){
        
        List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
        List<Campaign> listOfCampaign = campaignDataSet1(true);
        
        Id inactiveRecordTypeId = Schema.SObjectType.et4ae5__Automated_Send__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
        
        et4ae5__Automated_Send__c triggerSendObj = new et4ae5__Automated_Send__c();
        triggerSendObj.Name = listOfCampaign[0].Name + ' ' + listOfCampaign[0].Id;
        triggerSendObj.et4ae5__Object__c = 'CAMPAIGNMEMBER';
        triggerSendObj.et4ae5__Contact_Lead_FIeld__c = 'Contact';
        triggerSendObj.Campaign__c = listOfCampaign[0].id;
        triggerSendObj.et4ae5__Data_Extension_Name__c ='TriggeredSDE';
        triggerSendObj.et4ae5__Hours_Delayed__c = 0;
        triggerSendObj.et4ae5__SendClassificationName__c = 'Default Transactional';
        triggerSendObj.et4ae5__SendClassificationId__c = '22b1bff8-8ea9-ed11-a5b6-5cba2c193328';
        triggerSendObj.et4ae5__Subscriber_Field__c='contactid';
        triggerSendObj.et4ae5__FromEmail__c = 'rahulallada@enabledanalytics.com';
        triggerSendObj.et4ae5__Active__c = false;
        triggerSendObj.RecordTypeId = inactiveRecordTypeId;
        triggerSendObj.et4ae5__Action__c = 'EitherSubsequently';
        
        listOfTriggerSend.add(triggerSendObj);
        
        if(doInsert==True){
            insert listOfTriggerSend;
        }
        return listOfTriggerSend;
    }
    
    public static List<Lead> leadDataSet(boolean doInsert){
        
        List<Lead> leadList = new List<Lead>();
        List<Contact> contactList = contactTestData2(true);
        List<Campaign> listOfCampaign = campaignDataSet1(true);
        
        Lead varLead = new Lead();
        varLead.FirstName = 'Test Lead';
        varLead.LastName = 'Testing';
        varLead.Status = 'Open';
        varLead.Company = 'SpaceX';
        varLead.Campaign__c = listOfCampaign[0].id;
        varLead.Contact__c = contactList[0].Id;
        varLead.Weightage_Score__c = 10;
        varLead.Interacted__c = false;
        leadList.add(varLead);
        
        if(doInsert==True){
            insert leadList;
        }
        return leadList;
    }
    
    public static List<et4ae5__IndividualEmailResult__c> induvidualEmailResultDataSet1(boolean doInsert){
        
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes1 = new List<et4ae5__IndividualEmailResult__c>();
		List<Lead> leadList = leadDataSet(true);
        List<Contact> contactList = contactTestData2(true);
        List<Campaign> listOfCampaign = campaignDataSet1(true); 
        List<et4ae5__Automated_Send__c> listOfTriggerSend = triggeredSendDataSet(true);
        
        et4ae5__IndividualEmailResult__c  individualEmailResEach = new et4ae5__IndividualEmailResult__c();
        individualEmailResEach.Campaign__c=listOfCampaign[0].Id;
        individualEmailResEach.Name = 'Test';
        individualEmailResEach.et4ae5__Contact__c=contactList[0].Id;
        //individualEmailResEach.Email_Template__c=emailTempList[0].Id;
        individualEmailResEach.et4ae5__TriggeredSendDefinition__c=listOfTriggerSend[0].Id;
        //individualEmailResEach.et4ae5__Email_Asset_ID__c=emailTempList[0].Email_Asset_Id__c;
        individualEmailResEach.et4ae5__CampaignMemberId__c=listOfCampaign[0].Id;
        individualEmailResEach.Marked_by_Scheduling__c=true;
        individualEmailResEach.Marked_For_Opportunity_Creation__c=false;
        individualEmailResEach.et4ae5__Opened__c = True;
        individualEmailResEach.Errored__c = false;
        //individualEmailResEach.et4ae5__NumberOfTotalClicks__c=1;
        individualEmailResEach.et4ae5__Lead__c = leadList[0].Id;
        
        listOfIndividualEmailRes1.add(individualEmailResEach);
        
        if(doInsert==True){
            insert listOfIndividualEmailRes1;
        }
        return listOfIndividualEmailRes1;
    }
    
    public static List<et4ae5__IndividualEmailResult__c> induvidualEmailResultDataSet2(boolean doInsert){
        
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes2 = new List<et4ae5__IndividualEmailResult__c>();
		List<Lead> leadList = leadDataSet(true);
        List<Contact> contactList = contactTestData2(true);
        List<Campaign> listOfCampaign = campaignDataSet2(true); 
        List<et4ae5__Automated_Send__c> listOfTriggerSend = triggeredSendDataSet(true);
        
        et4ae5__IndividualEmailResult__c  individualEmailResEach = new et4ae5__IndividualEmailResult__c();
        individualEmailResEach.Campaign__c=listOfCampaign[0].Id;
        individualEmailResEach.Name = 'Test';
        individualEmailResEach.et4ae5__Contact__c=contactList[0].Id;
        //individualEmailResEach.Email_Template__c=emailTempList[0].Id;
        individualEmailResEach.et4ae5__TriggeredSendDefinition__c=listOfTriggerSend[0].Id;
        //individualEmailResEach.et4ae5__Email_Asset_ID__c=emailTempList[0].Email_Asset_Id__c;
        individualEmailResEach.et4ae5__CampaignMemberId__c=listOfCampaign[0].Id;
        individualEmailResEach.Marked_by_Scheduling__c=true;
        individualEmailResEach.Marked_For_Opportunity_Creation__c=false;
        individualEmailResEach.et4ae5__Opened__c = True;
        individualEmailResEach.Errored__c = false;
        //individualEmailResEach.et4ae5__NumberOfTotalClicks__c=1;
        individualEmailResEach.et4ae5__Lead__c = leadList[0].Id;
        
        listOfIndividualEmailRes2.add(individualEmailResEach);
        
        if(doInsert==True){
            insert listOfIndividualEmailRes2;
        }
        return listOfIndividualEmailRes2;
    }
    
    public static List<Interaction_event_mapping__c> interactionEventMappingDataSet1(boolean doInsert){
        
		List<Interaction_event_mapping__c> iemList = new List<Interaction_event_mapping__c>();
        List<Campaign> listOfCampaign = campaignDataSet1(true);
        List<Email_Template__c> emailTempList = emailTemplateData(true);
        
        Interaction_event_mapping__c iemVar = NEW  Interaction_event_mapping__c();
        //iemVar.Name = 'IEM-1234';
        iemVar.Campaign__c = listOfCampaign[0].Id;
        iemVar.Email_Template__c = emailTempList[0].Id;
        iemVar.Weightage__c = 9;
        iemVar.URL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        iemList.add(iemVar);      
        
        if(doInsert==True){
            insert iemList;
        }
        return iemList;
    }
    
    public static List<Interaction_event_mapping__c> interactionEventMappingDataSet2(boolean doInsert){
        
		List<Interaction_event_mapping__c> iemList = new List<Interaction_event_mapping__c>();
        List<Campaign> listOfCampaign = campaignDataSet1(true);
        List<Email_Template__c> emailTempList = emailTemplateData1(true);
        
        Interaction_event_mapping__c iemVar1 = NEW  Interaction_event_mapping__c();
        //iemVar.Name = 'IEM-1234';
        iemVar1.Campaign__c = listOfCampaign[0].Id;
        iemVar1.Email_Template__c = emailTempList[0].Id;
        iemVar1.Weightage__c = 5;
        iemVar1.URL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        iemList.add(iemVar1);      
        
        if(doInsert==True){
            insert iemList;
        }
        return iemList;
    }
    
    public static List<Interaction_event_mapping__c> interactionEventMappingDataSet3(boolean doInsert){
        
		List<Interaction_event_mapping__c> iemList = new List<Interaction_event_mapping__c>();
        List<Campaign> listOfCampaign = campaignDataSet1(true);
        List<Email_Template__c> emailTempList = emailTemplateData(true);
        
        Interaction_event_mapping__c iemVar2 = NEW  Interaction_event_mapping__c();
        //iemVar.Name = 'IEM-1234';
        iemVar2.Campaign__c = listOfCampaign[0].Id;
        iemVar2.Email_Template__c = emailTempList[0].Id;
        iemVar2.Weightage__c = 8;
        iemVar2.URL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        iemList.add(iemVar2);      
        
        if(doInsert==True){
            insert iemList;
        }
        return iemList;
    }
    
    public static List<et4ae5__IndividualLink__c> individualLinkDataSet1(boolean doInsert){
        
        List<et4ae5__IndividualLink__c> individualList = new List<et4ae5__IndividualLink__c>();
        List<Lead> leadList = leadDataSet(true);
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes = induvidualEmailResultDataSet1(true);
        
        et4ae5__IndividualLink__c indVar = new et4ae5__IndividualLink__c();
        indVar.Name = 'Test Link';
        indVar.No_Of_Clicks_Tracked__c = 9;
        indVar.et4ae5__NumberOfTotalClicks__c = 7;
        indVar.et4ae5__Individual_Email_Result__c= listOfIndividualEmailRes[0].Id;
        indVar.Lead__c= leadList[0].Id;
        indVar.et4ae5__LinkURL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        //indVar.No_Of_Clicks_Tracked__c = 1;
        indVar.et4ae5__Unique_Link_ID__c = '00D8G000000LFzsa0p8G000004dab4211637';
        individualList.add(indVar);
        
        if(doInsert==True){
            insert individualList;
        }
        return individualList;
    }
    
    public static List<et4ae5__IndividualLink__c> individualLinkDataSet2(boolean doInsert){
        
        List<et4ae5__IndividualLink__c> individualList1 = new List<et4ae5__IndividualLink__c>();
        List<Lead> leadList = leadDataSet(true);
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes = induvidualEmailResultDataSet2(true);
        
        et4ae5__IndividualLink__c indVar = new et4ae5__IndividualLink__c();
        indVar.Name = 'Test Link1';
        indVar.No_Of_Clicks_Tracked__c = 0;
        indVar.et4ae5__NumberOfTotalClicks__c = 7;
        indVar.et4ae5__Individual_Email_Result__c= listOfIndividualEmailRes[0].Id;
        indVar.Lead__c= leadList[0].Id;
        indVar.et4ae5__LinkURL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        //indVar.No_Of_Clicks_Tracked__c = 1;
        indVar.et4ae5__Unique_Link_ID__c = '00D8G000000LFzsa0p8G000004dab4211637';
        individualList1.add(indVar);
        
        if(doInsert==True){
            insert individualList1;
        }
        return individualList1;
    }
    
    //============================================================For IndividualLinkLelDetaBatchHandlerTest class all data in singlr method====================================================================
    public static List<et4ae5__IndividualLink__c> getDataOfIndividualLink(boolean doInsert){
        
        //Contact-------------------------------------------------------------------------
        List<Contact> contactList = TestDataFactory.contactTestData2(true);
        // insert contactList;
        
        //Campaign---------------------------------------------------------------------------
        //List<Campaign> campaignList =  TestDataFactory.campaignTestData1(false);
        List<Campaign> listOfCampaign = new List<Campaign>();
        Campaign campaignEach = new Campaign(Name='Test Campaign',IsActive=true,Campaign_Stage__c='Creation',Create_Opportunity_On_Open__c=true ,Count_Weightage_For_Duplicate_Clicks__c=true);
        Campaign campaignEach1 = new Campaign(Name='Test Campaign1',IsActive=true,Campaign_Stage__c='Creation',Create_Opportunity_On_Open__c=true ,Count_Weightage_For_Duplicate_Clicks__c=false);
        //campaignEach.
        listOfCampaign.add(campaignEach);
        listOfCampaign.add(campaignEach1);
        insert listOfCampaign;
        
        //Campaign Member---------------------------------------------------------------------------
        /*List<CampaignMember> campMembersList = new List<CampaignMember>();
        CampaignMember camMemVar = new CampaignMember();
        camMemVar.CampaignId = listOfCampaign[0].id;
        camMemVar.ContactId = contactList[0].Id;
        camMemVar.Status__c = 'Member Identification';
        campMembersList.add(camMemVar);
        
        insert campMembersList;*/
        
        //Email Template-------------------------------------------------------------------------
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template__c> emailTempList1 = TestDataFactory.emailTemplateData1(true);
        List<Email_Template__c> emailTempList2 = TestDataFactory.emailTemplateData2(true);
        //insert emailTempList;
        
        //Triggered Send------------------------------------------------------------------------------
        //List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(false,campaignList[0].id);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = new List<et4ae5__Automated_Send__c>();
        
        Id inactiveRecordTypeId = Schema.SObjectType.et4ae5__Automated_Send__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
        
        et4ae5__Automated_Send__c triggerSendObj = new et4ae5__Automated_Send__c();
        triggerSendObj.Name = listOfCampaign[0].Name + ' ' + listOfCampaign[0].Id;
        triggerSendObj.et4ae5__Object__c = 'CAMPAIGNMEMBER';
        triggerSendObj.et4ae5__Contact_Lead_FIeld__c = 'Contact';
        triggerSendObj.Campaign__c = listOfCampaign[0].id;
        triggerSendObj.et4ae5__Data_Extension_Name__c ='TriggeredSDE';
        triggerSendObj.et4ae5__Hours_Delayed__c = 0;
        triggerSendObj.et4ae5__SendClassificationName__c = 'Default Transactional';
        triggerSendObj.et4ae5__SendClassificationId__c = '22b1bff8-8ea9-ed11-a5b6-5cba2c193328';
        triggerSendObj.et4ae5__Subscriber_Field__c='contactid';
        triggerSendObj.et4ae5__FromEmail__c = 'rahulallada@enabledanalytics.com';
        triggerSendObj.et4ae5__Active__c = false;
        triggerSendObj.RecordTypeId = inactiveRecordTypeId;
        triggerSendObj.et4ae5__Action__c = 'EitherSubsequently';
        
        listOfTriggerSend.add(triggerSendObj);
        
        insert listOfTriggerSend;
        
        //Lead 
        List<Lead> leadList = new List<Lead>();
        
        Lead varLead = new Lead();
        varLead.FirstName = 'Test Lead';
        varLead.LastName = 'Testing';
        varLead.Status = 'Open';
        varLead.Company = 'SpaceX';
        varLead.Campaign__c = listOfCampaign[0].id;
        varLead.Contact__c = contactList[0].Id;
        varLead.Weightage_Score__c = 10;
        varLead.Interacted__c = false;
        leadList.add(varLead);
        
        insert leadList;
        
        //Individual Email Result
        List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c  individualEmailResEach = new et4ae5__IndividualEmailResult__c();
        individualEmailResEach.Campaign__c=listOfCampaign[0].Id;
        individualEmailResEach.Name = 'Test';
        individualEmailResEach.et4ae5__Contact__c=contactList[0].Id;
        //individualEmailResEach.Email_Template__c=emailTempList[0].Id;
        individualEmailResEach.et4ae5__TriggeredSendDefinition__c=listOfTriggerSend[0].Id;
        //individualEmailResEach.et4ae5__Email_Asset_ID__c=emailTempList[0].Email_Asset_Id__c;
        individualEmailResEach.et4ae5__CampaignMemberId__c=listOfCampaign[0].Id;
        individualEmailResEach.Marked_by_Scheduling__c=true;
        individualEmailResEach.Marked_For_Opportunity_Creation__c=false;
        individualEmailResEach.et4ae5__Opened__c = True;
        individualEmailResEach.Errored__c = false;
        //individualEmailResEach.et4ae5__NumberOfTotalClicks__c=1;
        individualEmailResEach.et4ae5__Lead__c = leadList[0].Id;
        
        listOfIndividualEmailRes.add(individualEmailResEach);
        
       // List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailRes2 = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c  individualEmailResEach2 = new et4ae5__IndividualEmailResult__c();
        individualEmailResEach2.Campaign__c=listOfCampaign[0].Id;
        individualEmailResEach2.Name = 'Test1';
        individualEmailResEach2.et4ae5__Contact__c=contactList[0].Id;
        //individualEmailResEach.Email_Template__c=emailTempList[0].Id;
        individualEmailResEach2.et4ae5__TriggeredSendDefinition__c=listOfTriggerSend[0].Id;
        //individualEmailResEach.et4ae5__Email_Asset_ID__c=emailTempList[0].Email_Asset_Id__c;
        individualEmailResEach2.et4ae5__CampaignMemberId__c=listOfCampaign[1].Id;
        individualEmailResEach2.Marked_by_Scheduling__c=true;
        individualEmailResEach2.Marked_For_Opportunity_Creation__c=false;
        individualEmailResEach2.et4ae5__Opened__c = True;
        individualEmailResEach2.Errored__c = false;
        //individualEmailResEach.et4ae5__NumberOfTotalClicks__c=1;
        individualEmailResEach2.et4ae5__Lead__c = leadList[0].Id;
        
        listOfIndividualEmailRes.add(individualEmailResEach2);
        
        
        insert listOfIndividualEmailRes;    
        
        //Individual Link
        List<et4ae5__IndividualLink__c> individualList = new List<et4ae5__IndividualLink__c>();
        
        et4ae5__IndividualLink__c indVar = new et4ae5__IndividualLink__c();
        indVar.Name = 'Test Link';
        indVar.No_Of_Clicks_Tracked__c = 9;
        indVar.et4ae5__NumberOfTotalClicks__c = 7;
        indVar.et4ae5__Individual_Email_Result__c= listOfIndividualEmailRes[0].Id;
        indVar.Lead__c= leadList[0].Id;
        indVar.et4ae5__LinkURL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        //indVar.No_Of_Clicks_Tracked__c = 1;
        indVar.et4ae5__Unique_Link_ID__c = '00D8G000000LFzsa0p8G000004dab4211637';
        individualList.add(indVar);
        
        et4ae5__IndividualLink__c indVar1 = new et4ae5__IndividualLink__c();
        indVar1.Name = 'Test Link1';
        indVar1.No_Of_Clicks_Tracked__c = 0;
        indVar1.et4ae5__NumberOfTotalClicks__c = 7;
        indVar1.et4ae5__Individual_Email_Result__c= listOfIndividualEmailRes[1].Id;
        indVar1.Lead__c= leadList[0].Id;
        indVar1.et4ae5__LinkURL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        //indVar.No_Of_Clicks_Tracked__c = 1;
        indVar1.et4ae5__Unique_Link_ID__c = '00D8G000000LFzsa0p8G000004dab42116378';
        individualList.add(indVar1);
        
        //insert individualList;
        //System.debug('individualList=>'+individualList);
        
        //Interaction Event Mapping Insert
        List<Interaction_event_mapping__c> iemList = NEW List<Interaction_event_mapping__c>();
        Interaction_event_mapping__c iemVar = NEW  Interaction_event_mapping__c();
        //iemVar.Name = 'IEM-1234';
        iemVar.Campaign__c = listOfCampaign[0].Id;
        iemVar.Email_Template__c = emailTempList[0].Id;
        iemVar.Weightage__c = 9;
        iemVar.URL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        iemList.add(iemVar);
        
        Interaction_event_mapping__c iemVar1 = NEW  Interaction_event_mapping__c();
        //iemVar.Name = 'IEM-1234';
        iemVar1.Campaign__c = listOfCampaign[0].Id;
        iemVar1.Email_Template__c = emailTempList1[0].Id;
        iemVar1.Weightage__c = 5;
        iemVar1.URL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        iemList.add(iemVar1);
        
        Interaction_event_mapping__c iemVar2 = NEW  Interaction_event_mapping__c();
        //iemVar.Name = 'IEM-1234';
        iemVar2.Campaign__c = listOfCampaign[0].Id;
        iemVar2.Email_Template__c = emailTempList[0].Id;
        iemVar2.Weightage__c = 8;
        iemVar2.URL__c = 'https://outlook.office365.com/owa/calendar/TrionNewClient@trionworks.com/bookings/s/nnK0Wigub0O5Ck-lMm8D5g2';
        iemList.add(iemVar2);
        
        insert iemList;
        // Test.startTest();
        
        //Lead Update
        Lead varLead2 = new Lead();
        varLead2.Id = varLead.Id;
        varLead2.Weightage_Score__c = 20;
        varLead2.Interacted__c = true;
        
        update varLead2;
        
        //Individual Email Result Update
        et4ae5__IndividualEmailResult__c  varIER = new et4ae5__IndividualEmailResult__c();
        varIER.Id = listOfIndividualEmailRes[0].Id;
        varIER.Errored__c = true;
        
        update varIER;
        
        //Interaction Event Mapping update
        /*Interaction_event_mapping__c iemVar1 = NEW  Interaction_event_mapping__c();
        iemVar1.Id = iemList[0].Id;
        iemVar1.Weightage__c = 12;
        update iemVar;*/
        
        if(doInsert==True){
            insert individualList;
        }
        return individualList;
    }
    
}