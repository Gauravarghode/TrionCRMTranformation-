({
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
    fetchFederaTaxData : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getFederaTaxData");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.oProposal", result);
                if(result.Year__c != null && result.Year__c != undefined){
                    component.set("v.selectedYearId", result.Year__c);
                }
                this.fetchProposalSUTAQuoteRecords(component,event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchProposalSUTAQuoteRecords : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getProposalSUTAQuoteRecords");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null && result != undefined){
                     result.forEach(function(record){
                         if(record.SUTA__c != null && record.SUTA__c != undefined){
                         	record.SUTAName = record.SUTA__r.Name;    
                         }else{
                             record.SUTAName = null;
                         }
                    });
                }
                component.set("v.lstSUTAQuotes", result);
                if(result != null && result != undefined){
                    component.set("v.sortedBy", 'Proposal_SUTA_header__c');
                    component.set("v.sortedDirection", 'asc'); 
                    this.sortData(component, 'Proposal_SUTA_header__c', 'asc');
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createDataTableHeaders : function(component, isEditable){
        var columns = [];
        var actions = [{ label: 'Edit', name: 'edit' },{ label: 'Delete', name: 'delete' }];
        columns.push({label: 'State', fieldName: 'State_Name__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Reporting Level', fieldName: 'Reporting_Level__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Entity', fieldName: 'Entity__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Cost Rate', fieldName: 'SUTA_Cost_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Bill Rate', fieldName: 'SUTA_Bill_Rate__c', type: 'number', sortable:true, editable: isEditable, cellAttributes: { alignment: 'left' }});
        columns.push({type: 'action', typeAttributes: { rowActions: actions }});
        component.set('v.columns', columns);
    },
    
    fetchYears : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getYears");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                 var mapYears = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapYears.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapYearOptions", mapYears);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    selectTaxYear : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.updateProposalYear");
        action.setParams({
            proposalId:component.get("v.recordId"),
            proposalYear:component.get("v.selectedYearId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                component.set("v.isShowSelectYear", false);
                component.set("v.selectedYearId", null);
                this.fetchFederaTaxData(component, event);
                this.navigateToRecord(component,event, component.get("v.recordId"));
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    saveSUTAQuoteRecords : function(component, event, draftValues) {
        this.showSpinner(component);
        var action = component.get("c.updateSUTAQuoteRecords");
        action.setParams({
            lstQuotes:draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.fetchFederaTaxData(component, event);
                component.set("v.draftValues", []);
                component.set("v.isShowCheckboxColumn", true);
                component.set("v.isEdit", false);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteSelectedRecords : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.deleteSUTAQuoteRecords");
        action.setParams({
            quoteId:component.get("v.selectedRecordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.fetchFederaTaxData(component, event);
                component.set("v.selectedRecordId", null);
                component.set("v.isShowDeleteModal", false);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchSUTARecords : function(component, event, sutaId, stateId,yearId) {
        this.showSpinner(component);
        var action = component.get("c.getSUTARecords");
        action.setParams({
            sutaId:sutaId,
            stateId:stateId,
            yearId:yearId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapSUTAOptions = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapSUTAOptions.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapSUTAOptions", mapSUTAOptions);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var deletemodalspinner = component.find("deletemodalspinner");
        $A.util.removeClass(deletemodalspinner, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var deletemodalspinner = component.find("deletemodalspinner");
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
        var filteredData = component.get("v.lstSUTAQuotes");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstSUTAQuotes", filteredData);
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
})