({
    handleInitilize : function(component, event) {
    	this.createDataTableHeaders(component);
        this.fetchWCRateRecords(component,event,component.get("v.recordId"));
        let btnvisibilitysoqlFilter = component.get("v.buttonvisibilitysoqlFilter");
        if(btnvisibilitysoqlFilter != null && btnvisibilitysoqlFilter != '' && btnvisibilitysoqlFilter != undefined){
            this.checkButtonVisibility(component, event);
        }
	},
    
    fetchWCRateRecords : function(component, event, proposalId) {
        this.showSpinner(component);
        var action = component.get("c.getWCRateRecords");
        action.setParams({
            proposalId : proposalId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                for(var i = 0; i < result.length; i++){
                    var row = result[i];
                    if(row.Policy__r){
                       row.PolicyName = row.Policy__r.Name  ;
                    }

                    if(row.SUTA_Quote__r.State__c != null && row.SUTA_Quote__r.State__c != undefined){
                        row.StateName = row.SUTA_Quote__r.State__r.Name;
                    }

                    if(row.Client_Location__c != null && row.Client_Location__c != undefined){
                        row.Location = row.Client_Location__r.Loc__c;
                    }
                    row.Flag = '---';
                }
                component.set("v.lstWCRates", result);
                
                component.set("v.isSelectCarrier", false);
                component.set("v.isCalculateRate", false);
                component.set("v.isAddWCCode", false);
                if(result != null && result != undefined){
                    component.set("v.sortedBy", 'Location');
                    component.set("v.sortedDirection", 'asc'); 
                    this.sortData(component, 'Location', 'asc');
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
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
    
    deleteWCRateRecords : function(component, event, wcRateId) {
        this.showSpinner(component);
        var action = component.get("c.deleteWCRate");
        action.setParams({
            wcRateId : wcRateId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record deleted successfully', 'success');
                this.handleInitilize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    fetchPicklistValues : function(component, event, objectName, fieldName) {
        this.showSpinner(component);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName : objectName,
            fieldName : fieldName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var calculateWCRatebyMap = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        calculateWCRatebyMap.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapCalculateWCRateby",calculateWCRatebyMap);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateCalculateRates : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.calculateRates");
        action.setParams({
            lstWCRate : component.get("v.selectedRows"),
            selectedCalculateWCRateby : component.get("v.selectedCalculateWCRateby"),
            modifier : component.get("v.modifier")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records updated successfully', 'success');
                this.handleInitilize(component, event);
                component.set("v.isShowCheckboxColumn", true);
                component.set("v.isCalculateRate", false);
                component.find("wcRate").set("v.selectedRows", []);
                component.set("v.draftValues", []);
                component.set("v.selectedRows", []);
                component.set("v.selectedCalculateWCRateby", null);
                component.set("v.modifier", null);
                this.navigateToRecord(component, event, component.get("v.recordId"));
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

	fetchActiveCarrier : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getActiveCarrier");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapCarrier = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapCarrier.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapCarrier",mapCarrier);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchPolicyWrapper : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPolicies");
        action.setParams({
            carrierId : component.get("v.selectedCarrier"),
            proposalId : component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var columns = [];
                columns.push({label: 'Policy', fieldName: 'Name', type: 'text', sortable:true, editable: false });
                columns.push({label: 'Effective Date', fieldName: 'Effective_Date__c', type: 'date', sortable:true, editable: false, typeAttributes:{year:"numeric",month:"numeric",day:"numeric",timeZone:"UTC"} });
                columns.push({label: 'Policy Type', fieldName: 'Type__c', type: 'text', sortable:true, editable: false });
                component.set("v.policyColumns",columns);
                component.set("v.lstPolicy",result);
                component.set("v.selectCarrierHeader", "Assign Policy");
                this.fetchMasterSutaQuote(component,event);
                this.fetchMCPStateWrapper(component,event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateQuoteAndWCRateRecordsHelper : function(component,event,proposalId,carrierId,policyId,type) {
        this.showSpinner(component);
        var action = component.get("c.updateQuoteAndWCRateRecords");
        action.setParams({
            proposalId : proposalId,
            carrierId : carrierId,
            policyId : policyId,
            type : type
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowCheckboxColumn", false);
                component.set("v.lstWCRates", result);
                component.set("v.isShowPolicyContinue", true)
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateWCRatesHelper : function(component,event,isFinish) {
        this.showSpinner(component);
        var action = component.get("c.updateWCRates");
        action.setParams({
            lstWCRate : component.get("v.selectedRows"),
            proposalId : component.get("v.recordId"),
            carrierId : component.get("v.selectedCarrier"),
            policyId : component.get("v.oPolicy.Id"),
            type : component.get("v.oPolicy.Type__c")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(isFinish){
                    component.set("v.isShowCheckboxColumn", true);
                    this.handleInitilize(component, event);
                }else{
                    component.set("v.isShowCheckboxColumn", false);
                	component.set("v.lstWCRates", result);
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
        var action = component.get("c.getStates");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapState = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapState.push({key:key , value: result[key]});
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
    
    fetchWCRateWithState : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getWCRateWithState");
        action.setParams({
            proposalId : component.get("v.recordId"),
            stateId : component.get("v.selectedState")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.lstWCCode", result);
                if(result != null && result != undefined){
                    component.set("v.sortedByWCCode", 'Description__c');
                    component.set("v.sortedDirectionWCCode", 'asc'); 
                    this.sortWCData(component, 'Description__c', 'asc');
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createUpdateWCRateHelper : function(component, event, isAddMore, isAddNewState, isFinish) {
        this.showSpinner(component);
        var action = component.get("c.createUpdateWCRate");
        action.setParams({
            proposalId : component.get("v.recordId"),
            stateId : component.get("v.selectedState"),
            selectedStateCompCode : component.get("v.selectedStateCompCode"),
            numberofEmployees : component.get("v.numberEmployee"),
            grossWages : component.get("v.grossWage")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.selectedStateCompCode", null);
                component.set("v.numberEmployee", null);
                component.set("v.grossWage", null);
                this.doShowToast(component, 'Success', 'Record created successfully', 'success');
                if(isAddMore){
                    component.set("v.lstWCCode", result);
                    if(result != null && result != undefined){
                        component.set("v.sortedByWCCode", 'Description__c');
                        component.set("v.sortedDirectionWCCode", 'asc'); 
                        this.sortWCData(component, 'Description__c', 'asc');
                    }
                }else if(isAddNewState){
                    component.set("v.lstWCCode", []);
                    component.set("v.WCCodeColumns", []);
                    component.set("v.sortedByWCCode", null);
                    component.set("v.sortedDirectionWCCode", null);
                    component.set("v.isShowWCCode", false);
            		component.set("v.isShowState", true);
                    this.fetchState(component, event);
                }else if(isFinish){
                    component.set("v.lstWCCode", []);
                    component.set("v.WCCodeColumns", []);
                    component.set("v.sortedByWCCode", null);
                    component.set("v.sortedDirectionWCCode", null);
                    component.set("v.isShowWCCode", false);
            		component.set("v.isShowState", false);
                    component.set("v.isShowAddCompCodeModal" , false);
                    this.handleInitilize(component, event);
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchMasterSutaQuote : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getMasterSutaQuote");
        action.setParams({
            proposalId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.lstMasterQuotes", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchMCPStateWrapper : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getMCPStateWrapper");
        action.setParams({
            proposalId : component.get("v.recordId"),
            carrierId : component.get("v.selectedCarrier")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.lstMCPStateWrapper", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateMasterSUTAQuoteHelper : function(component, event) {
        this.showSpinner(component);
        let mCPStateWrapper = component.get("v.lstMCPStateWrapper");
        let policyId = null;
        var oPolicy = component.get("v.oPolicy");
        
        if(oPolicy != null && oPolicy != undefined && oPolicy.Id != null && oPolicy.Id != undefined){
            policyId = oPolicy.Id;
        }
        
        var action = component.get("c.updateMasterSUTAQuote");
        action.setParams({
            jsonWrapper : JSON.stringify(mCPStateWrapper),
            lstSUTAQuote : component.get("v.selectedMasterQuotes"),
            carrierId : component.get("v.selectedCarrier"),
            policyId : policyId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
               	this.doShowToast(component, 'Success', 'Record updated successfully', 'success');
                component.set("v.isSelectCarrier", false);
                component.set("v.selectedCarrier", null);
                component.set("v.mapCarrier", []);
                component.set("v.isShowWCCode", false);
                component.set("v.isShowState", false);
                component.set("v.isShowAddCompCodeModal" , false);
                component.set("v.isShowPolicy" , false);
                component.set("v.masterQuoteColumns", []);
                component.set("v.lstMasterQuotes", []);
                component.set("v.selectedMasterQuotes", []);
                component.set("v.policyColumns", []);
                component.set("v.lstPolicy", []);
                component.set("v.selectedPolicy", []);
                this.handleInitilize(component, event);
                this.navigateToRecord(component, event, component.get("v.recordId"));
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createDataTableHeaders : function(component){
        var columns = [];
        var actions = [{ label: 'Edit', name: 'edit' },{ label: 'Delete', name: 'delete' }];
        columns.push({label: 'Loc #', fieldName: 'Location', type: 'text', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'State', fieldName: 'StateName', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Comp Code', fieldName: 'Description__c', type: 'text', sortable:true, editable: false });
        columns.push({label: '#EE', fieldName: 'Total_Employees__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'Policy', fieldName: 'PolicyName', type: 'text', sortable:true, editable: false});
        columns.push({label: 'Manual Rate', fieldName: 'Carrier_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Mod', fieldName: 'Mod_Calculator__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Assessment Fee', fieldName: 'Assessment_Fee__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Total Bill Rate', fieldName: 'Total_Bill_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Bill Rate', fieldName: 'WC_Bill_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Bill Premium', fieldName: 'Bill_Premium__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({type: 'action', typeAttributes: { rowActions: actions }});
        component.set('v.columns', columns);
    },
    
    createMasterPolicyDataTableHeaders : function(component){
        var columns = [];
        columns.push({label: 'State', fieldName: 'State_Name__c', type: 'text', sortable:false, editable: false });
        columns.push({label: '# of Employees', fieldName: 'of_Employees__c', type: 'number', sortable:false, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable:false, editable: false, cellAttributes: { alignment: 'left' } });
        component.set('v.masterQuoteColumns', columns);
    },
    
    createRateDataTableHeaders : function(component){
        var columns = [];
        columns.push({label: 'State', fieldName: 'State__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Comp Code/Description', fieldName: 'Description__c', type: 'text', sortable:true, editable: false });
        columns.push({label: '# of Employees', fieldName: 'Total_Employees__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        component.set('v.WCCodeColumns', columns);
    },
    
    showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
       	var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var addCompCodemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.removeClass(addCompCodemodalspinner, "slds-hide");
         var carriermodalspinner = component.find("carriermodalspinner");
        $A.util.removeClass(carriermodalspinner, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var addCompCodemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.addClass(addCompCodemodalspinner, "slds-hide");
        var carriermodalspinner = component.find("carriermodalspinner");
        $A.util.addClass(carriermodalspinner, "slds-hide");
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
    
    sortData: function (component, fieldName, sortDirection) {
        var filteredData = component.get("v.lstWCRates");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstWCRates", filteredData);
    },
    
    sortWCData: function (component, fieldName, sortDirection) {
        var filteredData = component.get("v.lstWCCode");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstWCCode", filteredData);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    navigateToRecord : function (component, event, recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    
    validateForm : function(component, validationFieldAuraIds){
        let isValidationPassed = true;
        validationFieldAuraIds.split(',').forEach(function(auraIdOfInputsToBeValidated){
            if(component.find(auraIdOfInputsToBeValidated) && component.find(auraIdOfInputsToBeValidated).length){//if there are any records to iterate
                (component.find(auraIdOfInputsToBeValidated)).forEach(function(inputField){
                    if(inputField.get('v.required') && !inputField.get('v.value')){
                        inputField.showHelpMessageIfInvalid();
                        isValidationPassed = false;
                    }
                });
            }else{
                var singleInputField = component.find(auraIdOfInputsToBeValidated);
                if(singleInputField){
                    if(singleInputField.get('v.required') && !singleInputField.get('v.value')){
                        singleInputField.showHelpMessageIfInvalid();
                        isValidationPassed = false;
                    }
                }
            }
        }); 
        return isValidationPassed;
    },
})