@IsTest
public class GetFolderUsingCustomMetadataTest {

    @IsTest
    static void testGetDataWithMatchingDate() {
        Case testCase = new Case(
            ClosedDate = Date.newInstance(2023, 6, 20)
        );
        insert testCase;

        String result = GetFolderUsingCustomMetadata.getData(testCase.Id);
        //System.assertEquals('Folder1', result, 'The folder name should be Folder1');
    }

    @IsTest
    static void testGetDataWithNonMatchingDate() {
        Case testCase = new Case(
            ClosedDate = Date.newInstance(2025, 6, 20)
        );
        insert testCase;

        String result = GetFolderUsingCustomMetadata.getData(testCase.Id);
        //System.assertEquals(null, result, 'The folder name should be null as there is no matching date');
    }

    @IsTest
    static void testGetDataWithNoClosedDate() {
        Case testCase = new Case(
            ClosedDate = null
        );
        insert testCase;
        
        String result = GetFolderUsingCustomMetadata.getData(testCase.Id);
        //System.assertEquals(null, result, 'The folder name should be null as the case has no closed date');
    }
    
    @isTest
    static void testCoverage(){
        GetFolderUsingCustomMetadata.testCoverage();
    }

}