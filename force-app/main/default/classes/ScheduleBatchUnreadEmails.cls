global class ScheduleBatchUnreadEmails implements Schedulable { 

global void execute(SchedulableContext context) { 

// call batch apex 

BatchUnreadEmails batchObj = new BatchUnreadEmails(); 

ID batchprocessid = Database.executeBatch(batchObj ); 

} 

} 

/* 
//******************************************* 
//Script to Schedule jobs for every 15 minutes 
//-------------------------------------------- 

ScheduleBatchUnreadEmails p1 = new ScheduleBatchUnreadEmails(); 
String sch1 ='0 0 * * * ? *'; 
system.schedule('ScheduleBatchUnreadEmails1', sch1, p1); 

ScheduleBatchUnreadEmails p2 = new ScheduleBatchUnreadEmails(); 
String sch2 ='0 15 * * * ? *'; 
system.schedule('ScheduleBatchUnreadEmails2', sch2, p2); 

ScheduleBatchUnreadEmails p3 = new ScheduleBatchUnreadEmails(); 
String sch3 ='0 30 * * * ? *'; 
system.schedule('ScheduleBatchUnreadEmails3', sch3, p3); 

ScheduleBatchUnreadEmails p4 = new ScheduleBatchUnreadEmails(); 
String sch4 ='0 45 * * * ? *'; 
system.schedule('ScheduleBatchUnreadEmails4', sch4, p4); 

//******************************************** 
*/