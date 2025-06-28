({
    handleInitlization: function(component, event) {
        this.fetchObjectName(component, event);
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
                    this.fetchOpportunityDetails(component, event, component.get("v.recordId"));
                }else{
                    component.set("v.proposalId", component.get("v.recordId"));
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
    
    fetchPicklistValues : function(component, event, objectName, fieldName, ACORDType) {
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
                var mapOfACORDType = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        mapOfACORDType.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapOfACORDType",mapOfACORDType);
                component.set("v.selectedAcordtype", ACORDType);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    
    fetchOpportunityDetails : function(component, event, recordId) {
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
                component.set("v.proposalId", result.Proposal__c);
                this.fetchProposalDetailsOnly(component, event, result.Proposal__c);
                this.createDataTableHeaders(component, event);
                this.fetchSubmissionRequirements(component, event);
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
                this.fetchOpportunityDetails(component,event,result.Opportunity__c); 
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchProposalDetailsOnly : function(component, event, recordId) {
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
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchSubmissionRequirements : function(component, event) {
        this.showSpinner(component);
        console.log(component.get("v.status"));
        var action = component.get("c.getSubmissionRequirement");
        action.setParams({
            recordId : component.get("v.opp.Id"),
            status : component.get("v.status"),
            Requiredstatus : component.get("v.Requiredstatus"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.lstSubmissionRequirement", result);
                if(result != null && result != undefined){
                    component.set("v.sortedBy", 'Required_Optional__c');
                    component.set("v.sortedDirection", 'desc'); 
                    this.sortData(component, 'Required_Optional__c', 'desc');
                }
                component.set("v.selectedRows", null);
                component.find("submissionTable").set("v.selectedRows", []);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    fetchSubmissionRequirementType : function(component, event){
        this.showSpinner(component);
        var action = component.get("c.getSubmissionRequirementType");
        action.setParams({
            recordId : component.get("v.opp.Id"),
            status : component.get("v.status")
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var result = res.getReturnValue();
                component.set("v.lstRequirmentType", result);
            }else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
        
    },
    
    submitSubmissionRequirements : function(component, event, isSubmit) {
        this.showSpinner(component);
        var action = component.get("c.updateSubmissionRequirement");
        action.setParams({
            oProposal : component.get("v.oProposal"),
            oSubmissionRequirement : component.get("v.oSubmissionRequirement"),
            notes : component.get("v.submissionRequirementNotes"),
            isSubmit : isSubmit
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record updated successfully', 'success');
                if(isSubmit){
                    component.set("v.isShowUploadModal", false);
                    component.set("v.isFileUploaded", false);
                    component.set("v.isShowAddNote", false);
                    component.set("v.oSubmissionRequirement", null);
                    component.set("v.submissionRequirementNotes", null);
                    component.set("v.selectedRecordId", null);
                    component.set("v.natureofBusinessDescription", null);
                    component.set("v.submissionRequirementNotes", null);
                    this.handleInitlization(component, event);
                    this.navigateToRecord(component, event, component.get("v.recordId"));
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createProposalSubmitSubmissionRequirement : function(component, event, submissionRequirementObj, isSubmit) {
        this.showSpinner(component);
        var action = component.get("c.createProposalAndupdateSubmissionRequirement");
        action.setParams({
            oProposal: component.get("v.oProposal"),
            oSubmissionRequirement : submissionRequirementObj,
            submissionRequirementId : component.get("v.oSubmissionRequirement.Id"),
            notes : component.get("v.submissionRequirementNotes"),
            isSubmit : isSubmit
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record updated successfully', 'success');
                if(isSubmit){
                    component.set("v.isShowUploadModal", false);
                    component.set("v.isFileUploaded", false);
                    component.set("v.isShowAddNote", false);
                    component.set("v.oSubmissionRequirement", null);
                    component.set("v.submissionRequirementNotes", null);
                    component.set("v.selectedRecordId", null);
                    component.set("v.natureofBusinessDescription", null);
                    component.set("v.submissionRequirementNotes", null);
                    this.handleInitlization(component, event);
                    this.navigateToRecord(component, event, component.get("v.recordId"));
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchContentDocumentId : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getContentDocumentId");
        action.setParams({
            parentId : component.get("v.oSubmissionRequirement.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null && result != undefined && result != '' && result.length > 0){
                    $A.get('e.lightning:openFiles').fire({
                        recordIds: result
                    });
                    component.set("v.contentDocumentId", result);
                }else{
                    this.doShowToast(component, 'Error', 'No Document found', 'error');
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    deleteFileUpdateSubmissionRequirement : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.deleteFileAndUpdateSubmissionRequirement");
        action.setParams({
            submissionRequirementId : component.get("v.oSubmissionRequirement.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record deleted successfully', 'success');
                component.set("v.isShowViewModal", false);
                component.set("v.oSubmissionRequirement", null);
                component.set("v.contentDocumentId", null);
                this.handleInitlization(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getWCRateRecords : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getWCRate");
        action.setParams({
            proposalId : component.get("v.proposalId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null && result != undefined){
                    result.forEach(function(record){
                        if(record.SUTA_Quote__r.State__c != null && record.SUTA_Quote__r.State__c != undefined){
                            record.WCStateName = record.SUTA_Quote__r.State__r.Name;
                        }
                        if(record.Client_Location__c != null && record.Client_Location__c != undefined && record.Client_Location__r.Loc__c != null && record.Client_Location__r.Loc__c != undefined){
                            record.Client_Location = record.Client_Location__r.Loc__c;
                        }
                    });
                }
                component.set("v.lstWCRate", result);
                component.set("v.WCRateSortedBy", 'Client_Location');
                component.set("v.WCRateSortedDirection", 'asc'); 
                this.sortWCRateData(component, 'Client_Location', 'asc');
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateWCRateHelper : function(component, event, oWCRate) {
        this.showSpinner(component);
        var action = component.get("c.updateWCRate");
        action.setParams({
            oWCRate : oWCRate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Record updated successfully', 'success');
                this.handleInitlization(component, event);
                this.getWCRateRecords(component, event);
                component.set("v.selectedWcRateId", null);
                component.set("v.selectedWcRateName", null);
                component.set("v.isShowStateRatingModal", false);
                component.set("v.isShowUploadModal", true);
                component.set("v.oWCRate", null);
                component.set("v.wcRateWhereClause", null);
                component.set("v.selectedStateCompCode", null);
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
    
    fetchShowCongaButtons : function(component, event, submissionDocId) {
        this.showSpinner(component);
        var action = component.get("c.isShowCongaButtons");
        action.setParams({
            submissionDocId : submissionDocId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.isShowAccordSignatureRequestButton", result);
                component.set("v.isShowGenerateACORDButton", result);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchAccordSignatureRequestURL : function(component, event, submissionDocId) {
        this.showSpinner(component);
        var action = component.get("c.getAccordSignatureRequestURL");
        action.setParams({
            submissionDocId : submissionDocId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null && result != '' && result != undefined){
                    window.open(result,'_blank');
                }else{
                    this.doShowToast(component, 'Error', $A.get("$Label.c.SD_AccordSignatureRequestMessage"), 'error');
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    fetchGenerateACORD : function(component, event, submissionDocId) {
        this.showSpinner(component);
        var action = component.get("c.getGenerateACORD");
        action.setParams({
            submissionDocId : submissionDocId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null && result != '' && result != undefined){
                    window.open(result,'_blank'); 
                }else{
                    this.doShowToast(component, 'Error', $A.get("$Label.c.SD_GenerateAccordMessage"), 'error');
                }
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
        var actions = [{ label: 'View', name: 'view' },{ label: 'Edit', name: 'edit' }, { label: 'Delete', name: 'delete' }];//, { label: 'Accord Signature Request', name: 'Accord_Signature_Request' }, { label: 'Generate ACORD', name: 'Generate_ACORD' }
        columns.push({label: 'Document', fieldName: 'Requirement_Type__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Required/Optional', fieldName: 'Required_Optional__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Status', fieldName: 'Status__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'ACORD Type', fieldName: 'ACORD_Type__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Notes', fieldName: 'Notes__c', type: 'text', sortable:true, editable: false });
        columns.push({type: 'action', typeAttributes: { rowActions: actions }});
        component.set('v.columns', columns);
    },
    
    createWCRateDataTableHeaders : function(component){
        var columns = [];
        var actions = [{ label: 'Edit', name: 'edit' }];
        columns.push({label: 'Loc #', fieldName: 'Client_Location', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'State Name', fieldName: 'WCStateName', type: 'text', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'Class Code/Description', fieldName: 'Description__c', type: 'text', sortable:true, editable: false });
        columns.push({label: '# Part Time Employees', fieldName: 'Part_Time_Employees__c', type: 'number', sortable:true, editable: false,cellAttributes: { alignment: 'left' } });
        columns.push({label: '# Full Time Employees', fieldName: 'of_Employees__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'Rate', fieldName: 'Current_Rate__c', type: 'percent-fixed', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({label: 'Estimated Annual Manual Premium', fieldName: 'Estimated_Annual_Manual_Premium__c', type: 'currency', sortable:true, editable: false, cellAttributes: { alignment: 'left' } });
        columns.push({type: 'action', typeAttributes: { rowActions: actions }});
        component.set('v.WCRateColumns', columns);
    },
    
	showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var newmodalspinner = component.find("newmodalspinner");
        $A.util.removeClass(newmodalspinner, "slds-hide");
        var addCompCodemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.removeClass(addCompCodemodalspinner, "slds-hide");
        var editRatingmodalspinner = component.find("editRatingmodalspinner");
        $A.util.removeClass(editRatingmodalspinner, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var newmodalspinner = component.find("newmodalspinner");
        $A.util.addClass(newmodalspinner, "slds-hide");
        var addCompCodemodalspinner = component.find("addCompCodemodalspinner");
        $A.util.addClass(addCompCodemodalspinner, "slds-hide");
        var editRatingmodalspinner = component.find("editRatingmodalspinner");
        $A.util.addClass(editRatingmodalspinner, "slds-hide");
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
        var filteredData = component.get("v.lstSubmissionRequirement");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstSubmissionRequirement", filteredData);
    },
    
    sortWCRateData: function (component, fieldName, sortDirection) {
        var filteredData = component.get("v.lstWCRate");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.lstWCRate", filteredData);
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
                        //inputField.showHelpMessageIfInvalid();
                        isValidationPassed = false;
                    }
                });
            }else{
                var singleInputField = component.find(auraIdOfInputsToBeValidated);
                if(singleInputField){
                    if(singleInputField.get('v.required') && !singleInputField.get('v.value')){
                        //singleInputField.showHelpMessageIfInvalid();
                        isValidationPassed = false;
                    }
                }
            }
        });
        return isValidationPassed;
    },
})