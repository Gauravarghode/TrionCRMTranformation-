/*
 * Author: Rahul Allada (EA)
 */

public class AccountTriggerHandler {
    public void fillTheSurveyDate(List<Account> listOfAccounts, Map<Id, Account> mapOfOldAccounts){
        List<Id> listOfContactIds = new List<Id>();
        if(trigger.isInsert){
            for(Account eachAccount : listOfAccounts){
                if(eachAccount.Send_Survey_Again__c){
                    eachAccount.Payroll_survey_last_sent_on__c = date.today();
                }
            }
        } else if(trigger.isUpdate){
            for(Account eachAccount : listOfAccounts){
                if(eachAccount.Send_Survey_Again__c){
                    eachAccount.Payroll_survey_last_sent_on__c = date.today();
                }
            }
        }
        
    }
}