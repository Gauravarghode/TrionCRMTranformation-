global class PricingOverrideEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelop){
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String emailFrom = email.fromName;
        String emailBody = email.htmlBody;
        String emailSubject = email.Subject;
        
        string arId = emailSubject.substringBetween('<~', '~>'); 
        
        if(emailBody.containsIgnoreCase('Approved') || emailBody.containsIgnoreCase('Approve')){
            
            for(Approval_Request__c ar : [Select Id, Proposal__c, Submitted_By_User__c,Submitted_By_User__r.Name, Comments__c,Approval_Decision__c,Approved_By__c,Approved_On__c 
                                        From Approval_Request__c Where Id =: arId limit 1]){
                ar.Approval_Decision__c = 'Approved'; 
                ar.Approved_By__c = ar.Submitted_By_User__r.Name;
                ar.Approved_On__c = system.now();
                
                update ar; 
                
                for(Proposal__c p : [Select Id, Price_Override_Status__c,Price_Override_By__c,Price_Override_Decision_Date__c 
                                From Proposal__c Where Id =: ar.Proposal__c limit 1]){
                    p.Price_Override_Status__c = 'Approved'; 
                    p.Price_Override_By__c = ar.Submitted_By_User__r.Name;
                    p.Price_Override_Decision_Date__c = system.now();
                    
                    update p; 
                }
            }
        }
        else if(emailBody.containsIgnoreCase('Rejected') || emailBody.containsIgnoreCase('Reject')){
            
            for(Approval_Request__c ar : [Select Id, Proposal__c, Submitted_By_User__c,Submitted_By_User__r.Name, Comments__c,Approval_Decision__c,Approved_By__c,Approved_On__c 
                                        From Approval_Request__c Where Id =: arId limit 1]){
                ar.Approval_Decision__c = 'Denied'; 
                ar.Approved_By__c = ar.Submitted_By_User__r.Name;
                ar.Approved_On__c = system.now();
                ar.Decline_Reason__c = 'Other';
                ar.Comments__c = 'Denied';
                update ar; 
                
                for(Proposal__c p : [Select Id, Price_Override_Status__c,Price_Override_By__c,Price_Override_Decision_Date__c 
                                From Proposal__c Where Id =: ar.Proposal__c limit 1]){
                    p.Price_Override_Status__c = 'Denied'; 
                    p.Price_Override_By__c = ar.Submitted_By_User__r.Name;
                    p.Price_Override_Decision_Date__c = system.now();
                    
                    update p; 
                }
            }
        }
        
        return null;
        
    }
}