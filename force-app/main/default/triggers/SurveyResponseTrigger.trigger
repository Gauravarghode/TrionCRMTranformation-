trigger SurveyResponseTrigger on Survey_Responses__c (before insert) {

    SurveyResponseTriggerHander surveyResponseTriggerHandler = new SurveyResponseTriggerHander();
    surveyResponseTriggerHandler.deleteExistingSurveyResponses(trigger.new);
}