public class QuestionSequenceTriggerHandler {
    
    
    public static void questionSequence(Set<id> headerIds, List<Questions__c> questionList){
        integer addVal;
        List<Questions__c> existingQuestionList = [SELECT Id,Question__c, Question_Header__c, Question_Sequence__c, Question_Sequence_Test__c, Question_Sequence_new__c 
                                           FROM Questions__c WHERE Question_Header__c IN :headerIds ORDER BY Question_Sequence_Test__c ASC];
        Integer existiungQuestionsSize = existingQuestionList.size();
        system.debug('existiungQuestionsSize is==== >' +existiungQuestionsSize);
        
        if (!headerIds.isEmpty()) {
            Map<Id, List<Questions__c>> questionsByHeader = new Map<Id, List<Questions__c>>();
            for (Questions__c existingQuestion : existingQuestionList){
                if (!questionsByHeader.containsKey(existingQuestion.Question_Header__c)){
                    questionsByHeader.put(existingQuestion.Question_Header__c, new List<Questions__c>());
                    system.debug('questionsByHeader is1111111111==== >' +questionsByHeader);
                }
                questionsByHeader.get(existingQuestion.Question_Header__c).add(existingQuestion);
                system.debug('questionsByHeader is22222222222222==== >' +questionsByHeader);
            }
            system.debug('questionsByHeader is33333333333==== >' +questionsByHeader);
            
            Map<Id, Decimal> headerSequences = new Map<Id, Decimal>();
            for (Question_Header__c header : [SELECT Id, Sequence__c FROM Question_Header__c WHERE Id IN :headerIds]){
                headerSequences.put(header.Id, header.Sequence__c);
                system.debug('headerSequences is==== >' +headerSequences);
            }
            system.debug('headerSequences is (Outside loop)==== >' +headerSequences);
            String questionQuestionSequence;
            
            
            addVal = 1;
            for (Questions__c question : questionList){
                if (question.Question_Header__c != null && headerSequences.containsKey(question.Question_Header__c)){
                    Decimal headerSequence = headerSequences.get(question.Question_Header__c);
                    system.debug('Decimal headerSequence is==== >' +headerSequence);
                    Integer nextSubSequence = questionsByHeader.containsKey(question.Question_Header__c) ? questionsByHeader.get(question.Question_Header__c).size() + addVal : addVal;
                    system.debug('Decimal nextSubSequence is==== >' +nextSubSequence);
                    //question.Question_Sequence__c = Decimal.valueOf(headerSequence) + (nextSubSequence / 100);
                    //question.Question_Sequence_Test__c = String.valueOf(headerSequence + (nextSubSequence / 100));
                    question.Question_Sequence_new__c = String.valueOf(nextSubSequence);
                    system.debug('addVal==== >' +addVal);
                    system.debug('questionList.size()==== >' +questionList.size());
                    if(questionList.size() > addVal){
                        addVal++;
                    }
                    system.debug('question.Question_Sequence_Test__c 11111111==== >' +question.Question_Sequence_new__c);
                    questionQuestionSequence = question.Question_Sequence_new__c;
                }
                system.debug('question.Question_Sequence_Test__c 222222222222==== >' +question.Question_Sequence_new__c);
            }        
            system.debug('questionQuestionSequence==== >' +questionQuestionSequence);
        }
    }
    
    
    public static void deleteSequence(List<Questions__c> deletedRecord){
        set<id> deletedId = new set<id>();
        String questionSequence; 
        for(Questions__c questss : deletedRecord){
            deletedId.add(questss.Question_Header__c);
            questionSequence = questss.Question_Sequence_new__c;
        }
        system.debug('deletedId ->>> '+ deletedId);
        system.debug('questionSequence ->>> '+ questionSequence);
        
        List<Questions__c> updatedRecords = new List<Questions__c>();
        for(Questions__c quests : [SELECT Id, Question__c, Data_Type__c, Question_Header__c, Question_choices__c, Question_Sequence__c, Sequence2__c, 
                                   Question_Sequence_Test__c, Question_Header_Sequence__c, Question_Sequence_new__c, Sequence__c, Sequence_Date_Check__c  
                                   FROM Questions__c where /*Question_Sequence_new__c > : questionSequence  
                                   AND*/ Question_Header__c IN: deletedId]){
                                       if(integer.valueOf(quests.Question_Sequence_new__c) > integer.valueOf(questionSequence)){
                                       system.debug('quests ->>> '+ quests);
                                       system.debug('quests.Question_Sequence_new__c BEFORE ->>> '+ quests.Question_Sequence_new__c);
                                       quests.Question_Sequence_new__c = String.valueOf(Integer.valueOf(quests.Question_Sequence_new__c) - 1);
                                       system.debug('quests.Question_Sequence_new__c AFTER->>> '+ quests.Question_Sequence_new__c);
                                       quests.Sequence_Date_Check__c = system.today();
                                       system.debug('quests.Sequence_Date_Check__c ->>> '+ quests.Sequence_Date_Check__c);
                                       updatedRecords.add(quests);                                       
                                   }
                                   }
        Update updatedRecords; 
        //Database.update(updatedRecords, False); 
        system.debug('List<Questions__c> updatedRecords->>> '+ updatedRecords);       
    }

    
    public static void duplicateValue(List<Questions__c> allRecords){
        String questionSequenceNumber;
        String question;
        set<id> updatedQuestionHeaderId = new set<id>();
        Set<Id> recordIds = new Set<Id>();
        
        for(Questions__c triggeredValue : allRecords){
            questionSequenceNumber = triggeredValue.Question_Sequence_new__c;
            question = triggeredValue.Question__c;
            updatedQuestionHeaderId.add(triggeredValue.Question_Header__c);
            recordIds.add(triggeredValue.Id);
        }
        system.debug('questionSequenceNumber->>> '+ questionSequenceNumber);
        system.debug('question->>> '+ question);
        system.debug('updatedQuestionHeaderId->>> '+ updatedQuestionHeaderId);
        
        List<Questions__c> questionsList = [SELECT Id, Data_Type__c, Question__c, Question_Header__c, Question_choices__c, Question_Sequence__c, Sequence2__c, 
                                            Question_Sequence_Test__c, Question_Header_Sequence__c, Question_Sequence_new__c, Sequence__c, Sequence_Date_Check__c 
                                            FROM Questions__c Where Question_Header__c IN: updatedQuestionHeaderId AND Question_Sequence_new__c =: questionSequenceNumber AND Id NOT IN :recordIds];
        
        // Filter the records manually in Apex to check for duplicate Questions
    Map<Id, Questions__c> duplicateRecords = new Map<Id, Questions__c>();
    for (Questions__c record : questionsList) {
        for (Questions__c triggeredValue : allRecords) {
            if (record.Question__c == triggeredValue.Question__c &&
                record.Question_Sequence_new__c == triggeredValue.Question_Sequence_new__c) {
                duplicateRecords.put(triggeredValue.Id, record);
            }
        }
    }
        
        // Add error if duplicates are found
    for (Questions__c questsnew : allRecords) {
        if (duplicateRecords.containsKey(questsnew.Id)) {
            questsnew.addError('Duplicate Value Found: Another record has the same Question and Sequence Number.');
        }
    }
        
        if(!questionsList.isEmpty()){
            for(Questions__c questsnew : allRecords){
                if(questsnew.Sequence_Date_Check__c == null){
                    questsnew.addError('Duplicate Value Found');
                    system.debug('questsnew.Sequence_Date_Check__c->>> '+ questsnew.Sequence_Date_Check__c);    
                }else {
                    questsnew.Sequence_Date_Check__c = null;
                }
            }
        }        
    }
}