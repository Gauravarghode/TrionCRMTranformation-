trigger SurveyFeedbackTrigger on Survey_Feedback__c (before insert) {

    SurveyFeedbackTriggerHandler surveyFeedbackTriggerHandler = new SurveyFeedbackTriggerHandler();
    if(trigger.isInsert && trigger.isBefore){
        surveyFeedbackTriggerHandler.deleteSurveyFeedbacks(trigger.new);
    }
}