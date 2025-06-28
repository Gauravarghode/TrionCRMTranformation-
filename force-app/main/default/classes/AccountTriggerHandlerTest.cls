/*
 * Author: Rahul Nomula (EA)
 */

@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    static void accountTriggerHandler_InsertHappyPath(){
        List<Contact> contactTestData = TestDataFactory.contactTestData2(true);
        List<Account> listOfAccounts = TestDataFactory.accountTestData1(false, contactTestData[0].Id );
        for(Account eachAcc: listOfAccounts){
            eachAcc.Send_Survey_Again__c = true;
        }
   
        insert listOfAccounts;
    }
    
    @isTest
    static void accountTriggerHandler_UpdateHappyPath(){
        
        List<Contact> contactTestData = TestDataFactory.contactTestData2(true);
        List<Account> listOfAccounts = TestDataFactory.accountTestData1(false, contactTestData[0].Id );
        //List<Account> listOfAccounts = TestDataFactory.accountTestData(false);
        insert listOfAccounts;
        
        for(account eachAccount : listOfAccounts){
            eachAccount.Send_Survey_Again__c = true;
        }
      
        update listOfAccounts;
    }
}