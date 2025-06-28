@isTest 
private class TestBatchUnreadEmails { 

public static testmethod void DoTest(){ 

Test.startTest(); 

Account a = new Account(); 

a.Name = 'test'; 

insert a; 

Case c = new Case(); 

c.Subject = 'test'; 
c.AccountId = a.Id; 
c.Status = 'New'; 

insert c; 

BatchUnreadEmails batchObj = new BatchUnreadEmails(); 

ID batchprocessid = Database.executeBatch(batchObj ); 

Test.stopTest(); 
} 
}