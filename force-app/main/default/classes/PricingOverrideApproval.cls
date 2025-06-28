public without sharing class PricingOverrideApproval{
    
    public string Notes {get;set;}
    public boolean hideForm {get;set;}
    public string ProposalId {get;set;}
    public string ApprovalRequestId {get;set;}
    public string UserId {get;set;}
  
    
    public PricingOverrideApproval(){
        
        if(ApexPages.currentPage().getParameters().get('ProposalId') != null){
            ProposalId = ApexPages.currentPage().getParameters().get('ProposalId');
        }
        if(ApexPages.currentPage().getParameters().get('ApprovalRequestId') != null){
            ApprovalRequestId = ApexPages.currentPage().getParameters().get('ApprovalRequestId');
        }
        if(ApexPages.currentPage().getParameters().get('UserId') != null){
            UserId = ApexPages.currentPage().getParameters().get('UserId');
        }
    }
    
    public pageReference doApprove(){
        
        try{
            
            User usr = [Select Id,Name From User Where Id =: UserId limit 1];
            
            for(Proposal__c p : [Select Id, Price_Override_Status__c,Price_Override_By__c,Price_Override_Decision_Date__c 
                                From Proposal__c Where Id =: ProposalId ]){
                p.Price_Override_Status__c = 'Approved';
                p.Price_Override_Decision_Notes__c = Notes;
                p.Price_Override_By__c = usr.Name;
                p.Price_Override_Decision_Date__c = system.now();
                
                update p; 
            }
            
            for(Approval_Request__c ar : [Select Id, Comments__c,Approval_Decision__c,Approved_By__c,Approved_On__c 
                                        From Approval_Request__c Where Id =: ApprovalRequestId ]){
                ar.Approval_Decision__c = 'Approved';
                ar.Comments__c = Notes;
                ar.Approved_By__c = usr.Name;
                ar.Approved_On__c = system.now();
                
                update ar; 
            }
            
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Your action has been submitted. Thank you!'));
            hideForm = true;
        }
        catch(Exception ex){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,ex.getMessage()));
        }
        return null;
    }
    
    public pageReference doReject(){
        
        try{
             
            if(Notes == null || Notes == ''){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Please enter comments'));
                return null;
            }
            
            User usr = [Select Id,Name From User Where Id =: UserId limit 1];
            
            for(Proposal__c p : [Select Id, Price_Override_Status__c,Price_Override_By__c,Price_Override_Decision_Date__c 
                                From Proposal__c Where Id =: ProposalId ]){
                p.Price_Override_Status__c = 'Denied';
                p.Price_Override_Decision_Notes__c = Notes;
                p.Price_Override_By__c = usr.Name;
                p.Price_Override_Decision_Date__c = system.now();
                
                update p; 
            }
            
            for(Approval_Request__c ar : [Select Id, Comments__c,Approval_Decision__c,Approved_By__c,Approved_On__c 
                                        From Approval_Request__c Where Id =: ApprovalRequestId ]){
                ar.Approval_Decision__c = 'Denied';
                ar.Comments__c = Notes;
                ar.Approved_By__c = usr.Name;
                ar.Approved_On__c = system.now();
                ar.Decline_Reason__c = 'Other';
                update ar; 
            }
            
            
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Your action has been submitted. Thank you!'));
            hideForm = true;
        }
        catch(Exception ex){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,ex.getMessage()));
        }
        return null;
    }
}