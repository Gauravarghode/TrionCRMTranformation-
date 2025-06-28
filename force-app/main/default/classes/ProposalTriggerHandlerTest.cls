@isTest
public class ProposalTriggerHandlerTest {

    @testSetup
    static void createData(){
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
            
        SUTA_Quote__c oQuote = new SUTA_Quote__c();
        oQuote.Policy__c = oPolicy.Id;
        oQuote.State__c = oState.Id; 
        oQuote.Proposal__c = oProposal.Id;
        oQuote.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuote;
        
        SUTA__c oSUTA = new SUTA__c();
        oSUTA.Name = 'Test SUTA';
        oSUTA.State__c = oState.Id;
        oSUTA.Year__c = oYear.Id;
        oSUTA.Status__c = 'Active';
        oSUTA.Reporting_Level__c = 'Client';
        insert oSUTA;
    }
    
    static testMethod void unitTestForProposalTriggerHandler(){
        test.startTest();
        
        List<Proposal__c> lstProposal = [SELECT ID, Year__c FROM Proposal__c ];
        Year__c oYear = new Year__c();
        oYear.Name = '2020';
        oYear.Status__c = 'Active';
        oYear.End_Date__c = date.today().addDays(20);
        oYear.FICA__c = 6.20;
        oYear.FUTA__c = 0.60;
        oYear.Medicare__c = 1.45;
        oYear.Start_Date__c = date.today();
        oYear.Year_Code__c = '2020';
        insert oYear;
        
        State__c oState = [SELECT ID FROM State__c];
        
        SUTA__c oSUTA = new SUTA__c();
        oSUTA.Name = 'Test SUTA';
        oSUTA.State__c = oState.Id;
        oSUTA.Year__c = oYear.Id;
        oSUTA.Status__c = 'Active';
        oSUTA.Reporting_Level__c = 'Client';
        insert oSUTA;
        
        for(Proposal__c oProposal : lstProposal){
            oProposal.Year__c = oYear.Id;
        }
             
        update lstProposal;
        
        test.stopTest();
    }
    
    static testMethod void unitTestForProposalTriggerHandler2(){
        test.startTest();
        
        List<Proposal__c> lstProposal = [SELECT ID, Year__c FROM Proposal__c ];
        Year__c oYear = new Year__c();
        oYear.Name = '2020';
        oYear.Status__c = 'Active';
        oYear.End_Date__c = date.today().addDays(20);
        oYear.FICA__c = 6.20;
        oYear.FUTA__c = 0.60;
        oYear.Medicare__c = 1.45;
        oYear.Start_Date__c = date.today();
        oYear.Year_Code__c = '2020';
        insert oYear;
        
        Pricing_Matrix__c pm = new Pricing_Matrix__c();
        pm.Stage__c = 'Quoting';
        pm.Status__c = 'Active';
        insert pm;
        
        List<Opportunity> lstOpp = [SELECT ID FROM Opportunity  ];
        
        Proposal__c oProposal1 = new Proposal__c();
        oProposal1.Opportunity__c = lstOpp.get(0).Id;
        oProposal1.Year__c = oYear.Id;
        oProposal1.Stage__c = 'Quoting';
        insert oProposal1;
         
        State__c oState = [SELECT ID FROM State__c];
        
        SUTA__c oSUTA = new SUTA__c();
        oSUTA.Name = 'Test SUTA';
        oSUTA.State__c = oState.Id;
        oSUTA.Year__c = oYear.Id;
        oSUTA.Status__c = 'Active';
        oSUTA.Reporting_Level__c = 'Client';
        insert oSUTA;
        
        for(Proposal__c oProposal : lstProposal){
            oProposal.Year__c = oYear.Id;
        }
             
        update lstProposal;
        
        test.stopTest();
    }
}