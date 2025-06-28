global class ContentDocumentBatchExample implements Database.Batchable<sObject> {
    
    Integer contentDocumentCount; 
    Map<Id, Integer> parentObjectAttachmentCountMap; 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM ContentDocument');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        contentDocumentCount = 0; 
        
        Map<Id, Set<Id>> contentDocumentToLinkedEntitiesMap = new Map<Id, Set<Id>>();
        
        for (sObject record : scope) {
            ContentDocument cd = (ContentDocument) record;
            contentDocumentToLinkedEntitiesMap.put(cd.Id, new Set<Id>());
        }
        
        List<ContentDocumentLink> cdLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentToLinkedEntitiesMap.keySet()];
        
        for (ContentDocumentLink link : cdLinks) {
            Id linkedEntityId = link.LinkedEntityId;
            if (linkedEntityId.getSObjectType() != User.SObjectType) {
                contentDocumentToLinkedEntitiesMap.get(link.ContentDocumentId).add(linkedEntityId);
            }
        }
        
        for (Id docId : contentDocumentToLinkedEntitiesMap.keySet()) {
            Set<Id> linkedEntityIds = contentDocumentToLinkedEntitiesMap.get(docId);
            Integer linkedEntityCount = linkedEntityIds.size();
            
            if (linkedEntityCount >= 2) {
                contentDocumentCount++;
                String linkedEntitiesString = 'Linked Entities: ';
                for (Id linkedEntityId : linkedEntityIds) {
                    linkedEntitiesString += linkedEntityId + ' , ' ;
                }
                System.debug('Content Document Id: ' + docId + ' Linked Entity Count>>: ' + linkedEntityCount + ' , ' + linkedEntitiesString);
            }
        }
        
        System.debug('Number of ContentDocument records Which have more than Two linked entities >>>: ' + contentDocumentCount);
        
        parentObjectAttachmentCountMap = new Map<Id, Integer>();
        
        Map<Id, List<Id>> attachmentParentMap = new Map<Id, List<Id>>();
        List<Attachment> attachments = [SELECT Id, ParentId FROM Attachment];        
        //List<Id> attchIds = new List<Id>(); // Corrected declaration
        
        for (Attachment att : attachments) {
            Id attachmentId = att.Id;
            Id parentId = att.ParentId;
            
            if (!attachmentParentMap.containsKey(attachmentId)) {
                attachmentParentMap.put(attachmentId, new List<Id>());
            }
            
            attachmentParentMap.get(attachmentId).add(parentId);
        }
        //attchIds.add(att.Id); 
        
        // System.debug('Parent Object Id: ' + parentId + ', Attachment Id: ' + att.Id); 
        for (Id attachmentId : attachmentParentMap.keySet()) {
            List<Id> parentIds = attachmentParentMap.get(attachmentId);
            Integer parentCount = parentIds.size();
            String parentIdsString = String.join(parentIds, ', ');
            System.debug('Attachment Id: ' + attachmentId + ', Number of Parent Objects Linked: ' + parentCount + ', Parent Object Ids: ' + parentIdsString);
        }
        
    }
    
    
    
    /*for (Id parentId : parentObjectAttachmentCountMap.keySet()) {  
Integer attachmentCount = parentObjectAttachmentCountMap.get(parentId);
List<Id> attachmentIdsForParent = new List<Id>();

for (Attachment att : attachments) {
if (att.ParentId == parentId) {
attachmentIdsForParent.add(att.Id);
}
}*/
    //System.debug('Parent Object Id: ' + parentId + ', Attachment Count>>: ' + attachmentCount + ', Attachment Ids: ' + attachmentIdsForParent);}
    
    //System.debug('Attachment Ids: ' + attchIds);
    
    
    global void finish(Database.BatchableContext BC) {
    }
}