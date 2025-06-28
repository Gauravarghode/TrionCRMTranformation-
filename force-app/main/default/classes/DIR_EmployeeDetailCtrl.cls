/***************************************************************************************
* Name: DIR_EmployeeDetailCtrl
* Created by Seven Points {DateCreated 5/28/2018} 
----------------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as a ctrl for visualforce page DIR_EmployeeDetail.page
----------------------------------------------------------------------------------------
* Unit Test: DIR_EmployeeDetailCtrlTest.cls
----------------------------------------------------------------------------------------
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Seven Points 5/28/2018 INITIAL DEVELOPMENT
****************************************************************************************/

public class DIR_EmployeeDetailCtrl {
    
    public String recordId {get;set;}
    public Employee__c emp {get;set;}
    public String FileId {get;set;}
    
    public Employee__c reportToEmployee {get;set;}
    public String reportEmployeeFileId {get;set;}
    public Boolean isShowReportsTo {get;set;}
    public  Boolean isShowReportsToEmployees {get;set;}
    public List<ReportsToEmployees> lstReportsToEmployees {get;set;}
    
    public DIR_EmployeeDetailCtrl(ApexPages.StandardController sc){
        try{
            recordId = sc.getId();
            isShowReportsTo = false;
            isShowReportsToEmployees = false;
            lstReportsToEmployees = new List<ReportsToEmployees>();
            
            if(String.isNotBlank(recordId)){
                emp = new Employee__c();
                List<Employee__c> lstEmployee = new List<Employee__c>();
                Set<String> setAdditionalFields = new Set<String>();
                setAdditionalFields.add('Department__r.Name');
                setAdditionalFields.add('Location__r.Name');
                
                reportToEmployee = new Employee__c();
                String reportToEmployeeId = '';
                
                String SOQL = prepareQuery('Employee__c',setAdditionalFields);
                SOQL += ' WHERE Id =:recordId Limit 1';
                lstEmployee = (List<Employee__c>)Database.query(SOQL);
                if(lstEmployee.size() > 0){
                    for(Employee__c e : lstEmployee){
                        emp = e;
                        if(e.Reports_To__c != null){
                            reportToEmployeeId = e.Reports_To__c;
                        }
                    }
                }
                
                FileId = '';
                String ContentDocumentIdStr = '';
                
                List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId limit 1];
                if(lstContentDocumentLink != null && lstContentDocumentLink.size() > 0 ) {
                    ContentDocumentIdStr = lstContentDocumentLink[0].ContentDocumentId;
                }
                if(ContentDocumentIdStr != '' && ContentDocumentIdStr != null){
                    for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: ContentDocumentIdStr Limit 1]){
                        FileId = cv.Id;
                    }
                }
                
                if(String.isNotBlank(reportToEmployeeId)){
                    isShowReportsTo = true;
                    lstEmployee = new List<Employee__c>();
                    SOQL = prepareQuery('Employee__c',setAdditionalFields);
                    SOQL += ' WHERE Id =:reportToEmployeeId Limit 1';
                    lstEmployee = (List<Employee__c>)Database.query(SOQL);
                    if(lstEmployee.size() > 0){
                        for(Employee__c e : lstEmployee){
                            reportToEmployee = e;
                        }
                    }
                    reportEmployeeFileId = '';
                    ContentDocumentIdStr = '';
                    lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: reportToEmployeeId limit 1];
                    if(lstContentDocumentLink != null && lstContentDocumentLink.size() > 0 ) {
                        ContentDocumentIdStr = lstContentDocumentLink[0].ContentDocumentId;
                    }
                    if(ContentDocumentIdStr != '' && ContentDocumentIdStr != null){
                        for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: ContentDocumentIdStr Limit 1]){
                            reportEmployeeFileId = cv.Id;
                        }
                    }
                    
                    Set<String> setEmployeeIds = new Set<String>();
                    Map<String, Employee__c> mapEmployee = new Map<String, Employee__c>();
                    Map<String, String> mapEmployeeFileIds = new Map<String, String>();
                    
                    List<Employee__c> lstReportsToEmps = new List<Employee__c>();
                    SOQL = prepareQuery('Employee__c',setAdditionalFields);
                    SOQL += ' WHERE Reports_To__c =:reportToEmployeeId ORDER By Last_Name__c';
                    lstReportsToEmps = (List<Employee__c>)Database.query(SOQL);
                    if(lstReportsToEmps.size() > 0){
                        for(Employee__c emp : lstReportsToEmps){
                            setEmployeeIds.add(emp.id);
                            mapEmployee.put(emp.Id,emp);
                        }
                        if(setEmployeeIds.size() > 0){
                            Map<String, String> mapContentDocumentLink = new Map<String, String>();
                            for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :setEmployeeIds]){
                                mapContentDocumentLink.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                            }
                            if(mapContentDocumentLink != null && mapContentDocumentLink.keySet().size() > 0){
                                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :mapContentDocumentLink.keySet()]){
                                    String rtFileId = cv.Id;
                                    if(mapContentDocumentLink.containsKey(cv.ContentDocumentId)){
                                        mapEmployeeFileIds.put(mapContentDocumentLink.get(cv.ContentDocumentId), rtFileId);
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
                                    lstReportsToEmployees.add(new ReportsToEmployees(empObj,attId));
                                }
                            }
                            isShowReportsToEmployees = true;
                        }
                    }
                }
                
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid ID'));
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
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
    
    public class ReportsToEmployees{
        
        public Employee__c employee {get;set;} 
        public String fileId {get;set;}
        
        public ReportsToEmployees(Employee__c employee, String fileId){
            this.employee = employee;
            this.fileId = fileId;
        }
    }
    
}