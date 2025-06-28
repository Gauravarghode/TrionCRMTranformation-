@isTest
public class PEOClientEmployeeInfoCompCtrl_Test {

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
        
        SUTA_Quote__c oQuote1 = new SUTA_Quote__c();
        oQuote1.Policy__c = oPolicy.Id;
        oQuote1.State__c = oState.Id; 
        oQuote1.Proposal__c = oProposal.Id;
        oQuote1.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuote1;
        
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
        insert oWC_Rate;
        
        Test.startTest();
            PEOClientEmployeeInfoCompCtrl.getObjectName(oOpportunity.Id);
            PEOClientEmployeeInfoCompCtrl.getOpportunityDetails(oOpportunity.Id);
            PEOClientEmployeeInfoCompCtrl.getProposalDetails(oProposal.Id); 
            PEOClientEmployeeInfoCompCtrl.getWCRate(oWC_Rate.Id);
            PEOClientEmployeeInfoCompCtrl.getClientLocation(oClientLocation.Id);
            
            List<SUTA_QuoteWrapper> lstWrapper = PEOClientEmployeeInfoCompCtrl.getProposalSUTAQuoteRecords(oProposal.Id);   
            List<SUTA_Quote__c> lstQuoteState = new List<SUTA_Quote__c>();
            for(SUTA_QuoteWrapper oQuoteWrapper : lstWrapper){
                oQuoteWrapper.isSelected = true;
                lstQuoteState.add(oQuoteWrapper.oQuote);
                for(ClientLocationWrapper oClientWrapper : oQuoteWrapper.lstClientLocationWrapper){
                    for(WC_RateWrapper oRateWrapper : oClientWrapper.lstWCRates){
                        oRateWrapper.isSelected = true;
                    }
                }
            }
            
            PEOClientEmployeeInfoCompCtrl.createState(oProposal.Id, lstQuoteState);
            PEOClientEmployeeInfoCompCtrl.createState(oProposal.Id, new List<SUTA_Quote__c>());
            try{
                PEOClientEmployeeInfoCompCtrl.createState(null, null);
            }catch(Exception e){}
            
            oClientLocation = new Client_Location__c();
            oClientLocation.Proposal__c = oProposal.Id;
            oClientLocation.SUTA_Quote__c = oQuote.Id;
            oClientLocation.Client__c = oAccount.Id;
            oClientLocation.Loc__c = 2;
            
            PEOClientEmployeeInfoCompCtrl.createClientLocation(oClientLocation);
            
            oWC_Rate = new WC_Rate__c();
            oWC_Rate.Client_Location__c = oClientLocation.Id;
            oWC_Rate.Proposal__c = oProposal.Id;
            oWC_Rate.SUTA_Quote__c = oQuote.Id;
            
            PEOClientEmployeeInfoCompCtrl.createWCRate(oWC_Rate);
        
            PEOClientEmployeeInfoCompCtrl.getStates();
            PEOClientEmployeeInfoCompCtrl.getClientLocationPicklistValues(oProposal.Id,oState.Id);
            
            Client_Location__c oClient_Location =  PEOClientEmployeeInfoCompCtrl.getNewClientLocation(oProposal.Id,oState.Id, oAccount.Id);
            
            try{
                oClient_Location =  PEOClientEmployeeInfoCompCtrl.getNewClientLocation(null, null, oAccount.Id);
            }catch(Exception e){}
            
            PEOClientEmployeeInfoCompCtrl.createWCCode(oProposal.Id, oState.Id, new WC_Rate__c());
            
            try{
                PEOClientEmployeeInfoCompCtrl.createWCCode(null, null, new WC_Rate__c());
            }catch(Exception e){}
            
            PEOClientEmployeeInfoCompCtrl.deleteSUTARecord(oQuote1.Id);
            PEOClientEmployeeInfoCompCtrl.deleteWCRate(oWC_Rate.Id);
            
            try{
                PEOClientEmployeeInfoCompCtrl.deleteWCRate(null);
            }catch(Exception e){}
            
            try{
                PEOClientEmployeeInfoCompCtrl.deleteSUTARecord(null);
            }catch(Exception ex){}
        
            oClientLocation = new Client_Location__c();
            oClientLocation.Proposal__c = oProposal.Id;
            oClientLocation.SUTA_Quote__c = oQuote.Id;
            oClientLocation.Client__c = oAccount.Id;
            
            String clientLocationId = PEOClientEmployeeInfoCompCtrl.createClientLocation(oClientLocation);
            PEOClientEmployeeInfoCompCtrl.deleteClientLocation(clientLocationId);
            
            try{
                PEOClientEmployeeInfoCompCtrl.deleteClientLocation(null);
            }catch(Exception ex){}
            
        try{
            PEOClientEmployeeInfoCompCtrl.deleteSUTARecords(JSON.serialize(lstWrapper));
        }catch(Exception e){}
            lstWrapper = PEOClientEmployeeInfoCompCtrl.getProposalSUTAQuoteRecords(oProposal.Id);
            for(SUTA_QuoteWrapper oQuoteWrapper : lstWrapper){
                oQuoteWrapper.isSelected = true;
            }
            
            try{
                PEOClientEmployeeInfoCompCtrl.deleteSUTARecords(null);
            }catch(Exception e){}
            
            try{
                PEOClientEmployeeInfoCompCtrl.createClientLocation(null);
            }catch(Exception ex){}
        
            try{
                PEOClientEmployeeInfoCompCtrl.createWCRate(null);
            }catch(Exception ex){}
        
            
        Test.stopTest();
    }
    
}