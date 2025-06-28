@isTest()
public class Arch_ChunkingSharePointStagingTest {
    //@isTest
    /*  Public static void testdataforChunking(){
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
List<Stagging__c> stagingRecords = new List<Stagging__c>();
for (Integer i = 0; i <5; i++) {
Stagging__c stagingRecord = new Stagging__c(Status__c = 'Not Started', Chunk__c = 'Test##SP');
stagingRecords.add(stagingRecord);
}
List<Stagging__c> stagingRecords2 = new List<Stagging__c>();
for (Integer i = 0; i <5; i++) {
Stagging__c stagingRecord = new Stagging__c(Status__c = 'Retry Required', Chunk__c = 'Test##SP');
stagingRecords2.add(stagingRecord);
}

Test.startTest();
System.runAs(u) {
Arch_ChunkingSharePointStagingFA.chunkStagingData(stagingRecords);
}
System.runAs(u) {
Arch_ChunkingSharePointStagingFA.chunkStagingData(stagingRecords2);
}

Test.stopTest();
} */
    
    public static String caseId;
    public static String emailRecordId;
    
    @IsTest
    static void testdataforChunking() {
        
        Case testCase = new Case(Subject = 'Test Case', Status = 'New', Failed_Record__c = False);
        insert testCase;
        caseId = testCase.Id;
        
        EmailMessage emailMessage = new EmailMessage(
            FromAddress = '123@testSalesforce.com',
            ToAddress = '321@testSalesforce.com',
            Headers = 'Test Header',
            HtmlBody = 'Test HTML Body',
            ParentId = testCase.Id
        );
        insert emailMessage;
        emailRecordId = emailMessage.Id;
        
        Stagging__c staggingRecord = new Stagging__c(
            Linked_Entity_Id__c = emailRecordId,
            status__c = 'Not Started',
            Upload_Failed__c = False,
            Retry_Executed_Count__c = 0
        );
        insert staggingRecord;
        
       /* EmailMessageHtml__c emailMessageHtml = new EmailMessageHtml__c(
            EmailMessage_Id__c = emailRecordId,
            File_Body__c = emailMessage.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Not Started',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 0,
            Parent_Case_Id__c = caseId,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        insert emailMessageHtml;*/

        Test.startTest();
        // System.enqueueJob(new Arch_SharePointCountMatchQueue(caseId, emailRecordId, emailRecordCount));
        List<Stagging__c> staggingList =New List<Stagging__c>();
        staggingList.add(staggingRecord);
        //emailList.add(emailMessageHtml2);
        Arch_ChunkingSharePointStagingFA.chunkStagingData(staggingList);
        //Arch_ChunkingSharePointEmailCSV.chunkStagingData(emailList);
        Test.stopTest();
    }
    
    @IsTest
    static void testdataforChunking02() {
        
        Case testCase = new Case(Subject = 'Test Case', Status = 'New', Failed_Record__c = False);
        insert testCase;
        caseId = testCase.Id;
        
        EmailMessage emailMessage = new EmailMessage(
            FromAddress = '123@testSalesforce.com',
            ToAddress = '321@testSalesforce.com',
            Headers = 'Test Header',
            HtmlBody = 'Test HTML Body',
            ParentId = testCase.Id
        );
        insert emailMessage;
        emailRecordId = emailMessage.Id;
        
        Stagging__c staggingRecord = new Stagging__c(
            Linked_Entity_Id__c = emailRecordId,
            status__c = 'Retry Required',
            Upload_Failed__c = False,
            Retry_Executed_Count__c = 1
        );
        insert staggingRecord;
       /* 
        EmailMessageHtml__c emailMessageHtml = new EmailMessageHtml__c(
            EmailMessage_Id__c = emailRecordId,
            File_Body__c = emailMessage.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Not Started',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 0,
            Parent_Case_Id__c = caseId,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        // insert emailMessageHtml;
        EmailMessageHtml__c emailMessageHtml2 = new EmailMessageHtml__c(
            EmailMessage_Id__c = emailRecordId,
            File_Body__c = emailMessage.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Retry Required',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 0,
            Parent_Case_Id__c = caseId,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        insert emailMessageHtml2; 
        */
        Test.startTest();
        // System.enqueueJob(new Arch_SharePointCountMatchQueue(caseId, emailRecordId, emailRecordCount));
        List<Stagging__c> staggingList =New List<Stagging__c>();
        staggingList.add(staggingRecord);
        //emailList.add(emailMessageHtml2);
        Arch_ChunkingSharePointStagingFA.chunkStagingData(staggingList);
        //Arch_ChunkingSharePointEmailCSV.chunkStagingData(emailList);
        Test.stopTest();
    }
    
    @isTest
    static void testCoverage(){
        Arch_ChunkingSharePointStagingFA.testQualifier();
    }
}