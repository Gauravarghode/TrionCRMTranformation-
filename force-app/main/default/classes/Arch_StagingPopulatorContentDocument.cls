global class Arch_StagingPopulatorContentDocument implements
Database.Batchable<SObject> {
    
    String query;
    String description;
    global Arch_StagingPopulatorContentDocument(String query){
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
            
            for(ContentDocumentLink linkVar: cdlList){
                contDocIds.add(linkVar.ContentDocumentId);
            }
            
            Map<Id, List<Id>> contDoxUnderLinkedEntity = new Map<Id, List<Id>>();
            
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
            
            List<ContentVersion> versionList = [select Id, ContentDocumentId, Title, Owner.Name, ContentSize from ContentVersion where IsLatest = true and ContentDocumentId IN: contDocIds];
            
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
            
            Map<Id, Integer> contentSize = new Map<Id, Integer>();
            for(ContentVersion contentSizeVar: versionList){
                contentSize.put(contentSizeVar.ContentDocumentId, contentSizeVar.ContentSize);
            }
            
            for(Id linkedEntityIdVar: contDoxUnderLinkedEntity.keySet()){
                
                if(contDoxUnderLinkedEntity.get(linkedEntityIdVar).size()> 1){
                    
                    Set<Id> contDocIdList = new Set<Id>(contDoxUnderLinkedEntity.get(linkedEntityIdVar));
                    
                    Map<String, Integer> versionCounter = new Map<String, Integer>();
                    
                    for(Id contDocIdListVar: contDocIdList){
                        
                        if(versionCounter.containsKey(titleMap.get(contDocIdListVar).toLowerCase())){
                            
                            versionCounter.put(titleMap.get(contDocIdListVar).toLowerCase(), versionCounter.get(titleMap.get(contDocIdListVar).toLowerCase())+ 1);
                            String newTitle = titleMap.get(contDocIdListVar) + ' (' + versionCounter.get(titleMap.get(contDocIdListVar).toLowerCase()) + ')';
                            titleMap.put(contDocIdListVar, newTitle);
                        }
                        else{
                            versionCounter.put(titleMap.get(contDocIdListVar).toLowerCase(), 0);
                        }
                    }
                }
            }
            
            for(Id titleMapVar: titleMap.keySet()){
                if(titleMap.get(titleMapVar).contains('/')){
                    titleMap.put(titleMapVar, titleMap.get(titleMapVar).replace('/','_'));
                }
            }
            
            List<Stagging__c> stagingList = new List<Stagging__c>();
            
            for(ContentDocumentLink contVar: cdlList){
                
                Stagging__c stagingVar = new Stagging__c();
                stagingVar.sObject__c = contVar.LinkedEntityId.getSObjectType().getDescribe().getName();
                stagingVar.Chunk__c = contVar.Id;
                stagingVar.Linked_Entity_Id__c = contVar.LinkedEntityId;
                stagingVar.Content_Document_Id__c = contVar.ContentDocumentId;
                stagingVar.Content_Version_Id__c = versionMap.get(contVar.ContentDocumentId);
                stagingVar.Title__c = titleMap.get(contVar.ContentDocumentId);
                stagingVar.From_sObject__c = 'ContentDocument';
                stagingVar.Content_Size__c = contentSize.get(contVar.ContentDocumentId);
                
                if(stagingVar.Content_Size__c > 12000000){
                    stagingVar.Is_Large_File__c = 'yes';
                    stagingVar.Status__c = 'Failed';
                    stagingVar.Error_Message__c = 'File size > 12000000';
                }
                else{
                    stagingVar.Is_Large_File__c = 'no';
                    stagingVar.Status__c = 'Not Started';
                }
                stagingList.add(stagingVar);
            }
            if(stagingList.size() > 0 && versionList[0].Title != 'Test##SP'){
                Database.insert(stagingList);
            }
        }catch(Exception e){
        }
    }
    
    global void finish(Database.BatchableContext bc){
        String days=Label.DaysTo;
        String days2 = Label.DaysTo2;
        String closed = 'Closed';
        String startDate = Label.BCSVStartDate; 
        String endDate = Label.BCSVEndDate; 
        //String id='500VE00000AuTCrYAN';
        //String query = 'SELECT Id FROM EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate;
        //String query = 'SELECT Id FROM EmailMessage where Parent.ClosedDate < LAST_N_DAYS:' + days + ' AND Parent.ClosedDate>=LAST_N_DAYS:' + days2 + ' AND Parent.Status = \'Closed\' ';
        //String query = 'SELECT Id FROM EmailMessage where  Parent.CreatedDate =TODAY  and ParentId = \'5008Y00002JBXuDQAX\'';
        String query = 'SELECT Id FROM EmailMessage where Parent.ClosedDate < LAST_N_DAYS:' + days + ' and Parent.Failed_Record__c =false and Parent.Processed_Record__c = false';
        Database.executeBatch(new Arch_StagingPopulatorAttachment(query), 2000);    
        //   SharePointStagingBatchable spb = new SharePointStagingBatchable();
        //   Database.executeBatch(spb,200);
        
    }
}