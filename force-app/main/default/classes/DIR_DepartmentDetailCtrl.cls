/***************************************************************************************
* Name: DIR_DepartmentDetailCtrl
* Created by Seven Points {DateCreated 5/29/2018} 
----------------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as a ctrl for visualforce page DIR_DepartmentDetail.page
----------------------------------------------------------------------------------------
* Unit Test: DIR_DepartmentDetailCtrlTest.cls
----------------------------------------------------------------------------------------
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Seven Points 5/29/2018 INITIAL DEVELOPMENT
****************************************************************************************/

public class DIR_DepartmentDetailCtrl {
    
    public String recordId {get;set;}
    public Department__c dept {get;set;}
    public Employee__c deptLeader {get;set;}
    public String FileId {get;set;}
    public List<DepartmentStaff> lstDepartmentStaff {get;set;}
    public Boolean isShowDifferentViews {get;set;}
    public String searchString {get;set;}
    public String searchError {get;set;}
    public Boolean isShowDepartmentLeader {get;set;}
    
    public DIR_DepartmentDetailCtrl(ApexPages.StandardController sc){
        try{
            isShowDepartmentLeader = false;
            searchError = null;
            isShowDifferentViews = true;
            recordId = sc.getId();
            lstDepartmentStaff = new List<DepartmentStaff>();
            
            if(String.isNotBlank(recordId)){
                deptLeader = new Employee__c();
                
                List<Department__c> lstDepartment = new List<Department__c>();
                Set<String> setAdditionalFields = new Set<String>();
                setAdditionalFields.add('Department_Leader__r.Name');
                
                String SOQL = prepareQuery('Department__c',setAdditionalFields);
                SOQL += ' WHERE Id =:recordId Limit 1';
                lstDepartment = (List<Department__c>)Database.query(SOQL);
                if(lstDepartment.size() > 0){
                    for(Department__c d : lstDepartment){
                        dept = d;
                    }
                    
                    setAdditionalFields = new Set<String>();
                    setAdditionalFields.add('Department__r.Name');
                    setAdditionalFields.add('Location__r.Name');
                    
                    String deptLeaderId = '';
                    if(dept.Department_Leader__c != null){
                        deptLeaderId = dept.Department_Leader__c;
                    }
                    if(String.isNotBlank(deptLeaderId)){
                        isShowDepartmentLeader = true;
                        List<Employee__c> lstEmployee = new List<Employee__c>();
                        SOQL = prepareQuery('Employee__c',setAdditionalFields);
                        SOQL += ' WHERE Id =:deptLeaderId Limit 1';
                        lstEmployee = (List<Employee__c>)Database.query(SOQL);
                        if(lstEmployee.size() > 0){
                            for(Employee__c e : lstEmployee){
                                deptLeader = e;
                            }
                        }
                        FileId = '';
                        String ContentDocumentIdStr = '';
                        List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: deptLeaderId limit 1];
                        if(lstContentDocumentLink != null && lstContentDocumentLink.size() > 0 ) {
                            ContentDocumentIdStr = lstContentDocumentLink[0].ContentDocumentId;
                        }
                        if(ContentDocumentIdStr != '' && ContentDocumentIdStr != null){
                            for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: ContentDocumentIdStr Limit 1]){
                                FileId = cv.Id;
                            }
                        }
                    }
                    
                }
                
                fetchDepartmentStaff(recordId);
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
            fetchDepartmentStaff(recordId);
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid ID'));
        }
        return null;
    }
    
    //Clear Search Button
    public pageReference doClearSearch(){
        searchString = '';
        if(String.isNotBlank(recordId)){
            fetchDepartmentStaff(recordId);
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid ID'));
        }
        return null;
    }
    
    //Fetch Department Staff
    public pageReference fetchDepartmentStaff(String deptId){
        pageReference pg = null;
        try{
            lstDepartmentStaff = new List<DepartmentStaff>();
            Set<String> setEmployeeIds = new Set<String>();
            Map<String, String> mapEmployeeFileIds = new Map<String, String>();
            Map<String, Employee__c> mapEmployee = new Map<String, Employee__c>();
            String SOQL = '';
            Set<String> setAdditionalFields = new Set<String>();
            setAdditionalFields.add('Department__r.Name');
            setAdditionalFields.add('Location__r.Name');
            
            SOQL = prepareQuery('Employee__c',setAdditionalFields);
            SOQL += ' WHERE Department__c =:deptId';
            
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
                    SOQL += ' AND (Id IN:setEmpIds OR Location__r.Name Like \'%'+searchString+'%\''+ ' ' + ') ';
                }
            }
            
            SOQL += ' ORDER BY Last_Name__c asc';
            List<Employee__c> lstEmployee = (List<Employee__c>)Database.query(SOQL);
            if(lstEmployee.size() > 0){
                for(Employee__c emp : lstEmployee){
                    setEmployeeIds.add(emp.id);
                    mapEmployee.put(emp.Id,emp);
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
                        lstDepartmentStaff.add(new DepartmentStaff(empObj,attId));
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
    
    public class DepartmentStaff{
        
        public Employee__c employee {get;set;} 
        public String fileId {get;set;}
        
        public DepartmentStaff(Employee__c employee, String fileId){
            this.employee = employee;
            this.fileId = fileId;
        }
    }
    
}