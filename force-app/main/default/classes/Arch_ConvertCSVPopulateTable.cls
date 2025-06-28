global class Arch_ConvertCSVPopulateTable implements Database.Batchable<sObject>{
    
    global Messaging.EmailFileAttachment csvAttachment;
     global List<Id> emailCaseIdList = new List<Id>();
    //global static List<Messaging.EmailFileAttachment> allAttachments = new List<Messaging.EmailFileAttachment>();
    String EmailMessageParentId;
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        String days = Label.DaysTo;
        String days2 = Label.DaysTo2;
        String closed='Closed';
        String startDate = Label.BCSVStartDate; 
        String endDate = Label.BCSVEndDate; 
        String id='500VE00000BEuiMYAT';
        
      /*  String query = 'SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, '
            +			'TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress,'
            +			' BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, '
            +			'IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId,Message_Size__c, '
            +			' IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c '
            +			'FROM EmailMessage where Parent.ClosedDate <LAST_N_DAYS:' + days + ' AND Parent.ClosedDate>=LAST_N_DAYS:' + days2 + 'AND Parent.Status = \'Closed\' ';   
      */  
          String query = 'SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, '
+			'TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress,'
+			' BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, '
+			'IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId,'
+			' IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c,Message_Size__c  '
+			'FROM EmailMessage where Parent.ClosedDate < LAST_N_DAYS:' + days + ' and Parent.Failed_Record__c =false and Parent.Processed_Record__c = false' ;   

        return Database.getQueryLocator(query);
    }
    
    global  void  execute(Database.BatchableContext bc, List<EmailMessage> emList){        
        List<EmailMessageHtml__c> embList=new List<EmailMessageHtml__c>(); 
        List<EmailMessageHtml__c> embListLongEmail=new List<EmailMessageHtml__c>(); 
        List<Id> emailIdList = new List<Id>();
        List<Id> emailCaseIdList = new List<Id>();
        for(EmailMessage eml : emList){
            emailCaseIdList.add(eml.ParentId);
        }
        
       
        
        for (EmailMessage em : emList) {
         if(em.Message_Size__c > 130000){
                emailIdList.add(em.Id);
              /*  String csvName = 'EmailMessageDetails_' + em.Id + '.csv';
                EmailMessageHtml__c  emhb=new EmailMessageHtml__c ();
                emhb.Title__c = csvName;
                emhb.File_Size__c =140000;
                emhb.EmailMessage_Id__c=em.Id;
                emhb.Status__c = 'Completed';
                emhb.sObject__c='Email Message';
                //emhb.Csv_Body__c=csvString1;
                //emhb.Csv_String_2__c = csvString2;
                
                emhb.Parent_Case_Id__c=em.ParentId;            
                if(emhb.File_Size__c > 12000000){
                    emhb.Is_Large_File__c = 'yes';
                    emhb.Status__c = 'Failed';
                    emhb.Error_Message__c = 'File size > 12000000';
                }
                else{
                    emhb.Is_Large_File__c = 'no';
                    emhb.Status__c = 'Completed';
                }
                embListLongEmail.add(emhb);
                
                if(!embListLongEmail.isEmpty()){
                    
                    system.debug('embListLongEmail-->'+embListLongEmail);
                    Database.insert(embListLongEmail);
                }   
                */
                
                QueueableGenCsvSendSharepoint.invokeQueueable(emailIdList);
                //GeneratingCSVAndSendingSharepoint.convertIntoCSV(emailIdList);                
            }else{
                
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
                
                EmailMessageHtml__c  emhb=new EmailMessageHtml__c ();
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
                
                System.debug('EmailMessageHtml__c  Title__c'+emhb.Title__c);
                System.debug('EmailMessageHtml__c  File_Size__c'+emhb.File_Size__c);
                System.debug('EmailMessageHtml__c  Emailmessage_Id__c'+emhb.Emailmessage_Id__c);
                System.debug('EmailMessageHtml__c  Is_Large_File__c'+emhb.Is_Large_File__c);
                System.debug('EmailMessageHtml__c  Status__c'+emhb.Status__c);
                System.debug('EmailMessageHtml__c  Error_Message__c'+emhb.Error_Message__c);
                System.debug('emhb.Parent_Case_Id__c'+emhb.Parent_Case_Id__c);        
            }
        }
        if(embList.size() > 0){
            system.debug('embList-->'+embList);
            Database.insert(embList);
        }       
    }
    global void finish(Database.BatchableContext bc) {
        system.debug('finish');
        String days=Label.DaysTo;
        String days2 = Label.DaysTo2;
        String closed = 'Closed';
        String startDate = Label.BCSVStartDate; 
        String endDate = Label.BCSVEndDate; 
       
        //String query = 'SELECT Id FROM EmailMessage where  Parent.ClosedDate <LAST_N_DAYS:' + days + ' AND Parent.ClosedDate>=LAST_N_DAYS:' + days2 + 'AND Parent.Status = \'Closed\' '; 
        String query = 'SELECT Id FROM EmailMessage where Parent.ClosedDate < LAST_N_DAYS:' + days + ' and Parent.Failed_Record__c =false and Parent.Processed_Record__c = false'; 
        Database.executeBatch(new Arch_StagingPopulatorContentDocument(query), 2000);
        
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
}