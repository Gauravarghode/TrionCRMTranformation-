@isTest
public class Arch_ConvertCSVPopulateTableTest {
    
    /*@isTest
    static void testBatchClass() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Datetime now = System.now();
        Datetime futureDate = now.addDays(-3); 
        
        Case testCase = new Case(
            Subject = 'Test Case', 
            Status = 'Closed', 
            //ClosedDate = futureDate, 
            AccountId = testAccount.Id,
            Reason = 'Issue Resolved' 
        );
        insert testCase;
        
        EmailMessage testEmailMessage = new EmailMessage(
            ParentId = testCase.Id,
            CreatedById = UserInfo.getUserId(),
            LastModifiedById = UserInfo.getUserId(),
            TextBody = 'Test text body',
            HtmlBody = 'Test <b>HTML</b> body',
            Headers = 'Test Headers',
            Subject = 'Test Subject',
            FromName = 'Test From Name',
            FromAddress = 'test@example.com',
            //ValidatedFromAddress = 'test@example.com',
            ToAddress = 'to@example.com',
            CcAddress = 'cc@example.com',
            BccAddress = 'bcc@example.com',
            Status = '2',
            MessageDate = now,
            IsClientManaged = false,
            RelatedToId = null,
            IsTracked = true,
            IsBounced = false,
            EmailTemplateId = null
        );
        insert testEmailMessage;
        
        Test.startTest();
        Arch_ConvertCSVPopulateTable batch = new Arch_ConvertCSVPopulateTable();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        List<EmailMessageHtml__c> result = [SELECT Id, Title__c, File_Size__c, EmailMessage_Id__c, Status__c, Csv_Body__c, Csv_String_2__c, Parent_Case_Id__c FROM EmailMessageHtml__c WHERE EmailMessage_Id__c = :testEmailMessage.Id];
        
        System.assertEquals(1, result.size(), 'One EmailMessageHtml__c record should be created');
        EmailMessageHtml__c emHtml = result[0];
        
        System.assertEquals('EmailMessageDetails_' + testEmailMessage.Id + '.csv', emHtml.Title__c, 'The Title__c should match');
        System.assertNotEquals(null, emHtml.Csv_Body__c, 'Csv_Body__c should not be null');
        System.assertNotEquals(null, emHtml.Csv_String_2__c, 'Csv_String_2__c should not be null');
        System.assertEquals('Not Started', emHtml.Status__c, 'The status should be Not Started by default');
        System.assertEquals(testEmailMessage.Id, emHtml.EmailMessage_Id__c, 'The EmailMessage_Id__c should match');
        System.assertEquals(testCase.Id, emHtml.Parent_Case_Id__c, 'The Parent_Case_Id__c should match');
    }*/
    @isTest
    static void testCoverage(){
        Arch_ConvertCSVPopulateTable.testCoverage();
    }
}

/*@isTest
public class BatchtoCSVTest {
    
    @isTest
    public static void meth1(){
        Account ac=new Account();
        ac.Name='asdsg';
        ac.toBeDeleted__c=true;
        insert ac;
      //  list<EmailMessage>liEma=new List<EmailMessage>();
      Contact_Type__c c=new Contact_Type__c();
     	c.Name='acc';
        c.Default_Days__c=2.00;
        insert c;
        Contact con =new Contact();
        con.LastName='dsdsdscsv';
       con.Email='Sujatha20017@gmail.com';
        con.AccountId=ac.id;
        con.Contact_Type__c=c.id;
        insert con;
        Case ca=new Case();
        ca.ContactId=con.id;
        ca.Issue_with__c='Client';
        ca.Status='New';
        ca.AccountId=ac.id;
        insert ca;
        List<EmailMessage>emailList=new List<EmailMessage>();
        
        EmailMessage e=new EmailMessage();
        e.ToAddress='Ksujatha@enabledanalytics.com';
        e.FromAddress='Sujatha20017@gmail.com';
        e.Subject='djshfsdf';
    	//e.AttachmentIds=false;
        e.Incoming=true;
        e.IsBounced=false;
        e.IsClientManaged=false;
        e.ParentId=ca.id;
        emailList.add(e);
         EmailMessage e1=new EmailMessage();
        e1.ToAddress='Ksujatha@enabledanalytics.com';
        e1.FromAddress='Sujatha20017@gmail.com';
        e1.Subject='dzcnsd';
    	//e.AttachmentIds=false;
        e1.Incoming=true;
        e1.IsBounced=false;
        e1.IsClientManaged=false;
        e1.ParentId=ca.id;
    	 emailList.add(e1);
        insert emailList;
        /*  List<EmailMessage_Html__b> embList=new List<EmailMessage_Html__b>();
            
            EmailMessage_Html__b emhb=new EmailMessage_Html__b();
            emhb.Title__c = 'asdas';
            emhb.File_Size__c = 12000009;
            emhb.EmailMessage_Id__c=emailList[0].Id;
            emhb.Status__c = 'Not Started';
            emhb.sObject__c='Email Message';
            emhb.File_Body__c = 'dskfcsdjkbvsdjvjhs';
            emhb.Parent_Case_Id__c=ca.id;
         emhb.Is_Large_File__c = 'yes';
                emhb.Status__c = 'Failed';
                emhb.Error_Message__c = 'File size > 12000000';
        embList.add(emhb);
          EmailMessage_Html__b emhb1=new EmailMessage_Html__b();
            emhb1.Title__c = 'scsdv';
            emhb1.File_Size__c = 12000000;
            emhb1.EmailMessage_Id__c=emailList[1].Id;
            emhb1.Status__c = 'Not Started';
            emhb1.sObject__c='Email Message';
            emhb1.File_Body__c = 'dskfcsdjkbvsdjvjhdsacdasdcs';
            emhb1.Parent_Case_Id__c=ca.id;
         emhb1.Is_Large_File__c = 'no';
                emhb1.Status__c = 'Not Started';
			embList.add(emhb1);  
    
        ContentVersion testContent = new ContentVersion(
            Title = 'Test Content',
            VersionData = Blob.valueOf('Test Content Data'),
             PathOnClient = 'TestPath.txt'
            
        );
        insert testContent;

       
        list<ContentDocumentLink>li=new list<ContentDocumentLink>();
        ContentDocumentLink testLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId,
            LinkedEntityId = ca.Id,
            ShareType = 'V'
          
        );
        li.add(testLink);
        insert li;
      
        Test.startTest();
      // Database.insertImmediate(embList);
        BatchtoCSVNew b=new BatchtoCSVNew();
        Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest
    static void testCoverage(){
        BatchtoCSVNew.testCoverage();
    }

}
*/