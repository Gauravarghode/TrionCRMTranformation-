/*********************************************************************************
* Name: TestBatchContactsCounter
* Created by SevenPoints {DateCreated 9/2/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This  is used as test class for batch apex BatchContactsCounter
----------------------------------------------------------------------------------
* Unit Test: TestBatchContactsCounter
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 SevenPoints 9/2/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

@isTest 
private class TestBatchContactsCounter { 

    static testMethod void myUnitTest() { 
        // create account
        Account a = new Account(); 
        a.Name = 'test'; 
        insert a; 
        
        // create contact
        Contact c = new Contact(); 
        c.LastName = 'Test1'; 
        c.AccountId = a.Id; 
        insert c; 

        Database.executeBatch(new BatchContactsCounter(), 10 ); 
    } 

    static testMethod void myUnitTest2() { 
        // create account
        Account a = new Account(); 
        a.Name = 'test'; 
        insert a; 
        
        // create contact
        Contact c = new Contact(); 
        c.LastName = 'Test1'; 
        c.AccountId = a.Id; 
        insert c; 
        
        // create contact2
        Contact c2 = new Contact(); 
        c2.LastName = 'Test1'; 
        c2.AccountId = a.Id; 
        insert c2; 
        
        Database.executeBatch(new BatchContactsCounter(), 10 ); 
    } 
}