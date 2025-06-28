/*
* Author: Rahul Allada (EA)
*/

public class SurveyResponseTriggerHander {
    
    // This class is a trigger handler for survey responses.
    // It is responsible for deleting existing survey responses when new survey responses are created.
    
    public void deleteExistingSurveyResponses(List<Survey_Responses__c> newSurveyResponses) {
        
        // This method deletes existing survey responses when new survey responses are created.
        // It first creates a list of case IDs for the new survey responses.
        // Then, it deletes all survey responses where the case ID is in the list of case IDs.
        
        //List<Id> listOfCaseIds = new List<Id>();
        List<Id> listOfAccountIds = new List<Id>();
        for (Survey_Responses__c eachSurveyResponse : newSurveyResponses) {
            listOfAccountIds.add(eachSurveyResponse.Account__c);
            //listOfCaseIds.add(eachSurveyResponse.Case__c);
        }
            delete [SELECT Id, Account__c FROM Survey_Responses__c WHERE Account__c IN: listOfAccountIds];

        //delete [SELECT Id, Case__c FROM Survey_Responses__c WHERE Case__c IN: listOfCaseIds];
        String username = Survey_Settings__c.getOrgDefaults().Survey_Feedback_Owner__c;
        List<User> userList = [SELECT Id, IsActive,username, Name FROM User where username =: username];
        //List<Survey_Settings__c> surveySettingList = [SELECT Id, Name, Survey_Feedback_Owner__c FROM Survey_Settings__c];
        
        if(userList.size() > 0)
        {
          for(Survey_Responses__c eachSurveyRS : newSurveyResponses){
            
              eachSurveyRS.CreatedById = userList[0].id;
        }  
        }
    }
}