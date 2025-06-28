/*********************************************************************************
* Name: DIR_HeaderCtrlTest
* Created by SevenPoints {DateCreated 5/30/2018}  
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class for DIR_HeaderCtrl.cls
----------------------------------------------------------------------------------
* Unit Test: DIR_HeaderCtrlTest.cls
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 5/30/2018 INITIAL DEVELOPMENT
*********************************************************************************/

@isTest
private class DIR_HeaderCtrlTest {
    
    static testMethod void myUnitTest() {
        
        Location__c l = DIR_TestUtility.createLocation('Test Location','Test Location Overview');
        insert l;
        
        Employee__c emp = DIR_TestUtility.createEmployee('Mr.','fn','ln','title','5555550001','5555550001','email@test.com');
        emp.Location__c = l.Id;
        insert emp;
        
        Department__c d = DIR_TestUtility.createDepartment('Test Department',emp.Id+'','demail@test.com','5555550001');
        insert d;
        
        ApexPages.currentPage().getParameters().put('search',emp.Name);
        ApexPages.currentPage().getParameters().put('searchError','');
        DIR_HeaderCtrl cls = new DIR_HeaderCtrl();
        cls.searchString = emp.Name;
        cls.doSearch();
        cls.searchString = 't';
        cls.doSearch();
        cls.searchString = 't*r';
        cls.doSearch();
        cls.doReturnToDirectory();
        
    }
    
}