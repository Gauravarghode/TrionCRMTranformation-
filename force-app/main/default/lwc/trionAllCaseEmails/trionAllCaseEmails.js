import { LightningElement, api, track } from 'lwc';
import getSharepointData1 from '@salesforce/apex/GetCsvUsingCaseSPId_checkV12.getSharepointId';
import getSharepointData2 from '@salesforce/apex/GetCsvUsingCaseSPId_checkV12.getCaseRecordbyId';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class TrionAllCaseEmails extends NavigationMixin(LightningElement) {
    @api recordId;
    @track emails = [];
    @track emailsToDisplay = [];
    @track showEmails = false;
    @track isDataLoaded = false;
    subscription = {};
    channelName = '/event/ListMapPlatform_V2__e';
    caseRecord = {};
     processedIds = new Set();

    get emailCounter() {
        return this.emails.length;
    }

     connectedCallback() {
        try {
             this.subscribeToPlatformEvents();
             this.runFirstMethod();
             this.runSecondMethod();
        } catch (error) {
            console.error('Error during component initialization: ', error);
        }
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvents();
    }

    async runSecondMethod() {
        try {
            const result = await getSharepointData2({ caseId: this.recordId });
            this.caseRecord = result;
            console.log('Result case record', result);
        } catch (error) {
            console.error('Error fetching case record: ', error);
        }
    }

    async runFirstMethod() {
        try {
            await getSharepointData1({ caseParentId: this.recordId });
            console.log('First method executed successfully');
        } catch (error) {
            console.error('Error executing first method:', error);
        }
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
            Status: eventPayload.Status__c
        };

        console.log('Processing event payload:', parsedData);

        if (parsedData.ParentId === this.recordId) {
            const newEmail = {
                FromAddress: parsedData.FromAddress || '',
                ToAddress: parsedData.ToAddress || '',
                MessageDate: this.formatDate(parsedData.CreatedDate || ''),
                IdOfCsv: parsedData.IdOfCsv || '',
                Subject: parsedData.Subject || '',
                ParentId: parsedData.ParentId || '',
                Status: parsedData.Status || '',
            };

            if (!this.processedIds.has(newEmail.IdOfCsv)) {
                this.processedIds.add(newEmail.IdOfCsv);
                this.emails = [...this.emails, newEmail];
                this.emailsToDisplay = this.emails.slice(0, 2);
                this.isDataLoaded = true;

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


    stringToObject(str) {
    const predefinedKeys = [
        'ToAddress', 'Subject', 'CreatedDate', 'ParentId',
        'IdOfCsv', 'Status', 'FromAddress'
    ];

    // Trim the leading and trailing parentheses
    str = str.trim().slice(2, -2);

    const obj = {};
    const regex = /([^=]+)=([^,{}]+?(?=,|})|[^{}]+)(?:,|$)/g;
    let match;

    while ((match = regex.exec(str)) !== null) {
        const key = match[1].trim();
        const value = match[2].trim();
        
        // Handle possible quotes around values
        const cleanedValue = value.replace(/^"(.*)"$/, '$1');
        
        if (predefinedKeys.includes(key)) {
            obj[key] = cleanedValue;
        }
    }

    return obj;
}

    handleNavigateToMessage(evt) {
        evt.stopPropagation();
        const emailId = evt.currentTarget.dataset.emailid;
        console.log('Test', emailId);
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

    openCaseList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    openCaseRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
    formatDate(dateString) {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const formattedDate = new Date(dateString).toLocaleDateString('en-US', options);
        return formattedDate;
    }
}