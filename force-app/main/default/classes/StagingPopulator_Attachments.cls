global class StagingPopulator_Attachments implements
Database.Batchable<SObject> {
    
    String query;
    String description;
    global StagingPopulator_Attachments(String query){
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> sObjectRecords){
        
        try{
            Set<Id> sObjectIds = (new Map<Id,SObject>(sObjectRecords)).keySet();
            
            List<Attachment> attList = [select Id, ParentId, Name, BodyLength from Attachment
                                        where ParentId IN: sObjectIds
                                        order by createddate asc];
            System.debug('Size is '+ attList.size());
            Map<Id, String> attachmentNameById = new Map<Id, String>();
            
            for(Attachment attVar: attList){
                if((attVar.Name).right(8).contains('.')){
                    String lastChar = ((attVar.Name).right(8));
                    String removeThis = lastChar.substring(lastChar.lastIndexOf('.'));
                    attVar.Name = attVar.Name.removeEnd(removeThis);
                }
                attachmentNameById.put(attVar.Id, attVar.Name);
            }
            
            Map<Id, List<Id>> attachmentsUnderParentId = new Map<Id, List<Id>>();
            
            for(Attachment attVar: attList){
                if(!attachmentsUnderParentId.containsKey(attVar.ParentId)){
                    attachmentsUnderParentId.put(attVar.ParentId, new List<Id>{attVar.Id});
                }
                else{
                    List<Id> contDocIdsInMap = attachmentsUnderParentId.get(attVar.ParentId);
                    contDocIdsInMap.add(attVar.Id);
                    attachmentsUnderParentId.put(attVar.ParentId, contDocIdsInMap);
                }
            }
            
            for(String attParentIdsVar: attachmentsUnderParentId.keySet()){
                
                if(attachmentsUnderParentId.get(attParentIdsVar).size()> 1){
                    
                    Set<Id> attachmentsUnderParent = new Set<Id>(attachmentsUnderParentId.get(attParentIdsVar));
                    Map<String, Integer> versionNumber = new Map<String, Integer>();
                    
                    for(Id attachmentsUnderParentVar: attachmentsUnderParent){
                        
                        if(versionNumber.containsKey(attachmentNameById.get(attachmentsUnderParentVar))){
                            
                            versionNumber.put(attachmentNameById.get(attachmentsUnderParentVar), Integer.valueOf(versionNumber.get(attachmentNameById.get(attachmentsUnderParentVar))+ 1));
                            String newAttachmentName = attachmentNameById.get(attachmentsUnderParentVar) + ' (' + versionNumber.get(attachmentNameById.get(attachmentsUnderParentVar)) + ')';
                            attachmentNameById.put(attachmentsUnderParentVar, newAttachmentName);
                        }
                        else{
                            versionNumber.put(attachmentNameById.get(attachmentsUnderParentVar), 0);
                        } 
                    }
                }
            }
            
            for(Id attachmentNameByIdVar: attachmentNameById.keySet()){
                if(attachmentNameById.get(attachmentNameByIdVar).contains('/')){
                    attachmentNameById.put(attachmentNameByIdVar, attachmentNameById.get(attachmentNameByIdVar).replace('/','_'));
                }
            }
                        
            List<Staging__b> stagingList = new List<Staging__b>();
            
            for(Attachment attVar: attList){
                
                Staging__b stagingVar = new Staging__b();
                stagingVar.sObject__c = attVar.ParentId.getSObjectType().getDescribe().getName();
                stagingVar.Chunk__c = attVar.Id;
                stagingVar.Linked_Entity_Id__c = attVar.ParentId;
                //stagingVar.Is_Large_File__c = (stagingVar.Content_Size__c > 12000000)? 'yes': 'no';
                //stagingVar.Status__c = (stagingVar.Content_Size__c > 12000000)? 'Failed': 'Not Started';
                stagingVar.Title__c = attachmentNameById.get(attVar.Id);
                stagingVar.From_sObject__c = 'Attachment';
                stagingVar.Content_Size__c = attVar.BodyLength;
                
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
            if(stagingList.size() > 0 && attList[0].Name != 'Test##SP'){
                Database.insertImmediate(stagingList);
            }
        }catch(Exception e){
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
}