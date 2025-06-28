@isTest
public class StagingPopulatorTest {
    
    static testmethod void StagingPopulator_ContentDocumentsTest(){
        
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
        
        ContentVersion content1 = new ContentVersion(); 
        content1.Title = 'Test##SP'; 
        content1.PathOnClient = '/' + content1.Title + '.jpg'; 
        Blob bodyBlob1 = Blob.valueOf('Unit Test ContentVersion Body'); 
        content1.VersionData = bodyBlob1; 
        content1.origin = 'H';
        insert content1;
        
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = acc.Id;
        contentlink1.ContentDocumentId = [select ContentDocumentId from ContentVersion where Id =: content1.Id].ContentDocumentId;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers';
        insert contentlink1;
        
        Test.startTest();
        Database.executeBatch(new StagingPopulator_ContentDocuments('select id from account'), 50);
        Test.stopTest();
    }
    
    static testmethod void StagingPopulator_AttachmentsTest(){
        
		Case cse=new Case();
        insert cse;
        
        Attachment attach1 = new Attachment();   	
    	attach1.Name = 'Test##SP';
    	Blob bodyBlobAttach1 = Blob.valueOf('Unit Test Attachment Body');
    	attach1.body = bodyBlobAttach1;
        attach1.parentId = cse.id;
        insert attach1;
        
        Attachment attach2 = new Attachment();   	
    	attach2.Name = 'Test##SP.jpg';
    	Blob bodyBlobAttach2 = Blob.valueOf('Unit Test Attachment Body');
    	attach2.body = bodyBlobAttach2;
        attach2.parentId = cse.id;
        insert attach2;
        
        Test.startTest();
        Database.executeBatch(new StagingPopulator_Attachments('select id from case'), 50);
        Test.stopTest();
    }    
}