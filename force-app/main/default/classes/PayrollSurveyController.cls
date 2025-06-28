public class PayrollSurveyController {
    
    @Auraenabled
    Public static AccountWrapper getAccountAndContactDetails(Id AccountId){
        AccountWrapper accountWrapper = new AccountWrapper();
        List<Account> retrievedAccount = [SELECT Id, Send_First_Payroll_Survey__c, Payroll_Contact__c, Payroll_survey_last_sent_on__c, Payroll_Contact__r.Default_Days_Survey__c, Payroll_Contact__r.Survey_Last_sent_on__c, Send_Survey_Again__c FROM Account WHERE Id =: AccountId LIMIT 1];
        system.debug(retrievedAccount);
        Survey_Settings__c surveySettings = Survey_Settings__c.getOrgDefaults();
		accountWrapper.surveyEnabled = surveySettings.Enable_Surveys__c;
        if(retrievedAccount != Null && retrievedAccount.size() == 1){
            for(Account eachAccount : retrievedAccount){
                //AccountWrapper accountWrapper = new AccountWrapper();
                accountWrapper.surveySent = eachAccount.Send_First_Payroll_Survey__c;
                accountWrapper.surveyLastSent = eachAccount.Payroll_Contact__r.Survey_Last_sent_on__c;
                accountWrapper.numberOfSurveyDays = Integer.valueOf(eachAccount.Payroll_Contact__r.Default_Days_Survey__c);
                accountWrapper.numberOfDaysBetween = eachAccount.Payroll_Contact__r.Survey_Last_sent_on__c != null ? eachAccount.Payroll_Contact__r.Survey_Last_sent_on__c.daysBetween(Date.today()) : null;
                accountWrapper.numberOfDaysLeft = (accountWrapper.numberOfSurveyDays != null && accountWrapper.numberOfDaysBetween != null) ? accountWrapper.numberOfSurveyDays - accountWrapper.numberOfDaysBetween : null;
                accountWrapper.sendSurveyAgain = eachAccount.Send_Survey_Again__c;
                accountWrapper.payrollSurveyLastSentOn = eachAccount.Payroll_survey_last_sent_on__c;
            }
        }
        return accountWrapper;
    }
    
    @Auraenabled
    Public static CaseWrapper getCaseAndContactDetails(Id CaseId){
        CaseWrapper caseWrapper = new CaseWrapper();
        List<Case> retrievedCase = [SELECT Id, Send_Survey_Email__c, Survey_Last_sent_on__c , Send_Survey_Email_Again__c, Contact.Default_Days_Survey__c, Contact.Survey_Last_sent_on__c, ContactEmail FROM Case WHERE Id =: CaseId];
        Survey_Settings__c surveySettings = Survey_Settings__c.getOrgDefaults();
		caseWrapper.surveyEnabled = surveySettings.Enable_Surveys__c;
        for( Case eachCase : retrievedCase ){
            caseWrapper.ContactEmail = eachCase.ContactEmail;
            caseWrapper.surveySent = eachCase.Send_Survey_Email__c;
            caseWrapper.surveyLastSent = eachCase.Contact.Survey_Last_sent_on__c;
            caseWrapper.numberOfSurveyDays = Integer.valueOf(eachCase.Contact.Default_Days_Survey__c);
            caseWrapper.numberOfDaysBetween = eachCase.Contact.Survey_Last_sent_on__c != null ? eachCase.Contact.Survey_Last_sent_on__c.daysBetween(Date.today()) : null;
            caseWrapper.numberOfDaysLeft = (caseWrapper.numberOfSurveyDays != null && caseWrapper.numberOfDaysBetween != null) ? caseWrapper.numberOfSurveyDays - caseWrapper.numberOfDaysBetween : null;
            caseWrapper.sendSurveyAgain = eachCase.Send_Survey_Email_Again__c;
            caseWrapper.caseSurveyLastSentOn = eachCase.Survey_Last_sent_on__c;
        }
        system.debug(caseWrapper);
		return caseWrapper;        
    }
        
        public class AccountWrapper{
            @AuraEnabled
            Public Boolean surveyEnabled;
            @AuraEnabled
            public boolean surveySent;
            @AuraEnabled
            public Date surveyLastSent;
            @AuraEnabled
            Public Integer numberOfSurveyDays;
            @AuraEnabled
            Public Integer numberOfDaysLeft;
            @AuraEnabled
            Public Integer numberOfDaysBetween;
            @AuraEnabled
            Public boolean sendSurveyAgain;
            @AuraEnabled
            Public date payrollSurveyLastSentOn;
            
        }
        
        Public class CaseWrapper {
            @AuraEnabled
            Public Boolean surveyEnabled;
            @AuraEnabled
            public boolean surveySent;
            @AuraEnabled
            public Date surveyLastSent;
            @AuraEnabled
            Public Integer numberOfSurveyDays;
            @AuraEnabled
            Public Integer numberOfDaysLeft;
            @AuraEnabled
            Public Integer numberOfDaysBetween;
            @AuraEnabled
            Public boolean sendSurveyAgain;
            @AuraEnabled
            Public Date caseSurveyLastSentOn;
            @AuraEnabled
            Public string ContactEmail;
        }
    }