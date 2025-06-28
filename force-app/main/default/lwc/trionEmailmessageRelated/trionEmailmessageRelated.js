import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRelatedFilesByEmailId from '@salesforce/apex/GetCsvUsingCaseSPId_V2.getfileDataTwoParameter';
import getCaseDetails from '@salesforce/apex/GetCsvUsingCaseSPId.getCaseRecordbyId';
import { NavigationMixin } from 'lightning/navigation';

export default class trionEmailmessageRelated extends NavigationMixin(LightningElement) {
    @track showPreview = false;
    @track selectedFile = 'abc';
    emailIdParam;
    caseIdParam;
    @track filesArray = [];
    @track attachmentsCounter ;
    @track caseDetails;
    @track hasAttachments = false

     @wire(CurrentPageReference) currentPageReference;

    connectedCallback() {
        this.emailIdParam = this.currentPageReference.state.c__emailId;
        this.caseIdParam = this.currentPageReference.state.c__caseId;
        console.log('case id fetched '+this.caseIdParam);

        getRelatedFilesByEmailId({ caseParentId: this.caseIdParam, eachEmailMessageIdFromSp: this.emailIdParam })
          .then(result => {
            console.log('Result of related files comp ', result );
            if(result !== '{}') {
                this.handleResponse(result);
                this.hasAttachments = true;
                this.attachmentsCounter = this.filesArray.length;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });

        getCaseDetails({ caseId: this.caseIdParam })
          .then(result => {
              this.caseDetails = result;
            console.log('Result caseDetails', result);
          })
          .catch(error => {
            console.error('Error:t caseDetails', error);
        });
    }

    disconnectedCallback() {
        this.caseDetails = null;
        this.filesArray = [];
        console.log('email related files disconnected..');
    }
    openPreview(evt) {
        evt.preventDefault();
        const selectedEtag = evt.target.dataset.id;
        let selectedFile ;
        this.filesArray.forEach( (file)=>{ if(file.eTag == selectedEtag){ selectedFile = file }} );
                        console.log('Modal opened',selectedFile );
        this.showPreview = true;
        if (selectedFile) {
            const showPreview = this.template.querySelector("c-file-preview");
            if (showPreview) {
                showPreview.fileDetails = selectedFile;
                showPreview.show();
                console.log('Modal opened',selectedFile );
            }
        }
    }

    closePreview() {
        this.showPreview = false;
    }

    handleResponse(data){
        console.log('handling response... ');
        let valueList = JSON.parse(data).value;
        let counter = 0; 
        this.filesArray = [];
        valueList.forEach( (item)=>{
            console.log('each item begin '+item);
             if( counter < 3 ){
                if(!(item.name.includes("EmailMessageDetails") && item.file.mimeType == "application/vnd.ms-excel")){
                    let etag = item["eTag"];
                    let etagEndIndex = etag.indexOf("}");
                    let etagSubstr = etag.substring(2,etagEndIndex);
                    let fileEx = item.file.mimeType.split("/")[1];
                    if (fileEx === 'vnd.openxmlformats-officedocument.wordprocessingml.document') {
                            fileEx = 'docx';
                        } 
                    let icon = this.fileIconPicker(fileEx);

                    console.log('etag '+ etagSubstr + ' raw '+ etag);
                    let iframeUrl = 'https://trionworks.sharepoint.com/sites/SalesforceArchive/_layouts/15/embed.aspx?UniqueId='+etagSubstr;
                    let newItem = {
                        name : item.name,
                        downloadUrl : item["@microsoft.graph.downloadUrl"],
                        size : this.formatSize(item.size),
                        fileExtension : fileEx ,//item.file.mimeType,
                        createdDateTime : this.formatDate(item.fileSystemInfo.createdDateTime),
                        eTag : etagSubstr,
                        webUrl : item.webUrl,
                        iframeUrl : iframeUrl,
                        fileId : item.id,
                        fileIcon : icon,
                        fullFileType : item.file.mimeType
                    };
                    console.log('proceessed item '+JSON.stringify(newItem) );
                    this.filesArray.push(newItem);   
                }
            }
            counter++;
        } );
        this.attachmentsCounter = counter - 1 ;//counter;
            console.log('~~~ finished procesing - count '+counter);
            console.log('finally processed '+ JSON.stringify(this.filesArray) );
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

    fileIconPicker(extension){
        if(extension == 'png' || extension == 'jpeg' || extension == 'jpg' ){
            return 'doctype:image';
        } else if(extension == 'pdf'){
            return 'doctype:pdf';
        } else if(extension == 'doc' || extension == 'docx' || extension == 'msword'){
            return 'doctype:word';
        }
        else {
            return 'standard:document_preview';
        }
    }

    showAllFiles(){
        var compDefinition = {
            componentDef: "c:trionViewAllEmailFiles",
            attributes: {
                recordId : this.caseIdParam
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    openCaseRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseDetails.Id,
                actionName: 'view'
            }
        });
    }
}