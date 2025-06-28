public class ContactTriggerHandler {

    
    Public void fillUpDefaultSurveyDays(List<Contact> listOfContacts, Map<Id, Contact> mapOfOldContacts){
        
        List<Id> listOfContactTypes = new List<Id>();
        Map<Id, Contact_Type__c> mapOfContactTypes = new Map<Id, Contact_Type__c>([SELECT Id, Default_Days__c FROM Contact_Type__c]);
        for(Contact eachContact : listOfContacts){
            if(trigger.isInsert && trigger.isBefore){
                if(eachContact.Contact_Type__c != Null && eachContact.Default_Days_Survey__c == null){
                    eachContact.Default_Days_Survey__c  = mapOfContactTypes?.get(eachContact.Contact_Type__c)?.Default_Days__c;
                }
            }
            if(trigger.isBefore && trigger.isUpdate){
                if(eachContact.Contact_Type__c != Null && eachContact.Default_Days_Survey__c == null && eachContact.Contact_Type__c != mapOfOldContacts.get(eachContact.Id).Contact_Type__c){
                    eachContact.Default_Days_Survey__c  = mapOfContactTypes?.get(eachContact.Contact_Type__c)?.Default_Days__c;
                }
            }
        }
    }
}