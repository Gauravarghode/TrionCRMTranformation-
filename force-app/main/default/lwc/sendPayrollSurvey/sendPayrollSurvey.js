import {
    LightningElement,
    api,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import Account_OBJECT from "@salesforce/schema/Account";
import ID_FIELD from "@salesforce/schema/Account.Id";
import payrollController from "@salesforce/apex/PayrollSurveyController.getAccountAndContactDetails";
import {
    updateRecord,
    getRecord,
    getFieldValue
} from "lightning/uiRecordApi";

import SEND_SURVEY_EMAIL from "@salesforce/schema/Account.Send_First_Payroll_Survey__c";
import SURVEY_EMAIL_BOUNCED from "@salesforce/schema/Account.Survey_Email_Bounced__c";
import SEND_SURVEY_AGAIN from "@salesforce/schema/Account.Send_Survey_Again__c";
import LightningAlert from 'lightning/alert';
import LightningConfirm from "lightning/confirm";

const fieldsToGet = [ID_FIELD, SEND_SURVEY_EMAIL, SEND_SURVEY_AGAIN];
export default class SendPayrollSurvey extends LightningElement {
    @api recordId;
    account;
    accountData;

    @api invoke() {

        payrollController({ AccountId: this.recordId }).then(response => {
            this.accountData = response;
            if(!this.accountData.surveyEnabled){
                LightningAlert.open({
                    message: 'Please enable the surveys settings to send the surveys.',
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            } else if (this.accountData.surveySent) {
                if(this.accountData.sendSurveyAgain){
                    LightningAlert.open({
                        message: 'Please wait for atleast 5 minutes to send the other survey.',
                        theme: 'error', // a red theme intended for error states
                        label: 'Error!', // this is the header text
                    });
                } else {
                    LightningConfirm.open({
                        message: 'The survey was already sent on ' + this.accountData.payrollSurveyLastSentOn + '. Are you sure you want to send it again?',
                        theme: 'warning',
                        label: 'Are you sure?',
                        variant: 'header',
                    }).then((result) => {
                        if (result) {
                            this.updateAccountRecord();
                        }
                    });
                }
            } else {
                console.log('Inside else block');
                this.updateAccountRecord();
            }
        }).catch(error => {
            console.log('error is '+ JSON.stringify(error));
            const successToast = new ShowToastEvent({
                title: "Survey Send Failed",
                message: error.body.output.errors[0].errorCode + ': ' + error.body.output.errors[0].message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(successToast);
        })
    }

    updateAccountRecord() {
        console.log('Inside update record');
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[SEND_SURVEY_EMAIL.fieldApiName] = true;
        fields[SURVEY_EMAIL_BOUNCED.fieldApiName] = false;
        fields[SEND_SURVEY_AGAIN.fieldApiName] = true;
        console.log('this.record id is ' + this.recordId)
        const recordInput = { fields };
        updateRecord(recordInput).then((record) => {
            const successToast = new ShowToastEvent({
                title: "Survey Email Sent",
                message: "The survey email has been sent successfully!",
                variant: 'success'
            });
            this.dispatchEvent(successToast);
        })
        .catch(error => {
            console.log('error is '+ JSON.stringify(error));
            const successToast = new ShowToastEvent({
                title: "Survey Send Failed",
                message: error.body.output.errors[0].errorCode + ': ' + error.body.output.errors[0].message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(successToast);
        });

    }
}