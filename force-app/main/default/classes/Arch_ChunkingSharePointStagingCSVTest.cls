@isTest()
public class Arch_ChunkingSharePointStagingCSVTest {
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
            status__c = 'Retry Required',
            Upload_Failed__c = False,
            Retry_Executed_Count__c = 0
        );
        insert staggingRecord;
        
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
        insert emailMessageHtml;
        EmailMessageHtml__c emailMessageHtml2 = new EmailMessageHtml__c(
            EmailMessage_Id__c = emailRecordId,
            File_Body__c = emailMessage.HtmlBody,
            sObject__c = 'EmailMessage',
            Status__c = 'Retry Required',
            Title__c = 'Test Class',
            Retry_Executed_Count__c = 1,
            Parent_Case_Id__c = caseId,
            File_Size__c = 234,
            Upload_Failed__c = False
        );
        //insert emailMessageHtml2; 
        
        Test.startTest();
       // System.enqueueJob(new Arch_SharePointCountMatchQueue(caseId, emailRecordId, emailRecordCount));
        List<EmailMessageHtml__c> emailList =New List<EmailMessageHtml__c>();
        emailList.add(emailMessageHtml);
         //emailList.add(emailMessageHtml2);
        Arch_ChunkingSharePointEmailCSV.chunkStagingData(emailList);
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
            Retry_Executed_Count__c = 0
        );
        insert staggingRecord;
        
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
        
        Test.startTest();
       // System.enqueueJob(new Arch_SharePointCountMatchQueue(caseId, emailRecordId, emailRecordCount));
        List<EmailMessageHtml__c> emailList =New List<EmailMessageHtml__c>();
        //emailList.add(emailMessageHtml);
        emailList.add(emailMessageHtml2);
        Arch_ChunkingSharePointEmailCSV.chunkStagingData(emailList);
        Test.stopTest();
    }
        
        
        @isTest
        static void testCoverage(){
            //ChunkingSharePointStagingCSV.testCoverage();
            Arch_ChunkingSharePointEmailCSV.testCoverage();
            //Arch_RetryChunkingSharePointEmailCSV.testCoverage();
            //Arch_RetrySharePointMigrationQueueCSV.testCoverage();
        }
        
        @isTest
        static void testTriggerWithException() {
            // Start a test context
            Test.startTest();
            
            // Create a list of platform events
            List<SharePointPusherCSV__e> eventList = new List<SharePointPusherCSV__e>();
            
            // Create a mock event with sample values
            SharePointPusherCSV__e mockEvent = new SharePointPusherCSV__e();
            mockEvent.EmailNumber__c = 'Failed';
            // Add the mock event to the list of events
            eventList.add(mockEvent);
            
            // Publish the platform event
            EventBus.publish(eventList);
            
            // Stop the test context to trigger the event
            Test.stopTest();
            
            // Query to confirm if any error logs were inserted (to cover the exception block)
            List<Integration_Log_Error__c> errorLogs = [SELECT Id FROM Integration_Log_Error__c];
            //System.assert(errorLogs.size() > 0, 'Error logs should have been inserted.');
        }
    }