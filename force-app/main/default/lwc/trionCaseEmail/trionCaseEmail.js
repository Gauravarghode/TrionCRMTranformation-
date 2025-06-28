import { LightningElement, api, wire } from 'lwc';
import getSharepointData1 from '@salesforce/apex/GetCsvUsingCaseSPId_checkV12.getSharepointId';
//import getSharepointData2 from '@salesforce/apex/GetCsvUsingCaseSPId_checkV12Handler.processSharepointEmailIds';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class FilteredRelatedCaseList extends NavigationMixin(LightningElement) {
    @api recordId;
    emails = [];
    emailsToDisplay = [];
    showEmails = false;
    subscription = {};
    channelName = '/event/ListMapPlatform_V2__e';
     processedIds = new Set();


    connectedCallback() {
        this.runFirstMethod();
        this.subscribeToPlatformEvents();
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvents();
    }

    runFirstMethod() {
        getSharepointData1({ caseParentId: this.recordId })
            .then((data) => {
                console.log('First method executed successfully ',data);
            })
            .catch(error => {
                console.error('Error executing first method:', error);
            });
    }

    subscribeToPlatformEvents() {
    return new Promise((resolve, reject) => {
        const messageCallback = (response) => {
            console.log('New platform event received: ', response);
            this.handlePlatformEvent(response.data.payload);
        };

        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                console.log('Subscription request sent to: ', JSON.stringify(response.channel));
                this.subscription = response;
                resolve();
            })
            .catch(error => {
                console.error('Error in platform event subscription: ', error);
                reject(error);
            });

        onError(error => {
            console.error('Error in platform event subscription: ', error);
            reject(error);
        });
    });
}

    unsubscribeFromPlatformEvents() {
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from: ', JSON.stringify(response));
            });
        }
    }

handlePlatformEvent(eventPayload) {
    console.log('Raw platform event payload:', eventPayload);
    try {
        const parsedData = {
            IdOfCsv: eventPayload.Id__c,
            ParentId: eventPayload.ParentId__c,
            FromAddress: eventPayload.FromAddress__c,
            ToAddress: eventPayload.ToAddress__c,
            CreatedDate: eventPayload.CreatedDate__c,
            Subject: eventPayload.Subject__c,
        };

        console.log('Processing event payload:', parsedData);

        if (parsedData.ParentId === this.recordId) {
            const newEmail = {
                    FromAddress: parsedData.FromAddress || '',
                    ToAddress: parsedData.ToAddress || '',
                    MessageDate: parsedData.CreatedDate || '',
                    IdOfCsv: parsedData.IdOfCsv || '',
                    Subject: parsedData.Subject || '',
                    ParentId: parsedData.ParentId || '',
            };

            if (!this.processedIds.has(newEmail.IdOfCsv)) {
                this.processedIds.add(newEmail.IdOfCsv);
                this.emails = [...this.emails, newEmail];
                this.emailsToDisplay = this.emails.slice(0, 2);
                this.showEmails = this.emailsToDisplay.length > 0;

                console.log('Processed platform event payload: ', newEmail);
            } else {
                console.log('Duplicate email ignored: ', newEmail.IdOfCsv);
            }
        } else {
            console.log('Platform event ignored: ParentId does not match current recordId');
        }
    } catch (error) {
        console.error('Error processing platform event payload: ', error);
    }
}



//   handlePlatformEvent(csvInfoList) {
//         console.log('Raw platform event payload:', csvInfoList);
//     try {
//         const parsedData = this.stringToObject(csvInfoList);
//         console.log('Processing event payload:', parsedData);

//         if (parsedData.ParentId === this.recordId) {
//             const emailId = parsedData.IdOfCsv;

//             if (!this.processedIds.has(emailId)) {
//                 const newEmail = {
//                     FromAddress: parsedData.FromAddress || '',
//                     ToAddress: parsedData.ToAddress || '',
//                     MessageDate: parsedData.CreatedDate || '',
//                     IdOfCsv: parsedData.IdOfCsv || '',
//                     Subject: parsedData.Subject || '',
//                     ParentId: parsedData.ParentId || '',
//                     //HtmlBody: parsedData.HtmlBody || ''
//                 };

//                 this.emails.push(newEmail);
//                 this.emailsToDisplay = this.emails.slice(0, 2);
//                 this.showEmails = this.emailsToDisplay.length > 0;

//                 this.processedIds.add(emailId);

//                 console.log('Processed platform event payload: ', newEmail);
//             } else {
//                 console.log('Duplicate event ignored: ID already processed');
//             }
//         } else {
//             console.log('Platform event ignored: ParentId does not match current recordId');
//         }
//     } catch (error) {
//         console.error('Error parsing platform event payload: ', error);
//     }
// }


stringToObject(str) {

         const predefinedKeys = [ 'ToAddress', 'FromAddress', 'Subject', 'CreatedById', 'CreatedDate', 'ParentId', 'IdOfCsv'];

    // Trim the leading and trailing brackets
    str = str.trim().slice(2, -2);

    const obj = {};
    const regex = /([^=]+)=([^,]+)(?:,|$)/g;
    let match;

    while ((match = regex.exec(str)) !== null) {
        const key = match[1].trim();
        const value = match[2].trim();
        
        if (predefinedKeys.includes(key)) {
            obj[key] = value;
        }
    }

    return obj;
}




    viewAllRecords(event) {
        var compDefinition = {
            componentDef: "c:trionAllCaseEmails",
            attributes: {
                recordId: this.recordId
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    viewRecordDetails(event) {
        event.preventDefault();
        const emailId = event.currentTarget.dataset.emailId;
        const selectedEmail = this.emails.find(email => email.IdOfCsv === emailId);
        if (selectedEmail) {
            this.publishPlatformEvent(selectedEmail);
        } else {
            console.error('Email not found with ID:', emailId);
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Email_Messages'
            },
        });
    }

    get cardLabel() {
        return 'Related Emails (' + this.emails.length + ')';
    }

    handleNavigateToMessage(event) {
        event.preventDefault();
        event.stopPropagation();
        const emailId = event.currentTarget.dataset.emailId;
        this.out_Email = emailId;
        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "Email_Messages",
            },
            state: {
                c__emailId: emailId,
                c__caseId: this.recordId
            }
        });
    }
}