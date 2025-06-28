trigger QuestionSequenceTrigger on Questions__c (before insert, after delete, before update) {
    
    Decimal maxSequence = 0.0;
    if (Trigger.isBefore && Trigger.isInsert){
        Set<Id> headerIds = new Set<Id>();
        for (Questions__c question : Trigger.new){
            system.debug('question is==== >' +question);
            if (question.Question_Header__c != null){
                headerIds.add(question.Question_Header__c);
                system.debug('headerIds is==== >' +headerIds);
            }
        }
        integer a;
        List<Questions__c> questionsSize = new  List<Questions__c>(Trigger.new);
    
        system.debug('Trigger ==== >' + questionsSize.size());
        //QuestionSequenceTriggerHandler.questionSequence(headerIds, Trigger.new);       
       
    }else if (Trigger.isAfter && Trigger.isDelete){
        //system.debug(trigger.new);
        system.debug('deleted value->>> '+ trigger.old);
        List<Questions__c> deletedRecord = new List<Questions__c>(trigger.old);
        system.debug('deletedRecord->>> '+ deletedRecord);
        Integer listSize = deletedRecord.size();
        system.debug('deletedRecord size->>> '+ listSize);
        
        QuestionSequenceTriggerHandler.deleteSequence(deletedRecord);
      
    }else if ((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)){
        system.debug('allRecords value->>> '+ trigger.new);
        List<Questions__c> allRecords = new List<Questions__c>(trigger.new);
        system.debug('allRecords->>> '+ allRecords);
        
        QuestionSequenceTriggerHandler.duplicateValue(allRecords);
     
   }
}