@isTest
public class ContentDocumentBatchExampleTest {
    @isTest
    public static void testBatchExecution() {
      
        Account testAccount1 = new Account(Name = 'Test Account 1');
        insert testAccount1;
          Account testAccount3 = new Account(Name = 'Test Account 3');
        insert testAccount3;
        
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert testAccount2;

       
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User testUser1 = new User(
            Alias = 'enabled',
            Email = 'testtrion@testalytics.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Analytics',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testenabledanalytics@testworks.com'
        );
        insert testUser1;

       /* User testUser2 = new User(
            Alias = 'standt',
            Email = 'standarduser2@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser2@testorg.com'
        );
        insert testUser2;*/

     
        ContentVersion testContent = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'TestPath.txt',
            VersionData = Blob.valueOf('Test Content Data')
        );
        insert testContent;

        ContentDocumentLink testLink1 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId,
            LinkedEntityId = testAccount1.Id,
            ShareType = 'V'
        );
          ContentDocumentLink testLink4 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId,
            LinkedEntityId = testAccount2.Id,
            ShareType = 'V'
        );
        insert testLink4;

        ContentDocumentLink testLink2 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId,
            LinkedEntityId = testUser1.Id,
            ShareType = 'V'
        );
        insert testLink2;

       /* ContentDocumentLink testLink3 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId,
            LinkedEntityId = testUser2.Id,
            ShareType = 'V'
        );
        insert testLink3;*/
          ContentDocumentLink testLink5 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId,
            LinkedEntityId = testAccount3.Id,
            ShareType = 'V'
        );
        insert testLink5;
	List<Attachment> attachments = new List<Attachment>();
        for(Integer i = 1; i <= 3; i++) {
            Attachment testAttachment = new Attachment(
                ParentId = testAccount1.Id, 
                Name = 'Test Attachment ' + i + '.txt',
                Body = Blob.valueOf('Test Attachment Body ' + i)
            );
            attachments.add(testAttachment);
        }
        insert attachments;

        Test.startTest();
        System.runAs(testUser1) {
        ContentDocumentBatchExample batchJob = new ContentDocumentBatchExample();
        Database.executeBatch(batchJob);
        }
        Test.stopTest();
    }
}