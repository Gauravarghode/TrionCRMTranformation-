public class MCPStateWrapper {
	@AuraEnabled public List<Policy__c> lstPolicy;
    @AuraEnabled public List<SUTA_Quote__c> lstSUTAQuote;
    @AuraEnabled public List<Policy__c> selectedPolicy;
    
    public MCPStateWrapper(List<Policy__c> lstPolicy, List<SUTA_Quote__c> lstSUTAQuote){
        this.lstPolicy = lstPolicy;
        this.lstSUTAQuote = lstSUTAQuote;
        this.selectedPolicy = new List<Policy__c>();
        
        if(lstSUTAQuote != null && lstSUTAQuote.size()>0 && lstPolicy != null && lstPolicy.size()>0){
            for(SUTA_Quote__c quote : lstSUTAQuote){
                for(Policy__c policy : lstPolicy){
                    if(quote.Policy__c == policy.Id){
                        selectedPolicy.add(policy);
                        break;
                    }
                }
            }
        }
    }
}