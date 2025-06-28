import { LightningElement, api, wire } from 'lwc';
//import { refreshApex } from '@salesforce/apex';
import hasDeletePermission from '@salesforce/customPermission/SharePoint_File_Delete_Custom_Permission';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import {getRecord} from 'lightning/uiRecordApi';
import deleteAction from '@salesforce/apex/GetCsvUsingSPId.deleteSharepointId';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class filePreview extends LightningElement {
  @api fileDetails;
  profileName;
  showModal = false;
  showFrame = false;

  validFormats = ["application/pdf","image/jpeg", "zip","rfc822", "application/msword","octet-stream", "application/octet-stream","image/png","application/vnd.ms-excel","audio/basic","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","image/gif","application/x-zip-compressed","text/html","application/rtf","image/tiff","image/bmp","application/x-pdf","video/mp4","audio/x-wav","application/vnd.openxmlformats-officedocument.wordprocessingml.document","audio/wav","application/x-msexcel","image/other","text/plain","image/tif","video/3gpp","text/x-vcard","application/msworks","message/disposition-notification","text/calendar","text/rfc822-headers","message/rfc822","application/vnd.openxmlformats-officedocument.wordprocessingml","text/xml","application/MSEXCEL","audio/x-m4a","image/pjpeg","image/jpg","message/delivery-status","image/x-citrix-jpeg","application/zip","image/x-citrix-gif","image/heic","application/x-microsoft-rpmsg-message","application/vnd.ms-word.document.macroenabled.12","text/directory","application/binary","application/pkcs7-signature","text/MSEXCEL","application/vnd.ms-xpsdocument","application/vnd.ms-excel.sheet.macroenabled.12","application/x-any","tiff","gif","docx","txt","html","doc","xls","wav","vcf","tif","application","letterhead","p7s","xps","docm","rpmsg","mp4","png;_modification-date=_wed,","wmz","emz","csv","xlsm","mov","bmp","xml","ics","xlsb","dms","banta","dat","mp3","amr","go","odt","heic","oft","jfif","bin","3gp","larkin group","mht","~tmp","url","page jim's body shop, llc","axd","jpe","avi","svg","pdfjess","aspx","dot","png","pages","jpg 2","webp","8fea0330","pdf new","dotx","pnm","lqm","mail","ppt","3gpp","h","heif","one","imageserver","dsn","hdr","ico","snote","crdownload","ogg","clk"];
  get isValidExtension(){
    console.log('>< is valid format '+ this.validFormats.includes(this.fileDetails.fileExtension)+' - '+this.fileDetails.fileExtension);
    return this.validFormats.includes(this.fileDetails.fileExtension);
  }

  @api show() {
    console.log("###iframeurl : " + this.fileDetails.iframeUrl);
    if (this.fileDetails.fileExtension === "pdf" || this.fileDetails.fileExtension === "docx" ) {this.showFrame = true;}
    else {this.showFrame = false;}
    this.showModal = true;
    console.log("###showFrame : " + this.showFrame);
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [PROFILE_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
          this.error = error ; 
        } else if (data) {
            this.profileName = data.fields.Profile.value.fields.Name.value;        
        }
    }

  get isDeleteEnabled() {
    console.log(' >< user profile '+this.profileName);
        if(hasDeletePermission || this.profileName === 'System Administrator'){
          return true;
        } else { return false; }
  }

  closeModal() {
        console.log('Closing modal' + JSON.stringify( this.fileDetails) );
    this.showModal = false;
  }

   downloadFile() {
        // Get the URL of the image displayed in the iframe
        // const iframe = this.template.querySelector('iframe');
        // const imageSrc = iframe.src;

        if (this.fileDetails.fileExtension === "pdf" ){
          let anchor = document.createElement('a');
          anchor.href = this.fileDetails.downloadUrl;
          anchor.download = 'image.jpg'; // Specify the desired file name for the downloaded image
          anchor.click();
          this.downloadingToastMessage();
        }
        if(this.isValidExtension == true){
          let anchor = document.createElement('a');
          anchor.href = this.fileDetails.downloadUrl;
          anchor.download = 'image.jpg'; // Specify the desired file name for the downloaded image
          anchor.click();
          this.downloadingToastMessage();
        }
        if(this.fileDetails.fileExtension === "jpg" || this.fileDetails.fileExtension === "jpeg" ){
          let anchor = document.createElement('a');
          anchor.href = this.fileDetails.downloadUrl;
          anchor.download = 'image.jpg'; // Specify the desired file name for the downloaded image
          anchor.click();
          this.downloadingToastMessage();
        }
        if(this.fileDetails.fileExtension === "png"){
          let anchor = document.createElement('a');
          anchor.href = this.fileDetails.downloadUrl;
          anchor.download = 'image.png'; // Specify the desired file name for the downloaded image
          anchor.click();
          this.downloadingToastMessage();
        }
    }

  downloadingToastMessage(){
    const evt = new ShowToastEvent({
          title: 'Downloading..',
          message: `The file ${this.fileDetails.name} is being downloaded.` ,
          variant: 'info',
        });
        this.dispatchEvent(evt);
  }

  connectedCallback() {
    //this.disableScrolling();
  }
    disableScrolling(){
      scrollTop = window.pageYOffset ;//|| document.documentElement.scrollTop;
      scrollLeft = window.pageXOffset ;//|| document.documentElement.scrollLeft;
      window.scrollTo = this.scrollTo(scrollLeft, scrollTop);
    }
    scrollTo(scrollLeft, scrollTop) {
      window.scrollTo(scrollLeft, scrollTop);
    }

    deleteFile(){
      deleteAction({ fileSharepointId: this.fileDetails.fileId })
        .then(result => {
          console.log('Result', result);
          const evt = new ShowToastEvent({
            title: 'Successfully Deleted!',
            message: `The file ${this.fileDetails.name} has been deleted successfully.` ,
            variant: 'success',
          });
          this.dispatchEvent(evt);
          window.location.reload(); 
        })
        .catch(error => {
          console.error('Error:', error);
          const evt = new ShowToastEvent({
            title: 'Delete Failed!',
            message: `Theere was an Error when deleting the file ${this.fileDetails.name}.` ,
            variant: 'error',
          });
          this.dispatchEvent(evt);
      });
    }
}