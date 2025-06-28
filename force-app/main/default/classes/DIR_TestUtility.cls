/*********************************************************************************
* Name: DIR_TestUtility
* Created by SevenPoints {DateCreated 5/30/2018}  
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as Utility class for test classes
----------------------------------------------------------------------------------
* Unit Test: DIR_TestUtility.cls
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 5/30/2018 INITIAL DEVELOPMENT
*********************************************************************************/

@isTest
public class DIR_TestUtility {
    
    public static Employee__c createEmployee(String salutation, String firstName, String lastName, String title, String mobilePhone, String officePhone, String officeEmail) {
        Employee__c emp = new Employee__c();
        emp.Salutation__c = salutation;
        emp.Name = firstName + lastName;
        emp.First_Name__c = firstName;
        emp.Last_Name__c = lastName;
        emp.Title__c = title;
        emp.Mobile_Phone__c = mobilePhone;
        emp.Office_Phone__c = officePhone;
        emp.Office_Email__c = officeEmail;
        return emp;
    }
    
    public static Location__c createLocation(String locationName, String overview) {
        Location__c l = new Location__c();
        l.Name = locationName; 
        l.Overview__c = overview;
        return l;
    }
    
    public static Department__c createDepartment(String departmentName, String departmentLeaderId, String departmentEmail, String departmentPhone) {
        Department__c d = new Department__c();
        d.Name = departmentName;
        d.Department_Leader__c = departmentLeaderId;
        d.Email__c = departmentEmail;
        d.Phone__c = departmentPhone;
        return d;
    }
    
}