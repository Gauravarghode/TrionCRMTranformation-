({
    handleInitlization: function(component, event) {
        this.fetchObjectName(component, event);
        this.createDataTableHeaders(component, false);
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
                component.set("v.lstSUTAQuotes", result);
                if(result != null && result != undefined){
                    component.set("v.sortedBy", 'State_Name__c');
                    component.set("v.sortedDirection", 'asc'); 
                    this.sortData(component, 'State_Name__c', 'asc');
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
        var actions = [{ label: 'Edit', name: 'edit' }];
        columns.push({label: 'State', fieldName: 'State_Name__c', type: 'text', sortable:true, editable: false });
        columns.push({label: '# of Employees', fieldName: 'of_Employees__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        component.set('v.columns', columns);
    },
    
    deleteSUTAQuotes : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.deleteSUTAQuoteRecords");
        action.setParams({
            lstSUTAQuote : component.get("v.selectedRows")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.find("quoteTable").set("v.selectedRows", []);
                component.set("v.draftValues", []);
                component.set("v.selectedRows", []);
                component.set("v.isDelete", false);
                this.handleInitlization(component, event);
                component.set("v.isShowCheckboxColumn", true);
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createClinetInfo: function(component, event) {
        this.showSpinner(component);
        let oppId;
        
        var sObjectName = component.get("v.sObjectName");
        if(sObjectName == 'opportunity'){
            oppId = component.get("v.opp.Id");
        }else{
            oppId = component.get("v.oProposal.Opportunity__c");
        }
        
        var action = component.get("c.submitClinetInfo");
        action.setParams({
            opportunityId : oppId,
            proposalId : component.get("v.oProposal.Id"),
            stateId : component.get("v.selectedStateId"),
            numberOfEmployees : component.get("v.numberOfEmployees"),
            grossWages : component.get("v.grossWages"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isAddEmployeeInfoModal", false);
                this.handleInitlization(component, event);
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
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
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