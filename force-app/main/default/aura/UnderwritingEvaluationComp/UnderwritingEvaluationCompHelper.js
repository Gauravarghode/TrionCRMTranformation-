({
    handleInitilize : function(component, event) {
        this.fetchProposalDetails(component, event);
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
                this.fetchLossYearsAndEvaluationRecords(component,event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchLossYearsAndEvaluationRecords : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getLossYearsAndEvaluationRecords");
        action.setParams({
            proposalId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var parentIndex = component.get("v.parentIndex");
                if(parentIndex != null && parentIndex != undefined 
                   	&& result != null && result != undefined){
                    for(let i=0;i<result.length;i++){
                        if(i == parentIndex){
                            result[i].isExpaned = true;
                        }
                    }
                    component.set("v.parentIndex", null);
                }
                component.set("v.lstUnderwritingEvaluationWrapper", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteLossYearHelper : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.deleteLossYear");
        action.setParams({
            jsonWrap : JSON.stringify(component.get("v.lstUnderwritingEvaluationWrapper"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowDeleteLossYear", false);
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
				this.handleInitilize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteLossYearEveHelper : function(component, event,recordId, parentIndex) {
        this.showSpinner(component);
        var action = component.get("c.deleteLossYearEvaluation");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
                /*var underwritingWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
                for(let i=0;i<underwritingWrapper.length;i++){
                    if(i == parentIndex){
                        underwritingWrapper[i].isExpaned = true;
                    }
                }
                component.set("v.lstUnderwritingEvaluationWrapper", underwritingWrapper);*/
                component.set("v.parentIndex", parentIndex);
                this.handleInitilize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchYears : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getYears");
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
                component.set("v.mapYear",mapYear);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateEvaluationYear : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.updateEvaluationYears");
        action.setParams({
            lstLossYearEvaluation : component.get("v.selectedRows"),
            yearId : component.get("v.selectedYear"),
            proposalId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowUpdateLossYearModal", false);  
                this.doShowToast(component, 'Success', 'Records updated successfully!', 'success');
                this.handleInitilize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createLossYearEvaluationRecord : function(component, event, fields) {
        this.showSpinner(component);
        var action = component.get("c.createLossYearEvaluation");
        action.setParams({
            oLossYearEvaluation : fields,
            yearId : component.get("v.selectedYear"),
            proposalId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowAddLossYearModal", false);  
                component.set("v.isShowAddLossModal", false);  
                this.doShowToast(component, 'Success', 'Records created successfully!', 'success');
                this.handleInitilize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    
    deleteParentLossYearRecord : function(component, event, lossYearId) {
        this.showSpinner(component);
        var action = component.get("c.deleteParentLossYear");
        action.setParams({
            lossYearId : lossYearId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records deleted successfully!', 'success');
                this.handleInitilize(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var filteredData = component.get("v.lstLossYearEvaluation");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstLossYearEvaluation", filteredData);
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
    
    
    showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
       	var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var addCompCodemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.removeClass(addCompCodemodalspinner, "slds-hide");
        var carriermodalspinner = component.find("carriermodalspinner");
        $A.util.removeClass(carriermodalspinner, "slds-hide");
        var addEveluationmodalspinner = component.find("addEveluationmodalspinner");
        $A.util.removeClass(addEveluationmodalspinner, "slds-hide");
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
        var addEveluationmodalspinner = component.find("addEveluationmodalspinner");
        $A.util.addClass(addEveluationmodalspinner, "slds-hide");
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
                if(singleInputField && singleInputField != null && singleInputField != undefined){
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