trigger trgContactCounter on Contact (after insert, after delete,after undelete,after update, before insert, before update) { 
    
   // Set<Id> aId = new Set<Id>(); 
    
    if(trigger.isBefore && trigger.isInsert){
        ContactTriggerHandler contactTriggerHandler = new ContactTriggerHandler();
        ContactTriggerHandler.fillUpDefaultSurveyDays(trigger.new, new Map<Id, contact>());
    }
    if(trigger.isBefore && trigger.isUpdate){
        ContactTriggerHandler contactTriggerHandler = new ContactTriggerHandler();
        ContactTriggerHandler.fillUpDefaultSurveyDays(trigger.new, trigger.oldMap);
    }

/*
    if(Trigger.isInsert || Trigger.isUndelete){ 
        for(Contact opp : Trigger.New){ 
            aId.add(opp.AccountId); 
        } 
        List<Account> acc = [select id,NumberOfEmployees from Account where Id in:aId]; 
        List<Contact> con = [select id from contact where AccountId in :aId]; 
        
        for(Account a : acc){ 
            a.NumberOfEmployees=con.size(); 
            
        }update acc; 
    } 
    
    if(Trigger.isDelete){ 
        for(Contact opp : Trigger.old){ 
            aId.add(opp.AccountId); 
        } 
        List<Account> acc = [select id,NumberOfEmployees from Account where Id in:aId]; 
        List<Contact> con = [select id from contact where AccountId in :aId]; 
        
        for(Account a : acc){ 
            a.NumberOfEmployees=con.size(); 
            
        }update acc; 
    } 
    
    if(Trigger.isUpdate){ 
        Set<Id> OldAId = new Set<Id>(); 
        for(Contact opp : Trigger.new){ 
            if(opp.AccountId != Trigger.oldMap.get(opp.id).AccountId) 
                aId.add(opp.AccountId); 
            OldAId.add(Trigger.oldMap.get(opp.id).AccountId); 
            
        } 
        if(!aId.isEmpty()){ 
            //for new Accounts 
            List<Account> acc = [select id,NumberOfEmployees from Account where Id in:aId]; 
            //For New Account Contacts 
            List<Contact> con = [select id from contact where AccountId in :aId]; 
            
            
This is For Old Contacts Count 
*/ 
            
            //for Old Accounts 
            /*List<Account> Oldacc = [select id,NumberOfEmployees from Account where Id in:OldAId]; 
            
            //For Old Account Contacts 
            List<Contact> OldCon = [select id from contact where AccountId in :OldAId]; 
            
            //For New Accounts 
            for(Account a : acc){ 
                a.NumberOfEmployees=con.size(); 
                
                
            }update acc; 
            
            //For Old Accounts 
            for(Account a : Oldacc){ 
                a.NumberOfEmployees=OldCon.size(); 
                
            }update Oldacc; 
        } 
    } */
}