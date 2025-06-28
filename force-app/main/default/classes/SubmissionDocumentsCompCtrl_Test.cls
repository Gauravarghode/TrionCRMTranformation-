@isTest
public class SubmissionDocumentsCompCtrl_Test {
    
    @isTest
    public static void myUnitTest(){
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
        insert oProposal;
        
        Submission_Requirement__c oSubmissionRequirement = new Submission_Requirement__c();
        oSubmissionRequirement.Opportunity__c = oOpportunity.Id;
        oSubmissionRequirement.Required_Optional__c = 'Optional';
        oSubmissionRequirement.Requirement_Type__c = 'ACORD';
        oSubmissionRequirement.Status__c = 'Not Started';
        insert oSubmissionRequirement;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = oSubmissionRequirement.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        State__c oState = new State__c();
        oState.Name = 'California';
        oState.State_Code__c = 'CA';
        insert oState;
        
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
        SubmissionDocumentsCompCtrl.getAccordSignatureRequestURL(oSubmissionRequirement.Id);
        SubmissionDocumentsCompCtrl.getGenerateACORD(oSubmissionRequirement.Id);
        String objname = SubmissionDocumentsCompCtrl.getObjectName(oOpportunity.Id);
        SubmissionDocumentsCompCtrl.getOpportunityDetails(oOpportunity.Id);
        SubmissionDocumentsCompCtrl.getProposalDetails(oProposal.Id);
        SubmissionDocumentsCompCtrl.getWCRate(oProposal.Id);
        SubmissionDocumentsCompCtrl.getSubmissionRequirement(oOpportunity.Id, 'Not Started', 'Optional');
        SubmissionDocumentsCompCtrl.updateSubmissionRequirement(oProposal, oSubmissionRequirement, 'testing notes', true);
        SubmissionDocumentsCompCtrl.updateWCRate(oWC_Rate);
        SubmissionDocumentsCompCtrl.getClientLocationPicklistValues(oProposal.Id, oState.Id);
        SubmissionDocumentsCompCtrl.getPicklistValues('Submission_Requirement__c', 'Required_Optional__c');
        
        try{
            SubmissionDocumentsCompCtrl.updateWCRate(null);
        }catch(Exception e ){}
        
        try{
            SubmissionDocumentsCompCtrl.updateSubmissionRequirement(null, null, null, null);
        }catch(Exception ex){}
        
        SubmissionDocumentsCompCtrl.createProposalAndupdateSubmissionRequirement(oProposal, oSubmissionRequirement, oSubmissionRequirement.Id, 'testing notes', true);
        
        try{
            SubmissionDocumentsCompCtrl.createProposalAndupdateSubmissionRequirement(null, null, null, null, null);
        }catch(Exception ex){}
        
        SubmissionDocumentsCompCtrl.getContentDocumentId(oSubmissionRequirement.Id);
        SubmissionDocumentsCompCtrl.deleteFileAndUpdateSubmissionRequirement(oSubmissionRequirement.Id);
        try{
            SubmissionDocumentsCompCtrl.deleteFileAndUpdateSubmissionRequirement(null);
        }catch(Exception ex){}
        try{
            SubmissionDocumentsCompCtrl.deleteFileAndUpdateSubmissionRequirement(oSubmissionRequirement.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }
    
}