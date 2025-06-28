/*********************************************************************************
* Name: DIR_DepartmentDetailCtrlTest
* Created by SevenPoints {DateCreated 5/30/2018}  
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class for DIR_DepartmentDetailCtrl.cls
----------------------------------------------------------------------------------
* Unit Test: DIR_DepartmentDetailCtrlTest.cls
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 5/30/2018 INITIAL DEVELOPMENT
*********************************************************************************/

@isTest
private class DIR_DepartmentDetailCtrlTest {
    
    static testMethod void myUnitTest() {
        
        Location__c l = DIR_TestUtility.createLocation('Test Location','Test Location Overview');
        insert l;
        
        Employee__c emp1 = DIR_TestUtility.createEmployee('Mr.','fn','ln','title','5555550001','5555550001','email1@test.com');
        emp1.Location__c = l.Id;
        insert emp1;
        
        Department__c d = DIR_TestUtility.createDepartment('Test Department',emp1.Id+'','demail@test.com','5555550001');
        insert d;
        
        Employee__c emp2 = DIR_TestUtility.createEmployee('Mr.','fn1','ln1','title','5555550002','5555550002','email2@test.com');
        emp2.Location__c = l.Id;
        emp2.Department__c = d.Id;
        insert emp2;
        
        Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion cv1 = new ContentVersion();
        cv1.title = 'test content';      
        cv1.PathOnClient = 'test';           
        cv1.VersionData = beforeblob1;          
        insert cv1;         
        
        ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv1.Id];
        
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = emp1.id;
        contentlink1.ShareType = 'V';
        contentlink1.ContentDocumentId = testcontent1.ContentDocumentId;
        insert contentlink1;
        
        Blob beforeblob2 = Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion cv2 = new ContentVersion();
        cv2.title = 'test content';      
        cv2.PathOnClient = 'test';           
        cv2.VersionData = beforeblob2;          
        insert cv2;         
        
        ContentVersion testContent2 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv2.Id];
        
        ContentDocumentLink contentlink2 = new ContentDocumentLink();
        contentlink2.LinkedEntityId = emp2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId = testcontent2.ContentDocumentId;
        insert contentlink2;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(d);
        DIR_DepartmentDetailCtrl cls = new DIR_DepartmentDetailCtrl(sc);
        cls.doToggleView();
        cls.searchString = emp1.Name;
        cls.doSearch();
        cls.searchString = 't';
        cls.doSearch();
        cls.searchString = 't*r';
        cls.doSearch();
        cls.doReturnToDirectory();
        cls.doClearSearch();
    }
    
}