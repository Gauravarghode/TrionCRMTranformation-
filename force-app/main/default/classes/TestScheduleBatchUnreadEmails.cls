@isTest 
private class TestScheduleBatchUnreadEmails { 

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

ScheduleBatchUnreadEmails sch = new ScheduleBatchUnreadEmails(); 
String schFrequency = '0 0 * * * ?'; 
System.schedule('ScheduleBatchUnreadEmails', schFrequency, sch); 

Test.stopTest(); 
} 
}