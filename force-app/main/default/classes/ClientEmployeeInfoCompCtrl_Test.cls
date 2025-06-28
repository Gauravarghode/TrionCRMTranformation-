@isTest
public class ClientEmployeeInfoCompCtrl_Test {

    @isTest
    public static void myUnitTest(){
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
        
        Account oAccount = new Account(); 
        oAccount.Name = 'testAccount'; 
        oAccount.Type = 'WC Carrier';
        insert oAccount;
        
        State__c oState = new State__c();
        oState.Name = 'California';
        oState.State_Code__c = 'CA';
        insert oState;
        
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
        
        Test.startTest();
            ClientEmployeeInfoCompCtrl.getObjectName(oOpportunity.Id);
            ClientEmployeeInfoCompCtrl.getOpportunityDetails(oOpportunity.Id);
            ClientEmployeeInfoCompCtrl.getProposalDetails(oProposal.Id);
            List<SUTA_Quote__c> lstSUTAQuote = ClientEmployeeInfoCompCtrl.getProposalSUTAQuoteRecords(oProposal.Id);
            ClientEmployeeInfoCompCtrl.getStates();
            ClientEmployeeInfoCompCtrl.submitClinetInfo(oOpportunity.Id, oProposal.Id, oState.Id, 10, 10);
            ClientEmployeeInfoCompCtrl.deleteSUTAQuoteRecords(lstSUTAQuote);
            ClientEmployeeInfoCompCtrl.submitClinetInfo(oOpportunity.Id, oProposal.Id, oState.Id, 10, 10);
            try{
                ClientEmployeeInfoCompCtrl.deleteSUTAQuoteRecords(null);
            }catch(Exception ex){}
        Test.stopTest();
    }
    
}