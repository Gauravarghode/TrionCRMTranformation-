public class UnderwritingEvaluationCompCtrl {

    @AuraEnabled
    public static boolean isButtonVisibilitySOQLFilter(String visibilitysoqlFilter, String recordId){
        boolean isButtonVisible = false;
        String objName = String.valueOf(Id.valueOf(recordId).getSobjectType());
        if(objName != null && objName != ''){
            String soql = 'SELECT Id FROM '+objName;
            if(!visibilitysoqlFilter.toLowerCase().contains('where')){
                soql += ' WHERE ';
            }
            soql += ' '+visibilitysoqlFilter;
            soql += ' AND Id=:recordId ';
            for(sObject obj : database.query(soql)){
                isButtonVisible = true;
            }
        }
        return isButtonVisible;
    }
    
    @AuraEnabled
    public static Proposal__c getProposalDetails(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c proposal : [SELECT Id,Average_Aged_Years__c,Average_Developed_Losses_Per_Year__c,
                                    Average_Losses_Per_Year__c,Final_Recommended_Premium__c,
                                    Selected_Losses__c,Total_Aged_Months__c,Total_Developed_Losses__c,
                                    Total_Losses__c,Total_of_Claims__c
                                    FROM Proposal__c 
                                    WHERE Id=:recordId]){
            oProposal = proposal;
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static List<UnderwritingEvaluationWrapper> getLossYearsAndEvaluationRecords(String proposalId){
        List<UnderwritingEvaluationWrapper> lstUnderwritingEvaluationWrapper = new List<UnderwritingEvaluationWrapper>();
        Map<Id, Loss_Year__c> mapLossYear = new Map<Id,Loss_Year__c>();
        Map<Id, List<Loss_Year_Evaluation__c>> mapLossYearEvaluations = new Map<Id, List<Loss_Year_Evaluation__c>>();
        
        for(Loss_Year__c oLossYear : [SELECT Id,Name,Program_Year__c,LDF__c,of_Claims__c,
                                      Total_Losses__c,Total_Paid__c,Total_Reserves__c,
                                      Developed_Losses__c,Year_Name__c, Excluded_Losses__c
                                      FROM Loss_Year__c 
                                      WHERE Proposal__c =: proposalId
                                     ORDER BY Name ASC]){
            mapLossYear.put(oLossYear.Id, oLossYear);
        }
        
        if(!mapLossYear.isEmpty()){
            for(Loss_Year_Evaluation__c oEvaluation : [SELECT Id,Loss_Year__c,Aged_Months__c,LDF__c,of_Claims__c,
                                                       Policy_Start_Date__c,Policy_End_Date__c,Total_Reserves__c,
                                                       Developed_Losses__c,Total_Losses__c,Valued__c,Name,Year_Name__c,
                                                       Carrier__c,Total_Paid__c,Loss_Year_Text__c, Excluded_Losses__c
                                                       FROM Loss_Year_Evaluation__c 
                                                       WHERE Loss_Year__c IN: mapLossYear.keyset()
                                                      ORDER BY Loss_Year__c ASC]){
                if(!mapLossYearEvaluations.containsKey(oEvaluation.Loss_Year__c)){
                   mapLossYearEvaluations.put(oEvaluation.Loss_Year__c, new List<Loss_Year_Evaluation__c>());
                }
                mapLossYearEvaluations.get(oEvaluation.Loss_Year__c).add(oEvaluation);
            }
        }
        
        if(!mapLossYear.isEmpty()){
            for(Loss_Year__c oLossYear : mapLossYear.values()){
                UnderwritingEvaluationWrapper oWrapper = new UnderwritingEvaluationWrapper();
                oWrapper.oLossYear = oLossYear;
                oWrapper.lstLossYearEvaluationWrapper = new List<LossYearEvaluationWrapper>();
                if(mapLossYearEvaluations.containsKey(oLossYear.Id)){
                    for(Loss_Year_Evaluation__c oEvaluation : mapLossYearEvaluations.get(oLossYear.Id)){
                        LossYearEvaluationWrapper oEvaluationWrapper = new LossYearEvaluationWrapper();
                        oEvaluationWrapper.oLossYearEvaluation = oEvaluation;
                        oWrapper.lstLossYearEvaluationWrapper.add(oEvaluationWrapper);
                    }
                }
                lstUnderwritingEvaluationWrapper.add(oWrapper);
            }
        }
        
        return lstUnderwritingEvaluationWrapper;
    }
    
    @AuraEnabled
    public static void deleteLossYear(String jsonWrap){
        try{
            List<UnderwritingEvaluationWrapper> lstUnderwritingEvaluationWrapper = (List<UnderwritingEvaluationWrapper>) JSON.deserialize(jsonWrap, List<UnderwritingEvaluationWrapper>.class);
            
            List<Loss_Year__c> lstLossYear = new List<Loss_Year__c>();
            
            for(UnderwritingEvaluationWrapper oWrapper : lstUnderwritingEvaluationWrapper){
                if(oWrapper.isDelete && oWrapper.isSelected){
                    lstLossYear.add(oWrapper.oLossYear);
                }
            }
            
            if(lstLossYear.size()>0){
                delete lstLossYear;
            }
            
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteLossYearEvaluation(String recordId){
        try{
            Loss_Year_Evaluation__c oEvaluation = new Loss_Year_Evaluation__c(Id=recordId);
            delete oEvaluation;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteParentLossYear(String lossYearId){
        try{
            Loss_Year__c olossYear = new Loss_Year__c(Id=lossYearId);
            delete olossYear;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getYears(){
        Map<String, String> mapYears = new Map<String, String>();
        for(Year__c oYear : [SELECT Id, Name FROM Year__c ORDER BY Name ASC]){
            mapYears.put(oYear.Id, oYear.Name);
        }
        return mapYears;
    }
    
    @AuraEnabled
    public static void updateEvaluationYears(List<Loss_Year_Evaluation__c> lstLossYearEvaluation, String yearId, String proposalId){
        try{
            boolean isExistingLossYearFound = false;
            Loss_Year__c oLossYear;
            for(Loss_Year__c lossYear : [SELECT Id FROM Loss_Year__c 
                                          WHERE Program_Year__c =:yearId AND Proposal__c =:proposalId]){
                oLossYear = lossYear;
                isExistingLossYearFound = true;                             
            }
            
            if(!isExistingLossYearFound){
                oLossYear = new Loss_Year__c();
                oLossYear.Program_Year__c = yearId;
                oLossYear.Proposal__c = proposalId;
                insert oLossYear;
            }
            
            for(Loss_Year_Evaluation__c lye : lstLossYearEvaluation){
                lye.Loss_Year__c = oLossYear.Id;
            }
            
            update lstLossYearEvaluation;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createLossYearEvaluation(Loss_Year_Evaluation__c oLossYearEvaluation, String yearId, String proposalId){
        try{
            boolean isExistingLossYearFound = false;
            Loss_Year__c oLossYear;
            for(Loss_Year__c lossYear : [SELECT Id FROM Loss_Year__c 
                                          WHERE Program_Year__c =:yearId AND Proposal__c =:proposalId]){
                oLossYear = lossYear;
                isExistingLossYearFound = true;                             
            }
            
            if(!isExistingLossYearFound){
                oLossYear = new Loss_Year__c();
                oLossYear.Program_Year__c = yearId;
                oLossYear.Proposal__c = proposalId;
                insert oLossYear;
            }
            oLossYearEvaluation.Proposal__c = proposalId;
            oLossYearEvaluation.Loss_Year__c = oLossYear.Id;
            insert oLossYearEvaluation; 
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createLossYearAndLossYearEvaluation(String yearId, String proposalId){
        try{
            boolean isExistingLossYearFound = false;
            Loss_Year__c oLossYear;
            Loss_Year_Evaluation__c oLossYearEvaluation;
            
            for(Loss_Year__c lossYear : [SELECT Id FROM Loss_Year__c 
                                          WHERE Program_Year__c =:yearId AND Proposal__c =:proposalId]){
                oLossYear = lossYear;
                isExistingLossYearFound = true;                             
            }
            
            if(!isExistingLossYearFound){
                oLossYear = new Loss_Year__c();
                oLossYear.Program_Year__c = yearId;
                oLossYear.Proposal__c = proposalId;
                insert oLossYear;
                
                oLossYearEvaluation = new Loss_Year_Evaluation__c();
                oLossYearEvaluation.Proposal__c = proposalId;
                oLossYearEvaluation.Loss_Year__c = oLossYear.Id;
                insert oLossYearEvaluation; 
            }else{
                boolean isHaveEvalutaion = false;
                
                for(Loss_Year_Evaluation__c lye : [SELECT Id FROM Loss_Year_Evaluation__c 
                                                   WHERE Loss_Year__c=:oLossYear.Id
                                                  AND Proposal__c =:proposalId]){
                    isHaveEvalutaion = true;
                }
                
                if(!isHaveEvalutaion){
                    oLossYearEvaluation = new Loss_Year_Evaluation__c();
                    oLossYearEvaluation.Proposal__c = proposalId;
                    oLossYearEvaluation.Loss_Year__c = oLossYear.Id;
                    insert oLossYearEvaluation; 
                }
                
            }
            
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
}