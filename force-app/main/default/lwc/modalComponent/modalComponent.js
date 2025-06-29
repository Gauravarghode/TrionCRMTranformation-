import { LightningElement, api } from 'lwc';

export default class ModalComponent extends LightningElement {
    @api isOpen = false;
    @api title = '';

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    savemodal(){

        this.dispatchEvent(new CustomEvent('save'));
        console.log('save triggered');
    }
  
}