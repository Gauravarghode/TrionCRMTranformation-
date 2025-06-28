/*********************************************************************************
* Name: DIR_OfficeLocationDetailCtrlTest
* Created by SevenPoints {DateCreated 5/30/2018}  
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class for DIR_OfficeLocationDetailCtrl.cls
----------------------------------------------------------------------------------
* Unit Test: DIR_OfficeLocationDetailCtrlTest.cls
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 5/30/2018 INITIAL DEVELOPMENT
*********************************************************************************/

@isTest
private class DIR_OfficeLocationDetailCtrlTest {
    
    static testMethod void myUnitTest() {
        
        Location__c l = DIR_TestUtility.createLocation('Test Location','Test Location Overview');
        insert l;
        
        Employee__c emp = DIR_TestUtility.createEmployee('Mr.','fn','ln','title','5555550001','5555550001','email@test.com');
        emp.Location__c = l.Id;
        insert emp;
        
        Department__c d = DIR_TestUtility.createDepartment('Test Department',emp.Id+'','demail@test.com','5555550001');
        insert d;
        
        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content';      
        cv.PathOnClient = 'test';           
        cv.VersionData = beforeblob;          
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = emp.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        DIR_OfficeLocationDetailCtrl cls = new DIR_OfficeLocationDetailCtrl(sc);
        cls.doToggleView();
        cls.searchString = emp.Name;
        cls.doSearch();
        cls.searchString = 't';
        cls.doSearch();
        cls.searchString = 't*r';
        cls.doSearch();
        cls.doReturnToDirectory();
        cls.doClearSearch();
    }
    
}