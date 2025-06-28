@isTest 
public class TestCasesSidebar{ 
static testMethod void myUnitTest() { 
// add a new case 
Case cs = new Case(type = 'Other',status = '0-New'); 
insert cs; 

CasesSidebarController csc = new CasesSidebarController(); 

// the number of cases with status=0-New is at least 1 
System.assert(csc.caseCountByStatus.get('0-New') >0); 

} 

}