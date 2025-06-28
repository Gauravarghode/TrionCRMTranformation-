@isTest
public class TestDataFactory_SP{
    
    public static list<Staging__b> insertStagingBigObj(Boolean doInsert,ContentVersion cv){
        list<Staging__b> stageList = new list<Staging__b>();
        for(integer i =0;i<=500;i++){
            Staging__b bigObjVar = new Staging__b();
            bigObjVar.Chunk__c='123456abcde789'+i;
            bigObjVar.Content_Version_Id__c = cv.id;
            bigObjVar.sObject__c='Account'+i;
            bigObjVar.Linked_Entity_Id__c='001a5678bcderff'+i;
            bigObjVar.Status__c='Not Started';
            stageList.add(bigObjVar);
        }
        if(doInsert==true){
            // Database.insertImmediate(stageList); 
            List<Database.SaveResult> result =database.insertImmediate(stageList);
        }
        return stageList;
        
    }
    
    public static list<Staging__b> sharePointTestData(Boolean doInsert){
        list<Staging__b> stageList = new list<Staging__b>();
        // Create a Staging__b record for testing
        for(Staging__b sb: stageList){
            Staging__b record2 = new Staging__b();
            record2.Linked_Entity_Id__c = 'Parent10'; 
            record2.Content_Document_Id__c = 'Doc10'; 
            record2.Chunk__c = 'Chunk10';
            record2.Status__c = 'Not Started';
            stageList.add(record2);
        }
        if(doInsert==True){
            Database.insertImmediate(stageList); 
        }
        return stageList;
    }
}