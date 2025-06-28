/***************************************************************************************
* Name: DIR_DirectoryCtrl
* Created by Seven Points {DateCreated 5/29/2018} 
----------------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as a ctrl for visualforce page DIR_Directory.page
----------------------------------------------------------------------------------------
* Unit Test: DIR_DirectoryCtrlTest.cls
----------------------------------------------------------------------------------------
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Seven Points 5/29/2018 INITIAL DEVELOPMENT
****************************************************************************************/

public class DIR_DirectoryCtrl {
    
    public List<Department__c> lstDepartments {get;set;}
    public List<Location__c> lstOfficeLocations {get;set;}
    
    public DIR_DirectoryCtrl(){
        lstDepartments = new List<Department__c>();
        lstOfficeLocations = new List<Location__c>();
        
        for(Department__c d : [SELECT Id, Name FROM Department__c ORDER BY Name asc]){
            lstDepartments.add(d);
        }
        
        for(Location__c ol : [SELECT Id, Name FROM Location__c ORDER BY Name asc]){
            lstOfficeLocations.add(ol);
        }
        
    }
    
}