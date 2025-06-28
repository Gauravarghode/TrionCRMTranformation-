/**
* @File Name : SurveyMarked.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : January 30, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 30, 2025 |   | Initial Version
**/

public without sharing class SurveyMarked {
	@AuraEnabled
    public static void surveyMarked(String surveyId) {

        if (String.isBlank(surveyId)) {
        throw new IllegalArgumentException('No survey IDs provided.');
    }
        Survey__c surveysToUpdate = new Survey__c(Id = surveyId, Surveyed__c = true);
        update surveysToUpdate;
}
}