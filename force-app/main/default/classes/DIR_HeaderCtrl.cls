/***************************************************************************************
* Name: DIR_HeaderCtrl
* Created by Seven Points {DateCreated 5/29/2018} 
----------------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as a ctrl for visualforce component DIR_Header.vfc
----------------------------------------------------------------------------------------
* Unit Test: DIR_HeaderCtrlTest.cls
----------------------------------------------------------------------------------------
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Seven Points 5/29/2018 INITIAL DEVELOPMENT
****************************************************************************************/

public class DIR_HeaderCtrl {
    
    public string searchString {get;set;}
    public string searchError {get;set;}
    public Boolean isShowReturnToDirectoryBtn {get;set;}
    
    public DIR_HeaderCtrl(){
        searchError = '';
        isShowReturnToDirectoryBtn = false;
        if(ApexPages.currentPage().getParameters().containsKey('search')){
            searchString = ApexPages.currentPage().getParameters().get('search');
            isShowReturnToDirectoryBtn = true;
        }
        if(ApexPages.currentPage().getParameters().containsKey('searchError')){
            searchError = ApexPages.currentPage().getParameters().get('searchError');
        }
    }
    
    public pageReference doSearch(){
        pageReference pg = null;
        searchError = '';
        if (searchString != '' && searchString != null) { 
            searchString = searchString.trim();
            if (searchString.length() < 2) {
                searchError = 'You must include at least two characters in the search string.';
            }
            if (searchError == '') { 
                pg = new pageReference('/apex/DIR_Search?search=' + searchString + '&searchError=' + searchError);
                pg.setRedirect(true);
            }
        }
        return pg;
    }
    
    public pageReference doReturnToDirectory(){
        pageReference pg = null; 
        pg = new pageReference('/apex/DIR_Directory');
        pg.setRedirect(true);
        return pg;
    }
    
}