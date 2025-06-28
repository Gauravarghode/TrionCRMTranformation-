public class WC_RateWrapper {
	@AuraEnabled public boolean isDelete;
    @AuraEnabled public boolean isSelected;
    @AuraEnabled public WC_Rate__c oRate;
    
    public WC_RateWrapper(){
        this.isDelete = false;
        this.isSelected = false;
    }
    
}