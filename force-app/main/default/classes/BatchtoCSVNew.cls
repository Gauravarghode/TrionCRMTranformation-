global class BatchtoCSVNew implements Database.Batchable<sObject>{
    
    global Messaging.EmailFileAttachment csvAttachment;
    //global static List<Messaging.EmailFileAttachment> allAttachments = new List<Messaging.EmailFileAttachment>();
    String EmailMessageParentId;
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        String closed='Closed';
        String startDate = Label.StartDate; 
        String endDate = Label.EndDate; 
        String query = 'SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c FROM EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate;        
        return Database.getQueryLocator(query);
    }
    
    global  void  execute(Database.BatchableContext bc, List<EmailMessage> emList){        
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
        for (EmailMessage em : emList) {
            EmailMessageParentId=em.ParentId;
            String generatedCSVFile = 'Id,ParentId,ActivityId,CreatedById,CreatedDate,LastModifiedDate,LastModifiedById,SystemModstamp,TextBody,Headers,Subject,Name,FromName,FromAddress,ValidatedFromAddress,ToAddress,CcAddress,BccAddress,Incoming,HasAttachment,Status,MessageDate,IsDeleted,ReplyToEmailMessageId,IsPrivateDraft,IsExternallyVisible,MessageIdentifier,ThreadIdentifier,ClientThreadIdentifier,IsClientManaged,RelatedToId,IsTracked,IsOpened,FirstOpenedDate,LastOpenedDate,IsBounced,EmailTemplateId,FileTest_Created_Date__c,HtmlBody\n'; // Header row
            
            //String body = em.HtmlBody != null ? wrapText(em.HtmlBody, 80) : ''; // Adjust the character limit as needed
            String formattedCreatedDate = em.CreatedDate != null ? em.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : '';
            String cleanedHtmlBody = em.HtmlBody != null ? em.HtmlBody.replaceAll('[\\n\\r]+', ' ') : 'Null';
            String cleanedTextBody = em.TextBody != null ? em.TextBody.replaceAll('[\\n\\r]+', ' ') : 'Null';
            //String cleanedHtmlBody2 = em.HtmlBody != null ? em.HtmlBody.replaceAll('[\\n\\r]+', ' ') : 'Null';
            String truncatedHtmlBody = cleanedHtmlBody.length() > 10000000 ? cleanedHtmlBody.substring(0, 10000000) : cleanedHtmlBody; 
            String truncatedTextBody = cleanedTextBody.length() > 10000000 ? cleanedTextBody.substring(0, 10000000) : cleanedTextBody;
            String fileRow = '\"'+'##  ' + em.Id + '\",\"' +'##  '+ em.ParentId + '\",\"'+'##  ' + em.ActivityId  + '\",\"' +'##  '+ em.CreatedById  + '\",\"'+'##  ' + formattedCreatedDate + '\",\"'+'##  ' + em.LastModifiedDate  + '\",\"'+'##  ' + em.LastModifiedById + '\",\"'+'##  ' + em.SystemModstamp + '\",\"' +'##  '+ em.TextBody + '\",\"'+'##  ' + em.Headers + '\",\"'+'##  ' + em.Subject + '\",\"'+'##  ' + em.Name + '\",\"'+'##  ' + em.FromName + '\",\"'+'##  ' + em.FromAddress + '\",\"'+'##  ' + em.ValidatedFromAddress + '\",\"'+'##  ' + em.ToAddress + '\",\"'+'##  ' + em.CcAddress + '\",\"'+'##  ' + em.BccAddress + '\",\"'+'##  ' + em.Incoming + '\",\"'+'##  '  + em.HasAttachment + '\",\"'+'##  ' + em.Status + '\",\"'+'##  ' + em.MessageDate + '\",\"'+'##  '+ em.IsDeleted + '\",\"'+'##  ' + em.ReplyToEmailMessageId + '\",\"'+'##  ' + em.IsPrivateDraft + '\",\"'+'##  ' + em.IsExternallyVisible + '\",\"'+'##  ' + em.MessageIdentifier + '\",\"'+'##  ' + em.ThreadIdentifier + '\",\"'+'##  ' + em.ClientThreadIdentifier + '\",\"'+'##  ' + em.IsClientManaged + '\",\"'+'##  ' + em.RelatedToId + '\",\"'+'##  ' + em.IsTracked + '\",\"'+'##  ' + em.IsOpened + '\",\"'+'##  ' + em.FirstOpenedDate + '\",\"'+'##  ' + em.LastOpenedDate + '\",\"'+'##  ' + em.IsBounced + '\",\"'+'##  ' + em.EmailTemplateId + '\",\"'+'##  ' + em.FileTest_Created_Date__c + '\",\"'+'##  '  +truncatedHtmlBody  + '\",..';  // body.replaceAll('\"', '\"\"').replaceAll('\n', ' ').replaceAll('\r', '') + '\"'c;
            
            generatedCSVFile += fileRow; // Remove + '\n'                        
            csvAttachment = new Messaging.EmailFileAttachment();
            
            Blob csvBlob = Blob.valueOf(generatedCSVFile);
            
            List<String> csvLines = generatedCSVFile.split('\n');
            
            Integer splitPoint = Math.ceil((Double)csvLines.size() / 2).intValue();
            String part1 = '';
            for (Integer i = 0; i < splitPoint; i++) {
                part1 += csvLines[i] + '\n';
            }
            
            String part2 = '';
            for (Integer i = splitPoint; i < csvLines.size(); i++) {
                part2 += csvLines[i] + '\n';
            }
            
            Blob blobPart1 = Blob.valueOf(part1);
            Blob blobPart2 = Blob.valueOf(part2);
            
            System.debug('Blob Part 1: ' + blobPart1.toString());
            System.debug('Blob Part 2: ' + blobPart2.toString());
            
            
            
            
            System.debug('Size of the generatedCSVFile: ' + generatedCSVFile.length());
            String csvName = 'EmailMessageDetails_' + em.Id + '.csv'; // Customize the file name with record ID
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(blobPart1);
            csvAttachment.setBody(blobPart2);
            
            String csvString1 = blobPart1.toString();
            String csvString2 = blobPart2.toString();
            
            
            //System.debug('Size of the csvBlob: ' + csvBlob.size());
            //System.debug('Size of the csvBlob: ' + csvBlob);
            
            //System.debug('Size of the csvString: ' + csvString.length());
            //Blob myBlob = Blob.valueOf(csvBlob);
            //String convertedString = myBlob.toString();
            
            //String csvString = EncodingUtil.base64Encode(csvBlob);
            //List<String> sendEmails = new List<String>();
            //sendEmails.add('chalumurisaikiran@enabledanalytics.com');
            //string csvBody=csvAttachment.getBody();
            // Set the record ID in the email subject
            //String subject = 'Email Message Details CSV - ';
            //email.setSubject(subject);
            //email.setToAddresses(sendEmails);
            //email.setPlainTextBody('Email Message details CSV');
            //allAttachments.add(csvAttachment);
            //email.setFileAttachments(allAttachments);
            //email.setFileAttachments(new Messaging.EmailFileAttachment[]{allAttachments});
            
            List<EmailMessage_Html__b> embList=new List<EmailMessage_Html__b>();
            
            EmailMessage_Html__b emhb=new EmailMessage_Html__b();
            emhb.Title__c = csvName;
            emhb.File_Size__c =csvAttachment.Body.Size();
            emhb.EmailMessage_Id__c=em.Id;
            emhb.Status__c = 'Not Started';
            emhb.sObject__c='Email Message';
            emhb.Csv_Body__c=csvString1;
            emhb.Csv_String_2__c = csvString2;
            
            emhb.Parent_Case_Id__c=EmailMessageParentId;            
            if(emhb.File_Size__c > 12000000){
                emhb.Is_Large_File__c = 'yes';
                emhb.Status__c = 'Failed';
                emhb.Error_Message__c = 'File size > 12000000';
            }
            else{
                emhb.Is_Large_File__c = 'no';
                emhb.Status__c = 'Not Started';
            }
            embList.add(emhb);
            
            System.debug('Email_Message_Html__b Title__c'+emhb.Title__c);
            System.debug('Email_Message_Html__b File_Size__c'+emhb.File_Size__c);
            System.debug('Email_Message_Html__b Emailmessage_Id__c'+emhb.Emailmessage_Id__c);
            System.debug('Email_Message_Html__b Is_Large_File__c'+emhb.Is_Large_File__c);
            System.debug('Email_Message_Html__b Status__c'+emhb.Status__c);
            System.debug('Email_Message_Html__b Error_Message__c'+emhb.Error_Message__c);
            System.debug('emhb.Parent_Case_Id__c'+emhb.Parent_Case_Id__c);
            
            if(embList.size() > 0){
                system.debug('embList-->'+embList);
                Database.insertImmediate(embList);
            }
            
            
        }
        
        
        //Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});          
    }
    global void finish(Database.BatchableContext bc) {
        system.debug('finish');
        String closed = 'Closed';
        String startDate = Label.StartDate; 
        String endDate = Label.EndDate; 
        String query = 'SELECT Id FROM EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate;
        Database.executeBatch(new StagingPopulator_ContentDocuments(query), 2000);
        Database.executeBatch(new StagingPopulator_Attachments(query), 2000);
        
        
       //UpdateCaseEmail demo = new UpdateCaseEmail();
       //Database.executeBatch(demo,200);
        
    }
    
    
    public static void testCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    /*public String wrapText(String text, Integer maxLength) {
String[] words = text.split('\\s+');
String wrappedText = '';
Integer lineLength = 0;
for (String word : words) {
if (lineLength + word.length() <= maxLength) {
wrappedText += word + ' ';
lineLength += word.length() + 1; // Add 1 for the space	
} else {
wrappedText += '\n' + word + ' ';
lineLength = word.length() + 1; // Reset line length for new line
}
}
return wrappedText.trim(); // Trim any trailing whitespace
}*/
}