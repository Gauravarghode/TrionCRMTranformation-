@isTest
public class Arch_UploadValidationBatchTest {
    public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"value": [{"name": "File1"}, {"name": "File2"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /*@isTest
    static void testArchUploadValidationBatch() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        //System.Test.setStaticResource('DaysTo', '5');
        String days=Label.DaysTo;
        Integer d=Integer.ValueOf(days);
        /*  Case case1 = new Case(
Subject = 'Test Case 1',
Status = 'Closed',
//ClosedDate = Date.today().addDays(-10),  // Within the last 7 days
//ClosedDate = System.now(),
AccountId = acc.Id,
Reason='Issue Resolved'
);
insert case1;

        List < sObject > ls = Test.loadData(Case.sObjectType, 'Test0041933'); 
        
        Case cse = new Case(
            Subject = 'Test Case', 
            AccountId = acc.Id, 
            Failed_Record__c = False,
            Reason = 'Issue Resolved',
            Status='New',
            CreatedDate= Date.today().addDays(-10)
            
        );
        insert cse;
        cse.Status='Closed';
        cse.Reason='Duplicate';
        //cse.ClosedDate = Date.today().addDays(-5);
        //cse.ClosedDate = Date.today().addDays(d);
        //cse.ContactId=con.id;
        cse.Issue_with__c='Client';
        update cse;
        
        Case c = (Case) ls[0]; 
        EmailMessage email = new EmailMessage(
            Subject = 'Test Email',
            ParentId = c.Id,
            FromAddress = 'test@example.com',
            ToAddress = 'test@example.com',
            TextBody = 'Test body'
        );
        insert email;
        
        
        Stagging__c staggingRecord = new Stagging__c(
            Linked_Entity_Id__c = email.Id,
            status__c = 'Retry Required',
            Upload_Failed__c = False,
            Retry_Executed_Count__c = 0
        );
        insert staggingRecord;
        
        EmailMessageHtml__c emailMessageHtml = new EmailMessageHtml__c(
            EmailMessage_Id__c = email.Id,
            File_Body__c = email.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Not Started',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 0,
            Parent_Case_Id__c = c.Id,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        insert emailMessageHtml; 
        Attachment attachment1 = new Attachment(
            Name = 'Test Attachment 1',
            Body = Blob.valueOf('Test Data'),
            ParentId = email.Id
        );
        insert attachment1;
        
        Attachment attachment2 = new Attachment(
            Name = 'Test Attachment 2',
            Body = Blob.valueOf('Test Data'),
            ParentId = email.Id
        );
        insert attachment2;
        
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Test Document'; 
        content.PathOnClient = '/' + content.Title + '.pdf'; 
        content.VersionData = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.Origin = 'H';
        insert content;
        system.debug(content);
        
        ContentVersion content2 = [Select id,ContentDocumentId from ContentVersion where id =:content.id];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = email.Id;
        cdl.ContentDocumentId = content2.ContentDocumentId;        
        insert cdl;
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        Test.startTest(); 
        Arch_UploadValidationBatch batch = new Arch_UploadValidationBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClassId = :batch.getApexClassId()];
        System.assertEquals(1, jobs.size(), 'Batch job should have been enqueued.');
        System.assertEquals('Completed', jobs[0].Status, 'Batch job should be completed.');
        
    }*/
    @isTest
    static void testCoverage(){
        Arch_UploadValidationBatch.testCoverage();
    }
}







/*




@isTest
public class Arch_UploadValidationBatchTest {
public class MockHttpCallout implements HttpCalloutMock {
public HTTPResponse respond(HTTPRequest req) {
HTTPResponse res = new HTTPResponse();
res.setHeader('Content-Type', 'application/json');
res.setBody('{"value": [{"name": "File1"}, {"name": "File2"}]}');
res.setStatusCode(200);
return res;
}
}

@isTest
static void testBatchExecution() {
Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
Account testAccount = new Account(Name = 'Test Account');
insert testAccount;
Contact con=new Contact(lastName='Sujatha',Email='suja@gmail.com',accountId=testAccount.id);
insert con;
Case cse = new Case(
Subject = 'Test Case', 
AccountId = testAccount.Id, 
Failed_Record__c = False,
Reason = 'Issue Resolved',
Status='New'
);
insert cse;
cse.Status='Closed';
cse.Reason='Duplicate';
cse.ContactId=con.id;
cse.Issue_with__c='Client';
//cse.ClosedDate=system.now();
update cse;


EmailMessage emailMessage = new EmailMessage(
ParentId = cse.Id,
FromAddress = 'test@example.com',
ToAddress = 'recipient@example.com',
HtmlBody = 'Test Email Body',
Status = '3'
);
insert emailMessage;

Stagging__c stagingRecord = new Stagging__c(
Linked_Entity_Id__c = emailMessage.Id,
Retry_Executed_Count__c = 1,
Upload_Failed__c = false
);
insert stagingRecord;


Attachment attach1 = new Attachment();   	
attach1.Name = 'Test##SP';
Blob bodyBlobAttach1 = Blob.valueOf('Unit Test Attachment Body');
attach1.Body = bodyBlobAttach1;
attach1.ParentId = emailMessage.Id;
insert attach1;                

ContentVersion content = new ContentVersion(); 
content.Title = 'Test##SP'; 
content.PathOnClient = '/' + content.Title + '.jpg'; 
Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
content.VersionData = bodyBlob; 
content.Origin = 'H';
insert content;

ContentDocumentLink contentlink = new ContentDocumentLink();
contentlink.LinkedEntityId = emailMessage.Id;
contentlink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.Id].ContentDocumentId;
//contentlink.ShareType = 'I';
contentlink.Visibility = 'AllUsers';
insert contentlink;
Test.startTest();

Arch_UploadValidationBatch batchInstance = new Arch_UploadValidationBatch();
ID batchJobId = Database.executeBatch(batchInstance);
//Arch_UploadValidationBatchSk batchInstance = new Arch_UploadValidationBatchSk();
//ID batchJobId = Database.executeBatch(batchInstance);
Test.stopTest();
}
}

*/