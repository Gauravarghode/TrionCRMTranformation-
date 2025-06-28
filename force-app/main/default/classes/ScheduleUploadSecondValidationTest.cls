@isTest
public class ScheduleUploadSecondValidationTest {
	@isTest
    public static void SecondValidationTesting(){
        //Arch_ScheduleUploadValidationBatch scheduler = new Arch_ScheduleUploadValidationBatch();
        //System.schedule('Test Arch_ScheduleSharePointFA', '0 0 * * * ?', scheduler);
        Arch_ScheduleUploadSecondValidationBatch scheduler1 = new Arch_ScheduleUploadSecondValidationBatch();
        System.schedule('Test Arch_ScheduleSharePointFA-2', '0 0 * * * ?', scheduler1);
        
    }
}