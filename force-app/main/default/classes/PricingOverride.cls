public class PricingOverride{
    
    private final Proposal__c proposal;
    
    public Proposal__c objProposal {get;set;}
    public List<SelectOption> users {get;set;}
    public List<string> selectedUsers {get;set;} 
    public string notes {get;set;}
    
    public PricingOverride(ApexPages.StandardController stdController){
        this.proposal = (Proposal__c)stdController.getRecord();
        this.selectedUsers = new List<string>();
        
        objProposal = new Proposal__c();
        for(Proposal__c p : [Select Id,Name, Opportunity__c,Opportunity__r.Name,Price_Override_Status__c, Pricing_Matrix__c From Proposal__c Where Id =: this.proposal.Id ]){
            objProposal = p;
        }
        
        users = new List<SelectOption>();
        for(Pricing_Approver__c pa: [Select Id,  User__c , User__r.Name, User__r.Email FROM Pricing_Approver__c 
               WHERE User__c != null AND Pricing_Matrix__c =: objProposal.Pricing_Matrix__c AND Status__c = 'Active' AND  Role__c = 'Approver' Order By User__r.Name]){
            users.add(new SelectOption(pa.User__c,pa.User__r.Name));
        }
        
    }
    
    public pageReference doSave(){
        pageReference pr = null;
        try{
            
            if(selectedUsers == null || selectedUsers.size() == 0){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Please select atleast one Approver'));
            }
            
            List<Approval_Request__c> listAppReq = new List<Approval_Request__c>();
            
            Id OwnerId = null;
            for(Group q : [Select Id From Group Where Name = 'Pricing Manager' limit 1]){
                OwnerId = q.Id;
            }
            
            
  
            for(User u : [Select Id,Name,Email,FirstName From User WHere Id IN: selectedUsers]){
                
                Approval_Request__c ar = new Approval_Request__c();
                ar.Approval_Request__c = 'Pricing Override';
                ar.Opportunity__c = objProposal.Opportunity__c;
                ar.Proposal__c = objProposal.Id;
                ar.Submitted_By__c = u.Name;
                ar.Submitted_By_User__c = u.Id;
                ar.Submitted_On__c = system.now();
                ar.OwnerId = OwnerId;
                ar.Submitter_Notes__c = notes;
                listAppReq.add(ar);
                                 
            }
            
            
            if(listAppReq.size() > 0){
                insert listAppReq;
                
                objProposal.Price_Override_Status__c = 'Requested';
                update objProposal;
                
                // Send Emails
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                 
                for(Approval_Request__c  ar: [Select id,Submitted_By_User__c,Submitted_By_User__r.Name,Submitted_By_User__r.Email, Submitted_By_User__r.FirstName  From Approval_Request__c Where Id IN: listAppReq]){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    sendTo.add(ar.Submitted_By_User__r.Email);
                    mail.setToAddresses(sendTo);
                    
                    mail.setSubject(Label.PricingOverrideApprovalEmailSubject  + ' <~' + ar.Id + '~>' );
                    
                      String body = 'Dear ' + ar.Submitted_By_User__r.FirstName + ',<br/><br/>';
                      body += 'Pricing Override Approval Request for Proposal: ' +  objProposal.Name + ' - ' + objProposal.Opportunity__r.Name + '<br/><br/>';
                      body += 'Please click <a href="' + Label.PricingOverrideApprovalSiteURL + '?UserId=' + ar.Submitted_By_User__c + '&ProposalId=' + objProposal.Id + '&ApprovalRequestId=' + ar.Id + '">here</a> or reply this email with keyword Approved or Rejected <br/><br/>';
                      body += 'Thanks '; 
                      mail.setHtmlBody(body);
                    
                    mail.setReplyTo(Label.PricingOverrideInboundEmailAddress);
                    mails.add(mail);  
                    
                }
                 
                Messaging.sendEmail(mails);
            }
            
            pr = new PageReference('/' + objProposal.Id);
        }
        catch(Exception ex){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,ex.getMessage()));
        }
        return pr;
    }
    
}