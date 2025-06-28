@isTest
public class SearchWCCarrierRatesCompCtrl_Test {

    @isTest
    public static void unitTest(){
    
        WC_Code__c oWCCode = new WC_Code__c();
        oWCCode.Name = '6801F';
        oWCCode.Code__c = '680TE';
        insert oWCCode;
        
        Account oAccount = new Account();
        oAccount.Name = 'Test';
        insert oAccount;
        
        Carrier_WC_Rate__c oRate = new Carrier_WC_Rate__c();
        oRate.WC_Code__c = oWCCode.Id;
        oRate.Carrier__c = oAccount.Id;
        insert oRate;
        
        Test.startTest();
        SearchWCCarrierRatesCompCtrl.getPicklistValues('Policy__c', 'Status__c');
        
        SearchWCCarrierRatesFilterWrapper owrapper = new SearchWCCarrierRatesFilterWrapper();
        owrapper.selectedCompCode = oWCCode.Id;
        
        List<Carrier_WC_Rate__c> lstCarrierWCRates = SearchWCCarrierRatesCompCtrl.getCarrierWCRates(JSON.serialize(new List<SearchWCCarrierRatesFilterWrapper>{owrapper}));
        SearchWCCarrierRatesCompCtrl.updateCarrierWCRates(lstCarrierWCRates);
        try{
            SearchWCCarrierRatesCompCtrl.updateCarrierWCRates(null);
        }catch(Exception dmlex){}
        
        SearchWCCarrierRatesCompCtrl.getCarrierPicklistValues();
        SearchWCCarrierRatesCompCtrl.getStatePicklistValues();
        Test.stopTest();
        
    }
    
}