({
	doInit : function(component, event, helper) {
		helper.handleInitlization(component, event);
	},
    toggleStateRecord: function(component, event, helper) {
        var lstSUTAQuoteWrapper = component.get("v.lstSUTAQuoteWrapper");
        var index = event.getSource().get("v.value");
        lstSUTAQuoteWrapper[index].isExpaned = !lstSUTAQuoteWrapper[index].isExpaned;
        component.set("v.lstSUTAQuoteWrapper", lstSUTAQuoteWrapper);
    },
    toggleClientRecord: function(component, event, helper) {
        var index = event.getSource().get("v.value");
        if(index != null && index != undefined){
            var indexArr = index.split("_");
            var lstSUTAQuoteWrapper = component.get("v.lstSUTAQuoteWrapper");
            var quoteWrapper = lstSUTAQuoteWrapper[indexArr[0]];
            var clientLocationWrapper = quoteWrapper.lstClientLocationWrapper[indexArr[1]];
            clientLocationWrapper.isExpaned = !clientLocationWrapper.isExpaned;
            component.set("v.lstSUTAQuoteWrapper", lstSUTAQuoteWrapper);
        }
    },
    
    handleShowAddStateModal : function(component, event, helper) {
        var lstSUTAQuoteToInsert = [{'sobjectType ':'SUTA_Quote__c', 'State__c': null}];
        component.set("v.lstSUTAQuoteToInsert", lstSUTAQuoteToInsert);
        component.set("v.isShowAddStateModal", true);
        component.set("v.selectedStateId", null);
    },
    
    handleAddMoreStateModal: function(component, event, helper) {
        var lstSUTAQuoteToInsert = component.get("v.lstSUTAQuoteToInsert");
        lstSUTAQuoteToInsert.push({'sobjectType ':'SUTA_Quote__c', 'State__c': null});
        component.set("v.lstSUTAQuoteToInsert", lstSUTAQuoteToInsert);
    },
    
    handleCloseAddStateModal : function(component, event, helper) {
        component.set("v.isShowAddStateModal", false);
        component.set("v.selectedStateId", null);
        component.set("v.lstSUTAQuoteToInsert", []);
    },
    
    handleAddStateModal : function(component, event, helper) {
        var lstSUTAQuoteToInsert = component.get("v.lstSUTAQuoteToInsert");
        if(lstSUTAQuoteToInsert != null && lstSUTAQuoteToInsert != undefined){
            var isRequiredFieldMissing = false;
            
            for(var i=0;i<lstSUTAQuoteToInsert.length;i++){
                document.getElementById('ST__'+i).style = "background-Color : transparent !important";
                if(lstSUTAQuoteToInsert[i].State__c == null || lstSUTAQuoteToInsert[i].State__c == undefined){
					isRequiredFieldMissing = true;
                    document.getElementById('ST__'+i).style = "background-Color : #a01c1c !important";
                }
            }
            
            if(isRequiredFieldMissing){
                helper.doShowToast(component, 'Error', 'Please select valid state and try again', 'error');
            }else{
                var isDuplicate = false;
                for(var i=0;i<lstSUTAQuoteToInsert.length;i++){
                    document.getElementById('ST__'+i).style = "background-Color : transparent !important";
                    for(var j=0;j<lstSUTAQuoteToInsert.length;j++){
                        if(i != j && lstSUTAQuoteToInsert[i].State__c == lstSUTAQuoteToInsert[j].State__c){
                            document.getElementById('ST__'+i).style = "background-Color : #a01c1c !important";
                            isDuplicate = true;
                        }
                    }
                }
                
                if(isDuplicate){
                    helper.doShowToast(component, 'Error', 'Dupicate State selected, please remove try again.', 'error');
                }else{
                    helper.createStateHelper(component, event);
                }
                
            }
        }
    },
    
    handleAddStateDelete: function(component, event, helper){
        var index = event.getSource().get("v.name");
        var lstSUTAQuoteToInsert = component.get("v.lstSUTAQuoteToInsert");
        lstSUTAQuoteToInsert.splice(index, 1);
        if(lstSUTAQuoteToInsert.length == 0){
            lstSUTAQuoteToInsert.push({'sobjectType ':'SUTA_Quote__c', 'State__c': null});
        }
        component.set("v.lstSUTAQuoteToInsert", lstSUTAQuoteToInsert);
    },
    
    handleShowAddLocation : function(component, event, helper){
        helper.showSpinner(component);
        var index = event.target.dataset.index;
        component.set("v.locationIndex", index);
        var oClientLocation = {'sobjectType ':'Client_Location__c','Client__c':null,'SUTA_Quote__c':null,'Proposal__c':null,'Loc__c':null,'Postal_Code__c':null};
        let loc = 1;
		component.set("v.isTerritorialRating", false);
		var lstSUTAQuoteWrapper = component.get("v.lstSUTAQuoteWrapper");
        if(lstSUTAQuoteWrapper != null && lstSUTAQuoteWrapper != undefined){
            let oQuoteWrapperObj = lstSUTAQuoteWrapper[index];
            let oQuoteObj = oQuoteWrapperObj.oQuote;
            /*if(oQuoteObj.State__c != null && oQuoteObj.State__c != undefined && oQuoteObj.State__r.Territorial_Rating__c != undefined && oQuoteObj.State__r.Territorial_Rating__c){
                component.set("v.isTerritorialRating", true);
            }*/
            if(oQuoteObj.State_Name__c != null && oQuoteObj.State_Name__c != undefined && oQuoteObj.State_Name__c == 'California'){
                component.set("v.isTerritorialRating", true);
            }
            component.set("v.selectedStateName", oQuoteObj.State_Name__c);
            
            if(oQuoteObj.Proposal__r.Opportunity__r.AccountId != null && oQuoteObj.Proposal__r.Opportunity__r.AccountId != undefined){
                oClientLocation.Client__c = oQuoteObj.Proposal__r.Opportunity__r.AccountId;
            }
            oClientLocation.SUTA_Quote__c = oQuoteObj.Id;
            oClientLocation.Proposal__c = oQuoteObj.Proposal__c;
            /*let loc = 1;
            console.log("***lstClientLocationWrapper***"+JSON.stringify(oQuoteWrapperObj.lstClientLocationWrapper));
            if(oQuoteWrapperObj.lstClientLocationWrapper != null && oQuoteWrapperObj.lstClientLocationWrapper != undefined){
                for(let i=0;i<oQuoteWrapperObj.lstClientLocationWrapper.length;i++){
                    loc = oQuoteWrapperObj.lstClientLocationWrapper[i].oClientLocation.Loc__c+1;
                }
            }*/
            oClientLocation.Loc__c = loc;
            var exeAction = component.get("c.getNewClientLocation");
            exeAction.setParams( {
                "proposalId": component.get("v.oProposal.Id"),
                "stateId":oQuoteObj.State__c,
                "accId":component.get("v.oProposal.Opportunity__r.AccountId")
            });
            helper.serverSideCall(component,exeAction).then(function(res) {
                if(res != null && res != undefined){
                    component.set("v.oClientLocation", res);
                }else{
                    component.set("v.oClientLocation", oClientLocation);
                }
               
                component.set("v.isShowAddLocationModal", true);
                helper.hideSpinner(component);
            }).catch(function(error) {
                console.log(error);
                helper.handleErrors(component, error);
                helper.hideSpinner(component);
            });
        }else{
            oClientLocation.Loc__c = loc;
            component.set("v.oClientLocation", oClientLocation);
            component.set("v.isShowAddLocationModal", true);
            helper.hideSpinner(component);
        }
    },
    
    handleCancelAddLocation : function(component, event, helper){
        component.set("v.isShowAddLocationModal", false);
        component.set("v.isTerritorialRating", false);
        var oClientLocation = component.get("v.oClientLocation");
        oClientLocation.Client__c = null;
        oClientLocation.SUTA_Quote__c = null;
        oClientLocation.Proposal__c = null;
        oClientLocation.Loc__c = null;
        oClientLocation.Street__c = null;
        oClientLocation.County__c = null;
        oClientLocation.Postal_Code__c = null;
        oClientLocation.Zip_Code__c = null;
        component.set("v.oClientLocation", oClientLocation);
        component.set("v.locationIndex", null);
    },
    
    handleAddLocation : function(component, event, helper){
        let isValidate = helper.validateForm(component, 'street,city,Zip_Code', false);
        if(isValidate){
            var isTerritorialRating = component.get("v.isTerritorialRating");
            if(isTerritorialRating){
                var postalCode =  component.get("v.oClientLocation.Postal_Code__c");
                if(postalCode != null && postalCode != undefined){
                    helper.createLocationHelperHelper(component, event);
                }else{
                    helper.doShowToast(component, 'Error', 'Please select valid Postal Code and try again.', 'error');    
                }
            }else{
                helper.createLocationHelperHelper(component, event);    
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill all required information and try again.', 'error');    
        }
    },
    
    handleShowAddWCRateModal : function(component, event, helper){
        var index = event.target.dataset.index;
        component.set("v.wcRateIndex", index);
        var wcRate = {'sobjectType ':'WC_Rate__c','SUTA_Quote__c':null,'Proposal__c':null, 
                      'State_Comp_Code__c':null, 'of_Employees__c':null, 
                      'Part_Time_Employees__c':null, 'Gross_Wages__c':null,
                      'Current_Rate__c':null,
                      'Client_Location__c':null}
        var lstSUTAQuoteWrapper = component.get("v.lstSUTAQuoteWrapper");
        if(lstSUTAQuoteWrapper != null && lstSUTAQuoteWrapper != undefined){
            var indexArr = index.split("_");
            var quoteWraper = lstSUTAQuoteWrapper[indexArr[0]];
            var clientLocationWrapper = quoteWraper.lstClientLocationWrapper[indexArr[1]];
            wcRate.SUTA_Quote__c = quoteWraper.oQuote.Id;
            wcRate.Proposal__c = quoteWraper.oQuote.Proposal__c;
            wcRate.Client_Location__c = clientLocationWrapper.oClientLocation.Id;
            var whereClause = ' State__c = \''+quoteWraper.oQuote.State__c+'\'';
            component.set("v.wcRateWhereClause", whereClause);
        }
        
        component.set("v.oWCRate", wcRate);
        component.set("v.isShowAddWCRateModal", true);
    },
 	handleCancelAddWCRateModal : function(component, event, helper){
        var wcRate = {'sobjectType ':'WC_Rate__c','SUTA_Quote__c':null,'Proposal__c':null, 
                      'State_Comp_Code__c':null, 'of_Employees__c':null, 
                      'Part_Time_Employees__c':null, 'Gross_Wages__c':null,'Current_Rate__c':null,
                      'Client_Location__c':null}
        
        component.set("v.oWCRate", wcRate);
        component.set("v.isShowAddWCRateModal", false);
        helper.handleInitlization(component, event);
        //component.set("v.wcRateIndex", null);
        component.set("v.wcRateWhereClause", null);
        component.set("v.mapClientLocationPicklistValues", []);
    },
	handleAddWCRateModal : function(component, event, helper){
        let isValidateForm = helper.validateForm(component, 'Gross_Wages_Rate', false);
        
        var wcRate = component.get("v.oWCRate");
        console.log("***wcRate***"+JSON.stringify(wcRate));
        
        /*let Part_Time_Employees_Rate = component.find("Part_Time_Employees_Rate").get("v.value");
        let of_Employees_Rate = component.find("of_Employees_Rate").get("v.value");
        
        if(Part_Time_Employees_Rate == null 
           || Part_Time_Employees_Rate == undefined 
           || of_Employees_Rate == null 
           || of_Employees_Rate == undefined ){
            isValidateForm = false;
        }*/
        
        if(wcRate.Part_Time_Employees__c == null
          || wcRate.Part_Time_Employees__c == undefined
          || wcRate.of_Employees__c == null
          || wcRate.of_Employees__c == undefined){
            isValidateForm = false;
        }
        
        if(isValidateForm){
            if(wcRate.State_Comp_Code__c != null && wcRate.State_Comp_Code__c != undefined){
                if(wcRate.Part_Time_Employees__c == 0 && wcRate.of_Employees__c == 0){
                    helper.doShowToast(component, 'Error', '# of Part-Time Employees OR # of Full-Time Employees should be grater then 0', 'error');
                }else{
                    helper.createWCRateHelper(component, event, false);
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select valid WC Code', 'error');
            }
		}else{
            helper.doShowToast(component, 'Error', 'Please fill all required information and try again.', 'error');    
        }
        
    },
    
    handleAddWCRateModalAndMore : function(component, event, helper){
        let isValidateForm = helper.validateForm(component, 'Gross_Wages_Rate', false);
        
        /*let Part_Time_Employees_Rate = component.find("Part_Time_Employees_Rate").get("v.value");
        let of_Employees_Rate = component.find("of_Employees_Rate").get("v.value");
        
        if(Part_Time_Employees_Rate == null 
           || Part_Time_Employees_Rate == undefined 
           || of_Employees_Rate == null 
           || of_Employees_Rate == undefined ){
            isValidateForm = false;
        }*/
        
        var wcRate = component.get("v.oWCRate");
        
        if(wcRate.Part_Time_Employees__c == null
          || wcRate.Part_Time_Employees__c == undefined
          || wcRate.of_Employees__c == null
          || wcRate.of_Employees__c == undefined){
            isValidateForm = false;
        }
        
        if(isValidateForm){
             
            if(wcRate.State_Comp_Code__c != null && wcRate.State_Comp_Code__c != undefined){
                if(wcRate.Part_Time_Employees__c == 0 && wcRate.of_Employees__c == 0){
                    helper.doShowToast(component, 'Error', '# of Part-Time Employees OR # of Full-Time Employees should be grater then 0', 'error');
                }else{
                    helper.createWCRateHelper(component, event, true);
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select valid WC Code', 'error');
            }
		}else{
            helper.doShowToast(component, 'Error', 'Please fill all required information and try again.', 'error');    
        }
        
    },
    
    handleShowAddCompModal : function(component, event, helper){
        component.set("v.isShowAddCompModal", true);
        component.set("v.isShowAddState", false);
        component.set("v.isShowAddComp", true);
        component.set("v.selectedState", null);
        component.set("v.mapClientLocationPicklistValues", []);
        component.set("v.wcCompWhereClause", null);
        component.set("v.selectedStateName", null);
        
        var wcRate = {'sobjectType ':'WC_Rate__c','SUTA_Quote__c':null,'Proposal__c':null, 
                          'State_Comp_Code__c':null, 'of_Employees__c':null, 
                          'Part_Time_Employees__c':null, 'Gross_Wages__c':null,'Current_Rate__c':null,
                          'Client_Location__c':null}
            component.set("v.oWCRate", wcRate);
        
        helper.fetchState(component, event);
    },
    
    handleHideAddCompModal : function(component, event, helper){
        component.set("v.isShowAddCompModal", false);
        component.set("v.isShowAddState", false);
        component.set("v.isShowAddComp", false);
        component.set("v.selectedState", null);
        component.set("v.mapClientLocationPicklistValues", []);
        component.set("v.wcCompWhereClause", null);
        component.set("v.selectedStateName", null);
        helper.handleInitlization(component, event);
    },
    
    handleCompStateChange : function(component, event, helper){
        let stateId = component.find("state").get("v.value");
        var whereClause = '';
        
        if(stateId != null && stateId != '' && stateId != undefined){
            whereClause = ' State__c = \''+stateId+'\'';
        }
        
        component.set("v.selectedState",stateId);
        
        var wcRate = component.get("v.oWCRate");
       	wcRate.State_Comp_Code__c = '';
        wcRate.of_Employees__c = null;
        wcRate.Part_Time_Employees__c = null;
        wcRate.Gross_Wages__c = null;
        wcRate.Client_Location__c = null;
        component.set("v.oWCRate", wcRate);
        
        component.set("v.wcCompWhereClause", whereClause);
        
        if(stateId != null && stateId != '' && stateId != undefined){
            helper.fetchClientLocationRecords(component,event,stateId);
        }
        
    },
    
    handleNewLocation: function(component, event, helper){
        let stateId = component.get("v.selectedState");
        component.set("v.isNewClientLocation", false);
        component.set("v.oClientLocation", null);
        var wCRate = component.get("v.oWCRate");
        wCRate.Client_Location__c = null;
        component.set("v.isShowAddComp", false);
        
        if(wCRate.Id != null && wCRate.Id != undefined && (stateId == null || stateId == undefined || stateId == '')){
            if(wCRate.SUTA_Quote__r.State__c !=null && wCRate.SUTA_Quote__r.State__c != undefined){
                stateId = wCRate.SUTA_Quote__r.State__c;
            } 
        }
        component.set("v.selectedState", stateId);
        component.set("v.oWCRate", wCRate);
		helper.fetchState(component, event);       
        helper.fetchNewClientLocation(component, event, stateId);
        
    },
    
    handleCloseNewLocationModal: function(component, event, helper) {
        component.set("v.isNewClientLocation", false);
        component.set("v.oClientLocation", null);
        component.set("v.isShowAddComp", true);
    },
    
    handleSubmitNewLocationModal: function(component, event, helper) {
        let isValidForm = helper.validateForm(component, 'street,city,Zip_Code', false);
        if(isValidForm){
            var isTerritorialRating = component.get("v.isTerritorialRating");
            if(isTerritorialRating){
                var postalCode =  component.get("v.oClientLocation.Postal_Code__c");
                if(postalCode != null && postalCode != undefined){
                    helper.createWCLocationHelperHelper(component, event);
                }else{
                    helper.doShowToast(component, 'Error', 'Please select valid Postal Code and try again.', 'error');    
                }
            }else{
                helper.createWCLocationHelperHelper(component, event);    
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill all required information and try again.', 'error');
        }
    },
    
    handleCreateWCCode : function(component, event, helper) {
        let isValidate = helper.validateForm(component, 'state,rating,numberEmployees,numberPartEmployees,grossWage,rating', false);
        if(isValidate){
            let stampCode = component.get("v.oWCRate.State_Comp_Code__c");
            if(stampCode != null && stampCode != undefined && stampCode != ''){
                var wcRate = component.get("v.oWCRate");
                if(wcRate.Part_Time_Employees__c == 0 && wcRate.of_Employees__c == 0){
                    helper.doShowToast(component, 'Error', '# of Part Time Employees OR # of Full Time Employees should be grater then 0', 'error');
                }else{
                    helper.createWCCodeHelper(component, event, false);
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select valid State Comp Code', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    handleDeleteSutaQutoteRecord : function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        helper.deleteSUTARecordHelper(component, event, recordId);
    },
    
    handleDeleteClientLocation: function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        let index = event.getSource().get("v.value");
        component.set("v.locationIndex", index);
        helper.deleteClientLocationHelper(component, event, recordId);
    },
    
    handleEditClientLocation: function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        let index = event.getSource().get("v.value");
        component.set("v.locationIndex", index);
        component.set("v.selectedClientLocationId", recordId);
        component.set("v.isShowEditLocationModal", true);
        helper.getClientLocationHelper(component, event, recordId);
    },
    
    handleCloseEditClientLocation : function(component, event, helper){
        component.set("v.locationIndex", null);
        component.set("v.selectedClientLocationId", null);
        component.set("v.isShowEditLocationModal", false);
        component.set("v.oClientLocation", null);
    },
    
    handleSaveEditClientLocation : function(component, event, helper){
        let isValidate = helper.validateForm(component, 'street,city,zip_Code,Postal_Code', true);
        if(isValidate){
            helper.showSpinner(component);
            component.find("editForm").submit();
        }else{
            helper.doShowToast(component, 'Error', 'Please fill all required information and try again.', 'error');    
        }
    },
    
    handleSuccessClientLocationRecord : function(component, event, helper){
        component.set("v.selectedClientLocationId", null);
        component.set("v.isShowEditLocationModal", false);
        helper.doShowToast(component, 'Success', 'Record updated successfully!', 'success');
        helper.handleInitlization(component, event);
    },
    
    handleErrorClientLocationRecord : function(component, event, helper){
        helper.hideSpinner(component);
        var message = event.getParam('message');
        if(message != null && message != '' && message != undefined){
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },
    
    handleEditWCRate : function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        let index = event.getSource().get("v.value");
        component.set("v.wcRateIndex", index);
        helper.getWCRateHelper(component, event, recordId);
    },
    
    handleDeleteWCRate : function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        let index = event.getSource().get("v.value");
        component.set("v.wcRateIndex", index);
        helper.deleteWCRateHelper(component, event,recordId);
    },
    
    handleEditNoLocationWCRate : function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        let index = event.getSource().get("v.value");
        component.set("v.wcRateNoLocationIndex", index);
        helper.getWCRateHelper(component, event, recordId);
    },
    
    handleDeleteNoLocationWCRate : function(component, event, helper){
        let recordId = event.getSource().get("v.name");
        let index = event.getSource().get("v.value");
        component.set("v.wcRateNoLocationIndex", index);
        helper.deleteWCRateHelper(component, event,recordId);
    },
    
    handleCreateAndNewAddWCCode : function(component, event, helper){
        let isValidate = helper.validateForm(component, 'state,rating,numberEmployees,numberPartEmployees,grossWage,rating', false);
        if(isValidate){
            let stampCode = component.get("v.oWCRate.State_Comp_Code__c");
            if(stampCode != null && stampCode != undefined && stampCode != ''){
                var wcRate = component.get("v.oWCRate");
                if(wcRate.Part_Time_Employees__c == 0 && wcRate.of_Employees__c == 0){
                    helper.doShowToast(component, 'Error', '# of Part Time Employees OR # of Full Time Employees should be grater then 0', 'error');
                }else{
                    helper.createWCCodeHelper(component, event, true); 
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select valid State Comp Code', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
})