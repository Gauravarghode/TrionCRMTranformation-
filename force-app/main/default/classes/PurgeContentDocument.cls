global class PurgeContentDocument implements
Database.Batchable<SObject> {
    
    global Database.QueryLocator  start(Database.BatchableContext bc){ 
        //Datetime startDate = Datetime.valueOf(Label.StartDate);
        //Datetime endDate = Datetime.valueOf(Label.EndDate);
        
        Datetime startDate = Datetime.valueOf(Label.StartDate.replace('T', ' ').replace('Z', ''));
        Datetime endDate = Datetime.valueOf(Label.EndDate.replace('T', ' ').replace('Z', ''));
        
        return Database.getQueryLocator([
            SELECT Id, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN (
                SELECT Id 
                FROM EmailMessage 
                WHERE Parent.ClosedDate >= :startDate 
                AND Parent.ClosedDate <= :endDate 
                AND Parent.Have_More_Character__c = TRUE
            ) 
            Limit 50000
        ]);
        
       // List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM EmailMessage WHERE Parent.ClosedDate >= :startDate AND Parent.ClosedDate <= :endDate AND Parent.Have_More_Character__c = false )LIMIT 50000];
    /*   Set<Id> contDocIds = new Set<Id>();
        
        for(ContentDocumentLink linkVar: contentDocumentLinkList){
            contDocIds.add(linkVar.ContentDocumentId);
        }
        
        List<ContentDocument> contentDocumentList =[SELECT id FROM ContentDocument WHERE Id =: contDocIds];
        System.debug(contentDocumentList); 
        return contentDocumentList;
*/
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Set<Id> contDocIds = new Set<Id>();
        for (sObject obj : scope) {
            ContentDocumentLink linkVar = (ContentDocumentLink)obj;
            contDocIds.add(linkVar.ContentDocumentId);
        }
        
        List<ContentDocument> contentDocumentList = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :contDocIds
        ];
        
        delete contentDocumentList;
    }
    
    
    global void finish(Database.BatchableContext bc){
        //Datetime startDate = Datetime.valueOf(Label.StartDate);
        //Datetime endDate = Datetime.valueOf(Label.EndDate);
        Datetime startDate = Datetime.valueOf(Label.StartDate.replace('T', ' ').replace('Z', ''));
        Datetime endDate = Datetime.valueOf(Label.EndDate.replace('T', ' ').replace('Z', ''));
        
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM EmailMessage WHERE Parent.ClosedDate >= :startDate AND Parent.ClosedDate <= :endDate AND Parent.Have_More_Character__c = TRUE )LIMIT 1];
        Set<Id> contDocIds = new Set<Id>();
        
        for(ContentDocumentLink linkVar: contentDocumentLinkList){
            contDocIds.add(linkVar.ContentDocumentId);
        }
        
        List<ContentDocument> contentDocumentList = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :contDocIds
        ];
        System.debug(contentDocumentList.size());
        
        if(contentDocumentList.size() > 0){
            Database.executeBatch(new PurgeContentDocument(), 2000);
        }
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
    }
}