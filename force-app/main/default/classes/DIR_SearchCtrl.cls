/***************************************************************************************
* Name: DIR_SearchCtrl
* Created by Seven Points {DateCreated 5/29/2018} 
----------------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as a ctrl for visualforce page DIR_Search.page
----------------------------------------------------------------------------------------
* Unit Test: DIR_SearchCtrlTest.cls
----------------------------------------------------------------------------------------
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Seven Points 5/29/2018 INITIAL DEVELOPMENT
****************************************************************************************/

public class DIR_SearchCtrl {
    
    public string searchString {get;set;}
    public string searchError {get;set;}
    public List<EmployeeWrapper> lstEmployeeWrapper {get;set;}
    public Boolean isShowDifferentViews {get;set;}
    
    public DIR_SearchCtrl(){
        try{
            isShowDifferentViews = true;
            lstEmployeeWrapper = new List<EmployeeWrapper>();
            if(ApexPages.currentPage().getParameters().containsKey('search')){
                searchString = ApexPages.currentPage().getParameters().get('search');
                
                Set<String> setAdditionalFields = new Set<String>();
                setAdditionalFields.add('Department__r.Name');
                setAdditionalFields.add('Location__r.Name');
                
                String SOQL = '';
                Set<String> setEmployeeIds = new Set<String>();
                Map<String, Employee__c> mapEmployee = new Map<String, Employee__c>();
                Map<String, String> mapEmployeeFileIds = new Map<String, String>();
                
                searchError = '';
                if (searchString != '' && searchString != null) { 
                    searchString = searchString.trim();
                    if (searchString.length() < 2) {
                        searchError = 'You must include at least two characters in the search string.';
                    }
                    if (searchError == '') {
                        
                        SOQL = prepareQuery('Employee__c',setAdditionalFields);
                        SOQL += ' WHERE Name Like \'%'+searchString+'%\'';
                        
                        SOQL += ' ORDER BY Last_Name__c asc ';
                        List<Employee__c> lstEmployee = (List<Employee__c>)Database.query(SOQL);
                        
                        if(lstEmployee.size() > 0){
                            for(Employee__c emp : lstEmployee){
                                setEmployeeIds.add(emp.id);
                                mapEmployee.put(emp.Id, emp);
                            }
                        }
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
                            lstEmployeeWrapper.add(new EmployeeWrapper(empObj,attId));
                        }
                    }
                }
                
            }else{
                lstEmployeeWrapper = new List<EmployeeWrapper>();
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
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
    
    public class EmployeeWrapper{ 
        
        public Employee__c employee {get;set;} 
        public String fileId {get;set;}
        
        public EmployeeWrapper(Employee__c employee, String fileId){
            this.employee = employee;
            this.fileId = fileId;
        }
    }
}