({
    handleInitilize : function(component, event) {
        this.createDataTableHeaders(component);
        this.fetchSUTARecords(component, event);
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
    
    fetchSUTARecords : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getSUTARecords");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.lstSUTAQuotes", result);
                if(result != null && result != undefined){
                    component.set("v.sortedBy", 'Display_State_Assessment_Fee_on_Proposal__c');
                    component.set("v.sortedDirection", 'asc'); 
                    this.sortData(component, 'Display_State_Assessment_Fee_on_Proposal__c', 'asc');
                }
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    updateSUTARecordSurcharges : function(component, event, isIncluded) {
        this.showSpinner(component);
        var action = component.get("c.updateSUTARecords");
        action.setParams({
            lstSUTAQuotes : component.get("v.selectedRows"),
            isIncluded : isIncluded
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.doShowToast(component, 'Success', 'Records updated successfully', 'success');
                component.set("v.isShowCheckboxColumn", true);
                component.find("sutaTable").set("v.selectedRows", []);
                component.set("v.selectedRows", []);
                component.set("v.isExcluded", false);
                component.set("v.isIncluded", false);
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
        columns.push({label: 'State', fieldName: 'Display_State_Assessment_Fee_on_Proposal__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Assessment Fee', fieldName: 'Proposal_State_Assessment_and_Surcharge__c', type: 'text', sortable:true, editable: false });
        component.set('v.columns', columns);
    },
    
    showSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        /*var modalSpinner = component.find("modalspinner");
        $A.util.removeClass(modalSpinner, "slds-hide");
        var deletemodalspinner = component.find("deletemodalspinner");
        $A.util.removeClass(deletemodalspinner, "slds-hide");*/
    },
    
    hideSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        /*var modalSpinner = component.find("modalspinner");
        $A.util.addClass(modalSpinner, "slds-hide");
        var deletemodalspinner = component.find("deletemodalspinner");
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
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
})