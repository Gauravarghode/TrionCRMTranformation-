@isTest
public class CaseTriggerHandlerTest {
    public static boolean isTestFailInsert = false;
    
    @testsetup
    static void insertTestdata(){
        List<Contact> listOfContact = TestDataFactory.contactData(true);
    }
    
    
    @isTest
    static void caseTriggerHandler_errorPath(){
        
        List<Contact> listOfContact = TestDataFactory.contactData(false);
        insert listOfContact;
        Survey_Settings__c setting = new Survey_Settings__c();
        setting.Enable_Surveys__c = true;
        setting.Survey_Feedback_Owner__c = 'ra@ra.com';
        insert setting;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
        Case caseEach = new Case(
            AccountId = acc.Id,
            Status = 'Closed',
            Issue_with__c = 'Client',
            Type = 'Staffing',
            Reason = 'Issue Resolved'
        );
        insert caseEach;
        } catch (exception e){
            
        }
        
    }
    
    @isTest
    static void caseTriggerHandler_errorPath1(){
        List<Contact> listOfContact = TestDataFactory.contactData(false);
        insert listOfContact;
        listOfContact[0].Default_Days_Survey__c = null;
        update listOfContact;
        Survey_Settings__c setting = new Survey_Settings__c();
        setting.Enable_Surveys__c = true;
        setting.Survey_Feedback_Owner__c = 'ra@ra.com';
        insert setting;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
        Case caseEach = new Case(
            AccountId = acc.Id,
            Status = 'Closed',
            Issue_with__c = 'Client',
            Type = 'Staffing',
            Reason = 'Issue Resolved',
            ContactId = listOfContact[0].Id
        );
        insert caseEach;
        } catch (exception e){
            
        }
    }
    
    @isTest
    static void caseTriggerHandler_insertHappyPath(){
        
        List<Contact> listOfContact = TestDataFactory.contactData(false);
        insert listOfContact;
        Survey_Settings__c setting = new Survey_Settings__c();
        setting.Enable_Surveys__c = true;
        setting.Survey_Feedback_Owner__c = 'ra@ra.com';
        insert setting;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
        Case caseEach = new Case(
            AccountId = acc.Id,
            Status = 'Closed',
            Issue_with__c = 'Client',
            Type = 'Staffing',
            Reason = 'Issue Resolved',
            ContactId = listOfContact[0].Id
        );
        insert caseEach;
        } catch (exception e){
            
        }
        
    }
    
    @isTest
    static void caseTriggerHandler_insertHappyPath_1(){
        
        List<Contact> listOfContact = TestDataFactory.contactData(false);
        insert listOfContact;
        listOfContact[0].Survey_Last_sent_on__c = date.today() - 60;
        update listOfContact;
        Survey_Settings__c setting = new Survey_Settings__c();
        setting.Enable_Surveys__c = true;
        setting.Survey_Feedback_Owner__c = 'ra@ra.com';
        insert setting;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
        Case caseEach = new Case(
            AccountId = acc.Id,
            Status = 'Closed',
            Issue_with__c = 'Client',
            Type = 'Staffing',
            Reason = 'Issue Resolved',
            ContactId = listOfContact[0].Id
        );
        insert caseEach;
        } catch (exception e){
            
        }
        
    }
    
    @isTest
    static void caseTriggerHandler_insertHappyPath_2(){
        
        List<Contact> listOfContact = TestDataFactory.contactData(false);
        insert listOfContact;
        listOfContact[0].Survey_Last_sent_on__c = date.today() - 60;
        update listOfContact;
        Survey_Settings__c setting = new Survey_Settings__c();
        setting.Enable_Surveys__c = false;
        setting.Survey_Feedback_Owner__c = 'ra@ra.com';
        insert setting;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
        Case caseEach = new Case(
            AccountId = acc.Id,
            Status = 'Closed',
            Issue_with__c = 'Client',
            Type = 'Staffing',
            Reason = 'Issue Resolved',
            ContactId = listOfContact[0].Id
        );
        insert caseEach;
        } catch (exception e){
            
        }
        
    }
    
    @isTest
    static void caseTriggerHandler_updateHappyPath_1(){
        
        List<Contact> listOfContact = TestDataFactory.contactData(false);
        insert listOfContact;
        listOfContact[0].Survey_Last_sent_on__c = date.today() - 60;
        update listOfContact;
        Survey_Settings__c setting = new Survey_Settings__c();
        setting.Enable_Surveys__c = true;
        setting.Survey_Feedback_Owner__c = 'ra@ra.com';
        insert setting;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        try{
        Case caseEach = new Case(
            AccountId = acc.Id,
            Status = 'Open',
            Issue_with__c = 'Client',
            Type = 'Staffing',
            Reason = 'Issue Resolved',
            ContactId = listOfContact[0].Id
        );
        insert caseEach;
            caseEach.Status = 'Closed';
            update caseEach;
        } catch (exception e){
            
        }
        
    }
    
    @isTest
    static void caseTriggerHandler_insertHappyPath1(){
        LeadTriggerHandlerTest.isTestFailInsert = true; 
        List<Case> caseList = new List<Case>();
        try{
            List<Contact> listOfContact =TestDataFactory.contactData(false);
            for(contact eachContact : listOfContact){
                eachContact.Survey_Last_sent_on__c = date.today() - 13;
            }
            insert listOfContact;
            
            caseList = TestDataFactory.caseTestData(false);
            //insert caseList;
            for(Case eachcase: caseList){
                eachcase.Status = 'Closed'; 
                eachcase.Reason = 'Issue Resolved';
                
            }
            insert caseList; 
            for(Case eachcase: caseList){
                eachcase.status = 'true';
                eachcase.Survey_Last_sent_on__c = date.today();   
              
            }
            System.assertEquals(1, [SELECT count() FROM case WHERE ContactId =: caseList[0].ContactId]);
            
        }catch(Exception e){
            system.debug('Exception is '+e.getMessage());
        }
        
    }
    @isTest
    static void caseTriggerHandler_UpdateHappyPath(){
        LeadTriggerHandlerTest.isTestFailInsert = true;  
        try{
            List<Contact> listOfContact =TestDataFactory.contactData(true);
            List<Account> listOfAccount = TestDataFactory.accountTestData(true);
            List<Case> caseList = TestDataFactory.caseTestData(true);
            for(case eachCase : caseList){
                eachCase.Send_Survey_Email__c = false;
                eachcase.Status = 'Closed'; 
                eachcase.Reason = 'Issue Resolved';
                eachCase.AccountId = listOfAccount[0].Id;
            }        
            update caseList;
            System.assertEquals(1, [SELECT count() FROM case WHERE ContactId =: caseList[0].ContactId]);
        }catch(Exception e){
            system.debug('Exception is '+e.getMessage());
        }
    }
}