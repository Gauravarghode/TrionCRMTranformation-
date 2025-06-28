public class ClientLocationWrapper{
	@AuraEnabled public boolean isExpaned;
    @AuraEnabled public boolean isDeleteWCRate;
	@AuraEnabled public Client_Location__c oClientLocation;
	@AuraEnabled public List<WC_RateWrapper> lstWCRates;
    
    public ClientLocationWrapper(){
        this.isExpaned = false;
        this.isDeleteWCRate = false;
    }
}