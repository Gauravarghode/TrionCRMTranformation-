@isTest
public class WCRateTriggerHandlerTest {
    static testmethod void testupdateWCRateFromSUTAQuote(){
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
        
        State_Comp_Code__c scc= new State_Comp_Code__c();
        scc.State__c =  oState.Id;
        scc.WC_Code__c = oWCCode.Id;
        insert scc;
        
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
        //oQuote.Name = 'Test';
        oQuote.Proposal__c = oProposal.Id;
        oQuote.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuote;
        
        Zip_Code__c oZip_Code = new Zip_Code__c();
        oZip_Code.State__c = oState.Id;
        oZip_Code.Code__c = '8';
        insert oZip_Code;
        
        Client_Location__c oClientLocation = new Client_Location__c();
        oClientLocation.Proposal__c = oProposal.Id;
        oClientLocation.SUTA_Quote__c = oQuote.Id;
        oClientLocation.Client__c = oAccount.Id;
        oClientLocation.Postal_Code__c = oZip_Code.Id;
        insert oClientLocation;
        
        Territory__c oTerritory = new Territory__c();
        oTerritory.Carrier__c = oAccount.Id;
        oTerritory.Code__c = 7;
        insert oTerritory;
        
        Territory_Assignment__c oTerritory_Assignment = new Territory_Assignment__c();
        oTerritory_Assignment.Territory__c = oTerritory.Id;
        oTerritory_Assignment.Zip_Code__c = oZip_Code.Id;
        oTerritory_Assignment.Status__c = 'Active';
        insert oTerritory_Assignment;
        
        Carrier_WC_Rate__c oCarrier_WC_Rate = new Carrier_WC_Rate__c();
        oCarrier_WC_Rate.Policy__c = oPolicy.Id;
        oCarrier_WC_Rate.Territory__c = oTerritory.Id;
        oCarrier_WC_Rate.State__c = oState.Id;
        oCarrier_WC_Rate.WC_Code__c = oWCCode.Id;
        oCarrier_WC_Rate.Carrier__c = oAccount.Id;
        insert oCarrier_WC_Rate;
        
        WC_Rate__c oWCRate = new WC_Rate__c();
        oWCRate.SUTA_Quote__c = oQuote.Id;
        oWCRate.Policy__c = oPolicy2.Id;
        oWCRate.Client_Location__c = oClientLocation.Id;
        oWCRate.Proposal__c = oProposal.Id;
        insert oWCRate;
        
        WCRateTriggerHandler.runOnce = true;

        update oWCRate;
    }
    
    
}