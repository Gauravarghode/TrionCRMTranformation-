public class ClientContactsCompCtrl {

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
    public static String getObjectName(String recordId){
        return String.valueOf(Id.valueOf(recordId).getSobjectType()).toLowerCase();
    }
    
    @AuraEnabled
    public static Proposal__c getProposalDetails(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c pro : [SELECT Id, Client__c,Opportunity__c, Opportunity__r.StageName,
                               Opportunity__r.AccountId
                               FROM Proposal__c 
                               WHERE Id=:recordId]){
            oProposal = pro;
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityDetails(String recordId){
        Opportunity opp = new Opportunity();
        for(Opportunity oOpportunity : [SELECT Id, Proposal__c, StageName,Proposal__r.Client__c, AccountId
                                        FROM Opportunity 
                                        WHERE Id=:recordId]){
            opp = oOpportunity;
        }
        return opp;
    }
    
    @AuraEnabled
    public static Map<String, String> getStatePicklistValues(){
        Map<String, String> mapStatePicklistValues = new Map<String, String>();
        for(State__c oState : [SELECT Id, Name,State_Code__c FROM State__c]){
            mapStatePicklistValues.put(oState.Id, oState.Name+(oState.State_Code__c!=null?' - '+oState.State_Code__c:''));
        }
        return mapStatePicklistValues;
    }
    
    @AuraEnabled
    public static List<Client_Contact__c> getClientContacts(String proposalId, String whereClause){
        List<Client_Contact__c> lstClientContactsWrapper = new List<Client_Contact__c>();
        String sSOQL = 'SELECT Id, First_Name__c, Last_Name__c,Title_Relationship__c,  ';
        sSOQL += ' Email__c,Phone_Number__c, Name, Type__c, Mobile_Phone__c, INC_EXC__c, State__c';
        sSOQL += ' FROM Client_Contact__c';
        sSOQL += ' WHERE Proposal__c=:proposalId';
        
        if(String.isNotBlank(whereClause) && String.isNotEmpty(whereClause)){
            sSOQL += ' AND '+whereClause;
        }
        
        sSOQL += ' ORDER BY First_Name__c, Last_Name__c ASC';
        
        for(Client_Contact__c oClientContact : database.query(sSOQL)){
            lstClientContactsWrapper.add(oClientContact);
        }
        return lstClientContactsWrapper;
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
    public static void saveClientContacts(List<Client_Contact__c> lstClientContacts){
        try{
            update lstClientContacts;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteClientContacts(String clientContactId){
        try{
            Client_Contact__c oClientContact = new Client_Contact__c(Id=clientContactId);
            delete oClientContact;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createClientContacts(String jsonWrapper, Opportunity opp){
        try{
            ClinetContactWrapper oClinetContactWrapper = (ClinetContactWrapper)JSON.deserialize(jsonWrapper, ClinetContactWrapper.class);
            Client_Contact__c oClientContact = new Client_Contact__c();
            if(String.isNotBlank(oClinetContactWrapper.clientContactId) && String.isNotEmpty(oClinetContactWrapper.clientContactId)){
                oClientContact.Id = oClinetContactWrapper.clientContactId;
            }else{
                oClientContact.Proposal__c = opp.Proposal__c;
            }
            oClientContact.First_Name__c = oClinetContactWrapper.firstName;
            oClientContact.Last_Name__c = oClinetContactWrapper.lastName;
            oClientContact.Title_Relationship__c = oClinetContactWrapper.titleRelationship;
            oClientContact.Email__c	 = oClinetContactWrapper.email;
            oClientContact.Phone_Number__c = oClinetContactWrapper.phone;
            
            
            if(oClinetContactWrapper.isIncluded){
                oClientContact.INC_EXC__c = 'Included';
            }else{
                oClientContact.INC_EXC__c = null;
            }
            
            /*else if(!oClinetContactWrapper.isPrimary){
                oClientContact.INC_EXC__c = 'Excluded';
            }*/
            
            oClientContact.Primary__c = oClinetContactWrapper.isPrimary;
            oClientContact.Ownership__c = oClinetContactWrapper.ownership;
            oClientContact.State__c = oClinetContactWrapper.selectedState;
            oClientContact.Payroll__c = oClinetContactWrapper.payroll;
            oClientContact.Location__c = oClinetContactWrapper.selectedClientLocation;
            if(oClinetContactWrapper.selectedStampCode != null && oClinetContactWrapper.selectedStampCode != ''){
                oClientContact.WC_Code__c = oClinetContactWrapper.selectedStampCode;
            }
            oClientContact.Birthdate__c = oClinetContactWrapper.birthdate;
            oClientContact.Duties__c = oClinetContactWrapper.duties;
            oClientContact.Type__c = oClinetContactWrapper.clientContactType;
            oClientContact.Mobile_Phone__c = oClinetContactWrapper.mobilePhone;
            upsert oClientContact;
            
            boolean isUpdateOpp = false;
            if(oClinetContactWrapper.isPrimary){
                if(oClinetContactWrapper.lastName != null && oClinetContactWrapper.lastName != ''){
                    opp.Primary_Contact_Last_Name__c = oClinetContactWrapper.lastName;
                    isUpdateOpp = true;
                }
                if(oClinetContactWrapper.firstName != null && oClinetContactWrapper.firstName != ''){
                    opp.Primary_Contact_First_Name__c = oClinetContactWrapper.firstName;
                    isUpdateOpp = true;
                }
                if(oClinetContactWrapper.phone != null && oClinetContactWrapper.phone != ''){
                    opp.Primary_Contact_Phone__c = oClinetContactWrapper.phone;
                    isUpdateOpp = true;
                }
                if(oClinetContactWrapper.titleRelationship != null && oClinetContactWrapper.titleRelationship != ''){
                    opp.Primary_Contact_Title__c = oClinetContactWrapper.titleRelationship;
                    isUpdateOpp = true;
                }
                if(oClinetContactWrapper.email != null && oClinetContactWrapper.email != ''){
                    opp.Primary_Contact_Email__c = oClinetContactWrapper.email;
                    isUpdateOpp = true;
                } 
            }
            
            if(isUpdateOpp){
                update opp;
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Client_Location__c getNewClientLocation(String proposalId, String stateId, String accId){
        try{
            Id sutaQuoteId;
            Integer loc = 1;
            Client_Location__c oClientLocation = new Client_Location__c();
            
            for(SUTA_Quote__c oQuote : [SELECT Id FROM SUTA_Quote__c 
                                        WHERE State__c=:stateId AND Proposal__c=:proposalId limit 1]){
                sutaQuoteId = oQuote.Id;
            }
            
            if(sutaQuoteId != null){
                for(Client_Location__c clientLocation : [SELECT Id, Loc__c FROM Client_Location__c 
                                                         WHERE Client__c=:accId 
                                                         AND Loc__c != null 
                                                         ORDER BY Loc__c DESC limit 1]){
                    loc += Integer.valueOf(clientLocation.Loc__c);
                }
            }else{
                SUTA_Quote__c oQuote = new SUTA_Quote__c();
                oQuote.Proposal__c = proposalId;
                oQuote.State__c = stateId;
                insert oQuote;
                sutaQuoteId = oQuote.Id;
            }
            
            oClientLocation.Proposal__c = proposalId;
            oClientLocation.SUTA_Quote__c = sutaQuoteId;
            oClientLocation.Client__c = accId;
            oClientLocation.Loc__c = loc;
            
            return oClientLocation;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0)+dmlex.getStackTraceString());
        }catch(Exception ex){
            throw new AuraException(ex.getMessage()+ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String createClientLocation(Client_Location__c oClientLocation){
        try{
            insert oClientLocation;
            return oClientLocation.Id;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getClientLocationValue(String locationId){
        String location = null;
        for(Client_Location__c oClientLocation : [SELECT Id,Location__c 
                                                  FROM Client_Location__c
                                                 WHERE Id=:locationId]){
            location = oClientLocation.Location__c;
        }
        return location;
    }
    
    @AuraEnabled 
    public static ClinetContactWrapper getClientContactRecord(String clientContactId){
        ClinetContactWrapper oClinetContactWrapper = new ClinetContactWrapper();
        for(Client_Contact__c oClientContact : [SELECT First_Name__c, Last_Name__c, Birthdate__c, Primary__c, Email__c,
                                                Mobile_Phone__c, Phone_Number__c, State__c, Client_Location__c, Payroll__c,
                                                INC_EXC__c, Duties__c, Ownership__c, Title_Relationship__c, Type__c, 
                                                Location__c, Proposal__c, WC_Code__c, Id FROM Client_Contact__c WHERE ID =: clientContactId]){
                                                    oClinetContactWrapper.firstName = oClientContact.First_Name__c;
                                                    oClinetContactWrapper.lastName = oClientContact.Last_Name__c;
                                                    oClinetContactWrapper.titleRelationship = oClientContact.Title_Relationship__c;
                                                    oClinetContactWrapper.email = oClientContact.Email__c;
                                                    oClinetContactWrapper.phone = oClientContact.Phone_Number__c;
                                                    oClinetContactWrapper.mobilePhone = oClientContact.Mobile_Phone__c;
                                                    oClinetContactWrapper.ownership = oClientContact.Ownership__c;
                                                    oClinetContactWrapper.selectedState = oClientContact.State__c;
                                                    oClinetContactWrapper.payroll = oClientContact.Payroll__c;
                                                    oClinetContactWrapper.selectedClientLocation = oClientContact.Location__c;
                                                    oClinetContactWrapper.clientLocation = oClientContact.Client_Location__c;
                                                    oClinetContactWrapper.selectedStampCode = oClientContact.WC_Code__c;
                                                    oClinetContactWrapper.primaryContactLastName = oClientContact.Last_Name__c;
                                                    oClinetContactWrapper.primaryContactFirstName = oClientContact.First_Name__c;
                                                    oClinetContactWrapper.primaryContactPhone = oClientContact.Phone_Number__c;
                                                    oClinetContactWrapper.primaryContactTitle = oClientContact.Title_Relationship__c;
                                                    oClinetContactWrapper.primaryContactEmail = oClientContact.Email__c;
                                                    oClinetContactWrapper.clientContactType = oClientContact.Type__c;
                                                    oClinetContactWrapper.birthdate = oClientContact.Birthdate__c;
                                                    oClinetContactWrapper.duties = oClientContact.Duties__c;
                                                    oClinetContactWrapper.isPrimary = oClientContact.Primary__c;
                                                    if(oClientContact.INC_EXC__c =='Included'){
                                                        oClinetContactWrapper.isIncluded = true;
                                                    }
                                                    oClinetContactWrapper.clientContactId = oClientContact.Id;
                                                    
                                                }
        return oClinetContactWrapper;
    }
}