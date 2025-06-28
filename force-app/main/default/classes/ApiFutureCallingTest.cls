@isTest
public class ApiFutureCallingTest {
    
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