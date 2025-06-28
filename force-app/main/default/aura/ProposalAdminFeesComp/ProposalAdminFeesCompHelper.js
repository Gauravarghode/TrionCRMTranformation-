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
    
    fetchProposalDetails: function(component, event) {
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
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchAdministrativeFeeTypePickValues : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName : 'Proposal__c',
            fieldName : 'Administrative_Fee_Type__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapAdministrativeFeeType = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapAdministrativeFeeType.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapAdministrativeFeeType",mapAdministrativeFeeType);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchDeliveryFeePerLocationPickValues : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName : 'Proposal__c',
            fieldName : 'Delivery_Fee_Per_Location__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapDeliveryFeePerLocation = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapDeliveryFeePerLocation.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapDeliveryFeePerLocation",mapDeliveryFeePerLocation);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchPerCheckFrequencyPickValues : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName : 'Proposal__c',
            fieldName : 'Per_Check_Frequency__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapPerCheckFrequency = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapPerCheckFrequency.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapPerCheckFrequency",mapPerCheckFrequency);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updatePoropaslValues : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.updateProposal");
        action.setParams({
            oProposal : component.get("v.oProposal")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record updated successfully!', 'success');
                component.set("v.isShowAdminFeesModal", false);
                this.navigateToRecord(component, event, component.get("v.recordId"));
                //$A.get('e.force:refreshView').fire();
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
    
    showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        /*var deletemodalspinner = component.find("deletemodalspinner");
        $A.util.removeClass(deletemodalspinner, "slds-hide");*/
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        /*var deletemodalspinner = component.find("deletemodalspinner");
        $A.util.addClass(deletemodalspinner, "slds-hide");*/
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