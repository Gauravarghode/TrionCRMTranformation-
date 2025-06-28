({
    handleInitlization: function(component, event) {
        this.fetchObjectName(component, event);
        /*let btnvisibilitysoqlFilter = component.get("v.buttonvisibilitysoqlFilter");
        if(btnvisibilitysoqlFilter != null && btnvisibilitysoqlFilter != '' && btnvisibilitysoqlFilter != undefined){
            this.checkButtonVisibility(component, event);
        }*/
        this.checkButtonVisibility(component, event);
    },
    
    checkButtonVisibility : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.isButtonVisibilitySOQLFilter");
        action.setParams({
            visibilitysoqlFilter : component.get("v.buttonvisibilitysoqlFilter"),
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isButtonVisible", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchObjectName : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getObjectName");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.sObjectName", result);
                if(result == 'opportunity'){
                    this.fetchOpportunityDetails(component, event);
                }else{
                    this.fetchProposalDetails(component, event, component.get("v.recordId"));
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchOpportunityDetails : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.opp", result);
                if(result.Proposal__c != null && result.Proposal__c != undefined){
                 	this.fetchProposalDetails(component,event,result.Proposal__c);   
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchProposalDetails : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.getProposalDetails");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.oProposal", result);
                this.fetchProposalSUTAQuoteRecords(component,event,result.Id); 
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchProposalSUTAQuoteRecords : function(component, event, proposalId) {
        this.showSpinner(component);
        var action = component.get("c.getProposalSUTAQuoteRecords");
        action.setParams({
            proposalId : proposalId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                let locationIndex = component.get("v.locationIndex");
                if(locationIndex != null && locationIndex != undefined && result != null && result != undefined){
                    for(let i=0;i<result.length;i++){
                        if(locationIndex == i){
                            result[i].isExpaned = true;
                        }
                    }
                    component.set("v.locationIndex", null);
                }
                
                let wcRateNoLocationIndex = component.get("v.wcRateNoLocationIndex");
                if(wcRateNoLocationIndex != null && wcRateNoLocationIndex != undefined && result != null && result != undefined){
                    var quoteWrapper = result[wcRateNoLocationIndex];
                    quoteWrapper.isExpaned = true;
                    component.set("v.wcRateNoLocationIndex", null);
                }
                
                let wcRateIndex = component.get("v.wcRateIndex");
                if(wcRateIndex != null && wcRateIndex != undefined && result != null && result != undefined){
                    let wcRateIndexArr = wcRateIndex.split("_");
                    var quoteWrapper = result[wcRateIndexArr[0]];
                    quoteWrapper.isExpaned = true;
                    if(quoteWrapper.lstClientLocationWrapper != null && quoteWrapper.lstClientLocationWrapper != undefined){
                        var clientLocationWrapper = quoteWrapper.lstClientLocationWrapper[wcRateIndexArr[1]];
                        clientLocationWrapper.isExpaned = true;
                    }
                    component.set("v.wcRateIndex", null);
                }
                
                component.set("v.lstSUTAQuoteWrapper", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createStateHelper : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.createState");
        action.setParams({
            proposalId : component.get("v.oProposal.Id"),
            lstQuoteState : component.get("v.lstSUTAQuoteToInsert")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var lstSUTAQuoteToInsert = component.get("v.lstSUTAQuoteToInsert");
                let isDuplicate = false;
                for(let i=0;i<result.length;i++){
                    if(result[i].Id != null && result[i].Id != undefined){
                        for(var j=0;j<lstSUTAQuoteToInsert.length;j++){
                            if(result[i].State__c == lstSUTAQuoteToInsert[j].State__c){
                                document.getElementById('ST__'+i).style = "background-Color : #a01c1c !important";
                                isDuplicate = true;
                            }
                        }
                    }
                }
                
                if(isDuplicate){
                    this.doShowToast(component, 'Error', 'You cannot add the same state multiple times for a SUTA Quote. Please select a different state and try again.', 'error');
                }else{
                    component.set("v.isShowAddStateModal", false);
                    component.set("v.lstSUTAQuoteToInsert", []);
                    this.handleInitlization(component, event);
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createLocationHelperHelper : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.createClientLocation");
        action.setParams({
            oClientLocation : component.get("v.oClientLocation")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records created successfully!', 'success');
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
                this.handleInitlization(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createWCLocationHelperHelper : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.createClientLocation");
        action.setParams({
            oClientLocation : component.get("v.oClientLocation")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records created successfully!', 'success');
                component.set("v.isNewClientLocation", false);
                component.set("v.isShowAddComp", true);
                var wCRate = component.get("v.oWCRate");
                this.fetchClientLocationRecords(component, event, wCRate.SUTA_Quote__r.State__c);
                wCRate.Client_Location__c = result;
                component.set("v.oWCRate", wCRate);
                
                var oClientLocation = component.get("v.oClientLocation");
                if(oClientLocation != null && oClientLocation != undefined){
                    oClientLocation.Client__c = null;
                    oClientLocation.SUTA_Quote__c = null;
                    oClientLocation.Proposal__c = null;
                    oClientLocation.Loc__c = null;
                    oClientLocation.Street__c = null;
                    oClientLocation.County__c = null;
                    oClientLocation.Postal_Code__c = null;
                    oClientLocation.Zip_Code__c = null;
                    component.set("v.oClientLocation", oClientLocation);
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createWCRateHelper : function(component, event, isAddMore) {
        this.showSpinner(component);
        var action = component.get("c.createWCRate");
        action.setParams({
            oWCRate : component.get("v.oWCRate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records created successfully!', 'success');
                var previousRate = component.get("v.oWCRate");
                
                var wcRate = {'sobjectType ':'WC_Rate__c'}
                wcRate['State_Comp_Code__c'] = '';
                wcRate['of_Employees__c'] = null;
                wcRate['Part_Time_Employees__c'] = null;
                wcRate['Gross_Wages__c'] = null;
                wcRate['Current_Rate__c'] = null;
                
                if(!isAddMore){
                    wcRate['SUTA_Quote__c'] = null;
                    wcRate['Proposal__c'] = null;
                    wcRate['Client_Location__c'] = null;
                }else{
                    wcRate['SUTA_Quote__c'] = previousRate.SUTA_Quote__c;
                    wcRate['Proposal__c'] = previousRate.Proposal__c;
                    wcRate['Client_Location__c'] = previousRate.Client_Location__c;
                    component.find("stateLookup").clearField();
                }
                 
                component.set("v.oWCRate", wcRate);
                component.set("v.mapClientLocationPicklistValues", []);
                
                if(!isAddMore){
                    component.set("v.isShowAddWCRateModal", false);
                    component.set("v.wcRateWhereClause", null);
                    this.handleInitlization(component, event);
                }else{
                    component.set("v.isShowAddWCRateModal", true);
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchState : function(component, event) {
        this.showSpinner(component);
        component.set("v.isTerritorialRating", false);
        var action = component.get("c.getStates");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapState = [];
                var selectedState = component.get("v.selectedState");
                if(result != null && result != undefined){
                    for(var key in result){
                        mapState.push({key:key , value: result[key]});
                        if(selectedState != null && selectedState != undefined && selectedState != '' && selectedState == key && result[key] == 'California'){
                            component.set("v.isTerritorialRating", true);
                        }
                    }
                }
                component.set("v.mapStates",mapState);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchClientLocationRecords : function(component, event, stateId) {
        this.showSpinner(component);
        var action = component.get("c.getClientLocationPicklistValues");
        action.setParams({
            proposalId : component.get("v.oProposal.Id"),
            stateId:stateId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var clientLocationMap = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        clientLocationMap.push({key:key , value: result[key]});
                    }
                }
				component.set("v.mapClientLocationPicklistValues", clientLocationMap);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchNewClientLocation : function(component, event, stateId) {
        this.showSpinner(component);
        var action = component.get("c.getNewClientLocation");
        action.setParams({
            proposalId : component.get("v.oProposal.Id"),
            stateId:stateId,
            accId:component.get("v.oProposal.Opportunity__r.AccountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isNewClientLocation", true);
                console.log("***oClientLocation***"+JSON.stringify(result));
                component.set("v.oClientLocation", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createWCCodeHelper : function(component, event, isNew) {
        this.showSpinner(component);

        var oWCRate = component.get("v.oWCRate");

        if(oWCRate != null && oWCRate != undefined){
            delete oWCRate['SUTA_Quote__r'];
        }

        var action = component.get("c.createWCCode");
        action.setParams({
            proposalId : component.get("v.oProposal.Id"),
            stateId: component.get("v.selectedState"),
            oRate: oWCRate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var wcRate = {'sobjectType ':'WC_Rate__c','SUTA_Quote__c':null,'Proposal__c':null, 
                          'State_Comp_Code__c':null, 'of_Employees__c':null, 
                          'Part_Time_Employees__c':null, 'Gross_Wages__c':null,'Current_Rate__c':null,
                          'Client_Location__c':null}
            	component.set("v.oWCRate", wcRate);
                this.doShowToast(component, 'Success', 'Records created successfully!', 'success');
                this.handleInitlization(component, event);
                let isParentModal = component.get("v.isParentModal");
                if(isNew == true){
                    component.set("v.selectedState", null);
                    component.set("v.mapClientLocationPicklistValues", []);
                    component.set("v.wcCompWhereClause", null);
                    component.set("v.selectedStateName", null);
                }else if(isParentModal == true){
                    component.set("v.isParentModal", false);
                    this.navigateToRecord(component, event, component.get("v.recordId"));
                }else{
                    component.set("v.isShowAddCompModal", false);
                    component.set("v.isShowAddState", false);
                    component.set("v.isShowAddComp", false);
                    $A.get('e.force:refreshView').fire();
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    navigateToRecord : function (component, event, recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    
    deleteSUTARecordHelper : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.deleteSUTARecord");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
                this.handleInitlization(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteClientLocationHelper : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.deleteClientLocation");
        action.setParams({
            clientLocationId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
                this.handleInitlization(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getClientLocationHelper : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.getClientLocation");
        action.setParams({
            clientLocationId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
				component.set("v.oClientLocation", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteWCRateHelper : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.deleteWCRate");
        action.setParams({
            wcRateId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
                this.handleInitlization(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getWCRateHelper : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.getWCRate");
        action.setParams({
            wcRateId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var whereClause = '';
                let stateId;
                
                if(result.SUTA_Quote__r.State__c !=null && result.SUTA_Quote__r.State__c != undefined){
                    whereClause = ' State__c = \''+result.SUTA_Quote__r.State__c+'\'';
                    stateId = result.SUTA_Quote__r.State__c;
                } 
                
                if(stateId != null && stateId != undefined){
                    this.fetchClientLocationRecords(component,event,stateId);
                }
                
            	component.set("v.wcRateWhereClause", whereClause);
				component.set("v.oWCRate", result);
                component.set("v.isShowAddWCRateModal", true);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    serverSideCall : function(component,action) {
        return new Promise(function(resolve, reject) { 
            action.setCallback(this, 
                               function(response) {
                                   var state = response.getState();
                                   if (state === "SUCCESS") {
                                       resolve(response.getReturnValue());
                                   } else {
                                       reject(new Error(response.getError()));
                                   }
                               }); 
            $A.enqueueAction(action);
        });
    },

    
	showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var addlocationmodalspinner = component.find("addlocationmodalspinner");
        $A.util.removeClass(addlocationmodalspinner, "slds-hide");
        var addratemodalspinner = component.find("addratemodalspinner");
        $A.util.removeClass(addratemodalspinner, "slds-hide");
        var newmodalspinner = component.find("newmodalspinner");
        $A.util.removeClass(newmodalspinner, "slds-hide");
        var addcompmodalspinner = component.find("addcompmodalspinner");
        $A.util.removeClass(addcompmodalspinner, "slds-hide");
        var editclientmodalspinner = component.find("editclientmodalspinner");
        $A.util.removeClass(editclientmodalspinner, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var addlocationmodalspinner = component.find("addlocationmodalspinner");
        $A.util.addClass(addlocationmodalspinner, "slds-hide");
        var addratemodalspinner = component.find("addratemodalspinner");
        $A.util.addClass(addratemodalspinner, "slds-hide");
        var newmodalspinner = component.find("newmodalspinner");
        $A.util.addClass(newmodalspinner, "slds-hide");
        var addcompmodalspinner = component.find("addcompmodalspinner");
        $A.util.addClass(addcompmodalspinner, "slds-hide");
        var editclientmodalspinner = component.find("editclientmodalspinner");
        $A.util.addClass(editclientmodalspinner, "slds-hide");
    },
    
    doShowToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                title: title,
                message: message,
                type: type
            });
            toastEvent.fire();
        }
    },
    
    handleErrors: function(component, errors) {
        var eCount;
        for(eCount in errors){
            var error = errors[eCount];
            if (error.pageErrors != undefined) {
                var i;
                for (i in error.pageErrors) {
                    this.doShowToast(component, error.pageErrors[i].statusCode, error.pageErrors[i].message, 'warning');
                }
            } else {
                var i;
                var msgArray = (error.message).split('|');
                for (i in msgArray) {
                    this.doShowToast(component, 'Error', msgArray[i], 'error');
                }   
            }
            
            if (error.fieldErrors != undefined) {
                var fieldErrors = error.fieldErrors;
                var fld;
                for (fld in fieldErrors) {
                    if (fieldErrors.hasOwnProperty(fld)) { 
                        var fldErrors = fieldErrors[fld];
                        var i;
                        for (i in fldErrors) {
                            this.doShowToast(component, fldErrors[i].statusCode, fldErrors[i].message+' ['+fld+']', 'error');
                        }
                    }
                }
            } else {
                var i;
                var msgArray = (error.message).split('|');
                for (i in msgArray) {
                    this.doShowToast(component, 'Error', msgArray[i], 'error');
                }   
            }
        }
    },
    
    validateForm : function(component, validationFieldAuraIds, isRecordEditForm){
        let isValidationPassed = true;
        
        validationFieldAuraIds.split(',').forEach(function(auraIdOfInputsToBeValidated){
            if(component.find(auraIdOfInputsToBeValidated) && component.find(auraIdOfInputsToBeValidated).length){//if there are any records to iterate
                (component.find(auraIdOfInputsToBeValidated)).forEach(function(inputField){
                    if(inputField.get('v.required') && !inputField.get('v.value')){
                        if(!isRecordEditForm){
                            inputField.showHelpMessageIfInvalid();
                        }
                        isValidationPassed = false;
                    }
                });
            }else{
                var singleInputField = component.find(auraIdOfInputsToBeValidated);
                if(singleInputField){
                    if(singleInputField.get('v.required') && !singleInputField.get('v.value')){
                        if(!isRecordEditForm){
                            singleInputField.showHelpMessageIfInvalid();
                        }
                        isValidationPassed = false;
                    }
                }
            }
        });
        return isValidationPassed;
    },
})