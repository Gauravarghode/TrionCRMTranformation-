({
	handleInitialize : function(component, event) {
        this.createDataTableHeaders(component, false);
		this.fetchProposalDetails(component,event);
        let btnvisibilitysoqlFilter = component.get("v.buttonvisibilitysoqlFilter");
        if(btnvisibilitysoqlFilter != null && btnvisibilitysoqlFilter != '' && btnvisibilitysoqlFilter != undefined){
            this.checkButtonVisibility(component, event);
        }
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

    fetchProposalDetails : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getProposalDetails");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.oProposal", result);
                this.fetchProposalWCRateRecords(component,event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchProposalWCRateRecords : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getWCRateRecords");
        action.setParams({
            proposalId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                
                for(var i=0;i<result.length;i++){
                    if(result[i].SUTA_Quote__r.State__c != null && result[i].SUTA_Quote__r.State__c != undefined){
                        result[i].StateName = result[i].SUTA_Quote__r.State__r.Name;
                    }
                    if(result[i].Client_Location__c != null && result[i].Client_Location__c != undefined){
                        result[i].Location = result[i].Client_Location__r.Loc__c;
                    }
                }

                component.set("v.lstWCRates", result);
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
    
    deleteWCRateRecord : function(component, event, wcRateId) {
        this.showSpinner(component);
        var action = component.get("c.deleteWCRate");
        action.setParams({
            wcRateId : wcRateId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record deleted successfully!', 'success');
                this.fetchProposalWCRateRecords(component,event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateStateCompCodeWCRate : function(component, event, wcRateId){
        this.showSpinner(component);
        var action = component.get("c.updateWCRateStateCompCode");
        action.setParams({
            wcRateId : wcRateId,
            stateCompCode : component.get("v.selectedStateCompCode")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowChangeCompCode", false);
                component.set("v.selectedRows", []);
                component.set("v.isShowStampCompCode", false);
                this.doShowToast(component, 'Success', 'Record updated successfully!', 'success');
                this.handleInitialize(component,event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchWCCarrier : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getWCCarrier");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapWCCarrier = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapWCCarrier.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapWCCarrier",mapWCCarrier);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateWCCarrierRates : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.updateWCRateCarrier");
        action.setParams({
            lstWCRate : component.get("v.selectedRows"),
            carrierId : component.get("v.selectedCarrier")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowSelectCarrierModal", false);
                component.set("v.isShowSelectCarrier", false);
                component.set("v.selectedRows", []);
                component.set("v.selectedCarrier", null);
                this.doShowToast(component, 'Success', 'Record updated successfully!', 'success');
                this.handleInitialize(component,event);
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
    
    fetchPolicyYears : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPolicyYears");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapYear = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapYear.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapPolicyYears",mapYear);
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
            policyId : policyId,
            policyYearId : component.get("v.selectedPolicyYear")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
               	this.doShowToast(component, 'Success', 'Record updated successfully', 'success');
                component.set("v.selectedCarrier", null);
                component.set("v.selectedPolicyYear", null);
                component.set("v.masterQuoteColumns", []);
                component.set("v.lstMasterQuotes", []);
                component.set("v.selectedMasterQuotes", []);
                component.set("v.policyColumns", []);
                component.set("v.lstPolicy", []);
                component.set("v.selectedPolicy", []);
                component.set("v.isShowSelectCarrierModal", false);
                component.set("v.isShowSelectCarrier", false);
                this.handleInitialize(component, event);
                this.navigateToRecord(component, event, component.get("v.recordId"));
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
    
    updateDebitDiscountHandler : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.updateDebitDiscount");
        action.setParams({
            mod : component.get("v.modValue"),
            lstWCRate : component.get("v.selectedWCRateRows")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                //var result = response.getReturnValue();
                component.set("v.isShowSetUWMod", false);
                component.set("v.isShowUWModSelected", true);
                component.set("v.selectedWCRateRows", []);
                this.doShowToast(component, 'Success', 'UW Mod Updated Successfully!', 'success');
                this.handleInitialize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createMasterPolicyDataTableHeaders : function(component){
        var columns = [];
        columns.push({label: 'State', fieldName: 'State_Name__c', type: 'text', sortable:false, editable: false });
        columns.push({label: '# of Employees', fieldName: 'Total_of_Employees__c', type: 'number', sortable:false, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Gross Wages', fieldName: 'Total_Gross_Wages__c', type: 'currency', sortable:false, editable: false, cellAttributes: { alignment: 'left' } });
        component.set('v.masterQuoteColumns', columns);
    },
    
    createDataTableHeaders : function(component, isHideActionAttributes){
        var columns = [];
        var actions = [{ label: 'Edit', name: 'edit' },{ label: 'Delete', name: 'delete' }];
        columns.push({label: 'Loc #', fieldName: 'Location', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'State', fieldName: 'StateName', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Description', fieldName: 'Description__c', type: 'text', sortable:true, editable: false });
        columns.push({label: '# of Employees', fieldName: 'Total_Employees__c', type: 'number', sortable:true, editable: false , cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Current Rate', fieldName: 'Current_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Est. Current Manual Premium', fieldName: 'Estimated_Annual_Manual_Premium__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Exp. Mod', fieldName: 'Client_Exp_Mod__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Exp Mod Rate', fieldName: 'Exp_Mod_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Exp Mod Premium', fieldName: 'Exp_Mod_Premium__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Carrier WC Rate', fieldName: 'Carrier_Rate__c', type: 'percent-fixed', sortable:true, editable: false, cellAttributes: { alignment: 'left' }, typeAttributes:{step: '0.001'}});
        columns.push({label: 'UW Mod', fieldName: 'Debit_Discount__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }}); 
        columns.push({label: 'Underwriting Rate', fieldName: 'Underwriting_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Underwriting Premium', fieldName: 'Underwriting_Premium__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        
        if(!isHideActionAttributes){ 
            columns.push({type: 'action', typeAttributes: { rowActions: actions }});
        }
        component.set('v.columns', columns);
    },
    
    showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var deletemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.removeClass(deletemodalspinner, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var deletemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.addClass(deletemodalspinner, "slds-hide");
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
})