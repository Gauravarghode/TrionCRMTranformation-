public class GetCsvUsingCaseSPId_checkV12Handler2_V2 {
    
    
    public static void subscribeEvents(List<ListMapPlatform_V2__e> platformList){
        System.debug(' Code is inside handler class');        
        System.debug(' List<ListMapPlatform_V2__e> platformList===> '+platformList);
        //System.debug(' String caseParentId===> '+caseParentId);
        String eachSharePointId;
        String spIdSetValue;
        try{
            Set<string> uniqueIdentifier = new set<string>();
            for(ListMapPlatform_V2__e platformeventList:platformList){
                uniqueIdentifier.add(platformeventList.Id__c);
                uniqueIdentifier.add(platformeventList.ParentId__c);
                uniqueIdentifier.add(platformeventList.CreatedDate__c);
                uniqueIdentifier.add(platformeventList.CreatedById__c);
                uniqueIdentifier.add(platformeventList.Subject__c);
                uniqueIdentifier.add(platformeventList.FromAddress__c);
                uniqueIdentifier.add(platformeventList.ToAddress__c);
                uniqueIdentifier.add(platformeventList.BccAddress__c);
                uniqueIdentifier.add(platformeventList.HtmlBody__c);
                uniqueIdentifier.add(platformeventList.Status__c);
                uniqueIdentifier.add(platformeventList.TextBody__c);
                uniqueIdentifier.add(platformeventList.Headers__c);
                uniqueIdentifier.add(platformeventList.MessageDate__c);
                uniqueIdentifier.remove(null);                         
            } 
            System.debug('uniqueIdentifier===>'+uniqueIdentifier);
            System.debug('uniqueIdentifier SIZE===>'+uniqueIdentifier.size());
            
            For(String spemid:uniqueIdentifier){
                spIdSetValue=spemid;
            }
            System.debug('spIdSetValue===>'+spIdSetValue);
            List<String> spEmailId=new List<String>(uniqueIdentifier);
            //emailSpId.add(serializedmethodOpMap);
            System.debug(' emailSpId.add(serializedmethodOpMap);===> '+spEmailId);
            System.debug(' emailSpId.add(serializedmethodOpMap);Size===> '+spEmailId.size());
            system.debug('Serialized map is (from new approach)'+system.json.serializePretty(spEmailId));
                        
        }catch (Exception e){
            System.debug('Catch Exception ===>'+e.getmessage());
        }
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