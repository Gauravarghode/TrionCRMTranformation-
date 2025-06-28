public class SearchWCCarrierRatesFilterWrapper {
    
    @AuraEnabled public String selectedCompCode;
    @AuraEnabled public boolean isDisabledSelectedCompCode;
    @AuraEnabled public String selectedState; 
    @AuraEnabled public boolean isDisabledSelectedState;
    @AuraEnabled public String selectedCarrier;
    @AuraEnabled public boolean isDisabledSelectedCarrier;
    @AuraEnabled public String selectedStatus;
    @AuraEnabled public boolean isDisabledSelectedStatus;
    
    public SearchWCCarrierRatesFilterWrapper(){
        this.isDisabledSelectedCompCode = false;
        this.isDisabledSelectedState = false;
        this.isDisabledSelectedCarrier = false;
        this.isDisabledSelectedStatus = false;
    }
}