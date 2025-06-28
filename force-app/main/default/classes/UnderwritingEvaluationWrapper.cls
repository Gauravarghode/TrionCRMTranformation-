public class UnderwritingEvaluationWrapper{
	@AuraEnabled public boolean isExpaned;
	@AuraEnabled public boolean isSelected;
	@AuraEnabled public boolean isDelete;
	@AuraEnabled public Loss_Year__c oLossYear;
	@AuraEnabled public List<LossYearEvaluationWrapper> lstLossYearEvaluationWrapper;
	
    public UnderwritingEvaluationWrapper(){
        this.isExpaned = false;
        this.isSelected = false;
        this.isDelete = false;
        this.oLossYear = new Loss_Year__c();
        this.lstLossYearEvaluationWrapper = new List<LossYearEvaluationWrapper>();
    }
    
}