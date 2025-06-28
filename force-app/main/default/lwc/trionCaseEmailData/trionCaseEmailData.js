import { LightningElement, wire, api, track } from 'lwc';
//import { subscribe, MessageContext } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import getSingleEmailData from '@salesforce/apex/GetCsvUsingCaseSPId.getSharepointIdfromEmailId';
import getCaseDetails from '@salesforce/apex/GetCsvUsingCaseSPId.getCaseRecordbyId';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_NAME_FIELD from "@salesforce/schema/User.Name";
import USER_ID_FIELD from "@salesforce/schema/User.Id";
import { NavigationMixin } from 'lightning/navigation';

const user_fields = [USER_NAME_FIELD, USER_ID_FIELD];

export default class TrionCaseEmailData extends NavigationMixin(LightningElement) {
    @track emailMessage = {};
    @api emailMessageId;
    isParamsLoaded = false;
    @track emailIdParam;
    @track caseIdParam;
    @api recId;
    caseRecord = {};

    @wire(getRecord, { recordId: "$emailMessage.CreatedById.", user_fields }) user;

  get userId() {
      console.log('user record >< >< '+ JSON.stringify(this.user) );
    return getFieldValue(this.user.data, USER_ID_FIELD);
  }

   get userName() {
       console.log('user record >< >< '+ JSON.stringify(this.user));
    return getFieldValue(this.user.data, USER_NAME_FIELD);
  } 
    // @wire(MessageContext) messageContext;
    
    @wire(CurrentPageReference) getStateParameters(currentPageReference) {
        if (currentPageReference) {
           
            this.emailIdParam = currentPageReference.state.c__emailId;
            this.caseIdParam = currentPageReference.state.c__caseId;
            this.getEmailMessage();
        }
    }

    getEmailMessage() {
       /* console.log( 'Param ',this.currentPageReference.state.c__emailId );
        if(this.currentPageReference.state.c__emailId){
            this.emailIdParam = this.currentPageReference.state.c__emailId;
            this.caseIdParam = this.currentPageReference.state.c__caseId;
            this.isParamsLoaded = true;
        }
        
        console.log(' ~~  email id '+this.emailIdParam);
        console.log(' ~~  case id '+this.caseIdParam);*/
        getSingleEmailData({ caseParentId: this.caseIdParam, eachEmailMessageIdFromSp: this.emailIdParam })
          .then(result => {
              console.log('Result singleEmailData ', JSON.stringify(result) );
              this.emailMessage = JSON.parse(JSON.stringify(result)) ;
              console.log(' ><! case id '+this.emailMessage.ParentId);
                let formattedCreatedDate = this.formatDate(this.emailMessage.CreatedDate);
                this.emailMessage.CreatedDate = formattedCreatedDate;
                let formattedLastModDate = this.formatDate(this.emailMessage.LastModifiedDate);
                this.emailMessage.LastModifiedDate = formattedLastModDate;

                getCaseDetails({ caseId: this.caseIdParam })
                .then(result => {
                    this.caseRecord = result;
                    console.log('Result case record', result);
                })
                .catch(error => {
                    console.error('Error: case record', error);
                });
          })
          .catch(error => {
            console.error('Error:', error);
        });
         this.isParamsLoaded = true;
        
        // if (this.messageContext) {
        //     this.subscribeToMessageChannel();
        // } else {
        //     console.error('Message context is not available');
        // }
    }

disconnectedCallback() {
     console.log('disconnected : email data component '+this.emailIdParam);
    this.emailIdParam = null;
    console.log('disconnected : email data component '+this.emailIdParam);
}
    // subscribeToMessageChannel() {
    //     subscribe(
    //         this.messageContext,
    //         'EmailDataPayload__e',
    //         (message) => {
    //             this.handleMessage(message);
    //         }
    //     );
    // }

    handleMessage(message) {
        // Extract the data from the message and assign it to the emailMessage object
        this.emailMessage = {
 /*           Subject: message.Subject__c,
            FromAddress: message.FromAddress__c,
            ToAddress: message.ToAddress__c,
            MessageDate: message.MessageDate__c,
            BccAddress: message.BccAddress__c,
            CcAddress: message.CcAddress__c,
            CreatedDate: message.CreatedDate__c,
            Headers: message.Headers__c,
            HtmlBody: message.HtmlBody__c,
            IdOfCsv: message.IdOfCsv__c,
            ParentId: message.ParentId__c,
            TextBody: message.TextBody__c,
*/
            Subject: message.Subject,
            FromAddress: message.FromAddress,
            ToAddress: message.ToAddress,
            MessageDate: message.MessageDate,
            BccAddress: message.BccAddress,
            CcAddress: message.CcAddress,
            CreatedDate: message.CreatedDate,
            Headers: message.Headers,
            HtmlBody: message.HtmlBody,
            IdOfCsv: message.IdOfCsv,
            ParentId: message.ParentId,
            TextBody: message.TextBody,
            Status: message.Status,
            LastModifiedById: message.LastModifiedById,
            FromName: message.FromName,
            

        };
    }

    openCaseRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecord.Id,
                actionName: 'view'
            }
        });
    }

    openUserRecord(evnt){
        let selectedUserId = evnt.target.dataset.id
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedUserId,
                actionName: 'view'
            }
        });
    }

     formatDate(dateString) {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const formattedDate = new Date(dateString).toLocaleDateString('en-US', options);
        return formattedDate;
    }

    /*
    BccAddress: "\"##  deepakkumar@enabledanalytics.com\""
CcAddress: "\"##  null\""
CreatedDate: "\"##  2024-01-30T07:28:07.000Z\""
FromAddress: "\"##  deepakkumar@enabledanalytics.com\""
Headers: "\"##  In-Reply-To: <LSKIU000000000000000000000000000000000000000000000S7T40H00jAwOeIPNR_GefC-jKe5MJw@sfdc.net>\nReferences: <WVVWf000000000000000000000000000000000000000000000S7T3JN008oU_iQsLS-WVBwZzYJV2Pw@sfdc.net> <LSKIU000000000000000000000000000000000000000000000S7T40H00jAwOeIPNR_GefC-jKe5MJw@sfdc.net>\""
IdOfCsv: "HtmlBody\n\"##  02sVE000000GrmjYAC\""
MessageDate: "\"##  2024-01-30 07:28:27\""
ParentId: "\"##  500VE000001sdS2YAI\""
Subject: "\"##  RE: TEST IGNORE    [ ref:!00DVE01ecv.!500VE01sdS2:ref ]\""
TextBody: "\"##  --------------- Original Message ---------------\nFrom: Deepak Kumar [deepakkumar@enabledanalytics.com]\nSent: 1/25/2024 2:41 AM\nTo: b.deepakkumar782@gmail.com\nSubject: RE: TEST IGNORE [ ref:!00DVE01ecv.!500VE01sdS2:ref ]\n\n--------------- Original Message ---------------\nFrom: Deepak Kumar [deepakkumar@enabledanalytics.com]\nSent: 1/25/2024 2:30 AM\nTo: b.deepakkumar782@gmail.com\nSubject: TEST IGNORE [ ]\n\nTEST IGNORE\nref:!00DVE01ecv.!500VE01sdS2:ref\""
ToAddress: "\"##  b.deepakkumar782@gmail.com\""
    */
}