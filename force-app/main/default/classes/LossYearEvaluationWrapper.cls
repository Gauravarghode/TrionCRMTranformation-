public class LossYearEvaluationWrapper{
	@AuraEnabled public boolean isSelected;
	@AuraEnabled public boolean isDelete;
	@AuraEnabled public Loss_Year_Evaluation__c oLossYearEvaluation;
    
    public LossYearEvaluationWrapper(){
        this.isSelected = false;
        this.isDelete = false;
        this.oLossYearEvaluation = new Loss_Year_Evaluation__c();
    }
    
}