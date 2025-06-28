import {
    LightningElement,
    api
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import ID_FIELD from "@salesforce/schema/Case.Id";

import {
    updateRecord
} from "lightning/uiRecordApi";

import LightningConfirm from "lightning/confirm";
import LightningAlert from 'lightning/alert';
import caseController from "@salesforce/apex/PayrollSurveyController.getCaseAndContactDetails";

import SEND_SURVEY_EMAIL from "@salesforce/schema/Case.Send_Survey_Email__c";
import SEND_SURVEY_EMAIL_AGAIN from "@salesforce/schema/Case.Send_Survey_Email_Again__c";
import SURVEY_EMAIL_BOUNCED from "@salesforce/schema/Case.Survey_Email_Bounced__c";

export default class SendSurveyFromCasesHeaderless extends LightningElement {
    @api recordId;
    caseWrapper;

    @api invoke() {
        console.log('Record id is ' + this.recordId);
        caseController({ CaseId: this.recordId }).then(response => {
            this.caseData = response;
            if(!this.caseData.surveyEnabled){
                LightningAlert.open({
                    message: 'Please enable the surveys settings to send the surveys.',
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            } else if (this.caseData.sendSurveyAgain) {
                LightningAlert.open({
                    message: 'Please wait for atleast 5 minutes to send the other survey.',
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            } else if (!this.caseData.ContactEmail){
                LightningAlert.open({
                    message: 'Please fill in the contact before sending the survey.',
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            } else if (!this.caseData.numberOfSurveyDays){
                LightningAlert.open({
                    message: 'Please fill in the contact type on the contact before sending the survey.',
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            } else if (this.caseData.numberOfDaysLeft > 0) {
                LightningConfirm.open({
                    message: 'The survey was last sent to this contact on ' + this.caseData.surveyLastSent + '. It is advisable to wait for ' + this.caseData.numberOfDaysLeft + ' more day(s). Are you sure you want to send it again?',
                    theme: 'warning',
                    label: 'Are you sure?',
                    variant: 'header',
                }).then((result) => {
                    if (result && this.caseData.caseSurveyLastSentOn) {
                        //this.updateAccountRecord();
                        this.showSurveyAlreadySentPopUp();
                    } else if(result && !this.caseData.caseSurveyLastSentOn){
                        this.updateAccountDetails();
                    }
                });
            } else if (this.caseData.caseSurveyLastSentOn) {
                this.showSurveyAlreadySentPopUp();
            } else {
                this.updateAccountDetails();
            }
        })
    }

    showSurveyAlreadySentPopUp() {
        LightningConfirm.open({
            message: 'The survey was already sent for this case on ' + this.caseData.caseSurveyLastSentOn + '. Are you sure you want to send it again?',
            theme: 'warning',
            label: 'Are you sure?',
            variant: 'header',
        }).then((result) => {
            if (result) {
                this.updateAccountDetails();
            }
        });
    }

    updateAccountDetails() {

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[SEND_SURVEY_EMAIL.fieldApiName] = true;
        fields[SEND_SURVEY_EMAIL_AGAIN.fieldApiName] = true;
        fields[SURVEY_EMAIL_BOUNCED.fieldApiName] = false;
        const recordInput = { fields };

        updateRecord(recordInput).then((record) => {
            const successToast = new ShowToastEvent({
                title: "Survey Email Sent",
                message: "The survey email has been sent successfully!",
                variant: 'success'
            });
            this.dispatchEvent(successToast);
        }).catch(error => {
            const successToast = new ShowToastEvent({
                title: "Survey Email send failed",
                message: error.body.output.errors[0].errorCode + ': ' + error.body.output.errors[0].message,
                variant: 'error'
            });
            this.dispatchEvent(successToast);
        })
    }

}