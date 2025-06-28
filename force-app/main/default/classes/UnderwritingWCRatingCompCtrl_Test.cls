@isTest
public class UnderwritingWCRatingCompCtrl_Test {
    
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
        oAccount.Status__c = 'Active';
        oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
        insert oAccount;
        
        State__c oState = new State__c();
        oState.Name = 'California';
        oState.State_Code__c = 'CA';
        oState.State_Classification__c ='Master';
        insert oState;
        
        State__c oStateMCP = new State__c();
        oStateMCP.Name = 'Louisiana';
        oStateMCP.State_Code__c = 'LA';
        oStateMCP.State_Classification__c ='MCP';
        insert oStateMCP;
        
        Policy_Year__c oPolicyYear = new Policy_Year__c();
        oPolicyYear.Account__c = oAccount.Id;
        oPolicyYear.Policy_Start_Date__c = date.today();
        oPolicyYear.Policy_End_Date__c = date.today().addDays(1);
        oPolicyYear.Year__c = oYear.Id;
        insert oPolicyYear;
        
        Policy__c oPolicyMCP = new Policy__c();
        oPolicyMCP.Carrier__c = oAccount.Id;
        oPolicyMCP.Policy_Year__c = oPolicyYear.Id;
        oPolicyMCP.Status__c = 'Active';
        oPolicyMCP.Type__c = 'MCP';
        oPolicyMCP.State__c = oStateMCP.Id;
        oPolicyMCP.Effective_Date__c = date.today();
        insert oPolicyMCP;
        
        Policy__c oPolicy = new Policy__c();
        oPolicy.Carrier__c = oAccount.Id;
        oPolicy.Policy_Year__c = oPolicyYear.Id;
        oPolicy.Status__c = 'Active';
        oPolicy.Type__c = 'Master';
        oPolicy.State__c = oState.Id;
        oPolicy.Effective_Date__c = date.today();
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
        //oQuote.Policy_Type__c = 'MCP';
        oQuote.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuote;
        
        SUTA_Quote__c oQuoteMCP = new SUTA_Quote__c();
        oQuoteMCP.Policy__c = oPolicyMCP.Id;
        oQuoteMCP.State__c = oStateMCP.Id; 
        oQuoteMCP.Proposal__c = oProposal.Id;
        //oQuote.Policy_Type__c = 'MCP';
        oQuoteMCP.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuoteMCP;
        
        SUTA__c oSUTA = new SUTA__c();
        oSUTA.Name = 'Test SUTA';
        oSUTA.State__c = oState.Id;
        oSUTA.Year__c = oYear.Id;
        oSUTA.Status__c = 'Active';
        oSUTA.Reporting_Level__c = 'Client';
        insert oSUTA;
        
        Client_Location__c oClientLocation = new Client_Location__c();
        oClientLocation.Proposal__c = oProposal.Id;
        oClientLocation.SUTA_Quote__c = oQuote.Id;
        oClientLocation.Client__c = oAccount.Id;
        insert oClientLocation;
        
        WC_Rate__c oWC_Rate = new WC_Rate__c();
        oWC_Rate.Client_Location__c = oClientLocation.Id;
        oWC_Rate.Proposal__c = oProposal.Id;
        oWC_Rate.SUTA_Quote__c = oQuote.Id;
        oWC_Rate.Effective_Rate__c  = 1; 
        insert oWC_Rate;
        
        Test.startTest();
        UnderwritingWCRatingCompCtrl.getProposalDetails(oProposal.Id);
        
        List<WC_Rate__c> lstWCRate = UnderwritingWCRatingCompCtrl.getWCRateRecords(oProposal.Id);
        
        UnderwritingWCRatingCompCtrl.updateWCRateStateCompCode(oWC_Rate.Id, null);
        UnderwritingWCRatingCompCtrl.getWCCarrier();
        UnderwritingWCRatingCompCtrl.updateWCRateCarrier(lstWCRate, oAccount.Id);
        
        List<Policy__c> lstPolicy = [SELECT ID, Carrier__c, Policy_Year__c, Status__c, Type__c, State__c, Effective_Date__c FROM Policy__c];
        List<SUTA_Quote__c> lstSUTAQuote = [SELECT ID, Name, Policy__c, State__c, Proposal__c, State_Assessment_Fee_Surcharge_Included__c FROM SUTA_Quote__c];
        List<MCPStateWrapper> lstMCPStateWrapper = new List<MCPStateWrapper>();
        lstMCPStateWrapper.add(new MCPStateWrapper(lstPolicy, lstSUTAQuote));
        
        UnderwritingWCRatingCompCtrl.updateMasterSUTAQuote(JSON.serialize(lstMCPStateWrapper), lstSUTAQuote, null, oPolicy.Id,null);
        try{
            UnderwritingWCRatingCompCtrl.updateWCRateStateCompCode(null, null);
        }catch(Exception e ){}
        try{
            UnderwritingWCRatingCompCtrl.updateMasterSUTAQuote(null, lstSUTAQuote, null, oPolicy.Id,null);
        }catch(Exception e){}
        try{
            UnderwritingWCRatingCompCtrl.updateWCRateCarrier(null, null);
        }catch(Exception ex){}
        
        UnderwritingWCRatingCompCtrl.deleteWCRate(oWC_Rate.Id);
        try{
            UnderwritingWCRatingCompCtrl.deleteWCRate(oWC_Rate.Id);
        }catch(Exception ex){}
        
        UnderwritingWCRatingCompCtrl.getPolicies(null, oProposal.Id);
        UnderwritingWCRatingCompCtrl.getMasterSutaQuote(oProposal.Id);
        UnderwritingWCRatingCompCtrl.getMCPStateWrapper(oProposal.Id, null);
        Test.stopTest();
    }
    
}