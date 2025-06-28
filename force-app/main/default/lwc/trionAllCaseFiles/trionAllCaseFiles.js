import { LightningElement, api, track } from 'lwc';
import getSharepointData1 from '@salesforce/apex/GetFileUsingCaseSPId_V1.getCaseFolderData';
import getSharepointData2 from '@salesforce/apex/GetCsvUsingCaseSPId_checkV12.getCaseRecordbyId';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class TrionAllCaseEmails extends NavigationMixin(LightningElement) {
    @api recordId;
    @track filesList = [];
    @track isDataLoaded = false;
    @track showFiles = false;
    subscription = {};
    channelName = '/event/FileListMapPlatform__e';
    processedIds = new Set();
    caseRecord = {};

    get fileCounter() {
        return this.filesList.length;
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
        const messageCallback = (response) => {
            console.log('New platform event received:', response);
            this.handlePlatformEvent(response.data.payload.fileDataPlatform__c);
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to:', JSON.stringify(response.channel));
            this.subscription = response;
        });

        onError(error => {
            console.error('Error in platform event subscription:', error);
        });
    }

    unsubscribeFromPlatformEvents() {
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from:', JSON.stringify(response));
            });
        }
    }

    handlePlatformEvent(fileDataPlatform) {
        console.log('Raw platform event payload:', fileDataPlatform);
        try {
            const parsedData = this.stringToObject(fileDataPlatform);
            console.log('Processing event payload:', parsedData);

            if (parsedData.ParentId === this.recordId) {
                const fileId = parsedData.fileId;

                if (!this.processedIds.has(fileId)) {
                    const fileEx = parsedData.fileType.split("/")[1];
                    if (fileEx === 'vnd.openxmlformats-officedocument.wordprocessingml.document') {
                        fileEx = 'docx';
                    } 
                    let iframeUrl = 'https://trionworks.sharepoint.com/sites/SalesforceArchive/_layouts/15/embed.aspx?UniqueId=' + parsedData.eTag;
                    const newFile = {
                        name: parsedData.name || '',
                        fileExtension: fileEx,
                        createdDateTime: this.formatDate(parsedData.createdDateTime || ''),
                        fileId: parsedData.fileId || '',
                        ParentId: parsedData.ParentId || '',
                        eTag: parsedData.eTag || '',
                        iframeUrl: iframeUrl,
                         downloadUrl: parsedData.downloadUrl,
                        size: this.formatSize(parsedData.size || ''),
                        fileIcon: this.fileIconPicker(fileEx)
                    };

                    this.filesList.push(newFile);
                    this.showFiles = this.filesList.length > 0;

                    this.processedIds.add(fileId);

                    console.log('Processed platform event payload:', newFile);
                } else {
                    console.log('Duplicate event ignored: ID already processed');
                }
            } else {
                console.log('Platform event ignored: ParentId does not match current recordId');
            }
        } catch (error) {
            console.error('Error parsing platform event payload:', error);
        }
    }



    stringToObject(str) {
    const predefinedKeys = ['name', 'fileType', 'createdDateTime', 'ParentId', 'fileId', 'size', 'downloadUrl', 'eTag'];

    str = str.trim().slice(1, -1);

    const obj = {};
    const regex = /([^=]+)=((?:https?:\/\/[^\s,]+)|(?:[^,]+))(?:,|$)/g;
    let match;

    while ((match = regex.exec(str)) !== null) {
        const key = match[1].trim();
        const value = match[2].trim();

        if (predefinedKeys.includes(key)) {
            obj[key] = value;
        }
    }

    const eTagRegex = /eTag=([^,]+)/;
    const eTagMatch = str.match(eTagRegex);
    if (eTagMatch) {
        obj['eTag'] = eTagMatch[1].trim();
    }

    return obj;
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
    formatSize(size) {
        if (size >= 1024 * 1024) {
            return Math.round(size / (1024 * 1024)) + " MB";
        } else {
            return Math.round(size / 1024) + " KB";
        }
    }
    fileIconPicker(extension) {
        if (extension == 'png' || extension == 'jpeg' || extension == 'jpg') {
            return 'doctype:image';
        } else if (extension == 'pdf') {
            return 'doctype:pdf';
        } else if (extension == 'doc' || extension == 'docx' || extension == 'msword') {
            return 'doctype:word';
        } else {
            return 'standard:document_preview';
        }
    }

    openPreview(event) {
 
       event.preventDefault();
    const selectedId = event.target.dataset.id;
    let selectedFile ;
        this.filesList.forEach( (file)=>{ if(file.fileId == selectedId){ selectedFile = file }} );
    console.log('selectedFile', selectedFile );

    if (selectedFile) {
        const showPreview = this.template.querySelector("c-file-preview");
        if (showPreview) {
            showPreview.fileDetails = selectedFile;
            showPreview.show();
            console.log('Modal opened');
        }
    }
  }
}