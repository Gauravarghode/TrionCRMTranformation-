@isTest
public class PricingOverrideEmailService_Test {

    @isTest
    public static void myUnitTest(){
        Pricing_Matrix__c pm = new Pricing_Matrix__c();
        pm.Stage__c = 'Quoting';
        pm.Status__c = 'Active';
        insert pm;
        
        Pricing_Condition__c oPricing_Condition = new Pricing_Condition__c();
        oPricing_Condition.Pricing_Matrix__c = pm.Id;
        oPricing_Condition.Object__c = 'Account';
        oPricing_Condition.Field__c = 'Name';
        oPricing_Condition.Data_Type__c = 'String';
        oPricing_Condition.Rule_Criteria__c = 'EQUALS';
        oPricing_Condition.Value__c = '10';
        insert oPricing_Condition;
        
        Year__c oYear = new Year__c();
        oYear.Name = '2021';
        oYear.Status__c = 'Active';
        oYear.End_Date__c = date.today().addDays(10);
        oYear.FICA__c = 6.20;
        oYear.FUTA__c = 0.60;
        oYear.Medicare__c = 1.45;
        oYear.Start_Date__c = date.today();
        oYear.Year_Code__c = '2021';
        insert oYear;
        
        State__c oState = new State__c();
        oState.Name = 'California';
        oState.State_Code__c = 'CA';
        insert oState;
        
        Account oAccount = new Account(); 
        oAccount.Name = 'testAccount'; 
        oAccount.Type = 'WC Carrier';
        insert oAccount;
        
        Opportunity oOpportunity = new Opportunity();
        oOpportunity.AccountId = oAccount.Id;
        oOpportunity.Name = 'Test';
        oOpportunity.CloseDate = date.today().addDays(100);
        oOpportunity.StageName = 'Prospecting';
        insert oOpportunity;
        
        Proposal__c oProposal = new Proposal__c();
        oProposal.Opportunity__c = oOpportunity.Id;
        oProposal.Year__c = oYear.Id;
        oProposal.Stage__c = 'Quoting';
        insert oProposal;
        
        Approval_Request__c ar = new Approval_Request__c();
                ar.Approval_Request__c = 'Pricing Override';
                ar.Opportunity__c = oOpportunity.Id;
                ar.Proposal__c = oProposal.Id;
                ar.Submitted_By__c = 'Test';
                ar.Submitted_By_User__c = UserInfo.getUserId();
                ar.Submitted_On__c = system.now(); 
                ar.Submitter_Notes__c = 'test';
        insert ar;        
                
        // setup controller object
        PricingOverrideEmailService objconfirm = new PricingOverrideEmailService();
          
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
          
        email.subject = '<~' + ar.Id + '~>';
        email.htmlBody = 'Approved';
        envelope.fromAddress = 'test@test.com';
         
        objconfirm.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
         
    }
    
    @isTest
    public static void myUnitTest2(){
        Pricing_Matrix__c pm = new Pricing_Matrix__c();
        pm.Stage__c = 'Quoting';
        pm.Status__c = 'Active';
        insert pm;
        
        Pricing_Condition__c oPricing_Condition = new Pricing_Condition__c();
        oPricing_Condition.Pricing_Matrix__c = pm.Id;
        oPricing_Condition.Object__c = 'Account';
        oPricing_Condition.Field__c = 'Name';
        oPricing_Condition.Data_Type__c = 'String';
        oPricing_Condition.Rule_Criteria__c = 'EQUALS';
        oPricing_Condition.Value__c = '10';
        insert oPricing_Condition;
        
        Year__c oYear = new Year__c();
        oYear.Name = '2021';
        oYear.Status__c = 'Active';
        oYear.End_Date__c = date.today().addDays(10);
        oYear.FICA__c = 6.20;
        oYear.FUTA__c = 0.60;
        oYear.Medicare__c = 1.45;
        oYear.Start_Date__c = date.today();
        oYear.Year_Code__c = '2021';
        insert oYear;
        
        State__c oState = new State__c();
        oState.Name = 'California';
        oState.State_Code__c = 'CA';
        insert oState;
        
        Account oAccount = new Account(); 
        oAccount.Name = 'testAccount'; 
        oAccount.Type = 'WC Carrier';
        insert oAccount;
        
        Opportunity oOpportunity = new Opportunity();
        oOpportunity.AccountId = oAccount.Id;
        oOpportunity.Name = 'Test';
        oOpportunity.CloseDate = date.today().addDays(100);
        oOpportunity.StageName = 'Prospecting';
        insert oOpportunity;
        
        Proposal__c oProposal = new Proposal__c();
        oProposal.Opportunity__c = oOpportunity.Id;
        oProposal.Year__c = oYear.Id;
        oProposal.Stage__c = 'Quoting';
        insert oProposal;
        
        Approval_Request__c ar = new Approval_Request__c();
                ar.Approval_Request__c = 'Pricing Override';
                ar.Opportunity__c = oOpportunity.Id;
                ar.Proposal__c = oProposal.Id;
                ar.Submitted_By__c = 'Test';
                ar.Submitted_By_User__c = UserInfo.getUserId();
                ar.Submitted_On__c = system.now(); 
                ar.Submitter_Notes__c = 'test';
        insert ar;  
        
        // setup controller object
        PricingOverrideEmailService objconfirm = new PricingOverrideEmailService();
          
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
          
        email.subject = '<~' + ar.Id + '~>';
        email.htmlBody = 'Rejected';
        envelope.fromAddress = 'test@test.com';
         
        objconfirm.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
         
    }
      
}