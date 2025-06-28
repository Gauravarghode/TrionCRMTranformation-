public class SUTA_QuoteWrapper{
	@AuraEnabled public boolean isDelete;
    @AuraEnabled public boolean isSelected;
    @AuraEnabled public boolean isExpaned;
	@AuraEnabled public SUTA_Quote__c oQuote;
	@AuraEnabled public List<ClientLocationWrapper> lstClientLocationWrapper;
    @AuraEnabled public List<WC_RateWrapper> lstRateWrapper;
    
    public SUTA_QuoteWrapper(){
        this.isExpaned = false;
        this.isDelete = false;
        this.isSelected = false;
    }
    
}