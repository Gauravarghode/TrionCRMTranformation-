@isTest
public class ProposalPricingMatrix_Test {

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
        
        PageReference pageRef = Page.ProposalPricingMatrix;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oProposal); 
        ProposalPricingMatrix ctr = new ProposalPricingMatrix(sc);
        
        PageReference pr = ctr.doProcess(); 
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
        
        try{
        PageReference pageRef = Page.ProposalPricingMatrix;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oProposal); 
        ProposalPricingMatrix ctr = new ProposalPricingMatrix(sc);
        
        PageReference pr = ctr.doProcess(); 
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
     
}