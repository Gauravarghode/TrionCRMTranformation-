public class SubmissionDocumentsCompCtrl {

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
    public static String getObjectName(String recordId){
        return String.valueOf(Id.valueOf(recordId).getSobjectType()).toLowerCase();
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityDetails(String recordId){
        Opportunity opp = new Opportunity();
        for(Opportunity oOpportunity : [SELECT Id, Proposal__c, StageName,Proposal__r.Client__c
                                        FROM Opportunity 
                                        WHERE Id=:recordId]){
            opp = oOpportunity;
        }
        return opp;
    }
    
    @AuraEnabled
    public static Proposal__c getProposalDetails(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c pro : [SELECT Id, Client__c,Opportunity__c, Opportunity__r.StageName,
                               Opportunity__r.AccountId, Nature_of_Business_Description__c,
                               Proposed_Effective_Date__c, Proposed_Exp_Date__c,
                               TOTAL_ESTIMATED_ANNUAL_PREMIUM_ALL_STATE__c
                               FROM Proposal__c 
                               WHERE Id=:recordId]){
            oProposal = pro;
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static List<Submission_Requirement__c> getSubmissionRequirement(String recordId, String status, String Requiredstatus){
        List<Submission_Requirement__c> lstSubmissionRequirement = new List<Submission_Requirement__c>();
        String sSOQL = 'SELECT Id, Name, Opportunity__c, Notes__c,Required_Optional__c, ';
        sSOQL += ' Requirement_Type__c,Status__c, Nature_of_Business_Description__c, ';
        sSOQL += ' EACH_ACCIDENT__c, DISEASE_POLICY_LIMIT__c, DISEASE_EACH_EMPLOYEE__c, ';
        sSOQL += ' U_S_L_H__c, VOLUNTARY_COMP__c, FOREIGN_COV__c, MANAGED_CARE_OPTION__c, ACORD_Type__c ';
        sSOQL += ' FROM Submission_Requirement__c';
        sSOQL += ' WHERE Opportunity__c =:recordId';
        
        if(String.isNotBlank(status) && String.isNotEmpty(status)){
            sSOQL += ' AND Status__c =:status';
        }
        if(String.isNotBlank(Requiredstatus) && String.isNotEmpty(Requiredstatus)){
            sSOQL += ' AND Required_Optional__c =:Requiredstatus';
        }
        
        for(Submission_Requirement__c oRequirement : database.query(sSOQL)){
            lstSubmissionRequirement.add(oRequirement);
        }
        
        return lstSubmissionRequirement;
    }
    
    @AuraEnabled
    public static void updateSubmissionRequirement(Proposal__c oProposal, Submission_Requirement__c oSubmissionRequirement, String notes, boolean isSubmit){
        try{
           if(isSubmit){
                oSubmissionRequirement.Status__c = 'Submitted';
            }
            
            if(String.isNotBlank(notes) && String.isNotEmpty(notes)){
                oSubmissionRequirement.Notes__c = notes;
            }
            update oSubmissionRequirement;
            update oProposal;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createProposalAndupdateSubmissionRequirement(Proposal__c oProposal, Submission_Requirement__c oSubmissionRequirement, String submissionRequirementId, String notes, boolean isSubmit){
        try{
            //insert oProposal;
            
            //Submission_Requirement__c oSubmissionRequirement = new Submission_Requirement__c();
            oSubmissionRequirement.Id = submissionRequirementId;
            if(isSubmit){
                oSubmissionRequirement.Status__c = 'Submitted';
            }
            if(String.isNotBlank(notes) && String.isNotEmpty(notes)){
                oSubmissionRequirement.Notes__c = notes;
            }
            update oSubmissionRequirement;
            
            update oProposal;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> getContentDocumentId(String parentId){
        //String conentDocumentId;
        List<String> conentDocumentId = new List<String>();
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:parentId]){
            //conentDocumentId = cdl.ContentDocumentId;
            conentDocumentId.add(cdl.ContentDocumentId);
        }
        return conentDocumentId;
    }
    
    @AuraEnabled
    public static void deleteFileAndUpdateSubmissionRequirement(String submissionRequirementId){
        try{
            String conentDocumentId;
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId 
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId=:submissionRequirementId limit 1]){
                conentDocumentId = cdl.ContentDocumentId;
            }
            
            if(conentDocumentId != null && conentDocumentId != ''){
                ContentDocument oContentDocument = new ContentDocument(Id=conentDocumentId);
                delete oContentDocument;
                
                Submission_Requirement__c oSubmissionRequirement = new Submission_Requirement__c();
                oSubmissionRequirement.Id = submissionRequirementId;
                oSubmissionRequirement.Status__c = 'Not Started';
                update oSubmissionRequirement;
            }else{
                throw new AuraException('No Document found!');
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<WC_Rate__c> getWCRate(String proposalId){
        List<WC_Rate__c> lstRate = new List<WC_Rate__c>();
        for(WC_Rate__c rate : [SELECT Id, Name, Client_Location__r.Location__c,Description__c,Part_Time_Employees__c,
                                of_Employees__c,Gross_Wages__c,Current_Rate__c,Estimated_Annual_Manual_Premium__c,
                               SUTA_Quote__r.State__c, State_Comp_Code__c, Client_Location__c, Proposal__c, 
                               SUTA_Quote__r.State__r.Name, Client_Location__r.Loc__c
                               FROM WC_Rate__c 
                               WHERE Proposal__c=:proposalId]){
          lstRate.add(rate);  
        }
        return lstRate;
    }
    
    @AuraEnabled
    public static void updateWCRate(WC_Rate__c oWCRate){
        try{
            boolean isDuplicate = false;

            for(WC_Rate__c oRate : [SELECT Id FROM WC_Rate__c 
                                    WHERE Id!=:oWCRate.Id 
                                    AND State_Comp_Code__c =:oWCRate.State_Comp_Code__c
                                    AND Client_Location__c =:oWCRate.Client_Location__c
                                    AND Proposal__c =: oWCRate.Proposal__c]){
             isDuplicate = true;
           }

            
            if(!isDuplicate){
                /*
                if(oWCRate.State_Comp_Code__c != null){
                    for(State_Comp_Code__c oCode : [SELECT Id, WC_Code__c FROM State_Comp_Code__c WHERE Id=:oWCRate.State_Comp_Code__c]){
                        oWCRate.Comp_Code__c = oCode.WC_Code__c;
                    }
                }
                update oWCRate;   
                */             
            }else{
                throw new AuraException('Duplicate Record Found!');
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getClientLocationPicklistValues(String proposalId, String stateId){
        Map<String, String> mapClientLocationPicklistValues = new Map<String, String>();
        for(Client_Location__c oClientLocation : [Select Id, Name, Location__c FROM Client_Location__c 
                                                  WHERE Proposal__c=:proposalId 
                                                  AND SUTA_Quote__r.State__c =:stateId]){
            String location = null;
            if(oClientLocation.Location__c != null){
                location = oClientLocation.Location__c.replaceAll('<br>', ' ');        
            }
            mapClientLocationPicklistValues.put(oClientLocation.Id, oClientLocation.Name+' - '+(location!=null?location:''));
        }
        return mapClientLocationPicklistValues;
    }
    
    @AuraEnabled
    public static Map<String, String> getPicklistValues(String objectName, String fieldName){
        Map<String, String> mapPicklistValues = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            mapPicklistValues.put(pickListVal.getValue(), pickListVal.getLabel());
        }    
        return mapPicklistValues;
    }
    
    @AuraEnabled
    public static boolean isShowCongaButtons(String submissionDocId){
        boolean isShowCongaButton = false;
        Submission_Requirement__c oSubmissionRequirement = new Submission_Requirement__c();
        for(Submission_Requirement__c sr : [SELECT Id,Proposal_Id__c,Opportunity__c,Client__c,
                                            Partner_Server_URL_370__c,Requirement_Type__c
                                            FROM Submission_Requirement__c WHERE Id=:submissionDocId]){
            oSubmissionRequirement = sr;
        }
        for(APXTConga4__Conga_Solution__c cs : [SELECT Id, APXTConga4__Solution_Description__c FROM APXTConga4__Conga_Solution__c]){
            if(cs.APXTConga4__Solution_Description__c==oSubmissionRequirement.Requirement_Type__c){
                isShowCongaButton = true;  
                break;
            }
        }
        return isShowCongaButton;
    }
    
    @AuraEnabled
    public static String getAccordSignatureRequestURL(String submissionDocId){
        Submission_Requirement__c oSubmissionRequirement = new Submission_Requirement__c();
        for(Submission_Requirement__c sr : [SELECT Id,Proposal_Id__c,Opportunity__c,Client__c,
                                            Partner_Server_URL_370__c,Requirement_Type__c,Accord_Signature_Conga_URL__c
                                            FROM Submission_Requirement__c WHERE Id=:submissionDocId]){
            oSubmissionRequirement = sr;
        }
        
        boolean isCongaSolutionConfigured = false;
        for(APXTConga4__Conga_Solution__c cs : [SELECT Id, APXTConga4__Solution_Description__c FROM APXTConga4__Conga_Solution__c]){
            if(cs.APXTConga4__Solution_Description__c==oSubmissionRequirement.Requirement_Type__c){
                isCongaSolutionConfigured = true;  
                break;
            }
        }
        String sURL = '';
        if(isCongaSolutionConfigured|| Test.isRunningTest()){
            /*sURL += System.Label.SD_AccordSignatureCongaURL;
            sURL = sURL.replaceAll('Partner_Server_URL_370__c', oSubmissionRequirement.Partner_Server_URL_370__c);
            sURL = sURL.replaceAll('SFId', oSubmissionRequirement.Id);
            sURL = sURL.replaceAll('Proposal_Id__c', oSubmissionRequirement.Proposal_Id__c);
           	sURL = sURL.replaceAll('Opportunity__c', oSubmissionRequirement.Opportunity__c);
            sURL = sURL.replaceAll('Client__c', oSubmissionRequirement.Client__c);*/
            sURL = oSubmissionRequirement.Accord_Signature_Conga_URL__c;
        }
        return sURL;
    }
    
    @AuraEnabled
    public static String getGenerateACORD(String submissionDocId){
        Submission_Requirement__c oSubmissionRequirement = new Submission_Requirement__c();
        for(Submission_Requirement__c sr : [SELECT Id,Proposal_Id__c,Opportunity__c,Client__c,
                                            Partner_Server_URL_370__c,Requirement_Type__c,
                                            Generate_ACORD_Conga_URL__c
                                            FROM Submission_Requirement__c WHERE Id=:submissionDocId]){
            oSubmissionRequirement = sr;
        }
        
        boolean isCongaSolutionConfigured = false;
        for(APXTConga4__Conga_Solution__c cs : [SELECT Id, APXTConga4__Solution_Description__c FROM APXTConga4__Conga_Solution__c]){
            if(cs.APXTConga4__Solution_Description__c==oSubmissionRequirement.Requirement_Type__c){
                isCongaSolutionConfigured = true;  
                break;
            }
        }
        String sURL = '';
        if(isCongaSolutionConfigured || Test.isRunningTest()){
            /*sURL += System.Label.SD_GenerateACORDURL;
            sURL = sURL.replaceAll('Partner_Server_URL_370__c', oSubmissionRequirement.Partner_Server_URL_370__c);
            sURL = sURL.replaceAll('SFId', oSubmissionRequirement.Id);
            sURL = sURL.replaceAll('Proposal_Id__c', oSubmissionRequirement.Proposal_Id__c);
           	sURL = sURL.replaceAll('Opportunity__c', oSubmissionRequirement.Opportunity__c);
            sURL = sURL.replaceAll('Client__c', oSubmissionRequirement.Client__c);*/
            sURL = oSubmissionRequirement.Generate_ACORD_Conga_URL__c;
        }
        return sURL;
    }
}