/***************************************************************************************
* Name: DIR_OfficeLocationDetailCtrl
* Created by Seven Points {DateCreated 5/29/2018} 
----------------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as a ctrl for visualforce page DIR_OfficeLocationDetail.page
----------------------------------------------------------------------------------------
* Unit Test: DIR_OfficeLocationDetailCtrlTest.cls
----------------------------------------------------------------------------------------
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Seven Points 5/29/2018 INITIAL DEVELOPMENT
****************************************************************************************/

public class DIR_OfficeLocationDetailCtrl {
    
    public String recordId {get;set;}
    public Location__c ol {get;set;}
    public List<OfficeLocationStaff> lstOfficeLocationStaff {get;set;}
    public Boolean isShowDifferentViews {get;set;}
    public String searchString {get;set;}
    public String searchError {get;set;}
    
    public DIR_OfficeLocationDetailCtrl(ApexPages.StandardController sc){
        try{
            searchError = null;
            isShowDifferentViews = true;
            recordId = sc.getId();
            lstOfficeLocationStaff = new List<OfficeLocationStaff>();
            
            if(String.isNotBlank(recordId)){
                ol = new Location__c();
                List<Location__c> lstOfficeLocation = new List<Location__c>();
                Set<String> setAdditionalFields = new Set<String>();
                
                String SOQL = prepareQuery('Location__c',setAdditionalFields);
                SOQL += ' WHERE Id =:recordId Limit 1';
                lstOfficeLocation = (List<Location__c>)Database.query(SOQL);
                if(lstOfficeLocation.size() > 0){
                    for(Location__c offloc : lstOfficeLocation){
                        ol = offloc;
                    }
                }
                
                fetchOfficeLocationStaff(recordId);
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid ID'));
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
    }
    
    //Search Button
    public pageReference doSearch(){
        if(String.isNotBlank(recordId)){
            fetchOfficeLocationStaff(recordId);
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid ID'));
        }
        return null;
    }
    
    //Clear Search Button
    public pageReference doClearSearch(){
        searchString = '';
        if(String.isNotBlank(recordId)){
            fetchOfficeLocationStaff(recordId);
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid ID'));
        }
        return null;
    }
    
    //Fetch Office Location Staff
    public pageReference fetchOfficeLocationStaff(String officeLocationId){
        pageReference pg = null;
        try{
            lstOfficeLocationStaff = new List<OfficeLocationStaff>();
            Set<String> setEmployeeIds = new Set<String>();
            Map<String, String> mapEmployeeFileIds = new Map<String, String>();
            Map<String, Employee__c> mapEmployee = new Map<String, Employee__c>();
            String SOQL = '';
            Set<String> setAdditionalFields = new Set<String>();
            setAdditionalFields.add('Department__r.Name');
            setAdditionalFields.add('Location__r.Name');
            
            SOQL = prepareQuery('Employee__c',setAdditionalFields);
            SOQL += ' WHERE Location__c =:officeLocationId';
            
            searchError = null;
            Set<String> setEmpIds = new Set<String>();
            if (searchString != '' && searchString != null) { 
                searchString = searchString.trim();
                if (searchString.length() >= 2) { 
                    if ((searchString.contains('*') || searchString.contains('?')) && searchString.length() < 3) { 
                        searchError = 'Three characters are required when using wildcards in your search.';
                    }
                } else { 
                    searchError = 'You must include at least two characters in the search string.';
                }
                if (searchError == null) { 
                    List<List<sObject>> searchList = [FIND :searchString IN ALL FIELDS RETURNING Employee__c(Id ORDER BY Name asc)];
                    List<Employee__c> listOfEmployees = ((List<Employee__c>)searchList[0]);
                    for (Employee__c c : listOfEmployees) {
                        setEmpIds.add(c.Id); 
                    }
                    SOQL += ' AND (Id IN:setEmpIds OR Department__r.Name Like \'%'+searchString+'%\''+ ' ' + ') ';
                }
            }
            
            SOQL += ' ORDER BY Last_Name__c asc ';
            List<Employee__c> lstEmployee = (List<Employee__c>)Database.query(SOQL);
            if(lstEmployee.size() > 0){
                for(Employee__c emp : lstEmployee){
                    setEmployeeIds.add(emp.id);
                    mapEmployee.put(emp.Id, emp);
                }
            }
            if(setEmployeeIds.size() > 0){
                
                Map<String, String> mapContentDocumentLink = new Map<String, String>();
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :setEmployeeIds]){
                    mapContentDocumentLink.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                }
                if(mapContentDocumentLink != null && mapContentDocumentLink.keySet().size() > 0){
                    for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :mapContentDocumentLink.keySet()]){
                        String FileId = cv.Id;
                        if(mapContentDocumentLink.containsKey(cv.ContentDocumentId)){
                            mapEmployeeFileIds.put(mapContentDocumentLink.get(cv.ContentDocumentId), FileId);
                        }
                    }
                }
                
                if(mapEmployee != null && mapEmployee.KeySet().size() > 0){
                    for(String empId : mapEmployee.keySet()){
                        Employee__c empObj = mapEmployee.get(empId);
                        String attId = '';
                        if(mapEmployeeFileIds.containsKey(empId)){
                            attId = mapEmployeeFileIds.get(empId); 
                        }
                        lstOfficeLocationStaff.add(new OfficeLocationStaff(empObj,attId));
                    }
                }
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        return pg;
    }
    
    public pageReference doToggleView(){
        if(isShowDifferentViews){
            isShowDifferentViews = false;
        }else{
            isShowDifferentViews = true;
        }
        return null;
    }
    
    //Prepare SOQL query based on Object Name
    public static String prepareQuery(String objName, Set<String> setAdditionalFields){
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.sObjectType objType = globalDescription.get(objName);
        Schema.DescribeSObjectResult r1 = objType.getDescribe(); 
        Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();  
        Set<String> setFields = new Set<String>();
        setFields = setAdditionalFields;
        
        String strQuery = '';
        strQuery = 'SELECT ';
        for(Schema.SObjectField field : mapFieldList.values()){  
            Schema.DescribeFieldResult fieldResult = field.getDescribe(); 
            if(fieldResult.isAccessible()){
                setFields.add(fieldResult.getName());
            }  
        }
        for(String fAPI : setFields){
            strQuery += fAPI + ', ';
        }
        strQuery = strQuery.substring(0, strQuery.lastIndexOf(','));
        strQuery += ' FROM ' + objName + ' ';
        return strQuery;
    }
    
    public pageReference doReturnToDirectory(){
        pageReference pg = null; 
        pg = new pageReference('/apex/DIR_Directory');
        pg.setRedirect(true);
        return pg;
    }
    
    public class OfficeLocationStaff{
        
        public Employee__c employee {get;set;} 
        public String fileId {get;set;}
        
        public OfficeLocationStaff(Employee__c employee, String fileId){
            this.employee = employee;
            this.fileId = fileId;
        }
    }
    
}