public class CaseTriggerHandler {
    public class CustomException extends exception {}
    
    public void triggerTheSurveyForTheFirstTime( List<Case> listOfCasesInserted, Map<Id, Case> mapOfOldCases ){
        
        
        Map<Id, Decimal> mapOfContactDefaultDays = new Map<Id, Decimal>();
        Map<Id, Date> mapOfContactAndSurveyLastSent = new Map<Id, Date>();
        List<Id> listOfContactIds = new List<Id>();
        for(Case eachInsertedCase : listOfCasesInserted){
            listOfContactIds.add(eachInsertedCase.ContactId);
        }
        for(Contact eachContact : [SELECT Id, Default_Days_Survey__c, Survey_Last_sent_on__c FROM Contact WHERE Id IN: listOfContactIds]){
            mapOfContactDefaultDays.put(eachContact.Id, eachContact?.Default_Days_Survey__c );
            mapOfContactAndSurveyLastSent.put(eachContact.Id, eachContact?.Survey_Last_sent_on__c);
        }
        
        /* for(Case eachCase : listOfCasesInserted){
if(case.status == 'Closed'){
eachCase.Send_Survey_Email__c = true;
}
} */
        
        if(trigger.isInsert){
            for(Case eachCase: listOfCasesInserted){
                if(eachCase.status == 'Closed' && Survey_Settings__c.getOrgDefaults().Enable_Surveys__c){
                    eachCase.Send_Survey_Email__c = true;
                    if(eachCase.Reason != 'Issue Resolved' || mapOfContactDefaultDays.get(eachCase.ContactId) < 0){
                        continue;
                    }
                    if(eachCase.contactId == Null){
                        eachCase.addError('Contact is mandatory when closing the case as the survey switch is ON.');
                    } else {
                        if(mapOfContactDefaultDays.get(eachCase.ContactId) == Null){
                            eachCase.addError('Contact Type and default days of survey in the contact should be filled as the Survey is ON.');
                        } else if(mapOfContactDefaultDays.get(eachCase.ContactId) < 0){
                            continue;
                        } else {
                            system.debug('Inside');
                            eachCase.Send_Survey_Email_Again__c = validateIfSurveyShouldBeSent(mapOfContactDefaultDays, mapOfContactAndSurveyLastSent, eachCase.contactId);
                            if(eachCase.Send_Survey_Email_Again__c){
                                system.debug(eachCase.Send_Survey_Email_Again__c);
                                eachCase.Survey_Last_sent_on__c = date.today();
                            }
                        }
                    }
                } else if(eachCase.status == 'Closed') {
                    eachCase.Send_Survey_Email__c = true;
                }
            }
        }
        
        if(trigger.isUpdate){
            
            for(Case eachCase: listOfCasesInserted){
                if(eachCase.status == 'Closed' && mapOfOldCases.get(eachCase.Id).status != 'Closed' && Survey_Settings__c.getOrgDefaults().Enable_Surveys__c && !eachCase.Send_Survey_Email__c){
                    eachCase.Send_Survey_Email__c = true;
                    system.debug('Inside before');
                    system.debug('eachCase.Reason is '+eachCase.Reason);
                    if(eachCase.Reason != 'Issue Resolved'){
                        continue;
                    }
                    system.debug('Inside after');
                    if(eachCase.contactId == Null){
                        eachCase.addError('Contact is mandatory when closing the case as the survey switch is ON.');
                    } else {
                        if(mapOfContactDefaultDays.get(eachCase.ContactId) == Null){
                            eachCase.addError('Contact Type and default days of survey in the contact should be filled as the Survey is ON.');
                        } else if(mapOfContactDefaultDays.get(eachCase.ContactId) < 0){
                            continue;
                        } else {
                            eachCase.Send_Survey_Email_Again__c = validateIfSurveyShouldBeSent(mapOfContactDefaultDays, mapOfContactAndSurveyLastSent, eachCase.contactId);
                            system.debug('eachCase.Send_Survey_Email_Again__c is '+eachCase.Send_Survey_Email_Again__c);
                            if(eachCase.Send_Survey_Email_Again__c){
                                eachCase.Survey_Last_sent_on__c = date.today();
                            }
                        }
                    }
                } else if(eachCase.status == 'Closed') {
                    eachCase.Send_Survey_Email__c = true;
                }
            } 
        }
    }
    
    Public Boolean validateIfSurveyShouldBeSent(Map<Id, Decimal> mapOfContactDefaultDays, Map<Id, Date> mapOfContactAndSurveyLastSent, Id contactId){
        
        if(mapOfContactAndSurveyLastSent.get(ContactId) != Null){
            if(mapOfContactAndSurveyLastSent.get(contactId).daysBetween(date.today()) >= mapOfContactDefaultDays.get(contactId)){
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
        
    }
    /* public void markTheSurveyLastSentOnDate(List<Case> listOfCasesInserted, Map<Id, Case> mapOfOldCases){
Map<Id, Decimal> mapOfContactDefaultDays = new Map<Id, Decimal>();
Map<Id, Date> mapOfContactAndSurveyLastSent = new Map<Id, Date>();
List<Id> listOfContactIds = new List<Id>();
for(Case eachInsertedCase : listOfCasesInserted){
listOfContactIds.add(eachInsertedCase.ContactId);
}
for(Contact eachContact : [SELECT Id, Default_Days_Survey__c, Survey_Last_sent_on__c FROM Contact WHERE Id IN: listOfContactIds]){
mapOfContactDefaultDays.put(eachContact.Id, eachContact?.Default_Days_Survey__c );
mapOfContactAndSurveyLastSent.put(eachContact.Id, eachContact?.Survey_Last_sent_on__c);
}

Boolean sendSurveys = Survey_Settings__c.getOrgDefaults().Enable_Surveys__c;
if(trigger.isInsert){

for(Case eachInsertedCase : listOfCasesInserted){
if(eachInsertedCase.status == 'Closed'){
eachInsertedCase.Send_Survey_Email__c = true;
if(mapOfContactAndSurveyLastSent.get(eachInsertedCase.ContactId) != Null){
system.debug(mapOfContactAndSurveyLastSent.get(eachInsertedCase.ContactId).daysBetween(date.today()));
system.debug(mapOfContactDefaultDays.get(eachInsertedCase.ContactId));
if(mapOfContactAndSurveyLastSent.get(eachInsertedCase.ContactId).daysBetween(date.today()) > mapOfContactDefaultDays.get(eachInsertedCase.ContactId) && sendSurveys){
system.debug('Survey Sent Successfully!');
eachInsertedCase.Send_Survey_Email_Again__c = true;
eachInsertedCase.Survey_Last_sent_on__c = date.today();
} else {
system.debug('Survey Cannot be sent!');
}
} else if(sendSurveys) {
eachInsertedCase.Send_Survey_Email_Again__c = true;
eachInsertedCase.Survey_Last_sent_on__c = date.today();
}
} else if(eachInsertedCase.Send_Survey_Email_Again__c == true){
eachInsertedCase.Survey_Last_sent_on__c = date.today();
} 
}
}

if(trigger.isUpdate){
for(Case eachInsertedCase : listOfCasesInserted){
//Send survey email will be false if the survey is not sent even once.
if(eachInsertedCase.status == 'Closed' && mapOfOldCases.get(eachInsertedCase.Id).status != 'Closed' && eachInsertedCase.Send_Survey_Email__c != true){
eachInsertedCase.Send_Survey_Email__c = true;
if(mapOfContactAndSurveyLastSent.get(eachInsertedCase.ContactId) != Null){
system.debug(mapOfContactAndSurveyLastSent.get(eachInsertedCase.ContactId).daysBetween(date.today()));
system.debug(mapOfContactDefaultDays.get(eachInsertedCase.ContactId));
if(mapOfContactAndSurveyLastSent.get(eachInsertedCase.ContactId).daysBetween(date.today()) > mapOfContactDefaultDays.get(eachInsertedCase.ContactId) && sendSurveys){
system.debug('Survey Sent Successfully!');
eachInsertedCase.Send_Survey_Email_Again__c = true;
eachInsertedCase.Survey_Last_sent_on__c = date.today();
}
} else if(sendSurveys) {
system.debug('Survey Cannot be sent!');
eachInsertedCase.Send_Survey_Email_Again__c = true;
eachInsertedCase.Survey_Last_sent_on__c = date.today();
}

} else if(eachInsertedCase.Send_Survey_Email_Again__c == true && mapOfOldCases.get(eachInsertedCase.Id).Send_Survey_Email_Again__c == false){
eachInsertedCase.Survey_Last_sent_on__c = date.today();
}
system.debug(system.JSON.serializePretty(eachInsertedCase));
}
}
} */
    
    Public void markTheSurveyLastSentOnDateOnContact(List<Case> listOfCasesInserted, Map<Id, Case> mapOfOldCases){
        List<Id> listOfContactIds = new List<Id>();
        if(trigger.isInsert){
            for(Case eachInsertedCase : listOfCasesInserted){
                if(eachInsertedCase.Send_Survey_Email_Again__c == true){
                    listOfContactIds.add(eachInsertedCase.ContactId);
                }
            }
        }
        if(trigger.isUpdate){
            for(Case eachInsertedCase : listOfCasesInserted){
                if(eachInsertedCase.Send_Survey_Email_Again__c == true && mapOfOldCases.get(eachInsertedCase.Id).Send_Survey_Email_Again__c == false){
                    listOfContactIds.add(eachInsertedCase.ContactId);
                }
            }
        }
        system.debug(listOfContactIds);
        List<Contact> listOfContactsToUpdate = [SELECT Id, Survey_Last_sent_on__c FROM Contact WHERE Id IN: listOfContactIds];
        for(Contact eachContact: listOfContactsToUpdate){
            system.debug(eachContact);
            eachContact.Survey_Last_sent_on__c = Date.today();
        }
        
        try{
            update listOfContactsToUpdate;
            if(CaseTriggerHandlerTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
        } catch(Exception e){
            system.debug('Exception is '+e.getMessage());
        }
        
        
    }
}