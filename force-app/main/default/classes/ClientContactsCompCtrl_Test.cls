@isTest
public class ClientContactsCompCtrl_Test {

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
        
        oOpportunity.Proposal__c = oProposal.Id;
        update oOpportunity;
            
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
        
        Client_Contact__c oClientContact = new Client_Contact__c();
        oClientContact.Proposal__c = oProposal.Id;
        oClientContact.State__c = oState.Id;
        oClientContact.Location__c = oClientLocation.Id;
        insert oClientContact;
        
        WC_Rate__c oWC_Rate = new WC_Rate__c();
        oWC_Rate.Client_Location__c = oClientLocation.Id;
        oWC_Rate.Proposal__c = oProposal.Id;
        oWC_Rate.SUTA_Quote__c = oQuote.Id;
        insert oWC_Rate;
        
        Test.startTest();
        ClientContactsCompCtrl.getOpportunityDetails(oOpportunity.Id);
        ClientContactsCompCtrl.getObjectName(oOpportunity.Id);
        ClientContactsCompCtrl.getProposalDetails(oProposal.Id);
        ClientContactsCompCtrl.getClientContactRecord(oClientContact.Id);
        ClientContactsCompCtrl.getStatePicklistValues();
        List<Client_Contact__c> lstClientContact = ClientContactsCompCtrl.getClientContacts(oProposal.Id, '');
        ClientContactsCompCtrl.getClientLocationPicklistValues(oProposal.Id, oState.Id);
        ClientContactsCompCtrl.saveClientContacts(lstClientContact);
        Client_Location__c oClientLocation1 = ClientContactsCompCtrl.getNewClientLocation(oProposal.Id, oState.Id,oAccount.Id);
        ClientContactsCompCtrl.createClientLocation(oClientLocation1);
        
        
        ClinetContactWrapper oClientContactWrapper = new ClinetContactWrapper();
        oClientContactWrapper.firstName = 'test';
        oClientContactWrapper.lastName = 'test';
        oClientContactWrapper.titleRelationship = 'test';
        oClientContactWrapper.email = 'test@test.com';
        oClientContactWrapper.phone = 'test';
        oClientContactWrapper.ownership = 10;
        oClientContactWrapper.selectedState = oState.Id;
        oClientContactWrapper.payroll = 10;
        oClientContactWrapper.selectedClientLocation = oClientLocation.Id;
        oClientContactWrapper.selectedStampCode = null;
        oClientContactWrapper.primaryContactLastName = 'test';
        oClientContactWrapper.primaryContactFirstName = 'test';
        oClientContactWrapper.primaryContactPhone = 'test';
        oClientContactWrapper.primaryContactTitle = 'test';
        oClientContactWrapper.primaryContactEmail = 'test@test.com';
        oClientContactWrapper.isPrimary = true;
        ClientContactsCompCtrl.createClientContacts(JSON.serialize(oClientContactWrapper), oOpportunity);
        
        ClientContactsCompCtrl.deleteClientContacts(oClientContact.Id);
        
        try{
            ClientContactsCompCtrl.saveClientContacts(null);
        }catch(Exception ex){}
        try{
            ClientContactsCompCtrl.deleteClientContacts(null);
        }catch(Exception ex){}
        try{
            ClientContactsCompCtrl.createClientLocation(null);
        }catch(Exception ex){}
        try{
            ClientContactsCompCtrl.createClientContacts(null, null);
        }catch(Exception ex){}
        ClientContactsCompCtrl.getClientLocationValue(oClientLocation.Id);
        ClientContactsCompCtrl.getNewClientLocation(oProposal.Id, null,oAccount.Id);
        ClientContactsCompCtrl.getPicklistValues('SUTA_Quote__c','Reporting_Level__c');
        try{
            ClientContactsCompCtrl.getNewClientLocation(null, null,null);
        }catch(Exception e){}
        Test.stopTest();
    }
    
}