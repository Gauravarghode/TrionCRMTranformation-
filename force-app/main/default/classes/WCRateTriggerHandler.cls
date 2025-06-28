public class WCRateTriggerHandler {
    
    //Trigger execution check variable
    public static Boolean runOnce = true;
    
    public static void onBeforeInsert(List<WC_Rate__c> newList, Map<Id, WC_Rate__c> oldMap){ 
        setWCRateFields(newList, null);
    }
    
    public static void onBeforeUpdate(List<WC_Rate__c> newList, Map<Id, WC_Rate__c> oldMap){ 
        setWCRateFields(newList, null);
    }
    
    public static void onAfterInsert(List<WC_Rate__c> newList, Map<Id, WC_Rate__c> oldMap){
         
    }
    
    public static void onAfterUpdate(List<WC_Rate__c> newList, Map<Id, WC_Rate__c> oldMap){
         
    }
     
     
    public static void setWCRateFields(List<WC_Rate__c> newList, Map<Id, WC_Rate__c> oldMap){
        Set<Id> setSUTAQuoteId = new Set<Id>();
        Set<Id> setClientLocationId = new Set<Id>();
        set<Id> setStateCompCode = new Set<Id>();

        MAP<Id,SUTA_Quote__c> mapSUTAQuote = new MAP<Id,SUTA_Quote__c>();
        MAP<Id,Client_Location__c> mapClientLocation = new MAP<Id,Client_Location__c>();
        MAP<Id,State_Comp_Code__c> mapStateCompCode = new MAP<Id,State_Comp_Code__c>();
        SET<Id> setClientLocPostalCode = new SET<Id>();
        SET<Id> setSCCState = new SET<Id>();
        SET<Id> setSSCWCCode = new SET<Id>();
        SET<Id> setSUTAPolicy = new SET<Id>();
        
        for(WC_Rate__c oRate : newList){
            oRate.Carrier_WC_Rate__c = null;
            setSUTAQuoteId.add(oRate.SUTA_Quote__c);
            if(oRate.Client_Location__c != null){
                setClientLocationId.add(oRate.Client_Location__c);
            }
            if(oRate.State_Comp_Code__c != null){
                setStateCompCode.add(oRate.State_Comp_Code__c);
            }
        }
        
        if(setSUTAQuoteId.size()>0){
            for(SUTA_Quote__c oQuote : [SELECT Id, Name, Policy__c,Policy__r.Carrier__c,Policy__r.Territorial_Rating__c, State_Assessment_Fee_and_surcharge__c, State_Assessment_Fee_Surcharge_Included__c  FROM SUTA_Quote__c 
                                        WHERE Id IN : setSUTAQuoteId  ]){ 
                mapSUTAQuote.put(oQuote.Id,oQuote);   
                if(oQuote.Policy__c != null ){
                    setSUTAPolicy.add(oQuote.Policy__c);
                }    
           }
        }

        if(setClientLocationId.size()>0){
            for(Client_Location__c cl : [SELECT Id,Postal_Code__c FROM Client_Location__c 
                                        WHERE Id IN : setClientLocationId ]){ 
                mapClientLocation.put(cl.Id,cl);      
                setClientLocPostalCode.add(cl.Postal_Code__c);                    
           }
        }
        
        if(setStateCompCode.size()>0){
            for(State_Comp_Code__c scc : [SELECT Id,State__c,WC_Code__c FROM State_Comp_Code__c 
                                        WHERE Id IN : setStateCompCode ]){ 
                mapStateCompCode.put(scc.Id,scc);      
                setSCCState.add(scc.State__c);   
                setSSCWCCode.add(scc.WC_Code__c);                    
           }
        }

        // Set Policy__c, Carrier__c and Assessment_fee__c
        for(WC_Rate__c oRate : newList){ 
                
                if(oRate.SUTA_Quote__c != null && mapSUTAQuote.containsKey(oRate.SUTA_Quote__c)){
 
                    SUTA_Quote__c oQuote = mapSUTAQuote.get(oRate.SUTA_Quote__c);

                    if(oQuote.Policy__c != null){
                        oRate.Policy__c = oQuote.Policy__c;
                    }
                    
                    if(oQuote.State_Assessment_Fee_Surcharge_Included__c && oQuote.State_Assessment_Fee_and_surcharge__c != null){
                        oRate.Assessment_fee__c = oQuote.State_Assessment_Fee_and_surcharge__c; 
                    }else {
                        oRate.Assessment_fee__c = 0; 
                    } 
                }
        }

        // set Carrier_WC_Rate__c
        if(mapStateCompCode.size() > 0){
            List<Carrier_WC_Rate__c> listCWCRate = [Select Id,Policy__c,State__c,WC_Code__c From Carrier_WC_Rate__c 
                                                    Where Policy__c IN: setSUTAPolicy AND State__c IN: setSCCState AND WC_Code__c IN: setSSCWCCode];
        
            for(WC_Rate__c oRate : newList){ 
                if(oRate.SUTA_Quote__c != null && mapSUTAQuote.containsKey(oRate.SUTA_Quote__c) && oRate.State_Comp_Code__c != null && mapStateCompCode.containsKey(oRate.State_Comp_Code__c) ){
                    for(Carrier_WC_Rate__c cwc: listCWCRate){
                        if(cwc.Policy__c == mapSUTAQuote.get(oRate.SUTA_Quote__c).Policy__c && cwc.State__c == mapStateCompCode.get(oRate.State_Comp_Code__c).State__c && cwc.WC_Code__c == mapStateCompCode.get(oRate.State_Comp_Code__c).WC_Code__c){
                            oRate.Carrier_WC_Rate__c = cwc.Id;
                            break;
                        }
                    }
                }
            }
        }

        // set Territory__c
        if(setClientLocPostalCode.size()>0){
            
            List<Territory_Assignment__c> listTerrAsgn = [Select Id,Carrier_Territory__c,Zip_Code__c,Territory__r.Carrier__c From Territory_Assignment__c Where Carrier_Territory__c != null AND
                                                            Zip_Code__c != null AND Zip_Code__c IN:setClientLocPostalCode AND
                                                            Territory__r.Carrier__c != null AND Status__c = 'Active' ];
            for(WC_Rate__c oRate : newList){ 
                if(oRate.SUTA_Quote__c != null && oRate.Client_Location__c != null && mapSUTAQuote.containsKey(oRate.SUTA_Quote__c) && mapClientLocation.containsKey(oRate.Client_Location__c)){

                    for(Territory_Assignment__c terr: listTerrAsgn){
                        if(terr.Zip_Code__c == mapClientLocation.get(oRate.Client_Location__c).Postal_Code__c &&   terr.Territory__r.Carrier__c == mapSUTAQuote.get(oRate.SUTA_Quote__c).Policy__r.Carrier__c && mapSUTAQuote.get(oRate.SUTA_Quote__c).Policy__r.Territorial_Rating__c == true ){
                            oRate.Territory__c = terr.Carrier_Territory__c;
                            break;
                        }
                    }
                }
            }
        }
         
    }
     
    
}