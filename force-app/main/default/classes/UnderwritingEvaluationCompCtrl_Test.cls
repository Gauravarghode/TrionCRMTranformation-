@isTest
public class UnderwritingEvaluationCompCtrl_Test {

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
        
        Policy_Year__c oPolicyYear = new Policy_Year__c();
        oPolicyYear.Account__c = oAccount.Id;
        oPolicyYear.Policy_Start_Date__c = date.today();
        oPolicyYear.Policy_End_Date__c = date.today().addDays(1);
        oPolicyYear.Year__c = oYear.Id;
        insert oPolicyYear;
        
        Policy__c oPolicy = new Policy__c();
        oPolicy.Carrier__c = oAccount.Id;
        oPolicy.Policy_Year__c = oPolicyYear.Id;
        oPolicy.Status__c = 'Active';
        oPolicy.Type__c = 'Master';
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
        oQuote.State_Assessment_Fee_Surcharge_Included__c = false;
        insert oQuote;
        
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
        
        Loss_Year__c oLoss_Year = new Loss_Year__c();
        oLoss_Year.Program_Year__c = oYear.Id;
        oLoss_Year.Proposal__c = oProposal.Id;
        insert oLoss_Year;
        
        Loss_Year_Evaluation__c oLossYearEvaluation = new Loss_Year_Evaluation__c();
        oLossYearEvaluation.Loss_Year__c = oLoss_Year.Id;
        oLossYearEvaluation.Proposal__c = oProposal.Id;
        insert oLossYearEvaluation;
        
        Test.startTest();
            UnderwritingEvaluationCompCtrl.getProposalDetails(oProposal.Id);
            List<UnderwritingEvaluationWrapper> wrapper = UnderwritingEvaluationCompCtrl.getLossYearsAndEvaluationRecords(oProposal.Id);
            UnderwritingEvaluationCompCtrl.createLossYearAndLossYearEvaluation(oYear.Id, oProposal.Id);
            
            UnderwritingEvaluationCompCtrl.getYears();
            UnderwritingEvaluationCompCtrl.updateEvaluationYears(new List<Loss_Year_Evaluation__c>{oLossYearEvaluation},oYear.Id,oProposal.Id);
            UnderwritingEvaluationCompCtrl.createLossYearEvaluation(new Loss_Year_Evaluation__c(), oYear.Id, oProposal.Id);
            UnderwritingEvaluationCompCtrl.deleteLossYear(JSON.serialize(wrapper));
            UnderwritingEvaluationCompCtrl.deleteParentLossYear(oLoss_Year.Id);
            UnderwritingEvaluationCompCtrl.createLossYearAndLossYearEvaluation(oYear.Id, oProposal.Id);
            try{
                UnderwritingEvaluationCompCtrl.deleteLossYear(null);
            }catch(Exception ex){}
            
            try{    
                UnderwritingEvaluationCompCtrl.deleteLossYearEvaluation(oLossYearEvaluation.Id);
            }catch(Exception e){}
            try{
                UnderwritingEvaluationCompCtrl.deleteLossYearEvaluation(null);
            }catch(Exception ex){}
            try{
                UnderwritingEvaluationCompCtrl.updateEvaluationYears(null,null,null);
            }catch(Exception ex){}
            try{
                UnderwritingEvaluationCompCtrl.createLossYearEvaluation(null,null,null);
            }catch(Exception ex){}
        Test.stopTest();
    }
    
}