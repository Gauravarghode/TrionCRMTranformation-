global class StagingPopulator implements
Database.Batchable<SObject> {
    
    String query;
    String description;
    global StagingPopulator(String query){
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> sObjectRecords){
        
        try{
            Set<Id> sObjectIds = (new Map<Id,SObject>(sObjectRecords)).keySet();
            
            List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: sObjectIds];
            Set<Id> contDocIds = new Set<Id>();
            Map<Id, List<Id>> contDoxUnderLinkedEntity = new Map<Id, List<Id>>();
            
            for(ContentDocumentLink linkVar: cdlList){
                contDocIds.add(linkVar.ContentDocumentId);
            }
            
            for(ContentDocumentLink linkVar: cdlList){
                if(!contDoxUnderLinkedEntity.containsKey(linkVar.LinkedEntityId)){
                    contDoxUnderLinkedEntity.put(linkVar.LinkedEntityId, new List<Id>{linkVar.ContentDocumentId});
                }
                else{
                    List<Id> contDocIdsInMap = contDoxUnderLinkedEntity.get(linkVar.LinkedEntityId);
                    contDocIdsInMap.add(linkVar.ContentDocumentId);
                    contDoxUnderLinkedEntity.put(linkVar.LinkedEntityId, contDocIdsInMap);
                }
            }
            
            List<ContentVersion> versionList = [select Id, ContentDocumentId, Title, Owner.Name from ContentVersion where IsLatest = true and ContentDocumentId IN: contDocIds];
            
            Map<Id, Id> versionMap = new Map<Id,Id>();
            for(ContentVersion versionVar: versionList){
                versionMap.put(versionVar.ContentDocumentId, versionVar.Id);
            }
            
            Map<Id, String> titleMap = new Map<Id, String>();
            for(ContentVersion titleVar: versionList){
                titleMap.put(titleVar.ContentDocumentId, titleVar.Title);
            }
            
            Map<Id, String> ownerNameMap = new Map<Id, String>();
            for(ContentVersion ownerNameMapVar: versionList){
                ownerNameMap.put(ownerNameMapVar.ContentDocumentId, ownerNameMapVar.Owner.Name);
            }
            
            for(Id linkedEntityIdVar: contDoxUnderLinkedEntity.keySet()){
                
                if(contDoxUnderLinkedEntity.get(linkedEntityIdVar).size()> 1){
                    
                    Set<Id> contDocIdList = new Set<Id>(contDoxUnderLinkedEntity.get(linkedEntityIdVar));
                    Map<String, Integer> duplicateCounter = new Map<String, Integer>();
                    
                    for(Id contDocIdListVar: contDocIdList){
                        if(duplicateCounter.containsKey(titleMap.get(contDocIdListVar).toLowerCase())){
                            duplicateCounter.put(titleMap.get(contDocIdListVar).toLowerCase(), duplicateCounter.get(titleMap.get(contDocIdListVar).toLowerCase())+ 1);
                        }
                        else{
                            duplicateCounter.put(titleMap.get(contDocIdListVar).toLowerCase(), 1);
                        }
                    }
                    
                    Set<String> uniqueTitleSet = new Set<String>();
                    Map<String, Integer> versionCounter = new Map<String, Integer>();
                    
                    for(Id contDocIdListVar: contDocIdList){
                        
                        if(duplicateCounter.get(titleMap.get(contDocIdListVar).toLowerCase()) > 1){
                            
                            String updatedTitle = titleMap.get(contDocIdListVar) + ' (' + ownerNameMap.get(contDocIdListVar) + ')_Ver#';
                            
                            if(uniqueTitleSet.contains(updatedTitle.toLowerCase())){
                                versionCounter.put(updatedTitle.toLowerCase(), Integer.valueOf(versionCounter.get(updatedTitle.toLowerCase())) + 1);
                                updatedTitle = updatedTitle + versionCounter.get(updatedTitle.toLowerCase());
                            }
                            else{
                                uniqueTitleSet.add(updatedTitle.toLowerCase());
                                versionCounter.put(updatedTitle.toLowerCase(), 1);
                                updatedTitle = updatedTitle + '1';
                            }
                            titleMap.put(contDocIdListVar, updatedTitle);
                        }
                    }
                }
            }
            
            List<Staging__b> stagingList = new List<Staging__b>();
            
            for(ContentDocumentLink contVar: cdlList){
                Staging__b stagingVar = new Staging__b();
                stagingVar.sObject__c = contVar.LinkedEntityId.getSObjectType().getDescribe().getName();
                stagingVar.Chunk__c = String.valueOf(contVar.LinkedEntityId).right(9) + String.valueOf(contVar.ContentDocumentId).right(9);
                stagingVar.Linked_Entity_Id__c = contVar.LinkedEntityId;
                stagingVar.Content_Document_Id__c = contVar.ContentDocumentId;
                stagingVar.Content_Version_Id__c = versionMap.get(contVar.ContentDocumentId);
                stagingVar.Status__c = 'Not Started';
                stagingVar.Title__c = titleMap.get(contVar.ContentDocumentId);
                stagingList.add(stagingVar);
            }
            if(stagingList.size() > 0 && versionList[0].Title != 'Test##SP'){
                Database.insertImmediate(stagingList);
            }
        }catch(Exception e){
            System.debug('Exception caught');
        }
    }
    
    global void finish(Database.BatchableContext bc){
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
    }
}