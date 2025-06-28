global class BatchUnreadEmails implements Database.Batchable<SObject>, Database.AllowsCallouts{ 

global database.Querylocator start(Database.BatchableContext BC){ 

DateTime dt = system.now().addMonths(-3); 

if(Test.isRunningTest()){ 

return Database.getQueryLocator([Select Id,Unread_Emails__c,(Select Id, ParentId, Status From EmailMessages Where Status = '0') From Case limit 1]);
} 

return Database.getQueryLocator([Select Id,Unread_Emails__c,(Select Id, ParentId, Status From EmailMessages Where Status = '0') From Case 
Where IsClosed = false AND LastModifiedDate >=: dt Order By LastModifiedDate ASC]); 
} 


global void execute(Database.BatchableContext BC,Sobject[] scope){ 

//try{ 

List<Case> listCase = new List<Case>(); 

for(sobject s : scope){ 

Case c = (Case)s; 

double dblUnread = c.EmailMessages.size(); 

if(c.Unread_Emails__c != dblUnread){ 

c.Unread_Emails__c = dblUnread; 

listCase.add(c); 
} 
} 


if(listCase.size() > 0){ 

database.update(listCase, false); 
} 

//} 
//catch(Exception ex){ 
// system.debug(ex.getMessage()); 
//} 

} 

global void finish(Database.BatchableContext BC){ 

} 
}