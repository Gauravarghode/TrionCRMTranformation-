@isTest
public class SUTAQuoteTriggerHandler_Test {

    static testmethod void testHandleWCRateUpdate(){
        
        Account oAccount = new Account(); 
        oAccount.Name = 'testAccount'; 
        oAccount.Type = 'WC Carrier';
        insert oAccount;

        WC_Code__c oWCCode = new WC_Code__c();
        oWCCode.Name = '0005';
        oWCCode.Code__c = '0005';
        insert oWCCode;
        
        State__c oState = new State__c();
        oState.Name = 'California';
        oState.State_Code__c = 'CA';
        insert oState;
        
        Year__c oYear = new Year__c();
        oYear.End_Date__c = date.today().addDays(10);
        oYear.FICA__c = 6.20;
        oYear.FUTA__c = 0.60;
        oYear.Medicare__c = 1.45;
        oYear.Start_Date__c = date.today();
        oYear.Name = '2018';
        oYear.Year_Code__c = '2018';
        insert oYear;
        
        Policy_Year__c oPolicyYear = new Policy_Year__c();
        oPolicyYear.Account__c = oAccount.Id;
        oPolicyYear.Policy_Start_Date__c = date.today();
        oPolicyYear.Policy_End_Date__c = date.today().addDays(1);
        oPolicyYear.Year__c = oYear.Id;
        insert oPolicyYear;
            
        Policy__c oPolicy = new Policy__c();
        oPolicy.Carrier__c = oAccount.Id;
        oPolicy.Policy_Year__c = oPolicyYear.Id;
        insert oPolicy;
        
        Policy__c oPolicy2 = new Policy__c();
        oPolicy2.Carrier__c = oAccount.Id;
        oPolicy2.Policy_Year__c = oPolicyYear.Id;
        insert oPolicy2;
        
        Carrier_WC_Rate__c oCarrierWCRate = new Carrier_WC_Rate__c();
        oCarrierWCRate.Policy__c = oPolicy2.Id;
        oCarrierWCRate.WC_Code__c = oWCCode.Id;
        oCarrierWCRate.State__c = oState.Id;
        oCarrierWCRate.Carrier__c = oAccount.Id;
        insert oCarrierWCRate;
        
        Opportunity oOpportunity = new Opportunity();
        oOpportunity.AccountId = oAccount.Id;
        oOpportunity.Name = 'Test';
        oOpportunity.CloseDate = date.today().addDays(100);
        oOpportunity.StageName = 'Prospecting';
        insert oOpportunity;
        
        Proposal__c oProposal = new Proposal__c();
        oProposal.Opportunity__c = oOpportunity.Id;
        insert oProposal;
            
        SUTA_Quote__c oQuote = new SUTA_Quote__c();
        oQuote.Policy__c = oPolicy.Id;
        oQuote.State__c = oState.Id;
        oQuote.Year__c = oYear.Id;
        //oQuote.Name = 'Test';
        oQuote.Proposal__c = oProposal.Id;
        oQuote.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuote;
                
        WC_Rate__c oWCRate = new WC_Rate__c();
        oWCRate.SUTA_Quote__c = oQuote.Id;
        oWCRate.Policy__c = oPolicy2.Id;
        oWCRate.Proposal__c = oProposal.Id;
        insert oWCRate;
        
        SUTAQuoteTriggerHandler.firstRun = true;
            
        oQuote.Policy__c = oPolicy2.Id;
        oQuote.State_Assessment_Fee_Surcharge_Included__c = true;
        update oQuote;
        
        //system.assertEquals(oQuote.Policy__c, oWCRate.Policy__c);
        //system.assertEquals(oQuote.Carrier__c, oWCRate.Carrier__c);
        //system.assertEquals(true, [SELECT Carrier_WC_Rate__c FROM WC_Rate__c limit 1].Carrier_WC_Rate__c != null);
    }
}