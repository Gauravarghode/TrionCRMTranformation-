({
    handleInitlization: function(component, event) {
        /*this.createDataTableHeaders(component, false);
        this.fetchOpportunityDetails(component, event);*/
        this.fetchObjectName(component, event);
        this.createDataTableHeaders(component, false);
        this.fetchStatePicklistValues(component,event);
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
                this.fetchClientContactsDetails(component,event,result.Id);  
                this.fetchProposalOpportunityDetails(component,event,result.Opportunity__c);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchProposalOpportunityDetails : function(component, event, recordId) {
        this.showSpinner(component);
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.opp", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchStatePicklistValues : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getStatePicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var stateMap = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        stateMap.push({key:key , value: result[key]});
                    }
                }
				component.set("v.mapStatePicklistValues", stateMap);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchClientContactsDetails : function(component, event, proposalId) {
        this.showSpinner(component);
        var action = component.get("c.getClientContacts");
        action.setParams({
            proposalId : proposalId,
            whereClause : component.get("v.clientContactsWhereClause")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.lstClientContacts", result);
                if(result != null && result != undefined){
                    var isContactInformation = component.get("v.isContactInformation");
                    
                    if(isContactInformation){
                        component.set("v.sortedBy", 'Type__c');
                    }else{
                        component.set("v.sortedBy", 'First_Name__c');
                    }
                    
                    component.set("v.sortedDirection", 'asc'); 
                    this.sortData(component, 'First_Name__c', 'asc');
                }
                component.find("clientTable").set("v.selectedRows", []);
                component.set("v.draftValues", []);
                component.set("v.selectedRows", []);
                component.set("v.isDelete", false);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteClinetContactRecords : function(component, event, selectedRecordId) {
        this.showSpinner(component);
        var action = component.get("c.deleteClientContacts");
        action.setParams({
            clientContactId : selectedRecordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record deleted successfully', 'success');
                $A.get('e.force:refreshView').fire();
                this.handleInitlization(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    saveClinetContactRecords : function(component, event, draftvalues) {
        this.showSpinner(component);
        var action = component.get("c.saveClientContacts");
        action.setParams({
            lstClientContacts : draftvalues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record updated successfully', 'success');
                this.fetchOpportunityDetails(component, event);
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
        var actions = [{ label: 'View', name: 'view' }, { label: 'Edit', name: 'edit' },{ label: 'Delete', name: 'delete' }];
        
        var isContactInformation = component.get("v.isContactInformation");
        if(isContactInformation){
            columns.push({label: 'Type', fieldName: 'Type__c', type: 'text', sortable:true, editable: isEditable });
            columns.push({label: 'First Name', fieldName: 'First_Name__c', type: 'text', sortable:true, editable: isEditable });
            columns.push({label: 'Last Name', fieldName: 'Last_Name__c', type: 'text', sortable:true, editable: isEditable });
            columns.push({label: 'Office Phone', fieldName: 'Phone__c', type: 'phone', sortable:true, editable: isEditable });
            columns.push({label: 'Mobile Phone', fieldName: 'Mobile__c', type: 'phone', sortable:true, editable: isEditable });
            columns.push({label: 'Email', fieldName: 'Email__c', type: 'email', sortable:true, editable: isEditable });
            columns.push({type: 'action', typeAttributes: { rowActions: actions }});
            component.set('v.columns', columns);
        }else{
            columns.push({label: 'First Name', fieldName: 'First_Name__c', type: 'text', sortable:true, editable: isEditable });
            columns.push({label: 'Last Name', fieldName: 'Last_Name__c', type: 'text', sortable:true, editable: isEditable });
            columns.push({label: 'Email', fieldName: 'Email__c', type: 'email', sortable:true, editable: isEditable });
            columns.push({label: 'Title/Relationship', fieldName: 'Title_Relationship__c', type: 'text', sortable:true, editable: isEditable });
            columns.push({label: 'Phone', fieldName: 'Phone_Number__c', type: 'phone', sortable:true, editable: isEditable });
            columns.push({type: 'action', typeAttributes: { rowActions: actions }});
            component.set('v.columns', columns);
        }
    },
    
    fetchClientLocationRecords : function(component, event, stateId) {
        this.showSpinner(component);
        var action = component.get("c.getClientLocationPicklistValues");
        action.setParams({
            proposalId : component.get("v.opp.Proposal__c"),
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
    
    submitClientLocationRecords : function(component, event) {
        this.showSpinner(component);
        var oClinetContactWrapper = component.get("v.oClinetContactWrapper");
        oClinetContactWrapper.isPrimary = component.get("v.isPrimary");
        oClinetContactWrapper.isIncluded = component.get("v.isIncluded");
        var action = component.get("c.createClientContacts");
        action.setParams({
            jsonWrapper : JSON.stringify(oClinetContactWrapper),
            opp : component.get("v.opp")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var isEdit = component.get('v.isEdit');
                var msg = 'Record created successfully';
                if(isEdit){
                    msg = 'Record updated successfully';
                }
                this.doShowToast(component, 'Success', msg, 'success');
                 $A.get('e.force:refreshView').fire();
                this.handleInitlization(component,event);
                component.set("v.isShowAddModal", false);
                component.set("v.isEdit", false);
        		component.set("v.mapClientLocationPicklistValues", []);
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
            proposalId : component.get("v.opp.Proposal__c"),
            stateId:stateId,
            accId:component.get("v.opp.AccountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isNewClientLocation", true);
                component.set("v.oClientLocation", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchClientLocationValue : function(component, event, locationId) {
        this.showSpinner(component);
        var action = component.get("c.getClientLocationValue");
        action.setParams({
            locationId : locationId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                let clinetContactWrapper = component.get("v.oClinetContactWrapper");
                clinetContactWrapper.clientLocation = result;
                component.set("v.oClinetContactWrapper", clinetContactWrapper);
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
                var clinetContactWrapper = component.get("v.oClinetContactWrapper");
                this.fetchClientLocationRecords(component, event, clinetContactWrapper.selectedState);
                clinetContactWrapper.selectedClientLocation = result;
                component.set("v.oClinetContactWrapper", clinetContactWrapper);
                component.set("v.isNewClientLocation", false);
                component.set("v.oClientLocation", null);
                var isRecordEdit = component.get("v.isRecordEdit");
                if(isRecordEdit){
                    component.set("v.isEdit", true);
                }else{
                    component.set("v.isShowAddModal", true);
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchClientContactType : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName : 'Client_Contact__c',
            fieldName : 'Type__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                var mapType = [];
                if(result != null && result != undefined){
                    var isContactInformation = component.get("v.isContactInformation");
                    
                    if(isContactInformation){
                        for(var key in result){
                            if(key == 'Inspection' || key == 'Accting Record' || key == 'Claims Info'){
                            	mapType.push({key:key , value: result[key]});    
                            }
                        }
                    }else{
                        for(var key in result){
                            mapType.push({key:key , value: result[key]});
                        }
                    }
                    
                    
                }
                component.set("v.mapType",mapType);
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
        var newmodalspinner = component.find("newmodalspinner");
        $A.util.removeClass(newmodalspinner, "slds-hide");
        var editmodalspinner = component.find("editmodalspinner");
        $A.util.removeClass(editmodalspinner, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var newmodalspinner = component.find("newmodalspinner");
        $A.util.addClass(newmodalspinner, "slds-hide");
        var editmodalspinner = component.find("editmodalspinner");
        $A.util.addClass(editmodalspinner, "slds-hide");
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
        var filteredData = component.get("v.lstClientContacts");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstClientContacts", filteredData);
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
    
    
    fatchClientContactEditRecord : function(component, event, helper){
        this.showSpinner(component);
        var clientContactrecordId = component.get('v.selectedRecordId');
        var action = component.get('c.getClientContactRecord');
        action.setParams({clientContactId : clientContactrecordId});
        action.setCallback(this, function(res){
            let state = res.getState();
            if(component.isValid && state ==='SUCCESS'){
                let result = res.getReturnValue();
                component.set('v.oClinetContactWrapper', result);
                component.set("v.isIncluded", result.isIncluded);
                component.set("v.isPrimary", result.isPrimary);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
})