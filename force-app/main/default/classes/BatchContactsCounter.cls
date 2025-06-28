/*********************************************************************************
* Name: BatchContactsCounter
* Created by SevenPoints {DateCreated 9/2/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This  is used as batch apex jobs to calculate contacts on account
----------------------------------------------------------------------------------
* Unit Test: TestBatchContactsCounter
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 SevenPoints 9/2/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/
 
global without sharing class BatchContactsCounter 
    implements Database.Batchable<sObject>, Schedulable{ 
    
    global void execute(SchedulableContext SC) {
         Database.executeBatch(new BatchContactsCounter(), 10 );
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        if(Test.isRunningTest() ){
             return Database.getQueryLocator([Select Id, NumberOfEmployees From Account limit 1 ]);
        }
        return Database.getQueryLocator([Select Id, NumberOfEmployees From Account  ]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            
            List<Account> listAccount = new List<Account>();
            
            for(Account acc : (List<Account>)scope){
                
                integer onCount = [select count() from contact where AccountId =: acc.id]; 
                
                acc.NumberOfEmployees = onCount;
                
                listAccount.add(acc); 
            }
            
            database.update(listAccount, false);
            
        }catch(Exception e){
            System.debug('================= EXCEPTION : '+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    /*************************************************************************************
    // SCHEDULED TO EXECUTE HOURLY
    System.schedule('BatchContactsCounter', '0 0 1 * * ?', new BatchContactsCounter());
    *************************************************************************************/ 
}