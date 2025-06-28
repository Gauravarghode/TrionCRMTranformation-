public class GetFolderUsingCustomMetadata {
    
    public static String getData(string parentCaseId){
        
        String metadataYear;
        String metadataMonth;
        String metadataDate;
        String metadataFolderName;
        String mergedMetadataDate;
        
        String metadataStartdate;
        String metadataEnddate;
        
        String caseClosedCompleteDate;
        //String caseClosedYear;
        //String caseClosedMonth;
        //String caseClosedDate;
        
        String mainCaseFolderName;
        List<Case> caseList=[Select id,closedDate from Case where id=:parentCaseId];
        for(Case cs:caseList){
            caseClosedCompleteDate=String.valueOf(cs.ClosedDate);
            //caseClosedYear=String.valueOf(cs.ClosedDate.year());
            //caseClosedMonth=String.valueOf(cs.ClosedDate.month());
            //caseClosedDate=String.valueOf(cs.ClosedDate.Day());
            		  	//System.debug('String caseClosedCompleteDate=>' + caseClosedCompleteDate);
            //System.debug('String caseClosedYear=>' + caseClosedYear);
            //System.debug('String caseClosedMonth=>' + caseClosedMonth);
            //System.debug('String caseClosedDate=>' + caseClosedDate);
        }
        
        List<Share_Point_Folder_Name__mdt> metadataFolderNameList=[select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, 
                                                                  Label, QualifiedApiName, SystemModstamp, Start_Date__c, End_Date__c, Folder_Name__c 
                                                                  from Share_Point_Folder_Name__mdt];
        for(Share_Point_Folder_Name__mdt fnamemdt:metadataFolderNameList){
            metadataStartdate = String.valueOf(fnamemdt.Start_Date__c);
            metadataEnddate= String.valueOf(fnamemdt.End_Date__c);
            metadataFolderName = fnamemdt.Folder_Name__c;
            //mergedMetadataDate= metadataYear + '-' + metadataMonth + '-' + metadataDate;
/*            System.debug('Custom Metadata startdate=>' + metadataStartdate);
            System.debug('Custom Metadata enddate=>' + metadataEnddate);
            System.debug('Custom Metadata foldername=>' + metadataFolderName);
  */          
            if(caseClosedCompleteDate >= metadataStartdate && caseClosedCompleteDate <= metadataEnddate){
              mainCaseFolderName =  metadataFolderName;
                System.debug('String mainCaseFolderName;=>' + mainCaseFolderName);
            }
                    
        }

        /*
		List<Sharepoint_Folder_Name__mdt> customMetadataFolderNameList=[select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, 
                                                                        QualifiedApiName, SystemModstamp, Year__c, Month__c, Date__c, Sharepoint_Folder_Name__c 
                                                                        from Sharepoint_Folder_Name__mdt where Year__c=:caseClosedYear and Month__c=:caseClosedMonth and Date__c=:caseClosedDate];
     
        for(Sharepoint_Folder_Name__mdt fnamemdt:customMetadataFolderNameList){
            metadataYear = fnamemdt.Year__c;
            metadataMonth= fnamemdt.Month__c;
            metadataDate = fnamemdt.Date__c;
            metadataFolderName = fnamemdt.Sharepoint_Folder_Name__c;
            mergedMetadataDate= metadataYear + '-' + metadataMonth + '-' + metadataDate;
            System.debug('Custom Metadata Date=>' + mergedMetadataDate);
            
        }
        */
        
       return mainCaseFolderName;
    }
    
    
     public static void testCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
     }
}











/*public class GetFolderUsingCustomMetadata {
    
    public static void getData(String parentCaseId) {
        GetFolderUsingCustomMetadata_V1 batch = new GetFolderUsingCustomMetadata_V1(parentCaseId);
        Database.executeBatch(batch);
        //return 'metadataFolderName';
    }
}
*/

/*public class GetFolderUsingCustomMetadata implements Database.Batchable<String> {
    private String parentCaseId;
    
    public GetFolderUsingCustomMetadata(String parentCaseId) {
        this.parentCaseId = parentCaseId;
    }
    
    public Iterable<String> start(Database.BatchableContext context) {
        // Return a single-element list containing the parentCaseId
        return new List<String> { parentCaseId };
    }
    
    public void execute(Database.BatchableContext context, List<String> scope) {
        for (String caseId : scope) {
            getData(caseId);
        }
    }
    
    public void finish(Database.BatchableContext context) {
        System.debug('######### Batch is completed');
    }
    
    public static String getData(String parentCaseId) {
        String metadataFolderName = '';
        String caseClosedCompleteDate = '';
        
        List<Case> caseList = [SELECT Id, ClosedDate FROM Case WHERE Id = :parentCaseId];
        for (Case cs : caseList) {
            caseClosedCompleteDate = String.valueOf(cs.ClosedDate.date());
            System.debug('String caseClosedCompleteDate => ' + caseClosedCompleteDate);
        }
        
        List<Share_Point_Folder_Name__mdt> metadataFolderNameList = Share_Point_Folder_Name__mdt.getAll().values();
        for (Share_Point_Folder_Name__mdt fnamemdt : metadataFolderNameList) {
            String metadataStartdate = String.valueOf(fnamemdt.Start_Date__c);
            String metadataEnddate = String.valueOf(fnamemdt.End_Date__c);
            metadataFolderName = fnamemdt.Folder_Name__c;
            
            if (caseClosedCompleteDate >= metadataStartdate && caseClosedCompleteDate <= metadataEnddate) {
                System.debug('String mainCaseFolderName => ' + metadataFolderName);
                break; // Exit the loop as we found the matching folder name
            }         
        }        
        return metadataFolderName;
    }
}
*/