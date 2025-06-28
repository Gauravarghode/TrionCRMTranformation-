@isTest
public class TestFactoryClass {
    Public Static List<Case>  createCases(){
        try{
            // Set up test data
            User testUser = [SELECT Id FROM User WHERE UserType = 'Standard' LIMIT 1];
            
            // Define test variables
            String subject = 'Test Case Subject';
            String description = 'This is a test case description.';
            Id ownerId = testUser.Id;
            String emailBody = 'This is the body of the email.';
            String attachmentName = 'testAttachment.txt';
            Blob attachmentBody = Blob.valueOf('This is the content of the attachment.');
            List<Case> caseList = new List<Case>();
            for(Integer i=0;i<10;i++){
                Case newCase = new Case(Subject = subject,Description = description,OwnerId = ownerId);
                caseList.add(newCase);
            }
            
            insert caseList;
            return caseList;
        }catch(Exception e){
            return new List<Case>();
        }
    }
    Public static void sendEmailsWithAttachments(List<Case> caseList) {
        // List to hold the email messages
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailMessage = new List<EmailMessage>();
        List<Attachment> attList = new List<Attachment>();
        List < sObject > ls = Test.loadData(Case.sObjectType, 'Test0041933'); 
        Case c = (Case) ls[0]; 
        // Iterate over the cases and prepare the email messages
        for (Case caseRecord : caseList) {
           EmailMessage createWhatEmail = new EmailMessage(
                 Subject                = 'test'
                ,Status                 = '3'
                ,ToAddress              = 'Test@gmail.com'
                ,FromAddress            = UserInfo.getUserEmail()
                ,FromName               = UserInfo.getFirstName()+' - '+UserInfo.getLastName()
                ,HtmlBody               = 'a body'
                ,Incoming               = false
                ,MessageDate            = DateTime.now(),
               ParentId = c.Id
            );
            emailMessage.add(createWhatEmail);
       
        }
        insert emailMessage;
         Map<Id,EmailMessage> emailMessageMap = new  Map<Id,EmailMessage>();
        for(EmailMessage emObj : emailMessage){
            emailMessageMap.put(emObj.ParentId,emObj);
        }
        system.debug('emailMessage'+emailMessage);
        for(Case caseRecord : caseList){
            if(emailMessageMap.ContainsKey(caseRecord.Id)){
                  Attachment testAttachment = new Attachment(
                    ParentId = String.ValueOf(emailMessageMap.get(c.Id).Id),
                    Name = 'Test Attachment 2.txt',
                    Body = Blob.valueOf('Test attachment content'),
                    ContentType = 'text/plain'
                );
                attList.add(testAttachment);
            }
          
        }
        insert attList;
        List<EmailMessageHtml__c> emailMessageHtml = new List<EmailMessageHtml__c>();
        for(emailMessage emObj : emailMessage){
             EmailMessageHtml__c emItem = new EmailMessageHtml__c();
                emItem.EmailMessage_Id__c = emObj.Id;
                emItem.Status__c = 'Completed';
                emItem.Is_Large_File__c = 'No';
                emItem.Name = emObj.Subject;
                emItem.sObject__c = 'EmailMessage';
                emItem.Parent_Case_Id__c = emObj.ParentId;
                emItem.File_Size__c = 2000;
                emailMessageHtml.add(emItem);
        }
        insert emailMessageHtml;
    }
    
}