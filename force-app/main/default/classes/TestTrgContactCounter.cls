@isTest 
private class TestTrgContactCounter { 

static testMethod void myUnitTest() { 
Account a = new Account(); 
a.Name = 'test'; 
insert a; 

Contact c = new Contact(); 
c.LastName = 'Test1'; 
c.AccountId = a.Id; 
insert c; 

a.NumberOfEmployees= 5; 
update a; 
} 

static testMethod void myUnitTest2() { 
Account a = new Account(); 
a.Name = 'test'; 
insert a; 

Contact c = new Contact(); 
c.LastName = 'Test1'; 
c.AccountId = a.Id; 
insert c; 

delete c; 
a.NumberOfEmployees= 4; 
update a; 
} 

static testMethod void myUnitTest3() { 
Account a = new Account(); 
a.Name = 'test'; 
insert a; 

Account ac = new Account(); 
ac.Name = 'test'; 
insert ac; 

Contact c = new Contact(); 
c.LastName = 'Test1'; 
c.AccountId = a.Id;  
insert c; 

a.NumberOfEmployees= 2; 
update c; 

c.AccountId = ac.Id; 
update c; 
} 
}