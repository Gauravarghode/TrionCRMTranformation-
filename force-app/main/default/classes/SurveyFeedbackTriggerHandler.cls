public class SurveyFeedbackTriggerHandler {
    
    public void deleteSurveyFeedbacks(List<Survey_Feedback__c> newSurveyFeedbacks){
         List<Id> listOfCaseIds = new List<Id>();

       // List<Id> listOfAccountIds = new List<Id>();
        for(Survey_Feedback__c eachSurveyFeedback : newSurveyFeedbacks){
           // listOfAccountIds.add(eachSurveyFeedback.Account__c);
           listOfCaseIds.add(eachSurveyFeedback.Case__c);
        } 
        
        //delete [SELECT Id, Account__c FROM Survey_Feedback__c WHERE Account__c IN: listOfAccountIds];
          delete [SELECT Id, Case__c FROM Survey_Feedback__c WHERE Case__c IN: listOfCaseIds];

        //changing Owner Of the record
        String username = Survey_Settings__c.getOrgDefaults().Survey_Feedback_Owner__c;
        List<User> userList = [SELECT Id, IsActive,username, Name FROM User where username =: username];
        //List<Survey_Settings__c> surveySettingList = [SELECT Id, Name, Survey_Feedback_Owner__c FROM Survey_Settings__c];
        
        if(userList.size() > 0)
        {
          for(Survey_Feedback__c eachSurveyFB : newSurveyFeedbacks){
            
              eachSurveyFB.CreatedById = userList[0].id;
        }  
        }
        
    }
}