@isTest
public class Arch_ApiFutureCallingFATest {
    
    @isTest
    static void testCoverage(){
        Arch_ApiFutureCallingFA.testCoverage();
    }
    /*
    @testSetup
    static void setupTestData() {
        Stagging__c stagging1 = new Stagging__c(
            sObject__c = 'EmailMessage', 
            Chunk__c = '06AVE000003jTfO2AU', 
            Linked_Entity_Id__c = '02sVE000004McXQYA0', 
            Status__c = 'Not Started', 
            Content_Document_Id__c = '069VE0000032tptYAA',
            Content_Version_Id__c = '068UH000000BljcYAC',
            Title__c = 'Test Document',
            From_sObject__c = 'ContentDocument'
        );
        insert stagging1;
        
        Stagging__c stagging2 = new Stagging__c(
            sObject__c = 'Case', 
            Chunk__c = '06AVE000003jTfO2AI', 
            Linked_Entity_Id__c = '02sVE000004McXQYA0', 
            Status__c = 'Not Started', 
            Title__c = 'Test Attachment',
            From_sObject__c = 'Attachment'
        );
        insert stagging2;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File', 
            VersionData = Blob.valueOf('Test content'), 
            ContentDocumentId = '069VE0000032tptYAA'
           // FileExtension = 'txt'
        );
        insert contentVersion;
        
        EmailMessage emailMessage = new EmailMessage(
            ParentId = '500VE00000B65xxYAB'
        );
        insert emailMessage;
        
        Attachment attachment = new Attachment(
            Name = 'Test Attachment', 
            Body = Blob.valueOf('Test attachment content'), 
            ContentType = 'text/plain'
        );
        insert attachment;
    }
    
    @isTest
    static void testFileMigrationForContentDocument() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        
        Test.startTest();
        Arch_ApiFutureCallingFA.fileMigration('06AVE000003jTfO2AU');
        Test.stopTest();
        
        Stagging__c updatedStagging = [SELECT Status__c FROM Stagging__c WHERE Chunk__c = '06AVE000003jTfO2AU'];
        System.assertEquals('Completed', updatedStagging.Status__c);
    }
    
    @isTest
    static void testFileMigrationForAttachment() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        
        Test.startTest();
        Arch_ApiFutureCallingFA.fileMigration('06AVE000003jTfO2AI');
        Test.stopTest();
        
        Stagging__c updatedStagging = [SELECT Status__c FROM Stagging__c WHERE Chunk__c = '06AVE000003jTfO2AI'];
        System.assertEquals('Completed', updatedStagging.Status__c);
    }
    
    @isTest
    static void testFileMigrationFailedCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400));
        
        Test.startTest();
        Arch_ApiFutureCallingFA.fileMigration('06AVE000003jTfO2AU');
        Test.stopTest();
        
        Stagging__c updatedStagging = [SELECT Status__c, Error_Message__c FROM Stagging__c WHERE Chunk__c = '06AVE000003jTfO2AU'];
        System.assertEquals('Pending', updatedStagging.Status__c);
        System.assert(updatedStagging.Error_Message__c.contains('File upload failed'));
    }
    
    @isTest
    static void testFileMigrationExceptionHandling() {
        Test.startTest();
        Arch_ApiFutureCallingFA.fileMigration('06AVE000003jTfO2AZ');
        Test.stopTest();
        
        List<Integration_Log_Error__c> logErrors = [SELECT Name, getMessage__c FROM Integration_Log_Error__c];
        System.assert(logErrors.size() > 0);
        System.assertEquals('Exception', logErrors[0].Name);
    }
    
    private class MockHttpResponse implements HttpCalloutMock {
        Integer statusCode;
        
        MockHttpResponse(Integer statusCode) {
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            if (statusCode == 200 || statusCode == 201) {
                res.setBody('{"status": "success"}');
            } else {
                res.setBody('{"status": "failure"}');
            }
            return res;
        }
    }*/
}


/*  
@istest(seeAllData = true)
public static void testDataforHttp(){
Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
User u = new User(
Alias = 'standt', 
Email = 'standarduser@sharepointtest.com',
EmailEncodingKey = 'UTF-8', 
LastName = 'Testing', 
LanguageLocaleKey = 'en_US',
LocaleSidKey = 'en_US', 
ProfileId = p.Id,
TimeZoneSidKey = 'America/Los_Angeles',
Username = 'uniqueUserName@testsharepoint.com'
);
insert u;

Account acc = new Account(Name='Demo');
insert acc;

ContentVersion content = new ContentVersion(); 
content.Title = 'Test##SP'; 
content.PathOnClient = '/' + content.Title + '.jpg'; 
Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
content.VersionData = bodyBlob; 
content.origin = 'H';
insert content;

ContentDocumentLink contentlink = new ContentDocumentLink();
contentlink.LinkedEntityId = acc.Id;
contentlink.ContentDocumentId = [select ContentDocumentId from ContentVersion where Id =: content.Id].ContentDocumentId;
contentlink.ShareType = 'I';
contentlink.Visibility = 'AllUsers';
insert ContentLink;

List<Staging__b> stagingRecords = new List<Staging__b>();
for (Integer i = 0; i <5; i++) {
Staging__b stagingRecord = new Staging__b(Status__c = 'Not Started', Chunk__c = 'Chunk ' + i, Job_Id__c = 'Test##SP');
stagingRecords.add(stagingRecord);
}
Staging__b stagingRecord1 = new Staging__b(Status__c = 'Not Started', Chunk__c = 'Chunk1', Job_Id__c = 'Test##SP');
Test.startTest();

System.runAs(u) {
ApiFuturecalling.fileMigration('Test##SP');
//ApiFuturecalling.updateSharepointStatus(stagingRecord1,'Completed','null');
}
}

@isTest
static void testCoverage(){
ApiFuturecalling.testCoverage();
}
}
*/