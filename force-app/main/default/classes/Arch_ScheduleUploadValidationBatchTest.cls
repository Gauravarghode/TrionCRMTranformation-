@isTest
public class Arch_ScheduleUploadValidationBatchTest {
	@isTest
    public static void ScheduleTest(){
        Arch_ScheduleUploadValidationBatch scheduler = new Arch_ScheduleUploadValidationBatch();
        System.schedule('Test Arch_ScheduleSharePointFA', '0 0 * * * ?', scheduler);
    }
}